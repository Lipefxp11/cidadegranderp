
#include <cassert>
#include <cstdint>
#include <cstring>
#include <cstdio>
#include <string>
#include <vector>
#include <iostream>
#include <atomic>
#include <deque>
#include <mutex>
#include <map>
#include <cmath>
#include "BCGTouchCapture.h"
#include "vendor/raknet/BitStream.h"
#include "vendor/encoding/encoding.h"
constexpr unsigned MAX_PLAYERS=1004;
constexpr int GAMESTATE_WAIT_CONNECT=9,GAMESTATE_CONNECTING=13,GAMESTATE_RESTARTING=18,GAMESTATE_CONNECTED=5,HIGH_PRIORITY=1,RELIABLE=2,RELIABLE_ORDERED=3,SPECIAL_ACTION_CARRY=25,SPECIAL_ACTION_CUFFED=24;
int RPC_Chat=101,RPC_ServerCommand=50;
void Log(const char*,...){}
uint32_t gameTick=0;uint32_t GetTickCount(){return gameTick;}

struct AudioStream{void Stop(bool){}};AudioStream* pAudioStream=nullptr;
struct SpeakerList{static void Hide(){}};struct MicroIcon{static void Hide(){}};
struct Network{static inline int starts=0;static void OnRaknetConnect(const char*,int){starts++;}};
struct Client {
 int id=-1,calls=0,connects=0,disconnects=0,mode=-1;bool allow=true;void Disconnect(int){disconnects++;}template<class... A>void Connect(A...){connects++;}std::vector<unsigned char> data;
 template<class... A> bool RPC(int* rpc,RakNet::BitStream* bits,int priority,int reliability,A...){mode=reliability;id=*rpc;calls++;data.assign(bits->GetData(),bits->GetData()+bits->GetNumberOfBytesUsed());return allow;}
};
struct CPlayerPed {
 void* m_pPed=this;int clears=0,applied=0,m_iCarryState=0,m_iCuffedState=0;std::string animation;
 bool IsAnimationPlaying(const char*){return false;}bool IsCarry(){return m_iCarryState!=0;}bool IsCuffed(){return m_iCuffedState!=0;}
 template<class... A> void ApplyAnimation(const char* name,A...){applied++;animation=name;}
 void ClearAllTasks(){clears++;m_iCarryState=0;}void ProcessCuffAndCarry(){}
 float GetHealth(){return 100;}float GetArmour(){return 0;}
 void ProcessSpecialAction(int);
};
struct CLocalPlayer {CPlayerPed ped;CPlayerPed* GetPlayerPed(){return &ped;}};
struct CRemotePlayer {CPlayerPed ped;bool m_bAppliedAnimation=true;CPlayerPed* GetPlayerPed(){return &ped;}};
struct CPlayerPool {CLocalPlayer local;CRemotePlayer remote;bool remoteActive=true;int deletes=0;void Delete(int,int){deletes++;remoteActive=false;}const char* GetLocalPlayerName(){return "Teste_BCG";}int GetLocalPlayerID(){return 0;}CLocalPlayer* GetLocalPlayer(){return &local;}bool GetSlotState(int id){return id==1&&remoteActive;}CRemotePlayer* GetAt(int id){return id==1?&remote:nullptr;}};
struct TextDrawPool {void SubmitBCGClick(int){};bool onTouchEvent(int,int,int,int){return true;}};
struct CNetGame {
 Client* m_pRakClient;int state=5;CPlayerPool pool;TextDrawPool td;struct Settings {unsigned byteWorldTime_Hour=0,byteWorldTime_Minute=0;} settings,*m_pNetSet=&settings;
 int m_bcgPhase=5,m_iPort=7825,restarts=0;unsigned m_bcgAttempts=0,m_dwLastConnectAttempt=0,m_bcgJoinTick=0;char m_szHostOrIp[64]="190.102.40.7";
 void NotifyConnection(int,const char*);void Packet_DisconnectionNotification(Packet*);void Packet_ConnectionLost(Packet*);void ProcessConnecting();void SetGameState(int v){state=v;}void ShutdownForGameModeRestart(){restarts++;state=GAMESTATE_RESTARTING;}
 int GetGameState(){return state;}int GetBCGPhase(){return m_bcgPhase;}bool SendChatMessage(const char*);bool SendChatCommand(const char*);
 void SendDialogResponse(int,int,int,const char*){}TextDrawPool* GetTextDrawPool(){return &td;}CPlayerPool* GetPlayerPool(){return &pool;}
};
struct CGame {bool input=true,paused=false;bool IsGamePaused(){return paused;}bool IsGameInputEnabled(){return input;}void EnableGameInput(bool value){input=value;}CPlayerPed* FindPlayerPed(){return nullptr;}int GetLocalMoney(){return 0;}};
struct CJavaWrapper {std::vector<std::string> events;void UiEvent(const char* value){events.emplace_back(value);}void ConnectionStatus(int,const char*){}};
struct Plugin {static inline std::vector<bool> ptt;static void SetPTT(int,bool down){ptt.push_back(down);}static bool IsTransmitting(){return false;}};
struct KeyFilter {static bool IsKeyAvailable(int){return false;}};
namespace BCGBridge {void CloseChat();bool OpenChat();}
struct ImVec2{float x,y;ImVec2(float a,float b):x(a),y(b){}};enum class TouchType{push,move,pop};
struct VoiceButton{bool handleTouch(ImVec2,int,int){return false;}};struct DialogWidget{bool visible(){return false;}};
struct Keyboard {bool shown=false;bool visible(){return shown;}void show(void*){shown=true;}};
struct TabList {bool visible(){return false;}};
struct Chat {int info=0;bool focused=false;bool visible(){return true;}bool contains(ImVec2 p){return p.x>=100&&p.x<500&&p.y>=10&&p.y<200;}void touchEvent(ImVec2 p,TouchType t){if(t==TouchType::push)focused=contains(p);if(t==TouchType::pop){if(focused&&contains(p))touchPopEvent();focused=false;}}template<class... A>void addDebugMessage(A...){}void touchPopEvent();void keyboardEvent(const std::string&);void addInfoMessage(const char*){info++;}};
struct UI {VoiceButton mic;DialogWidget modal;void touchEvent(ImVec2,TouchType){}VoiceButton* voicebutton(){return &mic;}DialogWidget* dialog(){return &modal;}Keyboard keys;TabList tabs;Chat chatWidget;Keyboard* keyboard(){return &keys;}TabList* playertablist(){return &tabs;}Chat* chat(){return &chatWidget;}};
Client client;CNetGame net{&client};CNetGame* pNetGame=&net;CGame game;CGame* pGame=&game;CJavaWrapper java;CJavaWrapper* pJavaWrapper=&java;UI ui;UI* pUI=&ui;
std::vector<int> gtaTouches;void AND_TouchEvent(int type,int,int,int){gtaTouches.push_back(type);}
using PLAYERID=uint16_t;
int checks=0;void check(bool ok,const char* name){checks++;if(!ok){std::cerr<<"FAIL "<<name<<"\n";std::abort();}std::cout<<"PASS "<<name<<"\n";}
bool eventHas(const std::string& needle){for(const auto& e:java.events)if(e.find(needle)!=std::string::npos)return true;return false;}
bool CNetGame::SendChatMessage(const char* szMsg)
{
    if (!szMsg || !m_pRakClient || GetGameState()!=GAMESTATE_CONNECTED) {
        Log("BCG CHAT message rejected: connection unavailable"); return false;
    }
    const size_t length = strnlen(szMsg,145);
    if (!length || length>144 || strchr(szMsg,'\n') || strchr(szMsg,'\r')) return false;
    RakNet::BitStream bsSend;
    uint8_t byteTextLen=static_cast<uint8_t>(length);
    bsSend.Write(byteTextLen);bsSend.Write(szMsg,byteTextLen);
    const bool sent=m_pRakClient->RPC(&RPC_Chat,&bsSend,HIGH_PRIORITY,RELIABLE,0,false,UNASSIGNED_NETWORK_ID,NULL);
    Log("BCG CHAT message bytes=%u queued=%d",byteTextLen,sent);
    return sent;
}
bool CNetGame::SendChatCommand(const char* szCommand)
{
    if (!szCommand || !m_pRakClient || GetGameState()!=GAMESTATE_CONNECTED) {
        Log("BCG CHAT command rejected: connection unavailable"); return false;
    }
    const size_t length=strnlen(szCommand,145);
    if (!length || length>144 || szCommand[0]!='/' || strchr(szCommand,'\n') || strchr(szCommand,'\r')) return false;
    RakNet::BitStream bsParams;
    int iStrlen=static_cast<int>(length);
    bsParams.Write(iStrlen);bsParams.Write(szCommand,iStrlen);
    const bool sent=m_pRakClient->RPC(&RPC_ServerCommand,&bsParams,HIGH_PRIORITY,RELIABLE,0,false,UNASSIGNED_NETWORK_ID,NULL);
    Log("BCG CHAT command bytes=%d queued=%d",iStrlen,sent);
    return sent;
}
namespace BCGBridge {
struct Request {int op,a,b,c;std::string text;};
static std::mutex lock;
static std::deque<Request> requests;
static std::atomic<bool> ready{false};
static bool chatOpen=false;
static bool modal=false;
static uint32_t controls[2]={0,0};
bool ControlDown(int key){return key>=0&&key<2&&!modal&&Ready()&&controls[key]&&GetTickCount()-controls[key]<600;}
static bool hudRequested=false;
static uint32_t tick=0;
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
    CloseChat();modal=false;controls[0]=controls[1]=0;dialog=-1;hudRequested=false;tick=0;markers.clear();
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
void Process(){std::deque<Request> batch;{std::lock_guard<std::mutex> guard(lock);batch.swap(requests);}for(const auto& r:batch){if(r.op==0){ready=r.a!=0;if(!ready)CloseChat();continue;}if(r.op==5){if(r.a>=0&&r.a<2)controls[r.a]=r.b?GetTickCount():0;continue;}if(r.op==6){modal=r.a!=0;controls[0]=controls[1]=0;if(pGame)pGame->EnableGameInput(!modal);continue;}if(r.op==3){Plugin::SetPTT(r.a,r.b!=0&&!chatOpen);continue;}if(r.op==2){SendText(r.text);continue;}if(!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED)continue;auto text=Encoding::utf2cp(r.text);if(r.op==1&&text.size()<=255&&r.a==dialog){pNetGame->SendDialogResponse(r.a,r.b,r.c,text.c_str());dialog=-1;}else if(r.op==4&&pNetGame->GetTextDrawPool())pNetGame->GetTextDrawPool()->SubmitBCGClick(r.a);}
if(chatOpen&&(!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED))CloseChat();
if (!pNetGame || pNetGame->GetGameState()!=GAMESTATE_CONNECTED || pNetGame->GetBCGPhase()!=5) hudRequested=false;
else if (Ready() && !hudRequested) {
    hudRequested=pNetGame->SendChatCommand("/bcgui31");
    if(hudRequested)Log("BCG V031 requested server HUD on native game thread");
}
if(!Ready()||!pGame||!pNetGame||pNetGame->GetGameState()!=GAMESTATE_CONNECTED||GetTickCount()-tick<250)return;
tick=GetTickCount();auto ped=pGame->FindPlayerPed();if(!ped||!ped->m_pPed)return;
char json[512];
std::snprintf(json,sizeof json,
    "{\"type\":\"nativeHud\",\"health\":%.1f,\"armour\":%.1f,\"cash\":%d,\"hour\":%u,\"minute\":%u,\"voiceReady\":%s,\"talking\":%s}",
    ped->GetHealth(),ped->GetArmour(),pGame->GetLocalMoney(),
    pNetGame->m_pNetSet->byteWorldTime_Hour,pNetGame->m_pNetSet->byteWorldTime_Minute,
    KeyFilter::IsKeyAvailable(66)?"true":"false",Plugin::IsTransmitting()?"true":"false");
Emit(json);
}
}

