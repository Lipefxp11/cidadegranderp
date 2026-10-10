#include "main.h"
#include "gui/gui.h"
#include "game/game.h"
#include "net/netgame.h"
#include "net/localplayer.h"
#include "net/netgame.h"
#include "playertablist.h"
#include <algorithm>
#include "net/localplayer.h"

extern UI* pUI;
extern CNetGame* pNetGame;
extern CGame *pGame;

bool bNeedEnterVehicle = false;
bool OpenButton = false;
int Tab = 0;

ButtonPanel::ButtonPanel()
	: Layout(Orientation::HORIZONTAL)
{

    m_bTab = new Button("TAB", UISettings::fontSize() / 2);
	m_bOpen = new OButton(">>", UISettings::fontSize() / 2);
	CButton* m_bClose = new CButton("<<", UISettings::fontSize() / 2);
    m_bAlt = new Button("ALT", UISettings::fontSize() / 2);
	m_bEsc = new Button("ESC", UISettings::fontSize() / 2);
    m_bSV = new CButton("SV", UISettings::fontSize() / 2);
	m_bH = new Button("H", UISettings::fontSize() / 2);
	CButton* m_bY = new CButton("Y", UISettings::fontSize() / 2);
	CButton* m_bN = new CButton("N", UISettings::fontSize() / 2);
	CButton* m_bF = new CButton("F", UISettings::fontSize() / 2);
	CButton* m_bP = new CButton("+", UISettings::fontSize() / 2);
	CButton* m_bG = new CButton("G", UISettings::fontSize() / 2);
	CButton* m_bFOOD = new CButton("FOOD", UISettings::fontSize() / 2);
	CButton* m_bGPS = new CButton("GPS", UISettings::fontSize() / 2);
	CButton* m_bD = new CButton("D", UISettings::fontSize() / 2);
	CButton* m_bUSE = new CButton("USE", UISettings::fontSize() / 2);
	CButton* m_b2 = new CButton("2", UISettings::fontSize() / 2);


    static_cast<CButton*>(m_bSV)->setCallback([]()
    {
        if (!pNetGame) return;

        CPlayerPool* pool = pNetGame->GetPlayerPool();
        if (!pool) return;

        CLocalPlayer* lp = pool->GetLocalPlayer();
        if (!lp) return;

        lp->ProcessDriveByExitHead();
    });
	m_bTab->setCallback([]()
						{
							if (Tab == 0) {
								if (pUI) { pUI->playertablist()->show(); Tab = 1; }
							}
							else {
								Tab = 0;
							}
						});
    m_bOpen->setCallback([]() { OpenButton = !OpenButton; });
    m_bClose->setCallback([]() { OpenButton = false; });
    m_bAlt->setCallback([this]() {
        if(m_bAlt->visible())
            LocalPlayerKeys.bKeys[ePadKeys::KEY_WALK] = true;
    });
    m_bEsc->setCallback([this]() {
        if (pNetGame && m_bEsc->visible()) {
            CTextDrawPool *pTextDrawPool = pNetGame->GetTextDrawPool();
            if (pTextDrawPool) {
                pTextDrawPool->SetSelectState(false, 0);
			}
		}});
	m_bH->setCallback([this]() {
		if(m_bH->visible())
			LocalPlayerKeys.bKeys[ePadKeys::KEY_CTRL_BACK] = true; });
	m_bY->setCallback([m_bY]() { if(m_bY->visible()) LocalPlayerKeys.bKeys[ePadKeys::KEY_YES] = true; });
	m_bN->setCallback([m_bN]() { if(m_bN->visible()) LocalPlayerKeys.bKeys[ePadKeys::KEY_NO] = true; });
	m_bF->setCallback([m_bF]() { if(m_bF->visible()) LocalPlayerKeys.bKeys[ePadKeys::KEY_SECONDARY_ATTACK] = true; });
	m_bP->setCallback([m_bP]() { if(m_bP->visible()) LocalPlayerKeys.bKeys[ePadKeys::KEY_SUBMISSION] = true; });
	m_bG->setCallback([m_bG]() { if(m_bG->visible()) bNeedEnterVehicle = true; });
	//m_bFOOD->setCallback([]() { pGame->FindPlayerPed()->SetCuffedOrCarry(1, 0); pGame->FindPlayerPed()->ProcessCuffAndCarry(); });
	m_bGPS->setCallback([]() { pNetGame->SendChatCommand("/gps"); });
	m_bD->setCallback([]() { LocalPlayerKeys.bKeys[ePadKeys::KEY_SUBMISSION] = true; });
	m_bUSE->setCallback([]() { LocalPlayerKeys.bKeys[ePadKeys::KEY_ANALOG_LEFT] = true; });
	m_b2->setCallback([m_b2]() { if(m_b2->visible()) LocalPlayerKeys.bKeys[ePadKeys::KEY_SUBMISSION] = true; });
	this->addChild(m_bClose);
    //this->addChild(m_bBind);
	this->addChild(m_bTab);
    this->addChild(m_bAlt);
	this->addChild(m_bEsc);
    this->addChild(m_bSV);
	this->addChild(m_bH);
	this->addChild(m_bF);//UI->add(btn);
	//if (Server == 10) this->addChild(m_bP);
	this->addChild(m_bY);
	this->addChild(m_bN);
	//if (Server == 24) this->addChild(m_bD);
	//if (Server == 24) this->addChild(m_bUSE);
	this->addChild(m_bG);
	//this->addChild(m_bFOOD);
	//if (Server == 21) this->addChild(m_bGPS);
	this->addChild(m_b2);
	this->addChild(m_bOpen);


	//m_bOpen->setPosition(ImVec2(5.0f, 140.0f));
	//m_bF->setColor(ImColor(0.11f, 0.11f, 0.11f, 0.80f));
}

void ButtonPanel::performLayout()
{
    Widget::performLayout();
    const float gap = UISettings::padding() / 3.0f;
    float x = 0.0f, rowHeight = 0.0f;
    for (Widget* key : {static_cast<Widget*>(m_bEsc), static_cast<Widget*>(m_bTab),
                       static_cast<Widget*>(m_bAlt), static_cast<Widget*>(m_bH),
                       static_cast<Widget*>(m_bOpen)}) {
        key->setPosition(ImVec2(x, 0.0f));
        x += key->width() + gap;
        rowHeight = std::max(rowHeight, key->height());
    }
    x = 0.0f;
    for (auto key : children()) {
        if (key == m_bEsc || key == m_bTab || key == m_bAlt || key == m_bH || key == m_bOpen) continue;
        key->setPosition(ImVec2(x, rowHeight + gap));
        x += key->width() + gap;
    }
}
