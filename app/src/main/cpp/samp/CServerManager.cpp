#include "main.h"
#include "CServerManager.h"
#include "settings.h"

#include "gui/gui.h"
extern UI *pUI;
#include "net/netgame.h"
extern CNetGame *pNetGame;
#include "java/jniutil.h"

extern CJavaWrapper *pJavaWrapper;
#define SRV_NAME "Cidade Grande RP"
const char* g_szServerNames[] = {
        (SRV_NAME)
};
constexpr size_t MAX_SERVERS = sizeof(g_szServerNames)
        / sizeof(g_szServerNames[0]);

#define BCG_IP "190.102.40.7"
const CServerInstance::CServerInstanceEncrypted g_sEncryptedAddresses[MAX_SERVERS] = {
        CServerInstance::create((BCG_IP), 1, 12, 7825, false)
};

int CServerInstance::iServer = -1;
void CServerInstance::initConnection(int id) {
    CServerInstance::iServer = id;

    std::string srvStr = "{\"value\":" + std::to_string(CServerInstance::iServer) + "}";

    if(CServerInstance::iServer < 0 || static_cast<size_t>(CServerInstance::iServer) >= MAX_SERVERS) {
        pNetGame = new CNetGame(
                (BCG_IP),
                7825,
                pSettings->Get().szNickName,
                pSettings->Get().szPassword);
    } else {
        pNetGame = new CNetGame(
                g_sEncryptedAddresses[CServerInstance::iServer].decrypt(),
                g_sEncryptedAddresses[CServerInstance::iServer].getPort(),
                pSettings->Get().szNickName,
                pSettings->Get().szPassword);
    }
}
