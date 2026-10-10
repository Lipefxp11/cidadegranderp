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
#include "vendor/raknet/BitStream.h"
#include "vendor/encoding/encoding.h"
constexpr unsigned MAX_PLAYERS=1004;
constexpr int GAMESTATE_CONNECTED=5,HIGH_PRIORITY=1,RELIABLE=2,SPECIAL_ACTION_CARRY=25,SPECIAL_ACTION_CUFFED=24;
int RPC_Chat=101,RPC_ServerCommand=50;
void Log(const char*,...){}
uint32_t GetTickCount(){return 0;}
struct Client {
 int id=-1,calls=0;bool allow=true;std::vector<unsigned char> data;
 template<class... A> bool RPC(int* rpc,RakNet::BitStream* bits,A...){id=*rpc;calls++;data.assign(bits->GetData(),bits->GetData()+bits->GetNumberOfBytesUsed());return allow;}
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
struct CPlayerPool {CLocalPlayer local;CRemotePlayer remote;int GetLocalPlayerID(){return 0;}CLocalPlayer* GetLocalPlayer(){return &local;}bool GetSlotState(int id){return id==1;}CRemotePlayer* GetAt(int id){return id==1?&remote:nullptr;}};
struct TextDrawPool {void SubmitBCGClick(int){};};
struct CNetGame {
 Client* m_pRakClient;int state=5;CPlayerPool pool;TextDrawPool td;struct Settings {unsigned byteWorldTime_Hour=0,byteWorldTime_Minute=0;} settings,*m_pNetSet=&settings;
 int GetGameState(){return state;}int GetBCGPhase(){return 5;}bool SendChatMessage(const char*);bool SendChatCommand(const char*);
 void SendDialogResponse(int,int,int,const char*){}TextDrawPool* GetTextDrawPool(){return &td;}CPlayerPool* GetPlayerPool(){return &pool;}
};
struct CGame {bool input=true;void EnableGameInput(bool value){input=value;}CPlayerPed* FindPlayerPed(){return nullptr;}int GetLocalMoney(){return 0;}};
struct CJavaWrapper {std::vector<std::string> events;void UiEvent(const char* value){events.emplace_back(value);}};
struct Plugin {static inline std::vector<bool> ptt;static void SetPTT(int,bool down){ptt.push_back(down);}static bool IsTransmitting(){return false;}};
struct KeyFilter {static bool IsKeyAvailable(int){return false;}};
namespace BCGBridge {void CloseChat();}
struct Keyboard {bool shown=false;bool visible(){return shown;}void show(void*){shown=true;}};
struct TabList {bool visible(){return false;}};
struct Chat {int info=0;void touchPopEvent();void keyboardEvent(const std::string&);void addInfoMessage(const char*){info++;}};
struct UI {Keyboard keys;TabList tabs;Chat chatWidget;Keyboard* keyboard(){return &keys;}TabList* playertablist(){return &tabs;}Chat* chat(){return &chatWidget;}};
Client client;CNetGame net{&client};CNetGame* pNetGame=&net;CGame game;CGame* pGame=&game;CJavaWrapper java;CJavaWrapper* pJavaWrapper=&java;UI ui;UI* pUI=&ui;
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
 check(length==11&&std::string(out,length)=="/testarchat","command uses exact int32 byte count");
 check(!BCGBridge::ChatOpen()&&game.input&&eventHas("\"ok\":true"),"queued send closes editor and releases controls");
 ui.chat()->touchPopEvent();BCGBridge::Queue(2,0,0,0,"Olá, ação e café");BCGBridge::Process();
 RakNet::BitStream message(client.data.data(),client.data.size(),false);uint8_t n=0;message.Read(n);message.Read(out,n);
 check(client.id==101&&std::string(out,n)==Encoding::utf2cp("Olá, ação e café"),"UTF-8 composer text reaches chat RPC in CP1252 without double conversion");
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
 std::cout<<"V030 native transport checks="<<checks<<" failures=0\n";
}
'''
file = root / 'verification/V030/native_transport_test.cpp'
file.write_text(head+net+'\n'+bridge+'\n'+chat+'\n'+clear+'\n'+special+'\n'+main)
executable = root / 'verification/V030/native_transport_test'
subprocess.run(['g++','-std=c++17','-O2','-I'+str(cpp),str(file),str(cpp/'vendor/raknet/BitStream.cpp'),str(cpp/'vendor/encoding/encoding.cpp'),'-o',str(executable)],check=True)
result = subprocess.run([str(executable)],check=True,capture_output=True,text=True)
(root/'verification/V030/native_transport_result.txt').write_text(result.stdout)
print(result.stdout)
