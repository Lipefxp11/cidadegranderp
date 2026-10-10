#include "../main.h"
#include "../game/game.h"
#include "netgame.h"
#include "textdrawpool.h"
#include "../BCGBridge.h"
#include "../vendor/encoding/encoding.h"
#include <cmath>

extern CGame* pGame;
extern CNetGame* pNetGame;

// 0.3.7
CTextDrawPool::CTextDrawPool()
{
    for (int i = 0; i < MAX_TEXT_DRAWS; i++) {
        m_pTextDraw[i] = nullptr;
        m_bSlotState[i] = false;
    }

    ResetTextDrawTextures();

    // ====
    m_bSelectState = false;
    m_dwHoverColor = 0;
    m_wClickedTextDrawID = 0xFFFF;
}
// 0.3.7
CTextDrawPool::~CTextDrawPool()
{
    for (int i = 0; i < MAX_TEXT_DRAWS; i++) {
        Delete(i);
    }
}
// 0.3.7
void CTextDrawPool::New(uint16_t wTextDrawID, TEXT_DRAW_TRANSMIT* pTextDrawTransmit, const char* szText)
{
    if(wTextDrawID>=MAX_TEXT_DRAWS)return;
    if (m_pTextDraw[wTextDrawID]) {
        Delete(wTextDrawID);
    }

    CTextDraw* pTextDraw = new CTextDraw(pTextDrawTransmit, szText);
    if (pTextDraw == nullptr) return;

    m_pTextDraw[wTextDrawID] = pTextDraw;
    m_bSlotState[wTextDrawID] = true;
}
// 0.3.7
void CTextDrawPool::Delete(uint16_t wTextDrawID)
{
    if(wTextDrawID>=MAX_TEXT_DRAWS)return;
    if (m_pTextDraw[wTextDrawID]) {
        delete m_pTextDraw[wTextDrawID];
        m_pTextDraw[wTextDrawID] = nullptr;
        m_bSlotState[wTextDrawID] = false;
    }
}
// 0.3.7
void CTextDrawPool::Draw()
{
    const bool chromium=false;
    for(int i=0;i<MAX_TEXT_DRAWS;i++)if(m_bSlotState[i]&&m_pTextDraw[i]){
        // Game texture sprites and 3D previews retain the engine renderer.
        if(!chromium||m_pTextDraw[i]->GetBCGData().dwStyle>=4)m_pTextDraw[i]->Draw();
    }
    if(!chromium){m_bcgSnapshot.clear();return;}
    if(GetTickCount()-m_bcgTick<150)return;
    m_bcgTick=GetTickCount();
    std::string snapshot="{\"type\":\"textdraws\",\"select\":"+std::string(m_bSelectState?"true":"false")+",\"items\":[";
    bool first=true;
    for(int i=0;i<MAX_TEXT_DRAWS;i++)if(m_bSlotState[i]&&m_pTextDraw[i]){
        const auto& d=m_pTextDraw[i]->GetBCGData();
        if(!std::isfinite(d.fX)||!std::isfinite(d.fY)||!std::isfinite(d.fLetterHeight))continue;
        if(d.dwStyle>=4&&(!m_bSelectState||!d.byteSelectable))continue;
        float width=d.byteCentered?d.fLineHeight:d.fLineWidth-d.fX;
        if(d.dwStyle>=4)width=d.fLineWidth;
        if(!std::isfinite(width)||width<0)width=0;
        char properties[500];
        std::snprintf(properties,sizeof properties,"{\"id\":%d,\"x\":%.3f,\"y\":%.3f,\"h\":%.3f,\"height\":%.3f,\"width\":%.3f,\"style\":%u,\"align\":%d,\"selectable\":%s,\"color\":\"#%08x\",\"box\":\"#%08x\",\"text\":",i,d.fX,d.fY,d.fLetterHeight,d.fLineHeight,width,d.dwStyle,d.byteCentered?2:d.byteAlignRight?3:1,d.byteSelectable?"true":"false",__builtin_bswap32(d.dwLetterColor),d.byteBox?__builtin_bswap32(d.dwBoxColor):0);
        if(!first)snapshot+=',';first=false;snapshot+=properties;
        snapshot+=BCGBridge::Quote(d.dwStyle>=4?"":Encoding::cp2utf(m_pTextDraw[i]->GetBCGText()));snapshot+='}';
    }
    snapshot+="]}";
    if(snapshot!=m_bcgSnapshot){BCGBridge::Emit(snapshot);m_bcgSnapshot=std::move(snapshot);}
}

