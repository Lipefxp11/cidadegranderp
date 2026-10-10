from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[2]
cpp = root / 'app/src/main/cpp/samp'

def function(file, name):
    source = (cpp / file).read_text()
    start = source.index(name)
    brace = source.index('{', start)
    depth = 1
    end = brace + 1
    while depth:
        if source[end] == '{': depth += 1
        if source[end] == '}': depth -= 1
        end += 1
    return source[start:end]

net = function('net/netgame.cpp', 'bool CNetGame::SendChatMessage(') + '\n' + function('net/netgame.cpp', 'bool CNetGame::SendChatCommand(')
bridge = (cpp / 'BCGBridge.cpp').read_text()
bridge = bridge[bridge.index('namespace BCGBridge {'):bridge.index('extern "C" JNIEXPORT')]
chat = function('gui/samp_widgets/chat.cpp', 'void Chat::touchPopEvent(') + '\n' + function('gui/samp_widgets/chat.cpp', 'void Chat::keyboardEvent(')
clear = function('net/scriptrpc.cpp', 'void ScrClearPlayerAnimations(')
special = function('game/playerped.cpp', 'void CPlayerPed::ProcessSpecialAction(')
reconnect='\n'.join(function('net/netgame.cpp',name) for name in ['void CNetGame::NotifyConnection(','void CNetGame::Packet_DisconnectionNotification(','void CNetGame::Packet_ConnectionLost(','void CNetGame::ProcessConnecting('])
touch=function('game/hooks.cpp','void AND_TouchEvent_hook(')

