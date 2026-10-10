from pathlib import Path
import re,subprocess
root=Path(__file__).resolve().parents[2];cpp=root/'app/src/main/cpp/samp'
net=(cpp/'net/netgame.cpp').read_text();start=net.index('void CNetGame::SendChatMessage(');end=net.index('// 0.3.7',net.index('void CNetGame::SendChatCommand(',start));methods=net[start:end]
chat=(cpp/'gui/samp_widgets/chat.cpp').read_text();chat=chat[chat.index('void Chat::keyboardEvent('):]
voice='\n'.join(l for l in (cpp/'gui/samp_widgets/voicebutton.h').read_text().splitlines() if not l.startswith('#'))
head=r'''
#include <cassert>
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <iostream>
#include "vendor/raknet/BitStream.h"
int RPC_Chat=101,RPC_ServerCommand=50;
const int GAMESTATE_CONNECTED=5,HIGH_PRIORITY=1,RELIABLE=2;
void Log(const char*,...){}
struct Client {int id=-1,calls=0;std::vector<unsigned char> data;template<class... A>bool RPC(int* rpc,RakNet::BitStream* bits,A...){id=*rpc;calls++;data.assign(bits->GetData(),bits->GetData()+bits->GetNumberOfBytesUsed());return true;}};
struct CNetGame {Client* m_pRakClient;int state=5;int GetGameState(){return state;}void SendChatMessage(const char*);void SendChatCommand(const char*);};
Client client;CNetGame net{&client};CNetGame* pNetGame=&net;
struct Chat {void keyboardEvent(const std::string&);};
struct ImVec2 {float x,y;ImVec2(float a=0,float b=0):x(a),y(b){}ImVec2 operator+(ImVec2 v)const{return {x+v.x,y+v.y};}};
struct ImColor {ImColor(float,float,float){}};
struct ImGuiRenderer {void drawImage(ImVec2,ImVec2,void*){}};
enum class TouchType {push,move,pop};
struct Button {Button(const std::string&,float){}virtual void draw(ImGuiRenderer*){}virtual void touchEvent(const ImVec2&,TouchType){}virtual void touchPushEvent(){}virtual void touchPopEvent(){}bool visible()const{return true;}bool contains(ImVec2 p)const{return p.x>=0&&p.x<100&&p.y>=0&&p.y<100;}ImVec2 absolutePosition(){return {0,0};}ImVec2 size(){return {100,100};}void setCaptionColor(ImColor){}};
struct UISettings {static float fontSize(){return 30;}};
struct RwTexture {void* raster;};
struct CUtil {static void* LoadTextureFromDB(const char*,const char*){return nullptr;}};
struct CSettings {struct Values {bool bVoiceChatEnable=true;}v;const Values& GetReadOnly(){return v;}};
CSettings settings;CSettings* pSettings=&settings;
struct Plugin {static inline std::vector<std::pair<int,bool>> events;static void SetPTT(int key,bool down){events.emplace_back(key,down);}};
'''
main=r'''
int checks=0;void check(bool ok,const char* name){++checks;if(!ok){std::cerr<<"FAIL "<<name<<"\n";std::abort();}std::cout<<"PASS "<<name<<"\n";}
int main(){
 Chat chat;chat.keyboardEvent("/testarmic");check(client.id==50,"native slash command reaches RPC 50");
 RakNet::BitStream command(client.data.data(),client.data.size(),false);int n=0;command.Read(n);char text[145]={};command.Read(text,n);check(n==10&&std::string(text,n)=="/testarmic","command carries int32 byte length and unchanged text");
 std::string accent="Ol";accent+=char(0xe1);chat.keyboardEvent(accent);check(client.id==101,"native message reaches chat RPC 101");
 RakNet::BitStream message(client.data.data(),client.data.size(),false);uint8_t len;message.Read(len);message.Read(text,len);check(std::string(text,len)==accent,"CP1252 accent is not double converted");
 int before=client.calls;chat.keyboardEvent(std::string(145,'a'));chat.keyboardEvent("a\nb");chat.keyboardEvent(std::string("a\0b",3));check(client.calls==before,"long multiline and embedded NUL are rejected");
 chat.keyboardEvent(std::string(144,'a'));check(client.calls==before+1&&client.data.size()==145,"144-byte chat serializes within SA-MP limit");
 before=client.calls;net.state=0;chat.keyboardEvent("oi");net.state=5;net.SendChatMessage(nullptr);net.SendChatCommand("bad");check(client.calls==before,"offline null and non-command requests do not send");
 VoiceButton mic;check(mic.handleTouch({20,20},2,3)&&mic.recording(),"microphone press starts local PTT");check(Plugin::events.back()==std::make_pair(66,true),"microphone uses only local key B");
 check(!mic.handleTouch({20,20},1,1)&&mic.recording(),"movement finger release does not stop microphone");
 ImGuiRenderer renderer;for(int i=0;i<500;i++)mic.draw(&renderer);check(mic.recording(),"holding microphone has no frame countdown cutoff and null textures are safe");
 check(mic.handleTouch({300,300},1,3)&&!mic.recording(),"microphone release outside button stops recording");check(Plugin::events.back()==std::make_pair(66,false),"release sends local PTT stop");
 settings.v.bVoiceChatEnable=false;check(!mic.handleTouch({20,20},2,4)&&!mic.recording(),"disabled microphone does not start recording");
 std::cout<<"Native V028 checks="<<checks<<" failures=0\n";
}
'''
(root/'native_v028_check.cpp').write_text(head+methods+chat+voice+main)
cmd=['g++','-std=c++17','-O2','-ffunction-sections','-fdata-sections','-Wl,--gc-sections','-I'+str(cpp),str(root/'native_v028_check.cpp'),str(cpp/'vendor/raknet/BitStream.cpp'),'-o',str(root/'native_v028_check')]
r=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
if r.returncode:print(r.stderr);raise SystemExit(r.returncode)
r=subprocess.run([str(root/'native_v028_check')],check=True,stdout=subprocess.PIPE,text=True);(root/'native_v028_result.txt').write_text(r.stdout);print(r.stdout)
