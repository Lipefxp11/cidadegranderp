#include "main.h"
#include "Navigation46.h"
#include "NavigationGeometry46.h"
#include "RoadGraph48.h"
#include "BCGBridge.h"
#include "game/game.h"
#include "net/netgame.h"
#include "game/Mobile/MobileMenu/MobileMenu.h"
#include "vendor/armhook/patch.h"
#include "gui/gui.h"
#include <map>
#include <cmath>
#include <dlfcn.h>
#include <shadowhook.h>
extern CGame* pGame;
extern CNetGame* pNetGame;
namespace Navigation46 {
namespace {
using Transform=void(*)(CVector2D&,const CVector2D&);
Transform world{},screen{};
RoadGraph48::Graph graph;
bool graphTried=false,transformsTried=false;
std::vector<uint32_t> route;
std::map<int,CVector> blips;
CVector checkpoint{},target{},origin{};
bool hasCheckpoint=false,hasTarget=false;
uint32_t lastSearch=0,lastPoll=0,targetChangedAt=0;
int (*originalSetBlip)(int,CVector,unsigned int,int,char*){};
void (*originalClearBlip)(int){};
bool Valid(const CVector& v){return std::isfinite(v.x)&&std::isfinite(v.y)&&std::isfinite(v.z)&&std::abs(v.x)<6000&&std::abs(v.y)<6000&&std::abs(v.z)<2000;}
float Distance2(const CVector&a,const CVector&b){float x=a.x-b.x,y=a.y-b.y;return x*x+y*y;}
int SetBlip(int type,CVector position,unsigned int color,int display,char* name){
 int handle=originalSetBlip(type,position,color,display,name);
 blips.erase(handle);
 if(handle!=-1&&Valid(position)){if(blips.size()>=250)blips.erase(blips.begin());blips[handle]=position;}return handle;
}
void ClearBlip(int handle){blips.erase(handle);originalClearBlip(handle);}
}
void InstallHooks(){
 auto setHook=shadowhook_hook_sym_name("libGame.so","_ZN6CRadar12SetCoordBlipE9eBlipType7CVectorj12eBlipDisplayPc",reinterpret_cast<void*>(&SetBlip),reinterpret_cast<void**>(&originalSetBlip));
 auto clearHook=shadowhook_hook_sym_name("libGame.so","_ZN6CRadar9ClearBlipEi",reinterpret_cast<void*>(&ClearBlip),reinterpret_cast<void**>(&originalClearBlip));
 Log("BCG GPS48 coordinate hooks set=%d clear=%d",setHook!=nullptr,clearHook!=nullptr);
}
void Checkpoint(const CVector& position){checkpoint=position;hasCheckpoint=Valid(position);}
void Reset(){route.clear();blips.clear();hasCheckpoint=hasTarget=false;lastSearch=lastPoll=targetChangedAt=0;}
void Render(){
 if(!pGame||!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED){Reset();return;}
 if(BCGBridge::ModalOpen()||BCGBridge::GameMenuOpen()||pGame->GetActiveInterior()!=0)return;
 if(!transformsTried&&CHook::lib){transformsTried=true;world=reinterpret_cast<Transform>(dlsym(CHook::lib,"_ZN6CRadar35TransformRealWorldPointToRadarSpaceER9CVector2DRKS0_"));screen=reinterpret_cast<Transform>(dlsym(CHook::lib,"_ZN6CRadar32TransformRadarPointToScreenSpaceER9CVector2DRKS0_"));}
 if(!world||!screen)return;
 if(!graphTried&&g_pszStorage){graphTried=true;char path[1024];snprintf(path,sizeof(path),"%s/bcg_roads48.bin",g_pszStorage);Log("BCG GPS48 graph loaded=%d",graph.Load(path));}
 if(graph.nodes.empty())return;
 auto ped=pGame->FindPlayerPed();if(!ped||!ped->m_pPed)return;const CVector position=ped->m_pPed->GetPosition();if(!Valid(position))return;
 uint32_t now=GetTickCount();
 if(!lastPoll||now-lastPoll>=250){
  lastPoll=now;CVector next{};bool available=false;
  if(gMobileMenu&&gMobileMenu->waypoint_blip){auto it=blips.find(static_cast<int>(gMobileMenu->waypoint_blip));if(it!=blips.end()){next=it->second;available=true;}}
  if(!available&&hasCheckpoint&&pGame->m_bCheckpointsEnabled){next=checkpoint;available=true;}
  if(!available){route.clear();hasTarget=false;return;}
  if(!hasTarget||Distance2(next,target)>1){target=next;hasTarget=true;route.clear();targetChangedAt=now;}
 }
 if(!hasTarget||now-targetChangedAt<300)return;
 bool moved=Distance2(position,origin)>900;
 if(!lastSearch||(now-lastSearch>=3000&&(moved||route.empty()))||lastSearch<targetChangedAt){
  // Debounce rapid map changes, with a fixed ceiling on search work.
  if(lastSearch&&now-lastSearch<1000)return;
  lastSearch=now;origin=position;route=graph.Route(graph.Nearest(position.x,position.y,position.z),graph.Nearest(target.x,target.y,target.z));
 }
 if(Distance2(position,target)<225)return;
 auto draw=ImGui::GetBackgroundDrawList();
 for(size_t i=1;i<route.size();i++){
  auto& from=graph.nodes[route[i-1]];auto& to=graph.nodes[route[i]];
  CVector2D a{},b{},sa{},sb{};world(a,{from.x,from.y});world(b,{to.x,to.y});if(!ClipRadarSegment(a,b))continue;screen(sa,a);screen(sb,b);
  if(!std::isfinite(sa.x)||!std::isfinite(sa.y)||!std::isfinite(sb.x)||!std::isfinite(sb.y))continue;
  draw->AddLine({sa.x,sa.y},{sb.x,sb.y},IM_COL32(230,65,75,230),3.f);
 }
}
}