void Chat::touchPopEvent()
{
    if (!pUI || pUI->keyboard()->visible() || pUI->playertablist()->visible()) return;

    // Restore the original client keyboard and direct native RPC path.
    pUI->keyboard()->show(this);
}
void Chat::keyboardEvent(const std::string& input)
{
    // Native KeyboardInput already stores SA-MP CP1252 bytes.
    if (!pNetGame || input.empty() || input.size() > 144 ||
        input.find_first_of("\r\n") != std::string::npos ||
        input.find('\0') != std::string::npos) return;
    const bool sent=input.front()=='/'?pNetGame->SendChatCommand(input.c_str()):pNetGame->SendChatMessage(input.c_str());
    if (!sent && pUI) pUI->chat()->addInfoMessage("Conexao indisponivel. Nao foi possivel enviar.");
}
void ScrClearPlayerAnimations(RPCParameters* rpcParams)
{
    if (!rpcParams || !rpcParams->input || rpcParams->numberOfBitsOfData < 16 || !pNetGame) return;
    RakNet::BitStream bsData(reinterpret_cast<unsigned char*>(rpcParams->input),
        (rpcParams->numberOfBitsOfData + 7) / 8, false);
    PLAYERID playerId;
    if (!bsData.Read(playerId) || playerId >= MAX_PLAYERS) return;
    CPlayerPool* pool=pNetGame->GetPlayerPool();
    if (!pool) return;
    CPlayerPed* ped=nullptr;
    if (playerId==pool->GetLocalPlayerID()) {
        if (pool->GetLocalPlayer()) ped=pool->GetLocalPlayer()->GetPlayerPed();
    } else if (pool->GetSlotState(playerId) && pool->GetAt(playerId)) {
        CRemotePlayer* remote=pool->GetAt(playerId);
        ped=remote->GetPlayerPed();remote->m_bAppliedAnimation=false;
    }
    if (!ped || !ped->m_pPed) return;
    ped->ClearAllTasks();
    Log("BCG ANIM cleared server animation for player=%u",playerId);
}
void CPlayerPed::ProcessSpecialAction(int iAction)
{
    if (iAction == SPECIAL_ACTION_CARRY && !IsAnimationPlaying("CRRY_PRTIAL"))
    {
        ApplyAnimation("CRRY_PRTIAL", "CARRY", 4.1, 0, 0, 0, 1, 1);

        m_iCarryState = 1;

        return;
    }

    if (iAction != SPECIAL_ACTION_CARRY && IsCarry())
    {
        // Replaying the same partial carry animation here leaves one arm
        // raised while walking/running after the carried object is removed.
        ClearAllTasks();

        m_iCarryState = 0;

        return;
    }

    if (iAction == SPECIAL_ACTION_CUFFED)
    {
        if(m_iCuffedState)
            ProcessCuffAndCarry();
        else
            m_iCuffedState = 1;

        return;
    }

    if (iAction != SPECIAL_ACTION_CUFFED && IsCuffed())
    {
        m_iCuffedState = 0;

        return;
    }
}
void CNetGame::NotifyConnection(int phase, const char* message)
{
    if(phase==0 || phase==1 || phase==6 || phase==7)BCGBridge::ResetSession();
    if(m_bcgPhase == phase)return;
    m_bcgPhase=phase;
    if (phase != 5) Plugin::SetPTT(66, false);
    Log("BCG CONNECTION state=%d endpoint=%s:%d message=%s",phase,m_szHostOrIp,m_iPort,message);
    if(pUI)pUI->chat()->addDebugMessage("%s",message);
    if(pJavaWrapper)pJavaWrapper->ConnectionStatus(phase,message);
    if(phase==2)m_bcgJoinTick=GetTickCount();
}
void CNetGame::Packet_DisconnectionNotification(Packet *pkt)
{
    Packet_ConnectionLost(pkt);
    NotifyConnection(6,"O servidor encerrou a conexao. Nova tentativa em alguns segundos...");
}
void CNetGame::Packet_ConnectionLost(Packet *pkt)
{
	if (m_pRakClient) {
		m_pRakClient->Disconnect(0);
	}

	NotifyConnection(6,"Conexao perdida. Reconectando ao servidor...");
    m_dwLastConnectAttempt=GetTickCount();
    m_bcgAttempts=std::max(2u,m_bcgAttempts);
	ShutdownForGameModeRestart();

	CPlayerPool *pPlayerPool = GetPlayerPool();
	if (pPlayerPool) {
		for (PLAYERID playerId = 0; playerId < MAX_PLAYERS; playerId++) {
			if (pPlayerPool->GetSlotState(playerId) == true) {
				pPlayerPool->Delete(playerId, 0);
			}
		}
	}

	if (pAudioStream) {
		pAudioStream->Stop(true);
	}

	SetGameState(GAMESTATE_WAIT_CONNECT);

	SpeakerList::Hide();
	MicroIcon::Hide();
}
void CNetGame::ProcessConnecting()
{
	if (GetTickCount() - m_dwLastConnectAttempt > (m_bcgAttempts==0 ? 1000 : std::min(30000u,3000u+m_bcgAttempts*1000u)))
	{
		//if (pUI) pUI->chat()->addDebugMessage("Connecting to %s:%d...", m_szHostOrIp, m_iPort);
		char notice[350];
        snprintf(notice,sizeof notice,"Conectando a %s:%d...",m_szHostOrIp,m_iPort);
        NotifyConnection(1,notice);
        ++m_bcgAttempts;

		m_pRakClient->Connect(m_szHostOrIp, m_iPort, 0, 0, 2);

		// voice fix voice not connect when restart
		Network::OnRaknetConnect(m_szHostOrIp, m_iPort);

		m_dwLastConnectAttempt = GetTickCount();
		SetGameState(GAMESTATE_CONNECTING);
	}
}
void AND_TouchEvent_hook(int type, int num, int posX, int posY)
{
    static BCGTouchCapture chatGesture;
    // imgui
    //bool bRet = pUI->OnTouchEvent(type, num, posX, posY);

    if (pGame->IsGamePaused()) {
        chatGesture.Reset();
        Plugin::SetPTT(66, false);
        return AND_TouchEvent(type, num, posX, posY);
    }

    if (pUI != nullptr)
    {
        const ImVec2 position(posX, posY);
        const bool chatHit = !BCGBridge::ChatOpen() &&
            pNetGame && pNetGame->GetGameState() == GAMESTATE_CONNECTED &&
            pUI->chat()->visible() && pUI->chat()->contains(position) &&
            !pUI->keyboard()->visible() && !pUI->dialog()->visible() &&
            !pUI->playertablist()->visible();
        if (chatGesture.Consume(type, num, chatHit)) {
            const auto event = type == 2 ? TouchType::push : type == 1 ? TouchType::pop : TouchType::move;
            pUI->chat()->touchEvent(position, event);
            return;
        }
        if (BCGBridge::ChatOpen()) {
            return;
        }
        if (!pUI->keyboard()->visible() && !pUI->dialog()->visible() &&
            pUI->voicebutton()->handleTouch(ImVec2(posX, posY), type, num)) return;
        switch (type)
        {
            case 2: // push
                pUI->touchEvent(ImVec2(posX, posY), TouchType::push);
                break;

            case 3: // move
                pUI->touchEvent(ImVec2(posX, posY), TouchType::move);
                break;

            case 1: // pop
                pUI->touchEvent(ImVec2(posX, posY), TouchType::pop);
                break;
        }

        if (pUI->keyboard()->visible() || pUI->dialog()->visible()) {
            AND_TouchEvent(1, 0, 0, 0);
            return;
        }
        else
        {
            if (pNetGame && pNetGame->GetTextDrawPool())
             {
                if (!pNetGame->GetTextDrawPool()->onTouchEvent(type, num, posX, posY)) {
                   return AND_TouchEvent(1, 0, 0, 0);
                }
             }
        }
    }

    if (pGame->IsGameInputEnabled())
        AND_TouchEvent(type, num, posX, posY);
    else
        AND_TouchEvent(1, 0, 0, 0);
}

