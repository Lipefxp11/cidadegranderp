#include "BCGBridge.h"
#include "Navigation46.h"
#include "Wardrobe47.h"
#include "main.h"
#include "game/game.h"
#include "net/netgame.h"
#include "net/textdrawpool.h"
#include "java/jniutil.h"
#include "vendor/encoding/encoding.h"
#include "voice/Plugin.h"
#include "voice/include/util/KeyFilter.h"
#include <atomic>
#include <deque>
#include <mutex>
#include <cmath>
#include <map>
extern CGame* pGame;
extern CNetGame* pNetGame;
namespace BCGBridge {
struct Request {int op,a,b,c;std::string text;};
static std::mutex lock;
static std::deque<Request> requests;
static std::atomic<bool> ready{false};
static bool chatOpen=false;
static bool modal=false;
static bool gameMenu=false;
bool GameMenuOpen(){return gameMenu;}
bool ModalOpen(){return modal && Ready();}
static uint32_t controls[2]={0,0};
void GameMenu(bool open){gameMenu=open;controls[0]=controls[1]=0;Plugin::SetPTT(66,false);Emit(std::string("{\"type\":\"gameMenu45\",\"open\":")+(open?"true}":"false}"));}
bool ControlDown(int key){return key>=0&&key<2&&!modal&&!gameMenu&&Ready()&&controls[key]&&GetTickCount()-controls[key]<600;}
static bool hudRequested=false;
static uint32_t hudRequestTick=0;
void ConfirmServerUI(){hudRequested=true;}
static uint32_t tick=0;
static std::string lastNativeHud47;
static uint32_t lastNativeHudTick47=0;
static int dialog=-1;
struct MapMarker {float x,y;unsigned color,type;};
static std::map<unsigned,MapMarker> markers;
void Marker(unsigned id,float x,float y,unsigned color,unsigned type){if(std::isfinite(x)&&std::isfinite(y)&&markers.size()<256)markers[id]={x,y,color,type};}
void RemoveMarker(unsigned id){markers.erase(id);}
bool Ready(){return ready.load();}
void Dialog(int id){dialog=id;if(id>=0&&chatOpen)CloseChat();}
std::string Quote(const std::string& value){std::string out="\"";for(unsigned char c:value){if(c=='"'||c=='\\'){out+='\\';out+=char(c);}else if(c=='\n')out+="\\n";else if(c=='\r')out+="\\r";else if(c=='\t')out+="\\t";else if(c>=32)out+=char(c);}return out+'"';}
void Emit(const std::string& json){if(pJavaWrapper)pJavaWrapper->UiEvent(json.c_str());}
bool ChatOpen(){return chatOpen;}
bool OpenChat(){
    if(!Ready()||!pGame||!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED||dialog>=0)return false;
    if(chatOpen)return true;
    Plugin::SetPTT(66,false);chatOpen=true;pGame->EnableGameInput(false);
    Log("BCG CHAT editor opened");
    Emit("{\"type\":\"chatInput\",\"open\":true}");return true;
}
void CloseChat(){
    if(!chatOpen)return;chatOpen=false;
    if(pGame)pGame->EnableGameInput(true);
    Emit("{\"type\":\"chatInput\",\"open\":false}");
    Log("BCG CHAT editor closed");
}
void ResetSession(){
    Navigation46::Reset();
    Wardrobe47::Reset();
    lastNativeHud47.clear();lastNativeHudTick47=0;
    CloseChat();modal=false;gameMenu=false;controls[0]=controls[1]=0;dialog=-1;hudRequested=false;hudRequestTick=0;tick=0;markers.clear();
    {std::lock_guard<std::mutex> guard(lock);
        for(auto it=requests.begin();it!=requests.end();){
            if(it->op==0)++it;else it=requests.erase(it);
        }
    }
    Emit("{\"type\":\"sessionReset\"}");
    Log("BCG SESSION input and queued requests reset");
}
static void SendText(const std::string& utf8){
    // An empty op 2 submission from the single chat editor is a cancel.
    if(utf8.empty()){CloseChat();return;}
    const std::string text=Encoding::utf2cp(utf8);
    const bool valid=!text.empty()&&text.size()<=144&&text.find_first_of("\r\n")==std::string::npos&&text.find('\0')==std::string::npos;
    const bool connected=pNetGame&&pNetGame->GetGameState()==GAMESTATE_CONNECTED;
    const bool sent=valid&&connected&&(text[0]=='/'?pNetGame->SendChatCommand(text.c_str()):pNetGame->SendChatMessage(text.c_str()));
    Emit(std::string("{\"type\":\"chatResult\",\"ok\":")+(sent?"true":"false")+",\"text\":"+Quote(sent?"Solicitacao na fila de envio.":!connected?"Conexao indisponivel. Seu texto foi mantido.":!valid?"Use ate 144 caracteres sem quebra de linha.":"Falha ao enviar. Tente novamente.")+"}");
    if(sent)CloseChat();
}
void Queue(int op,int a,int b,int c,const std::string& text){if(text.size()>4096)return;std::lock_guard<std::mutex> guard(lock);if(requests.size()<128)requests.push_back({op,a,b,c,text});}
void Process(){std::deque<Request> batch;{std::lock_guard<std::mutex> guard(lock);batch.swap(requests);}for(const auto& r:batch){if(r.op==0){ready=r.a!=0;lastNativeHud47.clear();lastNativeHudTick47=0;if(!ready)CloseChat();continue;}if(r.op==5){if(r.a>=0&&r.a<2)controls[r.a]=r.b?GetTickCount():0;continue;}if(r.op==6){modal=r.a!=0;controls[0]=controls[1]=0;if(pGame)pGame->EnableGameInput(!modal);continue;}if(r.op==3){Plugin::SetPTT(r.a,r.b!=0&&!chatOpen);continue;}if(r.op==2){SendText(r.text);continue;}if(!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED)continue;auto text=Encoding::utf2cp(r.text);if(r.op==1&&text.size()<=255&&r.a==dialog){pNetGame->SendDialogResponse(r.a,r.b,r.c,text.c_str());dialog=-1;}else if(r.op==4&&pNetGame->GetTextDrawPool())pNetGame->GetTextDrawPool()->SubmitBCGClick(r.a);}
if(chatOpen&&(!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED))CloseChat();
Wardrobe47::Process();
if (!pNetGame || pNetGame->GetGameState()!=GAMESTATE_CONNECTED) {hudRequested=false;hudRequestTick=0;}
else if (Ready() && !hudRequested && (!hudRequestTick || GetTickCount()-hudRequestTick>=3000)) {
    hudRequestTick=GetTickCount();
    pNetGame->SendChatCommand("/bcgui31");
}
if(!Ready()||!pGame||!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED||GetTickCount()-tick<250)return;
tick=GetTickCount();auto ped=pGame->FindPlayerPed();if(!ped||!ped->m_pPed)return;
char json[512];
std::snprintf(json,sizeof json,
    "{\"type\":\"nativeHud\",\"health\":%.1f,\"armour\":%.1f,\"cash\":%d,\"hour\":%u,\"minute\":%u,\"voiceReady\":%s,\"talking\":%s}",
    ped->GetHealth(),ped->GetArmour(),pGame->GetLocalMoney(),
    pNetGame->m_pNetSet->byteWorldTime_Hour,pNetGame->m_pNetSet->byteWorldTime_Minute,
    KeyFilter::IsKeyAvailable(66)?"true":"false",Plugin::IsTransmitting()?"true":"false");
if(lastNativeHud47!=json||GetTickCount()-lastNativeHudTick47>=5000){lastNativeHud47=json;lastNativeHudTick47=GetTickCount();Emit(json);}
}
}
extern "C" JNIEXPORT void JNICALL Java_com_gta_game_ui_ChromiumUI_nativeRequest(JNIEnv* env,jclass,jint op,jint a,jint b,jint c,jbyteArray data){std::string text;if(data){auto len=env->GetArrayLength(data);if(len>4096)return;text.resize(len);env->GetByteArrayRegion(data,0,len,reinterpret_cast<jbyte*>(text.data()));}BCGBridge::Queue(op,a,b,c,text);}
