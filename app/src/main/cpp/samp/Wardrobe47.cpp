#include "main.h"
#include "Wardrobe47.h"
#include "game/game.h"
#include "net/netgame.h"
#include "game/PlayerPedData.h"
#include "vendor/armhook/patch.h"
#include <map>
#include <cstring>
#include <cstdio>
#include <dlfcn.h>
extern CGame* pGame;
extern CNetGame* pNetGame;
namespace Wardrobe47 {
namespace {
struct Item {const char* texture;const char* model;};
constexpr Item tops[]={{"player_torso","torso"},{"tshirtwhite","tshirt"},{"vestblack","vest"},{"tshirtproblk","tshirt"},{"hoodyablack","hoodya"}};
constexpr Item bottoms[]={{"player_legs","legs"},{"jeansdenim","jeans"},{"shortsgrey","shorts"},{"tracktrblue","tracktr"},{"legsblack","legs"}};
constexpr Item shoes[]={{"foot","feet"},{"sneakerbincblk","sneaker"},{"sneakerprowht","sneaker"},{"flipflop","flipflop"}};
constexpr Item heads[]={{"player_face","head"},{"bald","head"},{"highfade","head"},{"afro","afro"},{"cornrows","cornrows"},{"baldbeard","head"}};
struct Fit {int top,bottom,shoe,head;void* applied=nullptr;bool dirty=true;};
std::map<int,Fit> fits;
uint32_t lastApply=0;
using Set=void(*)(void*,const char*,const char*,int);
using Rebuild=void(*)(CPedGTA*,bool);
Set set{};Rebuild rebuild{};bool resolved=false;
bool available=false;
}
bool Packet(const char* message) {
    constexpr const char* prefix="[BCG:LOOK47]";
    if(std::strncmp(message,prefix,std::strlen(prefix))) return false;
    int id,top,bottom,shoe,head;char extra;
    if(std::sscanf(message+std::strlen(prefix),"%d|%d|%d|%d|%d%c",&id,&top,&bottom,&shoe,&head,&extra)!=5||id<0||id>=MAX_PLAYERS) return true;
    if(top==-1&&bottom==-1&&shoe==-1&&head==-1){fits.erase(id);return true;}
    if(top<0||top>=5||bottom<0||bottom>=5||shoe<0||shoe>=4||head<0||head>=6)return true;
    auto found=fits.find(id);
    if(found!=fits.end()&&found->second.top==top&&found->second.bottom==bottom&&found->second.shoe==shoe&&found->second.head==head)return true;
    fits[id]={top,bottom,shoe,head};return true;
}
void Reset(){fits.clear();lastApply=0;}
void SetAvailable(bool value){available=value;}
void Process() {
    if(!available||!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED||!pGame||fits.empty())return;
    if(!resolved&&CHook::lib){resolved=true;set=reinterpret_cast<Set>(dlsym(CHook::lib,"_ZN15CPedClothesDesc18SetTextureAndModelEPKcS1_i"));rebuild=reinterpret_cast<Rebuild>(dlsym(CHook::lib,"_ZN8CClothes13RebuildPlayerEP10CPlayerPedb"));}
    if(!set||!rebuild||GetTickCount()-lastApply<100)return;
    lastApply=GetTickCount();
    auto pool=pNetGame->GetPlayerPool();if(!pool)return;
    for(auto& [id,fit]:fits){
        CPlayerPed* player=nullptr;
        if(id==pool->GetLocalPlayerID())player=pGame->FindPlayerPed();
        else if(auto remote=pool->GetAt(id))player=remote->GetPlayerPed();
        if(!player||!player->m_pPed) {fit.applied=nullptr;continue;}
        if(player->GetHealth()<=0)continue;
        auto ped=player->m_pPed;
        if(ped->m_nModelIndex!=0||!ped->m_pPlayerData||!ped->m_pPlayerData->m_pPedClothesDesc||!ped->m_pRwObject){fit.applied=nullptr;continue;}
        if(!fit.dirty&&fit.applied==ped->m_pRwObject)continue;
        auto desc=ped->m_pPlayerData->m_pPedClothesDesc;
        const Item items[]={tops[fit.top],heads[fit.head],bottoms[fit.bottom],shoes[fit.shoe]};
        for(int part=0;part<4;part++)set(desc,items[part].texture,items[part].model,part);
        rebuild(ped,true);
        fit.applied=ped->m_pRwObject;fit.dirty=false;lastApply=GetTickCount();
        return; // Avoid rebuilding many streamed characters during the same frame.
    }
}
}
