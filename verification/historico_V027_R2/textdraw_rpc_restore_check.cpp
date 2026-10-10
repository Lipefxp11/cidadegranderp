#include <cstdint>
#include <cassert>
#include <string>
#include <iostream>
#include <cstring>
#include <vector>
#include "vendor/raknet/BitStream.h"
struct CVector {float x,y,z;};
#pragma pack(push,1)

typedef struct _TEXT_DRAW_TRANSMIT
{
    union
    {
        uint8_t byteFlags;
        struct {
            uint8_t byteBox : 1;
            uint8_t byteLeft : 1;
            uint8_t byteRight : 1;
            uint8_t byteCenter : 1;
            uint8_t byteProportional : 1;
            uint8_t bytePadding : 3;
        };
    };
    float fLetterWidth;
    float fLetterHeight;
    uint32_t dwLetterColor;
    float fLineWidth;
    float fLineHeight;
    uint32_t dwBoxColor;
    uint8_t byteShadow;
    uint8_t byteOutline;
    uint32_t dwBackgroundColor;
    uint8_t byteStyle;
    uint8_t byteSelectable;
    float fX;
    float fY;
    uint16_t wModelID;
    CVector vecRot;
    float fZoom;
    uint16_t wColor1;
    uint16_t wColor2;
} TEXT_DRAW_TRANSMIT;
static_assert(sizeof(TEXT_DRAW_TRANSMIT) == 63, "SA-MP TextDraw RPC layout changed");

#pragma pack(pop)
constexpr uint16_t MAX_TEXT_DRAWS=3072;
struct CTextDraw {std::string text;void SetText(const char* v){text=v;}};
struct CTextDrawPool {int creates=0,deletes=0;bool selected=false;uint16_t id=0;TEXT_DRAW_TRANSMIT wire{};CTextDraw draw;
void New(uint16_t i,TEXT_DRAW_TRANSMIT* w,const char* s){creates++;id=i;wire=*w;draw.SetText(s);}
void Delete(uint16_t){deletes++;}CTextDraw* GetAt(uint16_t){return &draw;}void SetSelectState(bool b,uint32_t){selected=b;}};
struct CNetGame {CTextDrawPool pool;CTextDrawPool* GetTextDrawPool(){return &pool;}};
CNetGame game;CNetGame* pNetGame=&game;
void ScrShowTextDraw(RPCParameters* rpcParams)
{
    if (!rpcParams || !rpcParams->input || !pNetGame) return;
    constexpr unsigned int headerBits = (sizeof(uint16_t) * 2 + sizeof(TEXT_DRAW_TRANSMIT)) * 8;
    if (rpcParams->numberOfBitsOfData < headerBits) return;
    CTextDrawPool* pool = pNetGame->GetTextDrawPool();
    if (!pool) return;
    RakNet::BitStream data(rpcParams->input, (rpcParams->numberOfBitsOfData + 7) / 8, false);
    data.SetWriteOffset(rpcParams->numberOfBitsOfData);
    uint16_t id = 0, length = 0;
    TEXT_DRAW_TRANSMIT wire{};
    if (!data.Read(id) || id >= MAX_TEXT_DRAWS ||
        !data.Read(reinterpret_cast<char*>(&wire), sizeof wire) || !data.Read(length)) return;
    if (length > 1024 || data.GetNumberOfUnreadBits() < length * 8 || wire.byteStyle > 5) return;
    char text[1025]{};
    if (length && !data.Read(text, length)) return;
    text[length] = '\0';
    pool->New(id, &wire, text);
}
// 0.3.7
void ScrHideTextDraw(RPCParameters* rpcParams)
{
    if (!rpcParams || !rpcParams->input || !pNetGame || rpcParams->numberOfBitsOfData < 16) return;
    CTextDrawPool* pool = pNetGame->GetTextDrawPool();
    if (!pool) return;
    RakNet::BitStream data(rpcParams->input, (rpcParams->numberOfBitsOfData + 7) / 8, false);
    uint16_t id = 0;
    if (data.Read(id) && id < MAX_TEXT_DRAWS) pool->Delete(id);
}
// 0.3.7
void ScrTextDrawSetString(RPCParameters* rpcParams)
{
    if (!rpcParams || !rpcParams->input || !pNetGame || rpcParams->numberOfBitsOfData < 32) return;
    CTextDrawPool* pool = pNetGame->GetTextDrawPool();
    if (!pool) return;
    RakNet::BitStream data(rpcParams->input, (rpcParams->numberOfBitsOfData + 7) / 8, false);
    data.SetWriteOffset(rpcParams->numberOfBitsOfData);
    uint16_t id = 0, length = 0;
    if (!data.Read(id) || id >= MAX_TEXT_DRAWS || !data.Read(length) ||
        length > 1024 || data.GetNumberOfUnreadBits() < length * 8) return;
    char text[1025]{};
    if (length && !data.Read(text, length)) return;
    text[length] = '\0';
    CTextDraw* draw = pool->GetAt(id);
    if (draw) draw->SetText(text);
}

