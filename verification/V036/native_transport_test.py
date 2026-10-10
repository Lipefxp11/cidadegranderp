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
 int GetGameState(){return state;}int GetBCGPhase(){return m_bcgPhase;}bool SendChatMessage(const char*);bool SendChatCommand(const char*);bool HandleBCGControl(const char*);
 void SendDialogResponse(int,int,int,const char*){}TextDrawPool* GetTextDrawPool(){return &td;}CPlayerPool* GetPlayerPool(){return &pool;}
};
struct CGame {bool input=true,paused=false;bool IsGamePaused(){return paused;}bool IsGameInputEnabled(){return input;}void EnableGameInput(bool value){input=value;}CPlayerPed* FindPlayerPed(){return nullptr;}int GetLocalMoney(){return 0;}};
struct CJavaWrapper {std::vector<std::string> events;void UiEvent(const char* value){events.emplace_back(value);}void ConnectionStatus(int,const char*){}};
struct Plugin {static inline std::vector<bool> ptt;static void SetPTT(int,bool down){ptt.push_back(down);}static bool IsTransmitting(){return false;}};
struct KeyFilter {static bool IsKeyAvailable(int){return false;}};
namespace BCGBridge {void CloseChat();bool OpenChat();bool Ready();}
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
 BCGBridge::Queue(0,1,0,0,"");BCGBridge::Process();BCGBridge::ResetSession();net.m_bcgPhase=3;gameTick=100;client.calls=0;
 BCGBridge::Process();check(client.calls==1,"HUD negotiation starts during authentication phase");
 gameTick=1000;BCGBridge::Process();check(client.calls==1,"HUD negotiation does not flood commands");
 gameTick=3100;BCGBridge::Process();check(client.calls==2,"HUD negotiation retries without acknowledgement");
 net.HandleBCGControl("[BCG:UI]ACK|37");gameTick=6500;BCGBridge::Process();check(client.calls==2,"server acknowledgement stops HUD negotiation retries");
 net.m_bcgPhase=5;

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
 ui.keys.shown=false;BCGBridge::Queue(0,1,0,0,"");BCGBridge::Process();java.events.clear();ui.chat()->touchPopEvent();check(ui.keys.shown&&!BCGBridge::ChatOpen(),"Chromium HUD readiness never replaces original chat keyboard");
 gameTick=100;BCGBridge::Queue(5,0,1,0,"");BCGBridge::Process();check(BCGBridge::ControlDown(0),"held sprint arrives through native bridge");
 gameTick=701;check(!BCGBridge::ControlDown(0),"lost control release expires after 600ms");
 gameTick=800;BCGBridge::Queue(5,1,1,0,"");BCGBridge::Queue(6,1,0,0,"");BCGBridge::Process();check(!BCGBridge::ControlDown(1)&&!game.input,"dialog releases controls and freezes input");
 BCGBridge::Queue(6,0,0,0,"");BCGBridge::Process();check(game.input,"dialog close restores input");
 java.events.clear();std::string profileWire=Encoding::utf2cp("[BCG:UI]PROFILE|João Silva|19/11/2002|Brasileira|7|5000|500");check(net.HandleBCGControl(profileWire.c_str())&&eventHas("João Silva"),"server character metadata converts CP1252 to UTF8 once");
 std::cout<<"V036 native chat checks="<<checks<<" failures=0\n";
}
'''
file = root / 'verification/V036/native_transport_test.cpp'
file.write_text(head+net+'\n'+bridge+'\n'+chat+'\n'+clear+'\n'+special+'\n'+reconnect+'\n'+touch+'\n'+function('net/netgame.cpp','bool CNetGame::HandleBCGControl(')+'\n'+main)
executable = root / 'verification/V036/native_transport_test'
subprocess.run(['g++','-std=c++17','-O2','-I'+str(cpp),str(file),str(cpp/'vendor/raknet/BitStream.cpp'),str(cpp/'vendor/encoding/encoding.cpp'),'-o',str(executable)],check=True)
result = subprocess.run([str(executable)],check=True,capture_output=True,text=True)
(root/'verification/V036/native_transport_result.txt').write_text(result.stdout)
print(result.stdout)