void CTextDrawPool::DrawImage()
{
    /*for (int i = 0; i < MAX_TEXT_DRAWS; i++)
    {
        if (m_bSlotState[i]) {
            m_pTextDraw[i]->DrawImage();
        }
    }*/
}

// ========

void CTextDrawPool::SetSelectState(bool bState, uint32_t dwColor)
{
    if (bState) {
        m_bSelectState = true;
        m_dwHoverColor = (((dwColor << 16) | dwColor & 0xFF00) << 8) | (((dwColor >> 16) | dwColor & 0xFF0000) >> 8);
        m_wClickedTextDrawID = 0xFFFF;
        pGame->DisplayHUD(false);
        pGame->FindPlayerPed()->TogglePlayerControllable(false);
    }
    else {
        m_bSelectState = false;
        m_dwHoverColor = 0;
        m_wClickedTextDrawID = 0xFFFF;
        pGame->DisplayHUD(true);
        pGame->FindPlayerPed()->TogglePlayerControllable(true);

        SendClick();

        for (int i = 0; i < MAX_TEXT_DRAWS; i++)
        {
            if (m_bSlotState[i] && m_pTextDraw[i]) {
                CTextDraw* pTextDraw = m_pTextDraw[i];
                pTextDraw->m_bHovered = false;
                pTextDraw->m_dwHoverColor = 0;
            }
        }
    }
}

void CTextDrawPool::SendClick()
{
    RakNet::BitStream bsClick;
    bsClick.Write(m_wClickedTextDrawID);
    pNetGame->GetRakClient()->RPC(&RPC_ClickTextDraw, &bsClick, HIGH_PRIORITY, RELIABLE_ORDERED, 0, false, UNASSIGNED_NETWORK_ID, nullptr);
}

bool CTextDrawPool::onTouchEvent(int type, bool multi, int x, int y)
{
    if (m_bSelectState == false) return true;
    static bool bWannaClick = false;

    m_wClickedTextDrawID = 0xFFFF;


    for (int i = 0; i < MAX_TEXT_DRAWS; i++)
    {
        if (m_bSlotState[i] && m_pTextDraw[i])
        {
            CTextDraw* pTextDraw = m_pTextDraw[i];
            pTextDraw->m_bHovered = false;
            pTextDraw->m_dwHoverColor = 0;

            if (pTextDraw->m_TextDrawData.byteSelectable)
            {
                Log("onTouchEvent textdraw 2");
                switch (type)
                {
                    case 2:
                        if (IsPointInRect(x, y, &(pTextDraw->m_rectArea)))
                        {
                            bWannaClick = true;
                            return false;
                        }
                        break;
                    case 3:
                        /*m_wClickedTextDrawID = 0xFFFF;
                        pTextDraw->m_bHovered = true;
                        pTextDraw->m_dwHoverColor = m_dwHoverColor;
                        Log("x: %f, y:%f, %d",IsPointInRect(x, y, &pTextDraw->m_rectArea));*/
                        break;

                    case 1:
                        Log("m_rectArea %f %f %f %f, clicked: %f %f", pTextDraw->m_rectArea.bottom, pTextDraw->m_rectArea.top,pTextDraw->m_rectArea.left,pTextDraw->m_rectArea.right,
                            x,y);
                        if (IsPointInRect(x, y, &pTextDraw->m_rectArea)) {
                            Log("Point is in rect");
                            m_wClickedTextDrawID = i;
                            SendClick();
                            pTextDraw->m_bHovered = false;
                            pTextDraw->m_dwHoverColor = 0;
                            return false;
                        }
                        bWannaClick = false;
                        break;
                }
            }
        }
    }

    return true;
}

void CTextDrawPool::SnapshotProcess()
{
    if (!pNetGame || !pGame) return;
    if (pGame->IsGamePaused()) return;

    for (int i = 0; i < MAX_TEXT_DRAWS; i++)
    {
        if (m_bSlotState[i] && m_pTextDraw[i]) {
            m_pTextDraw[i]->SnapshotProcess();
        }
    }
}
void CTextDrawPool::SubmitBCGClick(int id){if(!m_bSelectState||!pNetGame)return;if(id==65535){m_wClickedTextDrawID=65535;SendClick();return;}if(id<0||id>=MAX_TEXT_DRAWS||!m_bSlotState[id]||!m_pTextDraw[id]||!m_pTextDraw[id]->GetBCGData().byteSelectable)return;m_wClickedTextDrawID=id;SendClick();}
