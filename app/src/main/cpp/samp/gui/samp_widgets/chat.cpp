#include "../gui.h"
#include "../../main.h"
#include "../../game/game.h"
#include "../../net/netgame.h"
#include <algorithm>
#include "../settings.h"
#include "java/jniutil.h"
#include "BCGBridge.h"

extern UI* pUI;
extern CGame* pGame;
extern CNetGame* pNetGame;
extern CSettings* pSettings;
extern CJavaWrapper *pJavaWrapper;

Chat::Chat()
        : ListBox()
{

}

void Chat::addChatMessage(const std::string& message, const std::string& nick, const ImColor& nick_color)
{
    addPlayerMessage(message, nick, nick_color);
}

void Chat::addInfoMessage(const std::string& format, ...)
{
    char tmp_buf[512];

    va_list args;
    va_start(args, format);
    vsnprintf(tmp_buf, sizeof tmp_buf, format.c_str(), args);
    va_end(args);

    addMessage(std::string(tmp_buf), ImColor(0x00, 0xc8, 0xc8));
}

void Chat::addDebugMessage(const std::string& format, ...)
{
    char tmp_buf[512];

    va_list args;
    va_start(args, format);
    vsnprintf(tmp_buf, sizeof tmp_buf, format.c_str(), args);
    va_end(args);

    addMessage(std::string(tmp_buf), ImColor(0xbe, 0xbe, 0xbe));
}

void Chat::addClientMessage(const std::string& message, const ImColor& color)
{
    addMessage(message, color);
}

void Chat::addMessage(const std::string& message, const ImColor& color)
{
    if (this->itemsCount() > UISettings::chatMaxMessages())
    {
        this->removeItem(0);
    }

    MessageItem* item = new MessageItem(message, color);
    this->addItem(item);
    /*if(!active())*/ this->setScrollY(1.0f);
}

void Chat::addPlayerMessage(const std::string& message, const std::string& nick, const ImColor& nick_color)
{
    if (this->itemsCount() > UISettings::chatMaxMessages())
    {
        this->removeItem(0);
    }

    PlayerMessageItem* item = new PlayerMessageItem(message, nick, nick_color);
    this->addItem(item);
    /*if(!active())*/ this->setScrollY(1.0f);
}

void Chat::draw(ImGuiRenderer* renderer)
{
    ListBox::draw(renderer);
}

void Chat::activateEvent(bool active)
{
    if (active)
    {
        this->setScrollable(true);
    }
    else
    {
        this->setScrollable(false);
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