void ScrSelectTextDraw(RPCParameters* rpcParams)
{
    if (!rpcParams || !rpcParams->input || !pNetGame || rpcParams->numberOfBitsOfData < 33) return;
    CTextDrawPool* pool = pNetGame->GetTextDrawPool();
    if (!pool) return;
    RakNet::BitStream data(rpcParams->input, (rpcParams->numberOfBitsOfData + 7) / 8, false);
    data.SetWriteOffset(rpcParams->numberOfBitsOfData);
    bool enabled = false;
    uint32_t color = 0;
    if (data.Read(enabled) && data.Read(color)) pool->SetSelectState(enabled, color);
}


int main(){int n=0;auto check=[&](bool v){assert(v);n++;};
TEXT_DRAW_TRANSMIT w{};w.byteStyle=2;w.dwLetterColor=0xff665544;
auto show=[&](uint16_t id,uint16_t len,const std::string& text,unsigned int cut=0){RakNet::BitStream b;b.Write(id);b.Write((char*)&w,sizeof w);b.Write(len);b.Write(text.data(),text.size());RPCParameters p{b.GetData(),(unsigned)b.GetNumberOfBitsUsed()-cut};ScrShowTextDraw(&p);};
show(3071,8,"Comprar!");check(game.pool.creates==1&&game.pool.id==3071&&game.pool.draw.text=="Comprar!");
check(sizeof(w)==63&&game.pool.wire.dwLetterColor==0xff665544);
show(3072,8,"Comprar!");check(game.pool.creates==1);
show(1,8,"Compra");check(game.pool.creates==1);
show(1,8,"Comprar!",1);check(game.pool.creates==1);
show(1,1025,std::string(1025,'X'));check(game.pool.creates==1);
show(1,0,"");check(game.pool.creates==2&&game.pool.draw.text.empty());
show(1,1024,std::string(1024,'X'));check(game.pool.creates==3&&game.pool.draw.text.size()==1024);
w.byteStyle=6;show(1,4,"test");check(game.pool.creates==3);
ScrShowTextDraw(nullptr);check(game.pool.creates==3);
RakNet::BitStream b;b.Write((uint16_t)1);b.Write((uint16_t)3);b.Write("Oi!",3);RPCParameters p{b.GetData(),(unsigned)b.GetNumberOfBitsUsed()};ScrTextDrawSetString(&p);check(game.pool.draw.text=="Oi!");p.numberOfBitsOfData--;ScrTextDrawSetString(&p);check(game.pool.draw.text=="Oi!");
RakNet::BitStream h;h.Write((uint16_t)1);RPCParameters hp{h.GetData(),16};ScrHideTextDraw(&hp);check(game.pool.deletes==1);hp.numberOfBitsOfData=15;ScrHideTextDraw(&hp);check(game.pool.deletes==1);
RakNet::BitStream sel;sel.Write(true);sel.Write((uint32_t)0x11223344);RPCParameters sp{sel.GetData(),33};ScrSelectTextDraw(&sp);check(game.pool.selected);game.pool.selected=false;sp.numberOfBitsOfData=32;ScrSelectTextDraw(&sp);check(!game.pool.selected);
std::cout<<"TextDraw RPC tests: "<<n<<" checks passed\n";
}