int main(){
 BCGBridge::Queue(0,0,0,0,"");BCGBridge::Process();client.calls=0;java.events.clear();
 ui.chat()->touchPopEvent();check(ui.keys.shown&&!BCGBridge::ChatOpen()&&java.events.empty(),"chat opens original client keyboard without Chromium readiness or WebView event");
 int before=client.calls;ui.chat()->touchPopEvent();check(client.calls==before,"repeated tap while native keyboard is visible does not send");
 ui.chat()->keyboardEvent("/ajuda");check(client.id==50&&client.mode==RELIABLE,"native command uses server-command RPC and RELIABLE");
 RakNet::BitStream command(client.data.data(),client.data.size(),false);int length=0;command.Read(length);char out[145]={};command.Read(out,length);check(length==6&&std::string(out,length)=="/ajuda","native command uses correct int32 length and original text");
 std::string latin=Encoding::utf2cp("Olá, ação");ui.chat()->keyboardEvent(latin);check(client.id==101&&client.mode==RELIABLE,"native text uses chat RPC and RELIABLE");
 RakNet::BitStream message(client.data.data(),client.data.size(),false);uint8_t n=0;message.Read(n);message.Read(out,n);check(std::string(out,n)==latin,"native CP1252 text is preserved without double conversion");
 ui.chat()->keyboardEvent(std::string(144,'a'));check(client.data.size()==145,"native 144-byte chat fits protocol");
 before=client.calls;ui.chat()->keyboardEvent(std::string(145,'a'));ui.chat()->keyboardEvent("");ui.chat()->keyboardEvent("a\nb");ui.chat()->keyboardEvent(std::string("a\0b",3));check(client.calls==before,"invalid native input never sends an RPC");
 client.allow=false;int info=ui.chatWidget.info;ui.chat()->keyboardEvent("falha");check(ui.chatWidget.info==info+1,"native failed queue displays an error in original chat");client.allow=true;
 net.state=GAMESTATE_WAIT_CONNECT;ui.chat()->keyboardEvent("offline");check(ui.chatWidget.info==info+2,"offline native send displays an error");net.state=5;
 ui.keys.shown=false;ui.chatWidget.focused=false;gtaTouches.clear();AND_TouchEvent_hook(2,0,200,100);AND_TouchEvent_hook(1,0,200,100);check(gtaTouches.empty()&&ui.keys.shown,"native chat gesture never opens GTA radar even when Chromium is disabled");
 ui.keys.shown=false;gtaTouches.clear();AND_TouchEvent_hook(2,0,900,800);AND_TouchEvent_hook(1,0,900,800);check(gtaTouches.size()==2,"normal gameplay touches remain available outside native chat");
 std::cout<<"V035 native chat checks="<<checks<<" failures=0\n";
}