head = r'''
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
'''
main = r'''
int main(){
 BCGBridge::Queue(0,1,0,0,"");BCGBridge::Process();client.calls=0;java.events.clear();
 ui.chat()->touchPopEvent();check(BCGBridge::ChatOpen()&&!ui.keys.shown&&!game.input,"native chat tap opens exactly one composer and blocks gameplay");
 ui.chat()->touchPopEvent();check(java.events.size()==1,"repeated chat taps do not open a second editor");
 BCGBridge::Queue(2,0,0,0,"/testarchat");BCGBridge::Process();check(client.id==50&&client.calls==1,"composer command crosses queue to server-command RPC");
 RakNet::BitStream command(client.data.data(),client.data.size(),false);int length=0;command.Read(length);char out[145]={};command.Read(out,length);
 check(client.mode==RELIABLE,"chat command uses SA-MP reliable transport without ordered-channel dependency");check(length==11&&std::string(out,length)=="/testarchat","command uses exact int32 byte count");
 check(!BCGBridge::ChatOpen()&&game.input&&eventHas("\"ok\":true"),"queued send closes editor and releases controls");
 ui.chat()->touchPopEvent();BCGBridge::Queue(2,0,0,0,"Olá, ação e café");BCGBridge::Process();
 RakNet::BitStream message(client.data.data(),client.data.size(),false);uint8_t n=0;message.Read(n);message.Read(out,n);
 check(client.mode==RELIABLE,"chat message uses SA-MP reliable transport without ordered-channel dependency");check(client.id==101&&std::string(out,n)==Encoding::utf2cp("Olá, ação e café"),"UTF-8 composer text reaches chat RPC in CP1252 without double conversion");
 client.allow=false;ui.chat()->touchPopEvent();java.events.clear();BCGBridge::Queue(2,0,0,0,"nao perder texto");BCGBridge::Process();
 check(BCGBridge::ChatOpen()&&!game.input&&eventHas("\"ok\":false"),"failed queue keeps the editor open with a visible error");
 client.allow=true;BCGBridge::Queue(2,0,0,0,"nao perder texto");BCGBridge::Process();check(!BCGBridge::ChatOpen()&&game.input,"retry succeeds and releases controls");
 int before=client.calls;ui.chat()->touchPopEvent();BCGBridge::Queue(2,0,0,0,std::string(145,'a'));BCGBridge::Process();check(client.calls==before&&BCGBridge::ChatOpen(),"overlength input is rejected without losing the editor");
 BCGBridge::Queue(2,0,0,0,"a\nb");BCGBridge::Queue(2,0,0,0,std::string("a\0b",3));BCGBridge::Process();check(client.calls==before,"newline and embedded NUL never reach the server");
 BCGBridge::Queue(2,0,0,0,"");BCGBridge::Process();check(client.calls==before&&!BCGBridge::ChatOpen()&&game.input,"cancel never sends an empty RPC and releases controls");
 ui.chat()->touchPopEvent();BCGBridge::Queue(3,66,1,0,"");BCGBridge::Process();check(!Plugin::ptt.back(),"typing prevents microphone transmission");
 net.state=0;BCGBridge::Process();check(!BCGBridge::ChatOpen()&&game.input,"disconnect closes the editor without trapping input");net.state=5;
 ui.chat()->touchPopEvent();BCGBridge::Dialog(90);check(!BCGBridge::ChatOpen(),"server dialog cancels chat before displaying authentication");BCGBridge::Dialog(-1);
 BCGBridge::Process();java.events.clear();BCGBridge::Queue(2,0,0,0,std::string(144,'a'));BCGBridge::Process();check(client.id==101&&client.data.size()==145,"144-byte message fits the SA-MP protocol");
 uint16_t id=0;RPCParameters rpc{};rpc.input=reinterpret_cast<unsigned char*>(&id);rpc.numberOfBitsOfData=16;ScrClearPlayerAnimations(&rpc);check(net.pool.local.ped.clears==1,"real server clear-animation RPC clears local tasks");
 id=1;ScrClearPlayerAnimations(&rpc);check(net.pool.remote.ped.clears==1&&!net.pool.remote.m_bAppliedAnimation,"clear-animation RPC clears remote tasks and animation state");
 id=MAX_PLAYERS;ScrClearPlayerAnimations(&rpc);id=65535;ScrClearPlayerAnimations(&rpc);rpc.numberOfBitsOfData=8;ScrClearPlayerAnimations(&rpc);ScrClearPlayerAnimations(nullptr);check(net.pool.local.ped.clears==1&&net.pool.remote.ped.clears==1,"invalid or truncated animation RPC is safe");
 CPlayerPed actor;actor.m_iCarryState=1;actor.ProcessSpecialAction(0);check(actor.clears==1&&actor.applied==0&&!actor.m_iCarryState,"releasing carried object clears the pose instead of replaying partial carry");
 actor.ProcessSpecialAction(SPECIAL_ACTION_CARRY);check(actor.applied==1&&actor.m_iCarryState==1,"legitimate carry action still works");

 BCGBridge::ResetSession();net.state=5;net.m_bcgPhase=3;gtaTouches.clear();
 AND_TouchEvent_hook(2,0,150,100);AND_TouchEvent_hook(3,0,160,110);AND_TouchEvent_hook(1,0,160,110);
 check(gtaTouches.empty()&&BCGBridge::ChatOpen(),"real chat DOWN/MOVE/UP never reaches GTA or opens radar");
 BCGBridge::Queue(2,0,0,0,"/testarchat");BCGBridge::Process();check(!BCGBridge::ChatOpen()&&game.input&&client.id==50,"chat command after captured touch reaches RPC and releases gameplay");
 gtaTouches.clear();AND_TouchEvent_hook(2,0,800,400);AND_TouchEvent_hook(1,0,800,400);check(gtaTouches.size()==2,"normal gameplay touches remain available outside chat");
 gtaTouches.clear();AND_TouchEvent_hook(2,0,150,100);AND_TouchEvent_hook(1,0,800,400);check(gtaTouches.empty()&&!BCGBridge::ChatOpen(),"dragging out of chat consumes the whole gesture without opening an editor");
 BCGTouchCapture capture;check(capture.Consume(2,0,true)&&!capture.Consume(2,1,false)&&capture.Consume(1,0,false)&&!capture.Consume(1,1,false),"chat capture is independent per finger");
 BCGBridge::Dialog(91);BCGBridge::Queue(2,0,0,0,"/stale");const int sentBefore=client.calls;net.state=0;net.NotifyConnection(6,"retry");BCGBridge::Process();check(client.calls==sentBefore&&!BCGBridge::ChatOpen(),"session reset discards stale text and releases modal state");
 net.state=5;net.m_bcgPhase=3;check(BCGBridge::OpenChat(),"fresh session can open chat after stale dialog cleanup");BCGBridge::CloseChat();
 BCGBridge::Queue(0,0,0,0,"");BCGBridge::ResetSession();BCGBridge::Process();check(!BCGBridge::Ready(),"session reset preserves WebView lifecycle readiness requests");BCGBridge::Queue(0,1,0,0,"");BCGBridge::Process();
 gameTick=1000;net.state=5;net.m_bcgPhase=5;net.Packet_DisconnectionNotification(nullptr);check(net.state==GAMESTATE_WAIT_CONNECT&&net.restarts==1&&client.disconnects==1,"server disconnect cleans old pools and schedules reconnection instead of terminal state zero");
 gameTick=5999;int attempts=client.connects;net.ProcessConnecting();check(client.connects==attempts,"reconnect waits through anti-fast-connect cooldown");
 gameTick=6001;net.ProcessConnecting();check(net.state==GAMESTATE_CONNECTING&&client.connects==attempts+1&&Network::starts==1,"reconnect starts RakNet and voice transport after cooldown");
 net.state=5;net.m_bcgPhase=3;BCGBridge::OpenChat();BCGBridge::Queue(2,0,0,0,"segunda sessao");BCGBridge::Process();check(client.id==101&&!BCGBridge::ChatOpen()&&game.input,"second connected session sends normal chat successfully");
 net.state=5;net.m_bcgPhase=5;client.allow=false;BCGBridge::ResetSession();BCGBridge::Process();client.allow=true;BCGBridge::Process();check(client.id==50&&BCGBridge::hudRequested,"HUD subscription retries a failed queue on fresh session");

 std::cout<<"V031 native transport checks="<<checks<<" failures=0\n";
}
'''
file = root / 'verification/V031/native_transport_test.cpp'
file.write_text(head+net+'\n'+bridge+'\n'+chat+'\n'+clear+'\n'+special+'\n'+reconnect+'\n'+touch+'\n'+main)
executable = root / 'verification/V031/native_transport_test'
subprocess.run(['g++','-std=c++17','-O2','-I'+str(cpp),str(file),str(cpp/'vendor/raknet/BitStream.cpp'),str(cpp/'vendor/encoding/encoding.cpp'),'-o',str(executable)],check=True)
result = subprocess.run([str(executable)],check=True,capture_output=True,text=True)
(root/'verification/V031/native_transport_result.txt').write_text(result.stdout)
print(result.stdout)
