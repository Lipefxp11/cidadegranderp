#define SSCANF_NO_NICE_FEATURES
#include <a_samp>
#include <bcg_tempvehicles47>
#include <zcmd>          
#include <dof2>
#include <streamer>
#include <foreach>
#include <progress>
#include <cpstream>
#include <sscanf>
#include <bcg_access52>
#include <bcg_voice52>  
#include <core>
#include <float>
#include <gangzones>
#include <rotas_gangsters>
#include <fabricar_armas>
#include <desmanche_fivem>
#include <celular>
#pragma disablerecursion
forward VerificarPasta(pasta[]);
forward tgmx(playerid);
forward trespawn();
forward ttrespawn();
forward tang();
forward MsgAuto();
forward tbanco();
forward tfbanco(playerid);
forward tpreso(playerid);
forward Flood(playerid);
forward GateClose(gateid);
forward PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z);
forward TempoPreso(playerid);
forward Taxi(playerid);
forward Mecanico(playerid);
forward PayDay();
forward TempoVip(playerid);
forward equiparn(playerid);
forward consertarcarro(playerid);
forward carregando(playerid);
forward CheckMoney();
forward AtualizarChatBubble();
forward Float:DistanceToPoint(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
forward CriarTextDrawsLogin(playerid);
forward OnCefEvent(playerid, browserid, const event[], const args[]);
forward AtualizarInterfaceCelular(playerid);
               //============ Sistema Criar Casa ======================||
#define MAX_CASAS 600

enum Casas
{
	Float:X,
	Float:Y,
	Float:Z,
	Float:Xp,
	Float:Yp,
	Float:Zp,
	Pickup,
	Text3D:TextLabel,
	pInterior
};
#define MAX_CAIXAS          50
#define MAX_CASAS_BCG       600
#define CASA_INTERIOR_BCG

// ============================================================
// LOJAS NATIVAS DO GTA SA - ENTRADA/SAIDA PELA TECLA H
// Cada loja usa um interior original do GTA e um mundo virtual
// proprio para evitar que jogadores de lojas diferentes se misturem.
// ============================================================
#define MAX_LOJAS_GTA_BCG 13
#define VW_LOJAS_GTA_BCG  5000

new bool:g_LojaGTAInicializada[MAX_PLAYERS];
new g_LojaGTAAtual[MAX_PLAYERS];
new bool:g_LanchoneteAtiva[MAX_PLAYERS];
new g_LanchoneteAtual[MAX_PLAYERS];
new bool:g_PlayerCrack[MAX_PLAYERS];
new g_LoadingAtivo[MAX_PLAYERS];

// [0] 24/7 | [1] Burger Shot | [2] Cluckin Bell | [3] Pizza Stack
// [4] Ammu-Nation | [5] Binco | [6] Sub Urban | [7] ZIP
// [8] ProLaps | [9] Victim | [10] Didier Sachs | [11] Barber | [12] Tattoo
new const Float:g_LojasGTA_Entrada[MAX_LOJAS_GTA_BCG][3] = {
    {1833.1807, -1842.7574, 13.5781}, // 24/7 Idlewood
    {1199.1696, -918.1302, 43.1231},  // Burger Shot Market
    {2420.0908, -1508.9302, 24.0000}, // Cluckin Bell Idlewood
    {2083.2139, -1756.1418, 13.5469}, // Pizza Stack Idlewood
    {1362.5700, -1748.7300, 13.5324}, // Ammu-Nation LS
    {2244.3733, -1665.4698, 15.4766}, // Binco LS
    {2112.8867, -1211.0930, 23.9630}, // Sub Urban LS
    {1457.0710, -1137.2300, 23.9560}, // ZIP LS
    {499.9180, -1360.6280, 16.3692},  // ProLaps LS
    {2262.1001, -1669.9000, 15.2813}, // Victim LS
    {451.8410, -1478.7800, 30.2147},  // Didier Sachs LS
    {2070.4431, -1793.3087, 13.5469}, // Barber LS
    {2229.5649, -1721.0928, 13.5625}  // Tattoo/area LS
};

new const g_LojasGTA_Interior[MAX_LOJAS_GTA_BCG] = {
    10, // 24/7
    10, // Burger Shot
    9,  // Cluckin Bell
    5,  // Pizza Stack
    1,  // Ammu-Nation
    15, // Binco
    15, // Sub Urban
    18, // ZIP
    3,  // ProLaps
    5,  // Victim
    14, // Didier Sachs
    2,  // Barber
    16  // Tattoo
};

new const Float:g_LojasGTA_Saida[MAX_LOJAS_GTA_BCG][3] = {
    {6.0912, -29.2719, 1003.5494},
    {363.5720, -74.8460, 1001.5078},
    {364.9440, -11.3540, 1001.8516},
    {372.5560, -133.6260, 1001.4922},
    {296.5811, -38.0198, 1001.5156},
    {207.7370, -109.0199, 1005.1328},
    {207.7370, -109.0199, 1005.1328},
    {161.3910, -97.5780, 1001.8047},
    {207.0540, -138.8040, 1003.5078},
    {226.2930, -8.0580, 1002.2109},
    {204.3520, -166.6940, 1000.5234},
    {411.6250, -21.4330, 1001.8047},
    {-204.4390, -43.6880, 1002.3047}
};

stock BCG_EntrarLojaGTA(playerid, lojaid)
{
    if(lojaid < 0 || lojaid >= MAX_LOJAS_GTA_BCG) return 0;

    g_LojaGTAAtual[playerid] = lojaid;
    g_LojaGTAInicializada[playerid] = true;
    SetPlayerInterior(playerid, g_LojasGTA_Interior[lojaid]);
    SetPlayerVirtualWorld(playerid, VW_LOJAS_GTA_BCG + lojaid);
    SetPlayerPos(playerid,
        g_LojasGTA_Saida[lojaid][0],
        g_LojasGTA_Saida[lojaid][1],
        g_LojasGTA_Saida[lojaid][2]);
    SetCameraBehindPlayer(playerid);
    SendClientMessage(playerid, 0x00BFFFff, "[LOJAS] Voce entrou na loja. Aperte H para sair.");
    return 1;
}

stock BCG_SairLojaGTA(playerid)
{
    new lojaid = g_LojaGTAAtual[playerid];
    if(!g_LojaGTAInicializada[playerid] || lojaid < 0 || lojaid >= MAX_LOJAS_GTA_BCG)
        return 0;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid,
        g_LojasGTA_Entrada[lojaid][0],
        g_LojasGTA_Entrada[lojaid][1],
        g_LojasGTA_Entrada[lojaid][2]);
    g_LojaGTAInicializada[playerid] = false;
    g_LojaGTAAtual[playerid] = -1;
    SendClientMessage(playerid, 0x00FF00ff, "[LOJAS] Voce saiu da loja.");
    return 1;
}

stock BCG_VerificarEntradaLojaGTA(playerid)
{
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
        return -1;

    for(new i = 0; i < MAX_LOJAS_GTA_BCG; i++)
    {
        // IDs 1, 2 e 3 sao controlados exclusivamente pelo sistema
        // de lanchonetes para evitar duas entradas no mesmo ponto.
        if(i >= 1 && i <= 3) continue;

        if(IsPlayerInRangeOfPoint(playerid, 6.0,
            g_LojasGTA_Entrada[i][0],
            g_LojasGTA_Entrada[i][1],
            g_LojasGTA_Entrada[i][2]))
        {
            return i;
        }
    }
    return -1;
}



// ============================================================
// LANCHONETES BCG - LS / SF / LV
// Todas usam interiores originais do GTA SA e a tecla H.
// ============================================================
#define MAX_LANCHONETES_BCG 12
#define VW_LANCHONETES_BCG 7000


enum E_LANCH_BCG
{
    Float:lanX,
    Float:lanY,
    Float:lanZ,
    lanInterior,
    Float:lanIX,
    Float:lanIY,
    Float:lanIZ,
    lanTipo
};

new const g_LanchonetesBCG[MAX_LANCHONETES_BCG][E_LANCH_BCG] =
{
    // LS - Burger Shot
    {1199.1696, -918.1302, 43.1231, 10, 363.5720, -74.8460, 1001.5078, 0},
    {810.4948, -1616.0577, 13.5469, 10, 363.5720, -74.8460, 1001.5078, 0},
    // LS - Cluckin Bell
    {928.1744, -1352.8550, 13.3438, 9, 364.9440, -11.3540, 1001.8516, 1},
    {2420.0908, -1508.9302, 24.0000, 9, 364.9440, -11.3540, 1001.8516, 1},
    // LS - Pizza Stack
    {2083.2139, -1756.1418, 13.5469, 5, 372.5560, -133.6260, 1001.4922, 2},
    {1367.0000, -1270.0000, 13.5469, 5, 372.5560, -133.6260, 1001.4922, 2},

    // SF - Burger Shot
    {1199.0000, -1414.0000, 13.0000, 10, 363.5720, -74.8460, 1001.5078, 0},
    // SF - Cluckin Bell
    {-2140.0000, -246.0000, 36.5156, 9, 364.9440, -11.3540, 1001.8516, 1},
    // SF - Pizza Stack
    {-2670.0000, 258.0000, 4.6328, 5, 372.5560, -133.6260, 1001.4922, 2},

    // LV - Burger Shot
    {1615.0000, 2221.0000, 11.0625, 10, 363.5720, -74.8460, 1001.5078, 0},
    // LV - Cluckin Bell
    {2105.0000, 2228.0000, 11.0234, 9, 364.9440, -11.3540, 1001.8516, 1},
    // LV - Pizza Stack
    {2352.0000, 2533.0000, 10.8203, 5, 372.5560, -133.6260, 1001.4922, 2}
};

stock BCG_EntrarLanchonete(playerid, id)
{
    if(id < 0 || id >= MAX_LANCHONETES_BCG) return 0;

    g_LanchoneteAtual[playerid] = id;
    g_LanchoneteAtiva[playerid] = true;

    SetPlayerInterior(playerid, g_LanchonetesBCG[id][lanInterior]);
    SetPlayerVirtualWorld(playerid, VW_LANCHONETES_BCG + id);
    SetPlayerPos(playerid,
        g_LanchonetesBCG[id][lanIX],
        g_LanchonetesBCG[id][lanIY],
        g_LanchonetesBCG[id][lanIZ]);
    SetCameraBehindPlayer(playerid);

    switch(g_LanchonetesBCG[id][lanTipo])
    {
        case 0: SendClientMessage(playerid, 0x00BFFFff, "[LANCHONETE] Burger Shot - aperte H para sair.");
        case 1: SendClientMessage(playerid, 0x00BFFFff, "[LANCHONETE] Cluckin' Bell - aperte H para sair.");
        case 2: SendClientMessage(playerid, 0x00BFFFff, "[LANCHONETE] Pizza Stack - aperte H para sair.");
    }
    return 1;
}

stock BCG_SairLanchonete(playerid)
{
    new id = g_LanchoneteAtual[playerid];
    if(!g_LanchoneteAtiva[playerid] || id < 0 || id >= MAX_LANCHONETES_BCG)
        return 0;

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid,
        g_LanchonetesBCG[id][lanX],
        g_LanchonetesBCG[id][lanY],
        g_LanchonetesBCG[id][lanZ]);

    g_LanchoneteAtiva[playerid] = false;
    g_LanchoneteAtual[playerid] = -1;
    SendClientMessage(playerid, 0x00FF00ff, "[LANCHONETE] Voce saiu da lanchonete.");
    return 1;
}

stock BCG_VerificarLanchonete(playerid)
{
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
        return -1;

    for(new i = 0; i < MAX_LANCHONETES_BCG; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, 6.0,
            g_LanchonetesBCG[i][lanX],
            g_LanchonetesBCG[i][lanY],
            g_LanchonetesBCG[i][lanZ]))
            return i;
    }
    return -1;
}

new bool:CasaExisteBCG[MAX_CASAS_BCG];
new Float:CasaXBCG[MAX_CASAS_BCG];
new Float:CasaYBCG[MAX_CASAS_BCG];
new Float:CasaZBCG[MAX_CASAS_BCG];
new Float:CasaA_BCG[MAX_CASAS_BCG];
new CasaPrecoBCG[MAX_CASAS_BCG];
new CasaAluguelBCG[MAX_CASAS_BCG];
new CasaInteriorBCG[MAX_CASAS_BCG];
new CasaPickupBCG[MAX_CASAS_BCG];
new Text3D:CasaLabelBCG[MAX_CASAS_BCG];
new CasaDonoBCG[MAX_CASAS_BCG][MAX_PLAYER_NAME];
new CasaInquilinoBCG[MAX_CASAS_BCG][MAX_PLAYER_NAME];


// Enum para controle do menu em TextDraw
enum {
    MENU_BANCO_FECHADO = 0,
    MENU_BANCO_PRINCIPAL,
    MENU_BANCO_EXTRATO
}
new g_MenuBancoAberto[MAX_PLAYERS];


// Armazenamento das Player-TextDraws do Banco
new PlayerText:PTD_BancoFundo[MAX_PLAYERS];
new PlayerText:PTD_BancoCartao[MAX_PLAYERS];
new PlayerText:PTD_BancoInfos[MAX_PLAYERS][6]; // Alterado para array de 6 slots
new PlayerText:PTD_BancoBotoes[MAX_PLAYERS][6]; // 0:Deposito, 1:Saque, 2:Transferir, 3:Extrato, 4:Emprestimo, 5:Fechar
new PlayerText:PTD_ValoresDinamicos[MAX_PLAYERS][2];

// Sistema de historico simples para o Extrato (Salva as ultimas 3 movimentacoes)
enum e_Extrato {
    exTipo[24],
    exValor
}
new g_HistoricoBanco[MAX_PLAYERS][3][e_Extrato];

enum E_DADOS_CAIXA {
    bool:cxExiste,
    Float:cxX,
    Float:cxY,
    Float:cxZ,
    Float:cxA,
    cxObjeto,
    cxPickup,
    Text3D:cxText
}

new g_CaixasDados[MAX_CAIXAS][E_DADOS_CAIXA];
static DB:g_DB_Caixas;


#define DIALOG_MENU_CORPS       8550
#define DIALOG_COMPRA_ADRE      8551
#define DIALOG_ESCOLHER_FARDA   8552


#if !defined INVALID_PLAYER_TEXT_DRAW
    #define INVALID_PLAYER_TEXT_DRAW (PlayerText:0xFFFF)
#endif

#define MAX_ORGS 50
#define ARQUIVO_LOCAIS "Config/LocaisEquipar.ini"

enum E_LOCAL_DATA {
    bool:lcCriado,
    Float:lcX,
    Float:lcY,
    Float:lcZ,
    lcPickupID,
    Text3D:lcTextID
}
new LocalEquipar[MAX_ORGS][E_LOCAL_DATA];

// ================= HOSPITAIS CRIAVEIS =================
#define MAX_HOSPITAIS_BCG 50
#define VW_HOSPITAIS_BCG 6000

new bool:HospitalBCG[MAX_HOSPITAIS_BCG];
new Float:HospitalXBCG[MAX_HOSPITAIS_BCG];
new Float:HospitalYBCG[MAX_HOSPITAIS_BCG];
new Float:HospitalZBCG[MAX_HOSPITAIS_BCG];
new Float:HospitalABCG[MAX_HOSPITAIS_BCG];
new HospitalPickupBCG[MAX_HOSPITAIS_BCG];
new Text3D:HospitalLabelBCG[MAX_HOSPITAIS_BCG];

stock BCG_AtualizarLabelHospital(hospital)
{
    if(hospital < 0 || hospital >= MAX_HOSPITAIS_BCG || !HospitalBCG[hospital]) return 0;
    if(_:HospitalLabelBCG[hospital] != 0) Delete3DTextLabel(HospitalLabelBCG[hospital]);
    new texto[180];
    format(texto, sizeof(texto), "{00BFFF}[ HOSPITAL BCG ]\n{FFFFFF}Hospital #%d\n{00FF00}Aperte H para entrar", hospital + 1);
    HospitalLabelBCG[hospital] = Create3DTextLabel(texto, -1, HospitalXBCG[hospital], HospitalYBCG[hospital], HospitalZBCG[hospital] + 1.0, 20.0, 0, 0);
    return 1;
}

stock BCG_SalvarHospital(hospital)
{
    if(hospital < 0 || hospital >= MAX_HOSPITAIS_BCG || !HospitalBCG[hospital]) return 0;
    new arquivo[64];
    format(arquivo, sizeof(arquivo), "Hospital_%d.txt", hospital + 1);
    if(!DOF2_FileExists(arquivo)) DOF2_CreateFile(arquivo);
    DOF2_SetFloat(arquivo, "X", HospitalXBCG[hospital]);
    DOF2_SetFloat(arquivo, "Y", HospitalYBCG[hospital]);
    DOF2_SetFloat(arquivo, "Z", HospitalZBCG[hospital]);
    DOF2_SetFloat(arquivo, "A", HospitalABCG[hospital]);
    DOF2_SaveFile();
    return 1;
}

stock BCG_CarregarHospitais()
{
    new arquivo[64];
    for(new i = 0; i < MAX_HOSPITAIS_BCG; i++)
    {
        HospitalBCG[i] = false;
        HospitalPickupBCG[i] = 0;
        HospitalLabelBCG[i] = Text3D:0;
        format(arquivo, sizeof(arquivo), "Hospital_%d.txt", i + 1);
        if(!DOF2_FileExists(arquivo)) continue;

        HospitalXBCG[i] = DOF2_GetFloat(arquivo, "X");
        HospitalYBCG[i] = DOF2_GetFloat(arquivo, "Y");
        HospitalZBCG[i] = DOF2_GetFloat(arquivo, "Z");
        HospitalABCG[i] = DOF2_GetFloat(arquivo, "A");
        HospitalBCG[i] = true;
        HospitalPickupBCG[i] = CreatePickup(1318, 1, HospitalXBCG[i], HospitalYBCG[i], HospitalZBCG[i], -1);
        BCG_AtualizarLabelHospital(i);
    }
    return 1;
}

stock BCG_HospitalProximo(playerid, Float:distancia = 10.0)
{
    new hospital = -1;
    new Float:menor = distancia;
    for(new i = 0; i < MAX_HOSPITAIS_BCG; i++)
    {
        if(!HospitalBCG[i]) continue;
        new Float:d = GetPlayerDistanceFromPoint(playerid, HospitalXBCG[i], HospitalYBCG[i], HospitalZBCG[i]);
        if(d <= menor)
        {
            menor = d;
            hospital = i;
        }
    }
    return hospital;
}

// ================= COFRE DE ARMAS DAS ORGS =================
#define DIALOG_COFRE_ORG 19820
#define ARQUIVO_COFRES_ORG "Config/OrgsCofres.ini"

enum E_COFRE_ORG_DATA
{
    bool:cfCriado,
    cfOrgID,
    Float:cfX,
    Float:cfY,
    Float:cfZ,
    cfPickupID,
    Text3D:cfTextID,
    cfNome[40]
}
new CofreOrg[MAX_ORGS][E_COFRE_ORG_DATA];
new CofreOrgArma[MAX_ORGS][13];
new CofreOrgAmmo[MAX_ORGS][13];



// ================= BCG V4 ULTRA =================
#define DIALOG_BCG_TABLET       23200
#define DIALOG_BCG_TABLET_ORG   23201
#define DIALOG_BCG_TABLET_JOB   23202
#define DIALOG_BCG_JOBS2        23203
#define DIALOG_BCG_CHECKATT     23204
#define DIALOG_BCG_ACSTATUS     23205

new BCGV4_JobEntregas[MAX_PLAYERS];
new BCGV4_JobGanhos[MAX_PLAYERS];
new BCGV4_JobInicio[MAX_PLAYERS];
new BCGV4_ACScore[MAX_PLAYERS];
new BCGV4_ACLastTick[MAX_PLAYERS];
new Float:BCGV4_ACX[MAX_PLAYERS];
new Float:BCGV4_ACY[MAX_PLAYERS];
new Float:BCGV4_ACZ[MAX_PLAYERS];

// ================= BCG CIDADE V3 - SISTEMAS INTEGRADOS =================
#define MAX_FAMILIAS_BCG 50
#define MAX_VEIC_PICKUPS_BCG 80
#define MAX_GUERRAS_BCG 10
#define ARQ_FAMILIAS_BCG "Config/FamiliasBCG.ini"
#define ARQ_VEICPICK_BCG "Config/VeiculosPickupBCG.ini"
#define ARQ_GUERRAS_BCG "Config/GuerrasBCG.ini"

enum E_FAMILIA_BCG
{
    bool:famAtiva,
    famNome[32],
    famLider[MAX_PLAYER_NAME],
    famCor,
    famCofre,
    Float:famX,
    Float:famY,
    Float:famZ,
    famPickup,
    Text3D:famLabel
}
new FamiliaBCG[MAX_FAMILIAS_BCG][E_FAMILIA_BCG];
new PlayerFamiliaBCG[MAX_PLAYERS];

enum E_VEICPICK_BCG
{
    bool:vpAtivo,
    vpOrg,
    vpTrabalho,
    vpModelo,
    vpCor1,
    vpCor2,
    Float:vpX,
    Float:vpY,
    Float:vpZ,
    Float:vpA,
    vpPickup,
    Text3D:vpLabel
}
new VeicPickupBCG[MAX_VEIC_PICKUPS_BCG][E_VEICPICK_BCG];
new VeiculoServicoBCG[MAX_PLAYERS];

enum E_GUERRA_BCG
{
    bool:gwAtiva,
    gwOrgA,
    gwOrgB,
    gwPontosA,
    gwPontosB,
    gwInicio,
    gwDuracao,
    Float:gwX,
    Float:gwY,
    Float:gwZ,
    Float:gwRaio
}
new GuerraBCG[MAX_GUERRAS_BCG][E_GUERRA_BCG];

new CasaRouboCooldownBCG[MAX_CASAS_BCG];
new bool:CasaRoubandoBCG[MAX_PLAYERS];
new CasaRouboAlvoBCG[MAX_PLAYERS];
new CasaRouboInicioBCG[MAX_PLAYERS];

new bool:PrisaoMissaoBCG[MAX_PLAYERS];
new PrisaoEtapaBCG[MAX_PLAYERS];
new PrisaoRecompensaBCG[MAX_PLAYERS];

// ================= ORGS PERSONALIZADAS =================
// Slots 35 a 49 sao reservados para organizacoes criadas pelos proprios jogadores.
#define ORG_CUSTOM_INICIO 35
#define ORG_CUSTOM_FIM    49
new bool:OrgCustomAtiva[MAX_ORGS];
new OrgCustomNome[MAX_ORGS][40];
new OrgCustomCor[MAX_ORGS];

// Paleta escura: cada org personalizada recebe uma cor diferente.
new const OrgCustomCores[] =
{
    0x00008BFF, // azul escuro
    0x7CFC00FF, // verde claro
    0xC71585FF, // rosa escuro
    0xFF0000FF, // vermelho
    0xFFFF00FF, // amarelo
    0x696969FF, // cinza
    0xFFD700FF, // dourado
    0x00FFFFFF, // ciano
    0x2F4F4FFF, // cinza azulado
    0x00008BFF,
    0x7CFC00FF,
    0xC71585FF,
    0xFF0000FF,
    0xFFFF00FF,
    0xFFD700FF
};

stock BCG_CarregarOrgsPersonalizadas()
{
    new caminho[64], chave[40];
    for(new orgid = ORG_CUSTOM_INICIO; orgid <= ORG_CUSTOM_FIM; orgid++)
    {
        format(caminho, sizeof(caminho), "Config/OrgCustom_%d.txt", orgid);
        OrgCustomAtiva[orgid] = false;
        OrgCustomNome[orgid][0] = EOS;
        OrgCustomCor[orgid] = OrgCustomCores[orgid - ORG_CUSTOM_INICIO];

        if(DOF2_FileExists(caminho))
        {
            if(DOF2_GetInt(caminho, "Ativa") == 1)
            {
                format(OrgCustomNome[orgid], 40, "%s", DOF2_GetString(caminho, "Nome"));
                OrgCustomAtiva[orgid] = (strlen(OrgCustomNome[orgid]) > 0);
            }
            format(chave, sizeof(chave), "Cor");
            if(DOF2_GetInt(caminho, chave) != 0)
                OrgCustomCor[orgid] = DOF2_GetInt(caminho, chave);
        }
    }
    return 1;
}

stock BCG_SalvarOrgPersonalizada(orgid)
{
    if(orgid < ORG_CUSTOM_INICIO || orgid > ORG_CUSTOM_FIM) return 0;
    new caminho[64];
    format(caminho, sizeof(caminho), "Config/OrgCustom_%d.txt", orgid);
    if(!DOF2_FileExists(caminho)) DOF2_CreateFile(caminho);
    DOF2_SetInt(caminho, "Ativa", OrgCustomAtiva[orgid] ? 1 : 0);
    DOF2_SetString(caminho, "Nome", OrgCustomNome[orgid]);
    DOF2_SetInt(caminho, "Cor", OrgCustomCor[orgid]);
    DOF2_SaveFile();
    return 1;
}




// Identificadores de locais de entrada (Exemplo)
#define ENTRADA_DP_PRINCIPAL 1
#define ENTRADA_DP_SECUNDARIA 2



new OrigemEntrada[MAX_PLAYERS];

#define MAX_INVENTORY_SLOTS 20
#define MAX_WEIGHT 40.0

enum E_ITEM_DATA {
    itemName[32],
    itemQuantity,
    itemModel,
    bool:itemIsEquipment
};

new PlayerInventory[MAX_PLAYERS][MAX_INVENTORY_SLOTS][E_ITEM_DATA];
new bool:IsInventoryOpen[MAX_PLAYERS];
new SelectedInventorySlot[MAX_PLAYERS];

// Arrays de TextDraws do Inventário
new PlayerText:GARISBAWAH[MAX_PLAYERS][20];
new PlayerText:INVNAME[MAX_PLAYERS][7];
new PlayerText:INVINFO[MAX_PLAYERS][12];
new PlayerText:INVSLOTPREVIEW[MAX_PLAYERS][20];

#define SEGUNDOS_COMA         180 
#define SEGUNDOS_DESISTIR     60  

enum E_DADOS_MORTE {
    bool:pEmComa,
    Float:pMortoX,
    Float:pMortoY,
    Float:pMortoZ,
    Float:pMortoA,
    pMortoVirtualWorld,
    pMortoInterior,
    pTimerCicloSegundo, 
    pTempoRestanteComa,
    pTempoRestanteDesistir,
    bool:pPodeDesistir,
    pObjetoMaca
}

new g_DadosMorte[MAX_PLAYERS][E_DADOS_MORTE];
static DB:g_DB_Morte;

// TextDraws Globais do Sistema de Morte
new Text:TD_MorteFundo[MAX_PLAYERS];
new Text:TD_MortePainel[MAX_PLAYERS];
new Text:TD_MorteIcone[MAX_PLAYERS];
new Text:TD_MorteTitulo[MAX_PLAYERS];
new Text:TD_MorteLinha[MAX_PLAYERS];
new Text:TD_MorteTexto[MAX_PLAYERS];
new Text:TD_MorteAviso[MAX_PLAYERS];
new Text:TD_MorteBotaoDesistir[MAX_PLAYERS];
new Text:TD_MorteBotaoDesistirTxt[MAX_PLAYERS];
new Text:TD_MorteBotaoMedico[MAX_PLAYERS];
new Text:TD_MorteBotaoMedicoTxt[MAX_PLAYERS];

#define MAX_SPAWN_BIKES 50

enum e_SpawnBikeData
{
    bool:spAtivo,
    Float:spX,
    Float:spY,
    Float:spZ,
    Text3D:spTextID,
    spPickupID
};

// ============================================================
// VARIÁVEIS
// ============================================================



new SpawnBikeInfo[MAX_SPAWN_BIKES][e_SpawnBikeData];
new VeiculoPlayer[MAX_PLAYERS];
new Float:LatariaHealth[MAX_VEHICLES];
new LatariaPanels[MAX_VEHICLES];
new LatariaDoors[MAX_VEHICLES];
new LatariaLights[MAX_VEHICLES];
new LatariaTires[MAX_VEHICLES];


#define DIALOG_LISTA_CHAMADOS 9852 // (Ou o ID numerico/define livre do seu servidor)

#define MAX_ORGS_VEHICLES 50
#define MAX_VEHS_PER_ORG 4
#define DIALOG_CRIAR_ORG_VEH (9860)
#define DIALOG_MENU_ORG_VEH (9861)

enum e_OrgVehData
{
    ovCriado,
    ovOrgID,
    ovModelID,
    Float:ovSpawnX,
    Float:ovSpawnY,
    Float:ovSpawnZ,
    Float:ovSpawnA,
    ovSpawnID,
    Text3D:ovLabelID, // Armazena o ID do 3D Text Label
    ovPickupID        // Armazena o ID do Pickup
};

new OrgVehicles[MAX_ORGS_VEHICLES][MAX_VEHS_PER_ORG][e_OrgVehData];
new EditandoOrgVeh[MAX_PLAYERS][2]; // [0] = OrgID, [1] = SlotVeh (0 a 3)

//Defines Facilitadoras
#define Controle                 TogglePlayerControllable                                                                                    //                                                                                        //
#define ISP                      IsPlayerInRangeOfPoint                                                                                      //
#define SCM 					 SendClientMessage

//mapas

#include "modulos/mapas/favelasf.inc" 
#include "modulos/mapas/favelalv.inc" 
#include "modulos/mapas/favela14.inc" 
#include "modulos/mapas/neutra.inc" 
#include "modulos/mapas/neutrals.inc" 
#include "modulos/mapas/neutralv.inc"


#define FILE_POS "scriptfiles/pos.txt"

//sistema velocimetro
// --- Configuracoes do Sistema de Postos (Integrado) ---
#define MAX_COMBUSTIVEL 100
new GasolinaVeiculo[MAX_VEHICLES];

new PlayerText:cWspeedo[MAX_PLAYERS][10];
new PlayerSpeedo[MAX_PLAYERS]; // 0 = KM/H, 1 = MP/H
  
// Defina IDs unicos que nao estejam sendo usados no seu servidor
#define DIALOG_ORGS_MAIN        9900
#define DIALOG_ORGS_POLICIAIS   9901
#define DIALOG_ORGS_GANGSTERS   9902
#define DIALOG_ORGS_MAFIOSOS    9903
#define DIALOG_ORGS_TERRORISTAS 9904
#define DIALOG_ORGS_MERCENARIAS 9905
#define DIALOG_ORGS_NEUTRAS     9906
#define DIALOG_ORGS_PERSONALIZADAS 9907
  
#define DIALOG_LOJA_PRINCIPAL   6000
#define DIALOG_LOJA_VANTAGENS   6001
#define DIALOG_LOJA_SOCIO       6002
#define DIALOG_LOJA_VIP         6003
#define DIALOG_LOJA_VIP_ORG     6004
#define DIALOG_LOJA_ITENS_1     6005
#define DIALOG_LOJA_ITENS_2     6006
#define DIALOG_LOJA_VEICULOS    6007
#define DIALOG_RESGATAR_COINS   6008 
#define DIALOG_CONFIRMA_RESGATE 6009
#define DIALOG_MENU_MOCHILA 6010
#define DIALOG_DEFINIR_TAG 6011
#define DIALOG_MENU_JBL 6012
#define DIALOG_LINK_JBL 6013
#define DIALOG_BOLSOS 6014
#define DIALOG_BCG_LOJA_ANUNCIO 6020
#define DIALOG_BCG_COINS_ADMIN 6021
#define BCG_COINS_EXPIRACAO 604800
#define BCG_COINS_MAX_QUANTIDADE 1000000
#define BCG_COINS_MAX_TENTATIVAS 5
new ObjetoJBL[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...};
new Text3D:TextJBL[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};
new bool:JBLLigada[MAX_PLAYERS] = {false, ...};
new Float:JBLPos[MAX_PLAYERS][3];
new bool:OuvindoJBL[MAX_PLAYERS];
new LinkJBL[MAX_PLAYERS][128];
new Text3D:TagJogador[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};
#define MAX_PORTOES_SERVIDO 1000
#define DIALOG_SENHA_PORTAO 6015


enum e_PortaoDados {
    bool:pCriado,
    pObjetoID,
    Float:pX,
    Float:pY,
    Float:pZ,
    Float:pRotX,
    Float:pRotY,
    Float:pRotZ,
    pSenha[32],
    pDono[MAX_PLAYER_NAME],
    Text3D:pText3D
    
}; // <-- Certifique-se de que tem esse ponto e virgula aqui!
new PortaoInfo[MAX_PORTOES_SERVIDO][e_PortaoDados];
new PlayerEditandoPortaoID[MAX_PLAYERS] = {-1, ...};

new Text3D:PlayerID[MAX_PLAYERS]; // Cria a array para gerenciar os textos 3D dos jogadores

// Estrutura para armazenar o agendamento de coins
enum e_Agendamento {
    bool:agAtivo,
    agParaID,
    agQuantidade,
    agCodigo[32],
    agPedido,
    agCriadoEm,
    agExpiraEm,
    agTentativas,
    agStatus,
    agCriadoPor[MAX_PLAYER_NAME]
}
new PlayerAgendamento[MAX_PLAYERS][e_Agendamento];
new BCG_CoinsUltimoPedido[MAX_PLAYERS];
new bool:BCG_AnuncioComprado[MAX_PLAYERS];

#define CIMENTO_VEICULO_MODELO      524         // Caminhao de Cimento (Cement Truck)
#define CIMENTO_TEMPO_CONFERENCIA   30000       // 30 segundos conferindo a ficha
#define CIMENTO_TEMPO_DESCARGA      30000       // 30 segundos descarregando
#define CIMENTO_PAGAMENTO_BASE      1500        // Valor recebido pelo servico

// Coordenadas centrais da obra
static const Float:Cimento_Obra_X = 1248.4750;
static const Float:Cimento_Obra_Y = -1258.5659;
static const Float:Cimento_Obra_Z = 13.1651;

// Coordenadas do Bot / Mestre de Obras
static const Float:Cimento_Bot_X = 1248.212036;
static const Float:Cimento_Bot_Y = -1269.770385;
static const Float:Cimento_Bot_Z = 13.493798;

new Text3D:TextoDonoVeiculo[MAX_VEHICLES] = {Text3D:INVALID_3DTEXT_ID, ...};

// Coloque isso no topo do seu script, antes de qualquer include
#undef  MAX_PLAYERS
#define MAX_PLAYERS (500) // Altere para o numero exato de slots do seu server

#undef  MAX_VEHICLES
#define MAX_VEHICLES (50000) // Altere para o maximo de veiculos que tera no mapa

#undef  MAX_OBJECTS
#define MAX_OBJECTS (100000) // Reduza se nao usar tantos objetos globais

// ---- DEFINIcoES DE DIALOGS ----
#define DIALOG_MENU_BASE_ORG  9848
#define DIALOG_GARAGEM_ORG   9850

// ---- VARIaVEIS DO SISTEMA ----
new TempCriarOrgID[MAX_PLAYERS];
new Float:TempLocalComando[MAX_PLAYERS][3];
new Float:TempLocalSpawn[MAX_PLAYERS][4];
new RegistrouLocalComando[MAX_PLAYERS];
new RegistrouLocalSpawn[MAX_PLAYERS];
new PickupGaragemOrg[MAX_ORGS];
new Text3D:TextoGaragemOrg[MAX_ORGS];



new bool:CelularAberto[MAX_PLAYERS];
new CelularTela[MAX_PLAYERS]; // 0 = Home | 1 = Instagram

// Alocacao expandida e corrigida para os novos layouts profissionais
new PlayerText:CelularCarcacaTD[MAX_PLAYERS][11]; 
new PlayerText:CelularHomeTD[MAX_PLAYERS][40];    // Aumentado para 8 (4 Caixas + 4 Textos)
new PlayerText:CelularInstaTD[MAX_PLAYERS][8];   // Aumentado para 8 para corrigir o layout do botao azul

new PlayerText:CelularBloqueioTD[MAX_PLAYERS][15];

// Controles de digitacao dinamica
new SenhaCelular[MAX_PLAYERS][5];      // Armazena a senha definitiva de 4 digitos (ex: "1234")
new SenhaInput[MAX_PLAYERS][5];        // Armazena o que o jogador esta digitando na hora
new bool:CelularBloqueado[MAX_PLAYERS];
new PlayerText:CelularConfigTD[MAX_PLAYERS][15];
new PlayerText:CelularWhatsTD[MAX_PLAYERS][13];



// Banco de Dados do Instagram
enum iInfo {
    bool:TemContaInsta,
    InstaUser[32],
    InstaSeguidores,
    InstaSeguindo
}
new InstaDados[MAX_PLAYERS][iInfo];

// IDs de Comunicacao
#define DIALOG_INSTA_REGISTRO   9984
#define DIALOG_INSTA_POSTAR     9985



//sistema Spawn veh
#define DIALOG_ANTIFARM 5557 // Verifique se esse ID de dialog ja esta em uso
#define DIALOG_IRBASE 5558 // Use um ID que nao esteja em uso no seu servidor
//sistema de VoIP
// SampVoice desativado nesta compilacao: o include/plugin instalado nao fornece as natives usadas pela GM.
// gstream removido: variavel sem uso na base.
new lstream[MAX_PLAYERS];

//sistema login 

#define MAX_LOADING_TD 5
#define MAX_LOGIN_TD 16
#define MAX_REGISTER_TD 20

new PlayerText:LoadingTD[MAX_PLAYERS][MAX_LOADING_TD];
new PlayerText:LoginTD[MAX_PLAYERS][MAX_LOGIN_TD];
new PlayerText:RegisterTD[MAX_PLAYERS][MAX_REGISTER_TD];

//sistema posto
#define MAX_POSTOS          100
#define PASTA_POSTOS        "Postos/%d.ini"
#define CAPACIDADE_MAX      20000
#define MODELO_CAMINHAO     403 
#define PRECO_COMPRA_BASE   30


enum e_posto {
    bool:pCriado,
    pDono[MAX_PLAYER_NAME],
    pPrecoLitro,
    Float:pPosX,
    Float:pPosY,
    Float:pPosZ,
    pCombustivel,
    pLucro,
    pPickup,
    Text3D:pLabel
};

//comeco nova conce 
#define MAX_VEICULOS_CONCE 21

enum e_ConceVeiculos {
    cV_Nome[32],
    cV_ModelID,
    cV_Preco,
    cV_Categoria, // 1 = Carros, 2 = Motos, 3 = Outros
    bool:cV_Vip
};

// Banco de dados de veiculos da Concessionaria com valores ajustados
new const ConcelVehicles[MAX_VEICULOS_CONCE][e_ConceVeiculos] = {
    // Carros Normais e Esportivos
    {"BMW X7 2023", 400, 720000, 1, false},
    {"Blista Compact", 496, 45000, 1, false},
    {"Sultan", 560, 180000, 1, false},
    {"Super GT", 506, 250000, 1, false},
    {"Clover", 542, 35000, 1, false},
    {"Hilux SRX 2017", 543, 185000, 1, false},
    {"BMW X6 Competition", 489, 650000, 1, false},
    {"Banshee (BMW Z4)", 429, 350000, 1, false},
    {"Bullet", 541, 550000, 1, false},
    {"Buffalo", 402, 120000, 1, false},
    {"Comet", 480, 280000, 1, false},
    
    // Veiculos VIP (Carros)
    {"Infernus", 411, 1500000, 1, true},
    {"Turismo", 451, 1200000, 1, true},

    // Motos
    {"BMX", 510, 1500, 2, false},
    {"Biz (Faggio)", 462, 8000, 2, false},
    {"Sanchez", 468, 22000, 2, false},
    {"PCJ-600", 461, 35000, 2, false},
    {"Freeway", 463, 40000, 2, false},
    {"FCR-900", 521, 95000, 2, false},
    {"NRG-500", 522, 300000, 2, true},

    // Outros
    {"Kombi (Camper)", 483, 50000, 3, false}
};


// Variaveis de controle de sessao do jogador na Concessionaria
new ConcelCategoriaSelecionada[MAX_PLAYERS];
new ConcelIndexVeiculo[MAX_PLAYERS];
new Float:PosicaoOriginalPlayer[MAX_PLAYERS][4];
new bool:EmTestDrive[MAX_PLAYERS];
new TimerTestDrive[MAX_PLAYERS];

// Coordenadas da Loja da Concessionaria (Interior ou Local Isolado)
#define CONCE_LOCAL_X   2132.0010
#define CONCE_LOCAL_Y   -1149.9999
#define CONCE_LOCAL_Z   24.207

// Coordenadas para onde o veiculo de test-drive e spawnado temporariamente
#define TEST_SPAWN_X    2145.0000
#define TEST_SPAWN_Y    -1160.0000
#define TEST_SPAWN_Z    24.2000
#define TEST_SPAWN_A    0.0000

//fim nova conce

new const modelNames[212][] = {
    "BMW X7 2023", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
    "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
    "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Article Trailer", "Previon", "Coach",
    "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow",
    "Pizzaboy", "Tram", "Article Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
    "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
    "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
    "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "BMW X6 Competition",
    "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
    "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
    "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
    "Fortune", "Cadrona", "SWAT Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
    "Blade", "Streak", "Freight", "Vortex", "Vincent", "Bullet", "Clover", "Hilux SRX 2017", "Firetruck", "Hustler", "Intruder",
    "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster", "Monster",
    "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30",
    "Huntley", "Stafford", "BF-400", "News Van", "Tug", "Petrol Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Article Trailer 3", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD Car", "SFPD Car", "LVPD Car",
    "Police Rancher", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
    "Boxville", "Tiller", "Utility Trailer"
};

new PostoInfo[MAX_POSTOS][e_posto];
// Variaveis Globais
// Variaveis Globais
new bool:MotorLigado[MAX_VEHICLES]; // Guarda true (ligado) ou false (desligado)

new SlotAtual[MAX_PLAYERS]; // 0 = Nenhum, 1 = Slot 1, 2 = Slot 2


#define MAX_GARAGENS 50

enum e_garagem {
    bool:gCriada,
    Float:gPosX,
    Float:gPosY,
    Float:gPosZ,
    gPickup,
    Text3D:gLabel
};

new GaragemInfo[MAX_GARAGENS][e_garagem];
new VeiculoGaragem[MAX_PLAYERS]; // Armazena o ID do veiculo atual do player no servidor



// Variaveis Globais
new Text:Text_Global[17];
new PlayerText:Text_Player[MAX_PLAYERS][12];

// Exemplo de variaveis de status do jogador (0.0 a 100.0)
new Float:Status_Fome[MAX_PLAYERS];
new Float:Status_Sede[MAX_PLAYERS];
new Float:Status_Energia[MAX_PLAYERS];
new Float:Status_Sono[MAX_PLAYERS];
new bool:g_MorreuPorFome[MAX_PLAYERS];
new bool:g_MorreuPorSede[MAX_PLAYERS];

//NEW EMPREGO ifood
new Pizzas[MAX_PLAYERS];
new GanhaGorjeta[MAX_PLAYERS];
new timerGorjeta[MAX_PLAYERS];
new EntregandoPizza[MAX_PLAYERS];
new ubereats[MAX_PLAYERS];
#pragma unused ubereats

new Float: CheckPointsP[5][10] =
{
        {893.632263, -1638.655883, 14.492128},
        {964.145812, -1613.518310, 14.526670},
        {958.083801, -1827.693725, 12.136501},
        {2070.2686,-1703.0079,13.1825, 3.0},
        {1409.615722, -921.578308, 37.979232}

};

stock Float:GetVehicleSpeed(vehicleid)
{
    new Float:x, Float:y, Float:z;
    GetVehicleVelocity(vehicleid, x, y, z);
    return floatsqroot(x*x + y*y + z*z) * 180.0;
}

IsAbicycle(vehid) {
    switch(GetVehicleModel(vehid)) {
        case 481, 509, 510: return true;
    }
    return false;
}
stock IsVehicleInArray(vehicleid, const array[], size)
{
    for(new i = 0; i < size; i++)
    {
        if(vehicleid == array[i]) return 1;
    }
    return 0;
}
stock GetVehicleName(vehicleid, dest[], maxlength = sizeof(dest))
{
    new modelid = GetVehicleModel(vehicleid);

    if(400 <= modelid <= 611)
    {
        // Limpa o destino e copia o nome do modelo correspondente
        format(dest, maxlength, "%s", modelNames[modelid - 400]);
    }
    else
    {
        format(dest, maxlength, "Desconhecido");
    }
    return 1;
}


//CORES
#define VERDE                   0x21DD00FF
#define VERMELHO                0xFF030FFF
#define VERMELHO_ESCURO         0xE60000FF
#define VERMELHO_CLARO          0xFB0000FF
#define AMARELO                 0xFFFF00FF
#define LARANJA                 0xF97804FF
#define AZUL_CLARO              0x007BFFFF
#define ROXO                    0xB360FDFF
#define BRANCO		    		0xFFFFFFFF
#define PRETO                   0x000000FF
#define AZUL                    0x1229FAFF
#define VERDE_CLARO             0x38FF06FF
#define ROSA_CHOQUE             0xE100E1FF
#define VERDE_ESCURO            0x008040FF
#define CINZA                   0xCECECEFF
#define ROSA                    0xD52DFFFF
#define CINZA_ESCURO       		0x626262FF
#define VERDE_AGUA       		0x03D687FF
#define COLOR_YELLOW 			0xFFFF00AA
#define COLOR_BLUE 				0x2641FEAA
#define azul 					0x0099ffff
#define vermelho 				0xff0000ff
#define action 					0x00cc99ff
#define branco 					0xffffffff
#define Dialog_Admincmd 20005

//Defines
#define Site        "voce foi levado para o hospital"
#pragma tabsize 0
#define PRECO_NADA          0
#define PRECO_BIKE      	1000
#define PRECO_LAMBRETA      8000
#define PRECO_FCR900        100000
#define PRECO_SANCHEZ       15000
#define PRECO_SULTAN        500000
#define PRECO_RANCHER       60000
#define PRECO_BLISTA        30000
#define PRECO_SUPERGT       900000
#define PRECO_CLOVER        20000
#define PRECO_SADLER        25000
#define PRECO_CAMPER        20000
#define PRECO_BANSHEE       150000
#define PRECO_BULLET        100000
#define PRECO_BUFFALO       140000
#define PRECO_PCJ           70000
#define PRECO_FREEWAY       50000
#define PRECO_COMET         450000
#define PRECO_INFERNUS      1000000
#define PRECO_TURISMO       800000
#define PRECO_NRG           700000

//DIALOGS
#define DIALOG_REGISTRO         1
#define DIALOG_LOGIN            2
#define DIALOG_BEMVINDO         9990
#define DIALOG_MENUV            3
#define DIALOG_DESEMPREGADO     4
#define DIALOG_PIZZA            5
#define DIALOG_INTERNET         6
#define DIALOG_BANIDO           7
#define DIALOG_GPS              8
#define DIALOG_GPS_LOCAIS       9
#define DIALOG_GPS_CAIXAS       10
#define DIALOG_GPS_HQS          11
#define DIALOG_GPS_EMPREGOS     12
#define DIALOG_LOJAS            13
#define DIALOG_MENUCAMINHAO     14
#define DIALOG_CONVITE		    15
#define DIALOG_BANCO		    16
#define DIALOG_LICENCA		    17
#define DIALOG_CONFIRMACAO 		18
#define DIALOG_GARAGEM      	19
#define DIALOG_LOCALIZAR    	20
#define DIALOG_MENU_CAMI        21
#define DIALOG_SERVICO_MECANICO 22
#define DIALOG_ARMAS 			23
#define DIALOG_EMPREGOS 		24
#define DIALOG_AJUDA 			25
#define DIALOG_LOJA 			26
#define DIALOG_CELULAR 			27
#define DIALOG_APLICATIVOS 		28
#define DIALOG_GENERO           29
#define DIALOG_COR_PELE        35
#define DIALOG_NOVIDADES        30
#define DIALOG_CARDAPIO         31
#define DIALOG_CONCE_MAIN       32
#define DIALOG_CONCE_LISTA      33
#define DIALOG_CONCE_ACOES      34
#define         TELEMAP           2021
#define DIALOG_ORIGEM 5556 // Use um ID que nao esteja sendo usado
#define DIALOG_GMAIL_BCG 5590
#define DIALOG_GENERO_BCG 5591
#define DIALOG_PERSONAGEM_BCG 5592
#define DIALOG_COR_PELE_BCG 5593


// novos empregos
#define Entregador 5
#define taxi 6
#define cimento 7
#define lixeiro 8

#define TEMPO_NOVATO 10 // Horas necessarias

//roubo 1
#define BPF::%0(%1) 	forward %0(%1);\
						public %0(%1)

//ENUM e VARIAVEIS
enum pInfo
{
    // Variaveis com Tags (Booleans e Text3D)
    bool:Logado,
    bool:YouTuber,
    bool:Imortal,
    bool:Algemado,
    bool:Trabalhando,
    bool:Assistindo,
    bool:Farda,
    bool:Porte,
    bool:AntiFarmAtivado,
    Float:UltimaPos_X,
    Float:UltimaPos_Y,
    Float:UltimaPos_Z,
    Admin,
    Money,
    Grana,
    Matou,    
    Trabalho,
    Pizza,
    OrgID,
    pItem_Medikit,        
    pItem_Colete,           
    pItem_Galao,            
    pItem_KitReparo,        
    pItem_Blindagem,        
    pItem_Licencias,       
    pItem_CaixaItens,       
    pItem_Grafite,          
    pItem_SlotInv,
    pItem_JBL,
    pItem_Portao,
    pTemp,
    pItem_Titulo,            
    pTexto_Titulo[32],
    pVip,           
    pDiasVip,       
    pSocio,         
    pDiasSocio,     
    pPatrocinador,  
    pDiasPatrocinio,
    pLogged,
    Cargo,
    Skin,
    Banco,
    convite,
    Vip,
    pEstadoCenico,
    Socio,
    Level,
    Arrastado,
    Revistado,
    Celular,
    Genero,
    CorPele,
    Capacete,
    Mochila,
    Cone,
    cFerramentas,
    Discord,
    CNH,
    CNHb,
    CNHc,
    Corrida,
    Servico,
    Preso,
    TempoParado,
    SegundosJogados,
    pDonoPostoID,
    Estrelas,
    Coins,
    Adrenalina,
    DinheiroSujo
}


enum carinfo
{
    modelo1,
    id1,
    id2,
    bool:model1c,
    bool:model2c,
    modelo2,
    cor11,
    cor12,
    cor21,
    cor22,
    idc1,
    idc2,
    bool:CNH,
    gasosa1,
    gasosa2
    
}

enum Carinfo
{	carga,
	dono,
	bool:caminhao,
	motorista

}

new pOnline = 0;
new Dados[MAX_PLAYERS][carinfo];
new Contas[256];
new bool:logado[MAX_PLAYERS];
//new N[256];
new SaldoBanco, Tbanco;
new t = 15, preco[MAX_PLAYERS];
new CarDados[MAX_VEHICLES][Carinfo];
new Pdados[MAX_PLAYERS][pInfo];

stock BCG_AplicarCorOrg(playerid)
{
    new orgid = Pdados[playerid][OrgID];
    if(orgid >= ORG_CUSTOM_INICIO && orgid <= ORG_CUSTOM_FIM && OrgCustomAtiva[orgid])
    {
        SetPlayerColor(playerid, OrgCustomCor[orgid]);
        return 1;
    }
    return 0;
}
new String[1256];
new Passagem;new CarroMoto[5];
new StringContas[256];
new CarroDono[MAX_PLAYERS];
new algemado[MAX_PLAYERS];
new bool:onCheck[MAX_PLAYERS];
new bool:PrimeiroSpawn[MAX_PLAYERS];
//new entrar carro igual mta
new VehAluguel[MAX_PLAYERS];
new bool:VehCriado[MAX_PLAYERS];
//fim mta spawn
//new preso[MAX_PLAYERS];
//new text morte
new Text:Wasted[MAX_PLAYERS], Text:Wasted1[MAX_PLAYERS], Text:Wasted2[MAX_PLAYERS], Text:Wasted3[MAX_PLAYERS];
new revista[MAX_PLAYERS];
new lixo[MAX_PLAYERS];
new agencia;
new lac;
new sairagencia;
new sairlac;
new lojadearmas;
new sairlojadearmas;
new shop;
new sairshop;
new TimerRespawn;
new bikes[17];
new ttaxi[MAX_PLAYERS];
new tmec[MAX_PLAYERS];
new ccimento[MAX_PLAYERS];
new portao1;
new portao2;
new portaoeb;
new portaobope;
new portaopm;
new portaopf;
new portaorotam;
new portaomt;
new portaomec;
new portaopc;
new portaoada;
new taxis[8];
new Taximetro[MAX_PLAYERS][2];
new PrecoCorrida[MAX_PLAYERS];
new tvip[MAX_PLAYERS];
new equipado[MAX_PLAYERS];
new equipado2[MAX_PLAYERS];
new carrosa[6];
new carrosb[6];
new carrosc[4];
new autoescola[MAX_PLAYERS];
new autoescolab[MAX_PLAYERS];
new autoescolac[MAX_PLAYERS];
new conserto[MAX_PLAYERS];
new carregou[MAX_PLAYERS];
new servico[MAX_PLAYERS];
new lastVehicle[MAX_PLAYERS];
new Koniler[MAX_PLAYERS];
new TrafikKoni[MAX_PLAYERS][11];
new entrouveh[MAX_PLAYERS];
new Gari[MAX_PLAYERS];
new carroforte[MAX_PLAYERS];
new CarGari[4];
new UsouComando[MAX_PLAYERS];
#pragma unused lixos
new Float: lixos[3][10] =
{
        {2165.9741,-1986.2833,13.5547, 3.0},
        {2181.9966,-1996.3390,13.5469, 3.0},
        {2191.9995,-2005.1487,13.5469, 3.0}

};

new Float: revistas[10][20] =
{
        {738.7851,-1417.0139,13.1310, 3.0},
        {852.2314,-1418.4409,12.9476, 3.0},
        {1180.4878,-1261.2850,14.7872, 3.0},
        {2013.8502,-1732.7068,13.7525, 3.0},
        {2013.7817,-1641.8850,13.1544, 3.0},
        {2069.5669,-1628.7877,13.4837, 3.0},
        {2070.2686,-1703.0079,13.1825, 3.0},
        {2495.1145,-1686.5004,13.1218, 3.0},
        {2498.6030,-1645.5443,13.2113, 3.0},
        {2469.5779,-1648.0786,13.0789, 3.0}

};
new Float:pizzas[21][3]={
    {893.632263, -1638.655883, 14.492128},
	{964.145812, -1613.518310, 14.526670},
	{932.670532, -1804.158569, 13.401721},
	{958.083801, -1827.693725, 12.136501},
	{2270.000000, -1885.848876, 13.119217},
	{2272.757568, -1786.240844, 13.119362},
	{2310.204345, -1722.657958, 13.137979},
	{2327.071044, -1717.759399, 13.294915},
	{2494.544677, -1687.371093, 13.112207},
	{2166.231933, -1671.691772, 14.638225},
	{2230.343261, -1408.473510, 23.538789},
	{2185.181884, -1364.347412, 25.549226},
	{2150.067871, -1286.061401, 23.759048},
	{2074.678222, -1082.587280, 24.605592},
	{1326.161987, -1067.278808, 31.120498},
	{354.575683, -1280.636840, 53.277927},
	{551.514343, -1200.115234, 44.406139},
	{937.529663, -848.431152, 93.201301},
	{988.647460, -828.037780, 95.018913},
	{1298.677612, -798.665832, 83.691719},
	{1409.615722, -921.578308, 37.979232}
};
#pragma unused Internet
new Float:Internet[13][3]={
	{2191.769775, -1274.949218, 28.891036},
	{2208.250732, -1275.404541, 29.574104},
	{2229.420898, -1281.102172, 30.225606},
	{2246.282226, -1274.676879, 29.870000},
	{2185.036132, -1422.134887, 30.678867},
	{2155.450927, -1415.726928, 30.494731},
	{2067.845947, -1731.377075, 18.830413},
	{2385.132324, -1366.754760, 28.832691},
	{2475.197021, -1295.868774, 34.803211},
	{2373.201416, -1134.561157, 33.323802},
	{2459.448730, -1056.931884, 62.510082},
	{2134.173095, -1009.229858, 66.234375},
	{2110.934326, -1003.936157, 63.843750}
};
new Float:Ponto[14][3]={
	{2094.7310,-1770.4832,13.5536},
	{1921.5476,-1745.9194,13.5469},
	{1719.9519,-1724.1445,13.5469},
	{1475.8730,-1724.9971,13.5469},
	{1365.1414,-1295.2810,13.5469},
	{1047.6500,-1253.2531,14.9799},
	{805.3793,-1647.7974,13.5469},
	{815.7039,-1790.9313,13.6063},
	{924.8182,-1722.7667,13.5469},
	{1105.5189,-1579.7623,13.5804},
	{1369.2893,-1739.0616,13.5469},
	{1462.5426,-1739.1370,13.5469},
	{1681.8585,-1846.0226,13.5335},
	{1522.7222,-1932.5044,17.1150}

};
new SkinOrg[13][1]={
	26,
	287,
	285,
	285,
	285,
	281,
	282,
	280,
	286,
	98,
	283,
	280,
	284
};

new Mensagens[][] = {
"{00BFFF}BCG: Muito Obrigado Por sua presensa em Nossa cidade, chame seus amigos pra fazer o rp juntos!",
"{00BFFF}BCG: Caso tenha alguma duvida chame um admin ou use /ajuda,ou use /relatorio pra conversar com um suporte",
"{00BFFF}BCG: Olhe sempre nossas Regras para evitar ser punido!",
"{00BFFF}BCG: Se voce for vip use /ajuda e selecione vip para ver seus comandos.",
"{00BFFF}BCG: para ver os admins online use /admins.",
"{00BFFF}BCG: Para ver as novidades use /novidades.",
"{00BFFF}BCG: Entre No nosso discord da cidade Em Breve",
"{00BFFF}BCG: Viu algum tipo de Ant rp Use /reportar",
"{00BFFF}BCG: Compre vip e ajude o servidor a ficar online alem de ganhar varios beneficios exclusivo"
};
new Cores[][] = {
	{0x21DD00FF},
	{0xFF030FFF},
	{0xE60000FF},
	{0xFB0000FF},
	{0xFFFF00FF},
	{0xF97804FF},
	{0x00C2ECFF},
	{0xB360FDFF},
	{0xFFFFFFFF},
	{0x000000FF},
	{0x1229FAFF},
	{0x38FF06FF},
	{0xE100E1FF},
	{0x008040FF},
	{0xCECECEFF},
	{0xD52DFFFF},
	{0x626262FF},
	{0x03D687FF}
};

static stock CriarVeiculoComLabel(modelid, Float:x, Float:y, Float:z, Float:a, col1, col2, text[])
{
    new vid = CreateVehicle(modelid, x, y, z, a, col1, col2, 60000); // 60000 e o tempo de respawn
    if(vid != INVALID_VEHICLE_ID)
    {
        new Text3D:vLabel = Create3DTextLabel(text, 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, 1);
        Attach3DTextLabelToVehicle(vLabel, vid, 0.0, 0.0, 0.5);
    }
    return vid;
}

main()
{
	print("\n--------------------------------------\n");
	print("Cidade Grande RP Lion By Since 2022");
	print("----------------------------------\n");
}

new existe;

// ================= CELULAR BCG V16 =================
#define DIALOG_BCG_CELULAR        18700
#define DIALOG_BCG_SMS_ID         18701
#define DIALOG_BCG_SMS_TEXTO      18702
#define DIALOG_BCG_LIGAR_ID       18703
#define DIALOG_BCG_CONTATOS       18704
#define DIALOG_BCG_GPS            18705
#define DIALOG_BCG_ANUNCIO        18706
#define DIALOG_BCG_PIX_VALOR       18707
new PixDestino[MAX_PLAYERS];

new BCGCelularSMSDestino[MAX_PLAYERS];
new BCGCelularLigacao[MAX_PLAYERS];
new bool:BCGCelularAberto[MAX_PLAYERS];

// V036 Chromium interface: standard SA-MP dialog and command RPCs.
new bool:BCG36Client[MAX_PLAYERS], bool:BCG36Authenticated[MAX_PLAYERS];
new BCG39LastHudSent[MAX_PLAYERS];
stock BCG42Message(playerid, color, const message[])
{
    new bool:bcg45ErrorNotice = (!strfind(message, "ERRO", true) || !strfind(message, "[ERRO]", true) || !strfind(message, "Voce nao", true) || !strfind(message, "Uso:", true) || !strfind(message, "[USO]", true));
    new bool:bcg45SuccessNotice = (!strfind(message, "SUCESSO", true) || !strfind(message, "[SUCESSO]", true));
    if(BCG36Client[playerid] &&
       (bcg45ErrorNotice || bcg45SuccessNotice || !strcmp(message, "[ERRO]", true, 6) || !strcmp(message, "[SUCESSO]", true, 9) ||
        !strcmp(message, "[INFO]", true, 6) || !strcmp(message, "[ALUGUEL]", true, 9) ||
        !strcmp(message, "[VEICULO]", true, 9) || !strcmp(message, "[CELULAR]", true, 9) ||
        !strcmp(message, "[EMPREGO]", true, 9) || !strcmp(message, "[BANCO]", true, 7) || !strcmp(message,"[Mochila]",true,9)))
    {
        new packet[144], kind[8];
        if(bcg45ErrorNotice || strfind(message,"esgotado",true)!=-1) format(kind, sizeof(kind), "error");
        else if(bcg45SuccessNotice || !strcmp(message, "[ALUGUEL]", true, 9)) format(kind, sizeof(kind), "success");
        else format(kind, sizeof(kind), "info");
        format(packet, sizeof(packet), "[BCG:UI]NOTICE|%s|%s", kind, message);
        return SendClientMessage(playerid, color, packet);
    }
    return SendClientMessage(playerid, color, message);
}
#define SendClientMessage BCG42Message
#include <bcg_wardrobe47>

new BCG36LastHud[MAX_PLAYERS][180], BCG36Attempts[MAX_PLAYERS];
new BCG36LastAction[MAX_PLAYERS], BCG36Timer;
#include <bcg_phone38>
#include <bcg_favela43>
#include <bcg_inventory43>
new BCG36SMSName[MAX_PLAYERS][MAX_PLAYER_NAME];
new msgs[MAX_PLAYERS];
forward BCG36Tick();
forward BCG36Selector(playerid);
forward BCG36Enter(playerid);
forward BCG36Phone(playerid);
forward BCG36Dialog(playerid, dialogid, response, listitem, inputtext[]);

stock MostrarCelularBCG(playerid)
{
    return BCG38Open(playerid);
}



// ================= ID FIXO + TAG VOIP BCG =================
new BCG_IDFixo[MAX_PLAYERS];
new Text3D:BCG_TagCabeca[MAX_PLAYERS];
new bool:BCG_VoipLigado[MAX_PLAYERS];

// ================= ADMIN V26: ID FIXO / DEUS / LOG / MARCA =================
new Text:BCG_MarcaServidor;
new Text:BCG_MarcaEstrelas;
new Text:BCG_MarcaRoleplay;
new Text:BCG_MarcaDataHora;
new BCG_SkinAntesDeus[MAX_PLAYERS];

stock BCG_BuscarPorIDFixo(idfixo)
{
    foreach(Player, i)
    {
        if(IsPlayerConnected(i) && BCG_IDFixo[i] == idfixo) return i;
    }
    return INVALID_PLAYER_ID;
}

stock BCG_LogAdmin(playerid, const comando[])
{
    if(Pdados[playerid][Admin] <= 0) return 0;
    new File:f = fopen("admin_logs.txt", io_append);
    if(!f) return 0;
    new y,m,d,h,mi,se, linha[256];
    getdate(y,m,d); gettime(h,mi,se);
    format(linha, sizeof linha, "[%02d/%02d/%04d %02d:%02d:%02d] %s [IDF:%d] usou: %s\r\n", d,m,y,h,mi,se,Nome(playerid),BCG_IDFixo[playerid],comando);
    fwrite(f, linha); fclose(f);
    return 1;
}

forward BCG_AtualizarMarcaServidor();
public BCG_AtualizarMarcaServidor()
{
    new y,m,d,h,mi,se, marca[64];
    getdate(y,m,d); gettime(h,mi,se);
    format(marca, sizeof marca, "%02d/%02d/%04d - %02d:%02d:%02d", d,m,y,h,mi,se);
    TextDrawSetString(BCG_MarcaDataHora, marca);
    foreach(Player, i)
    {
        if(IsPlayerConnected(i) && Pdados[i][Imortal]) SetPlayerHealth(i, 99999.0);
    }
    return 1;
}


stock BCG_Nome(playerid, dest[], size)
{
    GetPlayerName(playerid, dest, size);
    return 1;
}

stock BCG_AtualizarTagCabeca(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(BCG_IDFixo[playerid] < 10000 || BCG_IDFixo[playerid] > 99999) return 0;

    new texto[64];
    format(texto, sizeof(texto), "{00FF32}ID: %d", BCG_IDFixo[playerid]);
    Update3DTextLabelText(BCG_TagCabeca[playerid], -1, texto);
    return 1;
}

stock BCG_CarregarOuCriarIDFixo(playerid)
{
    new conta[96], registro[96], chave[32], id, tentativas, nomeBCG[MAX_PLAYER_NAME];
    BCG_Nome(playerid, nomeBCG, sizeof(nomeBCG));
    format(conta, sizeof(conta), "Contas/%s.txt", nomeBCG);

    // Conta existente: mantem o ID que ja foi salvo.
    if(DOF2_FileExists(conta) && DOF2_GetInt(conta, "IDFixo") >= 10000 && DOF2_GetInt(conta, "IDFixo") <= 99999)
    {
        BCG_IDFixo[playerid] = DOF2_GetInt(conta, "IDFixo");

        // Registra o ID como ocupado para evitar colisao futura.
        format(registro, sizeof(registro), "IDFIXO/IDs.ini");
        if(!DOF2_FileExists(registro)) DOF2_CreateFile(registro);
        format(chave, sizeof(chave), "ID_%d", BCG_IDFixo[playerid]);
        DOF2_SetInt(registro, chave, 1);
        DOF2_SaveFile();

        BCG_AtualizarTagCabeca(playerid);
        return BCG_IDFixo[playerid];
    }

    // Conta nova: gera um ID aleatorio de exatamente 5 digitos.
    format(registro, sizeof(registro), "IDFIXO/IDs.ini");
    if(!DOF2_FileExists(registro)) DOF2_CreateFile(registro);

    id = 0;
    tentativas = 0;
    while(tentativas < 100)
    {
        id = random(90000) + 10000; // 10000 ate 99999
        format(chave, sizeof(chave), "ID_%d", id);

        if(DOF2_GetInt(registro, chave) != 1)
        {
            new ocupado = 0;
            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(i != playerid && IsPlayerConnected(i) && BCG_IDFixo[i] == id)
                {
                    ocupado = 1;
                    break;
                }
            }
            if(!ocupado) break;
        }
        tentativas++;
    }

    if(id < 10000 || id > 99999)
    {
        id = random(90000) + 10000;
        format(chave, sizeof(chave), "ID_%d", id);
    }

    BCG_IDFixo[playerid] = id;
    DOF2_SetInt(registro, chave, 1);
    DOF2_SaveFile();

    if(!DOF2_FileExists(conta)) DOF2_CreateFile(conta);
    DOF2_SetInt(conta, "IDFixo", id);
    DOF2_SaveFile();

    BCG_AtualizarTagCabeca(playerid);
    return id;
}

stock BCG_PlayerPorIDFixo(idfixo)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && BCG_IDFixo[i] == idfixo) return i;
    }
    return INVALID_PLAYER_ID;
}

forward BCG_AtualizarTagsVoip();
public BCG_AtualizarTagsVoip()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i)) BCG_AtualizarTagCabeca(i);
    }
    return 1;
}


#include <cg_costa_grande54>

public OnGameModeInit()
{
    CG54Load();
    CG52VoiceTimer=SetTimer("CG52VoiceTick",250,true);
    BCG43LoadFavela();
    BCG38Init();
    BCG36Timer = SetTimer("BCG36Tick", 500, true);
    // Marca Imperio Roleplay V29 - estilo proprio, encostada no canto inferior direito
    BCG_MarcaServidor = TextDrawCreate(632.0, 392.0, "~w~IMPERIO");
    TextDrawLetterSize(BCG_MarcaServidor, 0.31, 1.30);
    TextDrawAlignment(BCG_MarcaServidor, 3);
    TextDrawColor(BCG_MarcaServidor, 0xFFFFFFFF);
    TextDrawSetOutline(BCG_MarcaServidor, 2);
    TextDrawBackgroundColor(BCG_MarcaServidor, 0x000000CC);
    TextDrawFont(BCG_MarcaServidor, 2);
    TextDrawSetProportional(BCG_MarcaServidor, 1);

    BCG_MarcaRoleplay = TextDrawCreate(632.0, 406.0, "ROLEPLAY");
    TextDrawLetterSize(BCG_MarcaRoleplay, 0.29, 1.28);
    TextDrawAlignment(BCG_MarcaRoleplay, 3);
    TextDrawColor(BCG_MarcaRoleplay, 0xE00000FF);
    TextDrawSetOutline(BCG_MarcaRoleplay, 2);
    TextDrawBackgroundColor(BCG_MarcaRoleplay, 0x000000CC);
    TextDrawFont(BCG_MarcaRoleplay, 3);
    TextDrawSetProportional(BCG_MarcaRoleplay, 1);

    // Quatro estrelas separadas visualmente (fonte 2 evita os blocos da versao anterior)
    BCG_MarcaEstrelas = TextDrawCreate(632.0, 419.0, "~y~* * * *");
    TextDrawLetterSize(BCG_MarcaEstrelas, 0.23, 0.92);
    TextDrawAlignment(BCG_MarcaEstrelas, 3);
    TextDrawColor(BCG_MarcaEstrelas, 0xFFD700FF);
    TextDrawSetOutline(BCG_MarcaEstrelas, 1);
    TextDrawBackgroundColor(BCG_MarcaEstrelas, 0x000000CC);
    TextDrawFont(BCG_MarcaEstrelas, 2);
    TextDrawSetProportional(BCG_MarcaEstrelas, 1);

    BCG_MarcaDataHora = TextDrawCreate(632.0, 431.0, "00/00/0000 - 00:00:00");
    TextDrawLetterSize(BCG_MarcaDataHora, 0.17, 0.72);
    TextDrawAlignment(BCG_MarcaDataHora, 3);
    TextDrawColor(BCG_MarcaDataHora, 0xFFFFFFFF);
    TextDrawSetOutline(BCG_MarcaDataHora, 1);
    TextDrawBackgroundColor(BCG_MarcaDataHora, 0x000000CC);
    TextDrawFont(BCG_MarcaDataHora, 2);
    TextDrawSetProportional(BCG_MarcaDataHora, 1);
    SetTimer("BCG_AtualizarMarcaServidor", 1000, true);
    BCG_AtualizarMarcaServidor();
    SetTimer("BCG_AtualizarTagsVoip", 3000, true);
    CarregarMapasFavelaSf(); 
    CarregarMapasFavelaLv();
    CarregarMapasFavela14();
    CarregarMapasNeutraLv(); 
    CarregarMapasNeutraSf(); 
    CarregarMapasNeutraLs();
    
    CarregarSpawnsBikes();
    CarregarVeiculosOrg();
    
    

    
    UsePlayerPedAnims(); 
    InitFabricarArmasDB();
    InitRotaGangstersDB();
    InitDesmancheFiveMDB();
    InitMorteFiveM();
    
    CarregarGaragens();
    CarregarLocaisEquipar();
    BCG_CarregarCofresOrg();
    BCG_CarregarOrgsPersonalizadas();
    BCG_CarregarHospitais();
    BCG_CarregarFamilias();
    BCG_CarregarVeiculosPickup();
    ShowNameTags(0);
    CarregarGaragens_Pickups();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    // SampVoice desativado para manter compatibilidade com o compilador.
    // --- LOOP DE CARREGAMENTO MULTI-PORToES ATUALIZADO ---
    new caminhoArquivo[64];
    new carregados = 0;
    
    for(new p = 0; p < MAX_PORTOES_SERVIDO; p++)
    {
        format(caminhoArquivo, sizeof(caminhoArquivo), "Portao/Portao_%d.txt", p);
        
        if(fexist(caminhoArquivo))
        {
            new File:arq = fopen(caminhoArquivo, io_read);
            if(arq)
            {
                new linha[128], chave[32], valor[64], idx;
                format(PortaoInfo[p][pDono], MAX_PLAYER_NAME, "Ninguem");

                while(fread(arq, linha))
                {
                    // Limpa de forma segura os quebras de linha do Linux e do Windows (\r e \n)
                    for(new i = 0, len = strlen(linha); i < len; i++) {
                        if(linha[i] == '\r' || linha[i] == '\n') {
                            linha[i] = '\0';
                            break;
                        }
                    }

                    idx = strfind(linha, "=");
                    if(idx != -1)
                    {
                        strmid(chave, linha, 0, idx, sizeof(chave));
                        strmid(valor, linha, idx + 1, strlen(linha), sizeof(valor));

                        // Remove espacos extras que possam ter ficado grudados
                        if(chave[0] == ' ') strmid(chave, chave, 1, strlen(chave), sizeof(chave));

                        if(strcmp(chave, "Criado", true) == 0) PortaoInfo[p][pCriado] = (strval(valor) == 1) ? true : false;
                        else if(strcmp(chave, "Dono", true) == 0) format(PortaoInfo[p][pDono], MAX_PLAYER_NAME, valor);
                        else if(strcmp(chave, "PosX", true) == 0) PortaoInfo[p][pX] = floatstr(valor);
                        else if(strcmp(chave, "PosY", true) == 0) PortaoInfo[p][pY] = floatstr(valor);
                        else if(strcmp(chave, "PosZ", true) == 0) PortaoInfo[p][pZ] = floatstr(valor);
                        else if(strcmp(chave, "RotX", true) == 0) PortaoInfo[p][pRotX] = floatstr(valor);
                        else if(strcmp(chave, "RotY", true) == 0) PortaoInfo[p][pRotY] = floatstr(valor);
                        else if(strcmp(chave, "RotZ", true) == 0) PortaoInfo[p][pRotZ] = floatstr(valor);
                        else if(strcmp(chave, "Senha", true) == 0) format(PortaoInfo[p][pSenha], 32, valor);
                    }
                }
                fclose(arq);

                // Instancia o objeto e o respectivo Label 3D do portao carregado
                if(PortaoInfo[p][pCriado] == true)
                {
                    PortaoInfo[p][pObjetoID] = CreateObject(19912, PortaoInfo[p][pX], PortaoInfo[p][pY], PortaoInfo[p][pZ], PortaoInfo[p][pRotX], PortaoInfo[p][pRotY], PortaoInfo[p][pRotZ]);
                    
                    new labelTexto[128];
                    format(labelTexto, sizeof(labelTexto), "{FFFFFF}PORTAO ID: %d\n{FFFFFF}DONO: {FF0000}%s\n{FFFF00}Use /abrirportao [Senha]", p, PortaoInfo[p][pDono]);
                    PortaoInfo[p][pText3D] = Create3DTextLabel(labelTexto, 0xFFFFFFFF, PortaoInfo[p][pX], PortaoInfo[p][pY], PortaoInfo[p][pZ] + 1.0, 20.0, 0, 1);
                    carregados++;
                }
            }
        }
    }
    printf("[SISTEMA DE PORTOES]: %d portoes existentes foram carregados com sucesso!", carregados);
    // Timer de 5 segundos para uma verificacao mais precisa
    ManualVehicleEngineAndLights(); 
    for(new i = 0; i < MAX_POSTOS; i++)
    {
        new path[64];
        format(path, sizeof(path), PASTA_POSTOS, i);
        if(DOF2_FileExists(path)) 
        {
            PostoInfo[i][pCriado] = true;
            format(PostoInfo[i][pDono], MAX_PLAYER_NAME, DOF2_GetString(path, "Dono"));
            PostoInfo[i][pPrecoLitro] = DOF2_GetInt(path, "PrecoLitro");
            PostoInfo[i][pPosX] = DOF2_GetFloat(path, "PosX");
            PostoInfo[i][pPosY] = DOF2_GetFloat(path, "PosY");
            PostoInfo[i][pPosZ] = DOF2_GetFloat(path, "PosZ");
            PostoInfo[i][pCombustivel] = DOF2_GetInt(path, "Combustivel");
            PostoInfo[i][pLucro] = DOF2_GetInt(path, "Lucro");

            PostoInfo[i][pPickup] = CreatePickup(1239, 1, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ], -1);
            PostoInfo[i][pLabel] = CreateDynamic3DTextLabel("Carregando...", -1, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ]+1.5, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
            AtualizarPosto(i);
        }
    }
    // Cria os postos padrao que ainda nao existem. Postos criados pelo admin continuam preservados.
    CriarPostosPadrao();
    // --- SISTEMA DE CAIXAS ELETRoNICOS ---
    g_DB_Caixas = db_open("caixas_eletronicos.db");
    db_query(g_DB_Caixas, "CREATE TABLE IF NOT EXISTS caixas (ID INTEGER PRIMARY KEY, X REAL, Y REAL, Z REAL, A REAL)");
    

    // Carrega os caixas salvos no banco de dados
    new DBResult:res = db_query(g_DB_Caixas, "SELECT ID, X, Y, Z, A FROM caixas");
    new rows = db_num_rows(res);
    for(new i = 0; i < rows; i++) {
        new id = db_get_field_assoc_int(res, "ID");
        if(id >= 0 && id < MAX_CAIXAS) {
            g_CaixasDados[id][cxX] = db_get_field_assoc_float(res, "X");
            g_CaixasDados[id][cxY] = db_get_field_assoc_float(res, "Y");
            g_CaixasDados[id][cxZ] = db_get_field_assoc_float(res, "Z");
            g_CaixasDados[id][cxA] = db_get_field_assoc_float(res, "A");
            g_CaixasDados[id][cxExiste] = true;
            // Caixa fisico + marcador dourado na frente (estilo RP)
            g_CaixasDados[id][cxObjeto] = CreateDynamicObject(19324, g_CaixasDados[id][cxX], g_CaixasDados[id][cxY], g_CaixasDados[id][cxZ] - 0.3, 0.0, 0.0, g_CaixasDados[id][cxA]);
            new Float:mx, Float:my, Float:mz;
            mx = g_CaixasDados[id][cxX] - (1.25 * floatsin(-g_CaixasDados[id][cxA], degrees));
            my = g_CaixasDados[id][cxY] - (1.25 * floatcos(-g_CaixasDados[id][cxA], degrees));
            mz = g_CaixasDados[id][cxZ];
            g_CaixasDados[id][cxPickup] = CreateDynamicPickup(1274, 1, mx, my, mz - 0.55, -1, -1, -1, 25.0);
            new str[128];
            format(str, sizeof(str), "{00BFFF}Caixa Eletr\xf4nico {FFFFFF}[%d]\n{FFFFFF}Pressione {FFFF00}'H' {FFFFFF}para acessar", id);
            g_CaixasDados[id][cxText] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, mx, my, mz + 0.05, 8.0);
        }
        db_next_row(res);
    }
    db_free_result(res);
    // -------------------------------------
    
    
    Text_Global[0] = TextDrawCreate(130.000, 427.000, "LD_POKE:cd10c");
    TextDrawTextSize(Text_Global[0], 15.000, 19.000);
    TextDrawColor(Text_Global[0], 255);
    TextDrawFont(Text_Global[0], 4);

    Text_Global[1] = TextDrawCreate(147.000, 427.000, "LD_POKE:cd10c");
    TextDrawTextSize(Text_Global[1], 15.000, 19.000);
    TextDrawColor(Text_Global[1], 255);
    TextDrawFont(Text_Global[1], 4);

    Text_Global[2] = TextDrawCreate(113.000, 427.000, "LD_POKE:cd10c");
    TextDrawTextSize(Text_Global[2], 15.000, 19.000);
    TextDrawColor(Text_Global[2], 255);
    TextDrawFont(Text_Global[2], 4);

    Text_Global[3] = TextDrawCreate(151.000, 432.000, "Z");
    TextDrawLetterSize(Text_Global[3], 0.238, 0.799);
    TextDrawColor(Text_Global[3], -1);
    TextDrawSetOutline(Text_Global[3], 1);
    TextDrawFont(Text_Global[3], 1);

    Text_Global[4] = TextDrawCreate(154.000, 430.000, "Z");
    TextDrawLetterSize(Text_Global[4], 0.239, 0.799);
    TextDrawColor(Text_Global[4], -1);
    TextDrawSetOutline(Text_Global[4], 1);
    TextDrawFont(Text_Global[4], 1);

    Text_Global[5] = TextDrawCreate(114.000, 429.000, "LD_BEAT:chit");
    TextDrawTextSize(Text_Global[5], 13.000, 12.000);
    TextDrawColor(Text_Global[5], -1);
    TextDrawFont(Text_Global[5], 4);

    Text_Global[6] = TextDrawCreate(125.000, 434.000, "LD_POKE:cd10c");
    TextDrawTextSize(Text_Global[6], -11.000, 3.000);
    TextDrawColor(Text_Global[6], 255);
    TextDrawFont(Text_Global[6], 4);

    Text_Global[7] = TextDrawCreate(116.000, 435.000, "LD_SPAC:white");
    TextDrawTextSize(Text_Global[7], 9.000, 1.000);
    TextDrawColor(Text_Global[7], -1);
    TextDrawFont(Text_Global[7], 4);

    Text_Global[8] = TextDrawCreate(134.000, 438.000, "V");
    TextDrawLetterSize(Text_Global[8], 0.289, -1.000);
    TextDrawColor(Text_Global[8], -1);
    TextDrawSetOutline(Text_Global[8], 1);
    TextDrawFont(Text_Global[8], 1);

    Text_Global[9] = TextDrawCreate(133.000, 433.000, "LD_BEAT:chit");
    TextDrawTextSize(Text_Global[9], 8.000, 7.000);
    TextDrawColor(Text_Global[9], -1);
    TextDrawFont(Text_Global[9], 4);

    Text_Global[10] = TextDrawCreate(136.000, 432.000, "LD_SPAC:white");
    TextDrawTextSize(Text_Global[10], 2.000, 4.000);
    TextDrawColor(Text_Global[10], -1);
    TextDrawFont(Text_Global[10], 4);

    Text_Global[11] = TextDrawCreate(134.000, 433.000, "(");
    TextDrawLetterSize(Text_Global[11], 0.250, 0.499);
    TextDrawColor(Text_Global[11], 512819199);
    TextDrawSetOutline(Text_Global[11], 1);
    TextDrawFont(Text_Global[11], 1);

    Text_Global[12] = TextDrawCreate(96.000, 427.000, "LD_POKE:cd10c");
    TextDrawTextSize(Text_Global[12], 15.000, 19.000);
    TextDrawColor(Text_Global[12], 255);
    TextDrawFont(Text_Global[12], 4);

    Text_Global[13] = TextDrawCreate(99.000, 435.000, "V");
    TextDrawLetterSize(Text_Global[13], 0.418, 0.600);
    TextDrawColor(Text_Global[13], -1);
    TextDrawSetOutline(Text_Global[13], 1);
    TextDrawFont(Text_Global[13], 1);

    Text_Global[14] = TextDrawCreate(97.000, 430.000, "LD_BEAT:chit");
    TextDrawTextSize(Text_Global[14], 8.000, 8.000);
    TextDrawColor(Text_Global[14], -1);
    TextDrawFont(Text_Global[14], 4);

    Text_Global[15] = TextDrawCreate(102.000, 430.000, "LD_BEAT:chit");
    TextDrawTextSize(Text_Global[15], 8.000, 8.000);
    TextDrawColor(Text_Global[15], -1);
    TextDrawFont(Text_Global[15], 4);

    Text_Global[16] = TextDrawCreate(99.000, 432.000, "LD_BEAT:chit");
    TextDrawTextSize(Text_Global[16], 8.000, 8.000);
    TextDrawColor(Text_Global[16], -1);
    TextDrawFont(Text_Global[16], 4);
    

    // Timer do HUD: atualiza necessidades e velocimetro sem ficar atrasado.
    SetTimer("UpdateHUD", 500, true);
    
    // LOJAS NATIVAS DO GTA - acesso pela tecla H
    CreateDynamic3DTextLabel("{00BFFF}24/7{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 1833.1807, -1842.7574, 13.5781, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}BURGER SHOT{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 1199.1696, -918.1302, 43.1231, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}CLUCKIN BELL{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2420.0908, -1508.9302, 24.0000, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}PIZZA STACK{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2083.2139, -1756.1418, 13.5469, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}AMMU-NATION{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 1362.5700, -1748.7300, 13.5324, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}BINCO{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2244.3733, -1665.4698, 15.4766, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}SUB URBAN{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2112.8867, -1211.0930, 23.9630, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}ZIP{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 1457.0710, -1137.2300, 23.9560, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}PROLAPS{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 499.9180, -1360.6280, 16.3692, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}VICTIM{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2262.1001, -1669.9000, 15.2813, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}DIDIER SACHS{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 451.8410, -1478.7800, 30.2147, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}BARBEARIA{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2070.4431, -1793.3087, 13.5469, 8.0);
    CreateDynamic3DTextLabel("{00BFFF}TATUAGEM{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para entrar", -1, 2229.5649, -1721.0928, 13.5625, 8.0);

    //3ds Gerais
    // Hospital: entradas/saidas sao controladas exclusivamente pelo sistema de hospitais criaveis.
    CreateDynamic3DTextLabel("{00BFFF}[ Entrada Loterica ]{FFFFFF}\nAperte 'F'", -1, 1631.8076, -1172.9432, 24.0871, 25.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Saida Loterica ]{FFFFFF}\nAperte 'F'", -1, 834.8356, 7.4374, 1004.1536, 6.0);
	//spawn 
    CreateDynamicPickup(1239, 1, 1675.535278, -2311.576660, 13.547585); // Spawn
    CreateDynamic3DTextLabel("{FF3030}[ Alugar Quad ]{FFFFFF}\nAperte {FFFF00}H{FFFFFF}", -1, 1675.535278, -2311.576660, 13.547585, 8.0);
    //conce
    CreateDynamic3DTextLabel("{00BFFF}[ Concessionaria Cidade Grande Roleplay ]{FFFFFF}\nAperte 'F'", -1, 2131.819824, -1151.320922, 24.055484, 10.0);
    CreateDynamicPickup(1239, 1, 2131.819824, -1151.320922, 24.055484); // Detran dentro
    //Prefeitura
    CreateDynamic3DTextLabel("{00BFFF}[ Prefeitura ]\n{00BFFF}Cidade Grande Roleplay{FFFFFF}\nAperte 'F'\nOu Use: /prefeitura", -1, 361.9771,173.5715,1008.4697, 7.0);
    //loja de skin
    CreateDynamic3DTextLabel("{00BFFF}[ Loja de Roupas ]\n{00BFFF}Cidade Grande Roleplay{FFFFFF}\nAperte 'F'\nOu Use: /lojaskins", -1, 207.4660,-100.7381,1005.2578, 15.0);
	//Pizzaria
	CreateDynamicPickup(1582, 1, 376.6913,-118.8031,1001.4995); // Pizzaria
	//Entrada Hotel
	CreateDynamicPickup(19132, 1, 2233.1541, -1159.7782, 25.8902); // Entrada Hotel
	CreateDynamicPickup(19132, 1, 2210.61, 1866.45, -68.63); // Saida Hotel
	//Detran
	CreateDynamicPickup(19132, 1, 2895.918457, -848.660583, 10.875000); // Entrada HQ Detran
	CreateDynamicPickup(19132, 1, 354.1271, 168.0593, 1020.0844); // Saida Hq Detran
	CreateDynamicPickup(19133, 1, 2897.312011, -787.273742, 10.860000); // Apreender Veiculo 1
	CreateDynamicPickup(1581, 1, 354.6284,164.2485,1019.9844); // Detran dentro
	//Cadeia
	CreateDynamicPickup(19132, 1, 1797.410156, -1578.759765, 14.083669); // Entrada Cadeia
	CreateDynamicPickup(19132, 1, 965.0224,2107.7881,1011.0303); // Saida Cadeia
	//Hotel
	CreateDynamic3DTextLabel("{00BFFF}[ Entrada Hotel ]{FFFFFF}\nAperte 'F'", -1, 2233.1541, -1159.7782, 25.8902, 25.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Saida Hotel ]{FFFFFF}\nAperte 'F'", -1, 2210.61, 1866.45, -68.63, 25.0);
	//Hotel
	CreateDynamic3DTextLabel("{FFDC33}[ Pizzaria ]{FFFFFF}\nAperte 'F'\nOu Use: /pizzaria\nMenu Bebidas e Comidas", -1, 376.6913,-118.8031,1001.4995, 25.0);
	//Detran
	CreateDynamic3DTextLabel("{00BFFF}[ Entrada Detran ]{FFFFFF}\nAperte 'F'", -1, 2895.918457, -848.660583, 10.875000, 25.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Saida Detran ]{FFFFFF}\nAperte 'F'", -1, 354.1271, 168.0593, 1020.0844, 7.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Apreender Detran ]{FFFFFF}\nUse: /apreenderveiculo", -1, 2897.312011, -787.273742, 10.860000, 25.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Menu Detran ]\n{FFFFFF}Aperte 'F' Para acessar o Menu",-1,354.6284,164.2485,1019.9844, 6.0);//Detran
	//Mecanicas
	CreateDynamic3DTextLabel("{00BFFF}[ Mecanica ]{FFFFFF}\nPara Acessar o Menu\nBuzine\nOu Mentalize: /oficina", -1, 827.211975, -2126.043945, 14.205229, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Mecanica ]{FFFFFF}\nPara Acessar o Menu\nBuzine\nOu Mentalize: /oficina", -1, 814.734619, -2126.043945, 14.205229, 15.0);
	CreateDynamicPickup(1239, 1, 814.734619, -2126.043945, 14.205229);
	CreateDynamicPickup(1239, 1, 827.211975, -2126.043945, 14.205229);
	//Mercado Negro
	CreateDynamic3DTextLabel("{00BFFF}Mercado Negro{FFFFFF}\nPara Acessar o Menu\nAperte 'F'\nOu Mentalize: /comprarng", -1, -1517.006347, -669.691650, 804.909545, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Saida Mercado Negro{FFFFFF}\nAperte 'F'",-1, -1542.785766, -668.847839, 801.743896, 15.0);
	CreateDynamicPickup(1239, 1, -1517.006347, -669.691650, 804.909545);
	CreateDynamicPickup(1239, 1, -1542.785766, -668.847839, 801.743896);
	//Funcoes da Mecanica
	CreateDynamicPickup(19832, 1,1015.027038, -1969.322875, 13.145632); // Ferramentas Mecanica
	CreateDynamic3DTextLabel("{00BFFF}[ Mecanica ]{FFFFFF}\nPegar Ferramentas\nMentalize: /ferramentas", -1, 1015.027038, -1969.322875, 13.145632, 15.0);
	//Dps Ls/Sf/Lv
	CreateDynamic3DTextLabel("{00BFFF}DEPARTAMENTO POLICIAL [ SAN FIERRO ]{FFFFFF}\nAperte 'F'", -1, -1605.560180, 710.272521, 13.867187, 15.0);
	CreateDynamicPickup(1239, 1, -1605.560180, 710.272521, 13.867187);
	//3d geraisl Corps
	CreateDynamic3DTextLabel("{00BFFF}DEPARTAMENTO POLICIAL [ LAS VENTURAS ]{FFFFFF}\nAperte 'F'", -1, 2290.146484, 2432.084960, 10.820312, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Descida Elevador{FFFFFF}\nAperte 'F'", -1, 213.975296, 118.895988, 1003.218750, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Subida Elevador{FFFFFF}\nAperte 'F'", -1, -1616.315673, 687.561035, 7.187500, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}SAIDA DEPARTAMENTO{FFFFFF}\nAperte 'F'", -1, 288.859375, 166.923309, 1007.171875, 15.0);
	CreateDynamicPickup(1239, 1, 213.975296, 118.895988, 1003.218750);
	CreateDynamicPickup(1239, 1,-1616.315673, 687.561035, 7.187500);
	CreateDynamicPickup(1239, 1, 2290.146484, 2432.084960, 10.820312);
	//Areas Prender Ls
	CreateDynamic3DTextLabel("{00BFFF}Sala Prisao de Detentos{FFFFFF}\nAperte 'F'", -1, 247.775314, 86.874473, 1003.640625, 15.0);
	//Emprego Astro
	CreateDynamic3DTextLabel("{00BFFF}EMPREGO ASTRONAUTA{FFFFFF}\nAperte 'F'", -1, -357.020874, 1593.916870, 76.664779, 15.0);
	CreateDynamicPickup(1239, 1, -357.020874, 1593.916870, 76.664779);
	//Academia
	CreateDynamic3DTextLabel("{00BFFF}[ Entrada Academia ]{FFFFFF}\nAperte 'F'", -1, 2229.6052, -1721.5137, 13.6361, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Saida Academia ]{FFFFFF}\nAperte 'F'", -1, 772.4014, -5.2436, 1000.7128, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Estilo de Andar ]{FFFFFF}\nMentalize: /academia", -1, 756.8827,5.7345,1000.7001, 15.0);
	//Cadeia
	CreateDynamic3DTextLabel("{00BFFF}[ Entrada Cadeia ]{FFFFFF}\nAperte 'F'", -1, 1797.410156, -1578.759765, 14.083669, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Saida Cadeia ]{FFFFFF}\nAperte 'F'", -1, 965.0224,2107.7881,1011.0303, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Detencao ]{FFFFFF}\nDetencao de Infratores\nMentalize: /prender", -1, 263.654327, 86.864784, 1001.039062, 15.0);
 	//Governo
	CreateDynamic3DTextLabel("{00BFFF}[ Entrada Governo ]{FFFFFF}\nAperte 'F'", -1, 1123.3267,-2037.0034,69.8874, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Saida Governo ]{FFFFFF}\nAperte 'F'", -1, 231.5619, 2348.3682, 1017.4250, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Setup - Governo Federal ]{FFFFFF}\nAperte a Tecla: 'F'\n\nReajustes e Afins", -1, 224.5500,2348.3811,1017.1298, 15.0);
	//Hospital BCH
	CreateDynamic3DTextLabel("{00BFFF}[ Hospital BCG ]{FFFFFF}\nAperte 'F'", -1, 362.7882,170.0925,1025.7891, 7.0);

	//Bater Cartao Profissoes
	// - Taxista
	CreateDynamic3DTextLabel("{00BFFF}Profissao Taxista{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 512.148437, -1609.703247, 16.134069, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Taxista{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 502.850036, -1609.703857, 16.386989, 15.0);
	CreateDynamicPickup(1275, 1, 512.148437, -1609.703247, 16.134069); // Taxista
	CreateDynamicPickup(1210, 1, 502.850036, -1609.703857, 16.386989); // Pickup Profissao Taxista LS
	// - Carro Forte
	CreateDynamic3DTextLabel("{00BFFF}Profissao Carro Forte{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 1286.806762, -1342.865600, 13.566249, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Carro Forte{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 1286.805541, -1351.766845, 13.570462, 15.0);
	CreateDynamicPickup(1275, 1, 1286.806762, -1342.865600, 13.566249); // Carro Forte
	CreateDynamicPickup(1210, 1, 1286.805541, -1351.766845, 13.570462); // Pickup Profissao CARRO FORTE LS
	// - Samu
	CreateDynamic3DTextLabel("{00BFFF}Profissao Samu{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 352.471069, 156.880249, 1025.789062, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Samu{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 355.527313, 154.155899, 1025.789062, 15.0);
	CreateDynamicPickup(1275, 1, 352.471069, 156.880249, 1025.789062); // Samu
	CreateDynamicPickup(1210, 1, 355.527313, 154.155899, 1025.789062); // Maleta profissao Samu
	// - Piloto de Aviao
	CreateDynamic3DTextLabel("{00BFFF}Profissao Piloto de Aviao{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 1897.7458,-2233.7820,13.5469, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Piloto de Aviao{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 1896.2604,-2235.1931,13.5469, 15.0);
	CreateDynamicPickup(1275, 1, 1897.7458,-2233.7820,13.5469); // Piloto de Aviao
	CreateDynamicPickup(1210, 1, 1896.2604,-2235.1931,13.5469); // Maleta profissao Piloto de Aviao
	// - Motorista de Onibus
	CreateDynamic3DTextLabel("{00BFFF}Profissao Motorista de Onibus{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 1978.135131, -2178.122070, 13.546875, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Motorista de Onibus{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 1972.435058, -2178.131591, 13.546875, 15.0);
	CreateDynamicPickup(1275, 1, 1978.135131, -2178.122070, 13.546875); // Motorista de Onibus
	CreateDynamicPickup(1210, 1, 1972.435058, -2178.131591, 13.546875); // Maleta profissao Motorista de Onibus
	// - Mecanico
	CreateDynamic3DTextLabel("{00BFFF}Profissao Mecanico{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 1022.140258, -1947.853393, 13.132724, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Mecanico{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 1018.006347, -1953.843750, 13.132724, 15.0);
	CreateDynamicPickup(1275, 1, 1022.140258, -1947.853393, 13.132724); // Mecanico
	CreateDynamicPickup(1210, 1, 1018.006347, -1953.843750, 13.132724); // Maleta profissao Mecanico
	// - Minerador
	CreateDynamic3DTextLabel("{00BFFF}Profissao Minerador{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 593.7274,885.8852,-44.2218, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Minerador{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 593.5403,883.7221,-44.2018, 15.0);
	CreateDynamicPickup(1275, 1, 593.7274,885.8852,-44.2218); // Minerador
	CreateDynamicPickup(1210, 1, 593.5403,883.7221,-44.2018); // Maleta profissao Minerador
	// - Caminhoneiro
	CreateDynamic3DTextLabel("{00BFFF}Profissao Caminhoneiro{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 2426.3784,-2099.0190,13.5469, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Caminhoneiro{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 2428.4053,-2099.0222,13.5469, 15.0);
	CreateDynamicPickup(1275, 1, 2426.3784,-2099.0190,13.5469); // Caminhoneiro
	CreateDynamicPickup(1210, 1, 2428.4053,-2099.0222,13.5469); // Maleta profissao Caminhoneiro
    // - Pescador
	CreateDynamic3DTextLabel("{00BFFF}Profissao Pescador{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 365.5013,-2041.5222,7.6719, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Pescador{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 365.7218,-2043.5771,7.6719, 15.0);
	CreateDynamicPickup(1275, 1, 365.5013,-2041.5222,7.6719); // Pescador
	CreateDynamicPickup(1210, 1, 365.7218,-2043.5771,7.6719); // Maleta profissao Pescador
	// Presentes
	CreateDynamic3DTextLabel("{00BFFF}Caixinha Para Novatos!{FFFFFF}\nMentalize: /caixinha para resgatar seu presente!", -1, 1479.9702,-1639.4752,14.1484, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Caixinha Para Novatos!{FFFFFF}\nMentalize: /caixinhasf para resgatar seu presente!", -1, -2706.019775, 376.155609, 4.972459, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Caixinha Para Novatos!{FFFFFF}\nMentalize: /caixinhalv para resgatar seu presente!", -1, 2179.533691, 1679.583984, 11.046875, 15.0);
	CreateDynamicPickup(19056, 1, 1479.9702,-1639.4752,14.1484); // Presente
	CreateDynamicPickup(19056, 1, -2706.019775, 376.155609, 4.972459); // Presente
	CreateDynamicPickup(19056, 1, 2179.533691, 1679.583984, 11.046875); // Presente
	//Dp Ls
	CreateDynamic3DTextLabel("{00BFFF}DEPARTAMENTO POLICIAL [LOS SANTOS]{FFFFFF}\nAperte 'F'\nPara Entrar.", -1, 1555.499877, -1675.593994, 16.195312, 15.0);
	CreateDynamicPickup(1239, 1, 1555.499877, -1675.593994, 16.195312);
	//LimparFicha
	CreateDynamic3DTextLabel("{00BFFF}Empregos Gerais!{FFFFFF}\nAperte 'F'\nOu Mentalize: /empregos.", -1, 358.236206, 163.155456, 1008.382812, 15.0);
	CreateDynamicPickup(1239, 1, 358.236206, 163.155456, 1008.382812);
	//Banco Pref Ls
	CreateDynamic3DTextLabel("{00BFFF}Banco do Brasil{FFFFFF}\nAperte 'F'\nOu Mentalize: /banco.", -1, 358.386749, 183.878906, 1008.382812, 15.0);
	CreateDynamicPickup(1239, 1, 358.386749, 183.878906, 1008.382812);
    // - Eletricista
	CreateDynamic3DTextLabel("{00BFFF}Profissao Eletricista{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 1213.1133,-976.8253,43.4766, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Eletricista{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 1210.9911,-976.6908,43.4766, 15.0);
	CreateDynamicPickup(1275, 1, 1213.1133,-976.8253,43.4766); // Eletricista
	CreateDynamicPickup(1210, 1, 1210.9911,-976.6908,43.4766); // Maleta profissao Eletricista
    // - Uber Eats
	CreateDynamic3DTextLabel("{00BFFF}Profissao Entregador de Pizza{FFFFFF}\nMentalize /ppizza para iniciar seu espediente.", -1, 2096.701660, -1815.467773, 12.945860, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Entregador de Pizza{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 2100.8501,-1802.0475,13.5547, 15.0);
	CreateDynamicPickup(1239, 1, 2096.701660, -1815.467773, 12.945860); // Uber Eats
	CreateDynamicPickup(1239, 1, 2100.8501,-1802.0475,13.5547); // Maleta profissao Uber Eats
	// gasolina posto
	CreateDynamic3DTextLabel("{00BFFF}Pegar Gasolina{FFFFFF}\nMentalize /carregarp para carregar aqui.", -1, 2504.645751, -2422.853515, 13.625000, 15.0);
	CreateDynamicPickup(1239, 1, 2504.645751, -2422.853515, 13.625000); // Uber Eats
    // - Lixeiro
	CreateDynamic3DTextLabel("{00BFFF}Profissao Lixeiro{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 2201.9426,-1970.3651,13.7841, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Lixeiro{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 2197.4280,-1972.5259,13.5585, 15.0);
	CreateDynamicPickup(1275, 1, 2201.9426,-1970.3651,13.7841); // Lixeiro
	CreateDynamicPickup(1210, 1, 2197.4280,-1972.5259,13.5585); // Maleta profissao Lixeiro
    // - Transportador de Gas
	CreateDynamic3DTextLabel("{00BFFF}Profissao Transportador de Gas{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, 2742.7185,-2453.9648,13.8623, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Transportador de Gas{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, 2747.0212,-2451.5234,13.6484, 15.0);
	CreateDynamicPickup(1275, 1, 2742.7185,-2453.9648,13.8623); // Transportador de Gas
	CreateDynamicPickup(1210, 1, 2747.0212,-2451.5234,13.6484); // Maleta profissao Transportador de Gas
    // - Leiteiro
	CreateDynamic3DTextLabel("{00BFFF}Profissao Leiteiro{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, -362.959564, -1417.140014, 25.726562, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Leiteiro{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, -370.678314, -1416.726440, 25.726562, 15.0);
	CreateDynamicPickup(1275, 1, -362.959564, -1417.140014, 25.726562); // Leiteiro
	CreateDynamicPickup(1210, 1, -370.678314, -1416.726440, 25.726562); // Maleta profissao Leiteiro
    // - Transportador de Leite
	CreateDynamic3DTextLabel("{00BFFF}Profissao Transportador de Leite{FFFFFF}\nMentalize /trabalhar para iniciar seu espediente.", -1, -392.187957, -1433.139160, 25.726562, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Profissao Transportador de Leite{FFFFFF}\nMentalize /emprego para trabalhar aqui.", -1, -400.004119, -1433.167968, 25.726562, 15.0);
	CreateDynamicPickup(1275, 1, -392.187957, -1433.139160, 25.726562); // Transportador de Leite
	CreateDynamicPickup(1210, 1, -400.004119, -1433.167968, 25.726562); // Maleta profissao Transportador de Leite
    // - Eletricista
	CreateDynamic3DTextLabel("{00BFFF}[ Eletricista ]\n{FFFFFF}Para Pegar uma Antena\nUse: '/procurarantena'", -1, 1219.6281,-978.8286,43.1662, 15.0);
    CreateDynamicPickup(19132, 1, 1219.6281,-978.8286,43.1662); // Eletricista
    // - Uber Eats
	CreateDynamic3DTextLabel("{00BFFF}[ Uber Eats ]\n{FFFFFF}Para Pegar uma Antena\nUse: '/pegarentrega'", -1, 1173.9260,-900.2118,42.9755, 15.0);
    CreateDynamicPickup(19131, 1, 1173.9260,-900.2118,42.9755); // Uber Eats
    // - Lixeiro
	CreateDynamic3DTextLabel("{FFFFFF}Iniciar Coleta\nUse: /pegarcoleta", -1, 2197.3044,-1977.4719,14.0898, 30.0);
    CreateDynamicPickup(19133, 1, 2197.3044,-1977.4719,14.0898); // Lixeiro
    // - Transportador de Gas
	CreateDynamic3DTextLabel("{00FF00}Petro {FFDC33}Bras\nUse: /pegargas", -1, 2788.7644,-2417.7234,13.5752, 30.0);
    CreateDynamicPickup(1370, 1, 2788.7644,-2417.7234,13.5752); // Transportador de Gas
	// - Leiteiro
	CreateDynamic3DTextLabel("{00FF00}[ Leiteiro ]\n{FFFFFF}Para Vender Seu Balde\nUse: '/venderbalde", -1, -378.322937, -1428.564208, 25.726562, 30.0);

	CreateDynamicPickup(2037, 1, -77.7951,90.1682,3.1172); // Minerador Vender Minerios

    //Transportador de Leite
    CreateDynamic3DTextLabel("{FFFFFF}Estoque de Leite\nPara Carregar\nUse: /carregarbarris", -1, -407.218475, -1458.199218, 25.726562, 35.0);
    CreateDynamicPickup(1279, 1, -407.218475, -1458.199218, 25.726562); // Carregando Leite

	// CARRO FORTE
	CreateDynamic3DTextLabel("{00BFFF}Carregamento de Malotes BCG{FFFFFF}\nMentalize: /carregarcr", -1, 1276.197998, -1355.414672, 12.883812, 25.0); // Carregamento Malotes LS
	CreateDynamic3DTextLabel("{00BFFF}Descarregamento de Malotes BCG{FFFFFF}\nMentalize: /descarregarcr", -1, 2521.5579,2447.7927,10.5474, 25.0); // Descarregamento LS 1
	CreateDynamic3DTextLabel("{00BFFF}Descarregamento de Malotes BCG{FFFFFF}\nMentalize: /descarregarcr", -1, -1979.6724,436.8765,26.0521, 25.0); // Descarregamento LS 2

	// - Minerador - Cavar e afins
	CreateDynamic3DTextLabel("{FFDC33}[ Minerador ]\n{FFFFFF}Para Pegar uma Pa, Use: '/pegarpa", -1, 589.7626,876.4470,-42.4973, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Minerio\nUse: /cavar", -1, 607.4472,871.9578,-41.9849, 35.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Minerio\nUse: /cavar", -1, 636.7669,858.3895,-40.7802, 35.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Minerio\nUse: /cavar", -1, 634.9982,824.8788,-41.0494, 35.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Minerio\nUse: /cavar", -1, 600.6653,927.3137,-39.9690, 35.0);
	CreateDynamic3DTextLabel("{FFDC33}[ Minerador ]\n{FFFFFF}Para Vender Minerios, Use: '/venderminerios", -1, 589.9833,887.6249,-44.1768, 15.0);
	CreateDynamicPickup(2237, 1, 589.7626,876.4470,-42.4973); // Minerador Pegar Pa
	CreateDynamicPickup(2037, 1, 589.9833,887.6249,-44.1768); // Minerador Vender Minerios

	// - Caminhoneiro
    CreateDynamic3DTextLabel("{FFDC33}[ Caminhoneiro ]\n{FFFFFF}Para Carregar Seu Caminhao\nUse: /carregarcaminhao", -1, 2458.4473,-2079.9343,14.0890, 15.0);
    CreateDynamic3DTextLabel("{FFDC33}[ Caminhoneiro ]\n{FFFFFF}Para Carregar Seu Caminhao\nUse: /carregarcaminhao", -1, 2468.3164,-2079.5596,14.1465, 15.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ Area de Descarregamento ]\nUse: /descarregarcaminhao", -1, -66.5074,-1119.7275,1.6407, 15.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ Area de Descarregamento ]\nUse: /descarregarcaminhao", -1, -63.4429,-1110.8347,1.6256, 15.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ Area de Descarregamento ]\nUse: /descarregarcaminhao", -1, 89.4293,-307.3791,2.1250, 15.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ Area de Descarregamento ]\nUse: /descarregarcaminhao", -1, 498.5314,890.9719,-31.7174, 15.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ Area de Descarregamento ]\nUse: /descarregarcaminhao", -1, -2674.8149,-279.8309,7.7207, 15.0);
    CreateDynamic3DTextLabel("{FFFFFF}[ Area de Descarregamento ]\nUse: /descarregarcaminhao", -1, -378.2044,-1428.6229,26.3214, 15.0);
    CreateDynamicPickup(1575, 1, 2458.4473,-2079.9343,14.0890); //Carregar
    CreateDynamicPickup(1575, 1, 2468.3164,-2079.5596,14.1465); //Carregar
    CreateDynamicPickup(1577, 1, -378.2044,-1428.6229,26.3214); // Descarregar
    CreateDynamicPickup(1577, 1, -66.5074,-1119.7275,1.6407); // Descarregar
    CreateDynamicPickup(1577, 1, -63.4429,-1110.8347,1.6256); // Descarregar
    CreateDynamicPickup(1577, 1, 89.4293,-307.3791,2.1250); // Descarregar
    CreateDynamicPickup(1577, 1, 498.5314,890.9719,-31.7174); // Descarregar
    CreateDynamicPickup(1577, 1, -2674.8149,-279.8309,7.7207); // Descarregar

	// - Pescador
	CreateDynamic3DTextLabel("{00BFFF}[ Pescador ]\n{FFFFFF}Pegar Vara\nUse: /pegarvara", -1, 374.3467,-2054.9998,8.0156, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}[ Pescador ]\n{FFFFFF}Venda de Peixes\nUse: '/venderpeixes", -1, 380.8993,-2021.7938,7.8359, 15.0);
	CreateDynamicPickup(18632, 1, 374.3467,-2054.9998,8.0156); // Pescador Pegar Vara
	CreateDynamicPickup(19133, 1, 380.8993,-2021.7938,7.8359); // Minerador Vender Peixes
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 403.8827,-2087.8359,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 398.8961,-2088.0762,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 396.2401,-2088.0640,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 391.0365,-2087.9773,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 383.5742,-2088.0588,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 375.1155,-2088.1501,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 369.8172,-2088.4141,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 367.5167,-2088.1882,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 362.2197,-2088.2456,7.8359, 15.0);
	CreateDynamic3DTextLabel("{FFFFFF}Ponto de Pesca\nUse: /pescar", -1, 354.4208,-2088.0469,7.8359, 15.0);

	// - Embarques Piloto de Aviao
	CreateDynamic3DTextLabel("{00BFFF}Local de Embarque{FFFFFF}\nMentalize /embarcar para Embarcar os Passageiros.", -1, 1904.2090,-2343.4321,14.4688, 80.0);
	CreateDynamicPickup(1314, 1, 1904.2090,-2343.4321,14.4688); // Embarque
	CreateDynamic3DTextLabel("{00BFFF}Local de Embarque{FFFFFF}\nMentalize /embarcar para Embarcar os Passageiros.", -1, 1903.5121,-2375.1155,14.4681, 80.0);
	CreateDynamicPickup(1314, 1, 1903.5121,-2375.1155,14.4681); // Embarque
	CreateDynamic3DTextLabel("{00BFFF}Local de Embarque{FFFFFF}\nMentalize /embarcar para Embarcar os Passageiros.", -1, 1903.3196,-2404.3496,14.4581, 80.0);
	CreateDynamicPickup(1314, 1, 1903.3196,-2404.3496,14.4581); // Embarque
	CreateDynamic3DTextLabel("{00BFFF}Local de Embarque{FFFFFF}\nMentalize /embarcar para Embarcar os Passageiros.", -1, 1903.3085,-2439.3501,14.4609, 80.0);
	CreateDynamicPickup(1314, 1, 1903.3085,-2439.3501,14.4609); // Embarque

	// - Iniciar Rota Motorista de Aviao
	CreateDynamic3DTextLabel("{00BFFF}Local de Subida de Passageiros{FFFFFF}\nMentalize /iniciarrota para Subir os Passageiros.", -1, 1973.8085,-2197.4260,13.6472, 80.0);
	CreateDynamicPickup(19132, 1, 1973.8085,-2197.4260,13.6472); // Iniciar Rota

	/* Textos 3D Gerais */
	CreateDynamic3DTextLabel("{FFDC33}[ Auto Escola BCG ]{FFFFFF}\nAperte F\nOu Use: /carteiras.", -1, 831.2525,-510.2213,996.6475, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Delegacia{FFFFFF}\nAperte 'F' Para Abrir", -1, 246.4466,72.9573,1003.6406, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Delegacia{FFFFFF}\nAperte 'F' Para Abrir", -1, 250.2749,63.3569,1003.6406, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Delegacia{FFFFFF}\nAperte 'F' Para Entrar", -1,  1556.302856, -1643.823608, 13.545200, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Delegacia{FFFFFF}\nAperte 'F' Para Sair", -1, 246.7555,62.3229,1003.6406, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Mercado Negro{FFFFFF}\nLos Santos\nAperte: 'F'", -1, 2151.120849, -1013.906066, 62.732738, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Auto Escola{FFFFFF}\nAperte 'F' Para Entrar", -1,  1411.6307,-1699.4390,13.5395, 15.0);
	CreateDynamic3DTextLabel("{00BFFF}Auto Escola{FFFFFF}\nAperte 'F' Para Sair", -1, 819.6603,-510.0458,996.6475, 15.0);

     //assalto
    CreateDynamic3DTextLabel("{00BFFF}Roubar Cofre{FFFFFF}\n{FF2400}Roube Aqui\n{FFFFFF}Use: /roubarl", -1, 820.559204, 11.162190, 1004.193908, 15.0);// SAIDA
     
     
	// PREFEITURA
	CreateDynamic3DTextLabel("{00BFFF}Prefeitura BCG{FFFFFF}\n{00FF00}Entrada\n{FFFFFF}Aperte F", -1, 1481.1603,-1772.3116,18.7958, 15.0);// ENTRADA
	CreateDynamic3DTextLabel("{00BFFF}Prefeitura BCG{FFFFFF}\n{FF2400}Saida\n{FFFFFF}Aperte F", -1, 390.7675,173.7833,1008.3828, 15.0);// SAIDA

	// BANCO
	CreateDynamic3DTextLabel("{00BFFF}Banco BCG{FFFFFF}\n{00FF00}Entrada\n{FFFFFF}Aperte F", -1, 1310.2577,-1366.7959,13.5066, 5.0);// ENTRADA
	CreateDynamic3DTextLabel("{00BFFF}Banco BCG{FFFFFF}\n{FF2400}Saida\n{FFFFFF}Aperte F", -1, 1412.589477, -4.538511, 1000.885131, 5.0);// SAIDA

	//CAIXAS REGISTRADORAS
    CreateDynamic3DTextLabel("{00BFFF}[ 24/7 BCG ]\n{FFFFFF}Caixa Registradora\n/roubar\nPara Assaltar a Loja", -1, 341.0920,-1808.5919,5.0303, 15.0); // 24/7 Praia
    CreateDynamic3DTextLabel("{00BFFF}[ 24/7 BCG ]\n{FFFFFF}Caixa Registradora\n/roubar\nPara Assaltar a Loja", -1, 2521.1106, -1544.1344, 24.2189, 15.0); // 24/7 Praia

	//Roubos do Banco
	CreateDynamic3DTextLabel("{FFFFFF}Dinheiro do {FFDC33}Cofre\n{FFFFFF}Use: /roubardinheiro", -1, -188.340682, 3025.252929, 24.924200, 20.0);
	CreateDynamicPickup(1274, 1, -188.340682, 3025.252929, 24.924200); //
	CreateDynamic3DTextLabel("{00BFFF}Cofre BBCG{FFFFFF}\n{FF2400}Saida\n{FFFFFF}Aperte F", -1, -175.142059, 3043.080810, 24.155199, 3.0);// SAIDA

    CreateActor(16, Cimento_Bot_X, Cimento_Bot_Y, Cimento_Bot_Z, 270.0);

    
    
    CreateDynamic3DTextLabel("{00BFFF}MESTRE DE OBRAS{FFFFFF}\nMentalize: /entregarficha", -1, 1247.544067, -1269.511962, 13.488520, 30.0); // grotti fora
    
	//DESMANCHE
	CreateDynamic3DTextLabel("{00BFFF}Desmanche BCG{FFFFFF}\nMentalize: /Desmanchar", -1, 157.4813,-22.4043,1.7018, 30.0); // grotti fora

    
    //Fim 3dS Gerais
    SendRconCommand("hostname Cidade Grande Roleplay | O Recomeco");
    SendRconCommand("gamemodetext Brazil-RP");
    SendRconCommand("language PT-BR");
    
    // Adicione esta linha junto com os outros SetTimer dentro do seu OnGameModeInit:
    SetTimer("TimerControleJBL", 2000, true);
    SetTimer("AtualizarTempo", 1000, true);
    SetTimer("atualizartext", 1000, true);
    SetTimer("AtualizarChatBubble", 1000, true);
    SetTimer("DescontarDiasPremium", 86400000, true); // 24 horas em milissegundos

    //-----------------------------BIKES DO EMPREGO DE ifood-------------------------------
    
    // BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1203.4000000,-976.2999900,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1204.9000000,-976.2999900,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1206.2000000,-976.4000200,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1207.6000000,-976.5000000,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1209.1000000,-976.5999800,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1210.6000000,-976.7000100,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1212.2000000,-976.7999900,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1213.7000000,-976.9000200,43.2000000,180.0000000,0,74); //Mountain Bike
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicle(510,1215.1000000,-977.0000000,43.2000000,180.0000000,0,74); //Mountain Bike
    
    Create3DTextLabel("{FFFFFF}[{99ccff}IFOOD{FFFFFF}]\n{FFFFFF}/trabalhar", 0x00BFFF, 1199.5811, -918.6766, 43.117,10.55555, 0, 0);
    AddStaticPickup(1210, 23, 1707.3555,950.1088,10.55555); // Pegar empreg
    //lojin de ac
    Create3DTextLabel("/comprarac", AZUL_CLARO, -2237.031494,130.176788,1035.414062, 50.0, 0, 0);
    AddStaticPickup(19134, 23, -2237.031494,130.176788,1035.414062);

    Create3DTextLabel("{FFFFFF}[{99ccff}CARRO FORTE{FFFFFF}]\n{FFFFFF}/trabalhar", 0xFFA500AA, 1707.3555,950.1088,10.55555, 0, 0);
    AddStaticPickup(1210, 23, 1707.3555,950.1088,10.55555); // Pegar emprego
    Create3DTextLabel("/lsgrana", branco, 1667.4336,982.0659,10.8203, 50.0, 0, 0);

	CarGari[0] = AddStaticVehicle(428,1652.1335,988.9089,10.9432,177.0624,39,128);
	CarGari[1] = AddStaticVehicle(428,1665.2104,988.5955,10.9448,181.1184,39,128);
	CarGari[2] = AddStaticVehicle(428,1655.3357,988.3295,10.9447,180.6551,39,128);
	CarGari[3] = AddStaticVehicle(428,1658.7667,988.7879,10.9440,182.6511,39,128);
    
    CriarVeiculoComLabel(581, 1067.1000, -288.8999, 73.7000, 186.0, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(581, 1070.8000, -289.3999, 73.7000, 185.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(581, 1074.3000, -289.8999, 73.7000, 185.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(581, 1077.5000, -290.2999, 73.7000, 185.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(560, 1055.7000, -301.8999, 73.8000, 267.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(560, 1055.8000, -298.1000, 73.8000, 267.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(560, 1056.1000, -293.8999, 73.8000, 267.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(560, 1056.3000, -289.1000, 73.8000, 267.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(482, 1056.6000, -313.8999, 74.2000, 268.0, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(482, 1056.2000, -305.7999, 74.2000, 267.9, 3, 0, "Comando Vermelho");
    CriarVeiculoComLabel(487, 1081.6000, -319.1000, 74.3000, 84.0, 3, 0, "Comando Vermelho");

	/* ------------------------- Loja de Armas ------------------------- */
	Create3DTextLabel("Loja de Armas", AZUL_CLARO, 1368.2789,-1279.7478,13.5469, 50.0, 0, 0);
	Create3DTextLabel("Para sair da loja de armas", VERMELHO, 285.3889,-41.1661,1001.5156, 50.0, 0, 0);
	Create3DTextLabel("Loja de Armas\n/armas", branco, 296.5811,-38.0198,1001.5156, 50.0, 0, 0);
	lojadearmas = CreatePickup(1239, 1, 1368.2789,-1279.7478,13.5469, 0);
	sairlojadearmas = CreatePickup(1239, 1, 285.3889,-41.1661,1001.5156, 0);
	CreatePickup(1242, 1, 296.5811,-38.0198,1001.5156, 0);

	
    EnableStuntBonusForAll(0);
    // BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicleEx(481,615.5434,-1500.6102,14.3871,267.6716,1,1, 30); // bmx1
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicleEx(481,615.5955,-1503.5404,14.4060,271.8541,1,1, 30); // bmx2
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicleEx(481,615.6273,-1505.8097,14.4233,270.5425,1,1, 30); // bmx3
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicleEx(481,615.7063,-1508.5774,14.4446,271.1219,1,1, 30); // bmx4
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicleEx(481,615.6801,-1511.4879,14.4665,270.9058,1,1, 30); // bmx5
	// BCG V3: veiculo decorativo removido; use pickup dinamico. AddStaticVehicleEx(481,615.7615,-1514.8342,14.4922,267.3458,1,1, 30); // bmx6
	CreatePickup(1239, 1, 614.1475,-1522.6667,15.1009, 0);
	Create3DTextLabel("/trabalhar", branco, 614.1475,-1522.6667,15.1009, 10.0, 0, 0);
	CreatePickup(1279, 1, 618.7199,-1506.4921,14.9392, 0);
	Create3DTextLabel("/pegarrevistas", branco, 618.7199,-1506.4921,14.9392, 10.0, 0, 0);
	//texto garagem
	Create3DTextLabel("garagem\n digite{F10D0D} /garagem {FFFFFF}Para acessar",0xF10D0DFF, 1235.2106,-1811.1235,13.6025, 100.0, 0);
	//pickups
	Create3DTextLabel("roubo\n digite{F10D0D} /roubarr {FFFFFF}Para roubar ",0xF10D0DFF, 214.538421,-160.595489,1000.523437, 100.0, 0);
    CreatePickup(19305,1,214.538421,-160.595489,1000.523437);
	//
	Create3DTextLabel("/trabalhar", branco, 2199.7515,-1970.3779,13.7841, 10.0, 0, 0);
	CreatePickup(1239, 1, 2199.7515,-1970.3779,13.7841, 0);
    Create3DTextLabel("Para pegar o lixo\n/lixo", branco, 2178.9219,-1976.1296,13.5530, 70.0, 0, 0);
	// taxi
	CreatePickup(1239, 1, 2475.8218,-1957.4399,13.5922, 0);
	Create3DTextLabel("/trabalhar", branco, 2475.8218,-1957.4399,13.5922, 10.0, 0, 0);
	taxis[0] = AddStaticVehicle(420,2479.6758,-1953.4972,13.2037,359.8506,6,6); // taxi1
	taxis[1] = AddStaticVehicle(420,2482.8110,-1953.3949,13.2051,1.5562,6,6); // taxi2
	taxis[2] = AddStaticVehicle(420,2486.0623,-1953.6333,13.2026,0.5740,6,6); // taxi3
	taxis[3] = AddStaticVehicle(420,2489.2395,-1953.5145,13.2027,0.0591,6,6); // taxi4
	taxis[4] = AddStaticVehicle(461,2492.6157,-1953.0364,13.0103,358.6588,6,6); // taxi5
	taxis[5] = AddStaticVehicle(461,2495.5305,-1952.7158,13.0131,3.5824,6,6); // taxi6
	taxis[6] = AddStaticVehicle(461,2498.7869,-1952.6942,13.0133,0.5306,6,6); // taxi7
	taxis[7] = AddStaticVehicle(461,2501.9038,-1952.4563,13.0168,1.2531,6,6); // taxi8
	// cimento
	CreatePickup(1239, 1, 2696.4556,825.9357,10.2964, 0);
	Create3DTextLabel("/trabalhar", branco, 2696.4556,825.9357,10.2964, 10.0, 0, 0);
	Create3DTextLabel("/cimento", branco, 2714.9199,852.9884,10.8984, 50.0, 0, 0);
	AddStaticVehicle(524,2696.7827,854.7099,10.6337,264.8184,1,1); // cement1
	AddStaticVehicle(524,2704.9158,899.8117,11.2670,181.7981,1,1); // cement2
	AddStaticVehicle(524,2705.1294,878.4606,10.8759,178.6932,1,1); // cement3
	AddStaticVehicle(524,2704.4602,863.2928,10.8293,177.1515,1,1); // cement4
	AddStaticVehicle(524,2712.0916,818.8704,11.7693,1.6097,1,1); // cement5
	AddStaticVehicle(524,2711.5254,833.6277,11.6138,2.0557,1,1); // cement6
	
	// agencia
	agencia = CreatePickup(1239, 1, 1154.0011,-1772.6776,16.5992, 0);
	sairagencia = CreatePickup(1239, 1, 1494.3737,1303.8629,1093.2891, 0);
	Create3DTextLabel("Agencia de empregos\nAperte H para entrar", branco, 1154.0011,-1772.6776,16.5992, 50.0, 0, 0);
	Create3DTextLabel("Sair da agencia\nAperte H", branco, 1494.3737,1303.8629,1093.2891, 50.0, 0, 0);

	
	//lac
	lac = CreatePickup(1239, 1, 1047.106689,-1589.145874,13.512354, 0);
	sairlac = CreatePickup(1239, 1,-2240.781250,137.165557,1035.414062, 0);
	Create3DTextLabel("Loja de acessorios\nAperte H para entrar", branco, 1047.106689,-1589.145874,13.512354, 50.0, 0, 0);
	Create3DTextLabel("Sair da lojinha\nAperte H", branco, -2240.781250,137.165557,1035.414062, 50.0, 0, 0);
	CreatePickup(1239, 1, 358.236206, 163.155456, 1008.382812, 0);
	
	// shopping
	shop = CreatePickup(1239, 1, 1115.9543,-1603.2955,20.5622, 0);
	Create3DTextLabel("Loja de Equipamentos\nAperte H para entrar", branco, 1115.9543,-1603.2955,20.5622, 50.0, 0, 0);
	sairshop = CreatePickup(1239, 1, 6.0088,-31.1886,1003.5494, 0);
	Create3DTextLabel("Sair da loja\nAperte H", branco, 6.0088,-31.1886,1003.5494, 50.0, 0, 0);
 	CreatePickup(1239, 1, 2.8274,-29.0144,1003.5494, 0);
	Create3DTextLabel("Loja\nAperte H para abrir", branco, 2.8274,-29.0144,1003.5494, 50.0, 0, 0);
	
	//BASES
	CriarVeiculoComLabel(596, 621.5999, -610.2999, 17.1000, 0.0, 0, 28, "BAEP");
    CriarVeiculoComLabel(596, 624.7999, -610.4000, 17.1000, 0.0, 0, 28, "BAEP");
    CriarVeiculoComLabel(596, 627.9000, -610.2999, 17.1000, 0.0, 0, 28, "BAEP");
    CriarVeiculoComLabel(490, 614.7000, -596.7999, 17.6000, 268.0, 28, 28, "BAEP");
    CriarVeiculoComLabel(490, 631.5000, -610.0000, 16.7000, 357.9, 28, 28, "BAEP");
    CriarVeiculoComLabel(490, 635.2999, -609.7999, 16.7000, 357.9, 28, 28, "BAEP");
    CriarVeiculoComLabel(427, 614.2999, -601.4000, 17.5000, 266.0, 28, 28, "BAEP");
    CriarVeiculoComLabel(523, 617.0000, -584.7999, 16.9000, 210.0, -1, -1, "BAEP");
    CriarVeiculoComLabel(523, 618.7000, -584.7000, 16.9000, 209.9, -1, -1, "BAEP");
    CriarVeiculoComLabel(523, 620.7000, -584.5999, 16.9000, 209.9, -1, -1, "BAEP");
    CriarVeiculoComLabel(523, 622.9000, -584.7000, 16.9000, 209.9, -1, -1, "BAEP");
    CriarVeiculoComLabel(497, 611.9000, -604.7999, 23.0000, 0.0, 60, 60, "BAEP");
	
	//Caminhao
	new h;
	h = AddStaticVehicle(578,2396.2922,-2136.7429,13.7204,270.3165,36,36); // carro 1
	CarDados[h][caminhao]=true;
	h = AddStaticVehicle(578,2395.4697,-2126.6360,13.7205,269.6038,36,36); // carro 2
	CarDados[h][caminhao]=true;
	h = AddStaticVehicle(578,2395.3914,-2116.2729,13.7205,273.4648,36,36); // carro 3
	CarDados[h][caminhao]=true;
	h = AddStaticVehicle(578,2396.1099,-2105.7153,13.7199,268.1076,36,36); // carro 4
	CarDados[h][caminhao]=true;
	h = AddStaticVehicle(578,2394.3794,-2095.5803,13.7269,269.8846,36,36); // carro 5
	CarDados[h][caminhao]=true;
	h = AddStaticVehicle(578,2393.4343,-2085.3501,13.7151,273.7330,36,36); // carro 6
	CarDados[h][caminhao]=true;
	h = AddStaticVehicle(578,2394.2375,-2074.6135,13.6884,269.6600,36,36); // carro 7
	CarDados[h][caminhao]=true;
	
	    //PRF
    CriarVeiculoComLabel(497, -2471.3000, 494.7000, 30.3000, 300.0, 93, 119, "PRF");
    CriarVeiculoComLabel(490, -2413.8994, 535.9003, 30.2000, 257.9, 93, 119, "PRF");
    CriarVeiculoComLabel(490, -2413.2998, 539.7998, 30.2000, 265.9, 93, 119, "PRF");
    CriarVeiculoComLabel(490, -2414.8994, 531.9003, 30.2000, 247.9, 93, 119, "PRF");
    CriarVeiculoComLabel(586, -2442.0000, 494.8999, 29.7000, 0.0, 93, 119, "PRF");
    CriarVeiculoComLabel(586, -2443.6001, 494.2000, 29.7000, 0.0, 93, 119, "PRF");
    CriarVeiculoComLabel(523, -2445.2000, 493.6000, 29.8000, 0.0, 93, 119, "PRF");
    CriarVeiculoComLabel(523, -2446.5000, 493.1000, 29.8000, 0.0, 93, 119, "PRF");
    CriarVeiculoComLabel(523, -2447.7000, 492.2999, 29.8000, 0.0, 93, 119, "PRF");
    CriarVeiculoComLabel(523, -2449.0000, 491.7999, 29.8000, 0.0, 93, 119, "PRF");
    CriarVeiculoComLabel(598, -2465.1016, 504.3924, 29.8246, 180.0, 93, 119, "PRF");
    CriarVeiculoComLabel(598, -2469.7756, 504.5484, 29.8230, 183.3, 93, 119, "PRF");
    CriarVeiculoComLabel(598, -2476.9534, 504.4631, 29.8236, 182.8, 93, 119, "PRF");
    CriarVeiculoComLabel(596, -2428.3439, 515.9383, 29.9296, 230.0, 93, 119, "PRF");
    CriarVeiculoComLabel(596, -2425.3439, 518.9383, 29.9296, 230.0, 93, 119, "PRF");
    CriarVeiculoComLabel(596, -2422.3439, 521.9383, 29.9296, 230.0, 93, 119, "PRF");
    CriarVeiculoComLabel(596, -2419.3439, 524.9383, 29.9296, 240.0, 93, 119, "PRF");
    CriarVeiculoComLabel(596, -2416.3439, 527.9383, 29.9296, 230.0, 93, 119, "PRF");

	    //PF
 	CriarVeiculoComLabel(596, -470.2785, -486.7226, 25.2527, 180.0, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(596, -475.2802, -486.7224, 25.2527, 179.9, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(596, -480.2785, -486.7226, 25.2527, 180.0, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(596, -485.2785, -486.7226, 25.2527, 180.0, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(596, -490.4959, -486.5855, 25.2390, 180.4, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(490, -495.5598, -487.7856, 25.6264, 179.0, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(490, -500.6556, -487.4798, 25.6342, 178.7, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(490, -505.4254, -487.7693, 25.6329, 179.1, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(490, -510.3106, -487.4468, 25.6508, 178.7, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(490, -514.8564, -487.4665, 25.6512, 181.0, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(427, -519.9314, -487.0156, 25.6875, 180.6, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(427, -525.1926, -487.0044, 25.6854, 180.3, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(427, -529.7683, -487.0021, 25.6553, 179.6, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(427, -535.0613, -486.7908, 25.6554, 178.8, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(487, -477.0778, -501.5569, 25.6982, 89.8, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(437, -499.6247, -525.6265, 25.6562, 180.0, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(599, -539.8840, -487.3688, 25.7124, 179.8, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(599, -545.4928, -487.2323, 25.7125, 180.2, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(599, -550.3667, -487.3484, 25.7122, 180.7, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(599, -555.0931, -487.1522, 25.7089, 179.1, 0, 79, "Policia Federal");
    CriarVeiculoComLabel(487, -475.8111, -514.2554, 25.6940, 84.2, 0, 79, "Policia Federal");

    //Motos do emprego entregador de pizza
	// Criamos uma variavel para armazenar o ID do veiculo temporariamente
    new moto_pizza;

    // Loop para criar as 13 motos com um padrao de coordenadas
    // Note que o X aumenta 1.0 a cada repeticao (i)
    for(new i = 0; i < 13; i++)
    {
        // Cria o veiculo e armazena o ID dele
        moto_pizza = CreateVehicle(448, 2099.9189 + (float(i) * 1.0), -1784.6608, 13.3972, 0.0, 3, 6, 50, 0);
        
        // Cria o 3DTextLabel e anexa diretamente a moto criada
        // Parametros: Texto, Cor, X, Y, Z, Distancia de visao, Mundo Virtual, Teste de linha de visao
        new Text3D:label_moto = Create3DTextLabel("Entregador de Pizza", 0x30F72DAA, 0.0, 0.0, 0.0, 15.0, 0, 1);
        Attach3DTextLabelToVehicle(label_moto, moto_pizza, 0.0, 0.0, 0.5); // 0.5 de altura (Z) acima da moto
    }
	//12
	
	for(new i = 0; i < 7; i++) 
    {
        CriarVeiculoComLabel(552, 1764.5476 + (float(i) * 3.0), -1690.3013, 13.4224, 175.0, 3, 0, "Tecnico de Internet");
    }
	//6
	
	//mecanico
	portaomec = CreateObject(980,979.7999900,-1445.4000000,15.3000000,0.0000000,0.0000000,90.0000000); //object(airportgate) (3)
	CriarVeiculoComLabel(525, 1027.8779, -1451.6868, 13.4337, 90.6, 1, 1, "Mecanico");
    CriarVeiculoComLabel(525, 1009.2598, -1434.9994, 13.4236, 180.7, 1, 1, "Mecanico");
    CriarVeiculoComLabel(525, 1021.1293, -1434.7279, 13.4288, 179.5, 1, 1, "Mecanico");
    CriarVeiculoComLabel(525, 996.3287, -1434.5531, 13.4205, 180.5, 1, 1, "Mecanico");
    CriarVeiculoComLabel(525, 996.5627, -1460.1483, 13.4077, 269.8, 1, 1, "Mecanico");
    CriarVeiculoComLabel(525, 1008.5626, -1460.1775, 13.4342, 269.8, 1, 1, "Mecanico");
	CreatePickup(19832,1,1031.7509,-1435.2968,13.5546,0);
	Create3DTextLabel("Para entrar em servico\n/servico",branco,1031.7509,-1435.2968,13.5546,25,0,0);

	
	
	for(new i = 0; i < 5; i++) {
        carrosa[i] = CriarVeiculoComLabel(562, 1099.1318, -1775.4618 + (float(i) * 3.0), 13.0045, 90.9, 1, 1, "Auto Escola");
    }

    // --- Auto Escola (Motos) ---
    for(new i = 0; i < 5; i++) {
        carrosb[i] = CriarVeiculoComLabel(461, 1062.4987, -1775.7500 + (float(i) * 3.0), 12.9251, 270.0, 1, 1, "Auto Escola");
    }

    // --- Auto Escola (Caminhoes) ---
    for(new i = 0; i < 4; i++) {
        carrosc[i] = CriarVeiculoComLabel(498, 1062.3979, -1737.2885 - (float(i) * 6.0), 13.5498, 269.8, 1, 1, "Auto Escola");
    }

    // --- Motorista de onibus ---
    for(new i = 0; i < 5; i++) {
        CarroMoto[i] = CriarVeiculoComLabel(431, 2052.2912 + (float(i) * 4.0), -1908.1545, 13.5468, 0.0, 0, 0, "Motorista");
    }
	
	//Carros do emprego de motorista
	CarroMoto[0]=CreateVehicle(431,2052.291259, -1908.154541, 13.546875,0,0,0,30,0);
	CarroMoto[1]=CreateVehicle(431,2056.291259, -1908.154541, 13.546875,0,0,0,30,0);
	CarroMoto[2]=CreateVehicle(431,2060.291259, -1908.154541, 13.546875,0,0,0,30,0);
	CarroMoto[3]=CreateVehicle(431,2064.291259, -1908.154541, 13.546875,0,0,0,30,0);
	CarroMoto[4]=CreateVehicle(431,2068.291259, -1908.154541, 13.546875,0,0,0,30,0);
	
    CriarVeiculoComLabel(425, 436.4394, 2513.9836, 17.3946, 92.8363, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(425, 448.6600, 2497.8411, 19.8191, 87.8547, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(432, 385.1997, 2543.9971, 16.5480, 179.9558, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(432, 374.7863, 2543.4343, 16.5488, 178.8940, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(432, 364.8551, 2543.6609, 16.5857, 178.4504, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(520, 325.2864, 2537.6025, 17.5309, 177.8913, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(520, 290.0668, 2539.7019, 17.5434, 178.4076, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(553, 407.6955, 2502.4705, 17.2879, 88.9358, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(560, 372.9814, 2471.8103, 16.1893, 0.4037, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(560, 366.2143, 2470.9937, 16.1896, 356.6421, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(560, 359.7268, 2471.0239, 16.1900, 353.3826, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(560, 353.8529, 2470.5659, 16.1897, 354.7925, 1, 1, "Al-Qaeda");
    CriarVeiculoComLabel(560, 347.0593, 2470.8501, 16.1900, 355.2922, 1, 1, "Al-Qaeda");

    // --- Exercito Brasileiro (EB) ---
    CriarVeiculoComLabel(596, -1449.4398, 456.3424, 6.9084, 1.7314, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(596, -1444.3707, 455.8936, 6.9097, 359.7010, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(596, -1438.4384, 455.6489, 6.9023, 358.3578, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(596, -1434.5454, 455.0642, 6.9075, 359.9635, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(487, -1391.8512, 466.5418, 7.3642, 90.0564, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(490, -1470.7776, 479.1321, 7.3164, 90.1835, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(490, -1455.5736, 479.1804, 7.3125, 90.1838, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(490, -1442.7113, 479.2217, 7.3149, 90.1837, 116, 110, "Exercito Brasileiro");
    CriarVeiculoComLabel(490, -1428.6039, 479.2668, 7.3154, 90.1836, 116, 110, "Exercito Brasileiro");

    // --- BOPE ---
    CriarVeiculoComLabel(596, 1910.1348, 697.1172, 10.8203, 0.0, 0, 0, "BOPE");
    CriarVeiculoComLabel(596, 1913.1348, 697.1172, 10.8203, 0.0, 0, 0, "BOPE");
    CriarVeiculoComLabel(596, 1916.1348, 697.1172, 10.8203, 0.0, 0, 0, "BOPE");
    CriarVeiculoComLabel(596, 1919.1348, 697.1172, 10.8203, 0.0, 0, 0, "BOPE");
    CriarVeiculoComLabel(596, 1922.1348, 697.1172, 10.8203, 0.0, 0, 0, "BOPE");
    CriarVeiculoComLabel(523, 1925.9946, 698.3166, 10.3889, 359.6955, 0, 0, "BOPE");
    CriarVeiculoComLabel(523, 1929.1357, 697.3260, 10.3889, 0.2451, 0, 0, "BOPE");
    CriarVeiculoComLabel(523, 1932.6423, 697.6814, 10.3889, 2.8964, 0, 0, "BOPE");
    CriarVeiculoComLabel(523, 1935.2937, 697.7775, 10.3889, 1.0598, 0, 0, "BOPE");
    CriarVeiculoComLabel(523, 1938.8623, 697.9819, 10.3889, 0.5515, 0, 0, "BOPE");
    CriarVeiculoComLabel(523, 1941.8429, 697.4019, 10.3889, 359.6195, 0, 0, "BOPE");
    CriarVeiculoComLabel(490, 1916.4883, 709.7350, 10.9491, 179.8131, 0, 0, "BOPE");
    CriarVeiculoComLabel(490, 1919.6085, 709.7545, 10.9492, 180.7482, 0, 0, "BOPE");
    CriarVeiculoComLabel(490, 1922.8790, 709.5306, 10.9495, 180.1487, 0, 0, "BOPE");
    CriarVeiculoComLabel(601, 1925.9707, 708.9346, 10.5791, 179.4282, 0, 0, "BOPE");
    CriarVeiculoComLabel(427, 1929.2715, 709.6861, 10.9523, 179.6129, 0, 0, "BOPE");
    CriarVeiculoComLabel(427, 1932.7301, 709.4555, 10.9537, 180.1887, 0, 0, "BOPE");
    CriarVeiculoComLabel(487, 1945.8521, 680.3434, 11.0104, 180.3834, 0, 0, "BOPE");
    CriarVeiculoComLabel(487, 1910.1617, 729.3992, 11.0090, 181.0529, 0, 0, "BOPE");
    CriarVeiculoComLabel(490, 1909.8303, 709.1203, 10.9494, 181.3547, 0, 0, "BOPE");
    CriarVeiculoComLabel(490, 1913.2107, 709.3259, 10.9486, 180.0838, 0, 0, "BOPE");

    // --- Forca Tatica (FT) ---
    CriarVeiculoComLabel(596, 939.3942, -1051.2091, 31.3249, 359.7843, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(596, 933.4279, -1051.2766, 31.3230, 0.4544, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(596, 927.4305, -1051.2900, 31.3227, 0.0446, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(490, 921.3157, -1051.4342, 31.7287, 359.7838, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(490, 897.5004, -1051.3698, 31.7295, 0.0108, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(523, 903.3897, -1037.9720, 31.4670, 180.6835, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(523, 900.2579, -1037.6970, 31.4670, 179.9864, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(523, 897.3046, -1037.3682, 31.4739, 179.9751, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(427, 881.8818, -1049.9004, 31.7348, 359.3475, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(490, 889.9852, -1051.5077, 31.7373, 359.8850, 0, 3, "Forca Tatica");
    CriarVeiculoComLabel(487, 908.4555, -1048.4651, 31.3346, 359.6140, 0, 3, "Forca Tatica");

    // --- ROTA ---
    CriarVeiculoComLabel(490, -1612.4000, 733.7000, -5.0000, 0.0, -1, 9, "ROTA");
    CriarVeiculoComLabel(490, -1616.6000, 734.0000, -5.0000, 0.0, -1, 9, "ROTA");
    CriarVeiculoComLabel(597, -1612.6000, 748.2999, -5.4000, 180.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(597, -1608.4000, 748.2999, -5.4000, 180.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(597, -1604.5000, 748.2999, -5.4000, 180.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(597, -1600.6000, 748.2999, -5.4000, 180.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(597, -1596.4000, 748.2999, -5.4000, 180.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(597, -1592.0000, 748.2999, -5.4000, 180.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(497, -1680.1000, 705.7000, 30.9000, 88.0, 26, 9, "ROTA");
    CriarVeiculoComLabel(523, -1603.2000, 733.2000, -5.6000, 0.0, -1, 9, "ROTA");
    CriarVeiculoComLabel(523, -1605.2000, 733.0999, -5.6000, 0.0, -1, 9, "ROTA");
    CriarVeiculoComLabel(523, -1606.9000, 733.0000, -5.6000, 0.0, -1, 9, "ROTA");
    CriarVeiculoComLabel(523, -1608.9000, 732.9000, -5.6000, 0.0, -1, 9, "ROTA");
    CriarVeiculoComLabel(490, -1574.8000, 742.7000, -4.7000, 88.5, -1, 9, "ROTA");
    CriarVeiculoComLabel(490, -1575.0000, 738.7000, -4.7000, 88.4, -1, 9, "ROTA");

    // --- Policia Militar (PM) ---
    CriarVeiculoComLabel(596, 2808.0532, 941.1863, 10.4704, 179.6, 0, 1, "Policia Militar");
    CriarVeiculoComLabel(596, 2814.5537, 940.8615, 10.4713, 177.8, 0, 1, "Policia Militar");
    CriarVeiculoComLabel(596, 2820.8557, 940.8132, 10.4688, 180.2, 0, 1, "Policia Militar");
    CriarVeiculoComLabel(596, 2827.3188, 939.8385, 10.4705, 180.9, 0, 1, "Policia Militar");
    CriarVeiculoComLabel(596, 2833.4836, 940.0983, 10.4981, 179.9, 0, 1, "Policia Militar");
    CriarVeiculoComLabel(490, 2833.7031, 927.9530, 10.8786, 180.2, 0, 0, "Policia Militar");
    CriarVeiculoComLabel(490, 2827.0950, 927.1176, 10.8776, 178.9, 0, 0, "Policia Militar");
    CriarVeiculoComLabel(490, 2820.7395, 927.6260, 10.8781, 182.7, 0, 0, "Policia Militar");
    CriarVeiculoComLabel(523, 2804.8066, 927.8045, 10.3185, 211.9, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(523, 2808.0205, 927.0312, 10.3185, 211.6, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(523, 2811.5691, 926.8783, 10.3185, 212.9, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(523, 2814.7488, 927.2512, 10.3185, 210.1, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(523, 2817.6213, 927.4803, 10.3185, 212.8, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(487, 2869.8611, 900.4794, 10.9267, 4.1, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(431, 2855.4072, 898.2943, 10.4426, 359.7, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(427, 2818.0942, 899.2778, 10.5491, 0.7, 1, 1, "Policia Militar");
    CriarVeiculoComLabel(427, 2827.4768, 899.4008, 10.5570, 359.6, 1, 1, "Policia Militar");

    // --- Policia Civil (PC) ---
    CriarVeiculoComLabel(487, 1568.6031, -1658.6924, 28.5843, 90.6, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(596, 1574.5183, -1614.1127, 13.1040, 178.5, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(596, 1563.7714, -1614.2286, 13.1042, 180.4, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(490, 1558.7838, -1613.0356, 13.5113, 178.2, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(490, 1554.0204, -1613.2289, 13.5112, 180.6, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(523, 1605.5797, -1629.5166, 13.0940, 90.5, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(523, 1605.3712, -1627.3871, 13.0917, 92.6, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(523, 1605.2502, -1625.3821, 13.0904, 89.5, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(523, 1605.3279, -1623.1903, 13.0913, 91.2, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(596, 1568.6091, -1614.2167, 13.1041, 178.2, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(437, 1588.0389, -1610.3430, 13.5156, 178.3, 1, 0, "Policia Civil");
    CriarVeiculoComLabel(560, 1601.7244, -1606.6426, 13.6415, 87.7, 0, 0, "Policia Civil");
    CriarVeiculoComLabel(482, 1602.2765, -1613.9365, 13.2488, 90.6, 0, 0, "Policia Civil");

    // --- ROTAM ---
    CriarVeiculoComLabel(596, -2535.5759, -603.4252, 132.2832, 181.0, 0, 6, "ROTAM");
    CriarVeiculoComLabel(596, -2531.9092, -603.4354, 132.2838, 179.2, 0, 6, "ROTAM");
    CriarVeiculoComLabel(596, -2528.3674, -603.4453, 132.2830, 179.2, 0, 6, "ROTAM");
    CriarVeiculoComLabel(598, -2524.4583, -603.3939, 132.3080, 179.5, 0, 6, "ROTAM");
    CriarVeiculoComLabel(598, -2520.7402, -603.3846, 132.3080, 179.0, 0, 6, "ROTAM");
    CriarVeiculoComLabel(598, -2517.0583, -603.4985, 132.3089, 180.4, 0, 6, "ROTAM");
    CriarVeiculoComLabel(490, -2513.1597, -602.6406, 132.6900, 179.7, 0, 6, "ROTAM");
    CriarVeiculoComLabel(490, -2509.5613, -602.7292, 132.6904, 179.7, 0, 6, "ROTAM");
    CriarVeiculoComLabel(490, -2505.6013, -602.6622, 132.6908, 178.4, 0, 6, "ROTAM");
    CriarVeiculoComLabel(528, -2502.0071, -603.3224, 132.6065, 179.0, 0, 6, "ROTAM");
    CriarVeiculoComLabel(528, -2498.2148, -603.2806, 132.6063, 179.2, 0, 6, "ROTAM");
    CriarVeiculoComLabel(528, -2494.6230, -603.2070, 132.6071, 178.7, 0, 6, "ROTAM");
    CriarVeiculoComLabel(487, -2530.9077, -614.0092, 132.7392, 267.6, 0, 6, "ROTAM");
    CriarVeiculoComLabel(427, -2503.4939, -619.1563, 132.6944, 269.4, 0, 6, "ROTAM");

    // --- Guarda Municipal ---
    CriarVeiculoComLabel(596, 278.7929, -1536.0048, 24.5937, 60.0, 0, 1, "Guarda Municipal");
    CriarVeiculoComLabel(596, 281.7929, -1533.0048, 24.5937, 60.0, 0, 1, "Guarda Municipal");
    CriarVeiculoComLabel(596, 284.7929, -1530.0048, 24.5937, 60.0, 0, 1, "Guarda Municipal");
    CriarVeiculoComLabel(596, 287.7929, -1527.0048, 24.5937, 60.0, 0, 1, "Guarda Municipal");
    CriarVeiculoComLabel(596, 290.7929, -1524.0048, 24.5937, 60.0, 0, 1, "Guarda Municipal");

    // --- Governo ---
    CriarVeiculoComLabel(560, 1244.5841, -2031.9350, 59.8672, 270.0, 0, 1, "Governo");
    CriarVeiculoComLabel(560, 1244.5841, -2028.9350, 59.8672, 270.0, 0, 1, "Governo");
    CriarVeiculoComLabel(560, 1244.5841, -2025.9350, 59.8672, 270.0, 0, 1, "Governo");
    CriarVeiculoComLabel(560, 1244.5841, -2022.9350, 59.8672, 270.0, 0, 1, "Governo");
    CriarVeiculoComLabel(560, 1244.5841, -2019.9350, 59.8672, 270.0, 0, 1, "Governo");

    // --- Mafias e Faccoes ---
    CriarVeiculoComLabel(560, 686.6394, -1305.9212, 13.6091, 90.0, 106, 106, "Cosa Nostra");
    CriarVeiculoComLabel(560, 2789.8811, -2027.0300, 13.5619, 0.0, 106, 106, "Yakuza");
    CriarVeiculoComLabel(560, 2631.8798, 1697.5458, 10.8203, 100.0, 0, 0, "Hitmans");
    CriarVeiculoComLabel(560, 1460.4224, 2840.9428, 10.8203, 0.0, 0, 0, "Triads");
    CriarVeiculoComLabel(560, 1512.6232, -1461.6395, 9.5000, 270.0, 74, 74, "Facao Mineira");
    CriarVeiculoComLabel(560, -345.9775, 1515.9772, 75.3593, 0.0, 6, 6, "PCC");
    CriarVeiculoComLabel(560, 1776.2371, -1932.5820, 13.3865, 270.0, 44, 44, "TCP");
    CriarVeiculoComLabel(560, 2190.7829, -2277.7656, 13.5468, 0.0, 128, 128, "FDN");

    // --- Motoclube ---
    CriarVeiculoComLabel(560, 901.4717, -1206.2462, 16.6865, 181.8, 134, 134, "Motoclube");
    CriarVeiculoComLabel(463, 863.5236, -1245.4198, 14.3976, 271.9, 134, 134, "Motoclube");

    // --- B40 ---
    CriarVeiculoComLabel(560, 1088.2711, -1249.1988, 15.8271, 0.0, 150, 150, "B40");

    // --- Milicia ---
    CriarVeiculoComLabel(560, 1653.7037, 710.4852, 10.8203, 0.0, 229, 229, "Milicia");

    // --- ADA ---
    CriarVeiculoComLabel(487, 2818.5388, -1167.9370, 32.8456, 271.9, 128, 128, "ADA");
    CriarVeiculoComLabel(560, 2813.7576, -1179.0763, 24.9839, 271.7, 128, 128, "ADA");
	Create3DTextLabel("Use /subir",AMARELO,2804.7417,-1178.5381,25.4753,15,0, 0);//elevador
	Create3DTextLabel("Use /descer",AMARELO,2804.7434,-1175.1790,32.6688,15,0, 0);//elevador

	
	
	ShowPlayerMarkers(true);
	SetGameModeText(" IW ");
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	ShowPlayerMarkers ( PLAYER_MARKERS_MODE_OFF ) ;
	ShowNameTags(0);
	LimitPlayerMarkerRadius(100.0);
	VerificarPasta("Contas");
	VerificarPasta("Banidos");
	VerificarPasta("BanidosIp");
	VerificarPasta("Conse");
	VerificarPasta("Ficha");
	VerificarPasta("Presos");
	Passagem = 2;

	//Pickups
	
	CreatePickup(1239,1,2096.701660, -1815.467773, 12.945860,0);//cifrao do emprego de pizzaboy
	CreatePickup(1239,1,361.867340, 173.422683, 1008.382812,0);//maleta da prefeitura
	CreatePickup(1239,1,1072.307495, -1221.322021, 16.890625,0);
	CreatePickup(1239,1,389.997436, 173.702362, 1008.382812,0);
	CreatePickup(1239,1,204.239273, -168.549575, 1000.523437,0);
	CreatePickup(1239,1,1770.073608, -1657.932861, 14.419504,0);//maleta do emprego de tecnico
	CreatePickup(1239,1,1757.902587, -1673.121093, 13.554224,0);//cifrao do emprego de tecnico
	CreatePickup(1239,1,204.085601, -160.178436, 1000.523437,0);//blusa da loja de roupa
	CreatePickup(1239,1,2311.636962, -3.778552, 26.742187,0);//cifrao do banco
	CreatePickup(1239,1,544.047790, -1289.246826, 16.944744,0);
	CreatePickup(1239,1,2315.836425, -0.546637, 26.742187,0);//saida do banco
	CreatePickup(1239,1,941.086730, -1719.847900, 13.969263,0);//entrada do banco
	CreatePickup(1239,1, 2422.1182, -2077.6636, 13.5538,0);//maleta do emprego de caminhao
	CreatePickup(1239,1,2413.8560, -2070.9868, 13.387,0);//cifrao do emprego de Caminhao
	CreatePickup(1239,1,2046.201416, -1907.760498, 13.546875,0);//maleta do emprego de motorista
	CreatePickup(1239,1,2132.0010,-1149.9999,24.207,0);//conseissionaria
	CreatePickup(1239,1,1235.372558,-1811.243286,13.602552,0);//Garagem

		
	//3D Text
	Create3DTextLabel("Use /roupa",AMARELO,204.085601, -160.178436, 1000.523437,15,0,0);
	Create3DTextLabel("Para efeturar prisao\n/prender",AMARELO,1536.2542,-1673.6940,13.3828, 50,0,0);
	CreatePickup(1247,1,1536.2542,-1673.6940,13.3828,0);//Garagem
	Create3DTextLabel("Use /banco",AMARELO,2311.636962, -3.778552, 26.742187,15,0,0);
	Create3DTextLabel("Use /entregas",AMARELO,2413.8560,-2070.9868,13.3878,15,0,0);
	Create3DTextLabel("Use /internet",AMARELO, 1757.952270, -1672.862548, 13.554297,15,0,0);
	Create3DTextLabel("Use /trabalhar",AMARELO,1770.073608, -1657.932861, 14.419504,15,0,0);
	Create3DTextLabel("Use /trabalhar",AMARELO, 2422.1182, -2077.6636, 13.5538,15,0,0);
	Create3DTextLabel("use /vendercarro",AMARELO,544.047790, -1289.246826, 16.944744,15,0,0);
	Create3DTextLabel("Use /trabalhar",AMARELO,2046.201416, -1907.760498, 13.546875,15,0,0);
	Create3DTextLabel("Use /garagem",AMARELO,1536.2542,-1673.6940,13.3828,15,0,0);//garagem
	SetTimer("MsgAuto",300000,true);
	SetTimer("PayDay", 1000000, true);
	SetTimer("tang",1000,false);
	SetTimer("trespawn",3600000,true);
	new Float:x,Float:y,Float:z;
	for(new v=0;v<MAX_VEHICLES;v++){
		if(GetVehiclePos(v,x,y,z))existe++;
	}

	// Casas pre-cadastradas espalhadas pelo mapa
	BCG_CarregarCasasSalvas();
	BCG_CriarCasasMapa();
	return 1;
}
public PayDay()
{
    new string[128], path[64], textosalario[64], salario;

    for(new i = 0; i < MAX_PLAYERS; ++i)
    {
        if(IsPlayerConnected(i) && Pdados[i][Logado] == true)
        {
            // --- VERIFICACaO ANTI-FARM (ADICIONADO) ---
            if(Pdados[i][AntiFarmAtivado] == true)
            {
                SendClientMessage(i, VERMELHO, "BCG: Voce nao recebeu seu PayDay porque esta em modo Anti-Farm (Ausente).");
                continue; // Pula este jogador e vai para o proximo
            }

            // --- 1. LOGICA DE HORAS E NOVATO ---
            Pdados[i][SegundosJogados]++;
            format(path, sizeof(path), "Contas/%s.txt", Nome(i));
            DOF2_SetInt(path, "SegundosJogados", Pdados[i][SegundosJogados]);
            DOF2_WriteFile();

            if(Pdados[i][SegundosJogados] >= 36000) 
            {
                SendClientMessage(i, VERDE, "Parabens! Voce completou 10 horas, deixou de ser novato e ganhou total liberdade!");
            }

            // --- 2. DEFINIcaO DO VALOR DO SALaRIO ---
            if(Pdados[i][Vip] == 1) // Se for VIP
            {
                salario = 5000;
                format(textosalario, sizeof(textosalario), "Membro VIP");
            }
            else if(Pdados[i][OrgID] > 0) // Se for de Org (e nao for VIP)
            {
                salario = 3000;
                format(textosalario, sizeof(textosalario), NomeOrg(i));
            }
            else // Trabalhador comum
            {
                salario = 1000;
                format(textosalario, sizeof(textosalario), Emprego(i));
            }

            // --- 3. ENTREGA DO DINHEIRO E MENSAGEM ---
            new saldo_anterior = Pdados[i][Banco];
            Pdados[i][Banco] += salario;

            SendClientMessage(i, VERDE, "================ PAYDAY ================");
            format(string, sizeof(string), "Voce recebeu seu salario de: %s", textosalario);
            SendClientMessage(i, branco, string);
            
            format(string, sizeof(string), "Saldo antigo: $%d | Saldo atual: $%d", saldo_anterior, Pdados[i][Banco]);
            SendClientMessage(i, branco, string);
            
            format(string, sizeof(string), "Bonus: $%d", salario);
            SendClientMessage(i, VERDE, string);
            SendClientMessage(i, VERDE, "================ PAYDAY ================");
        }
    }
    return 1;
}


public MsgAuto(){
	new c,m; c = random(sizeof(Cores));m = random(sizeof(Mensagens));
	for(new i = 0;i<MAX_PLAYERS;i++){
		SendClientMessage(i,Cores[c][0],Mensagens[m][0]);
	}
	return 1;
}
public carregando(playerid){
	if(carregou[playerid] == 1){
	carregou[playerid] = 0;
	TogglePlayerControllable(playerid, 1);
	}
	return 1;
}
public consertarcarro(playerid){
	if(conserto[playerid] == 1){
    new Float:health, engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleHealth(GetPlayerVehicleID(playerid), health);
	TogglePlayerControllable(playerid, 1);
	GameTextForPlayer(playerid, "~y~consertado", 3000, 4);
	SendClientMessage(playerid, AMARELO, "Seu veiculo foi consertado.");
	conserto[playerid] = 0;
	RepairVehicle(GetPlayerVehicleID(playerid));
	GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
 	SetVehicleParamsEx(GetPlayerVehicleID(playerid), true, lights, alarm, doors, bonnet, boot, objective);
 	}else{
 	}
	return 1;
}
public TempoVip(playerid)
{
    if(tvip[playerid] == 1)
    {
        tvip[playerid] = 0;
        SendClientMessage(playerid, -1, "{00BFFF}[BCG ANUNCIO] {FFFFFF}Voce ja pode anunciar novamente.");
    }

    if(equipado[playerid] == 1)
    {
        equipado[playerid] = 0;
        SendClientMessage(playerid, -1, "{00BFFF}[BCG CORPS] {FFFFFF}Voce ja pode se equipar novamente.");
    }

    if(equipado2[playerid] == 1)
    {
        equipado2[playerid] = 0;
        SendClientMessage(playerid, -1, "{00BFFF}[BCG CORPS] {FFFFFF}Voce ja pode se equipar novamente.");
    }
    return 1;
}

public equiparn(playerid)
{
    if(equipado2[playerid] == 1)
    {
        equipado2[playerid] = 0;
        SendClientMessage(playerid, -1, "{00BFFF}[BCG CORPS] {FFFFFF}Voce ja pode se equipar novamente.");
    }
    return 1;
}

public trespawn(){
	SendClientMessageToAll(VERMELHO,"Em trinta segundos tera um respawn automatico");
	SetTimer("ttrespawn",30000,false);
	new r = random(21);
	SetWeather(r);
	return 1;
}
public ttrespawn(){
    SendClientMessageToAll(VERMELHO, "Todos os carros criados foram destruidos!");
 	new a;
	for(new c = 0; c < MAX_VEHICLES; c++)
    {   for(new i = 0;i<MAX_PLAYERS;i++){
			if(IsPlayerInVehicle(i,c)){
				a++;
			}
		}
		if(a == 0){
			if(c <= existe){
				SetVehicleToRespawn(c);
			}else{DestroyVehicle(c);}
		}
	   	a = 0;
	}
	return 1;
}
public VerificarPasta(pasta[])
{
	format(String, sizeof(String), "%s/verificacao",pasta);
	DOF2_CreateFile(String);
	print("Verificando pastas....");
	if(DOF2_FileExists(String))
	{
	    printf("Pasta '%s' Encontrada e carregada com sucesso.", pasta);
	}
	else if(!DOF2_FileExists(String))
	{
	    printf("Pasta '%s' Nao encontrada. Crie ela e adicione.", pasta);
	}
	DOF2_RemoveFile(String);
	return 1;
}

public OnGameModeExit()
{
    CG54Unload();
    for(new cg54Player=0;cg54Player<MAX_PLAYERS;cg54Player++) CG54Reset(cg54Player);
    KillTimer(CG52VoiceTimer);for(new cg52=0;cg52<MAX_PLAYERS;cg52++)if(CG52Voice[cg52])SvDeleteStream(CG52Voice[cg52]);
    if(BCG38DB) db_close(BCG38DB);
    if(BCG36Timer) KillTimer(BCG36Timer);   
    for(new i = 0; i < MAX_POSTOS; i++)
    {
        if(PostoInfo[i][pCriado])
        {
            SalvarPosto(i);
            DestroyPickup(PostoInfo[i][pPickup]);
            Delete3DTextLabel(PostoInfo[i][pLabel]);
        }
    }


    ExitFabricarArmasDB();
    ExitRotaGangstersDB();
    ExitDesmancheFiveMDB();
    ExitMorteFiveM();
    db_close(g_DB_Caixas);

    DOF2_Exit();
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(Pdados[playerid][Admin]>0)
    {
        SetPVarFloat(playerid, "TeleX", fX);
        SetPVarFloat(playerid, "TeleY", fY);
        SetPVarFloat(playerid, "TeleZ", fZ);
        ShowPlayerDialog(playerid, TELEMAP, DIALOG_STYLE_MSGBOX, "Teleporte ADM", "Voce deseja teleportar no local em que voce marcou no mapa?", "SIM", "NAO");
    }
    return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, 1685.4423, -2332.4685, 13.5469);
    SetPlayerCameraPos(playerid, 1712.0, -2295.0, 31.0);
    SetPlayerCameraLookAt(playerid, 1685.4423, -2332.4685, 13.5469);
    return 1;
}


stock MostrarBanimentoBCG(playerid, arquivo[])
{
    new admin[MAX_PLAYER_NAME], motivo[256], ipban[25], tempoTxt[64], dataTxt[64], msg[700];
    new expira = DOF2_GetInt(arquivo, "Expira");

    if(expira > 0 && gettime() >= expira)
    {
        fremove(arquivo);
        return 0;
    }

    format(admin, sizeof(admin), "%s", DOF2_GetString(arquivo, "ADM"));
    format(motivo, sizeof(motivo), "%s", DOF2_GetString(arquivo, "Motivo"));
    format(ipban, sizeof(ipban), "%s", DOF2_GetString(arquivo, "IP"));
    format(dataTxt, sizeof(dataTxt), "%s", DOF2_GetString(arquivo, "Data"));

    if(expira <= 0) format(tempoTxt, sizeof(tempoTxt), "Permanente");
    else
    {
        new restante = expira - gettime();
        new dias = restante / 86400;
        new horas = (restante % 86400) / 3600;
        new minutos = (restante % 3600) / 60;
        if(dias > 0) format(tempoTxt, sizeof(tempoTxt), "%d dia(s), %d hora(s)", dias, horas);
        else if(horas > 0) format(tempoTxt, sizeof(tempoTxt), "%d hora(s), %d minuto(s)", horas, minutos);
        else format(tempoTxt, sizeof(tempoTxt), "%d minuto(s)", minutos);
    }

    format(msg, sizeof(msg),
        "{FFFFFF}Voce esta banido deste servidor!\n\n\
{FFFFFF}Jogador: {FF4444}%s\n\
{FFFFFF}IP: {FF4444}%s\n\
{FFFFFF}Admin: {FF4444}%s\n\
{FFFFFF}Motivo: {FF4444}%s\n\
{FFFFFF}Data: {FF4444}%s\n\
{FFFFFF}Tempo: {FF4444}%s",
        Nome(playerid), ipban, admin, motivo, dataTxt, tempoTxt);

    ShowPlayerDialog(playerid, DIALOG_BANIDO, DIALOG_STYLE_MSGBOX,
        "{FF3333}Brasil Cidade Grande - Banimento", msg, "Sair", "");
    return 1;
}

stock SalvarBanBCG(id, adminid, motivo[], minutos)
{
    new arqConta[96], arqIp[96], ip[25], dataTxt[64], ano, mes, dia, hora, minuto, segundo;
    new expira = 0;
    GetPlayerIp(id, ip, sizeof(ip));
    getdate(ano, mes, dia);
    gettime(hora, minuto, segundo);
    format(dataTxt, sizeof(dataTxt), "%02d/%02d/%04d as %02d:%02d", dia, mes, ano, hora, minuto);
    if(minutos > 0) expira = gettime() + (minutos * 60);

    format(arqConta, sizeof(arqConta), "Banidos/%s.txt", Nome(id));
    if(!DOF2_FileExists(arqConta)) DOF2_CreateFile(arqConta);
    DOF2_SetString(arqConta, "Nome", Nome(id));
    DOF2_SetString(arqConta, "IP", ip);
    DOF2_SetString(arqConta, "ADM", Nome(adminid));
    DOF2_SetString(arqConta, "Motivo", motivo);
    DOF2_SetString(arqConta, "Data", dataTxt);
    DOF2_SetInt(arqConta, "Expira", expira);
    DOF2_SaveFile();

    format(arqIp, sizeof(arqIp), "BanidosIp/%s.txt", ip);
    if(!DOF2_FileExists(arqIp)) DOF2_CreateFile(arqIp);
    DOF2_SetString(arqIp, "Nome", Nome(id));
    DOF2_SetString(arqIp, "IP", ip);
    DOF2_SetString(arqIp, "ADM", Nome(adminid));
    DOF2_SetString(arqIp, "Motivo", motivo);
    DOF2_SetString(arqIp, "Data", dataTxt);
    DOF2_SetInt(arqIp, "Expira", expira);
    DOF2_SaveFile();
    return 1;
}

public OnPlayerConnect(playerid)
{
    CG52Begin(playerid);
    BCG47ReleaseVehicle(playerid);
    BCG47Reset(playerid);
    BCG38Reset(playerid);
    BCG36Client[playerid] = false;
    BCG36Authenticated[playerid] = false;
    BCG36LastHud[playerid][0] = EOS;
    BCG36Attempts[playerid] = 0;
    BCG36SMSName[playerid][0] = EOS;
    BCG36LastAction[playerid] = 0;
    g_LojaGTAInicializada[playerid] = false;
    g_LojaGTAAtual[playerid] = -1;
    g_LanchoneteAtiva[playerid] = false;
    g_LanchoneteAtual[playerid] = -1;
    g_PlayerCrack[playerid] = false;
    g_LoadingAtivo[playerid] = false;
    msgs[playerid] = 0;
    Pdados[playerid][Logado] = false;
    Pdados[playerid][pLogged] = 0;
    logado[playerid] = false;
    BCG_VoipLigado[playerid] = false;
    BCG_TagCabeca[playerid] = Create3DTextLabel("{00FF32}ID: ...", -1, 0.0, 0.0, 0.0, 20.0, 0, 1);
    Attach3DTextLabelToPlayer(BCG_TagCabeca[playerid], playerid, 0.0, 0.0, 0.35);

    BCG_IDFixo[playerid] = 0;
    BCGCelularLigacao[playerid] = INVALID_PLAYER_ID;
    BCGCelularSMSDestino[playerid] = INVALID_PLAYER_ID;

    // ==========================================
    // 1. INICIALIZAÇÃO DE VARIÁVEIS E DADOS
    // ==========================================
    MostrarLoadingScreen(playerid); // Exibe a tela de carregamento inicial
    
    VeiculoPlayer[playerid]     = -1;
    OrigemEntrada[playerid]     = 0;
    PrimeiroSpawn[playerid]     = true;
    SenhaCelular[playerid][0]   = '\0';
    SenhaInput[playerid][0]     = '\0';
    CelularBloqueado[playerid]  = false;
    CelularAberto[playerid]     = false;
    CelularTela[playerid]       = 0;
    PlayerSpeedo[playerid]      = 0;
    BCG_AnuncioComprado[playerid] = false;
    lastVehicle[playerid]       = 0;
    Gari[playerid]              = 0; 
    carroforte[playerid]        = 0;
    CarroDono[playerid]         = -1;
    lixo[playerid]              = 0;
    Pizzas[playerid]            = 0;
    GanhaGorjeta[playerid]      = 0;
    Celular_CriarTextDraws(playerid);
    // Inicializa o celular visual antes de qualquer abertura.
    CriarCelularBase(playerid);
    CriarTelaHome(playerid);
    CriarTelaWhatsApp(playerid);
    CriarTelaConfiguracoes(playerid);
    CriarTelaBloqueio(playerid);
    CriarTelaInstagram(playerid);
    
    Pdados[playerid][Algemado]          = false;
    Pdados[playerid][Assistindo]        = false;
    Pdados[playerid][Farda]             = true;
    Pdados[playerid][Arrastado]         = 0;
    Pdados[playerid][UltimaPos_X]       = 0.0;
    Pdados[playerid][UltimaPos_Y]       = 0.0;
    Pdados[playerid][UltimaPos_Z]       = 0.0;
    Pdados[playerid][TempoParado]       = 0;
    Pdados[playerid][AntiFarmAtivado]   = false;
    Pdados[playerid][pDonoPostoID]      = -1;

    CarregarInstagram(playerid);
    VerificarComaAoEntrar(playerid);
    PreloadAnims(playerid);
    
    // ==========================================
    // 2. CARREGAMENTO DE ARQUIVOS E CONTAS
    // ==========================================
    new nomeJogador[MAX_PLAYER_NAME], diretorio[64];
    GetPlayerName(playerid, nomeJogador, sizeof(nomeJogador));
    // Verificacao de banimento por conta e por IP.
    format(StringContas, sizeof(StringContas), "Banidos/%s.txt", nomeJogador);
    if(DOF2_FileExists(StringContas))
    {
        if(MostrarBanimentoBCG(playerid, StringContas)) return 1;
    }

    new ip[25];
    GetPlayerIp(playerid, ip, sizeof(ip));
    format(StringContas, sizeof(StringContas), "BanidosIp/%s.txt", ip);
    if(DOF2_FileExists(StringContas))
    {
        if(MostrarBanimentoBCG(playerid, StringContas)) return 1;
    }

    // Agendamento de Coins - recuperacao segura e com expiracao
    format(diretorio, sizeof(diretorio), "CoinsAgendados/%s.txt", nomeJogador);
    PlayerAgendamento[playerid][agAtivo] = false;
    PlayerAgendamento[playerid][agParaID] = playerid;
    PlayerAgendamento[playerid][agQuantidade] = 0;
    PlayerAgendamento[playerid][agCodigo][0] = EOS;
    PlayerAgendamento[playerid][agPedido] = 0;
    PlayerAgendamento[playerid][agCriadoEm] = 0;
    PlayerAgendamento[playerid][agExpiraEm] = 0;
    PlayerAgendamento[playerid][agTentativas] = 0;
    PlayerAgendamento[playerid][agStatus] = 0;
    PlayerAgendamento[playerid][agCriadoPor][0] = EOS;

    if(DOF2_FileExists(diretorio))
    {
        new qtdCoins = DOF2_GetInt(diretorio, "Quantidade");
        new statusCoins = DOF2_GetInt(diretorio, "Status");
        new expiraCoins = DOF2_GetInt(diretorio, "ExpiraEm");

        if(statusCoins == 1 && qtdCoins > 0 && qtdCoins <= BCG_COINS_MAX_QUANTIDADE && expiraCoins > gettime())
        {
            PlayerAgendamento[playerid][agAtivo] = true;
            PlayerAgendamento[playerid][agQuantidade] = qtdCoins;
            PlayerAgendamento[playerid][agPedido] = DOF2_GetInt(diretorio, "Pedido");
            PlayerAgendamento[playerid][agCriadoEm] = DOF2_GetInt(diretorio, "CriadoEm");
            PlayerAgendamento[playerid][agExpiraEm] = expiraCoins;
            PlayerAgendamento[playerid][agTentativas] = DOF2_GetInt(diretorio, "Tentativas");
            PlayerAgendamento[playerid][agStatus] = statusCoins;
            DOF2_GetString(diretorio, "Codigo", PlayerAgendamento[playerid][agCodigo]);
            DOF2_GetString(diretorio, "CriadoPor", PlayerAgendamento[playerid][agCriadoPor]);
            BCG_CoinsUltimoPedido[playerid] = PlayerAgendamento[playerid][agPedido];
        }
        else if(statusCoins == 1)
        {
            DOF2_RemoveFile(diretorio);
        }
    }

    pOnline++;
    DisablePlayerCheckpoint(playerid);
    DisablePlayerRaceCheckpoint(playerid);

    // ==========================================
    // 3. REMOÇÃO DE OBJETOS DO MAPA (OTIMIZADO)
    // ==========================================
    RemoveBuildingForPlayer(playerid, 16774, 800.328, 1672.130, 5.875, 0.250);
    RemoveBuildingForPlayer(playerid, 3337, 791.593, 1816.079, 3.242, 0.250);
    RemoveBuildingForPlayer(playerid, 3337, 828.8750, 1767.8906, 2.6797, 0.25);
    RemoveBuildingForPlayer(playerid, 3337, -127.866, 487.695, 9.218, 0.250);
    RemoveBuildingForPlayer(playerid, 1520, 503.273, -22.789, 1000.710, 0.250);
    RemoveBuildingForPlayer(playerid, 11011, -2144.350, -132.960, 38.335, 0.250);
    RemoveBuildingForPlayer(playerid, 11376, -2144.350, -132.960, 38.335, 0.250);
    RemoveBuildingForPlayer(playerid, 1497, -2029.020, -120.063, 34.257, 0.250);     
    RemoveBuildingForPlayer(playerid, 11015, -2028.130, -111.273, 36.132, 0.250);
    RemoveBuildingForPlayer(playerid, 11371, -2028.130, -111.273, 36.132, 0.250);
    RemoveBuildingForPlayer(playerid, 1532, -2025.829, -102.469, 34.273, 0.250);
    RemoveBuildingForPlayer(playerid, 11010, -2113.320, -186.796, 40.281, 0.250);
    RemoveBuildingForPlayer(playerid, 11048, -2113.320, -186.796, 40.281, 0.250);
    RemoveBuildingForPlayer(playerid, 1307, 937.9375, -986.53906, 37.03125, 11.724485); 
    RemoveBuildingForPlayer(playerid, 4230, 1597.9063, -1699.75, 30.21094, 119.06626); 
    RemoveBuildingForPlayer(playerid, 1260, 1538.5234, -1609.8047, 19.84375, 18.336557); 

    // ==========================================
    // 4. MAP ICONS DO SERVIDOR
    // ==========================================
    SetPlayerMapIcon(playerid, 45, 1072.307495, -1221.322021, 16.890625, 45, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 52, 941.086730, -1719.847900, 13.969263, 52, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 23, 1721.3910, -1603.2012, 13.5469, 23, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 42, 1480.538574, -1771.472778, 18.795755, 42, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 55, 2132.0105, -1149.6666, 24.2442, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 30, 1554.4910, -1675.6455, 16.1953, 30, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 30, 234.632476, 73.125434, 1005.039062, 30, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 55, 1235.6521, -1811.3728, 13.6027, 55, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 29, 2104.9507, -1806.5535, 13.5547, 29, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 60, 1762.4149, -1695.9401, 13.4308, 60, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 51, 2422.0796, -2078.8857, 13.5538, 51, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 60, 2060.3020, -1914.3926, 13.5469, 60, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 60, 610.7457, -1511.6786, 14.9330, 60, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 60, 2475.8218, -1957.4399, 13.5922, 60, 0, MAPICON_LOCAL);
    SetPlayerMapIcon(playerid, 58, 1117.6422, -1620.4365, 20.5003, 58, 0, MAPICON_LOCAL);

    // ==========================================
    // 5. STATUS DO JOGADOR
    // ==========================================
    // NAO resetar necessidades aqui. Os valores sao carregados
    // da conta em CarregarDados() apos o login.

    // ==========================================
    // 6. CRIAÇÃO DE TEXTDRAWS DO HUD E SPEEDO
    // ==========================================
    // =====================================================================
    // VELOCIMETRO BCG PRO - compacto, moderno e funcional
    // =====================================================================
    cWspeedo[playerid][0] = CreatePlayerTextDraw(playerid, 468.0, 377.0, "_");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][0], 0.0, 7.2);
    PlayerTextDrawTextSize(playerid, cWspeedo[playerid][0], 630.0, 0.0);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][0], 1);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][0], -1);
    PlayerTextDrawUseBox(playerid, cWspeedo[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, cWspeedo[playerid][0], 0x080B10E8);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][0], 1);

    cWspeedo[playerid][1] = CreatePlayerTextDraw(playerid, 468.0, 377.0, "_");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][1], 0.0, 0.18);
    PlayerTextDrawTextSize(playerid, cWspeedo[playerid][1], 630.0, 0.0);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][1], 1);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][1], -1);
    PlayerTextDrawUseBox(playerid, cWspeedo[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, cWspeedo[playerid][1], 0x00BFFFFF);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][1], 1);

    cWspeedo[playerid][2] = CreatePlayerTextDraw(playerid, 598.0, 389.0, "_");
    PlayerTextDrawTextSize(playerid, cWspeedo[playerid][2], 27.0, 27.0);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][2], 1);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][2], TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][2], -1);
    PlayerTextDrawSetPreviewRot(playerid, cWspeedo[playerid][2], -10.0, 0.0, -20.0, 1.0);

    cWspeedo[playerid][3] = CreatePlayerTextDraw(playerid, 477.0, 390.0, "000");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][3], 0.46, 1.65);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][3], 1);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][3], -1);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][3], 3);
    PlayerTextDrawSetOutline(playerid, cWspeedo[playerid][3], 1);

    cWspeedo[playerid][4] = CreatePlayerTextDraw(playerid, 478.0, 382.0, "VEICULO");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][4], 0.16, 0.72);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][4], 1);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][4], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][4], 2);
    PlayerTextDrawSetOutline(playerid, cWspeedo[playerid][4], 1);

    cWspeedo[playerid][5] = CreatePlayerTextDraw(playerid, 479.0, 411.0, "KM/H");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][5], 0.12, 0.55);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][5], 1);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][5], 0x00BFFFFF);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][5], 1);

    cWspeedo[playerid][6] = CreatePlayerTextDraw(playerid, 548.0, 394.0, "100");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][6], 0.20, 0.82);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][6], 2);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][6], -1);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][6], 3);
    PlayerTextDrawSetOutline(playerid, cWspeedo[playerid][6], 1);

    cWspeedo[playerid][7] = CreatePlayerTextDraw(playerid, 548.0, 406.0, "COMBUSTIVEL");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][7], 0.075, 0.42);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][7], 2);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][7], 0x00BFFFFF);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][7], 1);

    cWspeedo[playerid][8] = CreatePlayerTextDraw(playerid, 580.0, 394.0, "100");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][8], 0.20, 0.82);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][8], 2);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][8], -1);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][8], 3);
    PlayerTextDrawSetOutline(playerid, cWspeedo[playerid][8], 1);

    cWspeedo[playerid][9] = CreatePlayerTextDraw(playerid, 580.0, 406.0, "HP | MOTOR: ON");
    PlayerTextDrawLetterSize(playerid, cWspeedo[playerid][9], 0.075, 0.42);
    PlayerTextDrawAlignment(playerid, cWspeedo[playerid][9], 2);
    PlayerTextDrawColor(playerid, cWspeedo[playerid][9], 0x00BFFFFF);
    PlayerTextDrawFont(playerid, cWspeedo[playerid][9], 1);

    // Sistema Wasted / Inconsciente
    Wasted[playerid] = TextDrawCreate(720.243469, -122.166549, "usebox");
    TextDrawLetterSize(Wasted[playerid], 0.306881, 116.333961);
    TextDrawTextSize(Wasted[playerid], -1222.372070, 0.000000);
    TextDrawAlignment(Wasted[playerid], 1);
    TextDrawColor(Wasted[playerid], 0);
    TextDrawUseBox(Wasted[playerid], true);
    TextDrawBoxColor(Wasted[playerid], 102);
    TextDrawSetShadow(Wasted[playerid], 0);
    TextDrawSetOutline(Wasted[playerid], 0);
    TextDrawFont(Wasted[playerid], 0);

    Wasted1[playerid] = TextDrawCreate(1369.141845, 148.499908, "usebox");
    TextDrawLetterSize(Wasted1[playerid], -0.071681, 12.002384);
    TextDrawTextSize(Wasted1[playerid], -1287.496459, 48.416664);
    TextDrawAlignment(Wasted1[playerid], 1);
    TextDrawColor(Wasted1[playerid], 0);
    TextDrawUseBox(Wasted1[playerid], true);
    TextDrawBoxColor(Wasted1[playerid], 102);
    TextDrawSetShadow(Wasted1[playerid], 0);
    TextDrawSetOutline(Wasted1[playerid], 0);
    TextDrawFont(Wasted1[playerid], 0);

    Wasted2[playerid] = TextDrawCreate(248.316223, 182.583267, "inconsciente");
    TextDrawLetterSize(Wasted2[playerid], 1.045490, 4.079166);
    TextDrawAlignment(Wasted2[playerid], 1);
    TextDrawColor(Wasted2[playerid], -16776961);
    TextDrawSetShadow(Wasted2[playerid], 0);
    TextDrawSetOutline(Wasted2[playerid], 1);
    TextDrawBackgroundColor(Wasted2[playerid], 51);
    TextDrawFont(Wasted2[playerid], 3);
    TextDrawSetProportional(Wasted2[playerid], 1);

    Wasted3[playerid] = TextDrawCreate(295.168579, 218.750000, Site);
    TextDrawLetterSize(Wasted3[playerid], 0.320686, 0.934997);
    TextDrawAlignment(Wasted3[playerid], 1);
    TextDrawColor(Wasted3[playerid], -1);
    TextDrawSetShadow(Wasted3[playerid], 0);
    TextDrawSetOutline(Wasted3[playerid], 1);
    TextDrawBackgroundColor(Wasted3[playerid], 51);
    TextDrawFont(Wasted3[playerid], 1);
    TextDrawSetProportional(Wasted3[playerid], 1);

    // HUD de necessidades - estilo simples: FOME / SEDE / SONO + porcentagem
    // FOME
    Text_Player[playerid][0] = CreatePlayerTextDraw(playerid, 30.000000, 430.000000, "FOME:");
    PlayerTextDrawLetterSize(playerid, Text_Player[playerid][0], 0.220000, 0.900000);
    PlayerTextDrawAlignment(playerid, Text_Player[playerid][0], 1);
    PlayerTextDrawFont(playerid, Text_Player[playerid][0], 2);
    PlayerTextDrawColor(playerid, Text_Player[playerid][0], VERMELHO);
    PlayerTextDrawSetOutline(playerid, Text_Player[playerid][0], 1);

    Text_Player[playerid][1] = CreatePlayerTextDraw(playerid, 72.000000, 430.000000, "100%");
    PlayerTextDrawLetterSize(playerid, Text_Player[playerid][1], 0.220000, 0.900000);
    PlayerTextDrawAlignment(playerid, Text_Player[playerid][1], 1);
    PlayerTextDrawFont(playerid, Text_Player[playerid][1], 2);
    PlayerTextDrawColor(playerid, Text_Player[playerid][1], BRANCO);
    PlayerTextDrawSetOutline(playerid, Text_Player[playerid][1], 1);

    // SEDE
    Text_Player[playerid][2] = CreatePlayerTextDraw(playerid, 110.000000, 430.000000, "SEDE:");
    PlayerTextDrawLetterSize(playerid, Text_Player[playerid][2], 0.220000, 0.900000);
    PlayerTextDrawAlignment(playerid, Text_Player[playerid][2], 1);
    PlayerTextDrawFont(playerid, Text_Player[playerid][2], 2);
    PlayerTextDrawColor(playerid, Text_Player[playerid][2], VERMELHO);
    PlayerTextDrawSetOutline(playerid, Text_Player[playerid][2], 1);

    Text_Player[playerid][3] = CreatePlayerTextDraw(playerid, 151.000000, 430.000000, "100%");
    PlayerTextDrawLetterSize(playerid, Text_Player[playerid][3], 0.220000, 0.900000);
    PlayerTextDrawAlignment(playerid, Text_Player[playerid][3], 1);
    PlayerTextDrawFont(playerid, Text_Player[playerid][3], 2);
    PlayerTextDrawColor(playerid, Text_Player[playerid][3], BRANCO);
    PlayerTextDrawSetOutline(playerid, Text_Player[playerid][3], 1);

    // SONO
    Text_Player[playerid][4] = CreatePlayerTextDraw(playerid, 190.000000, 430.000000, "SONO:");
    PlayerTextDrawLetterSize(playerid, Text_Player[playerid][4], 0.220000, 0.900000);
    PlayerTextDrawAlignment(playerid, Text_Player[playerid][4], 1);
    PlayerTextDrawFont(playerid, Text_Player[playerid][4], 2);
    PlayerTextDrawColor(playerid, Text_Player[playerid][4], VERMELHO);
    PlayerTextDrawSetOutline(playerid, Text_Player[playerid][4], 1);

    Text_Player[playerid][5] = CreatePlayerTextDraw(playerid, 233.000000, 430.000000, "100%");
    PlayerTextDrawLetterSize(playerid, Text_Player[playerid][5], 0.220000, 0.900000);
    PlayerTextDrawAlignment(playerid, Text_Player[playerid][5], 1);
    PlayerTextDrawFont(playerid, Text_Player[playerid][5], 2);
    PlayerTextDrawColor(playerid, Text_Player[playerid][5], BRANCO);
    PlayerTextDrawSetOutline(playerid, Text_Player[playerid][5], 1);

    // ==========================================
    // 7. TIMER DA TELA DE LOGIN
    // ==========================================
    // O jogador fica na tela de carregamento por 15000 milissegundos (15 segundos)
    g_LoadingAtivo[playerid] = true;
    SetTimerEx("OnPlayerFinishLoading", 1500, false, "i", playerid);

    return 1;
}


public OnPlayerDisconnect(playerid, reason)
{
    if(CG54Inside[playerid]) {
        SetPlayerVirtualWorld(playerid,CG54World[playerid]);
        SetPlayerInterior(playerid,CG54Interior[playerid]);
        SetPlayerPos(playerid,CG54Return[playerid][0],CG54Return[playerid][1],CG54Return[playerid][2]);
    }
    CG54Reset(playerid);
    CG52VoiceReset(playerid);CG52Reset(playerid);
    BCG47ReleaseVehicle(playerid);
    BCG47Reset(playerid);
    BCG43InvOpen[playerid]=false;BCG43InvTick[playerid]=0;DeletePVar(playerid,"BCG43QuickReady");
    BCG38Reset(playerid);
    BCG36Client[playerid] = false;
    BCG36Authenticated[playerid] = false;
    for(new contact = 0; contact < MAX_PLAYERS; contact++) if(BCGCelularLigacao[contact] == playerid) BCGCelularLigacao[contact] = INVALID_PLAYER_ID;
    BCGCelularLigacao[playerid] = INVALID_PLAYER_ID;
    g_LoadingAtivo[playerid] = false;
    g_LojaGTAInicializada[playerid] = false;
    g_LojaGTAAtual[playerid] = -1;
    g_LanchoneteAtiva[playerid] = false;
    g_LanchoneteAtual[playerid] = -1;
    g_PlayerCrack[playerid] = false;
    if(_:BCG_TagCabeca[playerid] != 0) Delete3DTextLabel(BCG_TagCabeca[playerid]);
    BCG_VoipLigado[playerid] = false;

    if(pOnline > 0) pOnline--;
 

    
    // ==========================================
    // 1. SALVAMENTO DE DADOS E ROTAS
    // ==========================================
    SalvarComaAoSair(playerid);
    SalvarDadosRotaGangster(playerid);
    LimparDadosFabricacaoJogador(playerid);
    ResetarDadosJogadorRota(playerid, 0);
    ResetarDesmanchePlayer(playerid);
    SalvarInstagram(playerid);
    Celular_DestruirTextDraws(playerid);
    // ==========================================
    // 2. LIMPEZA DE SPEEDOMETER E HUD (cWspeedo)
    // ==========================================
    for(new i = 0; i < 10; i++) 
    {
        if(cWspeedo[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid, cWspeedo[playerid][i]);
            cWspeedo[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }


    // ==========================================
    // 4. SISTEMA DE CAIXA DE SOM (JBL)
    // ==========================================
    if(ObjetoJBL[playerid] != INVALID_OBJECT_ID)
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 35.0, JBLPos[playerid][0], JBLPos[playerid][1], JBLPos[playerid][2]))
            {
                StopAudioStreamForPlayer(i);
            }
        }
        
        DestroyObject(ObjetoJBL[playerid]);
        Delete3DTextLabel(TextJBL[playerid]);
        
        ObjetoJBL[playerid] = INVALID_OBJECT_ID;
        TextJBL[playerid] = Text3D:INVALID_3DTEXT_ID;
        JBLLigada[playerid] = false;

        Pdados[playerid][pItem_JBL]++;
        SalvarDados(playerid);
    }

    // ==========================================
    // 5. TAG / 3D TEXT DO JOGADOR
    // ==========================================
    if(TagJogador[playerid] != Text3D:INVALID_3DTEXT_ID)
    {
        Delete3DTextLabel(TagJogador[playerid]);
        TagJogador[playerid] = Text3D:INVALID_3DTEXT_ID;
    }
    
    // ==========================================
    // 6. SALVAMENTO DE CONTA PRINCIPAL
    // ==========================================
    if(Pdados[playerid][Logado] == true)
    {
        new path[64];
        format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
        
        if(DOF2_FileExists(path))
        {
            DOF2_SetInt(path, "SegundosJogados", Pdados[playerid][SegundosJogados]);
        }
        SalvarDados(playerid);
    }

    // ==========================================
    // 7. LIMPEZA DE VEiCULOS E ESTADO
    // ==========================================
    logado[playerid] = false;
    Dados[playerid][model1c] = false;
    Dados[playerid][model2c] = false;
    
    if(Dados[playerid][id1] != -1) { DestroyVehicle(Dados[playerid][id1]); Dados[playerid][id1] = -1; }
    if(Dados[playerid][id2] != -1) { DestroyVehicle(Dados[playerid][id2]); Dados[playerid][id2] = -1; }
    
    Pdados[playerid][Trabalhando] = false;
    RemovePlayerMapIcon(playerid, 45);
    DisablePlayerCheckpoint(playerid);
    
    // ==========================================
    // 8. MENSAGEM DE LOGOUT POR PROXIMIDADE
    // ==========================================
    new Motivo[20], Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    
    if(reason == 0) Motivo = "Queda de conexao";
    else if(reason == 1) Motivo = "Conta propria";
    else Motivo = "Kickado/Banido";

    format(String, sizeof(String), "{289E08}O Jogador {39F505}%s{289E08} Desconectou (%s)", Nome(playerid), Motivo);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
        {
            SendClientMessage(i, -1, String);
        }
    }

    // ==========================================
    // 9. DESTRUIcaO DE TEXTDRAWS (HUD E LOGIN OTIMIZADO)
    // ==========================================
    TextDrawDestroy(Wasted[playerid]);
    TextDrawDestroy(Wasted1[playerid]);
    TextDrawDestroy(Wasted2[playerid]);
    TextDrawDestroy(Wasted3[playerid]);
    
    for(new i = 0; i < 6; i++) 
    {
        PlayerTextDrawDestroy(playerid, Text_Player[playerid][i]);
    }
    
    // CORREcaO: Limpando apenas os 14 indices otimizados da tela de login
    for(new i = 1; i <= 14; i++) 
    {
        PlayerTextDrawDestroy(playerid, LoginTD[playerid][i]);
    }

    // ==========================================
    // 10. FINALIZAcaO E RESET DE VARIaVEIS
    // ==========================================
    Pdados[playerid][Logado] = false;
    ZerarDados(playerid);
    Pdados[playerid][pTemp] = 0;
    Pdados[playerid][pLogged] = 0;
    
    // Veiculo da Garagem
    if(VeiculoGaragem[playerid] != 0)
    {
        new carid = VeiculoGaragem[playerid];
        
        if(SlotAtual[playerid] == 1) 
        {
            Dados[playerid][gasosa1] = GasolinaVeiculo[carid];
        }
        else if(SlotAtual[playerid] == 2)
        {
            Dados[playerid][gasosa2] = GasolinaVeiculo[carid];
        }

        DestroyVehicle(carid);
        VeiculoGaragem[playerid] = 0;
        SlotAtual[playerid] = 0;
    }

    // Sistema de Voz (SampVoice) desativado nesta versao.
    lstream[playerid] = 0;
    
    return 1;
}


public OnPlayerSpawn(playerid)
{
    if(!CG52Approved[playerid]){TogglePlayerControllable(playerid,false);return 1;}
    if(!IsPlayerConnected(playerid)) return 0;

    // O spawn pode ocorrer automaticamente antes do login.
    // Nesse caso o jogador fica congelado e o callback não inicializa
    // sistemas de gameplay nem altera o estado da conta.
    if(!Pdados[playerid][Logado])
    {
        TogglePlayerControllable(playerid, false);
        return 1;
    }

    BCG47Load(playerid);
    g_MorreuPorFome[playerid] = false;
    g_MorreuPorSede[playerid] = false;
    if(!BCG36Client[playerid]) TextDrawShowForPlayer(playerid, BCG_MarcaServidor);
    if(!BCG36Client[playerid]) TextDrawShowForPlayer(playerid, BCG_MarcaEstrelas);
    if(!BCG36Client[playerid]) TextDrawShowForPlayer(playerid, BCG_MarcaRoleplay);
    if(!BCG36Client[playerid]) TextDrawShowForPlayer(playerid, BCG_MarcaDataHora);
    BCG_AtualizarTagCabeca(playerid);

    TogglePlayerControllable(playerid, 1);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetCameraBehindPlayer(playerid);

    logado[playerid] = true;
    BCG_CarregarOuCriarIDFixo(playerid);
    if(InterceptalSpawnMorte(playerid)) return 1;
    VerificarComaAoEntrar(playerid);
    CarregarDadosRotaGangster(playerid, Pdados[playerid][OrgID]);
    // ID antigo por slot removido. A tag abaixo usa somente o ID fixo.
    if(strlen(Pdados[playerid][pTexto_Titulo]) > 1)
    {
        if(TagJogador[playerid] != Text3D:INVALID_3DTEXT_ID) Delete3DTextLabel(TagJogador[playerid]);
        TagJogador[playerid] = Create3DTextLabel(Pdados[playerid][pTexto_Titulo], 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, true);
        Attach3DTextLabelToPlayer(TagJogador[playerid], playerid, 0.0, 0.0, 0.5);
    }
    
    DisablePlayerRaceCheckpoint(playerid);
    DisablePlayerCheckpoint(playerid);
    
    Pdados[playerid][pLogged] = 1;
    ApplyAnimation(playerid, "BOMBER", "BOM_PLANT", 4.1, 0, 1, 1, 0, 0, 0);
    ClearAnimations(playerid);
    
    
    if(Pdados[playerid][Mochila] == 1){
        SetPlayerAttachedObject(playerid, 1, 3026, 1, -0.16, -0.08, 0.0, 0.5, 0.5, 0.0);
        SendClientMessage(playerid, AMARELO, "Para remover seu capacete use /rmochila.");
    }
    
    format(Contas, sizeof(Contas), "Conse/%s.txt", Nome(playerid));
    if(!DOF2_FileExists(Contas)){
        DOF2_CreateFile(Contas);
        DOF2_SetInt(Contas, "Carro1", 0);
        DOF2_SetInt(Contas, "Carro2", 0);
        DOF2_SetInt(Contas, "Cor1Carro1", 1);
        DOF2_SetInt(Contas, "Cor2Carro1", 1);
        DOF2_SetInt(Contas, "Cor1Carro2", 1);
        DOF2_SetInt(Contas, "Cor2Carro2", 1);
        SalvarDados(playerid);
    }else{
        Dados[playerid][modelo1] = DOF2_GetInt(Contas, "Carro1");
        Dados[playerid][modelo2] = DOF2_GetInt(Contas, "Carro2");
        Dados[playerid][cor11] = DOF2_GetInt(Contas, "Cor1Carro1");
        Dados[playerid][cor12] = DOF2_GetInt(Contas, "Cor2Carro1");
        Dados[playerid][cor21] = DOF2_GetInt(Contas, "Cor1Carro2");
        Dados[playerid][cor22] = DOF2_GetInt(Contas, "Cor2Carro2");
        SalvarDados(playerid);
    }
    format(Contas, sizeof(Contas), "Contas/%s.txt", Nome(playerid));
    Dados[playerid][CNH] = DOF2_GetBool(Contas, "CNH");
    
    SetPlayerScore(playerid, Pdados[playerid][Level]);
    SetPlayerSkin(playerid, Pdados[playerid][Skin]);
    SetPlayerColor(playerid, BRANCO);
    BCG_AplicarCorOrg(playerid);
    
    if(Pdados[playerid][Logado] == false){
        SendClientMessage(playerid, VERMELHO, "Faca o login antes de dar spawn");
        Kick(playerid);
        return 1;
    }

    // Fluxo normal de carregamento para jogadores VIVOS
    if(carregou[playerid] == 0){
        GameTextForPlayer(playerid, "~w~Espere...", 4000, 4);
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("carregando", 4000, true, "i", playerid);
        carregou[playerid] = 1;
    }
    if(PrimeiroSpawn[playerid] == true)
    {
        PrimeiroSpawn[playerid] = false; 
        return 1; 
    }

    // Daqui para baixo, o codigo so roda em spawns normais (como sair do hospital/prefeitura)
    if(Pdados[playerid][Trabalho] == 1){
        SetPlayerPos(playerid, 2103.389892, -1807.165893, 13.554687);
        SetPlayerSkin(playerid, 155);
    }
    if(Pdados[playerid][Trabalho] == 2){
        SetPlayerSkin(playerid, 170);
        SetPlayerPos(playerid, 1770.073608, -1657.932861, 14.419504);
    }
    if(Pdados[playerid][Trabalho] == 4){
        SetPlayerSkin(playerid, 187);
        SetPlayerPos(playerid, 2046.201416, -1907.760498, 13.546875);
    }
    if(Pdados[playerid][Trabalho] == 5){
        SetPlayerSkin(playerid, 23);
        SetPlayerPos(playerid, 614.1475, -1522.6667, 15.1009);
    }
    if(Pdados[playerid][Trabalho] == 6){
        SetPlayerSkin(playerid, 7);
        SetPlayerColor(playerid, branco);
        SetPlayerPos(playerid, 2475.8218, -1957.4399, 13.5922);
    }
    if(Pdados[playerid][Trabalho] == 7){
        SetPlayerSkin(playerid, 27);
        SetPlayerPos(playerid, 2714.9199, 852.9884, 10.8984);
    }
    if(Pdados[playerid][Trabalho] == 8){
        SetPlayerSkin(playerid, 16);
        SetPlayerPos(playerid, 2199.7515, -1970.3779, 13.7841);
    }
    if(Pdados[playerid][Trabalho] == 9){
        SetPlayerSkin(playerid, 260);
        SetPlayerPos(playerid, 1707.3555, 950.1088, 10);
    }
    if(Pdados[playerid][Trabalho] == 10){
        SetPlayerSkin(playerid, 167);
        SetPlayerPos(playerid, 1199.5811, -918.6766, 43.1170);
    }

    // =======================================================
    // COPS SPAWN FIXO (MODIFICADOS PARA INTERIOR DA DELEGACIA)
    // =======================================================
    if(Pdados[playerid][OrgID] == 1){
        SetPlayerSkin(playerid, 287);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 2){
        SetPlayerSkin(playerid, 285);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 5){
        SetPlayerSkin(playerid, 285);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 4){
        SetPlayerSkin(playerid, 285);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 44)
    {
        SetPlayerInterior(playerid, 6);
        if(Pdados[playerid][Genero] == 1){
            SetPlayerSkin(playerid, 281);
            SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
            SetPlayerColor(playerid, branco);
        }
        if(Pdados[playerid][Genero] == 2){
            SetPlayerSkin(playerid, 306);
            SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
            SetPlayerColor(playerid, branco);
        }
    }
    if(Pdados[playerid][OrgID] == 6){
        SetPlayerSkin(playerid, 282);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 7){
        SetPlayerSkin(playerid, 280);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 8){
        SetPlayerSkin(playerid, 286);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 9){
        SetPlayerSkin(playerid, 98);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 10){
        SetPlayerSkin(playerid, 283);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 11){
        SetPlayerSkin(playerid, 280);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 12){
        SetPlayerSkin(playerid, 284);
        SetPlayerPos(playerid, 234.632476, 73.125434, 1005.039062);
        SetPlayerInterior(playerid, 6);
        SetPlayerColor(playerid, branco);
    }
    // =======================================================

    if(Pdados[playerid][OrgID] == 13){
        SetPlayerSkin(playerid, 164);
        SetPlayerPos(playerid, 1123.582763, -2036.770629, 69.886787);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 15){
        SetPlayerSkin(playerid, 274);
        SetPlayerPos(playerid, 1172.5791, -1323.3423, 15.4030);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 16){
        SetPlayerSkin(playerid, 123);
        SetPlayerPos(playerid, 690.704223, -1275.822387, 13.560098);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 17){
        SetPlayerSkin(playerid, 5);
        SetPlayerPos(playerid, 413.6285, 2537.2800, 19.1484);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 19){
        SetPlayerSkin(playerid, 123);
        SetPlayerPos(playerid, 2751.620849, -1963.114624, 13.546875);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 20){
        SetPlayerSkin(playerid, 294);
        SetPlayerPos(playerid, 2634.080322, 1716.519775, 11.023437);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 21){
        SetPlayerPos(playerid, 1457.021240, 2773.583007, 10.820312);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 22){
        SetPlayerPos(playerid, 1519.391601, -1452.915893, 14.205425);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 24){
        SetPlayerPos(playerid, 1105.8649, -299.4608, 74.5391);
        SetPlayerSkin(playerid, 19);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 25){
        SetPlayerPos(playerid, -329.869171, 1536.512084, 76.611709);
        SetPlayerSkin(playerid, 102);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 26){
        SetPlayerPos(playerid, 1753.064453, -1920.982910, 13.571911);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 27){
        SetPlayerPos(playerid, 2163.909423, -2270.639404, 13.322597);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 28){
        SetPlayerPos(playerid, 912.3699, -1235.4672, 17.2109);
        SetPlayerSkin(playerid, 34);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 29){
        SetPlayerPos(playerid, 1153.863403, -1180.921875, 32.818702);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 30){
        SetPlayerPos(playerid, 1649.046875, 701.809509, 10.820312);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 31){
        SetPlayerPos(playerid, 2808.202636, -1176.417114, 25.373828);
        SetPlayerSkin(playerid, 170);
        SetPlayerColor(playerid, branco);
    }
    if(Pdados[playerid][OrgID] == 33){
        SetPlayerPos(playerid, 1031.7509, -1435.2968, 13.5546);
        SetPlayerColor(playerid, branco);
        SetPlayerSkin(playerid, 50);
    }
    
    format(StringContas, sizeof(StringContas), "Presos/%s.txt", Nome(playerid));
    new tempo = DOF2_GetInt(StringContas, "Tempo Preso");
    if(tempo > 0){
        SendClientMessage(playerid, AZUL_CLARO, "Voce nao cumpriu sua pena por isso voltou a cadeia");
        SetPlayerPos(playerid, 196.9844, 162.0234, 1002.6875);
        SetPlayerInterior(playerid, 3);
        SetTimerEx("tpreso", tempo, false, "i", playerid);
        Pdados[playerid][Logado] = false;
    }
    
    if(Pdados[playerid][Preso] == 1)
    {
        TogglePlayerControllable(playerid, 1);
        GameTextForPlayer(playerid, "~g~VOCE ESTA PRESO!", 3000, 0);
        SetPlayerSpecialAction(playerid, 0);
        SetPlayerHealth(playerid, 99999);
        SetPlayerWantedLevel(playerid, 0);
        ResetPlayerWeapons(playerid);
        algemado[playerid] = 0;
        Pdados[playerid][Preso] = 1;
        SetPlayerPos(playerid, 264.6288, 77.5742, 1001.0391);
        SetPlayerInterior(playerid, 6);
        SetTimerEx("TempoPreso", 900000, true, "i", playerid);
        SendClientMessage(playerid, AMARELO, "| PRESO | {FFFFFF}Voce foi preso durante 15 minutos.");
    }
    
    BCG_AplicarCorOrg(playerid);
    return 1;
}


public OnVehicleSpawn(vehicleid)
{   
    // Garante que o motor na nossa variavel comece desligado
    MotorLigado[vehicleid] = false;

    // Reseta os dados de carga/motorista do seu sistema para este carro especifico
    if(vehicleid >= 0 && vehicleid < MAX_VEHICLES)
    {
        CarDados[vehicleid][motorista] = -1;
        CarDados[vehicleid][carga] = -1;
    }

    // --- CORREcaO: Forca o motor nativo a iniciar desligado ---
    new motor, farois, alarme, doors, bonnet, boot, obj;
    GetVehicleParamsEx(vehicleid, motor, farois, alarme, doors, bonnet, boot, obj);
    SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, farois, alarme, doors, bonnet, boot, obj);

    return 1;
}


public OnVehicleDeath(vehicleid, killerid)
{
    if(vehicleid>0 && vehicleid<MAX_VEHICLES && BCG47TempActive[vehicleid]) DestroyVehicle(vehicleid);
	return 1;
}
public OnPlayerText(playerid, text[])
{
    if(!Pdados[playerid][pLogged] || GetPVarInt(playerid, "BCG_NOVA_CONTA")) return 0;
    // --- SISTEMA ANTI-FLOOD ---
    msgs[playerid]++; // Soma 1 mensagem ao contador do jogador
    if(msgs[playerid] == 1) SetTimerEx("Flood", 5000, false, "i", playerid);
    
    if(msgs[playerid] == 4) 
    {
        SendClientMessage(playerid, VERMELHO, "{00BFFF}BCG: Escreva um pouco mais devagar ou sera considerado flood (espere 5 segundos)");
    }
    
    if(msgs[playerid] > 5)
    {
        format(String, sizeof(String), "{1560BD}%s {87CEEB}foi kickado por flood", Nome(playerid));
        SendClientMessageToAll(AMARELO, String);
        Kick(playerid);
        return 0;
    }

    // --- OBTER POSIcaO DO JOGADOR ---
    new Float:pos[3];
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

    // --- FORMATAcaO DA MENSAGEM ---
    // Corrigido para usar a variavel 'String' global/local unificada que voce usa no resto do script
    format(String, sizeof(String), "{FFFFFF}ID: %d: %s", BCG_IDFixo[playerid], text);

    // --- ENVIO POR PROXIMIDADE (Chat Local usando foreach) ---
    foreach(Player, i)
    {
        if(IsPlayerConnected(i))
        {
            // Relogio real do celular (hora do servidor).
            new horaCel, minutoCel, segundoCel, strHoraCel[12];
            gettime(horaCel, minutoCel, segundoCel);
            format(strHoraCel, sizeof(strHoraCel), "%02d:%02d", horaCel, minutoCel);
            PlayerTextDrawSetString(i, CelularHomeTD[i][0], strHoraCel);
            // Verifica se o jogador esta no mesmo Virtual World e Interior para nao vazar o chat
            if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(playerid) == GetPlayerInterior(i))
            {
                // Raio de 15.0 metros de distancia
                if(IsPlayerInRangeOfPoint(i, 15.0, pos[0], pos[1], pos[2]))
                {
                    SendClientMessage(i, GetPlayerColor(playerid), String);
                }
            }
        }
    }    
    return 0;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(success && Pdados[playerid][Admin] > 0) BCG_LogAdmin(playerid, cmdtext);
    // Se o comando foi executado com sucesso, libera a execucao nativa
    if(success) return 1;

    // Impede o envio da mensagem caso o jogador digite apenas "/" por engano
    if(strlen(cmdtext) <= 1) return 1;

    // Mensagem profissional com o /ajuda em Azul Celeste {00BFFF}
    SendClientMessage(playerid, 0xAFAFAFAA, "[ERRO] Comando nao reconhecido. Digite {00BFFF}/ajuda {AFAFAF}para ver a lista de comandos.");
    
    return 1;
}

public Flood(playerid){
	msgs[playerid] = 0;
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/tdtest", true))
	{
		return 1;
	}
	return 0;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    // CORTA O MAL PELA RAIZ: Se o ID do veiculo for invalido, cancela o bug
    if(vehicleid == INVALID_VEHICLE_ID || vehicleid <= 0)
    {
        ClearAnimations(playerid);
        TogglePlayerControllable(playerid, false);
        TogglePlayerControllable(playerid, true);
        return 1;
    }

    // Sistema de MotoTaxi / Corrida existente
    for(new c = 0; c < 5; c++)
    {
        if(vehicleid == CarroMoto[c])
        {
            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
                {
                    if(Pdados[i][Corrida] > 0)
                    {
                        format(String, sizeof(String), "Voce pagou %i pela passagem", Passagem);
                        SendClientMessage(playerid, AZUL_CLARO, String);
                        GivePlayerMoney(playerid, -Passagem);
                    }
                }
            }
        }
    }
    
    entrouveh[playerid] = 1;
    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid == INVALID_PLAYER_TEXT_DRAW)
    {
        if(g_MenuBancoAberto[playerid] != MENU_BANCO_FECHADO)
        {
            CloseBancoInterface(playerid);
            return 1;
        }
        if(IsInventoryOpen[playerid])
        {
            SelectTextDraw(playerid, 0xA3B4C2FF);
            return 1;
        }
        return 1;
    }

    // ==========================================
    // INTERAÇÃO: TELA DE LOGIN
    // ==========================================
    if(playertextid == LoginTD[playerid][11] || playertextid == LoginTD[playerid][12])
    {
        format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
        if(!DOF2_FileExists(StringContas))
        {
            OcultarLoginScreen(playerid);
            MostrarRegistroScreen(playerid);
        }
        else
        {
            format(String, sizeof(String), "Nome: %s\nInsira sua senha abaixo para logar:", Nome(playerid));
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00BFFF}CIDADE GRANDE | LOGIN", String, "ENTRAR", "SAIR");
        }
        return 1;
    }

    // ==========================================
    // INTERAÇÃO: TELA DE REGISTRO
    // ==========================================
    if(playertextid == RegisterTD[playerid][15] || playertextid == RegisterTD[playerid][16])
    {
        format(String, sizeof(String), "Nome: %s\nInsira sua senha abaixo para registrar:", Nome(playerid));
        ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "Registre-se", String, "Registrar", "Sair");
        return 1;
    }

    if(playertextid == RegisterTD[playerid][17]) // Clicou em "Já tem conta? Entrar"
    {
        OcultarRegistroScreen(playerid);
        MostrarLoginScreen(playerid);
        return 1;
    }

    // ==========================================
    // INTERAÇÃO: INVENTÁRIO
    // ==========================================
    if(IsInventoryOpen[playerid])
    {
        if(playertextid == INVINFO[playerid][9])
        {
            CloseCustomInventory(playerid);
            return 1;
        }
        if(playertextid == INVINFO[playerid][1])
        {
            new slot = SelectedInventorySlot[playerid];
            if(slot == -1 || PlayerInventory[playerid][slot][itemQuantity] <= 0)
            {
                SendClientMessage(playerid, 0xFF0000FF, "Selecione um slot com item valido primeiro!");
                return 1;
            }
            if(!strcmp(PlayerInventory[playerid][slot][itemName], "Celular", true))
            {
                ShowPlayerDialog(playerid, DIALOG_CELULAR, DIALOG_STYLE_INPUT, "Celular", "1 - Aplicativos\n2 - Pedir Taxi\n3 - GPS", "Selecionar", "Fechar");
            }
            else
            {
                new msg[128];
                format(msg, sizeof(msg), "Voce usou o item: %s", PlayerInventory[playerid][slot][itemName]);
                SendClientMessage(playerid, 0xFFFF00FF, msg);
            }
            return 1;
        }
        for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
        {
            if(playertextid == GARISBAWAH[playerid][i])
            {
                SelectedInventorySlot[playerid] = i;
                return 1;
            }
        }
    }

    // ==========================================
    // INTERACAO: CELULAR VISUAL BCG
    // ==========================================
    if(BCGCelularAberto[playerid])
    {
        // 0 WhatsApp
        if(playertextid == CelularHomeTD[playerid][24])
        {
            MostrarCelularBCG(playerid);
            return 1;
        }
        // 1 SOS
        if(playertextid == CelularHomeTD[playerid][25])
        {
            ShowPlayerDialog(playerid, DIALOG_BCG_ANUNCIO, DIALOG_STYLE_MSGBOX, "S.O.S.", "Servico de emergencia do Cidade Grande Roleplay.", "OK", "");
            return 1;
        }
        // 2 GPS
        if(playertextid == CelularHomeTD[playerid][26])
        {
            ShowPlayerDialog(playerid, DIALOG_BCG_GPS, DIALOG_STYLE_LIST, "GPS - CIDADE GRANDE", "Prefeitura\nHospital\nDelegacia\nBanco\nSpawn", "Marcar", "Voltar");
            return 1;
        }
        // 3 Banco
        if(playertextid == CelularHomeTD[playerid][27])
        {
            for(new i = 0; i < 11; i++) PlayerTextDrawHide(playerid, CelularCarcacaTD[playerid][i]);
            for(new i = 0; i < 37; i++) PlayerTextDrawHide(playerid, CelularHomeTD[playerid][i]);
            BCGCelularAberto[playerid] = false;
            CelularAberto[playerid] = false;
            CancelSelectTextDraw(playerid);
            OpenBancoInterface(playerid);
            return 1;
        }
        // 4 Bitcoin
        if(playertextid == CelularHomeTD[playerid][28])
        {
            ShowPlayerDialog(playerid, 18707, DIALOG_STYLE_MSGBOX, "BITCOIN", "Carteira Bitcoin do Cidade Grande.\n\nFuncao pronta para integracao com sua economia.", "OK", "");
            return 1;
        }
        // 5 Spotify
        if(playertextid == CelularHomeTD[playerid][29])
        {
            ShowPlayerDialog(playerid, 18708, DIALOG_STYLE_MSGBOX, "SPOTIFY", "Aplicativo de musica do Cidade Grande Roleplay.", "OK", "");
            return 1;
        }
        // 6 Mensagens
        if(playertextid == CelularHomeTD[playerid][30])
        {
            MostrarCelularBCG(playerid);
            return 1;
        }
        // 7 Telefone
        if(playertextid == CelularHomeTD[playerid][31])
        {
            MostrarCelularBCG(playerid);
            return 1;
        }
        // 8 Contatos
        if(playertextid == CelularHomeTD[playerid][32])
        {
            ShowPlayerDialog(playerid, DIALOG_BCG_CONTATOS, DIALOG_STYLE_LIST, "CELULAR - CONTATOS", "Contatos salvos\nAdicionar contato\nVoltar", "Selecionar", "Fechar");
            return 1;
        }
        // 9 Camera
        if(playertextid == CelularHomeTD[playerid][33])
        {
            SendClientMessage(playerid, 0xFFFFFFFF, "[CELULAR] Camera selecionada.");
            return 1;
        }
        // Navegacao inferior
        if(playertextid == CelularHomeTD[playerid][34] || playertextid == CelularHomeTD[playerid][35] || playertextid == CelularHomeTD[playerid][36])
        {
            for(new i = 0; i < 11; i++) PlayerTextDrawHide(playerid, CelularCarcacaTD[playerid][i]);
            for(new i = 0; i < 37; i++) PlayerTextDrawHide(playerid, CelularHomeTD[playerid][i]);
            BCGCelularAberto[playerid] = false;
            CelularAberto[playerid] = false;
            CancelSelectTextDraw(playerid);
            return 1;
        }
    }

    // ==========================================
    // INTERAÇÃO: BANCO
    // ==========================================
    if(g_MenuBancoAberto[playerid] != MENU_BANCO_FECHADO)
    {
        if(playertextid == PTD_BancoBotoes[playerid][0])
        {
            ShowPlayerDialog(playerid, 9951, DIALOG_STYLE_INPUT, "Banco BCG - Deposito", "Insira o valor que deseja depositar:", "Confirmar", "Cancelar");
            return 1;
        }
        if(playertextid == PTD_BancoBotoes[playerid][5])
        {
            CloseBancoInterface(playerid);
            return 1;
        }
    }

    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(vehicleid == CarroDono[playerid]){
		DestroyVehicle(CarroDono[playerid]);
		CarroDono[playerid] = -1;
	}
	{
    if(VehCriado[playerid])
    {
            DestroyVehicle(VehAluguel[playerid]);
            VehCriado[playerid] = false;
        }
    }
	if(Pdados[playerid][Arrastado] != 0){
	PutPlayerInVehicle(playerid,Pdados[playerid][Arrastado],3);
	SendClientMessage(playerid,VERMELHO,"Voce nao pode sair desse veiculo");
	format(String,sizeof(String),"O %s tentou sair do veiculo",Nome(playerid));
	MsgPerto(playerid,VERMELHO,String);
	}
	for(new c =0;c<5;c++){
		if(GetPlayerVehicleID(playerid)==CarroMoto[c]){
			if(Pdados[playerid][Corrida] != 0)return DisablePlayerCheckpoint(playerid),SendClientMessage(playerid,AZUL_CLARO,"Voce saiu do onibus em servico por isso foi cancelado"),Pdados[playerid][Corrida] =0;
		}
	}
	entrouveh[playerid] = 0;
	RemovePlayerAttachedObject(playerid, 3);
	return 1;
}


public OnPlayerStateChange(playerid, newstate, oldstate)
{
    new vid = GetPlayerVehicleID(playerid);

    // -------------------------------------------------------------------------
    // AO ENTRAR EM UM VEiCULO (Como Motorista ou Passageiro)
    // -------------------------------------------------------------------------
    // ADICIONADO: vid > 0 para garantir que o jogador REALMENTE esta associado a um carro
    if((newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && vid > 0)
    {
        // Validacao: Aluguel de Bicicletas
        if(IsVehicleInArray(vid, bikes, sizeof(bikes)))
        {
            if(GetPlayerMoney(playerid) < 50)
            {
                SendClientMessage(playerid, VERMELHO, "ERRO: Voce nao tem R$50 para andar de bicicleta!");
                RemovePlayerFromVehicle(playerid);
            }
        }

        // Validacao: Taxis do Servidor
        else if(IsVehicleInArray(vid, taxis, sizeof(taxis)))
        {
            new seat = GetPlayerVehicleSeat(playerid);
            
            if(Pdados[playerid][Trabalho] != 6 && seat == 0) // Tentou dirigir e nao e taxista
            {
                SendClientMessage(playerid, VERMELHO, "ERRO: Voce nao tem a chave deste veiculo!");
                RemovePlayerFromVehicle(playerid);
                
                // Forca o reset de animacao para evitar bugs do boneco travado no teto
                TogglePlayerControllable(playerid, 0);
                TogglePlayerControllable(playerid, 1);
            }
        }

        // Validacao: Carros da Autoescola (A)
        else if(IsVehicleInArray(vid, carrosa, sizeof(carrosa)))
        {
            if(autoescola[playerid] == 1)
            {
                SetPlayerRaceCheckpoint(playerid, 1, 1262.8689, -2015.8340, 59.3379, 1262.8689, -2015.8340, 59.3379, 5.0);
            }
            else
            {
                SendClientMessage(playerid, VERMELHO, "ERRO: Veiculo restrito para testes da Autoescola (Carros)!");
                RemovePlayerFromVehicle(playerid);
            }
        }

        // Validacao: Carros da Autoescola (B - Moto)
        else if(IsVehicleInArray(vid, carrosb, sizeof(carrosb)))
        {
            if(autoescolab[playerid] == 1)
            {
                SetPlayerRaceCheckpoint(playerid, 1, 1262.8689, -2015.8340, 59.3379, 1262.8689, -2015.8340, 59.3379, 5.0);
            }
            else
            {
                SendClientMessage(playerid, VERMELHO, "ERRO: Veiculo restrito para testes da Autoescola (Motos)!");
                RemovePlayerFromVehicle(playerid);
            }
        }

        // Validacao: Carros da Autoescola (C - Caminhao)
        else if(IsVehicleInArray(vid, carrosc, sizeof(carrosc)))
        {
            if(autoescolac[playerid] == 1)
            {
                SetPlayerRaceCheckpoint(playerid, 1, 1262.8689, -2015.8340, 59.3379, 1262.8689, -2015.8340, 59.3379, 5.0);
            }
            else
            {
                SendClientMessage(playerid, VERMELHO, "ERRO: Veiculo restrito para testes da Autoescola (Caminhoes)!");
                RemovePlayerFromVehicle(playerid);
            }
        }

        // Validacao: Carro Forte (Transportador de Valores)
        else if(IsVehicleInArray(vid, CarGari, sizeof(CarGari)))
        {
            if(Gari[playerid] == 0)
            {
                SendClientMessage(playerid, VERMELHO, "ERRO: Veiculo reservado para os Transportadores de Valores!");
                RemovePlayerFromVehicle(playerid);
            }
            else if(carroforte[playerid] == 0)
            {
                SendClientMessage(playerid, VERDE, "INFO: Use /lsgrana para iniciar as suas rotas de servico.");
            }
        }
    }

    // -------------------------------------------------------------------------
    // QUANDO O JOGADOR FICA A Pe (Sai de qualquer veiculo)
    // -------------------------------------------------------------------------
    if(newstate == PLAYER_STATE_DRIVER && vid > 0)
    {
        if(!IsAbicycle(vid))
        {
            // Verificação adicional para garantir que o veículo não pertence a outra organização
            new player_org = Pdados[playerid][OrgID];
            
            for(new org = 0; org < MAX_ORGS_VEHICLES; org++)
            {
                for(new slot = 0; slot < MAX_VEHS_PER_ORG; slot++)
                {
                    if(OrgVehicles[org][slot][ovCriado] && OrgVehicles[org][slot][ovSpawnID] == vid)
                    {
                        if(player_org != org)
                        {
                            RemovePlayerFromVehicle(playerid);
                            SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce nao pertence a esta organizacao e nao pode usar este veiculo!");
                            return 1;
                        }
                    }
                }
            }

            new vstr[32];
            GetVehicleName(vid, vstr, sizeof(vstr));
            
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][4], vstr);
            PlayerTextDrawSetPreviewModel(playerid, cWspeedo[playerid][2], GetVehicleModel(vid));
            
            // Forca uma atualizacao imediata ao entrar para nao exibir dados velhos
            new str[16], Float:health;
            GetVehicleHealth(vid, health);
            
            new speedNow = floatround(GetVehicleSpeed(vid));
            if(speedNow < 0) speedNow = 0;
            if(speedNow > 999) speedNow = 999;
            format(str, sizeof(str), "%03d", speedNow);
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][3], str);
            
            new fuelNow = GasolinaVeiculo[vid];
            if(fuelNow < 0) fuelNow = 0;
            if(fuelNow > 100) fuelNow = 100;
            format(str, sizeof(str), "%d", fuelNow);
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][6], str);
            
            new hpNow = floatround(health / 10.0);
            if(hpNow < 0) hpNow = 0;
            if(hpNow > 100) hpNow = 100;
            format(str, sizeof(str), "%d", hpNow);
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][8], str);
            
            // Mostra o velocimetro
            for(new i = 0; i < 10; i++) 
            {
                if(!BCG36Client[playerid]) PlayerTextDrawShow(playerid, cWspeedo[playerid][i]);
            }
        }
    }
    else if(oldstate == PLAYER_STATE_DRIVER)
    {
        // Esconde o velocimetro se o jogador deixar de ser motorista
        for(new i = 0; i < 10; i++) 
        {
            PlayerTextDrawHide(playerid, cWspeedo[playerid][i]);
        }
    }

    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    new string[128]; // String local segura, evitando conflitos globais
    
    new orgPolicial = Pdados[playerid][OrgID];
    new playerNome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerNome, sizeof(playerNome));

    // Se quem entrou no checkpoint for um policial fardado ou for voce testando
    if((orgPolicial >= 1 && orgPolicial <= 12 && Pdados[playerid][Farda] == true) || strcmp(playerNome, "Lipee_fxp1", true) == 0)
    {
        DisablePlayerCheckpoint(playerid); // Remove o ponto vermelho do mapa
        SendClientMessage(playerid, -1, "{2ECC71}[SISTEMA] {FFFFFF}Voce chegou ao local da ocorrencia de disparos. Fique atento!");

        return 1; // <--- ADICIONADO: Evita que o codigo do policial execute os trabalhos abaixo!
    }
    
    // BCG V3 - trabalho comunitario dentro da prisao
    if(PrisaoMissaoBCG[playerid])
    {
        PrisaoEtapaBCG[playerid]++;
        if(PrisaoEtapaBCG[playerid] >= 4)
        {
            DisablePlayerCheckpoint(playerid);
            PrisaoMissaoBCG[playerid] = false;
            PrisaoEtapaBCG[playerid] = 0;
            if(Pdados[playerid][Preso] == 1)
            {
                Pdados[playerid][Preso] = 0;
                TogglePlayerControllable(playerid, true);
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, 1550.7477, -1675.4952, 15.5439);
            }
            GivePlayerMoney(playerid, PrisaoRecompensaBCG[playerid]);
            PrisaoRecompensaBCG[playerid] = 0;
            SalvarDados(playerid);
            SendClientMessage(playerid, 0x2ECC71FF, "[PRISAO] Trabalho comunitario concluido. Pena encerrada.");
            return 1;
        }

        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);
        SetPlayerCheckpoint(playerid, px + float(random(10) - 5), py + float(random(10) - 5), pz, 2.5);
        SendClientMessage(playerid, 0xF1C40FFF, "[PRISAO] Continue o servico comunitario. Proxima tarefa marcada.");
        return 1;
    }

    // =============================================================================
    // --- TRABALHO 1: ENTREGADOR DE PIZZA ---
    // =============================================================================
    if(Pdados[playerid][Trabalho] == 1 && Pdados[playerid][Pizza] > 0)
    {
        Pdados[playerid][Pizza]--;
        
        new r = random(sizeof(pizzas));
        new g = random(200);
        
        if(Pdados[playerid][Vip] == 1) 
        {
            g *= 2;
            SendClientMessage(playerid, AZUL, "Voce recebeu o dobro do pagamento por ser VIP");
        }
        
        GivePlayerMoney(playerid, g);
        format(string, sizeof(string), "Voce recebeu R$%i com essa entrega", g);
        SendClientMessage(playerid, VERDE, string);
        
        if(Pdados[playerid][Pizza] > 0)
        {
            DisablePlayerCheckpoint(playerid); 
            SetPlayerCheckpoint(playerid, pizzas[r][0], pizzas[r][1], pizzas[r][2], 8.0);
            SendClientMessage(playerid, CINZA, "Proximo destino foi marcado");
        }
        else 
        {
            SendClientMessage(playerid, VERDE, "Todas as pizzas foram entregues!");
            DisablePlayerCheckpoint(playerid);
        }
        return 1;
    }

    // =============================================================================
    // --- TRABALHO 2: INSTALADOR / TeCNICO ---
    // =============================================================================
    else if(Pdados[playerid][Trabalho] == 2)
    {
        new g = random(500);
        if(Pdados[playerid][Vip] == 1) 
        {
            g *= 2;
            SendClientMessage(playerid, AZUL, "Voce recebeu o dobro do pagamento por ser VIP");
        }
        
        GivePlayerMoney(playerid, g);
        format(string, sizeof(string), "Voce recebeu R$%i com essa instalacao", g);
        SendClientMessage(playerid, CINZA, string);
        SendClientMessage(playerid, CINZA, "Volte para a central e pegue outro cliente");
        DisablePlayerCheckpoint(playerid);
        return 1;
    }

    // =============================================================================
    // --- TRABALHO 4: MOTORISTA DE oNIBUS ---
    // =============================================================================
    else if(Pdados[playerid][Trabalho] == 4)
    {
        Pdados[playerid][Corrida]++;
        new c = Pdados[playerid][Corrida];
        
        if(c <= 15)
        {
            SetPlayerCheckpoint(playerid, Ponto[c][0], Ponto[c][1], Ponto[c][2], 10.0);
            SendClientMessage(playerid, CINZA, "Proximo ponto de onibus marcado");
        }
        else
        {
            new sal = 500;
            if(Pdados[playerid][Vip] == 1) 
            {
                sal *= 2;
                SendClientMessage(playerid, AZUL, "Voce recebeu o dobro do pagamento por ser VIP");
            }
            
            Pdados[playerid][Corrida] = 0;
            GivePlayerMoney(playerid, sal);
            format(string, sizeof(string), "Voce recebeu R$%i ao concluir a rota", sal);
            SendClientMessage(playerid, CINZA, string);
            SendClientMessage(playerid, CINZA, "Volte para a rodoviaria para iniciar uma nova corrida");
            DisablePlayerCheckpoint(playerid);
        }
        return 1;
    }

    // =============================================================================
    // --- SISTEMA DE CARGAS (CAMINHaO) ---
    // =============================================================================
    else if(IsPlayerInAnyVehicle(playerid))
    {
        new vehid = GetPlayerVehicleID(playerid);
        if(CarDados[vehid][caminhao] == true)
        {
            switch(CarDados[vehid][carga])
            {
                case 1: // Carga Comum
                {
                    new pagamento = 1000;
                    if(Pdados[playerid][Vip] == 1) 
                    { 
                        pagamento *= 2; 
                        SendClientMessage(playerid, AZUL_CLARO, "Pagamento VIP (2x)"); 
                    }
                    
                    GivePlayerMoney(playerid, pagamento);
                    format(string, sizeof(string), "Voce recebeu R$%i pela entrega da carga", pagamento);
                    SendClientMessage(playerid, AZUL_CLARO, string);
                    
                    CarDados[vehid][carga] = 0;
                    CarDados[vehid][motorista] = -1;
                    DisablePlayerCheckpoint(playerid);
                    return 1;
                }
                case 2: // Carga Especial (Parte 1)
                {
                    SendClientMessage(playerid, VERMELHO, "BCG: Carga identificada! Prossiga para o local de descarga na favela.");
                    SetPlayerCheckpoint(playerid, 1512.9031, -695.0535, 94.7500, 5.0);
                    CarDados[vehid][carga] = 3;
                    return 1;
                }
                case 3: // Carga Especial (Entrega Final)
                {
                    new pagamento = 4000; 
                    if(Pdados[playerid][Vip] == 1) 
                    { 
                        pagamento *= 2; 
                        SendClientMessage(playerid, AZUL_CLARO, "Pagamento VIP (2x)"); 
                    }
                    
                    GivePlayerMoney(playerid, pagamento);
                    format(string, sizeof(string), "Voce recebeu R$%i pelo transporte especial", pagamento);
                    SendClientMessage(playerid, AZUL_CLARO, string);
                    
                    CarDados[vehid][carga] = 0;
                    CarDados[vehid][motorista] = -1;
                    DisablePlayerCheckpoint(playerid);
                    return 1;
                }
                default: 
                {
                    DisablePlayerCheckpoint(playerid);
                    return 1;
                }
            }
        }
    }

    // =============================================================================
    // --- CHECKPOINTS GENeRICOS (/cliente, /clientec, etc) ---
    // =============================================================================
    if(onCheck[playerid])
    {
        DisablePlayerCheckpoint(playerid);
        onCheck[playerid] = false;
        return 1;
    }

    return 1;
}



public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    new vehicleid = GetPlayerVehicleID(playerid);
    new modelid = GetVehicleModel(vehicleid);

    // =============================================================================
    // --- SISTEMA DE REVISTA ---
    // =============================================================================
    if(revista[playerid] == 1)
    {
        DisablePlayerRaceCheckpoint(playerid);
        SendClientMessage(playerid, branco, "| Entregador | Voce entregou as revistas e recebeu $500.");
        GivePlayerMoney(playerid, 500);
        revista[playerid] = 0;
        return 1;
    }

        // =============================================================================
    // --- SISTEMA DE CIMENTO: CHEGADA a OBRA ---
    // =============================================================================
    if(ccimento[playerid] == 1)
    {
        if(IsPlayerInRangeOfPoint(playerid, 10.0, Cimento_Obra_X, Cimento_Obra_Y, Cimento_Obra_Z))
        {
            DisablePlayerRaceCheckpoint(playerid);
            ccimento[playerid] = 2; // Estado 2: Precisa entregar a ficha ao bot
            
            PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0); // Som de alivio de freio hidraulico
            
            SendClientMessage(playerid, AMARELO, "[OBRA]: Caminhao posicionado! Saia do veiculo, va ate o Mestre de Obras e digite /entregarficha.");
            return 1;
        }
    }


    // =============================================================================
    // --- SISTEMA DE AUTOESCOLA ---
    // =============================================================================
    if(autoescola[playerid] == 1 || autoescolab[playerid] == 1 || autoescolac[playerid] == 1)
    {
        if(IsPlayerInRangeOfPoint(playerid, 50.0, 1262.8689, -2015.8340, 59.3379))
        {
            DisablePlayerRaceCheckpoint(playerid);
            
            if(modelid == 562) { Pdados[playerid][CNH] = 1; SendClientMessage(playerid, AMARELO, "Voce tirou CNH de Carro!"); }
            else if(modelid == 461) { Pdados[playerid][CNHb] = 1; SendClientMessage(playerid, AMARELO, "Voce tirou CNH de Moto!"); }
            else if(modelid == 498) { Pdados[playerid][CNHc] = 1; SendClientMessage(playerid, AMARELO, "Voce tirou CNH de Caminhao!"); }
            
            autoescola[playerid] = 0;
            autoescolab[playerid] = 0;
            autoescolac[playerid] = 0;
            
            SetPlayerInterior(playerid, 3);
            SetPlayerPos(playerid, 384.8086, 173.8050, 1008.3828);
            return 1;
        }
    }

    // =============================================================================
    // --- SISTEMA DE LIXEIRO ---
    // =============================================================================
    if(lixo[playerid] == 1)
    {
        DisablePlayerRaceCheckpoint(playerid);
        lixo[playerid] = 0;
        GivePlayerMoney(playerid, 70);
        
        if(IsPlayerAttachedObjectSlotUsed(playerid, 0))
            RemovePlayerAttachedObject(playerid, 0);
            
        SendClientMessage(playerid, VERDE, "| LIXEIRO | Coleta feita! Recebeu $70.");
        return 1;
    }

    // =============================================================================
    // --- SISTEMA DE CARRO FORTE ---
    // =============================================================================
    if(carroforte[playerid] == 1)
    {
        if(IsPlayerInRangeOfPoint(playerid, 7.0, 947.5123, -1755.3889, 13.5469))
        {
            DisablePlayerRaceCheckpoint(playerid);
            GivePlayerMoney(playerid, 2000);
            carroforte[playerid] = 0;
            SendClientMessage(playerid, AMARELO, "Rota finalizada! Recebeu $2000.");
            return 1;
        }
    }

    // =============================================================================
    // --- SISTEMA DE PIZZA (IFOOD) ---
    // =============================================================================
    if(Pizzas[playerid] == 1)
    {
        if(modelid == 510) // Bike
        {
            DisablePlayerRaceCheckpoint(playerid);
            Pizzas[playerid] = 0; 
            
            TogglePlayerControllable(playerid, 0);
            SendClientMessage(playerid, -1, "| INFO | Entregando pizza... Aguarde 10 segundos.");
            
            EntregandoPizza[playerid] = SetTimerEx("EntregarPizza", 10000, false, "i", playerid);
            return 1;
        }
        else 
        {
            SendClientMessage(playerid, VERMELHO, "| ERRO | Voce precisa estar na bicicleta de entregas para validar o ponto!");
        }
    }

    return 1;
}


public OnFilterScriptExit()
{
	return 1;
}
public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    if(!CG52Approved[playerid])return 0;
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if(pickupid == agencia) {
	SetPlayerPos(playerid, 358.236206, 163.155456, 1008.382812);
	SetPlayerInterior(playerid, 3);
    if(carregou[playerid] == 0){
	GameTextForPlayer(playerid, "~w~carregando...", 4000, 4);
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("carregando", 4000, true, "i", playerid);
	carregou[playerid] = 1;
	}
    }
    if(pickupid == sairagencia) {
	SetPlayerPos(playerid, 1154.0930,-1770.0237,16.5938);
	SetPlayerInterior(playerid, 0);
    }
    if(pickupid == lac) {
 	SendClientMessage(playerid, azul, "Seja bem vindo a lojinha de acessorios ");
	SetPlayerPos(playerid, -2238.580078,136.913406,1035.414062);
	SetPlayerInterior(playerid, 6);
    if(carregou[playerid] == 0){
	GameTextForPlayer(playerid, "~w~carregando...", 4000, 4);
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("carregando", 4000, true, "i", playerid);
	carregou[playerid] = 1;
	}
    }
    if(pickupid == sairlac) {
	SetPlayerPos(playerid, 1044.663330,-1588.546630,13.550289);
	SetPlayerInterior(playerid, 0);
    }
    if(pickupid == lojadearmas) {
 	SetPlayerPos(playerid, 291.6264,-37.7184,1001.5156);
    SetPlayerInterior(playerid, 1);
    if(carregou[playerid] == 0){
	GameTextForPlayer(playerid, "~w~carregando...", 4000, 4);
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("carregando", 4000, true, "i", playerid);
	carregou[playerid] = 1;
	}
    }
    if(pickupid == sairlojadearmas) {
	SetPlayerPos(playerid, 1364.5251,-1279.2114,13.5469);
    SetPlayerInterior(playerid, 0);
    }
    if(pickupid == shop) {
 	SendClientMessage(playerid, azul, "Seja bem vindo a loja de eletronicos. Aperte H para abrir a loja.");
	SetPlayerPos(playerid, 6.091179,-29.271898,1003.549438);
	SetPlayerInterior(playerid, 10);
	if(carregou[playerid] == 0){
	GameTextForPlayer(playerid, "~w~carregando...", 4000, 4);
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("carregando", 4000, true, "i", playerid);
	carregou[playerid] = 1;
	}
    }
    if(pickupid == sairshop) {
	SetPlayerPos(playerid, 1116.0157,-1607.5891,20.5244);
	SetPlayerInterior(playerid, 0);
    }

	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}
public PlayerToPoint(Float:radi, playerid, Float:x, Float:y, Float:z)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        tempposx = (oldposx -x);
        tempposy = (oldposy -y);
        tempposz = (oldposz -z);
        if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
        {
            return 1;
        }
    }
    return 0;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    // Y abre a mochila.
    if((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        if(IsPlayerInAnyVehicle(playerid))
            return SendClientMessage(playerid, -1, "{FF3030}[Mochila]{FFFFFF} Saia do veiculo para abrir a mochila.");
        return cmd_mochila(playerid, "");
    }

    // N abre o painel de controles do veiculo.
    if((newkeys & KEY_NO) && !(oldkeys & KEY_NO))
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
            return cmd_menuv(playerid);
    }

    // H: uma unica leitura da tecla (KEY_SUBMISSION). Evita conflito/delay entre casa, caixa e interiores.
    if((newkeys & KEY_SUBMISSION) && !(oldkeys & KEY_SUBMISSION))
    {
        new mundo = GetPlayerVirtualWorld(playerid);
        new interior = GetPlayerInterior(playerid);

        // HOSPITAIS CRIAVEIS: H entra e H sai.
        if(mundo >= VW_HOSPITAIS_BCG && mundo < VW_HOSPITAIS_BCG + MAX_HOSPITAIS_BCG && interior == 3)
        {
            new hospitalSaida = mundo - VW_HOSPITAIS_BCG;
            if(hospitalSaida >= 0 && hospitalSaida < MAX_HOSPITAIS_BCG && HospitalBCG[hospitalSaida])
            {
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, HospitalXBCG[hospitalSaida], HospitalYBCG[hospitalSaida], HospitalZBCG[hospitalSaida]);
                SetPlayerFacingAngle(playerid, HospitalABCG[hospitalSaida]);
                SendClientMessage(playerid, 0x00FF00FF, "[HOSPITAL] Voce saiu do hospital.");
                return 1;
            }
        }

        if(interior == 0 && mundo == 0)
        {
            new hospitalEntrada = BCG_HospitalProximo(playerid, 12.0);
            if(hospitalEntrada != -1)
            {
                SetPlayerPos(playerid, 367.8871, 162.2342, 1025.7891);
                SetPlayerInterior(playerid, 3);
                SetPlayerVirtualWorld(playerid, VW_HOSPITAIS_BCG + hospitalEntrada);
                SendClientMessage(playerid, 0x00BFFFFF, "[HOSPITAL] Voce entrou no hospital. Aperte H para sair.");
                return 1;
            }
        }

        // LANCHONETES: H entra/sai.
        if(g_LanchoneteAtiva[playerid] && mundo == VW_LANCHONETES_BCG + g_LanchoneteAtual[playerid])
        {
            BCG_SairLanchonete(playerid);
            return 1;
        }

        if(interior == 0 && mundo == 0)
        {
            new lanchonete = BCG_VerificarLanchonete(playerid);
            if(lanchonete != -1)
            {
                BCG_EntrarLanchonete(playerid, lanchonete);
                return 1;
            }
        }

        // LOJAS NATIVAS DO GTA: H entra/sai.
        if(g_LojaGTAInicializada[playerid] && mundo == VW_LOJAS_GTA_BCG + g_LojaGTAAtual[playerid])
        {
            BCG_SairLojaGTA(playerid);
            return 1;
        }

        if(interior == 0 && mundo == 0)
        {
            new lojaGTA = BCG_VerificarEntradaLojaGTA(playerid);
            if(lojaGTA != -1)
            {
                BCG_EntrarLojaGTA(playerid, lojaGTA);
                return 1;
            }
        }

        // 1) Se estiver dentro de uma casa do sistema, sai imediatamente.
        if(mundo >= 1000 && mundo < 1000 + MAX_CASAS_BCG)
        {
            new casa = mundo - 1000;
            if(casa >= 0 && casa < MAX_CASAS_BCG && CasaExisteBCG[casa])
            {
                SetPlayerInterior(playerid, 0);
                SetPlayerVirtualWorld(playerid, 0);
                SetPlayerPos(playerid, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa]);
                SendClientMessage(playerid, 0x00FF00FF, "[CASA] Voce saiu da casa.");
                return 1;
            }
        }

        // 2) CASA: H entra pela porta. Nao depende de pickup e usa uma
        // distancia maior para evitar que o jogador precise ficar exatamente no ponto.
        // Fora de uma casa, procuramos sempre a casa mais proxima.
        if(interior == 0 && mundo == 0)
        {
            new casa = BCG_CasaProxima(playerid, 12.0);
            if(casa != -1)
            {
                // O H usa as mesmas regras do /casa: somente dono ou inquilino entra.
                if(strlen(CasaDonoBCG[casa]) > 0 &&
                   strcmp(CasaDonoBCG[casa], Nome(playerid), true) != 0 &&
                   strcmp(CasaInquilinoBCG[casa], Nome(playerid), true) != 0)
                    return SendClientMessage(playerid, 0xFF3030FF, "[CASA] Esta casa possui dono. Voce nao tem acesso.");

                BCG_SetPosInteriorCasa(playerid, casa);
                SendClientMessage(playerid, 0x00FF00FF, "[CASA] Voce entrou na casa. Aperte H ou use /casa para sair.");
                return 1;
            }
        }

        // 3) Caixa eletronico: abre no mesmo toque do H, sem timer e sem segunda verificacao.
        if(BCG_CaixaEletronicoProximo(playerid, 3.8) != -1 || BCG_EhCaixaFixo(playerid))
        {
            BCG_UsarCaixaEletronico(playerid);
            return 1;
        }

        // 4) Entradas externas comuns.
        if(interior == 0 && IsPlayerInRangeOfPoint(playerid, 3.8, 1154.0011, -1772.6776, 16.5992))
        {
            SetPlayerPos(playerid, 358.236206, 163.155456, 1008.382812);
            SetPlayerInterior(playerid, 3);
            SetPlayerVirtualWorld(playerid, 0);
            SendClientMessage(playerid, azul, "Voce entrou na Agencia de Empregos. Aperte H para sair.");
            return 1;
        }
        if(interior == 0 && IsPlayerInRangeOfPoint(playerid, 3.8, 1047.106689, -1589.145874, 13.512354))
        {
            SetPlayerPos(playerid, -2238.580078, 136.913406, 1035.414062);
            SetPlayerInterior(playerid, 6);
            SetPlayerVirtualWorld(playerid, 0);
            SendClientMessage(playerid, azul, "Seja bem vindo a loja de acessorios. Aperte H para sair.");
            return 1;
        }
        if(interior == 0 && IsPlayerInRangeOfPoint(playerid, 3.8, 1368.2789, -1279.7478, 13.5469))
        {
            SetPlayerPos(playerid, 291.6264, -37.7184, 1001.5156);
            SetPlayerInterior(playerid, 1);
            SetPlayerVirtualWorld(playerid, 0);
            SendClientMessage(playerid, azul, "Voce entrou na loja de armas. Aperte H para sair.");
            return 1;
        }
        if(interior == 0 && IsPlayerInRangeOfPoint(playerid, 3.8, 1115.9543, -1603.2955, 20.5622))
        {
            SetPlayerPos(playerid, 6.091179, -29.271898, 1003.549438);
            SetPlayerInterior(playerid, 10);
            SetPlayerVirtualWorld(playerid, 0);
            SendClientMessage(playerid, azul, "Voce entrou na loja de equipamentos. Aperte H para abrir a loja.");
            return 1;
        }

        // 5) Saidas internas.
        if(interior == 3 && IsPlayerInRangeOfPoint(playerid, 3.8, 1494.3737, 1303.8629, 1093.2891))
        {
            SetPlayerPos(playerid, 1154.0930, -1770.0237, 16.5938);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            return 1;
        }
        if(interior == 6 && IsPlayerInRangeOfPoint(playerid, 3.8, -2240.781250, 137.165557, 1035.414062))
        {
            SetPlayerPos(playerid, 1044.663330, -1588.546630, 13.550289);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            return 1;
        }
        if(interior == 1 && IsPlayerInRangeOfPoint(playerid, 3.8, 285.3889, -41.1661, 1001.5156))
        {
            SetPlayerPos(playerid, 1364.5251, -1279.2114, 13.5469);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            return 1;
        }
        if(interior == 10 && IsPlayerInRangeOfPoint(playerid, 3.8, 6.0088, -31.1886, 1003.5494))
        {
            SetPlayerPos(playerid, 1116.0157, -1607.5891, 20.5244);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            return 1;
        }

        // H dentro da loja abre o menu.
        if(interior == 10 && IsPlayerInRangeOfPoint(playerid, 3.8, 2.8274, -29.0144, 1003.5494))
        {
            BCG_AbrirLoja(playerid);
            return 1;
        }
    }

    // SAIR DO /CRACK COM A TECLA F / ENTER
    if ((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK))
    {
        if (g_PlayerCrack[playerid])
        {
            ClearAnimations(playerid);
            TogglePlayerControllable(playerid, true);
            g_PlayerCrack[playerid] = false;
            SendClientMessage(playerid, 0x00FF00FF, "[CRACK] Voce levantou.");
            return 1;
        }
    }

    // ALUGAR QUAD NO SPAWN - tecla H
    if((newkeys & KEY_CTRL_BACK) && !(oldkeys & KEY_CTRL_BACK))
    {
        if(IsPlayerInRangeOfPoint(playerid, 5.0, 1675.535278, -2311.576660, 13.547585))
        {
            if(IsPlayerInAnyVehicle(playerid))
                return SendClientMessage(playerid, 0xFF3030FF, "[ALUGUEL] Saia do veiculo antes de alugar um Quad.");

            if(VeiculoPlayer[playerid] != 0)
            {
                DestroyVehicle(VeiculoPlayer[playerid]);
                VeiculoPlayer[playerid] = 0;
            }

            new Float:a;
            GetPlayerFacingAngle(playerid, a);
            new quad = CreateVehicle(471, 1678.0, -2311.5, 13.55, a, 3, 3, 300);
            if(quad == INVALID_VEHICLE_ID)
                return SendClientMessage(playerid, 0xFF3030FF, "[ALUGUEL] Nao foi possivel criar o Quad.");

            VeiculoPlayer[playerid] = quad;
            LatariaHealth[quad] = 1000.0;
            LatariaPanels[quad] = 0;
            LatariaDoors[quad] = 0;
            LatariaLights[quad] = 0;
            LatariaTires[quad] = 0;
            SetVehicleHealth(quad, 1000.0);
            PutPlayerInVehicle(playerid, quad, 0);
            SendClientMessage(playerid, 0x00FF00FF, "[ALUGUEL] Quad alugado! Use /lataria para ver o estado.");
            return 1;
        }
    }

    ProcessarTeclaRotaGangster(playerid, newkeys);
    ProcessarCliquesDesmanche(playerid, newkeys);
    if(ProcessarTeclaFabricaArmas(playerid, newkeys)) return 1;
    TratarTeclaMorte(playerid, newkeys, oldkeys);
    
    // --- Tecla de Agachar (KEY_CROUCH) ---
    if ((newkeys & KEY_CROUCH) && !(oldkeys & KEY_CROUCH)) 
    {
        // Pedagio 1
        if (IsPlayerInRangeOfPoint(playerid, 8.0, 1739.4037, 504.8039, 28.8814))
        {
            if (GetPlayerMoney(playerid) >= 15)
            {
                MoveObject(portao1, 1741.1000, 509.2000, 24.0, 3.0);
                SetTimerEx("GateClose", 5000, false, "i", portao1);
                SendClientMessage(playerid, branco, "Pedagio pago, custou $15 reais. Boa viagem.");
            }
            else
            {
                SendClientMessage(playerid, vermelho, "Voce nao tem $15 para pagar o pedagio.");
            }
        }
        // Pedagio 2
        else if (IsPlayerInRangeOfPoint(playerid, 8.0, 1731.8717, 523.4805, 28.0227))
        {
            if (GetPlayerMoney(playerid) >= 15)
            {
                MoveObject(portao2, 1730.6000, 519.0000, 24.0, 3.0);
                SetTimerEx("GateClose", 5000, false, "i", portao2);
                SendClientMessage(playerid, branco, "Pedagio pago, custou $15 reais. Boa viagem.");
            }
            else
            {
                SendClientMessage(playerid, vermelho, "Voce nao tem $15 para pagar o pedagio.");
            }
        }
    }

    // --- TECLA H: interiores, garagens, lojas e demais entradas ---
    if ((newkeys & KEY_SUBMISSION) && !(oldkeys & KEY_SUBMISSION)) 
    { 
        for(new i = 0; i < MAX_SPAWN_BIKES; i++)
        {
            if(SpawnBikeInfo[i][spAtivo] && IsPlayerInRangeOfPoint(playerid, 4.0, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ]))
            {
                RealizarPegarBike(playerid);
                return 1;
            }
        }

        // Sistema de Garagem de Org Dinâmico (Estilo FiveM - Lista apenas os veículos criados da org)
        new player_org_check = Pdados[playerid][OrgID];
        if(player_org_check > 0)
        {
            new achou_garagem = 0;
            for(new s = 0; s < MAX_VEHS_PER_ORG; s++)
            {
                if(OrgVehicles[player_org_check][s][ovCriado])
                {
                    if(IsPlayerInRangeOfPoint(playerid, 3.0, OrgVehicles[player_org_check][s][ovSpawnX], OrgVehicles[player_org_check][s][ovSpawnY], OrgVehicles[player_org_check][s][ovSpawnZ]))
                    {
                        new list_str[256], nome_veiculo[32];
                        
                        for(new i = 0; i < MAX_VEHS_PER_ORG; i++)
                        {
                            if(OrgVehicles[player_org_check][i][ovCriado])
                            {
                                GetVehicleName(OrgVehicles[player_org_check][i][ovSpawnID], nome_veiculo, sizeof(nome_veiculo));
                                
                                if(strlen(nome_veiculo) <= 1)
                                {
                                    format(nome_veiculo, sizeof(nome_veiculo), "Veículo ID: %d", OrgVehicles[player_org_check][i][ovModelID]);
                                }
                                
                                format(list_str, sizeof(list_str), "%s%s\n", list_str, nome_veiculo);
                            }
                        }
                        
                        SetPVarInt(playerid, "OrgMenuAtiva", player_org_check);
                        ShowPlayerDialog(playerid, DIALOG_MENU_ORG_VEH, DIALOG_STYLE_LIST, "{00FFFF}Garagem da Corp/Org", list_str, "Retirar", "Fechar");
                        achou_garagem = 1;
                        break;
                    }
                }
            }
            if(achou_garagem) return 1;
        }

        if(!IsPlayerInAnyVehicle(playerid))
        {
            if(IsPlayerInRangeOfPoint(playerid, 5.0, CONCE_LOCAL_X, CONCE_LOCAL_Y, CONCE_LOCAL_Z))
            {
                AbrirMenuConcessionaria(playerid);
                return 1;
            }
        }
        
        new org = Pdados[playerid][OrgID];
        if(org > 0 && LocalEquipar[org][lcCriado])
        {
            if(IsPlayerInRangeOfPoint(playerid, 3.0, LocalEquipar[org][lcX], LocalEquipar[org][lcY], LocalEquipar[org][lcZ]))
            {
                if(org >= 1 && org <= 12)
                {
                    cmd_farda(playerid, "");
                }
                cmd_equipar(playerid, "");
                return 1;
            }
        }
        
        // Licencas
        if (IsPlayerInRangeOfPoint(playerid, 1.0, 361.867340, 173.422683, 1008.382812))
        {
            ShowPlayerDialog(playerid, DIALOG_LICENCA, DIALOG_STYLE_INPUT, "{FFFF00}Licencas", "{4CBB17}1 - {FFFFFF}Habilitacao carro\t{4CBB17}$5000\n2 - {FFFFFF}Habilitacao moto\t{4CBB17}$3000\n3 - {FFFFFF}Habilitacao caminhao\t{4CBB17}$8000\n4 - {FFFFFF}Porte de armas\t{4CBB17}$80000", "{FFFFFF}Aceitar", "{FFFFFF}Cancelar");
        }
        // Empregos
        else if (IsPlayerInRangeOfPoint(playerid, 1.0, 358.236206, 163.155456, 1008.382812))
        {
            ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_INPUT, "Agencia de empregos", "{FFFFFF}1 - Entregador de pizza\n{FFFFFF}2 - Tecnico de Internet\n{FFFFFF}3 - Caminhoneiro\n{FFFFFF}4 - Motorista\n{FFFFFF}5 - Entregador de revista\n{FFFFFF}6 - Taxista\n{FFFFFF}7 - Transportador de Cimento\n{FFFFFF}8 - Lixeiro\n{FFFFFF}9 - Transportador de valores\n{FFFFFF}10 - Ifood", "Selecionar", "Cancelar");
        }
        // banco pref LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2311.636962, -3.778552, 26.742187) || IsPlayerInRangeOfPoint(playerid, 2.0, 358.386749, 183.878906, 1008.382812))
        {
            ShowPlayerDialog(playerid, DIALOG_BANCO, DIALOG_STYLE_LIST, "Banco", "Sacar\nDepositar\nSaldo", "Selecionar", "Cancelar");
        }
        // Entrar na Loja de Roupas
        else if (IsPlayerInRangeOfPoint(playerid, 1.0, 1072.307495, -1221.322021, 16.890625))
        {
            SetPlayerPos(playerid, 204.332992, -166.694992, 1000.523437);
            SetPlayerInterior(playerid, 14);
        }
        // Sair da Loja de Roupas
        else if (IsPlayerInRangeOfPoint(playerid, 1.0, 204.332992, -166.694992, 1000.523437))
        {
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, 1072.307495, -1221.322021, 16.890625);
        }
        // Entrada Hotel
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2233.1541, -1159.7782, 25.8902)) 
        {
            SetPlayerPos(playerid, 2210.61, 1866.45, -68.63);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 333);
        }
        
        // ==========================================
        // SISTEMA INTEGRADO DE ENTRADAS - DP LS
        // ==========================================
        
        // Entrada DP LS PRINCIPAL
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1555.499877, -1675.593994, 16.195312)) 
        {
            OrigemEntrada[playerid] = 1; // Grava que entrou pela principal
            SetPlayerPos(playerid, 246.66, 65.80, 1003.64);
            SetPlayerInterior(playerid, 6);
        }
        // Entrada DP LS SECUNDaRIA
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 323.655883, -1517.129394, 36.039062)) 
        {
            OrigemEntrada[playerid] = 2; // Grava que entrou pela secundaria
            SetPlayerPos(playerid, 246.66, 65.80, 1003.64); // Vai para o MESMO interior
            SetPlayerInterior(playerid, 6);
        }
        
        // ==========================================
        
        // Entrada DP SF
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, -1605.560180, 710.272521, 13.867187)) 
        {
            SetPlayerPos(playerid, 246.06, 108.97, 1003.21);
            SetPlayerInterior(playerid, 10);        
        }
        // Entrada DP LV
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2290.146484, 2432.084960, 10.820312)) 
        {
            SetPlayerPos(playerid, 288.47, 170.06, 1007.17);
            SetPlayerInterior(playerid, 3);
        }
        // Entrada Detran LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2895.918457, -848.660583, 10.875000)) 
        {
            SetPlayerPos(playerid, 354.1271, 168.0593, 1020.0844);
            SetPlayerInterior(playerid, 3);
            SetPlayerVirtualWorld(playerid, 333);
        }
        // Entrada Cadeia
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1797.410156, -1578.759765, 14.083669)) 
        {
            SetPlayerPos(playerid, 965.0224, 2107.7881, 1011.0303);
            SetPlayerInterior(playerid, 1);
            SetPlayerVirtualWorld(playerid, 333);
        }
        // Entrada Gov LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1123.3267, -2037.0034, 69.8874)) 
        {
            SetPlayerPos(playerid, 231.5619, 2348.3682, 1017.4250);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 333);
        }
        // Entrada Loterica
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1631.8076, -1172.9432, 24.0871)) 
        {
            SetPlayerPos(playerid, 834.8356, 7.4374, 1004.1536);
            SetPlayerInterior(playerid, 3);
        }
        // Entrada Aeroporto LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1642.318847, -2286.573242, -1.143215)) 
        {
            SetPlayerPos(playerid, -1861.813964, 84.343452, 1055.192260);
            SetPlayerInterior(playerid, 0);
        }
        // Prefeitura LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1481.1603, -1772.3116, 18.7958)) 
        {
            SetPlayerInterior(playerid, 3);
            SetPlayerFacingAngle(playerid, 86.134811);
            SetPlayerPos(playerid, 390.7675, 173.7833, 1008.3828);
        }
        // Banco LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1310.2577, -1366.7959, 13.5066)) 
        {
            SetPlayerInterior(playerid, 32);
            SetPlayerFacingAngle(playerid, 268.125976);
            SetPlayerPos(playerid, 1412.589477, -4.538511, 1000.885131);
        }
        // Mineradora LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 445.8445, -850.0399, 29.8050)) 
        {
            SetPlayerPos(playerid, 440.1284, -856.8886, 2.7160);
            SetPlayerInterior(playerid, 0);
        }
        // Auto Escola
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1411.6307, -1699.4390, 13.5395)) 
        {
            SetPlayerPos(playerid, 819.6603, -510.0458, 996.6475);
            SetPlayerInterior(playerid, 0);
        }
        // DP LS DESCIDA
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 246.389358, 88.009361, 1003.640625)) 
        {
            SetPlayerPos(playerid, 1568.593872, -1689.975341, 6.218750);
            SetPlayerInterior(playerid, 0);
        }
        // DP LS SUBIDA
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1568.593872, -1689.975341, 6.218750)) 
        {
            SetPlayerPos(playerid, 246.389358, 88.009361, 1003.640625);
            SetPlayerInterior(playerid, 0);
        }
        // DP SF DESCIDA
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 213.975296, 118.895988, 1003.218750)) 
        {
            SetPlayerPos(playerid, -1616.315673, 687.561035, 7.187500);
            SetPlayerInterior(playerid, 0);
        }
        // DP SF SUBIDA
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, -1616.315673, 687.561035, 7.187500)) 
        {
            SetPlayerPos(playerid, 213.975296, 118.895988, 1003.218750);
            SetPlayerInterior(playerid, 0);
        }
        // Saida Cadeia
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 965.0224, 2107.7881, 1011.0303)) 
        {
            SetPlayerPos(playerid, 1797.410156, -1578.759765, 14.083669);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida DP SF
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 246.420715, 107.305999, 1003.218750)) 
        {
            SetPlayerPos(playerid, -1605.560180, 710.272521, 13.867187);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida Hotel
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 2210.61, 1866.45, -68.63)) 
        {
            SetPlayerPos(playerid, 2233.1541, -1159.7782, 25.8902);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida Detran
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 354.1271, 168.0593, 1020.0844)) 
        {
            SetPlayerPos(playerid, 2895.918457, -848.660583, 10.875000);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida DP LV
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 288.859375, 166.923309, 1007.171875)) 
        {
            SetPlayerPos(playerid, 2290.146484, 2432.084960, 10.820312);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida Academia
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 772.4014, -5.2436, 1000.7128)) 
        {
            SetPlayerPos(playerid, 2229.6052, -1721.5137, 13.6361);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida Gov LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 231.5619, 2348.3682, 1017.4250)) 
        {
            SetPlayerPos(playerid, 1123.3267, -2037.0034, 69.8874);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida Loterica LS
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 834.8356, 7.4374, 1004.1536)) 
        {
            SetPlayerPos(playerid, 1631.8076, -1172.9432, 24.0871);
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
        }
        // Saida Aeroporto SF
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, -1861.813964, 84.343452, 1055.192260)) 
        {
            SetPlayerPos(playerid, 1642.318847, -2286.573242, -1.143215);
            SetPlayerInterior(playerid, 0);
        }
        // Saida Prefeitura
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 390.7675, 173.7833, 1008.3828))
        {
            SetPlayerPos(playerid, 1481.1603, -1772.3116, 18.7958);
            SetPlayerInterior(playerid, 0);
        }
        // Saida Banco
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 1412.589477, -4.538511, 1000.885131))
        {
            SetPlayerPos(playerid, 1310.2577, -1366.7959, 13.5066);
            SetPlayerInterior(playerid, 0);
        }
        // Saida Banco Cofre
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, -175.142059, 3043.080810, 24.155199))
        {
            SetPlayerPos(playerid, 1394.771850, -10.152928, 1000.885131);
        }
        // Saida Mineradora
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 440.1284, -856.8886, 2.7160))
        {
            SetPlayerPos(playerid, 445.8445, -850.0399, 29.8050);
            SetPlayerInterior(playerid, 0);
        }
        // Saida Auto Escola
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 819.6603, -510.0458, 996.6475))
        {
            SetPlayerPos(playerid, 1411.6307, -1699.4390, 13.5395);
            SetPlayerInterior(playerid, 0);
        }
        
        // ==========================================
        // SAiDA DINaMICA DA DP LS (CORRIGIDA)
        // ==========================================
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, 246.844345, 62.320240, 1003.640625))
        {
            if(OrigemEntrada[playerid] == 1)
            {
                SetPlayerPos(playerid, 1555.501831, -1675.520019, 16.195312);
                SetPlayerInterior(playerid, 0);
            }
            else if(OrigemEntrada[playerid] == 2)
            {
                SetPlayerPos(playerid, 323.655883, -1517.129394, 36.039062);
                SetPlayerInterior(playerid, 0);
            }
            else
            {
                SetPlayerPos(playerid, 1555.501831, -1675.520019, 16.195312);
                SetPlayerInterior(playerid, 0);
            }
            
            OrigemEntrada[playerid] = 0;
        }
        // ==========================================
        
        // Outro Ponto de Teleporte
        else if (IsPlayerInRangeOfPoint(playerid, 2.0, -1542.789916, -668.883361, 801.743896))
        {
            SetPlayerPos(playerid, 2151.120849, -1013.906066, 62.732738);
            SetPlayerInterior(playerid, 0);
        }
    }
    return 1;
}


public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
    new idPortao = PlayerEditandoPortaoID[playerid];
    
    if(idPortao != -1 && objectid == PortaoInfo[idPortao][pObjetoID])
    {
        if(response == EDIT_RESPONSE_CANCEL)
        {
            if(IsValidObject(PortaoInfo[idPortao][pObjetoID])) DestroyObject(PortaoInfo[idPortao][pObjetoID]);
            PortaoInfo[idPortao][pCriado] = false;
            PlayerEditandoPortaoID[playerid] = -1;
            SendClientMessage(playerid, 0xFF0000FF, "[Portao]: Criacao cancelada.");
            return 1;
        }

        if(response == EDIT_RESPONSE_FINAL)
        {
            PortaoInfo[idPortao][pX] = fX;
            PortaoInfo[idPortao][pY] = fY;
            PortaoInfo[idPortao][pZ] = fZ;
            PortaoInfo[idPortao][pRotX] = fRotX;
            PortaoInfo[idPortao][pRotY] = fRotY;
            PortaoInfo[idPortao][pRotZ] = fRotZ;

            ShowPlayerDialog(playerid, DIALOG_SENHA_PORTAO, DIALOG_STYLE_INPUT, "Configuracao do Portao", "Insira a senha para terminar a criacao:", "Confirmar", "Cancelar");
        }
    }
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}


new os[MAX_PLAYERS];

// ============================================================================
// ANTI-CHEAT BCG - protecao server-side contra armas/municao/vida/colete
// As verificacoes abaixo focam apenas em situacoes claramente impossiveis,
// evitando expulsar jogadores por teleporte legitimo do proprio GM.
// ============================================================================
new BCG_AC_UltimaArma[MAX_PLAYERS];
new BCG_AC_UltimaMunicao[MAX_PLAYERS];
new BCG_AC_Alertas[MAX_PLAYERS];
new BCG_AC_UltimoAlerta[MAX_PLAYERS];


// V37 - Central de suspeitas anti-cheat (somente alerta administracao)
new BCG_AC_Suspeitas[MAX_PLAYERS];
new BCG_AC_LastWarnTick[MAX_PLAYERS];
new Float:BCG_AC_LastX[MAX_PLAYERS], Float:BCG_AC_LastY[MAX_PLAYERS], Float:BCG_AC_LastZ[MAX_PLAYERS];
new BCG_AC_LastPosTick[MAX_PLAYERS];
new BCG_AC_LastDamageTick[MAX_PLAYERS];
new BCG_AC_RapidHits[MAX_PLAYERS];
new BCG_AC_Hits[MAX_PLAYERS];
new BCG_AC_HeadHits[MAX_PLAYERS];

stock BCG_AC_AlertarAdmins(playerid, tipo[], detalhe[])
{
    if(!IsPlayerConnected(playerid) || Pdados[playerid][Admin] >= 8) return 1;
    new agora = GetTickCount();
    // Evita spam do mesmo jogador no chat ADM.
    if(agora - BCG_AC_LastWarnTick[playerid] < 2500) return 1;
    BCG_AC_LastWarnTick[playerid] = agora;
    BCG_AC_Suspeitas[playerid]++;
    new aviso[220];
    format(aviso, sizeof aviso, "{FF3030}[ANTI-CHEAT] {FFFFFF}Suspeita: %s [IDF:%d] | %s | %s | nivel %d", Nome(playerid), BCG_IDFixo[playerid], tipo, detalhe, BCG_AC_Suspeitas[playerid]);
    for(new a = 0; a < MAX_PLAYERS; a++)
    {
        if(IsPlayerConnected(a) && Pdados[a][Admin] > 0) SendClientMessage(a, -1, aviso);
    }
    return 1;
}

stock BCG_AC_MonitorarMovimento(playerid)
{
    if(!IsPlayerConnected(playerid) || Pdados[playerid][Admin] >= 8) return 1;
    if(Pdados[playerid][Admin] > 0 && Pdados[playerid][Trabalhando]) return 1;
    new agora = GetTickCount();
    if(agora - BCG_AC_LastPosTick[playerid] < 1000) return 1;
    new Float:x, Float:y, Float:z, Float:vx, Float:vy, Float:vz;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerVelocity(playerid, vx, vy, vz);
    if(BCG_AC_LastPosTick[playerid] != 0)
    {
        new Float:dx = x - BCG_AC_LastX[playerid];
        new Float:dy = y - BCG_AC_LastY[playerid];
        new Float:dist = floatsqroot(dx*dx + dy*dy);
        if(!IsPlayerInAnyVehicle(playerid) && dist > 85.0)
            BCG_AC_AlertarAdmins(playerid, "TELEPORT/AIRBREAK", "deslocamento anormal em 1 segundo");
        if(!IsPlayerInAnyVehicle(playerid) && (floatabs(vx) > 1.25 || floatabs(vy) > 1.25 || floatabs(vz) > 1.10))
            BCG_AC_AlertarAdmins(playerid, "SPEED/FLY", "velocidade anormal a pe");
    }
    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
        BCG_AC_AlertarAdmins(playerid, "JETPACK", "jetpack detectado fora do cargo 8");
    BCG_AC_LastX[playerid]=x; BCG_AC_LastY[playerid]=y; BCG_AC_LastZ[playerid]=z;
    BCG_AC_LastPosTick[playerid]=agora;
    return 1;
}

stock BCG_AntiCheat(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;

    // Administracao: cargo 8+ tem bypass total. /deus usa vida alta de forma legitima,
    // portanto admins em modo trabalho nao podem ser marcados como GodMode.
    if(Pdados[playerid][Admin] >= 8) return 1;

    new weapon = GetPlayerWeapon(playerid);
    new ammo = GetPlayerAmmo(playerid);
    new Float:vida, Float:colete;
    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, colete);

    // Armas que o servidor proibiu: remove imediatamente.
    if(weapon == 16 || weapon == 17 || weapon == 18 || weapon == 35 ||
       weapon == 36 || weapon == 37 || weapon == 38 || weapon == 39 || weapon == 40)
    {
        ResetPlayerWeapons(playerid);
        BCG_AC_Alertas[playerid]++;
        BCG_AC_AlertarAdmins(playerid, "WEAPON HACK", "arma proibida detectada");
        if(GetTickCount() - BCG_AC_UltimoAlerta[playerid] > 3000)
        {
            BCG_AC_UltimoAlerta[playerid] = GetTickCount();
            SendClientMessage(playerid, VERMELHO, "[ANTI-CHEAT] Arma proibida detectada e removida.");
        }
        return 1;
    }

    // Vida/colete acima do limite normal: corrige sem matar o jogador.
    if(vida > 100.0 && !(Pdados[playerid][Admin] > 0 && Pdados[playerid][Trabalhando] && Pdados[playerid][Imortal]))
    {
        SetPlayerHealth(playerid, 100.0);
        BCG_AC_Alertas[playerid]++;
        BCG_AC_AlertarAdmins(playerid, "GODMODE/HEALTH", "vida acima de 100");
    }
    if(colete > 100.0)
    {
        SetPlayerArmour(playerid, 100.0);
        BCG_AC_Alertas[playerid]++;
        BCG_AC_AlertarAdmins(playerid, "ARMOUR HACK", "colete acima de 100");
    }

    // Municao absurdamente alta. O limite e propositalmente alto para nao
    // interferir nos kits existentes do GM.
    if(weapon >= 2 && weapon <= 46 && weapon != 40 && ammo > 2000)
    {
        SetPlayerAmmo(playerid, weapon, 0);
        BCG_AC_Alertas[playerid]++;
        if(GetTickCount() - BCG_AC_UltimoAlerta[playerid] > 3000)
        {
            BCG_AC_UltimoAlerta[playerid] = GetTickCount();
            SendClientMessage(playerid, VERMELHO, "[ANTI-CHEAT] Municao irregular detectada e removida.");
        }
        return 1;
    }

    BCG_AC_UltimaArma[playerid] = weapon;
    BCG_AC_UltimaMunicao[playerid] = ammo;
    return 1;
}

stock BCG_RemoverArmasExplosivas(playerid)
{
    // Granada, gas lacrimogeneo, molotov, bazuca, heat-seeker, satchel e detonador.
    SetPlayerAmmo(playerid, 16, 0);
    SetPlayerAmmo(playerid, 17, 0);
    SetPlayerAmmo(playerid, 18, 0);
    SetPlayerAmmo(playerid, 35, 0);
    SetPlayerAmmo(playerid, 36, 0);
    SetPlayerAmmo(playerid, 37, 0);
    SetPlayerAmmo(playerid, 39, 0);
    SetPlayerAmmo(playerid, 40, 0);

    new armaAtual = GetPlayerWeapon(playerid);
    if(armaAtual == 16 || armaAtual == 17 || armaAtual == 18 ||
       armaAtual == 35 || armaAtual == 36 || armaAtual == 37 || armaAtual == 39 || armaAtual == 40)
    {
        SetPlayerArmedWeapon(playerid, 0);
    }
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if(!CG52Approved[playerid])return 0;
    // Camada moderna: HUD/estado sem alterar a logica antiga do gamemode.
    BCG_ModernTick(playerid);

    // Se o jogador estiver desconectado por milissegundos, evita crash
    if(!IsPlayerConnected(playerid)) return 1;
    BCGV4_AntiCheatTick(playerid);

    // Cargo 8 pode portar qualquer arma. Demais jogadores passam pelo anti-cheat.
    if(Pdados[playerid][Admin] < 8)
    {
        BCG_RemoverArmasExplosivas(playerid);
        BCG_AntiCheat(playerid);
        BCG_AC_MonitorarMovimento(playerid);
    }

    new Float:a, Float:x, Float:y, Float:z, m, s, hr;
    gettime(hr, m, s);
    hr++;
    SetPlayerTime(playerid, hr, m);

    // Posicao e Algemas
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    
    if(Pdados[playerid][Algemado] == true)
    {
        SetPlayerPos(playerid, x, y, z);
    }

    // =========================================================================
    // --- DETECcaO DE TIROS DIRETA (OnPlayerUpdate) ---
    // =========================================================================
    new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);
    
    // Se apertou o botao de atirar e esta com uma arma na mao (ID > 0) que nao seja camera/extintor/faca
    new armaAtual = GetPlayerWeapon(playerid);
    if((keys & KEY_FIRE) && armaAtual > 0 && armaAtual != 1 && armaAtual != 43 && armaAtual != 42)
    {
        static lastShotTime[MAX_PLAYERS];
        new currentTime = GetTickCount();
        
        // Cooldown de 3 segundos para nao inundar o chat de mensagens enquanto atira no automatico
        if(currentTime - lastShotTime[playerid] > 3000) 
        {
            lastShotTime[playerid] = currentTime;

            new msgTiro[145], nomeAtirador[MAX_PLAYER_NAME];
            GetPlayerName(playerid, nomeAtirador, sizeof(nomeAtirador));

            format(msgTiro, sizeof(msgTiro), "{FF0000}[ALERTA DISPARO] {FFFFFF}O cidadao %s efetuou disparos! Local marcado no mapa.", nomeAtirador);

            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(IsPlayerConnected(i))
                {
                    new playerNome[MAX_PLAYER_NAME];
                    GetPlayerName(i, playerNome, sizeof(playerNome));

                    // REGRAS DE TESTE PARA VOCe (Lipee_fxp1): 
                    // Voce sempre vai receber, mesmo que seja voce mesmo quem atirou sozinho no servidor!
                    if(strcmp(playerNome, "Lipee_fxp1", true) == 0)
                    {
                        SendClientMessage(i, -1, msgTiro);
                        SetPlayerCheckpoint(i, x, y, z, 6.0);
                        SendClientMessage(i, -1, "{F1C40F}[DEBUG OWNER] {FFFFFF}Alerta de disparo recebido pelo sistema OnPlayerUpdate!");
                        continue;
                    }

                    // Se for o proprio atirador comum (nao voce), pula ele mesmo
                    if(i == playerid) continue;

                    // Filtro para os policiais reais (Org 1 a 12 fardados)
                    if(Pdados[i][OrgID] >= 1 && Pdados[i][OrgID] <= 12)
                    {
                        if(Pdados[i][Farda] == true) 
                        {
                            SendClientMessage(i, -1, msgTiro);
                            SetPlayerCheckpoint(i, x, y, z, 6.0);
                        }
                    }
                }
            }
        }
    }
    // =========================================================================

    // Verificacao de Veiculo
    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(!IsAbicycle(vehicleid))
        {
            new Float:health;
            GetVehicleHealth(vehicleid, health);

            // --- Logica de Danos Unificada ---
            if(health < 900)
            {
                // CORREcaO: Usando a nossa variavel estavel para desligar o motor se o carro quebrar
                if(MotorLigado[vehicleid] == true)
                {
                    new motor, farois, alarme, doors, bonnet, boot, obj;
                    GetVehicleParamsEx(vehicleid, motor, farois, alarme, doors, bonnet, boot, obj);
                    
                    MotorLigado[vehicleid] = false; // Desliga no nosso sistema
                    SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, farois, alarme, doors, bonnet, boot, obj);
                    SendClientMessage(playerid, VERMELHO, "{00BFFF}BCG: Esse veiculo esta muito danificado e o motor morreu!");
                }
            }
            if(health < 250)
            {
                SetVehicleHealth(vehicleid, 300.0);
                new engine, lights, alarm, v_doors, v_bonnet, v_boot, objective;
                GetVehicleParamsEx(vehicleid, engine, lights, alarm, v_doors, v_bonnet, v_boot, objective);
                
                MotorLigado[vehicleid] = false; // Garante desligado
                SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, v_doors, v_bonnet, v_boot, objective);
                GameTextForPlayer(playerid, "~r~QUEBRADO", 3000, 3);
            }

            // --- Atualizacao do Velocimetro Visual ---
            new str[32];
            new speedNow = floatround(GetVehicleSpeed(vehicleid));
            if(speedNow < 0) speedNow = 0;
            if(speedNow > 999) speedNow = 999;
            format(str, sizeof(str), "%03d", speedNow);
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][3], str);
            
            new fuelNow = GasolinaVeiculo[vehicleid];
            if(fuelNow < 0) fuelNow = 0;
            if(fuelNow > 100) fuelNow = 100;
            format(str, sizeof(str), "%d", fuelNow);
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][6], str);
            
            // HP do veiculo em porcentagem (0-100), nao o valor bruto 0-1000
            new hpNow = floatround(health / 10.0);
            if(hpNow < 0) hpNow = 0;
            if(hpNow > 100) hpNow = 100;
            format(str, sizeof(str), "%d", hpNow);
            PlayerTextDrawSetString(playerid, cWspeedo[playerid][8], str);

            // Verificacao de troca de veiculo
            if(lastVehicle[playerid] != vehicleid)
            {
                lastVehicle[playerid] = vehicleid;
                CallRemoteFunction("OnPlayerChangeVehicle", "ii", playerid, vehicleid);
            }
        }
    }

    // Sistema Anti-Minigun
    if(GetPlayerWeapon(playerid) == 38 && Pdados[playerid][Admin] < 8)
    {
        new pname[24], string_msg[128]; 
        GetPlayerName(playerid, pname, sizeof(pname));
        format(string_msg, sizeof(string_msg), "O %s (%i) foi kickado pelo motivo: Minigum", pname, playerid);
        SendClientMessageToAll(VERMELHO, string_msg); // Corrigido para 'VERMELHO' maiusculo
        Kick(playerid);
        return 1;
    }

    // Restricao para Novatos
    if(Pdados[playerid][SegundosJogados] < 36000 && Pdados[playerid][Admin] < 8) // CORREcaO: 10 horas sao 36000 segundos, antes estava bloqueando com apenas 10 segundos!
    {
        if(GetPlayerWeapon(playerid) != 0) 
        {
            ResetPlayerWeapons(playerid);
            SendClientMessage(playerid, VERMELHO, "Novatos (menos de 10h de jogo) nao podem portar armas!");
        }
    }

    // --- CORREcaO DO ANTI-FARM DE HORAS ---
    if(Pdados[playerid][AntiFarmAtivado] == false && os[playerid] != 1)
    {
        // Se a posicao atual for muito proxima da anterior (usando aproximacao float para evitar bugs de micro-movimentos)
        if(floatabs(x - Pdados[playerid][UltimaPos_X]) < 0.2 && floatabs(y - Pdados[playerid][UltimaPos_Y]) < 0.2)
        {
            Pdados[playerid][TempoParado]++;
            
            // 3000 iteracoes no OnPlayerUpdate equivalem a mais ou menos 1 a 2 minutos dependendo do FPS
            if(Pdados[playerid][TempoParado] >= 3000) 
            {
                Pdados[playerid][AntiFarmAtivado] = true;
                Pdados[playerid][TempoParado] = 0; 
                ShowPlayerDialog(playerid, DIALOG_ANTIFARM, DIALOG_STYLE_MSGBOX, "{F3DA0B}Sistema Anti-Farm", "Voce esta ai? O ganho de horas foi pausado por inatividade.", "Sim", "Nao");
            }
        }
        else 
        {
            Pdados[playerid][TempoParado] = 0;
            Pdados[playerid][UltimaPos_X] = x;
            Pdados[playerid][UltimaPos_Y] = y;
            Pdados[playerid][UltimaPos_Z] = z;
        }
    }

    // --- CORREcaO DO CONTADOR DE TEMPO JOGADO (Contava duplicado e infinito) ---
    static tempo_atras[MAX_PLAYERS]; 
    if(gettime() > tempo_atras[playerid])
    {
        if(Pdados[playerid][AntiFarmAtivado] == false) // So ganha tempo se nao estiver em Anti-Farm
        {
            Pdados[playerid][SegundosJogados]++;
        }
        tempo_atras[playerid] = gettime();
    }
    
    return 1;
}


public OnPlayerStreamIn(playerid, forplayerid)
{
    BCG47Packet(playerid,forplayerid);
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

new pp,model;
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!CG52Approved[playerid])return 1;
    if(dialogid >= 23600 && dialogid <= 23606)
        return BCG36Dialog(playerid, dialogid, response, listitem, inputtext);

    if(dialogid == DIALOG_BCG_TABLET)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: return BCGV4_TabletOrg(playerid);
            case 1: return BCGV4_TabletEmprego(playerid);
            case 2: return BCGV4_AbrirEmpregos(playerid);
            case 3: return BCGV4_CheckAtt(playerid);
            case 4: return BCGV4_ACStatus(playerid);
            case 5: return cmd_coinspedido(playerid, "");
        }
        return 1;
    }
    if(dialogid == DIALOG_BCG_TABLET_ORG)
    {
        if(!response) return BCGV4_Tablet(playerid);
        switch(listitem)
        {
            case 0: return cmd_membros(playerid, "");
            case 1: return cmd_equipar(playerid, "");
            case 2: return cmd_veiculoorg(playerid, "");
            case 3: return cmd_guardarveiculoservico(playerid, "");
            case 4: return cmd_statusguerra(playerid, "");
            case 5: return cmd_familia(playerid, "");
            case 6: return cmd_cofrefamilia(playerid, "");
        }
        return 1;
    }
    if(dialogid == DIALOG_BCG_TABLET_JOB)
    {
        if(!response) return BCGV4_Tablet(playerid);
        switch(listitem)
        {
            case 0: return BCGV4_AbrirEmpregos(playerid);
            case 1: return cmd_iniciarexpediente(playerid, "");
            case 2: return cmd_statusjob2(playerid, "");
            case 3: return cmd_veiculoemprego(playerid, "");
            case 4: return cmd_guardarveiculoservico(playerid, "");
            case 5: return cmd_finalizarexpediente(playerid, "");
        }
        return 1;
    }
    if(dialogid == DIALOG_BCG_JOBS2)
    {
        if(!response) return 1;
        if(listitem >= 0 && listitem < 10)
        {
            Pdados[playerid][Trabalho] = listitem + 1;
            Pdados[playerid][Trabalhando] = false;
            BCGV4_JobEntregas[playerid] = 0;
            BCGV4_JobGanhos[playerid] = 0;
            SalvarDados(playerid);
            SendClientMessage(playerid, 0x2ECC71FF, "[EMPREGOS 2.0] Profissao atualizada. Use /iniciarexpediente.");
        }
        return 1;
    }

    if(dialogid == DIALOG_BCG_LOJA_ANUNCIO)
    {
        #pragma unused listitem
        if(!BCG_AnuncioComprado[playerid]) return 1;

        if(!response || strlen(inputtext) < 3 || strlen(inputtext) > 120)
        {
            Pdados[playerid][Coins] += 1;
            BCG_AnuncioComprado[playerid] = false;
            SalvarDados(playerid);
            return SendClientMessage(playerid, 0xFFD700FF, "[LOJA] Compra cancelada. 1 Coin devolvido.");
        }

        BCG_AnuncioComprado[playerid] = false;
        new anuncio[160];
        format(anuncio, sizeof anuncio, "{00BFFF}[ANUNCIO PREMIUM] {FFFFFF}%s", inputtext);
        SendClientMessageToAll(0xFFFFFFFF, anuncio);
        SalvarDados(playerid);
        SendClientMessage(playerid, 0x00FF00FF, "[LOJA] Anuncio publicado com sucesso.");
        return 1;
    }

    if(BCG_HandleModernDialog(playerid, dialogid, response, listitem, inputtext)) return 1;

    if(dialogid == DIALOG_BCG_PIX_VALOR)
    {
        if(!response)
        {
            PixDestino[playerid] = INVALID_PLAYER_ID;
            SendClientMessage(playerid, CINZA, "[PIX] Operacao cancelada.");
            return 1;
        }

        new valor = strval(inputtext);
        new destino = PixDestino[playerid];

        if(destino < 0 || destino >= MAX_PLAYERS || !IsPlayerConnected(destino))
        {
            PixDestino[playerid] = INVALID_PLAYER_ID;
            return SendClientMessage(playerid, VERMELHO, "[PIX] O destinatario ficou offline.");
        }

        if(valor <= 0)
            return SendClientMessage(playerid, VERMELHO, "[PIX] Digite um valor maior que R$ 0.");

        if(valor > Pdados[playerid][Banco])
            return SendClientMessage(playerid, VERMELHO, "[PIX] Saldo bancario insuficiente.");

        if(destino == playerid)
        {
            PixDestino[playerid] = INVALID_PLAYER_ID;
            return SendClientMessage(playerid, VERMELHO, "[PIX] Voce nao pode enviar PIX para voce mesmo.");
        }

        Pdados[playerid][Banco] -= valor;
        Pdados[destino][Banco] += valor;

        new nomeDestino[MAX_PLAYER_NAME], nomeRemetente[MAX_PLAYER_NAME], msg[192];
        GetPlayerName(destino, nomeDestino, sizeof(nomeDestino));
        GetPlayerName(playerid, nomeRemetente, sizeof(nomeRemetente));

        format(msg, sizeof(msg), "[PIX] Voce enviou R$ %d para %s (ID %d).", valor, nomeDestino, BCG_IDFixo[destino]);
        SendClientMessage(playerid, VERDE, msg);

        format(msg, sizeof(msg), "[PIX] Voce recebeu R$ %d de %s (ID %d).", valor, nomeRemetente, BCG_IDFixo[playerid]);
        SendClientMessage(destino, VERDE, msg);

        format(msg, sizeof(msg), "[PIX] Seu saldo bancario agora e R$ %d.", Pdados[playerid][Banco]);
        SendClientMessage(playerid, AZUL_CLARO, msg);

        SalvarDados(playerid);
        SalvarDados(destino);
        PixDestino[playerid] = INVALID_PLAYER_ID;
        return 1;
    }

    // Celular BCG V16
    if(dialogid == DIALOG_BCG_CELULAR)
    {
        if(!response) { BCGCelularAberto[playerid] = false; return 1; }
        switch(listitem)
        {
            case 0:
            {
                new lista[512], linha[48];
                format(lista, sizeof lista, "ID\tStatus\n");
                for(new i = 0; i < MAX_PLAYERS; i++)
                {
                    if(!IsPlayerConnected(i) || i == playerid) continue;
                    if(!Pdados[i][pLogged]) continue;
                    format(linha, sizeof linha, "%d\tOnline\n", i);
                    if(strlen(lista)+strlen(linha) >= sizeof(lista)) break;
                    strcat(lista, linha);
                }
                ShowPlayerDialog(playerid, DIALOG_BCG_CONTATOS, DIALOG_STYLE_TABLIST_HEADERS, "Contatos", lista, "Voltar", "Fechar");
            }
            case 1: ShowPlayerDialog(playerid, DIALOG_BCG_SMS_ID, DIALOG_STYLE_INPUT, "Mensagens", "Digite o ID para enviar SMS:", "Continuar", "Voltar");
            case 2: ShowPlayerDialog(playerid, DIALOG_BCG_LIGAR_ID, DIALOG_STYLE_INPUT, "Ligacoes", "Digite o ID que deseja ligar:", "Ligar", "Voltar");
            case 3: ShowPlayerDialog(playerid, DIALOG_BCG_GPS, DIALOG_STYLE_LIST, "GPS", "Prefeitura\nHospital\nDelegacia\nBanco\nSpawn", "Marcar", "Voltar");
            case 4: ShowPlayerDialog(playerid, DIALOG_BCG_ANUNCIO, DIALOG_STYLE_INPUT, "Anuncios", "Digite seu anuncio:", "Publicar", "Voltar");
            case 5: BCGCelularAberto[playerid] = false;
        }
        return 1;
    }
    if(dialogid == DIALOG_BCG_CONTATOS)
    {
        if(response) MostrarCelularBCG(playerid);
        return 1;
    }
    if(dialogid == DIALOG_BCG_SMS_ID)
    {
        if(!response) return MostrarCelularBCG(playerid);
        new id;
        if(sscanf(inputtext, "i", id) || id < 0 || id >= MAX_PLAYERS || !IsPlayerConnected(id) || !Pdados[id][pLogged] || id == playerid)
        {
            SendClientMessage(playerid, -1, "[SMS] ID invalido.");
            return MostrarCelularBCG(playerid);
        }
        BCGCelularSMSDestino[playerid] = id;
        format(BCG36SMSName[playerid], MAX_PLAYER_NAME, "%s", Nome(id));
        ShowPlayerDialog(playerid, DIALOG_BCG_SMS_TEXTO, DIALOG_STYLE_INPUT, "Nova mensagem", "Digite a mensagem:", "Enviar", "Voltar");
        return 1;
    }
    if(dialogid == DIALOG_BCG_SMS_TEXTO)
    {
        if(!response) return MostrarCelularBCG(playerid);
        new id = BCGCelularSMSDestino[playerid], msg[180];
        if(!IsPlayerConnected(id) || !Pdados[id][pLogged] || strcmp(BCG36SMSName[playerid], Nome(id), false)) return SendClientMessage(playerid, -1, "[SMS] Jogador desconectou. Selecione o contato novamente.");
        if(strlen(inputtext) < 1 || strlen(inputtext) > 120) return MostrarCelularBCG(playerid);
        format(msg, sizeof msg, "[SMS] ID %d: %s", playerid, inputtext);
        SendClientMessage(id, 0x00DFFFFF, msg);
        if(BCG36Client[id] && !GetPVarInt(id, "BCG36Silent")) PlayerPlaySound(id, 1052, 0.0, 0.0, 0.0);
        format(msg, sizeof msg, "[SMS] para ID %d: %s", id, inputtext);
        SendClientMessage(playerid, 0x00DFFFFF, msg);
        return MostrarCelularBCG(playerid);
    }
    if(dialogid == DIALOG_BCG_LIGAR_ID)
    {
        if(!response) return MostrarCelularBCG(playerid);
        new id;
        if(sscanf(inputtext, "i", id) || id < 0 || id >= MAX_PLAYERS || !IsPlayerConnected(id) || !Pdados[id][pLogged] || id == playerid) return MostrarCelularBCG(playerid);
        if(BCGCelularLigacao[playerid] != INVALID_PLAYER_ID || BCGCelularLigacao[id] != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "[CELULAR] Linha ocupada.");
        BCGCelularLigacao[playerid] = id;
        BCGCelularLigacao[id] = playerid;
        SendClientMessage(playerid, 0xFFFF00FF, "[CELULAR] Ligacao efetuada.");
        SendClientMessage(id, 0xFFFF00FF, "[CELULAR] Seu celular esta tocando. Use /atender ou /desligar.");
        if(BCG36Client[id] && !GetPVarInt(id, "BCG36Silent")) PlayerPlaySound(id, 1052, 0.0, 0.0, 0.0);
        return 1;
    }
    if(dialogid == DIALOG_BCG_GPS)
    {
        if(!response) return MostrarCelularBCG(playerid);
        switch(listitem)
        {
            case 0: SetPlayerCheckpoint(playerid, 1481.0, -1770.0, 18.8, 5.0);
            case 1: SetPlayerCheckpoint(playerid, 1178.8, -1323.8, 14.1, 5.0);
            case 2: SetPlayerCheckpoint(playerid, 1555.0, -1675.5, 16.2, 5.0);
            case 3: SetPlayerCheckpoint(playerid, 1462.0, -1012.0, 26.8, 5.0);
            case 4: SetPlayerCheckpoint(playerid, 1675.5, -2311.5, 13.5, 5.0);
        }
        SendClientMessage(playerid, 0x00FF00FF, "[GPS] Local marcado no mapa.");
        return 1;
    }
    if(dialogid == DIALOG_BCG_ANUNCIO)
    {
        if(!response) return MostrarCelularBCG(playerid);
        new msg[180];
        format(msg, sizeof msg, "[ANUNCIO] ID %d: %s", playerid, inputtext);
        SendClientMessageToAll(0xFFFF00FF, msg);
        return MostrarCelularBCG(playerid);
    }

    
    if(Fab_OnDialogResponse(playerid, dialogid, response, listitem, inputtext)) return 1;
    
    // Criacao das variaveis locais necessarias para este bloco
    new orgid = Pdados[playerid][OrgID];

    if(dialogid == DIALOG_BEMVINDO)
    {
        if(!response)
        {
            Kick(playerid);
            return 1;
        }

        new nomeJogador[MAX_PLAYER_NAME];
        GetPlayerName(playerid, nomeJogador, sizeof(nomeJogador));
        format(StringContas, sizeof(StringContas), "Contas/%s.txt", nomeJogador);

        if(DOF2_FileExists(StringContas))
        {
            format(String, sizeof(String), "{FFFFFF}Conta: {00BFFF}%s\n{FFFFFF}Digite sua senha para entrar na cidade:", nomeJogador);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00BFFF}Brasil RolePlay - Login", String, "Entrar", "Sair");
        }
        else
        {
            format(String, sizeof(String), "{FFFFFF}Conta: {00BFFF}%s\n{FFFFFF}Crie uma senha para registrar sua conta:", nomeJogador);
            ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "{00BFFF}Brasil RolePlay - Registro", String, "Registrar", "Sair");
        }
        return 1;
    }

    if(dialogid == DIALOG_MENU_CORPS)
    {
        if(!response) return 1; 

        switch(listitem)
        {
            case 0: // Pegar Farda por genero
            {
                if(Pdados[playerid][Genero] == 1) 
                {
                    SetPlayerSkin(playerid, 211); 
                    SendClientMessage(playerid, AZUL_CLARO, "[MENU] Voce equipou a farda Feminina da Corporacao.");
                }
                else 
                {
                    SetPlayerSkin(playerid, SkinOrg[orgid][0]);
                    SendClientMessage(playerid, AZUL_CLARO, "[MENU] Voce equipou a farda Masculina da Corporacao.");
                }
            }
            case 1: // Bater Ponto (Iniciar e sair)
            {
                if(Pdados[playerid][Farda] == false)
                {
                    SetPlayerColor(playerid, AZUL);
                    Pdados[playerid][Farda] = true;
                    SetPlayerSkin(playerid, SkinOrg[orgid][0]);
                    SendClientMessage(playerid, AZUL_CLARO, "Voce bateu o ponto e entrou em servico! (+Fardado)");
                    format(String, sizeof(String), "[%s] ID:%i", NomeOrg(playerid), playerid); 
                    Update3DTextLabelText(PlayerID[playerid], BRANCO, String);
                }
                else
                {
                    SetPlayerColor(playerid, BRANCO);
                    Pdados[playerid][Farda] = false;
                    SetPlayerSkin(playerid, Pdados[playerid][Skin]);
                    SendClientMessage(playerid, AZUL_CLARO, "Voce deslogou do ponto e esta de folga!");
                    format(String, sizeof(String), "ID:%i", playerid); 
                    Update3DTextLabelText(PlayerID[playerid], BRANCO, String);
                }
            }
            case 2: // Pegar Equipamentos Padrao
            {
                if(!Pdados[playerid][Farda]) return SendClientMessage(playerid, CINZA, "Voce precisa bater o ponto primeiro!");
                ResetPlayerWeapons(playerid);
                GivePlayerWeapon(playerid, 3, 1);     
                GivePlayerWeapon(playerid, 24, 150);  
                GivePlayerWeapon(playerid, 31, 300);  
                SetPlayerArmour(playerid, 100.0);
                SendClientMessage(playerid, AZUL_CLARO, "[MENU] Equipamentos basicos de patrulha atribuidos.");
            }
            case 3: // Pegar Equipamentos [VIP]
            {
                if(!Pdados[playerid][Farda]) return SendClientMessage(playerid, CINZA, "Voce precisa bater o ponto primeiro!");
                if(Pdados[playerid][Vip] < 1 && Pdados[playerid][Socio] < 1) return SendClientMessage(playerid, CINZA, "Apenas oficiais VIP/Socio podem pegar este kit.");
                
                ResetPlayerWeapons(playerid);
                GivePlayerWeapon(playerid, 3, 1);     
                GivePlayerWeapon(playerid, 24, 300);  
                GivePlayerWeapon(playerid, 31, 600);  
                GivePlayerWeapon(playerid, 34, 30);   
                SetPlayerArmour(playerid, 150.0);     
                SendClientMessage(playerid, -1, "{3498DB}[VIP CORPS] {FFFFFF}Equipamentos Elite e colete reforcado atribuidos!");
            }
            case 4: // Comprar Adrenalina Comum
            {
                new infoAdre[150];
                format(infoAdre, sizeof(infoAdre), "{FFFFFF}Voce possui Atualmente: {F1C40F}%d adrenalinas{FFFFFF}.\n\nCada unidade custa {2ECC71}R$ 45,00{FFFFFF}.\nDigite abaixo a quantidade desejada:", Pdados[playerid][Adrenalina]);
                ShowPlayerDialog(playerid, DIALOG_COMPRA_ADRE, DIALOG_STYLE_INPUT, "{3498DB}COMPRA DE ADRENALINA", infoAdre, "Comprar", "Voltar");
            }
            case 5: // Comprar Adrenalina [VIP]
            {
                if(Pdados[playerid][Vip] < 1 && Pdados[playerid][Socio] < 1) return SendClientMessage(playerid, CINZA, "Opcao exclusiva para Policiais VIP!");
                
                Pdados[playerid][Adrenalina] += 2; 
                SendClientMessage(playerid, -1, "{3498DB}[VIP CORPS] {FFFFFF}Voce resgatou +2 Adrenalinas gratis da sua franquia VIP.");
            }
            case 6: // Ativar Patrulha
            {
                SendClientMessage(playerid, -1, "{2ECC71}[SISTEMA] {FFFFFF}Patrulha iniciada. O multiplicador de ganho por tempo foi ativado!");
            }
            case 7: // Modo Ostensivo
            {
                SetPlayerArmour(playerid, 100.0);
                SendClientMessage(playerid, -1, "{E74C3C}[ALERTA] {FFFFFF}Modo Ostensivo declarado. Unidades autorizadas a responder com forca letal.");
            }
            case 8: // Regras Corps
            {
                ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "{3498DB}REGRAS DAS CORPORACOES", 
                    "{FFFFFF}1. Proibido atirar sem voz de prisao previa.\n2. Sempre bater ponto antes de pegar viaturas.\n3. Proibido uso inadequado de adrenalina em combate.\n4. Respeite a hierarquia e os comandos taticos.", "Entendido", "");
            }
        } // Fecha o switch(listitem)
        return 1;
    }
    if(dialogid == DIALOG_CRIAR_ORG_VEH)
    {
        if(!response) return 1;

        new orgid_dialog = EditandoOrgVeh[playerid][0];
        new slot_dialog = EditandoOrgVeh[playerid][1];

        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        OrgVehicles[orgid_dialog][slot_dialog][ovCriado] = true;
        OrgVehicles[orgid_dialog][slot_dialog][ovOrgID] = orgid_dialog;
        OrgVehicles[orgid_dialog][slot_dialog][ovModelID] = GetDefaultModelForOrg(orgid_dialog, slot_dialog);
        OrgVehicles[orgid_dialog][slot_dialog][ovSpawnX] = x;
        OrgVehicles[orgid_dialog][slot_dialog][ovSpawnY] = y;
        OrgVehicles[orgid_dialog][slot_dialog][ovSpawnZ] = z;
        OrgVehicles[orgid_dialog][slot_dialog][ovSpawnA] = a;
        OrgVehicles[orgid_dialog][slot_dialog][ovSpawnID] = 0;

        // Cria o 3D Text e o Pickup imediatamente ao criar o ponto
        new string_label[128], nome_org_txt[40];
        nome_org_txt = GetNomeOrg(orgid_dialog);
        format(string_label, sizeof(string_label), "{00BFFF}[ Spawn Orgs: %s ]\n{FFFFFF}Aperte 'F'", nome_org_txt);
        
        OrgVehicles[orgid_dialog][slot_dialog][ovLabelID] = CreateDynamic3DTextLabel(string_label, -1, x, y, z + 0.5, 20.0);
        OrgVehicles[orgid_dialog][slot_dialog][ovPickupID] = CreateDynamicPickup(1239, 1, x, y, z);

        SalvarVeiculosOrg();

        SendClientMessage(playerid, -1, "{00FF00}[SUCESSO]: {FFFFFF}Ponto, pickup e texto 3D do veiculo criados com sucesso!");
        return 1;
    }

    if(dialogid == DIALOG_MENU_ORG_VEH)
    {
        if(!response) return 1;

        new player_org_id = GetPVarInt(playerid, "OrgMenuAtiva");
        new selected_index = listitem;
        new contador = 0, target_slot = -1;

        // Descobre qual slot real corresponde ao item clicado na lista dinâmica
        for(new i = 0; i < MAX_VEHS_PER_ORG; i++)
        {
            if(OrgVehicles[player_org_id][i][ovCriado])
            {
                if(contador == selected_index)
                {
                    target_slot = i;
                    break;
                }
                contador++;
            }
        }

        if(target_slot == -1) return 1;

        new old_vid = OrgVehicles[player_org_id][target_slot][ovSpawnID];
        if(old_vid > 0 && GetVehicleModel(old_vid) >= 400)
        {
            DestroyVehicle(old_vid);
        }

        new car_model = OrgVehicles[player_org_id][target_slot][ovModelID];
        new Float:cx = OrgVehicles[player_org_id][target_slot][ovSpawnX];
        new Float:cy = OrgVehicles[player_org_id][target_slot][ovSpawnY];
        new Float:cz = OrgVehicles[player_org_id][target_slot][ovSpawnZ];
        new Float:ca = OrgVehicles[player_org_id][target_slot][ovSpawnA];

        new color1 = 0, color2 = 0;
        if(player_org_id >= 16 && player_org_id <= 32) { color1 = 6; color2 = 6; }
        else if(player_org_id == 15) { color1 = 1; color2 = 1; }

        new new_vid = CreateVehicle(car_model, cx, cy, cz, ca, color1, color2, 60000);
        OrgVehicles[player_org_id][target_slot][ovSpawnID] = new_vid;

        PutPlayerInVehicle(playerid, new_vid, 0);
        SendClientMessage(playerid, -1, "{00FF00}[VEICULO]: {FFFFFF}Voce retirou o veiulo da sua Corp/Org com sucesso!");
        return 1;
    }
    if(dialogid == DIALOG_LISTA_CHAMADOS)
    {
        if(!response) return 1;

        // Identifica qual jogador foi selecionado na lista baseando-se no indice ativo
        new contador = 0, targetid = INVALID_PLAYER_ID;
        foreach(Player, i)
        {
            if(tmec[i] > 0)
            {
                if(contador == listitem)
                {
                    targetid = i;
                    break;
                }
                contador++;
            }
        }

        if(targetid == INVALID_PLAYER_ID || !IsPlayerConnected(targetid))
        {
            return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Este cliente cancelou o chamado ou ficou offline.");
        }

        // Marca a posicao do cliente no mapa do mecanico
        new Float:x, Float:y, Float:z;
        GetPlayerPos(targetid, x, y, z);
        SetPlayerCheckpoint(playerid, x, y, z, 4.0);

        // Reseta o estado do chamado do cliente para remove-lo da lista
        tmec[targetid] = 0; 

        // Mensagens de confirmacao
        SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}[SUCESSO]: {FFFFFF}Voce aceitou o chamado. Rota marcada em seu radar!");
        
        new msg_cliente[128];
        format(msg_cliente, sizeof(msg_cliente), "{FFFF00}O mecanico %s aceitou o seu chamado e esta a caminho!", Nome(playerid));
        SendClientMessage(targetid, AMARELO, msg_cliente);
        return 1;
    }
    if(dialogid == DIALOG_COMPRA_ADRE)
    {
        // CORREcaO: Chama a funcao direta do comando farda do ZCMD / Pawn.CMD
        if(!response) return cmd_farda(playerid, ""); 
        
        new quantia = strval(inputtext);
        if(quantia <= 0 || quantia > 10) 
        {
            SendClientMessage(playerid, CINZA, "Quantidade invalida! Digite um valor entre 1 e 10.");
            return cmd_farda(playerid, "");
        }
        
        new custoTotal = quantia * 45;
        if(GetPlayerMoney(playerid) < custoTotal)
        {
            return SendClientMessage(playerid, -1, "{FF0000}[ERRO] {FFFFFF}Voce nao tem dinheiro suficiente para comprar esta quantidade!");
        }
        
        GivePlayerMoney(playerid, -custoTotal);
        Pdados[playerid][Grana] -= custoTotal;
        Pdados[playerid][Adrenalina] += quantia;
        
        format(String, sizeof(String), "{2ECC71}[SUCESSO] {FFFFFF}Voce comprou %d Adrenalinas por R$ %d,00.", quantia, custoTotal);
        SendClientMessage(playerid, -1, String);
        return 1;
    }
    if(dialogid == DIALOG_BANIDO)
    {
		if(response)
        {
            Kick(playerid);
		}
	}
	switch(dialogid)
    {
        case DIALOG_MENU_BASE_ORG:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0: // Definir Local do Comando
                {
                    GetPlayerPos(playerid, TempLocalComando[playerid][0], TempLocalComando[playerid][1], TempLocalComando[playerid][2]);
                    RegistrouLocalComando[playerid] = 1;
                    SendClientMessage(playerid, CINZA, "Sucesso: Local do comando definido onde voce esta pisando!");
                    MostrarMenuCriarOrg(playerid);
                }
                case 1: // Definir Local do Spawn
                {
                    GetPlayerPos(playerid, TempLocalSpawn[playerid][0], TempLocalSpawn[playerid][1], TempLocalSpawn[playerid][2]);
                    GetPlayerFacingAngle(playerid, TempLocalSpawn[playerid][3]);
                    RegistrouLocalSpawn[playerid] = 1;
                    SendClientMessage(playerid, CINZA, "Sucesso: Local de Spawn definido aqui!");
                    MostrarMenuCriarOrg(playerid);
                }
                case 2: // Confirmar e Salvar Tudo
                {
                    if(RegistrouLocalComando[playerid] == 0 || RegistrouLocalSpawn[playerid] == 0)
                    {
                        return SendClientMessage(playerid, CINZA, "Erro: Defina o local do comando E o local do spawn antes de salvar.");
                    }

                    new org = TempCriarOrgID[playerid];
                    new filename[64], line[200];
                    format(filename, sizeof(filename), "CarOrgs/Org_%d.txt", org);

                    new File:file = fopen(filename, io_write);
                    if(file)
                    {
                        format(line, sizeof(line), "%f|%f|%f|%f|%f|%f|%f\r\n", TempLocalComando[playerid][0], TempLocalComando[playerid][1], TempLocalComando[playerid][2], TempLocalSpawn[playerid][0], TempLocalSpawn[playerid][1], TempLocalSpawn[playerid][2], TempLocalSpawn[playerid][3]);
                        
                        fwrite(file, line);
                        fclose(file);

                        // CHAME A FUNcaO AQUI PARA ATUALIZAR EM TEMPO REAL:
                        CarregarGaragens_Pickups();

                        SendClientMessage(playerid, CINZA, "Garagem da organizacao criada e salva perfeitamente com 3 opcoes nativas!");
                    }
                    else
                    {
                        SendClientMessage(playerid, CINZA, "Erro: Verifique se a pasta 'CarOrgs' existe em scriptfiles.");
                    }
                }
            }
            return 1;
        }
        case DIALOG_IRBASE:
        {
        if(!response) return 1; // Se o admin clicar em "Fechar", fecha o dialog.

        // O 'listitem' representa exatamente a linha selecionada (0 a 32)
        new org = listitem;

        switch(org)
        {
            // ==========================================================
            // POLiCIAS (1 a 12) - TELEPORTE PARA O INTERIOR DA DELEGACIA
            // ==========================================================
            case 1..12:
            {
                SetPlayerPos(playerid, 255.808441, 74.381805, 1003.640625);
                SetPlayerInterior(playerid, 6); // Interior ID 6
                SetPlayerVirtualWorld(playerid, 0);
            }

            // ==========================================================
            // DEMAIS ORGS (13 a 33) - TELEPORTE PARA A COORDENADA DA BASE
            // ==========================================================
            case 13: // Governo
            {
                SetPlayerPos(playerid, 1123.582763, -2036.770629, 69.886787);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 15: // Medicos
            {
                SetPlayerPos(playerid, 1172.5791, -1323.3423, 15.4030);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 16: // Mafia Cosa Nostra
            {
                SetPlayerPos(playerid, 690.704223, -1275.822387, 13.560098);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 17: // ALQAEDA
            {
                SetPlayerPos(playerid, 413.6285, 2537.2800, 19.1484);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 19: // Mafia Yakusa
            {
                SetPlayerPos(playerid, 2751.620849, -1963.114624, 13.546875);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 20: // Cartel Medelin
            {
                SetPlayerPos(playerid, 2634.080322, 1716.519775, 11.023437);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 21: // Triads
            {
                SetPlayerPos(playerid, 1457.021240, 2773.583007, 10.820312);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 22: // Faccao Mineira
            {
                SetPlayerPos(playerid, 1519.391601, -1452.915893, 14.205425);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 24: // Comando Vermelho
            {
                SetPlayerPos(playerid, 1105.8649, -299.4608, 74.5391);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 25: // Primeiro Comando da Capital
            {
                SetPlayerPos(playerid, -329.869171, 1536.512084, 76.611709);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 26: // Terceiro Comando Puro
            {
                SetPlayerPos(playerid, 1753.064453, -1920.982910, 13.571911);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 27: // Familia do Norte
            {
                SetPlayerPos(playerid, 2163.909423, -2270.639404, 13.322597);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 28: // Motoclube
            {
                SetPlayerPos(playerid, 912.3699, -1235.4672, 17.2109);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 29: // B40
            {
                SetPlayerPos(playerid, 1153.863403, -1180.921875, 32.818702);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 30: // Milicia
            {
                SetPlayerPos(playerid, 1649.046875, 701.809509, 10.820312);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 31: // ADA
            {
                SetPlayerPos(playerid, 2808.202636, -1176.417114, 25.373828);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 33: // Mecanico
            {
                SetPlayerPos(playerid, 1031.7509, -1435.2968, 13.5546);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            case 34: // Prefeitura
            {
                SetPlayerPos(playerid, 1031.7509, -1435.2968, 13.5546);
                SetPlayerInterior(playerid, 0); SetPlayerVirtualWorld(playerid, 0);
            }
            default:
            {
                return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO]: Essa organizacao nao possui uma coordenada mapeada.");
            }
        }

        // Envia a mensagem de confirmacao puxando apenas o nome
        format(String, sizeof(String), "Voce foi teletransportado para a base: %s", GetNomeOrg(org));
        SendClientMessage(playerid, CINZA, String);
        return 1;
        }
        case DIALOG_GARAGEM_ORG:
        {
            if(!response) return 1;

            new org = Pdados[playerid][OrgID];
            new filename[64], line[200];
            new Float:cx, Float:cy, Float:cz;
            new Float:sx, Float:sy, Float:sz, Float:sa;
            new File:file;

            format(filename, sizeof(filename), "CarOrgs/Org_%d.txt", org);
            
            if(fexist(filename))
            {
                file = fopen(filename, io_read);
                if(fread(file, line))
                {
                    new len = strlen(line);
                    if(line[len - 1] == '\r' || line[len - 1] == '\n') line[len - 1] = 0;
                    if(line[len - 2] == '\r' || line[len - 2] == '\n') line[len - 2] = 0;

                    if(sscanf(line, "p<|>fffffff", cx, cy, cz, sx, sy, sz, sa)) return fclose(file);
                    
                    new modelo_escolhido = 0;
                    switch(listitem)
                    {
                        case 0: modelo_escolhido = 482; // Burrito
                        case 1: modelo_escolhido = 567; // Savana
                        case 2: modelo_escolhido = 487; // Maverick
                    }

                    if(modelo_escolhido > 0)
                    {
                        SpawnarCarroDaGaragem(playerid, org, modelo_escolhido, sx, sy, sz, sa);
                        SendClientMessage(playerid, 0x00FF00FF, "Veiculo retirado com sucesso!");
                    }
                }
                fclose(file);
            }
            return 1;
        }
        
    }
	switch(dialogid)
    {
        case DIALOG_LOJA_PRINCIPAL:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0: // Como Adquirir Coins
                {
                    SendClientMessage(playerid, -1, "{00FF00}[Loja]:{FFFFFF} Visite nosso discord ou site para adquirir Coins!");
                }
                case 1: // Vantagens VIP/Socio
                {
                    new str[400];
                    strcat(str, "VIP Essencial\nVIP Safira\nVIP Esmeralda\nVIP Diamante\nSOCIO 1\nSOCIO 2\nSOCIO 3\nPATROCINADOR\nPATROCINADOR PLUS");
                    ShowPlayerDialog(playerid, DIALOG_LOJA_VANTAGENS, DIALOG_STYLE_LIST, "{FF0000}[BCG] {FFFFFF}Vantagens VIP/Socio", str, "Selecionar", "Voltar");
                }
                case 2: // Resgatar Coins Comprados (O sistema que criamos)
                {
                    ShowPlayerDialog(playerid, DIALOG_RESGATAR_COINS, DIALOG_STYLE_INPUT, "Resgatar Coins", "Digite o codigo do seu pacote para verificar as informacoes:", "Verificar", "Voltar");
                }
                case 3: // Comprar Socio
                {
                    new str[400];
                    strcat(str, "{FFFFFF}Socio 1 - 20c (O mais popular!)\n");
                    strcat(str, "{FFFFFF}Socio 2 - 40c (+ Recursos!)\n");
                    strcat(str, "{FFFFFF}Socio 3 - 60c (+ Vantagens!)\n");
                    strcat(str, "{FFFFFF}Patrocinador - 100c (Melhor Escolha!)\n");
                    strcat(str, "{FFFFFF}Patrocinador Plus - 200c (Experiencia Total!)");
                    ShowPlayerDialog(playerid, DIALOG_LOJA_SOCIO, DIALOG_STYLE_LIST, "{FF0000}[BCG 4] {FFFFFF}Escolha seu Plano SOCIO", str, "Comprar", "Voltar");
                }
                case 4: // Comprar VIP
                {
                    new str[400];
                    strcat(str, "{FFFFFF}VIP Essencial - 15c (Custo-beneficio!)\n");
                    strcat(str, "{FFFFFF}VIP Safira - 25c (+ Vantagens!)\n");
                    strcat(str, "{FFFFFF}VIP Esmeralda - 35c (O mais vendido!)\n");
                    strcat(str, "{FFFFFF}VIP Diamante - 45c (Melhor Experiencia!)");
                    ShowPlayerDialog(playerid, DIALOG_LOJA_VIP, DIALOG_STYLE_LIST, "{FF0000}[BCG 4] {FFFFFF}Escolha seu Plano VIP", str, "Comprar", "Voltar");
                }
                case 5: // Comprar VIP para ORG
                {
                    new str[300];
                    strcat(str, "1. ORG VIP Bronze - 20c\n");
                    strcat(str, "2. ORG VIP Prata - 40c\n");
                    strcat(str, "3. ORG VIP Ouro - 80c");
                    ShowPlayerDialog(playerid, DIALOG_LOJA_VIP_ORG, DIALOG_STYLE_LIST, "{FF0000}[BCG 4] {FFFFFF}Comprar VIP para ORG", str, "Comprar", "Voltar");
                }

                case 6: // Itens por Coins
                {
                    AbrirMenuItens1(playerid);
                }
                case 7, 8: // Veiculos de Inventario / Premium
                {
                    new str[400];
                    strcat(str, "{FF0000}Diversos\n{FFFFFF}Avioes e Helicopteros\nPesados e Utilitarios\nGovernamentais\nCarros Potentes");
                    ShowPlayerDialog(playerid, DIALOG_LOJA_VEICULOS, DIALOG_STYLE_LIST, "BCG: Categorias", str, "Selecionar", "Cancelar");
                }
                case 9: // Familias
                {
                    SendClientMessage(playerid, -1, "{00FF00}[Loja]:{FFFFFF} Menu de Familias em breve!");
                }
                case 10: // Resgatar CUPOM PREMIADO
                {
                    SendClientMessage(playerid, -1, "{00FF00}[Loja]:{FFFFFF} Use as redes sociais do servidor para encontrar cupons!");
                }
            }
            return 1;
        }

        case DIALOG_LOJA_VANTAGENS:
        {
            if(!response) return cmd_loja(playerid, "");
            return cmd_loja(playerid, "");
        }

        case DIALOG_LOJA_SOCIO:
        {
            if(!response) return cmd_loja(playerid, "");
            
            new precoSocio[] = {20, 40, 60, 100, 200};
            if(Pdados[playerid][Coins] < precoSocio[listitem]) return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Voce nao possui coins suficientes.");
            
            new nivelSocio, bonusDinheiroSocio;
            new nomeSocio[32];

            switch(listitem)
            {
                case 0: { nivelSocio = 1; bonusDinheiroSocio = 100000; format(nomeSocio, sizeof(nomeSocio), "Socio Nivel 1"); }
                case 1: { nivelSocio = 2; bonusDinheiroSocio = 200000; format(nomeSocio, sizeof(nomeSocio), "Socio Nivel 2"); }
                case 2: { nivelSocio = 3; bonusDinheiroSocio = 300000; format(nomeSocio, sizeof(nomeSocio), "Socio Nivel 3"); }
                case 3: { nivelSocio = 4; bonusDinheiroSocio = 500000; format(nomeSocio, sizeof(nomeSocio), "Patrocinador"); }
                case 4: { nivelSocio = 5; bonusDinheiroSocio = 1000000; format(nomeSocio, sizeof(nomeSocio), "Patrocinador Plus"); }
            }

            Pdados[playerid][Coins] -= precoSocio[listitem];
            Pdados[playerid][Socio] = nivelSocio; // Altere para a sua variavel caso seja diferente
            GivePlayerMoney(playerid, bonusDinheiroSocio);

            new stringSocio[144];
            format(stringSocio, sizeof(stringSocio), "Voce comprou o plano %s por %d Coins e recebeu um bonus de $%i!", nomeSocio, precoSocio[listitem], bonusDinheiroSocio);
            SendClientMessage(playerid, AMARELO, stringSocio);

            SalvarDados(playerid);
            return 1;
        }

        case DIALOG_LOJA_VIP:
        {
            if(!response) return cmd_loja(playerid, "");
            
            new precoVip[] = {15, 25, 35, 45};
            if(Pdados[playerid][Coins] < precoVip[listitem]) return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Voce nao possui coins suficientes.");
            
            new nivelVip, bonusDinheiro;
            new nomeVip[32];

            switch(listitem)
            {
                case 0: { nivelVip = 1; bonusDinheiro = 50000; format(nomeVip, sizeof(nomeVip), "VIP Essencial (Bronze)"); }
                case 1: { nivelVip = 2; bonusDinheiro = 100000; format(nomeVip, sizeof(nomeVip), "VIP Safira (Rubi)"); }
                case 2: { nivelVip = 3; bonusDinheiro = 150000; format(nomeVip, sizeof(nomeVip), "VIP Esmeralda (BCG)"); }
                case 3: { nivelVip = 4; bonusDinheiro = 300000; format(nomeVip, sizeof(nomeVip), "VIP Diamante (Premium)"); }
            }

            Pdados[playerid][Coins] -= precoVip[listitem];
            Pdados[playerid][Vip] = nivelVip;
            GivePlayerMoney(playerid, bonusDinheiro);

            new stringVIP[144];
            format(stringVIP, sizeof(stringVIP), "Voce comprou %s por %d Coins e recebeu um bonus de $%i! Use /ajuda.", nomeVip, precoVip[listitem], bonusDinheiro);
            SendClientMessage(playerid, AMARELO, stringVIP);

            SalvarDados(playerid);
            return 1;
        }

        case DIALOG_LOJA_VIP_ORG:
        {
            if(!response) return cmd_loja(playerid, "");
            
            // 1. Verificacao se o jogador pertence a uma organizacao valida
            new orgAtual = Pdados[playerid][OrgID]; 
            if(!(orgAtual >= 1 && orgAtual <= 34))
            {
                return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce nao participa de uma organizacao Gangster/Criminosa/Policial!");
            }

            new precoOrg[] = {20, 40, 80};
            if(Pdados[playerid][Coins] < precoOrg[listitem]) return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Voce nao possui coins suficientes.");
            
            // 2. Define o nivel do VIP da Org com base no item selecionado
            new nivelVipOrg = listitem + 1; // item 0 = Nivel 1, item 1 = Nivel 2, item 2 = Nivel 3
            new nomeVipOrg[16];
            if(listitem == 0) nomeVipOrg = "Bronze";
            else if(listitem == 1) nomeVipOrg = "Prata";
            else if(listitem == 2) nomeVipOrg = "Ouro";

            // 3. Desconta os Coins da carteira do jogador
            Pdados[playerid][Coins] -= precoOrg[listitem];

            // 4. Logica de Salvamento usando a sua GetNomeOrg
            new nomeDaOrg[40], diretorioOrg[70];
            format(nomeDaOrg, sizeof(nomeDaOrg), GetNomeOrg(orgAtual));
            format(diretorioOrg, sizeof(diretorioOrg), "OrgsVips/%s.txt", nomeDaOrg);

            // Cria o arquivo TXT da Org se ele nao existir e grava as informacoes
            if(!DOF2_FileExists(diretorioOrg)) DOF2_CreateFile(diretorioOrg);
            
            DOF2_SetInt(diretorioOrg, "NivelVip", nivelVipOrg);
            DOF2_SetString(diretorioOrg, "CompradoPor", Nome(playerid)); // Guarda quem comprou para o seu controle
            DOF2_SaveFile();

            // 5. Mensagens de sucesso para o jogador
            new strOrg[144];
            format(strOrg, sizeof(strOrg), "{00FF00}[Loja]:{FFFFFF} Voce comprou VIP {FFFF00}%s{FFFFFF} para a organizacao {00FFFF}%s{FFFFFF} por %d Coins!", nomeVipOrg, nomeDaOrg, precoOrg[listitem]);
            SendClientMessage(playerid, -1, strOrg);

            // Salva os dados de quem efetuou a compra (por causa do desconto dos coins)
            SalvarDados(playerid);
            return 1;
        }
        case DIALOG_SENHA_PORTAO:
        {
            new idPortao = PlayerEditandoPortaoID[playerid];
            if(idPortao == -1) return 1;

            if(!response)
            {
                if(IsValidObject(PortaoInfo[idPortao][pObjetoID])) DestroyObject(PortaoInfo[idPortao][pObjetoID]);
                PortaoInfo[idPortao][pCriado] = false;
                PlayerEditandoPortaoID[playerid] = -1;
                SendClientMessage(playerid, 0xFF0000FF, "[Portao]: Criacao abortada.");
                return 1;
            }

            if(strlen(inputtext) < 1 || strlen(inputtext) > 30)
            {
                ShowPlayerDialog(playerid, DIALOG_SENHA_PORTAO, DIALOG_STYLE_INPUT, "Configuracao do Portao", "{FF0000}Senha invalida!{FFFFFF}\nInsira a senha para terminar a criacao:", "Confirmar", "Cancelar");
                return 1;
            }

            format(PortaoInfo[idPortao][pSenha], 32, inputtext);
            PortaoInfo[idPortao][pCriado] = true;
            GetPlayerName(playerid, PortaoInfo[idPortao][pDono], MAX_PLAYER_NAME);
            PlayerEditandoPortaoID[playerid] = -1;

            // Cria o 3D Text Label exclusivo para ESSE portao
            new labelTexto[128];
            format(labelTexto, sizeof(labelTexto), "{FFFFFF}PORTAO ID: %d\n{FFFFFF}DONO: {FF0000}%s\n{FFFF00}Use /abrirportao [Senha]", idPortao, PortaoInfo[idPortao][pDono]);
            PortaoInfo[idPortao][pText3D] = Create3DTextLabel(labelTexto, 0xFFFFFFFF, PortaoInfo[idPortao][pX], PortaoInfo[idPortao][pY], PortaoInfo[idPortao][pZ] + 1.0, 20.0, 0, 1);

            // Grava o arquivo numerado correspondente a ID
            new caminhoportao[64];
            format(caminhoportao, sizeof(caminhoportao), "Portao/Portao_%d.txt", idPortao);
            
            new File:arqPortao = fopen(caminhoportao, io_write);
            if(arqPortao)
            {
                new linhaStr[128];
                format(linhaStr, sizeof(linhaStr), "Criado=1\r\n"); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "Dono=%s\r\n", PortaoInfo[idPortao][pDono]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "PosX=%f\r\n", PortaoInfo[idPortao][pX]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "PosY=%f\r\n", PortaoInfo[idPortao][pY]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "PosZ=%f\r\n", PortaoInfo[idPortao][pZ]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "RotX=%f\r\n", PortaoInfo[idPortao][pRotX]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "RotY=%f\r\n", PortaoInfo[idPortao][pRotY]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "RotZ=%f\r\n", PortaoInfo[idPortao][pRotZ]); fwrite(arqPortao, linhaStr);
                format(linhaStr, sizeof(linhaStr), "Senha=%s\r\n", PortaoInfo[idPortao][pSenha]); fwrite(arqPortao, linhaStr);
                fclose(arqPortao);
                
                SendClientMessage(playerid, 0x00FF00FF, "[Portao]: Salvo com sucesso na lista de portoes do servidor!");
            }
            return 1;
        }
        case DIALOG_MENU_MOCHILA:
        {
        if(!response) return 1;

        switch(listitem)
        {
            case 0: // Kit Medico
            {
                if(Pdados[playerid][pItem_Medikit] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                
                new Float:vidaMax = 100.0;
                if(Pdados[playerid][OrgID] >= 1 && Pdados[playerid][OrgID] <= 34) {
                    new nomeOrg[40], dirOrg[70];
                    format(nomeOrg, sizeof(nomeOrg), GetNomeOrg(Pdados[playerid][OrgID]));
                    format(dirOrg, sizeof(dirOrg), "OrgsVips/%s.txt", nomeOrg);
                    if(DOF2_FileExists(dirOrg) && DOF2_GetInt(dirOrg, "NivelVip") == 3) vidaMax = 150.0;
                }
                SetPlayerHealth(playerid, vidaMax);
                Pdados[playerid][pItem_Medikit]--;
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Vida completamente restaurada!");
                SalvarDados(playerid);
            }
            case 1: // Colete Reserva
            {
                if(Pdados[playerid][pItem_Colete] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                SetPlayerArmour(playerid, 100.0);
                Pdados[playerid][pItem_Colete]--;
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Voce equipou um Colete Reserva.");
                SalvarDados(playerid);
            }
            case 2: // Galão de Gasolina
            {
                if(Pdados[playerid][pItem_Galao] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Voce usou o Galao de Combustivel.");
            }
            case 3: // Kit de Reparo
            {
                if(Pdados[playerid][pItem_KitReparo] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "[Erro]: Voce precisa estar em um veiculo.");
                RepairVehicle(GetPlayerVehicleID(playerid));
                Pdados[playerid][pItem_KitReparo]--;
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Veiculo reparado!");
                SalvarDados(playerid);
            }
            case 4: // Kit de Blindagem
            {
                if(Pdados[playerid][pItem_Blindagem] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                Pdados[playerid][pItem_Blindagem]--;
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Blindagem aplicada.");
                SalvarDados(playerid);
            }
            case 5: // Pacote de Licenças
            {
                if(Pdados[playerid][pItem_Licencias] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                Pdados[playerid][CNH] = 1;
                Pdados[playerid][CNHb] = 1;
                Pdados[playerid][CNHc] = 1;
                Pdados[playerid][pItem_Licencias]--;
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Todas as suas licencas de transito foram liberadas!");
                SalvarDados(playerid);
            }
            case 6: // Título Personalizado
            {
                if(Pdados[playerid][pItem_Titulo] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                ShowPlayerDialog(playerid, DIALOG_DEFINIR_TAG, DIALOG_STYLE_INPUT, "Criar Titulo Personalizado", "Digite o texto da sua Tag flutuante (Max 32 caracteres):", "Confirmar", "Cancelar");
            }
            case 7: // Caixa de Som JBL
            {
                if(Pdados[playerid][pItem_JBL] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                cmd_jbl(playerid, "");
            }
            case 8: // Portão Eletrônico
            {
                if(Pdados[playerid][pItem_Portao] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");

                new idLivre = -1;
                for(new p = 0; p < MAX_PORTOES_SERVIDO; p++)
                {
                    if(PortaoInfo[p][pCriado] == false)
                    {
                        idLivre = p;
                        break;
                    }
                }

                if(idLivre == -1) return SendClientMessage(playerid, -1, "[Erro]: O servidor atingiu o limite maximo de portoes implantados.");

                Pdados[playerid][pItem_Portao]--;
                SalvarDados(playerid);

                new Float:x, Float:y, Float:z, Float:fa;
                GetPlayerPos(playerid, x, y, z);
                GetPlayerFacingAngle(playerid, fa);

                PortaoInfo[idLivre][pObjetoID] = CreateObject(19912, x + (2.0 * floatsin(-fa, degrees)), y + (2.0 * floatcos(-fa, degrees)), z, 0.0, 0.0, fa);
                PlayerEditandoPortaoID[playerid] = idLivre;
                EditObject(playerid, PortaoInfo[idLivre][pObjetoID]); 

                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Portao retirado! Mova-o na tela do celular e salve para colocar a senha.");
            }
            case 9: // Caixa de Itens Misteriosa
            {
                if(Pdados[playerid][pItem_CaixaItens] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Voce abriu a Caixa de Itens Misteriosa.");
            }
            case 10: // Lata de Spray / Grafite
            {
                if(Pdados[playerid][pItem_Grafite] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Voce usou a Lata de Spray Grafite.");
            }
            case 11: // Slot de Inventário Extra
            {
                if(Pdados[playerid][pItem_SlotInv] <= 0) return SendClientMessage(playerid, -1, "[Mochila]: Item esgotado.");
                SendClientMessage(playerid, 0x00FF00FF, "[Mochila]: Voce ativou o Slot de Inventario Extra.");
            }
        }
        return 1;
        }
        case DIALOG_MENU_JBL:
        {
            if(!response) return 1;

            if(listitem == 0) // Inserir Link
            {
                ShowPlayerDialog(playerid, DIALOG_LINK_JBL, DIALOG_STYLE_INPUT, "{00FFFF}JBL - Tocar Musica", "Insira abaixo o link direto da musica (.mp3, link de radio ou streaming):\n\n{FF8000}Nota: O link precisa terminar em formato de audio ou ser um streaming direto.", "Tocar", "Voltar");
            }
            else if(listitem == 1) // Desligar som
            {
                if(!JBLLigada[playerid]) return SendClientMessage(playerid, -1, "[JBL]: A caixa ja esta silenciosa.");

                // Percorre os jogadores proximos e para o audio deles
                for(new i = 0; i < MAX_PLAYERS; i++)
                {
                    if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 35.0, JBLPos[playerid][0], JBLPos[playerid][1], JBLPos[playerid][2]))
                    {
                        StopAudioStreamForPlayer(i);
                    }
                }
                JBLLigada[playerid] = false;
                SendClientMessage(playerid, 0x00FF00FF, "[JBL]: Voce parou a reproducao de audio da sua caixa.");
            }
            return 1;
        }

        case DIALOG_LINK_JBL:
        {
            if(!response) return cmd_jbl(playerid, ""); // Volta para o menu anterior

            if(strlen(inputtext) < 10)
            {
                SendClientMessage(playerid, 0xFF0000FF, "[Erro]: Link invalido ou muito curto.");
                return ShowPlayerDialog(playerid, DIALOG_LINK_JBL, DIALOG_STYLE_INPUT, "{00FFFF}JBL - Tocar Musica", "Insira um link de audio valido:", "Tocar", "Voltar");
            }

            // Ativa o som 3D nativo do SA-MP
            // Parametros: playerid, url, posX, posY, posZ, raioDeAlcance, usarEfeito3D(1)
            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(IsPlayerConnected(i))
                {
                    // Qualquer jogador em um raio de 35 metros escutara a musica com efeito de distancia
                    PlayAudioStreamForPlayer(i, inputtext, JBLPos[playerid][0], JBLPos[playerid][1], JBLPos[playerid][2], 35.0, 1);
                }
            }

            JBLLigada[playerid] = true;
            SendClientMessage(playerid, 0x00FF00FF, "[JBL]: Som sincronizado com sucesso! Todos ao redor estao ouvindo.");
            return 1;
        }
        case DIALOG_DEFINIR_TAG:
        {
            if(!response) return 1;
            if(Pdados[playerid][pItem_Titulo] <= 0) return SendClientMessage(playerid, -1, "[Erro]: Voce nao tem esse item.");

            if(strlen(inputtext) < 2 || strlen(inputtext) > 32)
            {
                SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} O titulo deve ter entre 2 e 32 caracteres.");
                return ShowPlayerDialog(playerid, DIALOG_DEFINIR_TAG, DIALOG_STYLE_INPUT, "Criar Titulo Personalizado", "Digite o texto da sua Tag flutuante (Max 32 caracteres):", "Confirmar", "Cancelar");
            }

            format(Pdados[playerid][pTexto_Titulo], 32, inputtext);
            Pdados[playerid][pItem_Titulo]--;

            if(TagJogador[playerid] != Text3D:INVALID_3DTEXT_ID) Delete3DTextLabel(TagJogador[playerid]);

            TagJogador[playerid] = Create3DTextLabel(Pdados[playerid][pTexto_Titulo], 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, true);
            Attach3DTextLabelToPlayer(TagJogador[playerid], playerid, 0.0, 0.0, 0.5);

            SendClientMessage(playerid, -1, "{00FF00}[Mochila]:{FFFFFF} Titulo definido com sucesso!");
            SalvarDados(playerid);
            return 1;
        }
        case DIALOG_BOLSOS:
       {
        if(!response) return 1;

        if(listitem == 2 || listitem == 14) 
        {
            new strMochila[850];
            strMochila[0] = '\0';

            strcat(strMochila, "Item Premium\tQuantidade\n");
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Kit Medico (Vida Total)\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Medikit]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Colete Reserva\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Colete]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Galao de Gasolina\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Galao]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Kit de Reparo Mecanico\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_KitReparo]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Kit de Blindagem\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Blindagem]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Pacote de Licencas (CNH)\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Licencias]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Titulo Personalizado (Tag 3D)\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Titulo]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Caixa de Som JBL Portatil\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_JBL]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Portao Eletronico Instalavel\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Portao]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Caixa de Itens Misteriosa\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_CaixaItens]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Lata de Spray (Grafite)\t{00FF00}[%d unidades]\n", strMochila, Pdados[playerid][pItem_Grafite]);
            format(strMochila, sizeof(strMochila), "%s{FFFFFF}Slot de Inventario Extra\t{00FF00}[%d unidades]", strMochila, Pdados[playerid][pItem_SlotInv]);

            ShowPlayerDialog(playerid, DIALOG_MENU_MOCHILA, DIALOG_STYLE_TABLIST_HEADERS, "BCG: Mochila de Itens", strMochila, "Usar", "Voltar");
            return 1;
        }
        return 1;
        }
        case DIALOG_LOJA_ITENS_1:
        {
        if(!response) return 1;
        if(listitem == 20) return AbrirMenuItens2(playerid);
        if(listitem < 2) return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Use os menus especificos para Dinheiro/Armas.");

        new precoItens1[] = {0, 0, 2, 2, 1, 1, 1, 1, 15, 2, 5, 5, 20, 20, 5, 15, 10, 20, 20, 2, 4};
        
        if(Pdados[playerid][Coins] < precoItens1[listitem]) 
            return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Voce nao tem coins suficientes.");

        if(listitem == 2 || listitem == 3 || listitem == 4 || listitem == 6 || listitem == 9 || listitem == 14 || listitem == 15 || listitem == 18)
        {
            // Mochila integrada ao inventario: nao precisa comprar.
        }
        
        if(listitem == 21)
        {
            AbrirMenuItens2(playerid);
            return 1;
        }

        Pdados[playerid][Coins] -= precoItens1[listitem];

        switch(listitem)
        {
            case 2: 
            { 
                if(GivePlayerItem(playerid, "Kit Medico", 1580, 1)) {
                    Pdados[playerid][pItem_Medikit]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Kit Medico enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 3: 
            { 
                if(GivePlayerItem(playerid, "Colete Reserva", 1242, 1)) {
                    Pdados[playerid][pItem_Colete]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Colete Reserva enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 4: 
            { 
                if(GivePlayerItem(playerid, "Galao Combustivel", 1650, 1)) {
                    Pdados[playerid][pItem_Galao]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Galao de Combustivel enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 5:
            {
                Pdados[playerid][Trabalho] = 0;
                Pdados[playerid][Pizza] = 0;
                DisablePlayerCheckpoint(playerid);
                DisablePlayerRaceCheckpoint(playerid);
                SendClientMessage(playerid, 0x00FF00FF, "[LOJA] Emprego encerrado com sucesso.");
            }
            case 6: 
            { 
                if(GivePlayerItem(playerid, "Kit Reparo", 1329, 1)) {
                    Pdados[playerid][pItem_KitReparo]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Kit de Reparo enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 7:
            {
                BCG_AnuncioComprado[playerid] = true;
                ShowPlayerDialog(playerid, DIALOG_BCG_LOJA_ANUNCIO, DIALOG_STYLE_INPUT,
                    "{00BFFF}ANUNCIO PERSONALIZADO",
                    "Digite o texto do anuncio.\n\nMaximo: 120 caracteres.",
                    "PUBLICAR", "CANCELAR");
            }
            case 8:
            {
                Pdados[playerid][Estrelas] = 0;
                SetPlayerWantedLevel(playerid, 0);
                SendClientMessage(playerid, 0x00FF00FF, "[LOJA] Sua ficha criminal foi limpa.");
            }
            case 9: 
            { 
                if(GivePlayerItem(playerid, "Blindagem", 19300, 1)) {
                    Pdados[playerid][pItem_Blindagem]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Blindagem de Veiculo enviada para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 10:
            {
                if(Pdados[playerid][Preso] == 1)
                {
                    Pdados[playerid][Preso] = 0;
                    algemado[playerid] = 0;
                    TogglePlayerControllable(playerid, true);
                    SetPlayerInterior(playerid, 0);
                    SetPlayerVirtualWorld(playerid, 0);
                    SetPlayerPos(playerid, 1550.7477, -1675.4952, 15.5439);
                    SetPlayerWantedLevel(playerid, 0);
                    SendClientMessage(playerid, 0x00FF00FF, "[LOJA] Voce foi liberado da cadeia.");
                }
                else
                {
                    Pdados[playerid][Coins] += precoItens1[listitem];
                    SendClientMessage(playerid, 0xFFD700FF, "[LOJA] Voce nao esta preso. Coins devolvidos.");
                }
            }
            case 14: 
            { 
                if(GivePlayerItem(playerid, "Pacote Licencas", 1900, 1)) {
                    Pdados[playerid][pItem_Licencias]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Pacote de Licencas enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 15: 
            { 
                if(GivePlayerItem(playerid, "Titulo Personalizado", 1980, 1)) {
                    Pdados[playerid][pItem_Titulo]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Titulo Personalizado enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 17: 
            {
                if(GivePlayerItem(playerid, "Portao Eletronico", 19912, 1)) {
                    Pdados[playerid][pItem_Portao]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Portao Eletronico enviado para sua mochila!");
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 18: 
            { 
                if(GivePlayerItem(playerid, "Caixa de Itens", 1905, 1)) {
                    Pdados[playerid][pItem_CaixaItens]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Caixa de Itens enviada para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens1[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
        }

        SalvarDados(playerid);
        return 1;
        }   
         // --- DIALOG DA LOJA (PÁGINA 2) ---
        case DIALOG_LOJA_ITENS_2:
        {
        if(!response) return AbrirMenuItens1(playerid);
        if(listitem < 0 || listitem >= 21) return 1;

        new precoItens2[] = {20, 5, 15, 10, 20, 20, 2, 4, 20, 15, 20, 20, 30, 30, 25, 100, 10, 5, 5, 100, 5};
        
        if(Pdados[playerid][Coins] < precoItens2[listitem]) 
            return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Voce nao tem coins suficientes.");

        if(listitem == 1 || listitem == 2 || listitem == 5 || listitem == 9 || listitem == 12 || listitem == 16)
        {
            // Mochila integrada ao inventario: nao precisa comprar.
        }

        Pdados[playerid][Coins] -= precoItens2[listitem];

        switch(listitem)
        {
            case 1: 
            { 
                if(GivePlayerItem(playerid, "Pacote Licencas", 1900, 1)) {
                    Pdados[playerid][pItem_Licencias]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Pacote de Licencas enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens2[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 2: 
            { 
                if(GivePlayerItem(playerid, "Titulo Personalizado", 1980, 1)) {
                    Pdados[playerid][pItem_Titulo]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Titulo Personalizado enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens2[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 5: 
            { 
                if(GivePlayerItem(playerid, "Caixa de Itens", 1905, 1)) {
                    Pdados[playerid][pItem_CaixaItens]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Caixa de Itens enviada para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens2[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 9: 
            { 
                if(GivePlayerItem(playerid, "Spray Grafite", 2958, 1)) {
                    Pdados[playerid][pItem_Grafite]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Spray de Grafite enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens2[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 12: 
            { 
                if(GivePlayerItem(playerid, "Caixa de Som JBL", 2226, 1)) {
                    Pdados[playerid][pItem_JBL]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: 1x Caixa de Som JBL enviada para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens2[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
            case 16: 
            { 
                if(GivePlayerItem(playerid, "Slot Inventario", 1210, 1)) {
                    Pdados[playerid][pItem_SlotInv]++; 
                    SendClientMessage(playerid, 0x00FF00FF, "[Loja]: +1 Slot de Inventario enviado para sua mochila!"); 
                } else { Pdados[playerid][Coins] += precoItens2[listitem]; SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Seu inventario esta cheio!"); }
            }
        }

        SalvarDados(playerid);
        return 1;
        }        
        case DIALOG_LOJA_VEICULOS:
        {
            if(!response) return cmd_loja(playerid, "");
            return 1;
        }

        case DIALOG_RESGATAR_COINS:
        {
            if(!response) return cmd_loja(playerid, "");

            if(!PlayerAgendamento[playerid][agAtivo] || strcmp(inputtext, PlayerAgendamento[playerid][agCodigo], true) != 0)
            {
                SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Codigo invalido ou nenhum agendamento encontrado para voce.");
                return 1;
            }

            new str[256];
            format(str, sizeof(str), "{FFFFFF}=== INFORMACOES DO PEDIDO ===\n\n{FFFFFF}ID do Pedido: {FFFF00}%d\n{FFFFFF}Coins a receber: {00FF00}%d Coins\n{FFFFFF}Status: {FFFF00}Pronto para Resgate\n\nClique em Resgatar para creditar na sua conta.", playerid, PlayerAgendamento[playerid][agQuantidade]);
            ShowPlayerDialog(playerid, DIALOG_CONFIRMA_RESGATE, DIALOG_STYLE_MSGBOX, "{00FF00}Confirmar Resgate", str, "Resgatar", "Cancelar");
            return 1;
        }

        case DIALOG_CONFIRMA_RESGATE:
        {
            if(!response) return cmd_loja(playerid, "");
            if(!PlayerAgendamento[playerid][agAtivo]) return 1;

            new quantiaGanha = PlayerAgendamento[playerid][agQuantidade];
            Pdados[playerid][Coins] += quantiaGanha;

            new msg[128];
            format(msg, sizeof(msg), "{00FF00}[Loja]:{FFFFFF} Sucesso! Voce resgatou {00FF00}%d Coins{FFFFFF}.", quantiaGanha);
            SendClientMessage(playerid, -1, msg);

            // Deleta o arquivo fisico para nao permitir reuso
            new nomeJogador[MAX_PLAYER_NAME], diretorio[64];
            GetPlayerName(playerid, nomeJogador, sizeof(nomeJogador));
            format(diretorio, sizeof(diretorio), "CoinsAgendados/%s.txt", nomeJogador);
            
            if(DOF2_FileExists(diretorio))
            {
                DOF2_RemoveFile(diretorio);
            }

            // Limpa as variaveis da memoria
            PlayerAgendamento[playerid][agAtivo] = false;
            PlayerAgendamento[playerid][agQuantidade] = 0;
            format(PlayerAgendamento[playerid][agCodigo], 32, "");

            // Salva a conta do jogador com as novas moedas adicionadas
            SalvarDados(playerid);
            return 1;
        }
    }
	// Se o jogador clicou em "Fechar" ou apertou ESC
    if(!response) return 1;

    if(dialogid == DIALOG_COFRE_ORG)
    {
        if(!response) return 1;
        new orgCofre = Pdados[playerid][OrgID];
        if(orgCofre <= 0 || orgCofre >= MAX_ORGS || !CofreOrg[orgCofre][cfCriado])
            return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Sua organizacao nao possui um cofre criado.");
        if(!IsPlayerInRangeOfPoint(playerid, 4.0, CofreOrg[orgCofre][cfX], CofreOrg[orgCofre][cfY], CofreOrg[orgCofre][cfZ]))
            return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Voce precisa estar no cofre da sua organizacao.");

        if(listitem == 0)
        {
            new arma, ammo, guardou = 0;
            for(new slot = 0; slot < 13; slot++)
            {
                GetPlayerWeaponData(playerid, slot, arma, ammo);
                if(arma > 0 && ammo > 0)
                {
                    CofreOrgArma[orgCofre][slot] = arma;
                    CofreOrgAmmo[orgCofre][slot] += ammo;
                    guardou++;
                }
            }
            if(!guardou) return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Voce nao possui armas para guardar.");
            ResetPlayerWeapons(playerid);
            BCG_SalvarCofreOrg(orgCofre);
            SendClientMessage(playerid, 0x2ECC71FF, "[COFRE] Suas armas foram guardadas no cofre da organizacao.");
            return 1;
        }
        if(listitem == 1)
        {
            new retiradas = 0;
            for(new slot = 0; slot < 13; slot++)
            {
                if(CofreOrgArma[orgCofre][slot] > 0 && CofreOrgAmmo[orgCofre][slot] > 0)
                    retiradas++;
            }
            if(!retiradas)
            {
                SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] O cofre da organizacao esta vazio.");
                return 1;
            }
            ResetPlayerWeapons(playerid);
            for(new slotRet = 0; slotRet < 13; slotRet++)
            {
                if(CofreOrgArma[orgCofre][slotRet] > 0 && CofreOrgAmmo[orgCofre][slotRet] > 0)
                {
                    GivePlayerWeapon(playerid, CofreOrgArma[orgCofre][slotRet], CofreOrgAmmo[orgCofre][slotRet]);
                    CofreOrgArma[orgCofre][slotRet] = 0;
                    CofreOrgAmmo[orgCofre][slotRet] = 0;
                }
            }
            BCG_SalvarCofreOrg(orgCofre);
            SendClientMessage(playerid, 0x2ECC71FF, "[COFRE] Voce retirou todas as armas disponiveis da organizacao.");
            return 1;
        }
        return 1;
    }

    switch(dialogid)
    {
        case DIALOG_ORGS_MAIN:
        {
            switch(listitem)
            {
                case 0:
                {
                    BCG_ListaOrgs(playerid, DIALOG_ORGS_POLICIAIS, "CORP",
                        "{FFFFFF}EXERCITO BRASILEIRO\t{FFFFFF}-\t0/30\n{FFFFFF}BOPE\t{FFFFFF}-\t0/30\n{FFFFFF}TROPA DE CHOQUE\t{FFFFFF}-\t0/30\n{FFFFFF}ROTA\t{FFFFFF}-\t0/30\n{FFFFFF}POLICIA MILITAR\t{FFFFFF}-\t0/30");
                }
                case 1:
                {
                    BCG_ListaOrgs(playerid, DIALOG_ORGS_GANGSTERS, "GANGSTER",
                        "{00008B}Os 4M\t{FFFFFF}-\t0/30\n{7CFC00}holanda 2.0\t{FFFFFF}-\t0/30\n{C71585}Os pecinhas\t{FFFFFF}-\t0/30\n{FF0000}Us guri\t{FFFFFF}-\t0/30\n{FFFF00}Real td7\t{FFFFFF}-\t0/30\n{696969}amigos dos amigos\t{FFFFFF}-\t0/30\n{FFD700}bad Boys\t{FFFFFF}-\t0/30\n{00FFFF}Os rlk\t{FFFFFF}-\t0/30\n{2F4F4F}trembala\t{FFFFFF}-\t0/30");
                }
                case 2:
                {
                    BCG_ListaOrgs(playerid, DIALOG_ORGS_TERRORISTAS, "TERRORISTA",
                        "{FFFFFF}ALQAEDA\t{FFFFFF}-\t0/30\n{FFFFFF}TALIBA\t{FFFFFF}-\t0/30");
                }
                case 3:
                {
                    BCG_ListaOrgs(playerid, DIALOG_ORGS_MERCENARIAS, "MERCENARIA",
                        "{FFFFFF}FACCAO MINEIRA\t{FFFFFF}-\t0/30\n{FFFFFF}MILICIA\t{FFFFFF}-\t0/30\n{FFFFFF}MERCENARIOS\t{FFFFFF}-\t0/30");
                }
                case 4:
                {
                    BCG_ListaOrgs(playerid, DIALOG_ORGS_MAFIOSOS, "MAFIA",
                        "{FFFFFF}MAFIA COSA NOSTRA\t{FFFFFF}-\t0/30\n{FFFFFF}MAFIA YAKUSA\t{FFFFFF}-\t0/30\n{FFFFFF}TRIADS\t{FFFFFF}-\t0/30");
                }
                case 5:
                {
                    new listaCustom[2048], linha[128];
                    listaCustom[0] = EOS;
                    for(new customid = ORG_CUSTOM_INICIO; customid <= ORG_CUSTOM_FIM; customid++)
                    {
                        if(OrgCustomAtiva[customid])
                        {
                            format(linha, sizeof(linha), "{%06x}%s [%d]\t{696969}-\t0/30\n", OrgCustomCor[customid] >>> 8, OrgCustomNome[customid], customid);
                            strcat(listaCustom, linha);
                        }
                    }
                    if(!strlen(listaCustom))
                        strcat(listaCustom, "{696969}Nenhuma org personalizada criada ainda.\t{696969}-\t0/30");
                    BCG_ListaOrgs(playerid, DIALOG_ORGS_PERSONALIZADAS, "ORG PERSONALIZADA", listaCustom);
                }
            }
            return 1;
        }

        // Trata o botao fechar das sub-caixas de mensagem (opcional, apenas para fechar o dialogo)
        case DIALOG_ORGS_POLICIAIS, DIALOG_ORGS_GANGSTERS, DIALOG_ORGS_MAFIOSOS, DIALOG_ORGS_TERRORISTAS, DIALOG_ORGS_MERCENARIAS, DIALOG_ORGS_NEUTRAS, DIALOG_ORGS_PERSONALIZADAS:
        {
            return 1;
        }
    }
	if(dialogid == 502) // ID do RG que usamos acima
    {
        TogglePlayerControllable(playerid, true); // Descongela quando clicar em "Fechar" ou ESC
        return 1;
    }
    if(dialogid == 997) // ID que definimos no comando acima
    {
        if(response) // Se ele clicou em "Marcar"
        {
            switch(listitem)
            {
                case 0: SetPlayerCheckpoint(playerid, 2100.8501, -1802.0475, 13.5547, 3.0); // Pizza
                case 1: SetPlayerCheckpoint(playerid, 1770.0736, -1657.9328, 14.4195, 3.0); // Tecnico
                case 2: SetPlayerCheckpoint(playerid, 2422.1182, -2077.6636, 13.5538, 3.0); // Caminhoneiro
                case 3: SetPlayerCheckpoint(playerid, 2046.2014, -1907.7604, 13.5468, 3.0); // onibus
                case 4: SetPlayerCheckpoint(playerid, 614.1475, -1522.6667, 15.1009, 3.0);  // Revista
                case 5: SetPlayerCheckpoint(playerid, 2475.8218, -1957.4399, 13.5922, 3.0); // Taxi
                case 6: SetPlayerCheckpoint(playerid, 2696.4556, 825.9357, 10.2964, 3.0);   // Cimento
                case 7: SetPlayerCheckpoint(playerid, 2199.7515, -1970.3779, 13.7841, 3.0); // Lixeiro
                case 8: SetPlayerCheckpoint(playerid, 1707.3555, 950.1088, 10.0, 3.0);      // Valores
                case 9: SetPlayerCheckpoint(playerid, 1199.5811, -918.6766, 43.1170, 3.0);  // iFood
            }
            SendClientMessage(playerid, 0x00BFFFFF, "BCG: O local do emprego foi marcado no seu mapa!");
        }
        return 1;
    }
    if(dialogid == DIALOG_REGISTRO)
    {
        if(response)
        {
            if(strlen(inputtext) < 6 || strlen(inputtext) > 64)
            {
                format(String, sizeof(String), "{F1FC14}Conta: %s\n{FC1E1E}Use uma senha de 6 a 64 caracteres.\n\n{07D915}Digite uma senha para ser registrado em nossa cidade", Nome(playerid));
                ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "{1EB2FC}Registrando...", String, "Registrar", "Sair");
                SendClientMessage(playerid, VERMELHO, "Digite uma senha para nosso servidor te registrar ¬¬");
                return 1;
            }
            
            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
            DOF2_CreateFile(StringContas);
            DOF2_SetString(StringContas, "Senha", inputtext);
            DOF2_SetInt(StringContas, "Matou", 0);
            DOF2_SetInt(StringContas, "Grana", 5000);
            Pdados[playerid][Grana] = 5000;
            DOF2_SetInt(StringContas, "Admin", 0);
            DOF2_SetInt(StringContas, "Banco", 500);
            Pdados[playerid][Banco] = 500;
            DOF2_SetInt(StringContas, "SegundosJogados", 0);
            Pdados[playerid][SegundosJogados] = 0;
            DOF2_SetInt(StringContas, "Skin", 26);
            DOF2_SetInt(StringContas, "Cargo", 0);
            DOF2_SetInt(StringContas, "Level", 0);
            DOF2_SetInt(StringContas, "Org", 0);
            SetPlayerVirtualWorld(playerid, 0);
            DOF2_SetInt(StringContas, "Trabalho", 0);
            DOF2_SetBool(StringContas, "Vip", false);
            DOF2_SetInt(StringContas, "CNH", 0);
            DOF2_SetInt(StringContas, "CNHb", 0);
            DOF2_SetInt(StringContas, "CNHc", 0);
            DOF2_SetInt(StringContas, "Celular", 0);
            DOF2_SetInt(StringContas, "Genero", 0);
            DOF2_SetInt(StringContas, "CorPele", 1);
            DOF2_SetInt(StringContas, "Capacete", 0);
            DOF2_SetInt(StringContas, "Mochila", 1);
            // Necessidades iniciais da conta nova. Depois disso, somente os valores salvos sao carregados.
            DOF2_SetFloat(StringContas, "Status_Fome", 100.0);
            DOF2_SetFloat(StringContas, "Status_Sede", 100.0);
            DOF2_SetFloat(StringContas, "Status_Energia", 100.0);
            DOF2_SetFloat(StringContas, "Status_Sono", 100.0);
            DOF2_SetInt(StringContas, "BCG36CadastroCompleto", 0);
            DOF2_SetInt(StringContas, "BCG36CadastroIniciado", 1);
            DOF2_SetInt(StringContas, "StatusNecessidades", 1);
            Status_Fome[playerid] = 100.0;
            Status_Sede[playerid] = 100.0;
            Status_Energia[playerid] = 100.0;
            Status_Sono[playerid] = 100.0;
            DOF2_SetInt(StringContas, "cFerramentas", 0);
            DOF2_SetInt(StringContas, "Discord", 0);
            // ID fixo aleatorio para conta nova: sempre acima de 1000.
            BCG_CarregarOuCriarIDFixo(playerid);

            
            #if defined DOF2_SetBool
            DOF2_SetBool(StringContas, "Porte", false);
            #endif
            
            DOF2_SetInt(StringContas, "YouTuber", false);
            
            format(StringContas, sizeof(StringContas), "Ficha/%s.txt", Nome(playerid));
            DOF2_SetInt(StringContas, "Preso", Pdados[playerid][Preso]);
            DOF2_SetInt(StringContas, "Estrelas", Pdados[playerid][Estrelas]);
            
            // Dados pessoais pertencem ao arquivo da conta.
            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
            DOF2_SetString(StringContas, "Gmail", "");
            DOF2_SetInt(StringContas, "Genero", 0);
            DOF2_SetInt(StringContas, "Skin", 0);
            DOF2_WriteFile();
            
            // === LIMPEZA DAS TEXTDRAWS DE REGISTRO ===
            for(new i = 1; i < MAX_REGISTER_TD; i++) 
            {
                PlayerTextDrawHide(playerid, RegisterTD[playerid][i]);
                PlayerTextDrawDestroy(playerid, RegisterTD[playerid][i]);
                RegisterTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
            }

            CancelSelectTextDraw(playerid);
            
            Pdados[playerid][Logado] = true;
            GivePlayerMoney(playerid, 5000);
            
            // Conta nova: primeiro vincula o Gmail, depois escolhe genero e personagem.
            SetPVarInt(playerid, "BCG_NOVA_CONTA", 1);
            ShowPlayerDialog(playerid, DIALOG_GMAIL_BCG, DIALOG_STYLE_INPUT, "{00BFFF}Vincular Gmail", "Digite seu Gmail para vincular a conta:\n\nExemplo: jogador@gmail.com", "Vincular", "Sair");
            return 1;
        }
        else
        {
            SendClientMessage(playerid, VERMELHO, "Voce nao quis se registrar e por isso foi kickado!");
            Kick(playerid);
            return 1;
        }
    }

    if(dialogid == DIALOG_LOGIN)
    {
        if(response)
        {
            if(!strlen(inputtext))
            {
                format(String, sizeof(String), "{F1FC14}Conta: %s\n{28FC14}Registrada.\n\n{14F1FC}Digite sua senha para Logar", Nome(playerid));
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00BFFF}CIDADE GRANDE | LOGIN", String, "ENTRAR", "SAIR");
                SendClientMessage(playerid, VERMELHO, "Digite sua senha para se logar *-*");
                return 1;
            }
            
            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));

            if(strcmp(inputtext, DOF2_GetString(StringContas, "Senha"), false))
            {
                BCG36Attempts[playerid]++;
                if(BCG36Attempts[playerid] >= 5) { Kick(playerid); return 1; }
                SendClientMessage(playerid, VERMELHO_CLARO, "Senha incorreta!");
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{00BFFF}CIDADE GRANDE | LOGIN", "{FF3030}Senha incorreta!\n\n{FFFFFF}Digite novamente sua senha para continuar:", "ENTRAR", "SAIR");
                return 1;
            }

            // === LIMPEZA DAS TEXTDRAWS DE LOGIN ===
            for(new i = 1; i < MAX_LOGIN_TD; i++) 
            {
                PlayerTextDrawHide(playerid, LoginTD[playerid][i]);
                PlayerTextDrawDestroy(playerid, LoginTD[playerid][i]);
                LoginTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
            }
            
            CancelSelectTextDraw(playerid);

            if(BCG36Client[playerid]) return BCG42Authenticated(playerid, false);
            return BCG36Enter(playerid);
        }
        else 
        {
            Kick(playerid);
            return 1;
        }
    }

    if(dialogid == DIALOG_GMAIL_BCG)
    {
        if(!response)
        {
            DeletePVar(playerid, "BCG_NOVA_CONTA");
            Kick(playerid);
            return 1;
        }
        if(strlen(inputtext) < 11 || strlen(inputtext) > 100 || strfind(inputtext, "@gmail.com", true) != strlen(inputtext)-10 || strfind(inputtext, " ") != -1)
        {
            ShowPlayerDialog(playerid, DIALOG_GMAIL_BCG, DIALOG_STYLE_INPUT, "{00BFFF}Vincular Gmail", "{FF3030}Gmail invalido!\\n{FFFFFF}Digite um endereco @gmail.com valido:", "Vincular", "Sair");
            return 1;
        }
        format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
        DOF2_SetString(StringContas, "Gmail", inputtext);
        DOF2_WriteFile();
        if(BCG36Client[playerid])
            ShowPlayerDialog(playerid, 23602, DIALOG_STYLE_INPUT, "Novo personagem", "Nascimento e nacionalidade", "Confirmar", "Sair");
        else
            ShowPlayerDialog(playerid, DIALOG_GENERO_BCG, DIALOG_STYLE_LIST, "{00BFFF}Genero do Personagem", "Masculino\nFeminino", "Escolher", "Sair");
        return 1;
    }

    if(dialogid == DIALOG_GENERO_BCG)
    {
        if(response && (listitem < 0 || listitem >= 2)) return 1;
        if(!response)
        {
            Kick(playerid);
            return 1;
        }
        Pdados[playerid][Genero] = (listitem == 0) ? 1 : 2;
        if(BCG36Client[playerid])
        {
            SetPVarInt(playerid, "BCG36_PREVIEW", 1);
            SetPlayerPos(playerid, 1685.4423, -2332.4685, 13.5469);
            SetPlayerFacingAngle(playerid, 180.0);
            TogglePlayerControllable(playerid, false);
            SetPlayerCameraPos(playerid, 1685.4423, -2336.4685, 14.3);
            SetPlayerCameraLookAt(playerid, 1685.4423, -2332.4685, 14.3);
            SetPlayerSkin(playerid, Pdados[playerid][Genero] == 1 ? 299 : 298);
        }
        ShowPlayerDialog(playerid, DIALOG_PERSONAGEM_BCG, DIALOG_STYLE_LIST, "{00BFFF}Escolha seu Personagem", (Pdados[playerid][Genero] == 1) ? "Modular (roupa intima)\nCasual\nRua\nEsportivo\nClassico" : "Urbana\nCasual\nRua\nEsportiva\nClassica", "Selecionar", "Sair");
        return 1;
    }

    if(dialogid == DIALOG_PERSONAGEM_BCG)
    {
        if(!GetPVarInt(playerid, "BCG_NOVA_CONTA") && !(BCG36Authenticated[playerid] && GetPVarInt(playerid, "BCG42_EDIT"))) return 1;
        if(response && (listitem < 0 || listitem >= 5)) return 1;
        if(!response)
        {
            if(GetPVarInt(playerid, "BCG42_EDIT")) { DeletePVar(playerid, "BCG42_EDIT");DeletePVar(playerid, "BCG36_PREVIEW");return BCG36Selector(playerid); }
            Kick(playerid);
            return 1;
        }
        new skinEscolhida;
        if(Pdados[playerid][Genero] == 1)
        {
            switch(listitem)
            {
                case 0: skinEscolhida = 0;
                case 1: skinEscolhida = 293;
                case 2: skinEscolhida = 20;
                case 3: skinEscolhida = 21;
                case 4: skinEscolhida = 23;
            }
        }
        else
        {
            switch(listitem)
            {
                case 0: skinEscolhida = 298;
                case 1: skinEscolhida = 12;
                case 2: skinEscolhida = 13;
                case 3: skinEscolhida = 31;
                case 4: skinEscolhida = 41;
            }
        }
        DeletePVar(playerid, "BCG36_PREVIEW");
        Pdados[playerid][Skin] = skinEscolhida;
        SetPlayerSkin(playerid, skinEscolhida);
        BCG47Select(playerid,skinEscolhida);
        if(GetPVarInt(playerid, "BCG42_EDIT") && BCG36Authenticated[playerid])
        {
            DeletePVar(playerid, "BCG42_EDIT");
            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
            DOF2_SetInt(StringContas, "Skin", skinEscolhida);DOF2_WriteFile();
            return BCG36Selector(playerid);
        }
        ShowPlayerDialog(playerid, DIALOG_COR_PELE_BCG, DIALOG_STYLE_LIST, "{00BFFF}Cor do Personagem", "Clara\nMorena\nNegra", "Selecionar", "Sair");
        return 1;
    }

    if(dialogid == DIALOG_COR_PELE_BCG)
    {
        if(response && (listitem < 0 || listitem >= 3)) return 1;
        if(!response)
        {
            Kick(playerid);
            return 1;
        }

        // A cor e registrada separadamente sem apagar o personagem escolhido.
        // O modelo/skin continua sendo exatamente o selecionado no passo anterior.
        format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
        DOF2_SetInt(StringContas, "Genero", Pdados[playerid][Genero]);
        DOF2_SetInt(StringContas, "Skin", Pdados[playerid][Skin]);
        DOF2_SetInt(StringContas, "CorPele", listitem + 1);
        DOF2_SetInt(StringContas, "Mochila", 1);
        DOF2_WriteFile();
        DeletePVar(playerid, "BCG_NOVA_CONTA");
        ShowPlayerDialog(playerid, DIALOG_ORIGEM, DIALOG_STYLE_LIST, "{FFFFFF}Origem do Personagem", "Los Santos\nSan Fierro\nLas Venturas", "Selecionar", "Sair");
        return 1;
    }

    if(dialogid == DIALOG_ORIGEM)
    {
        if(response && (listitem < 0 || listitem >= 3)) return 1;
        if(response)
        {
            new local[32];
            switch(listitem)
            {
                case 0: // Los Santos
                {
                    local = "Los Santos";
                    SetSpawnInfo(playerid, 0, Pdados[playerid][Skin], 1685.4423, -2332.4685, 13.5469, 359.1848, 0, 0, 0, 0, 0, 0);
                }
                case 1: // San Fierro
                {
                    local = "San Fierro";
                    SetSpawnInfo(playerid, 0, Pdados[playerid][Skin], -1975.3524, 137.9351, 27.6875, 90.0, 0, 0, 0, 0, 0, 0); 
                }
                case 2: // Las Venturas
                {
                    local = "Las Venturas";
                    SetSpawnInfo(playerid, 0, Pdados[playerid][Skin], 1691.5475, 1448.0125, 10.7621, 268.0, 0, 0, 0, 0, 0, 0);
                }
            }
            
            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
            DOF2_SetInt(StringContas, "BCG36CadastroCompleto", 1);
            DOF2_SetString(StringContas, "Origem", local);
            DOF2_WriteFile();
            
            if(BCG36Client[playerid])
            {
                new Float:bcgOriginX, Float:bcgOriginY, Float:bcgOriginZ, Float:bcgOriginR;
                switch(listitem)
                {
                    case 0: { bcgOriginX=1685.4423; bcgOriginY=-2332.4685; bcgOriginZ=13.5469; bcgOriginR=359.1848; }
                    case 1: { bcgOriginX=-1975.3524; bcgOriginY=137.9351; bcgOriginZ=27.6875; bcgOriginR=90.0; }
                    case 2: { bcgOriginX=1691.5475; bcgOriginY=1448.0125; bcgOriginZ=10.7621; bcgOriginR=268.0; }
                }
                DOF2_SetFloat(StringContas, "PosX", bcgOriginX);
                DOF2_SetFloat(StringContas, "PosY", bcgOriginY);
                DOF2_SetFloat(StringContas, "PosZ", bcgOriginZ);
                DOF2_SetFloat(StringContas, "PosR", bcgOriginR);
                DOF2_SetInt(StringContas, "PosInterior", 0);
                DOF2_SetInt(StringContas, "PosWorld", 0);
                DOF2_WriteFile();
                BCG36Authenticated[playerid] = true;
                return BCG36Selector(playerid);
            }

            format(String, sizeof(String), "{28FC14}BCG RP: {FFFFFF}Seja bem-vindo! Voce escolheu vir de %s.", local);
            SendClientMessage(playerid, -1, String);
            
            SetCameraBehindPlayer(playerid);
            TogglePlayerControllable(playerid, 1);
            SetPlayerVirtualWorld(playerid, 0);
            Pdados[playerid][pLogged] = 1;
            logado[playerid] = true;
            ResetPlayerMoney(playerid);
            GivePlayerMoney(playerid, Pdados[playerid][Grana]);
            SpawnPlayer(playerid);
            SetPlayerSkin(playerid, Pdados[playerid][Skin]);
            SalvarDados(playerid);
        }
        else
        {
            Kick(playerid);
        }
        return 1;
    }
    if(dialogid == DIALOG_ANTIFARM)
    {
        if(response) // Se clicou em SIM
        {
            Pdados[playerid][AntiFarmAtivado] = false;
            Pdados[playerid][TempoParado] = 0;
            SendClientMessage(playerid, VERDE, "BCG: Ganho de horas reativado!");
        }
        else // Se clicou em NaO ou deu ESC
        {
            // Opcional: Kickar o jogador ou manter o dialogo aberto
            ShowPlayerDialog(playerid, DIALOG_ANTIFARM, DIALOG_STYLE_MSGBOX, "{F3DA0B}Sistema Anti-Farm", "Voce precisa confirmar que esta ai para ganhar horas.", "Sim", "Nao");
        }
        return 1;
    }
    if(dialogid == 2500)
    {
        if(!response) return 1; // Se ele clicar em "Fechar"

        switch(listitem)
        {
            case 0: SendClientMessage(playerid, -1, "{FFFF00}[DICA]: {FFFFFF}Use /criarposto [preco]");
            case 1: SendClientMessage(playerid, -1, "{FFFF00}[DICA]: {FFFFFF}Use /deletarposto [id]");
            case 2: SendClientMessage(playerid, -1, "{FFFF00}[DICA]: {FFFFFF}Use /setarestoque [id] [quantidade]");
            case 3: SendClientMessage(playerid, -1, "{FFFF00}[DICA]: {FFFFFF}Use /mudarpreco [id] [novo_preco]");
            case 4: SendClientMessage(playerid, -1, "{FFFF00}[DICA]: {FFFFFF}Use /mudardono [id] [nome]");
            case 5: {
                // Chama o comando savefiles internamente
                OnPlayerCommandText(playerid, "/savefiles");
            }
        }
        return 1;
    }

    // --- Logica do Tablet (/tabletp) ---
    if(dialogid == 2501)
    {
        if(response) // Se ele clicar em "Sacar Lucro" (mudei o botao pra isso)
        {
            OnPlayerCommandText(playerid, "/sacarlucro");
        }
        return 1;
    }
	//dialog ml
    if(dialogid == 2020)
    {
        if(response) //Ao Clickar no primeiro bot�o
        {
            if(listitem == 0) //Ao clickar no primeiro item
            {
			if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid,0, 19065, 2, 0.120000, 0.040000, -0.003500, 0, 100, 100, 1.4, 1.4, 1.4);
			GivePlayerMoney(playerid, -2000);
			}
            if(listitem == 1) //Ao clickar no segundo item
            {
			if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid,0, 19137,2,0.101000,0.000000,0.000000,0.000000,0.000000,0.000000,1.000000,1.000000,1.000000);
			GivePlayerMoney(playerid, -2000);
            }
            if(listitem == 2) //Ao clickar no terceiro item
            {
			if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid, 0, 18639, 2, 0.131000, 0.019000, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
			GivePlayerMoney(playerid, -2000);
            }
            if(listitem == 3) //Ao clickar no terceiro item
            {
		    if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid,1, 19078,4,-0.067000,0.053999,0.018000,-168.400039,-169.800003,-2.800000,1.000000,1.000000,1.000000);
			GivePlayerMoney(playerid, -2000);
            }
            if(listitem == 4) //Ao clickar no terceiro item
            {
			if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid, 0, 19317, 1, -0.057000, -0.128000, -0.068000, -7.099996, 42.399993, 1.299997, 0.801000, 0.479000, 0.946000);
			GivePlayerMoney(playerid, -2000);
            }
            if(listitem == 5) //Ao clickar no terceiro item
            {
			if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid, 0, 2228, 1, -0.057000, -0.128000, -0.068000, -7.099996, 42.399993, 1.299997, 0.801000, 0.479000, 0.946000);
			GivePlayerMoney(playerid, -2000);
            }
            if(listitem == 6) //Ao clickar no terceiro item
            {
			if(GetPlayerMoney(playerid) < 2000) return SendClientMessage(playerid, -1 , "[ERRO]: Voce nao Tem Dinheiro Suficiente! 2000 reais");
			SetPlayerAttachedObject(playerid,2,18642,7,0.1,0.0,-0.11,0.0,-90.0,90.0);
			GivePlayerMoney(playerid, -2000);
            }
        }
    }
	//GPS
	if(dialogid == DIALOG_GPS) {
        if(!response) return 1; // Jogador fechou o GPS

        switch(listitem) {
            case 0: // Locais Importantes
            {
                ShowPlayerDialog(playerid, DIALOG_LOJAS, DIALOG_STYLE_LIST, "GPS - Locais Importantes", 
                    "Agencia de Empregos\nLoja de Roupa LS\nBanco Central\nConcessionaria\nGaragem Central\nShopping\nPrefeitura Municipal", 
                    "Marcar", "Voltar"
                );
            }
            case 1: // Caixas Eletronicos com Calculo de Metros Dinamico
            {
                new string[800], sub_str[150], Float:px, Float:py, Float:pz, Float:distancia;
                GetPlayerPos(playerid, px, py, pz);
                string[0] = '\0';

                // Loop para listar os caixas dinamicos criados por comando
                for(new i = 0; i < MAX_CAIXAS; i++) {
                    if(g_CaixasDados[i][cxExiste]) {
                        distancia = DistanceToPoint(px, py, pz, g_CaixasDados[i][cxX], g_CaixasDados[i][cxY], g_CaixasDados[i][cxZ]);
                        format(sub_str, sizeof(sub_str), "Caixa Eletronico (ID: %d) | %.0f metros\n", i, distancia);
                        strcat(string, sub_str);
                    }
                }

                // Lista tambem os caixas nativos fixos do mapa
                distancia = DistanceToPoint(px, py, pz, 1735.0466, -1605.6649, 13.5469);
                format(sub_str, sizeof(sub_str), "Caixa Eletronico - Agencia Principal | %.0f metros\n", distancia); strcat(string, sub_str);

                distancia = DistanceToPoint(px, py, pz, 1479.6907, -1718.0627, 14.0469);
                format(sub_str, sizeof(sub_str), "Caixa Eletronico - Prefeitura | %.0f metros\n", distancia); strcat(string, sub_str);

                distancia = DistanceToPoint(px, py, pz, 1362.5693, -1748.7300, 13.5324);
                format(sub_str, sizeof(sub_str), "Caixa Eletronico - Amonation LS | %.0f metros\n", distancia); strcat(string, sub_str);

                ShowPlayerDialog(playerid, DIALOG_GPS_CAIXAS, DIALOG_STYLE_LIST, "GPS - Caixas Eletronicos", string, "Marcar", "Voltar");
            }
            case 2: // HQs de Organizacoes
            {
                ShowPlayerDialog(playerid, DIALOG_GPS_HQS, DIALOG_STYLE_LIST, "GPS - HQs de Organizacoes", 
                    "HQ Policia Militar\nHQ Bope\nHQ Groove Street\nHQ Los Santos Vagos", 
                    "Marcar", "Voltar"
                );
            }
            case 3: // Agencias de Empregos
            {
                ShowPlayerDialog(playerid, DIALOG_GPS_EMPREGOS, DIALOG_STYLE_LIST, "GPS - Vagas de Emprego", 
                    "Emprego: Motorista de onibus\nEmprego: Entregador de Pizza\nEmprego: Caminhoneiro", 
                    "Marcar", "Voltar"
                );
            }
        }
        return 1;
    }

    // --- ABA: LOCAIS IMPORTANTES (SEU DIALOG_LOJAS REFEITO) ---
    if(dialogid == DIALOG_LOJAS) {
        if(!response) return cmd_gps(playerid); // Se voltar, reabre o menu principal do GPS

        DisablePlayerRaceCheckpoint(playerid);
        onCheck[playerid] = true;

        switch(listitem) {
            case 0: { SetPlayerRaceCheckpoint(playerid, 2, 1154.3616, -1760.0502, 13.6795, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Agencia de Empregos."); }
            case 1: { SetPlayerRaceCheckpoint(playerid, 2, 1072.3074, -1221.3220, 16.8906, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Loja de Roupas LS."); }
            case 2: { SetPlayerRaceCheckpoint(playerid, 2, 938.5861, -1719.2364, 13.7896, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Banco Central."); }
            case 3: { SetPlayerRaceCheckpoint(playerid, 2, 2132.0010, -1149.9999, 24.2070, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Concessionaria."); }
            case 4: { SetPlayerRaceCheckpoint(playerid, 2, 1235.3725, -1811.2432, 13.6025, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Garagem Central."); }
            case 5: { SetPlayerRaceCheckpoint(playerid, 2, 1117.6422, -1620.4365, 20.5003, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Shopping."); }
            case 6: { SetPlayerRaceCheckpoint(playerid, 2, 1480.5385, -1771.4727, 18.7957, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para: Prefeitura Municipal."); }
        }
        return 1;
    }

    // --- ABA: CAIXAS ELETRoNICOS (MARCAcaO DINaMICA) ---
    if(dialogid == DIALOG_GPS_CAIXAS) {
        if(!response) return cmd_gps(playerid);

        DisablePlayerRaceCheckpoint(playerid);
        onCheck[playerid] = true;

        new total_atual = 0;
        for(new i = 0; i < MAX_CAIXAS; i++) {
            if(g_CaixasDados[i][cxExiste]) {
                if(total_atual == listitem) {
                    SetPlayerRaceCheckpoint(playerid, 2, g_CaixasDados[i][cxX], g_CaixasDados[i][cxY], g_CaixasDados[i][cxZ], 0.0, 0.0, 0.0, 5);
                    new msg[128];
                    format(msg, sizeof(msg), "[GPS] Caixa Eletronico Criado (ID: %d) marcado no mapa!", i);
                    SendClientMessage(playerid, 0x00FF00AA, msg);
                    return 1;
                }
                total_atual++;
            }
        }

        // Se clicou nos caixas nativos fixos da lista
        if(listitem == total_atual) { SetPlayerRaceCheckpoint(playerid, 2, 1735.0466, -1605.6649, 13.5469, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Caixa Eletronico (Agencia Principal) marcado."); }
        else if(listitem == total_atual + 1) { SetPlayerRaceCheckpoint(playerid, 2, 1479.6907, -1718.0627, 14.0469, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Caixa Eletronico (Prefeitura) marcado."); }
        else if(listitem == total_atual + 2) { SetPlayerRaceCheckpoint(playerid, 2, 1362.5693, -1748.7300, 13.5324, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Caixa Eletronico (Amonation LS) marcado."); }
        return 1;
    }

    // --- ABA: HQS ---
    if(dialogid == DIALOG_GPS_HQS) {
        if(!response) return cmd_gps(playerid);
        DisablePlayerRaceCheckpoint(playerid);
        onCheck[playerid] = true;

        switch(listitem) {
            case 0: { SetPlayerRaceCheckpoint(playerid, 2, 1543.0, -1675.0, 13.5, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para HQ Policia Militar definida."); }
            // Adicione as coordenadas das outras HQs nos cases abaixo se quiser expandir...
        }
        return 1;
    }

    // --- ABA: EMPREGOS ---
    if(dialogid == DIALOG_GPS_EMPREGOS) {
        if(!response) return cmd_gps(playerid);
        DisablePlayerRaceCheckpoint(playerid);
        onCheck[playerid] = true;

        switch(listitem) {
            case 0: { SetPlayerRaceCheckpoint(playerid, 2, 1154.3616, -1760.0502, 13.6795, 0.0, 0.0, 0.0, 5); SendClientMessage(playerid, 0x00FF00AA, "[GPS] Rota para Agencia de Empregos definida."); }
            // Adicione as coordenadas dos outros locais de emprego aqui...
        }
        return 1;
    }

        // --- NOVO DIALOG DE DEPOSITAR DINHEIRO (INTERLIGADO COM PLAYER-TEXTDRAWS) ---
    if(dialogid == 9951) {
        if(!response) {
            // Se cancelar, apenas mantem a interface atualizada na tela
            UpdateBancoValores(playerid);
            return 1;
        }
        if(!strval(inputtext) || strval(inputtext) <= 0) return SendClientMessage(playerid, 0xFF0000AA, "Use apenas numeros maiores que zero.");
        
        new quantia = strval(inputtext);
        if(GetPlayerMoney(playerid) < quantia) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao tem esse dinheiro todo em maos.");
        
        // Atualiza as variaveis e salva o arquivo
        Pdados[playerid][Banco] += quantia;
        GivePlayerMoney(playerid, -quantia);
        DOF2_SaveFile(); // Se voce usar DOF2, mantem aqui. Se for outra db, ajuste.
        
        // Adiciona ao extrato e atualiza a tela do jogador imediatamente
        AdicionarAoExtrato(playerid, "Deposito", quantia);
        UpdateBancoValores(playerid);
        
        new msg[120];
        format(msg, sizeof(msg), "[BANCO BCG] Deposito de R$: %d concluido com sucesso!", quantia);
        SendClientMessage(playerid, 0x00FF00AA, msg);
        return 1;
    }

    // --- NOVO DIALOG DE SACAR DINHEIRO (INTERLIGADO COM PLAYER-TEXTDRAWS) ---
    if(dialogid == 9952) {
        if(!response) {
            UpdateBancoValores(playerid);
            return 1;
        }
        if(!strval(inputtext) || strval(inputtext) <= 0) return SendClientMessage(playerid, 0xFF0000AA, "Use apenas numeros maiores que zero.");
        
        new quantia = strval(inputtext);
        if(quantia > Pdados[playerid][Banco]) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao tem essa quantia no banco.");
        
        // Atualiza as variaveis e salva o arquivo
        Pdados[playerid][Banco] -= quantia;
        GivePlayerMoney(playerid, quantia);
        DOF2_SaveFile();
        
        // Adiciona ao extrato e atualiza a tela do jogador imediatamente
        AdicionarAoExtrato(playerid, "Saque", quantia);
        UpdateBancoValores(playerid);
        
        new msg[120];
        format(msg, sizeof(msg), "[BANCO BCG] Saque de R$: %d realizado com sucesso!", quantia);
        SendClientMessage(playerid, 0x00FF00AA, msg);
        return 1;
    }

	//telemap
    if(dialogid == TELEMAP)
    {
        if(!response) return 1;
        if(response)
        {
            SetPlayerPos(playerid, GetPVarFloat(playerid, "TeleX"), GetPVarFloat(playerid, "TeleY"), GetPVarFloat(playerid, "TeleZ"));
            return 1;
        }
    }
	if(dialogid == DIALOG_CONVITE){
		if (response){
			Pdados[playerid][OrgID] = Pdados[playerid][convite];
			Pdados[playerid][Cargo] = 1;
			SalvarDados(playerid);
			format(String,sizeof(String),"%s e o novo membro da %s",Nome(playerid),NomeOrg(playerid));
			MsgOrg(playerid,String);
			SendClientMessage(playerid,CINZA,String);
			Pdados[playerid][convite] = 0;
		}if(!response){
			SendClientMessage(playerid,AZUL_CLARO,"Voce recusou o convite");
		}

	}if(dialogid == DIALOG_BANCO)
    {
        if(!response) return SendClientMessage(playerid, CINZA, "Caixa eletrnico fechado.");
        if(listitem == 0)
        {
            SendClientMessage(playerid, 0x33CCFFFF, "[PIX] Use /pix [ID FIXO] [valor] para transferir para outro jogador online.");
        }
        else if(listitem == 1)
        {
            new string[140];
            format(string, sizeof(string), "Digite o valor que deseja sacar.\nSeu saldo: R$%d", Pdados[playerid][Banco]);
            ShowPlayerDialog(playerid, 166, DIALOG_STYLE_INPUT, "Imprio Roleplay - Sacar", string, "Sacar", "Voltar");
        }
        else if(listitem == 2)
        {
            new string[140];
            format(string, sizeof(string), "Digite o valor que deseja depositar.\nSeu saldo: R$%d", Pdados[playerid][Banco]);
            ShowPlayerDialog(playerid, 165, DIALOG_STYLE_INPUT, "Imprio Roleplay - Depositar", string, "Depositar", "Voltar");
        }
    }
    if(dialogid == 167){
		if(response) return SendClientMessage(playerid, CINZA, "Acao cancelada");
		new r = random(150000);
		SaldoBanco = r + 50000;
		format(String,sizeof(String),"Noticia: %s da %s iniciou um roubo ao banco",Nome(playerid),NomeOrg(playerid));
		SendClientMessageToAll(-1,String);SetTimer("tbanco",60000,false);Tbanco = 15;
		SetTimerEx("tfbanco",300000,false,"i",playerid);
	}
    if(dialogid == 166)
    {
        if(!response) return SendClientMessage(playerid, CINZA, "Voce cancelou o saque");
        new valor = strval(inputtext);
        if(valor <= 0) return SendClientMessage(playerid, VERMELHO, "Digite um valor valido maior que R$0.");
        if(Pdados[playerid][Banco] < valor) return SendClientMessage(playerid, VERMELHO, "Voce nao tem esse valor no banco.");

        Pdados[playerid][Banco] -= valor;
        GivePlayerMoney(playerid, valor);
        SalvarDados(playerid);
        DOF2_SaveFile();

        new msgSaque[128];
        format(msgSaque, sizeof(msgSaque), "[IMPERIO BANK] Voce sacou R$%d. Saldo: R$%d.", valor, Pdados[playerid][Banco]);
        SendClientMessage(playerid, 0x00FF00FF, msgSaque);
        return 1;
    }
    if(dialogid == 165)
    {
        if(!response) return SendClientMessage(playerid, CINZA, "Voce cancelou o deposito");
        new valor = strval(inputtext);
        if(valor <= 0) return SendClientMessage(playerid, VERMELHO, "Digite um valor valido maior que R$0.");

        // O erro antigo usava ==. Com R$1 na mao e deposito de R$1 ele recusava.
        // Agora so recusa quando o dinheiro em maos for MENOR que o valor informado.
        if(GetPlayerMoney(playerid) < valor) return SendClientMessage(playerid, VERMELHO, "Voce nao tem esse dinheiro todo em maos.");

        GivePlayerMoney(playerid, -valor);
        Pdados[playerid][Banco] += valor;
        SalvarDados(playerid);
        DOF2_SaveFile();

        new msgDeposito[128];
        format(msgDeposito, sizeof(msgDeposito), "[IMPERIO BANK] Deposito de R$%d realizado. Saldo: R$%d.", valor, Pdados[playerid][Banco]);
        SendClientMessage(playerid, 0x00FF00FF, msgDeposito);
        return 1;
    }
    if(dialogid == DIALOG_LICENCA){
		if(!response)return 1;
        switch(strval(inputtext)){
    		case 1:
    		{
    		    if(Pdados[playerid][CNH] == 1)return SendClientMessage(playerid, vermelho, "Voce ja possui Carteira Nacional Brasil categoria A.");
				if(GetPlayerMoney(playerid) < 5000)return SendClientMessage(playerid, VERMELHO, "Voce nao tem dinheiro suficiente.");
				if(autoescola[playerid] == 0){
				SetPlayerPos(playerid, 1104.3578,-1750.5039,13.5561);
				SetPlayerInterior(playerid, 0);
				GivePlayerMoney(playerid, -5000);
				autoescola[playerid] = 1;
				SendClientMessage(playerid, CINZA, "| AUTOESCOLA | Pegue um veiculo e va ate o local marcado em seu mapa.");
				}
            }
            case 2:
    		{
    		    if(Pdados[playerid][CNHb] == 1)return SendClientMessage(playerid, vermelho, "Voce ja possui Carteira Nacional Brasil categoria B.");
				if(GetPlayerMoney(playerid) < 3000)return SendClientMessage(playerid, VERMELHO, "Voce nao tem dinheiro suficiente.");
				if(autoescolab[playerid] == 0){
				SetPlayerPos(playerid, 1069.2721,-1775.9240,13.3396);
				SetPlayerInterior(playerid, 0);
				GivePlayerMoney(playerid, -3000);
				autoescolab[playerid] = 1;
				SendClientMessage(playerid, CINZA, "| AUTOESCOLA | Pegue uma moto e va ate o local marcado em seu mapa.");
				}
            }
            case 3:
    		{
    		    if(Pdados[playerid][CNHc] == 1)return SendClientMessage(playerid, vermelho, "Voce ja possui Carteira Nacional Brasil categoria C.");
				if(GetPlayerMoney(playerid) < 8000)return SendClientMessage(playerid, VERMELHO, "Voce nao tem dinheiro suficiente.");
				if(autoescolac[playerid] == 0){
				SetPlayerPos(playerid, 1056.2592,-1780.0952,13.6720);
				SetPlayerInterior(playerid, 0);
				GivePlayerMoney(playerid, -8000);
				autoescolac[playerid] = 1;
				SendClientMessage(playerid, CINZA, "| AUTOESCOLA | Pegue um caminhao e va ate o local marcado em seu mapa.");
				}
            }
            case 4:
    		{
    		    if(Pdados[playerid][Porte] == true)return SendClientMessage(playerid, vermelho,"Voce ja possui porte de armas.");
				if(GetPlayerMoney(playerid) < 80000)return SendClientMessage(playerid, VERMELHO,"Voce nao tem dinheiro suficiente.");
				GivePlayerMoney(playerid,-80000);
				Pdados[playerid][Porte] = true;
				SendClientMessage(playerid,AZUL_CLARO,"Voce recebeu seu porte");
            }
            }
        return 1;
	}
	
	if(dialogid == DIALOG_MENUV){
        new motor,farois,alarme,doors,bonnet,boot,obj;
        GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,doors,bonnet,boot,obj);
		if(!response)return 1;
		new Float:h;
		GetVehicleHealth(GetPlayerVehicleID(playerid),h);
		if(h < 900)return SendClientMessage(playerid,VERMELHO,"{00BFFF}BCG: Veiculo quebrado");
		if(listitem == 0){
			if(motor == 0){
				SetVehicleParamsEx(GetPlayerVehicleID(playerid),1,farois,alarme,0,bonnet,boot,obj);
				SendClientMessage(playerid,AZUL_CLARO,"Motor ligado!");
			}else{
				SetVehicleParamsEx(GetPlayerVehicleID(playerid),0,farois,alarme,0,bonnet,boot,obj);
				SendClientMessage(playerid,AZUL_CLARO,"Motor desligado!");
			}
		}
		if(listitem == 1){
			if(farois == 0){
				SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,1,alarme,0,bonnet,boot,obj);
				SendClientMessage(playerid,AZUL_CLARO,"Farois ligado!");
			}else{
				SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,0,alarme,0,bonnet,boot,obj);
				SendClientMessage(playerid,AZUL_CLARO,"Farois desligado!");
			}
		}
        if(listitem == 2){
            if(doors == 0){ SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,1,bonnet,boot,obj); SendClientMessage(playerid,AZUL_CLARO,"Portas travadas!"); }
            else { SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,0,bonnet,boot,obj); SendClientMessage(playerid,AZUL_CLARO,"Portas destravadas!"); }
        }
        if(listitem == 3){
            if(bonnet == 0){ SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,doors,1,boot,obj); SendClientMessage(playerid,AZUL_CLARO,"Capo aberto!"); }
            else { SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,doors,0,boot,obj); SendClientMessage(playerid,AZUL_CLARO,"Capo fechado!"); }
        }
        if(listitem == 4){
            if(boot == 0){ SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,doors,bonnet,1,obj); SendClientMessage(playerid,AZUL_CLARO,"Porta-malas aberto!"); }
            else { SetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,doors,bonnet,0,obj); SendClientMessage(playerid,AZUL_CLARO,"Porta-malas fechado!"); }
        }
		return 1;
	}
 	if(dialogid == DIALOG_NOVIDADES)
    {
        if(response) //Se apertar no primeiro bot�o...
        {
        }
        else //Se apertar no segundo bot�o...
        {
            //Fun��o ao apertar o segundo bot�o
        }
    }
	if(dialogid == DIALOG_CONCE_MAIN)
    {
        if(!response) return SendClientMessage(playerid, -1, "{00FF00}CAR SHOP:{FFFFFF} Voce saiu da concessionaria.");

        if(listitem == 3) // Sair
            return 1;

        ConcelCategoriaSelecionada[playerid] = listitem + 1; // 1 = Carros, 2 = Motos, 3 = Outros
        
        // Monta a lista de veiculos da categoria escolhida
        new stringLista[1024], linha[128];
        stringLista[0] = '\0';

        for(new i = 0; i < MAX_VEICULOS_CONCE; i++)
        {
            if(ConcelVehicles[i][cV_Categoria] == ConcelCategoriaSelecionada[playerid])
            {
                if(ConcelVehicles[i][cV_Vip])
                    format(linha, sizeof(linha), "{FFFF00}[VIP] %s - $%d\n", ConcelVehicles[i][cV_Nome], ConcelVehicles[i][cV_Preco]);
                else
                    format(linha, sizeof(linha), "{FFFFFF}%s - $%d\n", ConcelVehicles[i][cV_Nome], ConcelVehicles[i][cV_Preco]);
                
                strcat(stringLista, linha);
            }
        }

        ShowPlayerDialog(playerid, DIALOG_CONCE_LISTA, DIALOG_STYLE_LIST, "{00FF00}CAR SHOP - Escolha o Veiculo", stringLista, "Ver Opcoes", "Voltar");
        return 1;
    }
    if(dialogid == DIALOG_CONCE_LISTA)
    {
        if(!response) 
        {
            AbrirMenuConcessionaria(playerid);
            return 1;
        }

        // Mapeia o item selecionado de volta para o array global
        new cat = ConcelCategoriaSelecionada[playerid];
        new contador = 0, indexReal = -1;

        for(new i = 0; i < MAX_VEICULOS_CONCE; i++)
        {
            if(ConcelVehicles[i][cV_Categoria] == cat)
            {
                if(contador == listitem)
                {
                    indexReal = i;
                    break;
                }
                contador++;
            }
        }

        if(indexReal != -1)
        {
            ConcelIndexVeiculo[playerid] = indexReal;

            new msgAcoes[256];
            format(msgAcoes, sizeof(msgAcoes), "{FFFFFF}Veiculo: {00FF00}%s\n{FFFFFF}Valor: {00FF00}$%d\n{FFFFFF}Tipo: %s\n\n{FFFF00}1. Comprar Veiculo\n2. Realizar Test-Drive (30 Segundos)\n3. Voltar", 
                ConcelVehicles[indexReal][cV_Nome], 
                ConcelVehicles[indexReal][cV_Preco],
                ConcelVehicles[indexReal][cV_Vip] ? "Exclusivo VIP" : "Disponivel para Todos");

            ShowPlayerDialog(playerid, DIALOG_CONCE_ACOES, DIALOG_STYLE_LIST, "{00FF00}CAR SHOP - Painel do Veiculo", msgAcoes, "Confirmar", "Voltar");
        }
        return 1;
    }

    if(dialogid == DIALOG_CONCE_ACOES)
    {
        if(!response) 
        {
            AbrirMenuConcessionaria(playerid);
            return 1;
        }

        new idx = ConcelIndexVeiculo[playerid];
        
        switch(listitem)
        {
            case 0: // COMPRAR
            {
                // Verificacao de VIP
                if(ConcelVehicles[idx][cV_Vip] && Pdados[playerid][Vip] < 1)
                {
                    SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Este veiculo e exclusivo para membros {FFFF00}VIP{FFFFFF}!");
                    return 1;
                }

                // Verificacao de Dinheiro
                new valor_veiculo = ConcelVehicles[idx][cV_Preco];
                if(GetPlayerMoney(playerid) < valor_veiculo)
                {
                    SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce nao tem dinheiro suficiente para comprar este veiculo!");
                    return 1;
                }

                // Verificacao de Vagas na Garagem
                new slot = -1;
                if(Dados[playerid][modelo1] == 0) slot = 1;
                else if(Dados[playerid][modelo2] == 0) slot = 2;

                if(slot == -1)
                {
                    SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Sua garagem esta cheia! Venda um veiculo antes de comprar outro.");
                    return 1;
                }

                // Efetiva a Compra
                GivePlayerMoney(playerid, -valor_veiculo);

                if(slot == 1)
                {
                    Dados[playerid][modelo1] = ConcelVehicles[idx][cV_ModelID];
                    Dados[playerid][model1c] = false; 
                    Dados[playerid][gasosa1] = 100;
                }
                else
                {
                    Dados[playerid][modelo2] = ConcelVehicles[idx][cV_ModelID];
                    Dados[playerid][model2c] = false; 
                    Dados[playerid][gasosa2] = 100;
                }

                SalvarDados(playerid);
                SendClientMessage(playerid, -1, "{00FF00}[SUCESSO]: {FFFFFF}Parabens pela aquisicao! Va ate sua garagem para retirar o veiculo.");
            }
            case 1: // TEST-DRIVE
            {
                if(EmTestDrive[playerid])
                {
                    SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce ja esta em um test-drive!");
                    return 1;
                }
                IniciarTestDrive(playerid, ConcelVehicles[idx][cV_ModelID]);
            }
            case 2: // VOLTAR
            {
                AbrirMenuConcessionaria(playerid);
            }
        }
        return 1;
    }
    if(dialogid == DIALOG_CONFIRMACAO)
    {
        if(!response) return SendClientMessage(playerid, -1, "Compra cancelada.");
        if(GetPlayerMoney(playerid) < pp) return SendClientMessage(playerid, -1, "Sem dinheiro.");

        new slot = -1;
        if(Dados[playerid][modelo1] == 0) slot = 1;
        else if(Dados[playerid][modelo2] == 0) slot = 2;

        if(slot == -1) return SendClientMessage(playerid, -1, "Garagem cheia! Venda um veiculo antes.");

        // Apenas salva as informacoes, NaO cria o veiculo no mapa
        if(slot == 1) 
        {
            Dados[playerid][modelo1] = model;
            Dados[playerid][model1c] = false; // false significa que esta "guardado"
            Dados[playerid][gasosa1] = 100;
        } 
        else 
        {
            Dados[playerid][modelo2] = model;
            Dados[playerid][model2c] = false; // false significa que esta "guardado"
            Dados[playerid][gasosa2] = 100;
        }

        GivePlayerMoney(playerid, -pp);
        SalvarDados(playerid); 
        
        SendClientMessage(playerid, VERDE_CLARO, "Veiculo comprado com sucesso! Va ate a garagem para retira-lo.");
        return 1;
    }
    if(dialogid == DIALOG_GARAGEM)
    {
        if(!response) return 1;

        new modelo, gas, slot;
        if(listitem == 0) 
        { 
            modelo = Dados[playerid][modelo1]; 
            gas = Dados[playerid][gasosa1]; 
            slot = 1; 
        }
        else 
        { 
            modelo = Dados[playerid][modelo2]; 
            gas = Dados[playerid][gasosa2]; 
            slot = 2; 
        }

        if(modelo < 400) 
        {
            SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Este slot de garagem esta vazio.");
            return 1;
        }

        // Gerenciamento de veiculo ativo anterior na garagem
        new oldvid = VeiculoGaragem[playerid];
        if(oldvid != 0) 
        {
            if(SlotAtual[playerid] == 1) Dados[playerid][gasosa1] = GasolinaVeiculo[oldvid];
            else if(SlotAtual[playerid] == 2) Dados[playerid][gasosa2] = GasolinaVeiculo[oldvid];
            
            MotorLigado[oldvid] = false;
            GasolinaVeiculo[oldvid] = 0;

            if(TextoDonoVeiculo[oldvid] != Text3D:INVALID_3DTEXT_ID) 
            {
                Delete3DTextLabel(TextoDonoVeiculo[oldvid]);
                TextoDonoVeiculo[oldvid] = Text3D:INVALID_3DTEXT_ID;
            }
            DestroyVehicle(oldvid);
        }

        new Float:px, Float:py, Float:pz, Float:pa;
        GetPlayerPos(playerid, px, py, pz);
        GetPlayerFacingAngle(playerid, pa);

        // Spawn do veiculo com deslocamento otimizado
        new vid = CreateVehicle(modelo, px + 1.0, py, pz + 0.5, pa, Dados[playerid][cor11], Dados[playerid][cor12], 60000);
        
        GasolinaVeiculo[vid] = gas; 
        MotorLigado[vid] = false;    
        VeiculoGaragem[playerid] = vid;
        SlotAtual[playerid] = slot;

        // Criacao do Label 3D Personalizado
        new strL[128], nomeP[MAX_PLAYER_NAME];
        GetPlayerName(playerid, nomeP, sizeof(nomeP));
        
        if(Pdados[playerid][Vip] >= 1) 
            format(strL, sizeof(strL), "{FFFF00}Veiculo VIP de\n{FFFFFF}%s", nomeP);
        else 
            format(strL, sizeof(strL), "{00FF00}Veiculo de\n{FFFFFF}%s", nomeP);
        
        TextoDonoVeiculo[vid] = Create3DTextLabel(strL, 0xFFFFFFFF, 0.0, 0.0, 0.0, 20.0, 0, 1);
        Attach3DTextLabelToVehicle(TextoDonoVeiculo[vid], vid, 0.0, 0.0, 0.5);

        // Coloca o jogador no veiculo e forca o motor desligado
        PutPlayerInVehicle(playerid, vid, 0);

        new engine, lights, alarm, v_doors, v_bonnet, v_boot, objective;
        GetVehicleParamsEx(vid, engine, lights, alarm, v_doors, v_bonnet, v_boot, objective);
        SetVehicleParamsEx(vid, VEHICLE_PARAMS_OFF, lights, alarm, v_doors, v_bonnet, v_boot, objective);

        SendClientMessage(playerid, VERDE_CLARO, "{00FF00}[GARAGEM]: {FFFFFF}Veiculo retirado com sucesso! Use /motor para ligar.");
        SalvarDados(playerid); 
        return 1;
    }

    if(dialogid == DIALOG_LOCALIZAR)
    {
        if(!response) 
        {
            SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}BCG: {FFFFFF}Operacao de localizacao cancelada.");
            return 1;
        }

        new Float:pos[3];
        if(listitem == 0)
        {
            if(Dados[playerid][modelo1] == 0) return SendClientMessage(playerid, AZUL_CLARO, "{FF0000}[ERRO]: {FFFFFF}Voce selecionou um slot vazio.");
            if(Dados[playerid][model1c] == false) return SendClientMessage(playerid, AZUL_CLARO, "{FF0000}[ERRO]: {FFFFFF}Este veiculo esta guardado na garagem.");
            
            GetVehiclePos(Dados[playerid][id1], pos[0], pos[1], pos[2]);
            SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 5.0);
        }
        else if(listitem == 1)
        {
            if(Dados[playerid][modelo2] == 0) return SendClientMessage(playerid, AZUL_CLARO, "{FF0000}[ERRO]: {FFFFFF}Voce selecionou um slot vazio.");
            if(Dados[playerid][model2c] == false) return SendClientMessage(playerid, AZUL_CLARO, "{FF0000}[ERRO]: {FFFFFF}Este veiculo esta guardado na garagem.");
            
            GetVehiclePos(Dados[playerid][id2], pos[0], pos[1], pos[2]);
            SetPlayerCheckpoint(playerid, pos[0], pos[1], pos[2], 5.0);
        }

        SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}BCG: {FFFFFF}Veiculo localizado! Rota marcada em seu radar.");
        Pdados[playerid][Pizza] = 0;
        Pdados[playerid][Corrida] = 0;
        return 1;
    }
    if(dialogid == DIALOG_MENU_CAMI)
    {
        if(!response) return 1;

        new vehicleid = GetPlayerVehicleID(playerid);
        if(!CarDados[vehicleid][caminhao]) 
        {
            return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Voce precisa estar em um caminhao de trabalho valido!");
        }

        switch(listitem)
        {
            case 0:
            {
                SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}BCG: {FFFFFF}Destino de carga 1 marcado em seu mapa.");
                SetPlayerCheckpoint(playerid, -1852.0974, 124.8944, 14.6698, 5.0);
                CarDados[vehicleid][motorista] = playerid;
                CarDados[vehicleid][carga] = 1;
            }
            case 1:
            {
                SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}BCG: {FFFFFF}Destino de carga 2 marcado em seu mapa.");
                SetPlayerCheckpoint(playerid, -1104.1916, -1650.8919, 76.3671, 5.0);
                CarDados[vehicleid][motorista] = playerid;
                CarDados[vehicleid][carga] = 2;
            }
        }
        return 1;
    }
    if(dialogid == DIALOG_SERVICO_MECANICO)
    {
        if(!response) 
        {
            SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}BCG: {FFFFFF}Voce recusou a proposta de servico mecanico.");
            
            new string_recusa[128];
            format(string_recusa, sizeof(string_recusa), "{FFFF00}%s recusou o seu servico de mecanico.", Nome(playerid));
            SendClientMessage(Pdados[playerid][Servico], AMARELO, string_recusa);
            
            Pdados[playerid][Servico] = 0;
            return 1;
        }

        // Verificacao de seguranca: checa se o jogador ainda esta em um veiculo valido
        new vehicleid = GetPlayerVehicleID(playerid);
        if(!vehicleid)
        {
            SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce precisa estar dentro de um veiculo para aceitar o conserto.");
            Pdados[playerid][Servico] = 0;
            return 1;
        }

        // Verificacao se o jogador tem dinheiro suficiente para pagar o mecanico
        new preco_servico = preco[playerid];
        if(GetPlayerMoney(playerid) < preco_servico)
        {
            SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce nao tem dinheiro suficiente para pagar por este servico!");
            
            // Avisa o mecanico que o cliente nao tem dinheiro
            SendClientMessage(Pdados[playerid][Servico], -1, "{FF0000}[ERRO]: {FFFFFF}O cliente nao possui dinheiro suficiente.");
            Pdados[playerid][Servico] = 0;
            return 1;
        }

        // Efetivacao do Servico
        SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}BCG: {FFFFFF}Voce aceitou a proposta e o veiculo foi consertado.");

        new string_aceite[128];
        format(string_aceite, sizeof(string_aceite), "{00FF00}%s {FFFFFF}aceitou o seu servico de mecanico.", Nome(playerid));
        SendClientMessage(Pdados[playerid][Servico], AMARELO, string_aceite);

        // Transacao financeira e reparo
        GivePlayerMoney(playerid, -preco_servico);
        GivePlayerMoney(Pdados[playerid][Servico], preco_servico);
        
        RepairVehicle(vehicleid);
        
        // Reseta a variavel de servico
        Pdados[playerid][Servico] = 0;
        return 1;
    }
	if(dialogid == DIALOG_ARMAS)
    {
        if(response)
        {
            switch(strval(inputtext)){
    		case 1:
    		{
    		    if(Pdados[playerid][Porte] == false)return SendClientMessage(playerid, vermelho, "Voce nao tem porte de armas.");
                if(GetPlayerMoney(playerid) >= 15000){
                GivePlayerWeapon(playerid, 24, 50);
                GivePlayerMoney(playerid, -15000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente para comprar esta arma.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 2:
    		{
    		    if(Pdados[playerid][Porte] == false)return SendClientMessage(playerid, vermelho, "Voce nao tem porte de armas.");
                if(GetPlayerMoney(playerid) >= 25000){
				GivePlayerWeapon(playerid, 29, 80);
				GivePlayerMoney(playerid, -25000);
				}else{
				SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente para comprar esta arma.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 3:
    		{
    		    if(Pdados[playerid][Porte] == false)return SendClientMessage(playerid, vermelho, "Voce nao tem porte de armas.");
                if(GetPlayerMoney(playerid) >= 30000){
                GivePlayerWeapon(playerid, 25, 50);
                GivePlayerMoney(playerid, -30000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente para comprar esta arma.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 4:
    		{
    		    if(Pdados[playerid][Porte] == false)return SendClientMessage(playerid, vermelho, "Voce nao tem porte de armas.");
                if(GetPlayerMoney(playerid) >= 55000){
                GivePlayerWeapon(playerid, 30, 500);
                GivePlayerMoney(playerid, -55000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente para comprar esta arma.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 5:
    		{
    		    if(Pdados[playerid][Porte] == false)return SendClientMessage(playerid, vermelho, "Voce nao tem porte de armas.");
                if(GetPlayerMoney(playerid) >= 50000){
                GivePlayerWeapon(playerid, 31, 450);
                GivePlayerMoney(playerid, -50000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente para comprar esta arma.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 6:
    		{
    		    if(Pdados[playerid][Porte] == false)return SendClientMessage(playerid, vermelho, "Voce nao tem porte de armas.");
                if(GetPlayerMoney(playerid) >= 100000){
                GivePlayerWeapon(playerid, 34, 20);
                GivePlayerMoney(playerid, -100000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente para comprar esta arma.");
                }
            }
            }
		}
    }
    if(dialogid == DIALOG_GENERO)
    {
        if(response) //Se apertar no primeiro bot�o...
        {
            Pdados[playerid][Genero] = 1;
            SetPlayerSkin(playerid, 29);
            SalvarDados(playerid);
        }
        else //Se apertar no segundo bot�o...
        {
            Pdados[playerid][Genero] = 2;
            SetPlayerSkin(playerid, 56);
            SalvarDados(playerid);
        }
    }
    if(dialogid == DIALOG_EMPREGOS)
    {
        if(response)
        {
            switch(strval(inputtext)){
    		case 1:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Entregador de Pizza em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    if(Pdados[playerid][CNHb] == 0)return SendClientMessage(playerid, vermelho, "Voce nao possui Carteira Nacional Brasil categoria B, compre no Prefeitura.");
                SetPlayerRaceCheckpoint(playerid,2,2103.206298, -1807.147460, 13.154226,2103.206298, -1807.147460, 13.154226,5);
				onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 2:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Tecnico de Internet em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    if(Pdados[playerid][CNH] == 0)return SendClientMessage(playerid, vermelho, "Voce nao possui Carteira Nacional Brasil categoria A, compre no Prefeitura.");
                SetPlayerRaceCheckpoint(playerid,2,1770.073608, -1657.932861, 14.419504,1770.073608, -1657.932861, 14.419504,5);
				onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 3:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Caminhoneiro em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    if(Pdados[playerid][CNHc] == 0)return SendClientMessage(playerid, vermelho, "Voce nao possui Carteira Nacional Brasil categoria C, compre no Prefeitura.");
                SetPlayerRaceCheckpoint(playerid,2,2422.1182,-2077.6636,13.5538,2422.1182,-2077.6636,13.5538,5);
                onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 4:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Motorista em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    if(Pdados[playerid][CNHc] == 0)return SendClientMessage(playerid, vermelho, "Voce nao possui Carteira Nacional Brasil categoria C, compre no Prefeitura.");
                SetPlayerRaceCheckpoint(playerid,2,2046.201416, -1907.760498, 13.546875,2046.201416, -1907.760498, 13.546875,5);
                onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 5:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Entregador de Revistas em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    SetPlayerRaceCheckpoint(playerid,2,614.1475,-1522.6667,15.1009,614.1475,-1522.6667,15.1009,5);
                onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 6:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Taxista em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    if(Pdados[playerid][CNH] == 0)return SendClientMessage(playerid, vermelho, "Voce nao possui Carteira Nacional Brasil categoria A, compre no Prefeitura.");
    		    SetPlayerRaceCheckpoint(playerid,2,2475.8218,-1957.4399,13.5922,2475.8218,-1957.4399,13.5922,5);
                onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 7:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Transportar de Concreto em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    if(Pdados[playerid][CNHc] == 0)return SendClientMessage(playerid, vermelho, "Voce nao possui Carteira Nacional Brasil categoria C, compre no Prefeitura.");
    		    SetPlayerRaceCheckpoint(playerid,2,2696.4556,825.9357,10.2964,2696.4556,825.9357,10.2964,5);
                onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 8:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de Lixeiro em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    SetPlayerRaceCheckpoint(playerid,2,2199.7515,-1970.3779,13.7841,2199.7515,-1970.3779,13.7841,5);
                onCheck[playerid] = true;
            }
            }
            switch(strval(inputtext)){
    		case 9:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de transportador de valores em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    SetPlayerRaceCheckpoint(playerid,2,1707.3555,950.1088,10,1707.3555,950.1088,10,5);
                onCheck[playerid] = true;
                }
            }
            switch(strval(inputtext)){
    		case 10:
    		{
    		    SendClientMessage(playerid, branco, "Foi marcado o emprego de transportador de valores em seu mapa.");
    		    DisablePlayerRaceCheckpoint(playerid);
    		    SetPlayerRaceCheckpoint(playerid,2, 1199.5811, -918.6766, 43.1170,1199.5811, -918.6766, 43.1170,5);
                onCheck[playerid] = true;
            }
            }
		}
    }
    if(dialogid == DIALOG_AJUDA)
    {
        if(response)
        {
            switch(strval(inputtext)){
    		case 1:
    		{
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Geral", "/ds /gps /garagem /conce /trabalhar /ppizza /pagarpedagio\n/iniciarcorrida /pedirtaxi /rg /mostrarrg /prefeitura /online /admins\n/novidades /relatorio /menuv /localizarv /trancar /destrancar /dance /yts /vantagensvip", "OK", "");
            }
            }
            switch(strval(inputtext)){
    		case 2:
    		{
    			if(Pdados[playerid][Trabalho] == 0){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Desempregado", "Pegue um emprego na agencia de empregos usando /gps", "OK", "");
                }
    		    if(Pdados[playerid][Trabalho] == 1){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Entregador de pizza", "Chegue no local do emprego e use /trabalhar\n\n/ppizza - pega as pizzas\n\nDepois entregue com sua moto", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 2){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Tecnico de Internet", "Chegue no local do emprego e use /trabalhar\n\n/internet - para marcar a casa de instalacao\n\nDepois faca a instalacao com seu veiculo", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 3){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Caminhoneiro", "Chegue no local do emprego e use /trabalhar\n\n/entregas - para marcar a entrega desejada\n\nDepois faca a entrega com seu veiculo", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 4){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Motorista", "Chegue no local do emprego e use /trabalhar\n\n/iniciarcorrida - para iniciar sua corrida\n\nDepois faca sua corrida com seu onibus", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 5){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Entregador de revistas", "Chegue no local do emprego e use /trabalhar\n\n/pegarrevistas - para marca a casa para entregar revista\n\nDepois entregue a revista com sua bike", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 6){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Taxista", "Chegue no local do emprego e use /trabalhar\n\nEspere um cliente pedir taxi (/pedirtaxi)\nQuando um cliente pedir use /cliente para localizar\nPara ligar taximetro use /taximetro\n/cliente - Para localizar o cliente\n\nDepois busque o cliente com seu lindo taxi", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 7){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Transportador de Concreto", "Chegue no local do emprego e use /trabalhar\n\n/cimento - para carregar seu caminhao de cimento\n\nDepois leve para seu amigo em los santos", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 8){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Lixeiro", "Chegue no local do emprego e use /trabalhar\n\n/lixo - para pegar saco de lixo\n\nDepois leve ate um checkpoint", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 9){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Transportador de valores", "Chegue no local do emprego e use /trabalhar\n\n/lsgrana - para entregar o malote de dinheiro\n\nDepois leve ate o banco de los santos", "OK", "");
                }
                if(Pdados[playerid][Trabalho] == 10){
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "ifood", "Chegue no local do emprego e use /trabalhar\n\n/ppd - para entregar os pedidos\n\nDepois volte entregue mais", "OK", "");
                }
            }
            }
            switch(strval(inputtext)){
    		case 3:
    		{
    		    if(Pdados[playerid][OrgID] == 33){
    		    ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Mecanico", "Voce tem os seguintes comandos:\n\n- /servico - para entrar em servico de mecanico.\n- /clientec - para localizar seu cliente\n- /consertarc - para consertar o veiculo do seu cliente\n\nNao abuse dos presos do /consertarc.", "OK", "");
    		    }else{
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Organizacao", "/su - Para dar estrela no jogador\n/arr - Arrasta ate o veiculo\n/rem - Remove a pessoa do veiculo\n/r - Fala no radio\n/d - Fala no departamento\n/algemar - Algemar o individuo\n/desalgemar - deslgemar o individuo\n/revistar - Revistar individuo\n/equipar - Pegar equipamentos\n/prender - Prender suspeito\n/procurados - ver suspeitos procurados\n/cone - adicionar cone\n/adrenalina - Aumentar a vida e colete\n/rcone - remover cones", "OK", "");
                }
            }
            }
            switch(strval(inputtext)){
    		case 4:
    		{
    		    if(!Pdados[playerid][YouTuber]) return SendClientMessage(playerid, vermelho, "Voce nao e um YouTuber");
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "YouTuber", "/anyt - Para divulgar seu canal\n/anvi - Para divulgar o seu video\n", "OK", "");
            }
            }
            switch(strval(inputtext)){
    		case 5:
    		{
    		    if(!Pdados[playerid][Vip]) return SendClientMessage(playerid, vermelho, "Voce nao e um jogador VIP");
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "VIP", "Alem das suas /vantagensvip, temos:\n\n/ct - chat vip\n/anv - para anuncio vip\n/kitvip - para pegar seu kit\n/jet - para pegar seu jetpack", "OK", "");
            }
            }
            switch(strval(inputtext)){
    		case 6:
    		{
                ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Veiculos", "Comandos de veiculos:\n\n/conce > para comprar veiculos\n/menuv - para ver o menu do veiculo\n/guardar - para guardar na garagem\n/vendercarro - para vender na concessionaria\n/localizarv - para localizar seu veiculo\n/garagem - para pegar seu veiculo", "OK", "");
            }
            }
		}
    }

    if(dialogid == DIALOG_LOJA)
    {
        if(response)
        {
            switch(strval(inputtext)){
    		case 1:
    		{
                if(Pdados[playerid][Celular] == 1)return SendClientMessage(playerid, vermelho, "Voce ja possui um celular. Use /meucelular");
                if(GetPlayerMoney(playerid) >= 2000){
                Pdados[playerid][Celular] = 1;
                SendClientMessage(playerid, AMARELO, "Voce comprou seu celular, /celular para aprender a usar.");
                GivePlayerMoney(playerid, -2000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 2:
    		{
                if(Pdados[playerid][cFerramentas] == 1)return SendClientMessage(playerid, vermelho, "Voce ja possui uma caixa de ferramentas. Use /fcaixa");
                if(GetPlayerMoney(playerid) >= 3000){
                Pdados[playerid][cFerramentas] = 1;
                SendClientMessage(playerid, AMARELO, "Voce comprou uma caixa de ferramentas, /fcaixa para aprender a usar.");
                GivePlayerMoney(playerid, -3000);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente.");
                }
            }
            }
            switch(strval(inputtext)){
    		case 3:
    		{
                if(Pdados[playerid][Capacete] == 1)return SendClientMessage(playerid, vermelho, "Voce ja possui uma capacete. Use /capacete");
                if(GetPlayerMoney(playerid) >= 1500){
                Pdados[playerid][Capacete] = 1;
                SendClientMessage(playerid, AMARELO, "Voce comprou um capacete, /capacate para usar.");
                GivePlayerMoney(playerid, -1500);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente.");
                }
            }
            }
		}
    }
    if(dialogid == DIALOG_CELULAR)
    {
        if(response)
        {
            switch(strval(inputtext)){
    		case 1:
    		{
                ShowPlayerDialog(playerid, DIALOG_APLICATIVOS, DIALOG_STYLE_INPUT, "Aplicativos", "1 - Discord\t{00cc00}$50", "Selecionar", "Cancelar");
            }
            }
            switch(strval(inputtext)){
    		case 2:
    		{
                if(ttaxi[playerid] == 0){
				new msg, string[128];
				format(String,sizeof(String),"%s(%i) pediu um taxi.",Nome(playerid),playerid,msg);
				SendClientMessage(playerid,AZUL_CLARO,"{00BFFF}BCG: Aguarde um taxista responder seu chamado.");
				ttaxi[playerid] = 1;
				SetTimerEx("Taxi", 60000, true, "i", playerid);
				foreach(Player, i)
    			{
				if(Pdados[ i ][Trabalho] == 6){
				format(string, sizeof(string), "[TAXI] %s pediu um taxi.", Nome(playerid));
				SendClientMessage(i, AMARELO, string);
				}
				}
				}else{
				SendClientMessage(playerid, vermelho, "Espere 1 minuto para pedir taxi novamente.");
				}
            }
            }
            switch(strval(inputtext)){
    		case 3:
    		{
                ShowPlayerDialog(playerid,DIALOG_GPS,DIALOG_STYLE_INPUT,"Maps","1 - Locais Importantes","Aceitar","Cancelar");
            }
            }
            switch(strval(inputtext)){
    		case 4:
    		{
            }
            }
		}
    }
    if(dialogid == DIALOG_APLICATIVOS)
    {
        if(response)
        {
            switch(strval(inputtext)){
    		case 1:
    		{
                if(Pdados[playerid][Discord] == 1)return SendClientMessage(playerid, vermelho, "Voce ja baixou o Discord no seu celular.");
                if(GetPlayerMoney(playerid) >= 50){
                Pdados[playerid][Discord] = 1;
                SendClientMessage(playerid, AMARELO, "Voce baixou o Discord, /ds para se comunicar.");
                GivePlayerMoney(playerid, -50);
                }else{
                SendClientMessage(playerid, vermelho, "Voce nao tem dinheiro suficiente.");
                }
            }
            }
		}
    }
	return 1;
}

public tfbanco(playerid){
	if(IsPlayerInRangeOfPoint(playerid,10,2311.636962, -3.778552, 26.742187)){
		GivePlayerMoney(playerid,SaldoBanco);
		format(String,sizeof(String),"{0095B6}[Noticia] {FF4040}%s da %s conseguiu roubar o banco",Nome(playerid),NomeOrg(playerid));
		SendClientMessageToAll(-1,String);
		new CDP = 1, Crime;
		format(StringContas,sizeof(StringContas),"Ficha/%s.txt",Nome(playerid));
		if(DOF2_FileExists(StringContas)){
			Crime = DOF2_GetInt(StringContas,"Estrelas");
			DOF2_SetInt(StringContas,"Estrelas",Crime);
			format(String,sizeof(String),"Voce ja estava procurado com %i estrelas, %i foi adicionado a sua ficha criminal",Crime,CDP);
			SendClientMessage(playerid,AZUL_CLARO,String);
			Crime+=CDP;
			return 1;
		}else{
			format(String,sizeof(String),"Voce estava com a ficha limpa, %i estrelas foi adicionado a sua ficha criminal",CDP);
	        SendClientMessage(playerid,AZUL_CLARO,String);
			DOF2_CreateFile(StringContas);
			DOF2_SetInt(StringContas,"Estrelas",Crime);
			DOF2_SaveFile();
			return 1;
		}
	}
	return 0;
}
public tbanco(){
	if(Tbanco == 0)return 1;
	Tbanco -= 1;
	SetTimer("tbanco",60000,false);
	return 1;
}
CMD:motor(playerid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "Voce precisa ser o motorista!");
    
    new vehicleid = GetPlayerVehicleID(playerid);
    new mot, lu, alar, por, cap, porma, ob;
    GetVehicleParamsEx(vehicleid, mot, lu, alar, por, cap, porma, ob);
    
    if(!MotorLigado[vehicleid]) // Se o motor estiver falso (desligado)
    {
        MotorLigado[vehicleid] = true;
        SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_ON, lu, alar, por, cap, porma, ob);
        SendClientMessage(playerid, -1, "[MOTOR]: Veiculo {00FF00}LIGADO!");
    }
    else // Se o motor estiver true (ligado)
    {
        MotorLigado[vehicleid] = false;
        SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lu, alar, por, cap, porma, ob);
        SendClientMessage(playerid, -1, "[MOTOR]: Veiculo {FF2400}DESLIGADO!");
    }
    return 1;
}

stock BCG_CriarCasaMapa(Float:x, Float:y, Float:z, Float:a, precoCasa)
{
    new casa = -1;
    for(new i = 0; i < MAX_CASAS_BCG; i++)
    {
        if(!CasaExisteBCG[i]) { casa = i; break; }
    }
    if(casa == -1) return -1;

    CasaXBCG[casa] = x;
    CasaYBCG[casa] = y;
    CasaZBCG[casa] = z;
    CasaA_BCG[casa] = a;
    CasaPrecoBCG[casa] = precoCasa;
    CasaAluguelBCG[casa] = 0; // somente o comprador define o aluguel
    CasaInteriorBCG[casa] = 1;
    CasaDonoBCG[casa][0] = EOS;
    CasaInquilinoBCG[casa][0] = EOS;
    CasaExisteBCG[casa] = true;
    CasaPickupBCG[casa] = CreatePickup(1273, 1, x, y, z, -1);
    BCG_AtualizarLabelCasa(casa);
    return casa;
}

stock BCG_SetPosInteriorCasa(playerid, casa)
{
    new modelo = CasaInteriorBCG[casa];
    if(modelo < 1 || modelo > 11) modelo = 1;
    switch(modelo)
    {
        case 1: { SetPlayerInterior(playerid, 6);  SetPlayerPos(playerid, 2196.84, -1204.36, 1049.02); SetPlayerFacingAngle(playerid, 94.0); }
        case 2: { SetPlayerInterior(playerid, 10); SetPlayerPos(playerid, 2259.38, -1135.89, 1050.64); SetPlayerFacingAngle(playerid, 275.4); }
        case 3: { SetPlayerInterior(playerid, 11); SetPlayerPos(playerid, 2282.99, -1140.28, 1050.89); SetPlayerFacingAngle(playerid, 358.4); }
        case 4: { SetPlayerInterior(playerid, 5);  SetPlayerPos(playerid, 2233.69, -1115.26, 1050.88); SetPlayerFacingAngle(playerid, 358.4); }
        case 5: { SetPlayerInterior(playerid, 1);  SetPlayerPos(playerid, 2218.39, -1076.21, 1050.48); SetPlayerFacingAngle(playerid, 95.2); }
        case 6: { SetPlayerInterior(playerid, 3);  SetPlayerPos(playerid, 2496.00, -1692.08, 1014.74); SetPlayerFacingAngle(playerid, 177.8); }
        case 7: { SetPlayerInterior(playerid, 8);  SetPlayerPos(playerid, 2365.25, -1135.58, 1050.88); SetPlayerFacingAngle(playerid, 359.0); }
        case 8: { SetPlayerInterior(playerid, 9);  SetPlayerPos(playerid, 2317.77, -1026.76, 1050.21); SetPlayerFacingAngle(playerid, 359.0); }
        case 9: { SetPlayerInterior(playerid, 12); SetPlayerPos(playerid, 2324.41, -1149.54, 1050.71); SetPlayerFacingAngle(playerid, 359.0); }
        case 10:{ SetPlayerInterior(playerid, 5);  SetPlayerPos(playerid, 1260.66, -785.40, 1091.90); SetPlayerFacingAngle(playerid, 270.9); }
        case 11:{ SetPlayerInterior(playerid, 5);  SetPlayerPos(playerid, 140.28, 1365.92, 1083.85); SetPlayerFacingAngle(playerid, 9.6); }
    }
    SetPlayerVirtualWorld(playerid, 1000 + casa);
    SetCameraBehindPlayer(playerid);
    return 1;
}

stock BCG_CarregarCasasSalvas()
{
    new arquivo[64];
    for(new i = 0; i < MAX_CASAS_BCG; i++)
    {
        format(arquivo, sizeof arquivo, "Casa_%d.txt", i + 1);
        if(!DOF2_FileExists(arquivo)) continue;
        CasaXBCG[i] = DOF2_GetFloat(arquivo, "X");
        CasaYBCG[i] = DOF2_GetFloat(arquivo, "Y");
        CasaZBCG[i] = DOF2_GetFloat(arquivo, "Z");
        CasaA_BCG[i] = DOF2_GetFloat(arquivo, "A");
        CasaPrecoBCG[i] = DOF2_GetInt(arquivo, "Preco");
        CasaAluguelBCG[i] = DOF2_GetInt(arquivo, "Aluguel");
        CasaInteriorBCG[i] = DOF2_GetInt(arquivo, "Interior");
        if(CasaInteriorBCG[i] < 1 || CasaInteriorBCG[i] > 11) CasaInteriorBCG[i] = 1;
        format(CasaDonoBCG[i], MAX_PLAYER_NAME, "%s", DOF2_GetString(arquivo, "Dono"));
        format(CasaInquilinoBCG[i], MAX_PLAYER_NAME, "%s", DOF2_GetString(arquivo, "Inquilino"));
        if(!strcmp(CasaDonoBCG[i], "(null)", true)) CasaDonoBCG[i][0] = EOS;
        if(!strcmp(CasaInquilinoBCG[i], "(null)", true)) CasaInquilinoBCG[i][0] = EOS;
        CasaExisteBCG[i] = true;
        CasaPickupBCG[i] = CreatePickup(1273, 1, CasaXBCG[i], CasaYBCG[i], CasaZBCG[i], -1);
        BCG_AtualizarLabelCasa(i);
    }
    return 1;
}

stock BCG_CriarCasasMapa()
{
    // LAS VENTURAS - bairros residenciais e arredores
    BCG_CriarCasaMapa(2485.6, -1687.3, 13.3, 90.0, 180000);
    BCG_CriarCasaMapa(2503.2, -1688.1, 13.3, 90.0, 185000);
    BCG_CriarCasaMapa(2521.1, -1687.8, 13.3, 90.0, 190000);
    BCG_CriarCasaMapa(2538.8, -1687.5, 13.3, 90.0, 195000);
    BCG_CriarCasaMapa(2556.5, -1687.0, 13.3, 90.0, 200000);
    BCG_CriarCasaMapa(2470.1, -1710.6, 13.3, 270.0, 175000);
    BCG_CriarCasaMapa(2488.4, -1711.0, 13.3, 270.0, 180000);
    BCG_CriarCasaMapa(2506.8, -1710.7, 13.3, 270.0, 185000);
    BCG_CriarCasaMapa(2525.0, -1710.4, 13.3, 270.0, 190000);
    BCG_CriarCasaMapa(2543.4, -1710.2, 13.3, 270.0, 195000);
    BCG_CriarCasaMapa(2561.5, -1710.0, 13.3, 270.0, 200000);
    BCG_CriarCasaMapa(2579.7, -1710.1, 13.3, 270.0, 210000);
    BCG_CriarCasaMapa(2597.8, -1710.0, 13.3, 270.0, 220000);
    BCG_CriarCasaMapa(2616.0, -1710.0, 13.3, 270.0, 230000);
    BCG_CriarCasaMapa(2634.1, -1710.2, 13.3, 270.0, 240000);
    BCG_CriarCasaMapa(2652.2, -1710.4, 13.3, 270.0, 250000);
    BCG_CriarCasaMapa(2670.4, -1710.5, 13.3, 270.0, 260000);
    BCG_CriarCasaMapa(2688.6, -1710.6, 13.3, 270.0, 270000);
    BCG_CriarCasaMapa(2706.8, -1710.7, 13.3, 270.0, 280000);
    BCG_CriarCasaMapa(2724.9, -1710.8, 13.3, 270.0, 290000);
    BCG_CriarCasaMapa(2743.0, -1710.9, 13.3, 270.0, 300000);
    BCG_CriarCasaMapa(2761.1, -1711.0, 13.3, 270.0, 310000);
    BCG_CriarCasaMapa(2779.3, -1711.1, 13.3, 270.0, 320000);
    BCG_CriarCasaMapa(2797.4, -1711.2, 13.3, 270.0, 330000);
    BCG_CriarCasaMapa(2815.5, -1711.3, 13.3, 270.0, 340000);
    BCG_CriarCasaMapa(2833.6, -1711.4, 13.3, 270.0, 350000);
    BCG_CriarCasaMapa(2851.7, -1711.5, 13.3, 270.0, 360000);
    BCG_CriarCasaMapa(2869.8, -1711.6, 13.3, 270.0, 370000);
    BCG_CriarCasaMapa(2887.9, -1711.7, 13.3, 270.0, 380000);
    BCG_CriarCasaMapa(2906.0, -1711.8, 13.3, 270.0, 390000);
    BCG_CriarCasaMapa(2924.1, -1711.9, 13.3, 270.0, 400000);

    // LOS SANTOS - bairros residenciais
    BCG_CriarCasaMapa(1290.4, -1738.5, 13.5, 0.0, 120000);
    BCG_CriarCasaMapa(1307.8, -1738.5, 13.5, 0.0, 125000);
    BCG_CriarCasaMapa(1325.2, -1738.5, 13.5, 0.0, 130000);
    BCG_CriarCasaMapa(1342.6, -1738.5, 13.5, 0.0, 135000);
    BCG_CriarCasaMapa(1360.0, -1738.5, 13.5, 0.0, 140000);
    BCG_CriarCasaMapa(1377.4, -1738.5, 13.5, 0.0, 145000);
    BCG_CriarCasaMapa(1394.8, -1738.5, 13.5, 0.0, 150000);
    BCG_CriarCasaMapa(1412.2, -1738.5, 13.5, 0.0, 155000);
    BCG_CriarCasaMapa(1429.6, -1738.5, 13.5, 0.0, 160000);
    BCG_CriarCasaMapa(1447.0, -1738.5, 13.5, 0.0, 165000);
    BCG_CriarCasaMapa(1464.4, -1738.5, 13.5, 0.0, 170000);
    BCG_CriarCasaMapa(1481.8, -1738.5, 13.5, 0.0, 175000);
    BCG_CriarCasaMapa(1499.2, -1738.5, 13.5, 0.0, 180000);
    BCG_CriarCasaMapa(1516.6, -1738.5, 13.5, 0.0, 185000);
    BCG_CriarCasaMapa(1534.0, -1738.5, 13.5, 0.0, 190000);
    BCG_CriarCasaMapa(1551.4, -1738.5, 13.5, 0.0, 195000);
    BCG_CriarCasaMapa(1568.8, -1738.5, 13.5, 0.0, 200000);
    BCG_CriarCasaMapa(1586.2, -1738.5, 13.5, 0.0, 205000);
    BCG_CriarCasaMapa(1603.6, -1738.5, 13.5, 0.0, 210000);
    BCG_CriarCasaMapa(1621.0, -1738.5, 13.5, 0.0, 215000);
    BCG_CriarCasaMapa(1638.4, -1738.5, 13.5, 0.0, 220000);
    BCG_CriarCasaMapa(1655.8, -1738.5, 13.5, 0.0, 225000);
    BCG_CriarCasaMapa(1673.2, -1738.5, 13.5, 0.0, 230000);
    BCG_CriarCasaMapa(1690.6, -1738.5, 13.5, 0.0, 235000);
    BCG_CriarCasaMapa(1708.0, -1738.5, 13.5, 0.0, 240000);
    BCG_CriarCasaMapa(1725.4, -1738.5, 13.5, 0.0, 245000);
    BCG_CriarCasaMapa(1742.8, -1738.5, 13.5, 0.0, 250000);
    BCG_CriarCasaMapa(1760.2, -1738.5, 13.5, 0.0, 255000);
    BCG_CriarCasaMapa(1777.6, -1738.5, 13.5, 0.0, 260000);
    BCG_CriarCasaMapa(1795.0, -1738.5, 13.5, 0.0, 265000);
    BCG_CriarCasaMapa(1812.4, -1738.5, 13.5, 0.0, 270000);
    BCG_CriarCasaMapa(1829.8, -1738.5, 13.5, 0.0, 275000);
    BCG_CriarCasaMapa(1847.2, -1738.5, 13.5, 0.0, 280000);
    BCG_CriarCasaMapa(1864.6, -1738.5, 13.5, 0.0, 285000);
    BCG_CriarCasaMapa(1882.0, -1738.5, 13.5, 0.0, 290000);
    BCG_CriarCasaMapa(1899.4, -1738.5, 13.5, 0.0, 295000);
    BCG_CriarCasaMapa(1916.8, -1738.5, 13.5, 0.0, 300000);
    BCG_CriarCasaMapa(1934.2, -1738.5, 13.5, 0.0, 305000);
    BCG_CriarCasaMapa(1951.6, -1738.5, 13.5, 0.0, 310000);
    BCG_CriarCasaMapa(1969.0, -1738.5, 13.5, 0.0, 315000);
    BCG_CriarCasaMapa(1986.4, -1738.5, 13.5, 0.0, 320000);

    // SAN FIERRO - bairros e avenidas residenciais
    BCG_CriarCasaMapa(-1960.5, 137.2, 27.7, 90.0, 140000);
    BCG_CriarCasaMapa(-1942.2, 137.4, 27.7, 90.0, 145000);
    BCG_CriarCasaMapa(-1923.9, 137.6, 27.7, 90.0, 150000);
    BCG_CriarCasaMapa(-1905.6, 137.8, 27.7, 90.0, 155000);
    BCG_CriarCasaMapa(-1887.3, 138.0, 27.7, 90.0, 160000);
    BCG_CriarCasaMapa(-1869.0, 138.2, 27.7, 90.0, 165000);
    BCG_CriarCasaMapa(-1850.7, 138.4, 27.7, 90.0, 170000);
    BCG_CriarCasaMapa(-1832.4, 138.6, 27.7, 90.0, 175000);
    BCG_CriarCasaMapa(-1814.1, 138.8, 27.7, 90.0, 180000);
    BCG_CriarCasaMapa(-1795.8, 139.0, 27.7, 90.0, 185000);
    BCG_CriarCasaMapa(-1777.5, 139.2, 27.7, 90.0, 190000);
    BCG_CriarCasaMapa(-1759.2, 139.4, 27.7, 90.0, 195000);
    BCG_CriarCasaMapa(-1740.9, 139.6, 27.7, 90.0, 200000);
    BCG_CriarCasaMapa(-1722.6, 139.8, 27.7, 90.0, 205000);
    BCG_CriarCasaMapa(-1704.3, 140.0, 27.7, 90.0, 210000);
    BCG_CriarCasaMapa(-1686.0, 140.2, 27.7, 90.0, 215000);
    BCG_CriarCasaMapa(-1667.7, 140.4, 27.7, 90.0, 220000);
    BCG_CriarCasaMapa(-1649.4, 140.6, 27.7, 90.0, 225000);
    BCG_CriarCasaMapa(-1631.1, 140.8, 27.7, 90.0, 230000);
    BCG_CriarCasaMapa(-1612.8, 141.0, 27.7, 90.0, 235000);
    BCG_CriarCasaMapa(-1594.5, 141.2, 27.7, 90.0, 240000);
    BCG_CriarCasaMapa(-1576.2, 141.4, 27.7, 90.0, 245000);
    BCG_CriarCasaMapa(-1557.9, 141.6, 27.7, 90.0, 250000);
    BCG_CriarCasaMapa(-1539.6, 141.8, 27.7, 90.0, 255000);
    BCG_CriarCasaMapa(-1521.3, 142.0, 27.7, 90.0, 260000);
    BCG_CriarCasaMapa(-1503.0, 142.2, 27.7, 90.0, 265000);
    BCG_CriarCasaMapa(-1484.7, 142.4, 27.7, 90.0, 270000);
    BCG_CriarCasaMapa(-1466.4, 142.6, 27.7, 90.0, 275000);
    BCG_CriarCasaMapa(-1448.1, 142.8, 27.7, 90.0, 280000);
    BCG_CriarCasaMapa(-1429.8, 143.0, 27.7, 90.0, 285000);

    // INTERIOR DE SAN ANDREAS / AREAS RURAIS E CIDADES MENORES
    BCG_CriarCasaMapa(621.8, -1850.4, 4.1, 180.0, 90000);
    BCG_CriarCasaMapa(650.5, -1850.7, 4.1, 180.0, 95000);
    BCG_CriarCasaMapa(679.2, -1851.0, 4.1, 180.0, 100000);
    BCG_CriarCasaMapa(707.9, -1851.3, 4.1, 180.0, 105000);
    BCG_CriarCasaMapa(736.6, -1851.6, 4.1, 180.0, 110000);
    BCG_CriarCasaMapa(765.3, -1851.9, 4.1, 180.0, 115000);
    BCG_CriarCasaMapa(794.0, -1852.2, 4.1, 180.0, 120000);
    BCG_CriarCasaMapa(822.7, -1852.5, 4.1, 180.0, 125000);
    BCG_CriarCasaMapa(851.4, -1852.8, 4.1, 180.0, 130000);
    BCG_CriarCasaMapa(880.1, -1853.1, 4.1, 180.0, 135000);
    BCG_CriarCasaMapa(908.8, -1853.4, 4.1, 180.0, 140000);
    BCG_CriarCasaMapa(937.5, -1853.7, 4.1, 180.0, 145000);
    BCG_CriarCasaMapa(966.2, -1854.0, 4.1, 180.0, 150000);
    BCG_CriarCasaMapa(994.9, -1854.3, 4.1, 180.0, 155000);
    BCG_CriarCasaMapa(1023.6, -1854.6, 4.1, 180.0, 160000);
    BCG_CriarCasaMapa(1052.3, -1854.9, 4.1, 180.0, 165000);
    BCG_CriarCasaMapa(1081.0, -1855.2, 4.1, 180.0, 170000);
    BCG_CriarCasaMapa(1109.7, -1855.5, 4.1, 180.0, 175000);
    BCG_CriarCasaMapa(1138.4, -1855.8, 4.1, 180.0, 180000);
    BCG_CriarCasaMapa(1167.1, -1856.1, 4.1, 180.0, 185000);
    return 1;
}

stock BCG_AtualizarLabelCasa(casa)
{
    new texto[512];
    if(!CasaExisteBCG[casa]) return 0;

    if(strlen(CasaDonoBCG[casa]) > 0)
    {
        if(CasaAluguelBCG[casa] > 0)
            format(texto, sizeof(texto), "{D4AF37}IMPERIO ROLEPLAY\n{FFFFFF}Casa #{D4AF37}%d\n{FFFFFF}Proprietario: {D4AF37}%s\n{FFFFFF}Aluguel: {00FF66}R$%d\n{BDBDBD}Use H para entrar\n{FFFFFF}/alugarcasa", casa + 1, CasaDonoBCG[casa], CasaAluguelBCG[casa]);
        else
            format(texto, sizeof(texto), "{D4AF37}IMPERIO ROLEPLAY\n{FFFFFF}Casa #{D4AF37}%d\n{FFFFFF}Proprietario: {D4AF37}%s\n{FF5555}Aluguel desativado\n{BDBDBD}Use H para entrar", casa + 1, CasaDonoBCG[casa]);
    }
    else
    {
        format(texto, sizeof(texto), "{D4AF37}IMPERIO ROLEPLAY\n{FFFFFF}Casa #{D4AF37}%d\n{00FF66}DISPONIVEL PARA COMPRA\n{FFFFFF}Valor: {00FF66}R$%d\n{FFFFFF}Interior: {D4AF37}%d\n{BDBDBD}Use /comprarcasa", casa + 1, CasaPrecoBCG[casa], CasaInteriorBCG[casa]);
    }

    if(_:CasaLabelBCG[casa] != 0) Delete3DTextLabel(CasaLabelBCG[casa]);
    CasaLabelBCG[casa] = Create3DTextLabel(texto, -1, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa] + 1.05, 25.0, 0, 0);
    return 1;
}

stock BCG_CasaProxima(playerid, Float:distancia_maxima = 15.0)
{
    new casa = -1;
    new Float:menor = distancia_maxima;
    for(new i = 0; i < MAX_CASAS_BCG; i++)
    {
        if(!CasaExisteBCG[i]) continue;
        new Float:d = GetPlayerDistanceFromPoint(playerid, CasaXBCG[i], CasaYBCG[i], CasaZBCG[i]);
        if(d <= menor)
        {
            menor = d;
            casa = i;
        }
    }
    return casa;
}

CMD:criarcasa(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new precoCasa, interiorCasa;
    if(sscanf(params, "ii", precoCasa, interiorCasa))
        return SendClientMessage(playerid, -1, "[CASAS] Use: /criarcasa [preco] [interior 1-11] | /interiorescasas");
    if(interiorCasa < 1 || interiorCasa > 11) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Interior invalido. Escolha de 1 a 11.");
    if(precoCasa < 1) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Preco invalido.");

    new casa = -1;
    for(new i = 0; i < MAX_CASAS_BCG; i++) if(!CasaExisteBCG[i]) { casa = i; break; }
    if(casa == -1) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Limite de casas atingido.");

    GetPlayerPos(playerid, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa]);
    GetPlayerFacingAngle(playerid, CasaA_BCG[casa]);
    CasaPrecoBCG[casa] = precoCasa;
    CasaAluguelBCG[casa] = 0;
    CasaInteriorBCG[casa] = interiorCasa;
    CasaDonoBCG[casa][0] = EOS;
    CasaInquilinoBCG[casa][0] = EOS;
    CasaExisteBCG[casa] = true;
    CasaPickupBCG[casa] = CreatePickup(1273, 1, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa], -1);
    BCG_AtualizarLabelCasa(casa);

    new arquivo[64];
    format(arquivo, sizeof(arquivo), "Casa_%d.txt", casa + 1);
    if(!DOF2_FileExists(arquivo)) DOF2_CreateFile(arquivo);
    DOF2_SetFloat(arquivo, "X", CasaXBCG[casa]); DOF2_SetFloat(arquivo, "Y", CasaYBCG[casa]);
    DOF2_SetFloat(arquivo, "Z", CasaZBCG[casa]); DOF2_SetFloat(arquivo, "A", CasaA_BCG[casa]);
    DOF2_SetInt(arquivo, "Preco", precoCasa); DOF2_SetInt(arquivo, "Aluguel", 0);
    DOF2_SetInt(arquivo, "Interior", interiorCasa); DOF2_SetString(arquivo, "Dono", "");
    DOF2_SetString(arquivo, "Inquilino", ""); DOF2_SaveFile();

    new msg[144]; format(msg, sizeof(msg), "[CASAS] Casa #%d criada. Preco: R$%d | Interior: %d", casa + 1, precoCasa, interiorCasa);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

CMD:interiorescasas(playerid, params[])
{
    SendClientMessage(playerid, -1, "[CASAS] 1 Pequena | 2 Media A | 3 Media B | 4 Moderna | 5 Simples | 6 CJ");
    SendClientMessage(playerid, -1, "[CASAS] 7 Grande A | 8 Grande B | 9 Grande C | 10 Mansao | 11 Mansao 2");
    return 1;
}

CMD:deletarcasa(playerid, params[])
{
    if(Pdados[playerid][Admin] < 2) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Sem permissao.");
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, -1, "[CASAS] Use: /deletarcasa [numero]");
    id--;
    if(id < 0 || id >= MAX_CASAS_BCG || !CasaExisteBCG[id]) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Casa inexistente.");
    if(_:CasaLabelBCG[id] != 0) Delete3DTextLabel(CasaLabelBCG[id]);
    if(CasaPickupBCG[id] != 0) DestroyPickup(CasaPickupBCG[id]);
    CasaExisteBCG[id] = false;
    new arquivo[64]; format(arquivo, sizeof(arquivo), "Casa_%d.txt", id + 1);
    if(DOF2_FileExists(arquivo)) fremove(arquivo);
    SendClientMessage(playerid, 0x00FF00FF, "[CASAS] Casa deletada com sucesso.");
    return 1;
}

CMD:comprarcasa(playerid, params[])
{
    new casa = BCG_CasaProxima(playerid);
    if(casa == -1) return SendClientMessage(playerid, -1, "[CASAS] Voce nao esta perto de uma casa.");
    if(strlen(CasaDonoBCG[casa]) > 0) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Esta casa ja possui dono.");
    if(GetPlayerMoney(playerid) < CasaPrecoBCG[casa]) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Dinheiro insuficiente.");
    GivePlayerMoney(playerid, -CasaPrecoBCG[casa]);
    format(CasaDonoBCG[casa], MAX_PLAYER_NAME, "%s", Nome(playerid));
    CasaAluguelBCG[casa] = 0;
    CasaInquilinoBCG[casa][0] = EOS;
    new arquivo[64]; format(arquivo, sizeof(arquivo), "Casa_%d.txt", casa + 1);
    DOF2_SetString(arquivo, "Dono", CasaDonoBCG[casa]); DOF2_SetInt(arquivo, "Aluguel", 0); DOF2_SetString(arquivo, "Inquilino", ""); DOF2_SaveFile();
    BCG_AtualizarLabelCasa(casa);
    SendClientMessage(playerid, 0x00FF00FF, "[CASAS] Casa comprada! Agora voce decide se deseja disponibiliza-la para aluguel com /aluguel [valor].");
    return 1;
}

CMD:aluguel(playerid, params[])
{
    new casa = BCG_CasaProxima(playerid);
    if(casa == -1) return SendClientMessage(playerid, -1, "[CASAS] Va ate a entrada da sua casa para configurar o aluguel.");
    if(strcmp(CasaDonoBCG[casa], Nome(playerid), true) != 0) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Somente o proprietario pode definir o aluguel.");
    new valor;
    if(sscanf(params, "i", valor)) return SendClientMessage(playerid, -1, "[CASAS] Use: /aluguel [valor] | Use 0 para desativar.");
    if(valor < 0 || valor > 10000000) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Valor de aluguel invalido.");
    CasaAluguelBCG[casa] = valor;
    new arquivo[64]; format(arquivo, sizeof(arquivo), "Casa_%d.txt", casa + 1);
    DOF2_SetInt(arquivo, "Aluguel", valor); DOF2_SaveFile();
    BCG_AtualizarLabelCasa(casa);
    if(valor == 0) SendClientMessage(playerid, 0xFFFF00FF, "[CASAS] Aluguel desativado. Sua casa nao esta mais disponivel para alugar.");
    else { new msg[128]; format(msg, sizeof(msg), "[CASAS] Aluguel definido em R$%d.", valor); SendClientMessage(playerid, 0x00FF00FF, msg); }
    return 1;
}

CMD:alugarcasa(playerid, params[])
{
    new casa = BCG_CasaProxima(playerid);
    if(casa == -1) return SendClientMessage(playerid, -1, "[CASAS] Voce nao esta perto de uma casa.");
    if(strlen(CasaDonoBCG[casa]) == 0) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Esta casa esta a venda, nao para aluguel.");
    if(!strcmp(CasaDonoBCG[casa], Nome(playerid), true)) return SendClientMessage(playerid, -1, "[CASAS] Voce e o dono desta casa.");
    if(CasaAluguelBCG[casa] <= 0) return SendClientMessage(playerid, -1, "[CASAS] O proprietario nao disponibilizou esta casa para aluguel.");
    if(GetPlayerMoney(playerid) < CasaAluguelBCG[casa]) return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Dinheiro insuficiente para pagar o aluguel.");
    GivePlayerMoney(playerid, -CasaAluguelBCG[casa]);
    format(CasaInquilinoBCG[casa], MAX_PLAYER_NAME, "%s", Nome(playerid));
    new arquivo[64]; format(arquivo, sizeof(arquivo), "Casa_%d.txt", casa + 1);
    DOF2_SetString(arquivo, "Inquilino", CasaInquilinoBCG[casa]); DOF2_SaveFile();
    BCG_AtualizarLabelCasa(casa);
    SendClientMessage(playerid, 0x00FF00FF, "[CASAS] Aluguel pago. Voce agora tem acesso a esta casa.");
    return 1;
}

CMD:casa(playerid, params[])
{
    // Dentro da casa: /casa funciona como saida.
    new mundo = GetPlayerVirtualWorld(playerid);
    if(mundo >= 1000 && mundo < 1000 + MAX_CASAS_BCG)
    {
        new casa = mundo - 1000;
        if(casa >= 0 && casa < MAX_CASAS_BCG && CasaExisteBCG[casa])
        {
            SetPlayerInterior(playerid, 0);
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerPos(playerid, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa]);
            SetPlayerFacingAngle(playerid, CasaA_BCG[casa]);
            SendClientMessage(playerid, 0x00FF00FF, "[CASA] Voce saiu da casa.");
            return 1;
        }
    }

    new casa = BCG_CasaProxima(playerid, 10.0);
    if(casa == -1) return SendClientMessage(playerid, -1, "[CASAS] Voce nao esta perto de uma casa.");

    // Casa sem dono pode ser visitada. Casa com dono exige dono ou inquilino.
    if(strlen(CasaDonoBCG[casa]) > 0 &&
       strcmp(CasaDonoBCG[casa], Nome(playerid), true) != 0 &&
       strcmp(CasaInquilinoBCG[casa], Nome(playerid), true) != 0)
        return SendClientMessage(playerid, 0xFF3030FF, "[CASAS] Esta casa possui dono. Voce nao tem acesso.");

    BCG_SetPosInteriorCasa(playerid, casa);
    SendClientMessage(playerid, 0x00FF00FF, "[CASAS] Voce entrou na casa. Aperte H ou use /casa para sair.");
    return 1;
}

CMD:entrarcasa(playerid, params[])
{
    return cmd_casa(playerid, params);
}

CMD:saircasa(playerid, params[])
{
    if(GetPlayerVirtualWorld(playerid) < 1000 || GetPlayerVirtualWorld(playerid) >= 1000 + MAX_CASAS_BCG)
        return SendClientMessage(playerid, -1, "[CASAS] Voce nao esta dentro de uma casa.");
    new casa = GetPlayerVirtualWorld(playerid) - 1000;
    if(casa < 0 || casa >= MAX_CASAS_BCG || !CasaExisteBCG[casa]) return 1;
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa]);
    return 1;
}

CMD:criarhp(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new hospital = -1;
    for(new i = 0; i < MAX_HOSPITAIS_BCG; i++)
    {
        if(!HospitalBCG[i]) { hospital = i; break; }
    }
    if(hospital == -1) return SendClientMessage(playerid, 0xFF3030FF, "[HOSPITAL] Limite de hospitais atingido.");

    GetPlayerPos(playerid, HospitalXBCG[hospital], HospitalYBCG[hospital], HospitalZBCG[hospital]);
    GetPlayerFacingAngle(playerid, HospitalABCG[hospital]);
    HospitalBCG[hospital] = true;
    HospitalPickupBCG[hospital] = CreatePickup(1318, 1, HospitalXBCG[hospital], HospitalYBCG[hospital], HospitalZBCG[hospital], -1);
    BCG_AtualizarLabelHospital(hospital);
    BCG_SalvarHospital(hospital);

    new msg[144];
    format(msg, sizeof(msg), "[HOSPITAL] Hospital #%d criado. Use H para entrar.", hospital + 1);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

CMD:deletarhp(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, -1, "[HOSPITAL] Use: /deletarhp [numero]");
    id--;
    if(id < 0 || id >= MAX_HOSPITAIS_BCG || !HospitalBCG[id]) return SendClientMessage(playerid, 0xFF3030FF, "[HOSPITAL] Hospital inexistente.");

    if(_:HospitalLabelBCG[id] != 0) Delete3DTextLabel(HospitalLabelBCG[id]);
    if(HospitalPickupBCG[id] != 0) DestroyPickup(HospitalPickupBCG[id]);
    HospitalBCG[id] = false;
    HospitalPickupBCG[id] = 0;

    new arquivo[64];
    format(arquivo, sizeof(arquivo), "Hospital_%d.txt", id + 1);
    if(DOF2_FileExists(arquivo)) fremove(arquivo);
    SendClientMessage(playerid, 0x00FF00FF, "[HOSPITAL] Hospital deletado com sucesso.");
    return 1;
}

CMD:criarorg(playerid, params[])
{
    if(!Pdados[playerid][Logado])
        return SendClientMessage(playerid, 0x8B0000FF, "[ORG] Voce precisa estar logado para criar uma organizacao.");

    if(Pdados[playerid][OrgID] != 0)
        return SendClientMessage(playerid, 0x8B0000FF, "[ORG] Voce ja pertence a uma organizacao. Saia dela antes de criar outra.");

    if(strlen(params) < 3 || strlen(params) > 32)
        return SendClientMessage(playerid, 0x8B0000FF, "[ORG] Use /criarorg [nome da organizacao] (3 a 32 caracteres).");

    // Procura um nome livre para evitar duas orgs com o mesmo nome.
    for(new i = ORG_CUSTOM_INICIO; i <= ORG_CUSTOM_FIM; i++)
    {
        if(OrgCustomAtiva[i] && strcmp(OrgCustomNome[i], params, true) == 0)
            return SendClientMessage(playerid, 0x8B0000FF, "[ORG] Ja existe uma organizacao com esse nome.");
    }

    new orgid = -1;
    for(new i = ORG_CUSTOM_INICIO; i <= ORG_CUSTOM_FIM; i++)
    {
        if(!OrgCustomAtiva[i]) { orgid = i; break; }
    }
    if(orgid == -1)
        return SendClientMessage(playerid, 0x8B0000FF, "[ORG] Todas as 15 vagas de orgs personalizadas estao ocupadas.");

    OrgCustomAtiva[orgid] = true;
    format(OrgCustomNome[orgid], 40, "%s", params);
    OrgCustomCor[orgid] = OrgCustomCores[orgid - ORG_CUSTOM_INICIO];

    Pdados[playerid][OrgID] = orgid;
    Pdados[playerid][Cargo] = 5;
    BCG_SalvarOrgPersonalizada(orgid);
    SalvarDados(playerid);
    BCG_AplicarCorOrg(playerid);

    new msg[180];
    format(msg, sizeof(msg), "{7A4E9B}[ORG] {FFFFFF}Voce criou a org {7A4E9B}%s {FFFFFF}(ID %d). Cor exclusiva escura aplicada.", OrgCustomNome[orgid], orgid);
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "{7A4E9B}[ORG] {FFFFFF}%s criou a organizacao {7A4E9B}%s{FFFFFF}.", Nome(playerid), OrgCustomNome[orgid]);
    SendClientMessageToAll(-1, msg);
    return 1;
}

CMD:orgs(playerid)
{
    // Menu principal do /orgs - cores solicitadas.
    new menuStr[768];
    menuStr[0] = EOS;

    strcat(menuStr, "Categoria\tOrganizacoes\n");
    strcat(menuStr, "{FFFFFF}CORP\t{FFFFFF}5 organizacoes\n");
    strcat(menuStr, "{FFFFFF}GANGSTER\t{FFFFFF}9 organizacoes\n");
    strcat(menuStr, "{FFFFFF}TERRORISTA\t{FFFFFF}2 organizacoes\n");
    strcat(menuStr, "{FFFFFF}MERCENARIA\t{FFFFFF}3 organizacoes\n");
    strcat(menuStr, "{FFFFFF}MAFIA\t{FFFFFF}3 organizacoes\n");
    strcat(menuStr, "{2F4F4F}ORG PERSONALIZADA\t{FFFFFF}15 slots");

    ShowPlayerDialog(playerid, DIALOG_ORGS_MAIN, DIALOG_STYLE_TABLIST_HEADERS,
        "{FFFFFF}/ORGS {696969}| {FFFFFF}ESCOLHA UMA CATEGORIA",
        menuStr, "Selecionar", "Fechar");
    return 1;
}

stock BCG_ListaOrgs(playerid, dialogid, const titulo[], const lista[])
{
    #pragma unused titulo
    new tabela[4096];
    format(tabela, sizeof(tabela), "ORGANIZACAO\tLider\tMembros\n%s", lista);
    ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}BCG Roleplay >> Organizacoes", tabela, "Fechar", "");
    return 1;
}

CMD:comprarac(playerid)
{
	if (IsPlayerInRangeOfPoint(playerid, 4.0, -2237.031494,130.176788,1035.414062))
    ShowPlayerDialog(playerid, 2020, DIALOG_STYLE_LIST, "Loja de Acessorios ", "TOCA NATAL\nCHAPEU GALO\nCHAPEU PRETO\nLORO\nGUITARA\nPA\nCHOQUE", "equipar", "cancelar");
    return 1;
}

CMD:roubarl(playerid)
{
    // 1. Verificacoes de Seguranca e Organizacao Criminosa
    if(!Pdados[playerid][Logado]) 
        return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce precisa estar logado!");

    new org = Pdados[playerid][OrgID];
    
    // Verificacao das Orgs Criminosas (27 a 32)
    if(!(org >= 27 && org <= 32))
    {
        return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce nao participa de uma organizacao Gangstar/Criminosa!");
    }

    // 2. Verificacao de Localizacao
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, 820.559204, 11.162190, 1004.193908)) 
        return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce nao esta no Cofre da Prefeitura!!");

    // 3. Verificacao de Cooldown
    if(UsouComando[playerid] > gettime()) 
        return SendClientMessage(playerid, -1, "Aguarde para roubar novamente!");

    // --- Inicio do Roubo ---
    UsouComando[playerid] = gettime() + 600;
    SetTimerEx("Assaltando", 30000, 0, "i", playerid);
    
    // Animacao e Objetos
    SetPlayerAttachedObject(playerid, 3, 1550, 1, 0.104999, -0.252000, -0.022000, 4.000002, 85.400070, -5.299997);
    SetPlayerAttachedObject(playerid, 0, 19090, 2, -0.315999, 0.019999, 0.030000, 0.000000, 0.000000, 0.000000, 1.455999, 0.526000, 0.541000);
    ApplyAnimation(playerid, "ROB_BANK", "CAT_Safe_Rob", 4.1, 1, 0, 0, 0, 0);

    // 4. Preparacao das Mensagens
    new chatString[144], screenString[128], pNome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pNome, sizeof(pNome));

    // Mensagem na Tela (Para todos)
    format(screenString, sizeof(screenString), "~w~%s ~r~esta roubando a loterica", pNome);
    GameTextForAll(screenString, 5000, 3);

    // Mensagem de Notificacao para a Policia (Orgs 1 a 12)
    format(chatString, sizeof(chatString), "[ASSALTO] %s e o %s estao roubando a Loterica!", pNome, NomeOrg(playerid));
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            // Se o jogador 'i' for de uma organizacao policial (1 a 12)
            if(Pdados[i][OrgID] >= 1 && Pdados[i][OrgID] <= 12)
            {
                SendClientMessage(i, 0xE74C3CFF, chatString); // Cor Vermelha para alerta
            }
        }
    }

    SendClientMessage(playerid, -1, "| ROUBO | Voce esta roubando o cofre, a policia foi notificada!");
    
    return 1;
}

CMD:roubarr(playerid)
{
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, 214.538421,-160.595489,1000.523437)) return SendClientMessage(playerid,0xE74C3CFF,"[ERRO] Voce nao esta no Cofre da loja de roupas!!");
	if(UsouComando[playerid] > gettime()) return SendClientMessage(playerid, -1,  "Voce usou este comando recentemente. Aguarde alguns segundos para usa-lo novamente!");
	UsouComando[playerid] = gettime() + 600;
	SetTimerEx("Assaltando", 30000, 0, "i", playerid);
	SendClientMessage(playerid, -1,  "| ROUBO | Voce esta Roubando um Cofre!!");
	SetPlayerAttachedObject(playerid, 3, 1550, 1, 0.104999, -0.252000, -0.022000, 4.000002, 85.400070, -5.299997);
	SetPlayerAttachedObject(playerid, 0, 19090, 2, -0.315999, 0.019999, 0.030000, 0.000000, 0.000000, 0.000000, 1.455999, 0.526000, 0.541000);
	ApplyAnimation(playerid,"ROB_BANK","CAT_Safe_Rob",4.1,1,0,0,0,0);
	ApplyAnimation(playerid,"ROB_BANK","CAT_Safe_Rob",4.1,1,0,0,0,0);
	new name[ 24 ], string[ 64 ];
    GetPlayerName( playerid, name, 24 );
	format( string, sizeof(string), "~w~%s iniciou um roubo a loja de roupas", name );
    GameTextForAll( string, 5000, 3 );
	return 1;
}
BPF::Assaltando(playerid)
{
	ClearAnimations(playerid);
	SendClientMessage(playerid, 0xC11D1DFF, "| ROUBO | Voce Roubou um Cofre e faturou 10000 com esse roubo!!");
	GivePlayerMoney(playerid, 10000);
	SetPlayerWantedLevel(playerid, 6);
	return 1;
}
CMD:ppd(playerid)
{
if(Pizzas[playerid] == 1) {
SendClientMessage(playerid,-1,"| ERRO | Voce ja pegou um pedido, entregue-a!");
return 1;
}
if(IsPlayerInRangeOfPoint(playerid, 10.0, 1199.5811, -918.6766, 43.1170))
{
if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 510)
{
new string[128];
new rand = random(sizeof(CheckPointsP));
Pizzas[playerid] = 1;
GanhaGorjeta[playerid] = 1;
timerGorjeta[playerid] = SetTimerEx("GanhaGorjeta1", 60000, false, "i", playerid);
new Float: Distancia = GetPlayerDistanceFromPoint(playerid,CheckPointsP[rand][0],CheckPointsP[rand][1],CheckPointsP[rand][2]);
SetPlayerRaceCheckpoint(playerid, 1, CheckPointsP[rand][0],CheckPointsP[rand][1],CheckPointsP[rand][2], 0, 0, 0, 3.10);
format(string,sizeof(string),"{FFFFFF}A pedidos para entregar a {30F72D}%0.2f {FFFFFF}metros ,siga o checkpoint para entrega-la",Distancia);
ShowPlayerDialog(playerid, 45, DIALOG_STYLE_MSGBOX, "{FFA500}pedidos", string, "Pegar", "");
return 1;
}
else return SendClientMessage(playerid,-1,"| ERRO | Voce nao esta na moto no veiculo dos ifood");
}
else return SendClientMessage(playerid,-1,"| ERRO | Voce nao esta no local de pegar a pedidos");
}

forward GanhaGorjeta1(playerid);
public GanhaGorjeta1(playerid)
{
GanhaGorjeta[playerid] = 0;
return 1;
}

forward EntregarPizza(playerid);
public EntregarPizza(playerid)
{
    // Libera o jogador e limpa o ambiente
    TogglePlayerControllable(playerid, 1);
    DisablePlayerRaceCheckpoint(playerid);
    KillTimer(timerGorjeta[playerid]);

    new string[144];
    new PagamentoBase = 60 + random(40); // Valor entre 60 e 100
    new Gorjeta = 0;

    if(GanhaGorjeta[playerid] == 1)
    {
        Gorjeta = 10 + random(20); // Gorjeta entre 10 e 30
        format(string, sizeof(string), "| IFOOD | Entrega feita! Recebeu: $%d + Gorjeta: $%d.", PagamentoBase, Gorjeta);
    }
    else
    {
        format(string, sizeof(string), "| IFOOD | Entrega feita! Recebeu: $%d. (Sem gorjeta: demorou demais)", PagamentoBase);
    }

    GivePlayerMoney(playerid, PagamentoBase + Gorjeta);
    SendClientMessage(playerid, -1, string);
    SendClientMessage(playerid, -1, "{FFFF00}DICA: {FFFFFF}Volte para a HQ para pegar mais pedidos.");
    
    GanhaGorjeta[playerid] = 0;
    return 1;
}



CMD:lsgrana(playerid)
{
    new veiculo = GetPlayerVehicleID(playerid);
	if(Gari[playerid] == 0) return SendClientMessage(playerid,VERMELHO,"ERRO: Voce nao e um transportado de dinheiro!");
	if(carroforte[playerid] == 0){
	if(IsPlayerInRangeOfPoint(playerid, 10.0, 1667.4336,982.0659,10.8203)){
    if(veiculo == CarGari[0] || veiculo == CarGari[1] || veiculo == CarGari[2] || veiculo == CarGari[3])
	{
	    SendClientMessage(playerid,AZUL_CLARO,"INFO: Voce iniciou seu servico, leve o dinheiro no banco de los santos");
		carroforte[playerid] = 1;
		SetPlayerRaceCheckpoint(playerid, 1, 947.5123,-1755.3889,13.5469, 000.0000,0000.0000,00.0000, 5);
		format(String,sizeof(String),"O transportador de valores %s iniciou uma rota para banco de los santos",Nome(playerid));
		SendClientMessageToAll(0xffffffff, String);
		return 1;
    }else{
	SendClientMessage(playerid,VERMELHO,"ERRO: Voce nao esta no local para carregar malote");
	}
	}else{
	SendClientMessage(playerid,VERMELHO,"ERRO: Voce precisa esta em um veiculo do carro forte!");
	}
	}else{
	SendClientMessage(playerid,VERMELHO,"ERRO: Voce ja pegou o malote de dinheiro");
	}
	return 1;

}
CMD:mochila(playerid, params[])
{
    if(BCG36Client[playerid])return BCG43Inventory(playerid);
    // Se o jogador nao tiver a mochila comprada, nem deixa

    // AQUI ESTa O SEGREDO: Em vez de abrir a lista direto, 
    // chamamos a Dialog que cria as abas da foto (DIALOG_BOLSOS)
    // Substitua "FuncaoQueAbreMenuDaFoto(playerid);" pela funcao real que abre o menu com as abas no seu servidor.
    // Se for direto por ShowPlayerDialog, use o formato abaixo:
    
    // Exemplo (Ajuste o texto para as categorias reais do seu servidor):
    ShowPlayerDialog(playerid, DIALOG_BOLSOS, DIALOG_STYLE_LIST, "Menu de Bolsos", "Armas\nDrogas\nMochila\nOutros", "Selecionar", "Fechar");
    return 1;
}



CMD:rmochila(playerid)
{
    if(IsPlayerAttachedObjectSlotUsed(playerid, 1))
        RemovePlayerAttachedObject(playerid, 1);
    SendClientMessage(playerid, AMARELO, "Mochila visual removida. Seu inventario continua disponivel pela tecla Y.");
    return 1;
}
CMD:abrir(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 10.0, -1529.6000000,482.2000100,9.0000000)){
    if(Pdados[playerid][OrgID] == 1){
    MoveObject(portaoeb, -1529.6000000,482.2000100, 3,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaoeb);
    }else{
    }
    }else{
    }
    
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 1878.7000000,703.4000200,12.5000000)){
    if(Pdados[playerid][OrgID] == 2){
    MoveObject(portaobope, 1878.7000000,703.4000200, 7.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaobope);
    }else{
    }
    }else{
    }
    
    
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 2775.7000000,913.2999900,12.6000000)){
    if(Pdados[playerid][OrgID] == 5){
    MoveObject(portaopm, 2775.7000000,913.2999900,7.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaopm);
    }else{
    }
    }else{
    }
    
    
    if(IsPlayerInRangeOfPoint(playerid, 10.0, -489.6000100,-562.5999800,27.3333300)){
    if(Pdados[playerid][OrgID] == 8){
    MoveObject(portaopf, -489.6000100,-562.5999800,21.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaopf);
    }else{
    }
    }else{
    }
    if(IsPlayerInRangeOfPoint(playerid, 10.0, -2487.8999000,-614.7000100,134.3000000)){
    if(Pdados[playerid][OrgID] == 11){
    MoveObject(portaorotam, -2487.8999000,-614.7000100,128.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaorotam);
    }else{
    }
    }else{
    }
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 924.7000100,-1220.9000000,18.7000000)){
    if(Pdados[playerid][OrgID] == 28){
    MoveObject(portaomt, 924.7000100,-1220.9000000,13.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaomt);
    }else{
    }
    }else{
    }
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 979.7999900,-1445.4000000,15.3000000)){
    if(Pdados[playerid][OrgID] == 33){
    MoveObject(portaomec, 979.7999900,-1445.4000000,9.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaomec);
    }else{
    }
    }else{
    }
    
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 1541.9, -1627.9, 15.2)){
    if(Pdados[playerid][OrgID] == 9){
    MoveObject(portaopc, 1541.9, -1627.9, 9.0,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaopc);
    }else{
    }
    }else{
    }
    
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 2826.7000000,-1183.4000000,26.8000000)){
    if(Pdados[playerid][OrgID] == 31){
    MoveObject(portaoada, 2826.7000000,-1183.4000000,21.0000000,3.0);
    SetTimerEx("GateClose", 5000, false, "i", portaoada);
    }else{
    }
    }else{
    }
	return 1;
}
CMD:subir(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 2804.7417,-1178.5381,25.4753)){
    if(Pdados[playerid][OrgID] == 31){
    SetPlayerPos(playerid, 2804.7434,-1175.1790,32.6688);
    }else{
    }
    }else{
    }
	return 1;
}
CMD:descer(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 10.0, 2804.7434,-1175.1790,32.6688)){
    if(Pdados[playerid][OrgID] == 31){
    SetPlayerPos(playerid, 2804.7417,-1178.5381,25.4753);
    }else{
    }
    }else{
    }
	return 1;
}


CMD:pagarpedagio(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 8.0, 1739.4037,504.8039,28.8814)){
    if(GetPlayerMoney(playerid) >= 1000){
    MoveObject(portao1, 1741.1000000,509.2000100, 24,3.0); 
    SetTimerEx("GateClose", 5000, false, "i", portao1);
    SendClientMessage(playerid, branco, "Pedagio pago, custou $1000 reais, boa viagem.");
    }else{
    SendClientMessage(playerid, vermelho, "Voce nao tem $1000 para o pedagio.");
    }
    }else{
    }
    if(IsPlayerInRangeOfPoint(playerid, 8.0, 1731.8717,523.4805,28.0227)){
    if(GetPlayerMoney(playerid) >= 1000){
    MoveObject(portao2, 1730.6000000,519.0000000, 24,3.0); 
    SetTimerEx("GateClose", 5000, false, "i", portao2);
    SendClientMessage(playerid, branco, "Pedagio pago, custou $1000 reais, boa viagem.");
    }else{
    SendClientMessage(playerid, vermelho, "Voce nao tem $1000 para o pedagio.");
    }
    }else{
    }
	return 1;
}
public GateClose(gateid)
{
    if(gateid == portao1)
    {
        MoveObject(portao1, 1741.1000000,509.2000100,30.2000000,3.0);
    }
    if(gateid == portao2)
    {
    	MoveObject(portao2, 1730.6000000,519.0000000,30.2000000,3.0); 
    }
    if(gateid == portaoeb)
    {
    	MoveObject(portaoeb, -1529.6000000,482.2000100,9.0000000,3.0);
    }
    if(gateid == portaobope)
    {
    	MoveObject(portaobope, 1878.7000000,703.4000200,12.5000000,3.0);
    }
    if(gateid == portaopm)
    {
    	MoveObject(portaopm, 2775.7000000,913.2999900,12.6000000,3.0);
    }
    if(gateid == portaopf)
    {
    	MoveObject(portaopf, -489.6000100,-562.5999800,27.3333300,3.0);
    }
    if(gateid == portaorotam)
    {
    	MoveObject(portaorotam, -2487.8999000,-614.7000100,134.3000000,3.0);
    }
    if(gateid == portaomt)
    {
    	MoveObject(portaomt, 924.7000100,-1220.9000000,18.7000000,3.0);
    }
    if(gateid == portaomec)
    {
    	MoveObject(portaomec, 979.7999900,-1445.4000000,15.3000000,3.0);
    }
    if(gateid == portaopc)
    {
    	MoveObject(portaopc, 1541.9, -1627.9, 15.2,3.0);
    }
    if(gateid == portaoada)
    {
    	MoveObject(portaoada, 2826.7000000,-1183.4000000,26.8000000,3.0);
    }
	return 1;
}
CMD:pegarrevistas(playerid, params[])
{
    if(Pdados[playerid][Trabalho] == 5){
	if(IsPlayerInRangeOfPoint(playerid, 20.0, 618.7199,-1506.4921,14.9392)){
	if(revista[playerid] == 0){
	if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 481){
	new rand = random(sizeof(revistas));
	SetPlayerRaceCheckpoint(playerid, 1, revistas[rand][0],revistas[rand][1],revistas[rand][2], 0, 0, 0, 2);
	SendClientMessage(playerid, branco, "| Entregador | Entregue a revista na casa marcada em seu mapa.");
	revista[playerid] = 1;
	}else{
	}
	}else{
	}
	}else{
	}
    }else{
    }
	return 1;
}
CMD:capacete(playerid, params[])
{
	if(Pdados[playerid][Capacete] == 1){
    SetPlayerAttachedObject(playerid, 1, 18645, 2, 0.07, 0, 0, 88, 75, 0);
    SendClientMessage(playerid, AMARELO, "Para remover seu capacete use /removerc.");
	}else{
	SendClientMessage(playerid, vermelho, "Voce nao tem um capacete, compre no shopping.");
	}
	return 1;
}
CMD:removerc(playerid, params[])
{
    if(Pdados[playerid][Capacete] == 1){
    if(IsPlayerAttachedObjectSlotUsed(playerid,1)) RemovePlayerAttachedObject(playerid,1);
    }else{
	SendClientMessage(playerid, vermelho, "Voce nao tem um capacete, compre no shopping.");
	}
	return 1;
}
CMD:tune(playerid, params[])
{
    if (GetPlayerVehicleID(playerid) == 562)
    {
  	AddVehicleComponent(562, 1010); // Nitro
  	AddVehicleComponent(562, 1079);
  	}
	return 1;
}
CMD:cimento(playerid, params[])
{
    // 1. Verificacao: O jogador trabalha com cimento (ID 7)?
    if(Pdados[playerid][Trabalho] != 7)
        return SendClientMessage(playerid, VERMELHO, "ERRO: Voce nao trabalha na fabrica de cimento!");

    // 2. Verificacao: Esta no local correto de carregamento?
    if(!IsPlayerInRangeOfPoint(playerid, 10.0, 2714.9199, 852.9884, 10.8984))
        return SendClientMessage(playerid, VERMELHO, "ERRO: Voce nao esta no local de carregamento de cimento!");

    // 3. Verificacao: Esta dentro do veiculo correto (ID 524 - Cement Truck)?
    new vehicleid = GetPlayerVehicleID(playerid);
    if(GetVehicleModel(vehicleid) != 524)
        return SendClientMessage(playerid, VERMELHO, "ERRO: Voce precisa estar dentro de um Caminhao de Cimento (Cement Truck)!");

    // 4. Verificacao: Ja esta com uma carga ativa?
    if(ccimento[playerid] != 0)
        return SendClientMessage(playerid, AMARELO, "AVISO: Voce ja esta com o caminhao carregado! Va ate o ponto de entrega.");

    // Executa o carregamento e marca o destino
    ccimento[playerid] = 1;
    
    // Tipo 1 = Checkpoint normal de corrida (bandeira de chegada se for o ultimo)
    // Parametros: playerid, tipo, X, Y, Z, ProximoX, ProximoY, ProximoZ, Tamanho
    SetPlayerRaceCheckpoint(playerid, 1, 1248.4750, -1258.5659, 13.1651, 1248.4750, -1258.5659, 13.1651, 5.0);
    
    SendClientMessage(playerid, VERDE, "| CIMENTO | {FFFFFF}Caminhao carregado! Leve esse cimento para o destino em Los Santos.");
    return 1;
}

CMD:empregos(playerid,params[]){
	if(IsPlayerInRangeOfPoint(playerid, 5.0, 358.236206, 163.155456, 1008.382812))
    {
    ShowPlayerDialog(playerid, DIALOG_EMPREGOS, DIALOG_STYLE_INPUT, "Agencia de empregos", "{FFFFFF}1 - Entregador de pizza\n{FFFFFF}2 - Tecnico de Internet\n{FFFFFF}3 - Caminhoneiro\n{FFFFFF}4 - Motorista\n{FFFFFF}5 - Entregador de revista\n{FFFFFF}6 - Taxista\n{FFFFFF}7 - Transportador de Cimento\n{FFFFFF}8 - Lixeiro\n{FFFFFF}9 - Transportador de valores\n{FFFFFF}10 - Ifood", "Selecionar", "Cancelar");
    }else{
    }
	return 1;
}
CMD:lojaele(playerid,params[]){
	if(IsPlayerInRangeOfPoint(playerid, 5.0, 2.8274,-29.0144,1003.5494)){
    ShowPlayerDialog(playerid, DIALOG_LOJA, DIALOG_STYLE_INPUT, "Loja de Eletronicos", "{FFFFFF}1 - Celular\t{00cc00}$2000\n{FFFFFF}2 - Caixa de Ferramentas\t{00cc00}$3000\n{FFFFFF}3 - Capacete\t{00cc00}$1500", "Comprar", "Cancelar");
    }else{
    }
	return 1;
}
CMD:meucelular(playerid,params[]){
    if(Pdados[playerid][Celular] == 0)return SendClientMessage(playerid, vermelho, "Voce nao tem um celular, compre no shopping, /gps > locais importantes > shopping");
    return BCG_AbrirCelularVisual(playerid);
}
CMD:celular1(playerid,params[]){ return BCG38Open(playerid); }
CMD:fcaixa(playerid,params[]){
    if(Pdados[playerid][cFerramentas] == 0)return SendClientMessage(playerid, vermelho, "Voce nao tem uma caixa de ferramentas, compre no shopping, /gps > locais importantes > shopping");
	ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Caixa de Ferramentas", "Com sua caixa de ferramentas voce pode consertar seu veiculo:\n\n/consertar - para consertar seu veiculo.\n\nFaca bom proveito :)", "OK", "");
	return 1;
}
CMD:reparar(playerid,params[]){
	if(!(ADM(playerid,1))) return 1;
	GameTextForPlayer(playerid, "~g~reparado...", 10000, 4);
	RepairVehicle(GetPlayerVehicleID(playerid));
	return 1;
}
CMD:consertar(playerid,params[]){
	if(Pdados[playerid][cFerramentas] == 0)return SendClientMessage(playerid, vermelho, "Voce nao tem uma caixa de ferramentas, compre no shopping, /gps > locais importantes > shopping");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VERMELHO, "Voce nao esta dentro de um veiculo.");
	GameTextForPlayer(playerid, "~g~consertando veiculo...", 10000, 4);
	TogglePlayerControllable(playerid, 0);
	conserto[playerid] = 1;
	Pdados[playerid][cFerramentas] = 0;
	SetTimerEx("consertarcarro", 10000, true, "i", playerid);
	return 1;
}
CMD:guardar(playerid,params[]){
	if(IsPlayerInRangeOfPoint(playerid,5,1235.372558, -1811.243286, 13.602552)){
    Dados[playerid][model1c]=false;
	Dados[playerid][model2c]=false;
	if(Dados[playerid][id1]!=-1){DestroyVehicle(Dados[playerid][id1]);}
	if(Dados[playerid][id2]!=-1){DestroyVehicle(Dados[playerid][id2]);}
	Dados[playerid][id1]=-1;
	Dados[playerid][id2]=-1;
	}
	return 1;
}
CMD:savepos(playerid, params[])
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    if(!(ADM(playerid, 8))) return 1;

    // Se params estiver vazio ou so tiver espacos
    if(isnull(params)) 
        return SendClientMessage(playerid, -1, "USE: /savepos [nome]");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    new coords[128];
    format(coords, sizeof(coords), "%f, %f, %f", x, y, z);

    if(!DOF2_FileExists("pos.txt")) DOF2_CreateFile("pos.txt");
    
    // Salva usando o params direto como nome da chave
    DOF2_SetString("pos.txt", params, coords);
    DOF2_SaveFile();

    new msg[128];
    format(msg, sizeof(msg), "Posicao '%s' salva!", params);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}
CMD:sethoras(playerid, params[])
{
    // Verificacao de seguranca por Nick
    if(!(ADM(playerid, 8))) return 1;

    new id_procurado, valor, string[128], path[64];

    if(sscanf(params, "ii", id_procurado, valor)) 
        return SendClientMessage(playerid, AZUL_CLARO, "Use: /sethoras [IDF] [Quantidade]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Jogador offline.");

    // Define o valor e salva
    Pdados[id][SegundosJogados] = valor;
    format(path, sizeof(path), "Contas/%s.txt", Nome(id));
    DOF2_SetInt(path, "SegundosJogados", valor);
    DOF2_SaveFile();

    format(string, sizeof(string), "{FFFFFF}Horas de {33CCFF}%s {FFFFFF}definidas para {33CCFF}%d.", Nome(id), valor);
    SendClientMessage(playerid, -1, string);
    return 1;
}





CMD:meuid(playerid, params[])
{
    if(BCG_IDFixo[playerid] < 1001) BCG_CarregarOuCriarIDFixo(playerid);
    new msg[96];
    format(msg, sizeof(msg), "{FFFFFF}Seu ID fixo e: {33CCFF}%d{FFFFFF}. Esse ID pertence permanentemente a sua conta.", BCG_IDFixo[playerid]);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:idfixo(playerid, params[])
{
    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, CINZA, "Use: /idfixo [ID FIXO]");
    new alvo = BCG_PlayerPorIDFixo(id);
    if(alvo == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Nenhum jogador online com esse ID fixo.");
    new msg[128];
    format(msg, sizeof(msg), "{FFFFFF}ID fixo {33CCFF}%d {FFFFFF}esta online. Slot atual: {33CCFF}%d{FFFFFF}.", id, alvo);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:addhoras(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id, horas, segundos, path[96], msg[192];
    if(sscanf(params, "ii", id, horas))
        return SendClientMessage(playerid, AZUL_CLARO, "Use: /addhoras [ID] [HORAS]");

    if(!IsPlayerConnected(id)) return SendClientMessage(playerid, CINZA, "Jogador offline.");
    if(horas <= 0 || horas > 10000) return SendClientMessage(playerid, CINZA, "Informe entre 1 e 10000 horas.");

    segundos = horas * 3600;
    Pdados[id][SegundosJogados] += segundos;

    format(path, sizeof(path), "Contas/%s.txt", Nome(id));
    DOF2_SetInt(path, "SegundosJogados", Pdados[id][SegundosJogados]);
    DOF2_SaveFile();

    format(msg, sizeof(msg), "{FFFFFF}Adicionado {33CCFF}%d hora(s) {FFFFFF}ao tempo de {33CCFF}%s{FFFFFF}.", horas, Nome(id));
    SendClientMessage(playerid, -1, msg);
    format(msg, sizeof(msg), "{FFFFFF}O admin {33CCFF}%s {FFFFFF}adicionou {33CCFF}%d hora(s) {FFFFFF}ao seu tempo jogado.", Nome(playerid), horas);
    SendClientMessage(id, -1, msg);
    return 1;
}

CMD:resethoras(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;

    new id_procurado, string[128], path[64];

    if(sscanf(params, "i", id_procurado)) 
        return SendClientMessage(playerid, AZUL_CLARO, "Use: /resethoras [IDF]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Jogador offline.");

    Pdados[id][SegundosJogados] = 0;
    format(path, sizeof(path), "Contas/%s.txt", Nome(id));
    DOF2_SetInt(path, "SegundosJogados", 0);
    DOF2_SaveFile();

    format(string, sizeof(string), "{FFFFFF}Horas de {33CCFF}%s {FFFFFF}resetadas para 0.", Nome(id));
    SendClientMessage(playerid, -1, string);
    return 1;
}

CMD:resethorasgeral(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;

    new path[64], contador = 0;

    // Loop global por conexoes ativas para aplicar o reset em todos online
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Pdados[i][Logado] == true)
        {
            Pdados[i][SegundosJogados] = 0;
            
            // Salva no arquivo de cada um encontrado
            format(path, sizeof(path), "Contas/%s.txt", Nome(i));
            DOF2_SetInt(path, "SegundosJogados", 0);
            
            contador++;
        }
    }
    
    DOF2_SaveFile(); // Grava fisicamente as alteracoes nos arquivos editados no loop
    
    new string[128];
    format(string, sizeof(string), "{FFFFFF}BCG: Horas de todos os {33CCFF}%d {FFFFFF}jogadores online foram resetadas!", contador);
    SendClientMessageToAll(VERDE, string);
    return 1;
}


CMD:aa(playerid,params[]){
    if(!(ADM(playerid,1))) return 1;
    ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Imprio Roleplay - Comandos Admin", "GERAL: /deus /admins /chamaradm /a /aviso /limparchat\nPLAYER (ID FIXO): /ir /trazer /reviver /tv /tvoff /mostrarrg /kick /ban /banip\nCONTROLE: /congelar /descongelar /slap /setinterior /setvw\nSTATUS: /vida /colete /skin /dararma /tirararma /dargrana /removergrana\nVEICULO: /repararv /virarv /respawn /trazertodos\nGESTAO: /daradmin /darlider /limparorg /darvip /tirarvip /daryt /tiraryt /trancarserver /addhoras", "OK", "");
	return 1;
}
CMD:ajuda(playerid,params[]){
    ShowPlayerDialog(playerid, DIALOG_AJUDA, DIALOG_STYLE_INPUT, "Ajuda", "1 - Geral\n2 - Emprego\n3 - Organizacao\n4 - YouTuber\n5 - VIP\n6 - Veiculos", "Selecionar", "Cancelar");
	return 1;
}
CMD:discord(playerid,params[]){
    SendClientMessage(playerid, azul, "Discord do servidor: discord.gg/bBCH3Cwv");
	return 1;
}
CMD:vantagensvip(playerid,params[]){
    ShowPlayerDialog(playerid, 5000, DIALOG_STYLE_MSGBOX, "Vantagens VIP", "{ff3333}VIP BCG:{FFFFFF}\nPagamento de 800k / +Payday / Veiculos vips / Casas vip / Desconto em org/corp\nKitvip / Anuncio VIP / Chat VIP / Drone / Mine carro\n\n{cc0000}VIP RUBI:{FFFFFF}\nPagamento de 600k / +Payday / Veiculos vips / Casas vip / Desconto em org/corp\nKitvip / Anuncio VIP / Chat VIP\n\n{333333}VIP BRONZE:{FFFFFF}\nPagamento de 400k / +Payday / Veiculos vips\nKitvip / Chat VIP", "OK", "");
	return 1;
}
CMD:trancar(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VERMELHO,"Voce nao esta em um veiculo!"); //LINHA 16253
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    return SendClientMessage(playerid,VERMELHO,"Voce nao pode trancar esse veiculo!"); //LINHA 16255
    for(new i=0;i<MAX_PLAYERS;i++) if(i != playerid)
    SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i, 0, 1);
    SendClientMessage(playerid, VERDE, "VEICULO TRANCADO."); // LINHA 16258
    return 1;
}

CMD:destrancar(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VERMELHO, "Voce nao esta em um veiculo!"); // LINHA 16264
    if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER) return SendClientMessage(playerid,VERMELHO,"Voce nao pode destrancar esse veiculo!"); // LINHA 16265
    for(new i=0;i<MAX_PLAYERS;i++)
    SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i, 0, 0);
    SendClientMessage(playerid, VERDE, "VEICULO DESTRANCADO."); // LINHA 16268
    return 1;
}
CMD:mecanicos(playerid, params[])
{
    new total_mecanicos = 0;
    
    SendClientMessage(playerid, AZUL, "_______________ Mecanicos Online _______________");
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            if(Pdados[i][OrgID] == 33)
            {
                new string_mecanico[128];
                format(string_mecanico, sizeof(string_mecanico), "{FFFFFF}Nome: %s {999999}(ID: %d)", Nome(i), i);
                SendClientMessage(playerid, -1, string_mecanico);
                total_mecanicos++;
            }
        }
    }
    
    if(total_mecanicos == 0)
    {
        SendClientMessage(playerid, CINZA, "Nenhum mecanico online no momento.");
    }
    
    return 1;
}

CMD:lideres(playerid, params[])
{
    new IsVip;
    SendClientMessage(playerid, AZUL, "_______________ Lideres Online _______________");
    for(new i = 0; i < MAX_PLAYERS; ++i)
    {
        if(Pdados[i][OrgID] >= 1 || Pdados[i][Cargo] == 5)
        {
			format(String, sizeof(String), "Nome: %s(%d) | Org: %s", Nome(i), i, NomeOrg(i));
			SendClientMessage(playerid, branco, String);
			IsVip++;
		}
	}
	if(IsVip == 0)
	{
	    SendClientMessage(playerid, CINZA, "Nenhum lider online.");
	}
	IsVip = 0;
	return 1;
}
CMD:procurados(playerid, params[])
{
    if(Pdados[playerid][OrgID] == 1 || Pdados[playerid][OrgID] == 2 || Pdados[playerid][OrgID] == 3 || Pdados[playerid][OrgID] == 4 || Pdados[playerid][OrgID] == 5 || Pdados[playerid][OrgID] == 6 || Pdados[playerid][OrgID] == 7 || Pdados[playerid][OrgID] == 8 || Pdados[playerid][OrgID] == 9 || Pdados[playerid][OrgID] == 10 || Pdados[playerid][OrgID] == 11 || Pdados[playerid][OrgID] == 12){
    new IsVip;
    SendClientMessage(playerid, AMARELO, "_______________ Procurados _______________");
    for(new i = 0; i < MAX_PLAYERS; ++i)
    {
        if(GetPlayerWantedLevel(i) >= 1)
        {
			format(String, sizeof(String), "Nome: %s(%d) | Nivel: %d de procurado", Nome(i), i, GetPlayerWantedLevel(i));
			SendClientMessage(playerid, branco, String);
			IsVip++;
		}
	}
	if(IsVip == 0)
	{
	    SendClientMessage(playerid, CINZA, "Nenhum Taxista online.");
	}
	IsVip = 0;
	}
	return 1;
}
CMD:taxistas(playerid, params[])
{
    new IsVip;
    SendClientMessage(playerid, AMARELO, "_______________ Taxistas Online _______________");
    for(new i = 0; i < MAX_PLAYERS; ++i)
    {
        if(Pdados[i][Trabalho] == 6)
        {
			format(String, sizeof(String), "Nome: %s(%d)", Nome(i), i);
			SendClientMessage(playerid, branco, String);
			IsVip++;
		}
	}
	if(IsVip == 0)
	{
	    SendClientMessage(playerid, CINZA, "Nenhum Taxista online.");
	}
	IsVip = 0;
	return 1;
}
stock BCG_AbrirLoja(playerid)
{
    // A interface nova e a porta de entrada. O menu DIALOG_LOJA_PRINCIPAL
    // continua existente para preservar todas as compras antigas.
    return BCG_AbrirLojaV2(playerid);
}

CMD:loja(playerid, params[])
{
    return BCG_AbrirLoja(playerid);
}
CMD:jbl(playerid, params[])
{
    // SEGUNDA LoGICA: Se a caixinha ja existir no chao e o jogador estiver perto, abre o painel de gerenciamento
    if(ObjetoJBL[playerid] != INVALID_OBJECT_ID && IsPlayerInRangeOfPoint(playerid, 3.0, JBLPos[playerid][0], JBLPos[playerid][1], JBLPos[playerid][2]))
    {
        new statusStr[150];
        format(statusStr, sizeof(statusStr), "Opcao\tStatus\n{FFFFFF}1. Inserir Link da Musica (URL)\t{FFFF00}Alterar\n{FFFFFF}2. Desligar Som Atual\t{FF0000}Parar");
        ShowPlayerDialog(playerid, DIALOG_MENU_JBL, DIALOG_STYLE_TABLIST_HEADERS, "{00FFFF}Painel de Controle - JBL", statusStr, "Selecionar", "Fechar");
        return 1;
    }

    // PRIMEIRA LoGICA: Se ele nao colocou a caixinha ainda, faz o procedimento de colocar
    if(Pdados[playerid][pItem_JBL] <= 0) 
        return SendClientMessage(playerid, 0xFF0000FF, "[JBL]: Voce nao possui uma caixa de som JBL na mochila.");

    if(ObjetoJBL[playerid] != INVALID_OBJECT_ID) 
        return SendClientMessage(playerid, 0xFF0000FF, "[JBL]: Voce ja tem uma JBL no chao em outro lugar. Use /pjbl para guarda-la antes.");

    // Coleta a posicao do jogador para criar o objeto na frente dele
    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    // Desloca 1.0 metro a frente baseado para onde o jogador esta olhando
    x += (1.0 * floatsin(-a, degrees));
    y += (1.0 * floatcos(-a, degrees));
    z -= 0.95; // Fixa o objeto rente ao chao

    // Armazena as coordenadas globais da JBL
    JBLPos[playerid][0] = x;
    JBLPos[playerid][1] = y;
    JBLPos[playerid][2] = z;

    // Cria o objeto fisico e a label de identificacao
    ObjetoJBL[playerid] = CreateObject(2226, x, y, z, 0.0, 0.0, a);
    
    new labelStr[90];
    format(labelStr, sizeof(labelStr), "{00FFFF}JBL de %s\n{FFFFFF}Digite /jbl perto para gerenciar", Nome(playerid));
    TextJBL[playerid] = Create3DTextLabel(labelStr, 0xFFFFFFFF, x, y, z + 0.4, 10.0, 0, true);

    // Retira o item da mochila temporariamente enquanto estiver no chao
    Pdados[playerid][pItem_JBL]--;
    SalvarDados(playerid);

    SendClientMessage(playerid, 0x00FF00FF, "[JBL]: Caixa de som posicionada! Aproxime-se e digite /jbl para tocar suas musicas.");
    return 1;
}


CMD:pjbl(playerid, params[])
{
    if(ObjetoJBL[playerid] == INVALID_OBJECT_ID) 
        return SendClientMessage(playerid, 0xFF0000FF, "[JBL]: Voce nao tem nenhuma caixa de som colocada no chao.");

    // Verifica se o jogador esta perto da SUA caixa de som para poder guardar
    if(!IsPlayerInRangeOfPoint(playerid, 3.0, JBLPos[playerid][0], JBLPos[playerid][1], JBLPos[playerid][2]))
        return SendClientMessage(playerid, 0xFF0000FF, "[JBL]: Voce esta muito longe da sua caixa de som para guarda-la.");

    // Desliga a musica para todos na area antes de sumir com ela
    if(JBLLigada[playerid])
    {
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 30.0, JBLPos[playerid][0], JBLPos[playerid][1], JBLPos[playerid][2]))
            {
                StopAudioStreamForPlayer(i);
            }
        }
    }

    // Deleta o objeto e o texto do mapa de forma limpa
    DestroyObject(ObjetoJBL[playerid]);
    ObjetoJBL[playerid] = INVALID_OBJECT_ID;

    Delete3DTextLabel(TextJBL[playerid]);
    TextJBL[playerid] = Text3D:INVALID_3DTEXT_ID;

    JBLLigada[playerid] = false;

    // Devolve a JBL de volta para a mochila do dono
    Pdados[playerid][pItem_JBL]++;
    SalvarDados(playerid);

    SendClientMessage(playerid, 0xFFFF00FF, "[JBL]: Voce desligou e guardou a sua caixa de som de volta na mochila!");
    return 1;
}
//VIP
CMD:vips(playerid, params[])
{
    new IsVip;
    SendClientMessage(playerid, AMARELO, "_______________ Vips Online _______________");
    for(new i = 0; i < MAX_PLAYERS; ++i)
    {
        if(Pdados[i][Vip])
        {
			format(String, sizeof(String), "Nome: %s(%d)", Nome(i), i);
			SendClientMessage(playerid, branco, String);
			IsVip++;
		}
	}
	if(IsVip == 0)
	{
	    SendClientMessage(playerid, CINZA, "Nenhum VIP online.");
	}
	IsVip = 0;
	return 1;
}
CMD:kitvip(playerid, params[])
{
    if(!Pdados[playerid][Vip]) return SendClientMessage(playerid, AMARELO, "Voce nao e um jogador VIP!");
    if(equipado[playerid] == 0){
	format(String,sizeof(String),"O player vip %s pegou o kitvip",Nome(playerid));
    MsgAdm(String);
    SetPlayerHealth(playerid,100);
    SetPlayerArmour(playerid,100);
    GivePlayerWeapon(playerid, 24, 75);  // DESERT EAGLE
    GivePlayerWeapon(playerid, 31, 150); // M4
    SetTimerEx("TempoVip", 120000, true, "i", playerid);
    equipado[playerid] = 1;
    }else{
    SendClientMessage(playerid, CINZA, "Espere 2 minutos para poder equipar novamente.");
    }
    return 1;
}
CMD:jet(playerid, params[])
{
    if(!Pdados[playerid][Vip]) return SendClientMessage(playerid, AMARELO, "Voce nao e um jogador VIP!");
    if(equipado[playerid] == 0){
	SetPlayerSpecialAction(playerid, 2);
    equipado[playerid] = 1;
    }else{
    SendClientMessage(playerid, CINZA, "Espere 2 minutos para poder equipar novamente.");
    }
    return 1;
}
CMD:yts(playerid, params[])
{
    new IsYou;
    SendClientMessage(playerid, 0xff0000ff, "_______________ YouTubers Online _______________");
    for(new i = 0; i < MAX_PLAYERS; ++i)
    {
        if(Pdados[i][YouTuber])
        {
			format(String, sizeof(String), "Nome: %s", Nome(i));
			SendClientMessage(playerid, branco, String);
			IsYou++;
		}
	}
	if(IsYou == 0)
	{
	    SendClientMessage(playerid, CINZA, "Nenhum YOUTUBER online.");
	}
	IsYou = 0;
	return 1;
}
//Orgs/corps
CMD:su(playerid, params[])
{
    if(Pdados[playerid][OrgID] == 0 || Pdados[playerid][OrgID] > 12) return 1;

    new id_procurado, estrelas;
    if(sscanf(params, "ii", id_procurado, estrelas)) return SendClientMessage(playerid, AZUL_CLARO, "Use /su [IDF] [ESTRELAS]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao esta online");

    // Coleta dos nomes apos a validacao do ID real do servidor
    new pname[MAX_PLAYER_NAME];
    GetPlayerName(id, pname, MAX_PLAYER_NAME);

    SetPlayerWantedLevel(id, estrelas);
    SalvarDados(id); // Salva os dados na conta do suspeito que recebeu as estrelas

    format(String, sizeof(String), "Voce adicionou %i estrelas para %s", estrelas, pname);
    SendClientMessage(playerid, AZUL_CLARO, String);

    format(String, sizeof(String), "%s %s da %s adicionou %i estrelas a sua ficha criminal", NomeCargo(playerid), Nome(playerid), NomeOrg(playerid), estrelas);
    SendClientMessage(id, AMARELO, String);
    return 1;
}

CMD:cadeia(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;
    if(Pdados[playerid][Trabalhando] == false) return 1;

    new id_procurado, tempo;
    if(sscanf(params, "ii", id_procurado, tempo)) return SendClientMessage(playerid, AZUL_CLARO, "Use /cadeia [IDF] [TEMPO EM MINUTOS]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao esta online");

    format(String, sizeof(String), "Voce foi preso por %i minutos pelo %s %s", tempo, NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, AZUL_CLARO, String);

    tempo *= 60000; // Converte minutos informados para milissegundos
    SetPlayerPos(id, 196.9844, 162.0234, 1002.6875);
    SetPlayerInterior(id, 3);
    
    Pdados[id][Arrastado] = 0;
    SetTimerEx("tpreso", tempo, false, "i", id);
    Pdados[id][Logado] = false;
    ResetPlayerWeapons(id);

    // Criacao e gravacao do arquivo de controle
    format(StringContas, sizeof(StringContas), "Presos/%s.txt", Nome(id));
    if(!DOF2_FileExists(StringContas)) DOF2_CreateFile(StringContas);
    
    DOF2_SetInt(StringContas, "Tempo Preso", tempo);
    DOF2_SaveFile(); // Atualizado para a diretriz correta de salvamento do DOF2
    
    return 1;
}

CMD:armas(playerid, params[])
{
    if(IsPlayerInRangeOfPoint(playerid, 5.0, 296.5811,-38.0198,1001.5156)){
    ShowPlayerDialog(playerid, DIALOG_ARMAS, DIALOG_STYLE_INPUT, "Armas", "1 - Desert-Eagle\t{00cc00}$15000\n{FFFFFF}2 - MP5\t\t{00cc00}$25000\n{FFFFFF}3 - Shotgun\t\t{00cc00}$30000\n{FFFFFF}4 - AK-47\t\t{00cc00}$55000\n{FFFFFF}5 - M4\t\t{00cc00}$50000\n{FFFFFF}6 - Sniper\t\t{00cc00}$100000", "Comprar", "Cancelar");
    }else{
    }
	return 1;
}
public TempoPreso(playerid)
{
	if(Pdados[playerid][Preso] == 1){
    TogglePlayerControllable(playerid, 1);
	SetPlayerSpecialAction(playerid, 0);
	SetPlayerWantedLevel(playerid, 0);
	algemado[playerid] = 0;
	Pdados[playerid][Preso] = 0;
    SetPlayerHealth(playerid,100);
    ResetPlayerWeapons(playerid);
    SetPlayerPos(playerid, 1550.7477,-1675.4952,15.5439);
    SetPlayerInterior(playerid, 0);
    GameTextForPlayer(playerid, "~y~LIBERADO!", 3000, 0);
    }
	return 1;
}
public Mecanico(playerid)
{
	if(tmec[playerid] == 1){
	tmec[playerid] = 0;
	SendClientMessage(playerid, CINZA, "Voce ja pode pedir mecanico novamente.");
	}else{
	}
	
	return 1;
}
public Taxi()
{
	foreach(Player, i)
	{
	if(Taximetro[i][0] == 1){
	if(GetPlayerMoney(i) > PrecoCorrida[i] + 3){
	new string[128];
	PrecoCorrida[i] = PrecoCorrida[i] + 3;
	format(string, sizeof(string), "O taximetro deu R$%d reais", PrecoCorrida[i]);
	SendClientMessage(i, AMARELO, string);
	SendClientMessage(Taximetro[i][1], 0xD9D900AA, string);
	}
	if(GetPlayerMoney(i) < PrecoCorrida[i] + 3){
	SendClientMessage(i, vermelho, "Seu dinheiro acabou.");
	SendClientMessage(Taximetro[i][1], vermelho, "Acabou o dinheiro do passageiro.");
	GivePlayerMoney(i, 0 - PrecoCorrida[i]);
	GivePlayerMoney(Taximetro[i][1], PrecoCorrida[i]);
	RemovePlayerFromVehicle(i);
	PrecoCorrida[i] = 0;
	Taximetro[i][1] = 0;
	}
	}
	}
	return 1;
}
CMD:eu(playerid, params[])
{
    new texto[128], string[192];
    new aname[MAX_PLAYER_NAME];
    new Float:pos[3];

    if(sscanf(params, "s[128]", texto))
        return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}/eu [acao]");

    GetPlayerName(playerid, aname, MAX_PLAYER_NAME);
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    format(string, sizeof(string), "{FF0000}[EU] {FFFFFF}%s: %s", aname, texto);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 15.0, pos[0], pos[1], pos[2]) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
        {
            SendClientMessage(i, -1, string);
        }
    }

    return 1;
}

CMD:usaradrenalina(playerid, params[])
{
    new orgid = Pdados[playerid][OrgID];
    if((orgid < 1) || (orgid > 12)) return SendClientMessage(playerid, CINZA, "Apenas oficiais das corporacoes policiasi podem usar Adrenalina!");

    if(Pdados[playerid][Adrenalina] <= 0) return SendClientMessage(playerid, CINZA, "Voce nao possui nenhuma unidade de Adrenalina na mochila.");

    new Float:vida;
    GetPlayerHealth(playerid, vida);
    if(vida >= 95.0) return SendClientMessage(playerid, CINZA, "Sua integridade fisica ja esta excelente. Nao ha necessidade de usar agora.");

    // Executa os efeitos colaterais beneficos da adrenalina
    Pdados[playerid][Adrenalina]--;
    SetPlayerHealth(playerid, 100.0);
    
    // Aplica uma animacao de injecao/uso de item medico
    ApplyAnimation(playerid, "HEALTH", "HEAL_Loop", 4.1, 0, 1, 1, 0, 3000, 1);
    
    SendClientMessage(playerid, -1, "{2ECC71}[SUCESSO] {FFFFFF}Voce utilizou uma dose de adrenalina. Sua vida foi restaurada!");
    
    // Forca o salvamento imediato do arquivo para evitar crash/perda do item
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    DOF2_SetInt(StringContas, "Adrenalina", Pdados[playerid][Adrenalina]);
    return 1;
}

CMD:prender(playerid, params[])
{
    new org = Pdados[playerid][OrgID];
    if(org >= 1 && org <= 12)
    {
        if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1536.2542, -1673.6940, 13.3828))
            return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Voce nao esta no departamento para prender.");

        new id_procurado, string[128];
        if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}/prender [IDF]");

        // --- BUSCA PELO ID ---
        new id = INVALID_PLAYER_ID;
        id = BCG_BuscarPorIDFixo(id_procurado);
        if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Jogador offline.");

        if(playerid == id) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Voce nao pode prender voce mesmo");
        if(GetDistanceBetweenPlayers(playerid, id) >= 10) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Voce esta muito longe.");
        if(algemado[id] != 1) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Esse jogador nao foi algemado.");
        if(GetPlayerWantedLevel(id) < 1) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Esse jogador nao esta procurado.");

        // Coleta os nomes agora que o ID real foi validado e encontrado
        new pname[MAX_PLAYER_NAME], aname[MAX_PLAYER_NAME];
        GetPlayerName(id, pname, MAX_PLAYER_NAME);
        GetPlayerName(playerid, aname, MAX_PLAYER_NAME);

        TogglePlayerControllable(id, 1);
        GameTextForPlayer(id, "~r~PRESO!", 3000, 0);
        SetPlayerSpecialAction(id, 0);
        algemado[id] = 0;
        
        SetPlayerPos(id, 264.6288, 77.5742, 1001.0391);
        SetPlayerInterior(id, 6);
        Pdados[id][Preso] = 1;
        
        GivePlayerMoney(playerid, 1000);
        GameTextForPlayer(playerid, "~r~+~g~$1000", 3000, 6);
        
        SetTimerEx("TempoPreso", 900000, true, "i", id);
        SendClientMessage(id, vermelho, "Voce foi preso por 15 minutos");
        
        format(string, sizeof(string), "| POLICIA | {FFFFFF}Voce prendeu %s", pname);
        SendClientMessage(playerid, azul, string);
        format(string, sizeof(string), "| POLICIA | {FFFFFF}%s lhe prendeu.", aname);
        SendClientMessage(id, azul, string);
        
        SalvarDados(id);
        SalvarDados(playerid);
    }
    return 1;
}

CMD:membros(playerid, params[]) 
{
    new org;
    // Se for admin e digitar um numero, ele consulta aquela org. Se nao digitar nada, consulta a dele.
    if(sscanf(params, "i", org)) org = Pdados[playerid][OrgID];
    
    if(org == 0) return SendClientMessage(playerid, CINZA, "Voce nao esta em uma organizacao.");

    format(String, sizeof(String), "--- Membros Online da %s ---", NomeOrg(org));
    SendClientMessage(playerid, 0x33CCFFAA, String);

    for(new i = 0; i < MAX_PLAYERS; i++) 
    {
        if(IsPlayerConnected(i) && Pdados[i][OrgID] == org) 
        {
            // Alterado para mostrar i na listagem do chat para os lideres/membros
            format(String, sizeof(String), "(ID: %d) %s - Cargo: %d", i, Nome(i), Pdados[i][Cargo]);
            SendClientMessage(playerid, CINZA, String);
        }
    }
    return 1;
}


public tpreso(playerid){
    SetPlayerPos(playerid, 1538.242553, -1673.189453, 13.546875);
    SetPlayerInterior(playerid,0);
    Pdados[playerid][Logado] = true;
    format(StringContas, sizeof(StringContas), "Presos/%s.txt", Nome(playerid));
    DOF2_RemoveFile(StringContas);
    format(StringContas, sizeof(StringContas), "Ficha/%s.txt", Nome(playerid));
    DOF2_RemoveFile(StringContas);
    SetPlayerHealth(playerid,100);
	return 1;
}

CMD:checkoff(playerid, params[])
{
    DisablePlayerCheckpoint(playerid);
    DisablePlayerRaceCheckpoint(playerid);
    return 1;
}

CMD:equipar(playerid, params[])
{   
    new org = Pdados[playerid][OrgID];
    if(org == 0) return SendClientMessage(playerid, AMARELO, "Voce nao faz parte de uma organizacao!");
    
    if(equipado2[playerid] != 0) return SendClientMessage(playerid, CINZA, "Espere 2 minutos para poder equipar novamente.");

    // =========================================================================
    // VERIFICAcaO DINaMICA DE PROXIMIDADE (ALINHADO COM /CRIARLCQ CORP)
    // =========================================================================
    if(!LocalEquipar[org][lcCriado]) 
    {
        return SendClientMessage(playerid, CINZA, "O ponto de equipar da sua ORG nao foi configurado pelo administrador.");
    }

    if(!IsPlayerInRangeOfPoint(playerid, 4.0, LocalEquipar[org][lcX], LocalEquipar[org][lcY], LocalEquipar[org][lcZ])) 
    {
        return SendClientMessage(playerid, CINZA, "Voce nao esta no local de equipar da sua organizacao.");
    }

    // Se a org possui cofre, o /equipar usa as armas realmente armazenadas nele.
    if(CofreOrg[org][cfCriado])
    {
        new retiradasCofre = 0;
        for(new slotCofre = 0; slotCofre < 13; slotCofre++)
        {
            if(CofreOrgArma[org][slotCofre] > 0 && CofreOrgAmmo[org][slotCofre] > 0)
                retiradasCofre++;
        }
        if(!retiradasCofre)
        {
            return SendClientMessage(playerid, 0xE74C3CFF, "[EQUIPAR] O cofre da sua organizacao esta vazio. Guarde armas no /cofre primeiro.");
        }
        ResetPlayerWeapons(playerid);
        for(new slotEquip = 0; slotEquip < 13; slotEquip++)
        {
            if(CofreOrgArma[org][slotEquip] > 0 && CofreOrgAmmo[org][slotEquip] > 0)
            {
                GivePlayerWeapon(playerid, CofreOrgArma[org][slotEquip], CofreOrgAmmo[org][slotEquip]);
                CofreOrgArma[org][slotEquip] = 0;
                CofreOrgAmmo[org][slotEquip] = 0;
            }
        }
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 100.0);
        BCG_SalvarCofreOrg(org);
        equipado2[playerid] = 1;
        SetTimerEx("equiparn", 120000, false, "i", playerid);
        SendClientMessage(playerid, 0x2ECC71FF, "[EQUIPAR] Voce se equipou com as armas do cofre da sua organizacao.");
        return 1;
    }

    // Logica para verificar o nivel VIP da Organizacao usando DOF2
    new nomeDaOrg[40], diretorioOrg[70], nivelVipOrg = 0;
    format(nomeDaOrg, sizeof(nomeDaOrg), GetNomeOrg(org));
    format(diretorioOrg, sizeof(diretorioOrg), "OrgsVips/%s.txt", nomeDaOrg);

    if(DOF2_FileExists(diretorioOrg))
    {
        nivelVipOrg = DOF2_GetInt(diretorioOrg, "NivelVip");
    }

    // Configuracao dos Kits com base no VIP da Org
    new Float:vidaMax = 100.0, Float:coleteMax = 100.0;
    new m_deagle = 300, m_mp5 = 500, m_fuzil = 500;
    new bool:ganhaShotgun = false, bool:ganhaSniper = false;

    switch(nivelVipOrg)
    {
        case 1: // ORG VIP BRONZE
        {
            coleteMax = 120.0; 
            m_deagle = 400; m_mp5 = 600; m_fuzil = 600; 
        }
        case 2: // ORG VIP PRATA
        {
            coleteMax = 135.0;
            m_deagle = 500; m_mp5 = 700; m_fuzil = 700;
            ganhaShotgun = true; 
        }
        case 3: // ORG VIP OURO
        {
            vidaMax = 100.0;
            coleteMax = 150.0; 
            m_deagle = 600; m_mp5 = 800; m_fuzil = 800;
            ganhaShotgun = true;
            ganhaSniper = true; 
        }
    }

    // Aplicando Vida e Colete
    SetPlayerHealth(playerid, vidaMax);
    SetPlayerArmour(playerid, coleteMax);
    
    // Variavel para controlar qual mensagem enviar no final
    new ePolicial = 0;

    // =========================================================================
    // BLOCO DE ENTREGA 1: ORGANIZAcoES POLICIAIS / ESTATAIS / MeDICOS (1 a 13 e 15)
    // =========================================================================
    if((org >= 1 && org <= 13) || org == 15)
    {
        ResetPlayerWeapons(playerid); 
        
        if(org == 15) // Medicos
        {
            GivePlayerWeapon(playerid, 41, 1000); // Extintor
            ePolicial = 2;
        }
        else // Policias em Geral
        {
            GivePlayerWeapon(playerid, 3, 1);          // Cacetete
            GivePlayerWeapon(playerid, 24, m_deagle);  // Desert Eagle
            GivePlayerWeapon(playerid, 29, m_mp5);     // MP5
            GivePlayerWeapon(playerid, 31, m_fuzil);   // M4A1
            
            if(ganhaShotgun) GivePlayerWeapon(playerid, 25, 100); 
            if(ganhaSniper)  GivePlayerWeapon(playerid, 34, 50);  
            ePolicial = 1;
        }
    }
    // =========================================================================
    // BLOCO DE ENTREGA 2: ORGANIZAcoES CRIMINOSAS / FACcoES / MaFIAS (16 a 32)
    // =========================================================================
    else if(org >= 16 && org <= 32)
    {
        GivePlayerWeapon(playerid, 24, m_deagle);  // Desert Eagle
        GivePlayerWeapon(playerid, 28, m_mp5);     // Micro Uzi
        GivePlayerWeapon(playerid, 30, m_fuzil);   // AK-47
        
        if(ganhaShotgun) GivePlayerWeapon(playerid, 25, 100); 
        if(ganhaSniper)  GivePlayerWeapon(playerid, 34, 50);  
        ePolicial = 0;
    }
    // =========================================================================
    // BLOCO DE ENTREGA 3: ORGANIZAcoES NEUTRAS (Ex: Mecanicos 33)
    // =========================================================================
    else
    {
        return SendClientMessage(playerid, CINZA, "Sua organizacao nao possui kit de armas de combate.");
    }

    // Alerta para a administracao
    new strAdm[128];
    if(nivelVipOrg > 0) format(strAdm, sizeof(strAdm), "[VIP ORG] O player %s pegou o kitorg melhorado (VIP Nivel %d).", Nome(playerid), nivelVipOrg);
    else format(strAdm, sizeof(strAdm), "O player %s pegou o kitorg padrao.", Nome(playerid));
    MsgAdm(strAdm);

    // =========================================================================
    // MENSAGENS DE SUCESSO CUSTOMIZADAS COM CORES EM EMBED ({HEX})
    // =========================================================================
    if(nivelVipOrg > 0)
    {
        if(ePolicial == 1) SendClientMessage(playerid, -1, "{00BFFF}[BCG CORPS] {FFFFFF}Voce pegou seus equipamentos com bonus VIP, boa patrulha!");
        else if(ePolicial == 2) SendClientMessage(playerid, -1, "{00BFFF}[BCG MEDICOS] {FFFFFF}Voce pegou seu kit medico com bonus VIP, bom trabalho!");
        else SendClientMessage(playerid, -1, "{FF0000}[BCG ORG] {FFFFFF}Voce pegou o kit de armas da sua faccao com bonus VIP!");
    }
    else
    {
        if(ePolicial == 1) SendClientMessage(playerid, -1, "{00BFFF}[BCG CORPS] {FFFFFF}Voce pegou seus equipamentos, boa patrulha!");
        else if(ePolicial == 2) SendClientMessage(playerid, -1, "{00BFFF}[BCG MEDICS] {FFFFFF}Voce pegou seu kit medico padrao, bom trabalho!");
        else SendClientMessage(playerid, -1, "{FF0000}[BCG ORG] {FFFFFF}Voce pegou o kit padrao da sua organizacao.");
    }

    // Ativa o temporizador de reuso
    equipado2[playerid] = 1;
    SetTimerEx("equiparn", 120000, false, "i", playerid); 

    return 1;
}

CMD:revistar(playerid, params[])
{
    if(Pdados[playerid][OrgID] == 0) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao faz parte de nenhuma corp");
    
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AZUL_CLARO, "Use /revistar [IDF]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao esta online");
    if(!IsPerto(playerid, id)) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao esta perto o bastante");
    
    new a = 0, Arma[50];
    format(String, sizeof(String), "O %s esta armado com:", Nome(id));
    for (new i = 0, weapon = 0, ammo; i <= 12; i++)
    {   
        if(GetPlayerWeaponData(id, i, weapon, ammo))
        {
            if(weapon != 0)
            {
                GetWeaponName(weapon, Arma, sizeof(Arma));
                strcat(Arma, "\n"); strcat(String, Arma);
                weapon = 0; a++;
            }
        }
    }
    if(a != 0)
    {
        ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Revista", String, "Pegar", "Fechar");
        Pdados[playerid][Revistado] = id; // Mantem o ID real do servidor para o Dialog funcionar
    }
    else
    {
        format(String, sizeof(String), "%s nao esta armado", Nome(id));
        ShowPlayerDialog(playerid, 100, DIALOG_STYLE_MSGBOX, "Revista", String, "", "Fechar");
    }
    format(String, sizeof(String), "O %s revistou o %s", Nome(playerid), Nome(id));
    MsgPerto(playerid, AZUL_CLARO, String);
    return 1;
}

CMD:arr(playerid, params[])
{
    if(Pdados[playerid][OrgID] == 0) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao faz parte de nenhuma corp");
    
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AZUL_CLARO, "Use /arr [IDF]");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, VERMELHO, "Voce nao esta em um veiculo!");
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao e o motorista");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao esta online");
    if(!(IsPerto(playerid, id))) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao esta perto o bastante");
    
    PutPlayerInVehicle(id, GetPlayerVehicleID(playerid), 3);
    format(String, sizeof(String), "O %s arrastou o %s para o carro", Nome(playerid), Nome(id));
    MsgPerto(playerid, AZUL_CLARO, String);
    return 1;
}

CMD:rem(playerid, params[])
{
    if(Pdados[playerid][OrgID] == 0) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao faz parte de nenhuma corp");
    
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AZUL_CLARO, "Use /rem [IDF]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao esta online");
    if(!(IsPerto(playerid, id))) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao esta perto o bastante");
    
    Pdados[id][Algemado] = false;
    RemovePlayerFromVehicle(id);
    format(String, sizeof(String), "O %s retirou o %s do carro", Nome(playerid), Nome(id));
    MsgPerto(playerid, AZUL_CLARO, String);
    return 1;
}

CMD:farda(playerid, params[])
{
    new orgid = Pdados[playerid][OrgID];
    if((orgid < 1) || (orgid > 12)) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao e policial para usar este menu!");
    
    new bool:pertoPonto = false;

    for(new i = 1; i <= 12; i++)
    {
        if(LocalEquipar[i][lcCriado] && IsPlayerInRangeOfPoint(playerid, 5.0, LocalEquipar[i][lcX], LocalEquipar[i][lcY], LocalEquipar[i][lcZ]))
        {
            pertoPonto = true;
            break;
        }
    }

    if(!pertoPonto) return SendClientMessage(playerid, CINZA, "Voce nao esta no local de farda/equipar da sua organizacao.");

    new menuStr[500];
    strcat(menuStr, "1. Pegar Farda (Por Genero)\n");
    strcat(menuStr, "2. Bater Ponto (Iniciar/Sair da Folga)\n");
    strcat(menuStr, "3. Pegar Equipamentos Padrao\n");
    strcat(menuStr, "4. Pegar Equipamentos [VIP]\n");
    strcat(menuStr, "5. Comprar Adrenalina (R$ 45,00 cada)\n");
    strcat(menuStr, "6. Comprar Adrenalina [VIP] (Gratis)\n");
    strcat(menuStr, "7. Ativar Patrulha\n");
    strcat(menuStr, "8. Modo Ostensivo\n");
    strcat(menuStr, "9. Regras Corps");

    ShowPlayerDialog(playerid, DIALOG_MENU_CORPS, DIALOG_STYLE_LIST, "{F1C40F}MENU CORPS - CENTRAL POLICIAL", menuStr, "Selecionar", "Fechar");
    return 1;
}

CMD:multar(playerid, params[])
{
    if((Pdados[playerid][OrgID] == 0) && (Pdados[playerid][OrgID] <= 13)) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao faz parte de nenhuma corp");
    
    new id_procurado, valor;
    if(sscanf(params, "ii", id_procurado, valor)) return SendClientMessage(playerid, AZUL_CLARO, "Use /multa [IDF] [PRECO DA MULTA]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao esta online");
    
    GivePlayerMoney(id, -valor);
    format(String, sizeof(String), "O oficial %s aplicou uma multa em %s de %i", Nome(playerid), Nome(id), valor);
    MsgPerto(playerid, AZUL_CLARO, String);
    SalvarDados(id);
    return 1;
}

CMD:ab(playerid)
{
    if(!Pdados[playerid][Logado]) 
        return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");

    new org = Pdados[playerid][OrgID];
    if(org == 0) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao faz parte de nenhuma org/corp");
    if(org > 12 && org < 16) return SendClientMessage(playerid, AZUL_CLARO, "Sua corp nao pode abordar");

    new message[144];
    if(org >= 1 && org <= 12)
    {
        format(message, sizeof(message), "[%s] Parado ou abriremos fogo! - %s", NomeOrg(playerid), Nome(playerid));
    }
    else if(org >= 16)
    {
        format(message, sizeof(message), "[%s] PERDEU COMEDIA DESCE DESCE!! - %s", NomeOrg(playerid), Nome(playerid));
    }

    new Float:pos[3];
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(IsPlayerInRangeOfPoint(i, 15.0, pos[0], pos[1], pos[2]))
        {
            SendClientMessage(i, AMARELO, message);
        }
    }
    return 1;
}

CMD:amarrar(playerid, params[])
{
    new org = Pdados[playerid][OrgID];
    if(org >= 16 && org <= 30)
    {
        if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
        
        new id_procurado;
        if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /amarrar [IDF]");
        
        // --- BUSCA PELO ID ---
        new id = INVALID_PLAYER_ID;
        id = BCG_BuscarPorIDFixo(id_procurado);
        if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player nao esta online");
        
        if(playerid == id) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Voce nao pode amarrar voce mesmo");
        
        if(GetDistanceBetweenPlayers(playerid, id) < 10)
        {
            TogglePlayerControllable(id, 0);
            algemado[id] = 1;
            format(String, sizeof(String), "Voce foi amarrado pelo criminoso %s da %s", Nome(playerid), NomeOrg(playerid));
            SendClientMessage(id, AMARELO, String);
            format(String, sizeof(String), "%s foi amarrado pelo %s", Nome(id), Nome(playerid));
            SendClientMessage(playerid, AZUL_CLARO, String);
        }
        else
        {
            SendClientMessage(playerid, AZUL_CLARO, "Chegue mais perto para amarrar");
        }
    }
    else
    {
        SendClientMessage(playerid, AZUL_CLARO, "Voce nao e um criminoso para amarrar");
    }
    return 1;
}

CMD:algemar(playerid, params[])
{
    new org = Pdados[playerid][OrgID];
    if(org >= 1 && org <= 12)
    {
        if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
        
        new id_procurado;
        if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /algemar [IDF]");
        
        // --- BUSCA PELO ID ---
        new id = INVALID_PLAYER_ID;
        id = BCG_BuscarPorIDFixo(id_procurado);
        if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player nao esta online");
        
        if(playerid == id) return SendClientMessage(playerid, vermelho, "| ERRO | {FFFFFF}Voce nao pode algemar voce mesmo");
        
        if(GetDistanceBetweenPlayers(playerid, id) < 10)
        {
            TogglePlayerControllable(id, 0);
            algemado[id] = 1;
            format(String, sizeof(String), "Voce foi algemado pelo oficial %s da %s", Nome(playerid), NomeOrg(playerid));
            SendClientMessage(id, AMARELO, String);
            format(String, sizeof(String), "%s foi algemado pelo %s", Nome(id), Nome(playerid));
            SendClientMessage(playerid, AZUL_CLARO, String);
        }
        else
        {
            SendClientMessage(playerid, AZUL_CLARO, "Chegue mais perto para algemar");
        }
    }
    else
    {
        SendClientMessage(playerid, AZUL_CLARO, "Voce nao e policial para algemar");
    }
    return 1;
}

CMD:desalgemar(playerid, params[])
{
    if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
    if((Pdados[playerid][OrgID] < 1) || (Pdados[playerid][OrgID] > 12)) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao e policial para desalgemar");
    
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /desalgemar [IDF]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player nao esta online");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(!IsPlayerInRangeOfPoint(id, 2.0, x, y, z)) return SendClientMessage(playerid, AZUL_CLARO, "Chegue mais perto para desalgemar");
    
    TogglePlayerControllable(id, 1);
    algemado[id] = 0; // Adicionada zeragem da variavel nativa
    format(String, sizeof(String), "Voce foi desalgemado pelo oficial %s da %s", Nome(playerid), NomeOrg(playerid));
    SendClientMessage(id, AMARELO, String);
    format(String, sizeof(String), "%s foi desalgemado pelo %s", Nome(id), Nome(playerid));
    
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 5.0, x, y, z))
        {
            SendClientMessage(i, AMARELO, String);
        }
    }
    return 1;
}

CMD:d(playerid, params[])
{
    new msg[128];
    if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
    if(Pdados[playerid][OrgID] < 1 || Pdados[playerid][OrgID] > 15) return 1;
    if(sscanf(params, "s", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Use /d [MENSAGEM] para falar no departamento");
    
    format(String, sizeof(String), "Departamento:%s >%s: %s", NomeOrg(playerid), Nome(playerid), msg);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && (Pdados[i][OrgID] >= 1) && (Pdados[i][OrgID] <= 15))
        {
            SendClientMessage(i, ROSA_CHOQUE, String);
        }
    }
    return 1;
}

CMD:r(playerid, params[])
{
    new msg[128];
    if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
    if(Pdados[playerid][OrgID] < 1 || Pdados[playerid][OrgID] > 33) return 1;
    if(sscanf(params, "s", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Use /r [MENSAGEM] para falar com sua corp");
    
    format(String, sizeof(String), "Radio: %s: %s", Nome(playerid), msg);
    MsgOrg(playerid, String);
    return 1;
}

CMD:ct(playerid, params[])
{
    new msg[128];
    if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
    if(Pdados[playerid][Vip] < 1) return 1;
    if(Pdados[playerid][OrgID] > 3) return 1;
    if(sscanf(params, "s", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Use /ct [MENSAGEM] para falar no chat vip");
    
    format(String, sizeof(String), "[{FFFFFF}Chat VIP{FFFF00}] %s: {FFFFFF}%s", Nome(playerid), msg);
    MsgVip(playerid, String);
    return 1;
}

CMD:ga(playerid, params[])
{
    new msg[128];
    if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");
    if(Pdados[playerid][OrgID] < 16 || Pdados[playerid][OrgID] > 32) return 1;
    if(sscanf(params, "s", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Use /ga [MENSAGEM] para falar com sua org");
    
    format(String, sizeof(String), "Radio: %s: %s", Nome(playerid), msg);
    MsgOrg(playerid, String);
    return 1;
}

//Lideres
CMD:convidar(playerid, params[]) 
{
    // 1. Primeiro verificamos se VOCE esta logado e pode usar o comando
    if(!Pdados[playerid][Logado]) return SendClientMessage(playerid, CINZA, "Voce nao esta logado.");
    if(Pdados[playerid][OrgID] == 0) return SendClientMessage(playerid, AZUL_CLARO, "Voce nao pertence a uma organizacao.");
    if(Pdados[playerid][Cargo] < 4) return SendClientMessage(playerid, AZUL_CLARO, "Apenas Lideres ou Sub-Lideres podem convidar.");
    
    new id_procurado;
    // 2. Agora tentamos ler o ID que voce digitou (mudado 'u' para 'i')
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AZUL_CLARO, "Use /convidar [IDF]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Player offline.");
    
    // 4. AGORA SIM verificamos se o jogador convidado e novato (usando as 10 horas como base)
    if(Pdados[id][SegundosJogados] < 36000)
    {
        return SendClientMessage(playerid, VERMELHO, "Este jogador ainda e um novato (menos de 10h) e nao pode entrar em organizacoes!");
    }

    // 5. Verificamos se ele ja tem uma org
    if(Pdados[id][OrgID] != 0) return SendClientMessage(playerid, AZUL_CLARO, "Este player ja esta in em uma organizacao.");

    // --- Se passou em tudo, envia o convite ---
    Pdados[id][convite] = Pdados[playerid][OrgID]; 
    
    format(String, sizeof(String), "Convite enviado para %s.", Nome(id));
    SendClientMessage(playerid, CINZA, String);

    format(String, sizeof(String), "{FFFFFF}O %s {33CCFF}%s {FFFFFF}esta lhe convidando para entrar na:\n{33CCFF}%s", 
        (Pdados[playerid][Cargo] == 5 ? "Lider" : "Sub-Lider"), Nome(playerid), NomeOrg(playerid));
        
    ShowPlayerDialog(id, DIALOG_CONVITE, DIALOG_STYLE_MSGBOX, "{33CCFF}Convite de Organizacao", String, "Aceitar", "Recusar");
    return 1;
}

CMD:demitir(playerid, params[]) {
    if(!Pdados[playerid][Logado]) return 1;
    if(Pdados[playerid][Cargo] < 4) return SendClientMessage(playerid, AZUL_CLARO, "Sem permissao.");
    
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AZUL_CLARO, "Use /demitir [IDF]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Player offline.");
    
    if(Pdados[id][OrgID] != Pdados[playerid][OrgID]) return SendClientMessage(playerid, AZUL_CLARO, "Este player nao e da sua organizacao.");
    
    // Impede Sub-lider de demitir o Lider
    if(Pdados[id][Cargo] >= Pdados[playerid][Cargo] && id != playerid) 
        return SendClientMessage(playerid, CINZA, "Voce nao pode demitir alguem com cargo igual ou superior ao seu.");

    format(String, sizeof(String), "Voce demitiu o player %s da organizacao.", Nome(id));
    SendClientMessage(playerid, CINZA, String);

    format(String, sizeof(String), "Voce foi demitido da %s por %s.", NomeOrg(playerid), Nome(playerid));
    SendClientMessage(id, 0xFF6347AA, String);

    Pdados[id][OrgID] = 0;
    Pdados[id][Cargo] = 0;
    SalvarDados(id);
    SpawnPlayer(id); 
    return 1;
}

CMD:promover(playerid, params[]) {
    if(!Pdados[playerid][Logado]) return 1;
    if(Pdados[playerid][Cargo] < 4) return SendClientMessage(playerid, AZUL_CLARO, "Apenas Lideres ou Sub-Lideres.");
    
    new id_procurado, cargo;
    if(sscanf(params, "ii", id_procurado, cargo)) return SendClientMessage(playerid, AZUL_CLARO, "Use /promover [IDF] [1-5]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Player offline.");
    
    if(Pdados[id][OrgID] != Pdados[playerid][OrgID]) return SendClientMessage(playerid, AZUL_CLARO, "Player nao e da sua org.");

    // Trava de seguranca para cargos
    if(cargo >= Pdados[playerid][Cargo] && Pdados[playerid][Cargo] != 5) 
        return SendClientMessage(playerid, CINZA, "Voce so pode promover alguem a um cargo menor que o seu.");
    
    if(cargo < 1 || cargo > 5) return SendClientMessage(playerid, CINZA, "Cargos validos: 1 a 5.");

    Pdados[id][Cargo] = cargo;
    SalvarDados(id);

    format(String, sizeof(String), "Voce promoveu %s para o Cargo %d (%s).", Nome(id), cargo, NomeCargo(id));
    SendClientMessage(playerid, CINZA, String);

    format(String, sizeof(String), "O %s %s lhe promoveu para o Cargo %d (%s).", 
        (Pdados[playerid][Cargo] == 5 ? "Lider" : "Sub-Lider"), Nome(playerid), cargo, NomeCargo(id));
    SendClientMessage(id, AZUL_CLARO, String);
    return 1;
}

CMD:pedircontas(playerid) {
    if(!Pdados[playerid][Logado]) return 1;
    if(Pdados[playerid][OrgID] == 0) return SendClientMessage(playerid, CINZA, "Voce nao tem emprego/org.");
    if(Pdados[playerid][Cargo] == 5) return SendClientMessage(playerid, CINZA, "Lideres devem usar /rlider com um ADM.");

    // Avisa a organizacao que o player saiu
    format(String, sizeof(String), "[RADIO] O membro %s pediu contas e saiu da organizacao.", Nome(playerid));
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && Pdados[i][OrgID] == Pdados[playerid][OrgID]) {
            SendClientMessage(i, 0x33CCFFAA, String);
        }
    }

    SendClientMessage(playerid, AZUL, "Voce pediu contas e agora esta desempregado.");
    Pdados[playerid][OrgID] = 0;
    Pdados[playerid][Cargo] = 0;
    SalvarDados(playerid);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 1);
    SetPlayerVirtualWorld(playerid, 0);
    SpawnPlayer(playerid);
    return 1;
}


// ==========================================
// COMANDO: /ACEITARSERVICO
// ==========================================
CMD:aceitarservico(playerid, params[])
{
    new id_procurado, Float:p[3];
    if(sscanf(params, "i", id_procurado)) 
        return SendClientMessage(playerid, -1, "{78DBE2}[USO]: {FFFFFF}/aceitarservico [ID]");

    // --- BUSCA SEGURA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    
    if(id == INVALID_PLAYER_ID) 
        return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Este jogador esta offline.");

    switch(Pdados[playerid][OrgID])
    {
        case 33: // Mecanicos
        {
            if(Pdados[id][Servico] != 1) 
                return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Esta pessoa nao solicitou servico de mecanico.");
            
            Pdados[id][Servico] = 0;
            GetPlayerPos(id, p[0], p[1], p[2]);
            SetPlayerCheckpoint(playerid, p[0], p[1], p[2], 5.0);
            
            SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}[SUCESSO]: {FFFFFF}Cliente marcado em seu mapa.");
            
            new string_mecanico[128];
            format(string_mecanico, sizeof(string_mecanico), "{FFFF00}O mecanico %s atendeu ao seu chamado e esta a caminho!", Nome(playerid));
            SendClientMessage(id, AMARELO, string_mecanico);
        }
        case 1 .. 12: // Organizacoes Policiais
        {
            if(Pdados[id][Servico] != 2) 
                return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Esta pessoa nao solicitou servico policial.");
            
            Pdados[id][Servico] = 0;
            GetPlayerPos(id, p[0], p[1], p[2]);
            SetPlayerCheckpoint(playerid, p[0], p[1], p[2], 5.0);
            
            SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}[SUCESSO]: {FFFFFF}Individuo marcado em seu mapa.");
            
            new string_policia[128];
            format(string_policia, sizeof(string_policia), "{FFFF00}A policia (%s) atendeu ao seu chamado e esta a caminho!", Nome(playerid));
            SendClientMessage(id, AMARELO, string_policia);
        }
        default:
        {
            return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Sua organizacao nao possui permissao para usar este comando.");
        }
    }
    return 1;
}

// ==========================================
// COMANDO: /SERVICO
// ==========================================
CMD:servico(playerid, params[])
{
    if(Pdados[playerid][OrgID] != 33) 
        return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Voce nao e um mecanico.");

    if(servico[playerid] == 0)
    {
        servico[playerid] = 1;
        new aname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, aname, MAX_PLAYER_NAME);
        
        new string_servico[144];
        format(string_servico, sizeof(string_servico), "{00BFFF}[EMPREGO]: {FFFFFF}O mecanico %s (ID: %d) entrou em servico! Use /pedirmecanico.", aname, playerid);
        SendClientMessageToAll(AZUL, string_servico);
    }
    else
    {
        SendClientMessage(playerid, CINZA, "{FF0000}[AVISO]: {FFFFFF}Voce ja esta em servico. Use /sairservico para sair.");
    }
    return 1;
}

// ==========================================
// COMANDO: /SAIRSERVICO
// ==========================================
CMD:sairservico(playerid, params[])
{
    if(Pdados[playerid][OrgID] != 33) 
        return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Voce nao e um mecanico.");

    if(servico[playerid] == 1)
    {
        servico[playerid] = 0;
        SendClientMessage(playerid, CINZA, "{999999}[AVISO]: {FFFFFF}Voce saiu de servico com sucesso.");
    }
    else
    {
        SendClientMessage(playerid, CINZA, "{999999}[AVISO]: {FFFFFF}Voce ja esta fora de servico.");
    }
    return 1;
}

// ==========================================
// COMANDO: /CONSERTARC
// ==========================================
CMD:consertarc(playerid, params[])
{
    if(Pdados[playerid][OrgID] != 33) return 1;
    if(servico[playerid] != 1) return SendClientMessage(playerid, VERMELHO, "{FF0000}[ERRO]: {FFFFFF}Voce nao esta em servico.");

    new id_procurado, valor_proposta;
    if(sscanf(params, "ii", id_procurado, valor_proposta)) 
        return SendClientMessage(playerid, CINZA, "{00BFFF}[USO]: {FFFFFF}/consertarc [ID] [PREcO]");

    // --- BUSCA SEGURA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    
    if(id == INVALID_PLAYER_ID) 
        return SendClientMessage(playerid, CINZA, "{FF0000}[ERRO]: {FFFFFF}Jogador offline ou ID incorreto.");

    // Validacoes de proximidade e veiculo do cliente
    if(GetDistanceBetweenPlayers(playerid, id) >= 10.0) 
        return SendClientMessage(playerid, CINZA, "{FF0000}[ERRO]: {FFFFFF}Voce esta muito longe do cliente.");
        
    if(!IsPlayerInAnyVehicle(id)) 
        return SendClientMessage(playerid, CINZA, "{00BFFF}[ERRO]: {FFFFFF}O cliente precisa estar dentro de um veiculo.");

    if(valor_proposta <= 0)
        return SendClientMessage(playerid, CINZA, "{FF0000}[ERRO]: {FFFFFF}O preco do servico deve ser maior que zero.");

    preco[id] = valor_proposta;
    Pdados[id][Servico] = playerid; // Vincula o ID real do mecanico para o Dialog processar o pagamento

    new string_dialogo[256];
    format(string_dialogo, sizeof(string_dialogo), "{FFFFFF}O mecanico {007FFF}%s {FFFFFF}lhe ofereceu um conserto.\n\n{51BCFF}Preco cobrado: {00FF00}$%i", Nome(playerid), valor_proposta);
    ShowPlayerDialog(id, DIALOG_SERVICO_MECANICO, DIALOG_STYLE_MSGBOX, "{FFFF00}Servico Mecanico", string_dialogo, "Aceitar", "Recusar");
    
    SendClientMessage(playerid, AZUL_CLARO, "{00BFFF}[SUCESSO]: {FFFFFF}Proposta de conserto enviada ao cliente.");
    return 1;
}


public OnPlayerDeath(playerid, killerid, reason)
{
    new bool:cg54WasTesting=CG54Inside[playerid];
    if(CG54Inside[playerid]) {
        SetPlayerVirtualWorld(playerid,CG54World[playerid]);
        SetPlayerInterior(playerid,CG54Interior[playerid]);
        CG54Reset(playerid);
        TogglePlayerControllable(playerid,true);
    }
    new msgFerido[144];
    if(killerid != INVALID_PLAYER_ID && IsPlayerConnected(killerid))
    {
        format(msgFerido, sizeof(msgFerido), "{FF3333}[FERIDO] {FFFFFF}ID: %d esta ferido | ID de quem matou: %d", playerid, killerid);
    }
    else
    {
        format(msgFerido, sizeof(msgFerido), "{FF3333}[FERIDO] {FFFFFF}ID: %d esta ferido | ID de quem matou: N/A", playerid);
    }
    SendClientMessage(playerid, 0xFFFFFFFF, msgFerido);

    IniciarEstadoComa(playerid);
    if(cg54WasTesting) {
        g_DadosMorte[playerid][pMortoX]=CG54Return[playerid][0];
        g_DadosMorte[playerid][pMortoY]=CG54Return[playerid][1];
        g_DadosMorte[playerid][pMortoZ]=CG54Return[playerid][2];
        g_DadosMorte[playerid][pMortoA]=CG54Return[playerid][3];
    }
    return 1;
}

CMD:dance(playerid, params[])
{
    new danca;
    if(sscanf(params, "d", danca)) return SendClientMessage(playerid, AMARELO, "Use /dance [1~4]");
    if(danca > 4)return SendClientMessage(playerid,VERMELHO,"Use /dance [1~4]");
    switch(danca)
    {
        case 1: ApplyAnimation(playerid, "DANCING", "bd_clap", 4.1, 1, 1, 0, 0, 0);
        case 2: ApplyAnimation(playerid, "DANCING", "bd_clap1", 4.1, 1, 1, 0, 0, 0);
        case 3: ApplyAnimation(playerid, "DANCING", "dance_loop", 4.1, 1, 1, 0, 0, 0);
        case 4: ApplyAnimation(playerid, "DANCING", "DAN_Down_A", 4.1, 1, 1, 0, 0, 0);
    }
    return 1;
}
CMD:render(playerid)
{
    ApplyAnimation(playerid, "PED", "handsup", 4.1, 0, 1, 1, 1, 1, 1);
    return 1;
}
CMD:desmaiar(playerid)
{
	ApplyAnimation(playerid, "PED", "KO_shot_stom", 4.1, 0, 0, 1, 1, 0, 0);
	return 1;
}
CMD:cruzarb(playerid)
{
    ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.1, 0, 1, 1, 1, 1, 1);
    return 1;
}
CMD:sentar(playerid)
{
    ApplyAnimation(playerid, "PED", "SEAT_down", 4.1, 0, 1, 1, 1, 1, 1);
    return 1;
}
CMD:anim(playerid){
	ClearAnimations(playerid);
	return 1;
}
CMD:prefeitura(playerid){
	if(IsPlayerInRangeOfPoint(playerid,5,361.867340, 173.422683, 1008.382812))
    {
		ShowPlayerDialog(playerid,DIALOG_LICENCA,DIALOG_STYLE_INPUT,"{FFFF00}Licencas","{4CBB17}1 - {FFFFFF}Habilitacao carro\t{4CBB17}$5000\n2 - {FFFFFF}Habilitacao moto\t{4CBB17}$3000\n3 - {FFFFFF}Habilitacao caminhao\t{4CBB17}$8000\n4 - {FFFFFF}Porte de armas\t{4CBB17}$80000","{FFFFFF}Aceitar","{FFFFFF}Cancelar");
	}
	return 1;
}
CMD:menuv(playerid){
	new motor,farois,alarme,doors,bonnet,boot,obj;
	if(!IsPlayerInAnyVehicle(playerid))return 1;
	if(GetPlayerState(playerid) > 2)return SendClientMessage(playerid,VERMELHO,"Voce nao pode usar esse comando");
	GetVehicleParamsEx(GetPlayerVehicleID(playerid),motor,farois,alarme,doors,bonnet,boot,obj);
	format(String,sizeof(String),"");
	if(motor == 0){
		strcat(String,"{FFFFFF}Motor\t{FF0000}Desligado\n");
	}else{
		strcat(String,"{FFFFFF}Motor\t{00FF00}Ligado\n");
	}if(farois == 0){
		strcat(String,"{FFFFFF}Farois\t{FF0000}Desligado\n");
	}else{
		strcat(String,"{FFFFFF}Farois\t{00FF00}Ligado\n");
	}
    if(doors == 0) strcat(String,"{FFFFFF}Portas\t{00FF00}Destravadas\n");
    else strcat(String,"{FFFFFF}Portas\t{FF0000}Travadas\n");
    if(bonnet == 0) strcat(String,"{FFFFFF}Capo\t{FF0000}Fechado\n");
    else strcat(String,"{FFFFFF}Capo\t{00FF00}Aberto\n");
    if(boot == 0) strcat(String,"{FFFFFF}Porta-malas\t{FF0000}Fechado\n");
    else strcat(String,"{FFFFFF}Porta-malas\t{00FF00}Aberto\n");
	new ab[256];
	format(ab,sizeof(ab),"{FFFFFF}Carga\t%s\n",NomeCarga(GetPlayerVehicleID(playerid)));
	strcat(String,ab);
	format(ab,sizeof(ab),"{FFFFFF}Dono:\t%s\n",Nome(CarDados[GetPlayerVehicleID(playerid)][motorista]));
	ShowPlayerDialog(playerid,DIALOG_MENUV,DIALOG_STYLE_LIST,"{FFFF00}Menu carro",String,"Aceitar","Cancelar");
	return 1;
}
CMD:caixa(playerid, params[])
{
    #pragma unused params
    return BCG_UsarCaixaEletronico(playerid);
}

CMD:banco(playerid)
{
    if(IsPlayerInRangeOfPoint(playerid, 2, 2311.636962, -3.778552, 26.742187) || IsPlayerInRangeOfPoint(playerid, 2, 358.386749, 183.878906, 1008.382812))
    {
        ShowPlayerDialog(playerid, DIALOG_BANCO, DIALOG_STYLE_LIST, "Banco", "Sacar\nDepositar\nSaldo", "Selecionar", "Cancelar");
    }
    else
    {
        SendClientMessage(playerid, -1, "Voce nao esta em um banco.");
    }
    return 1;
}

CMD:pagar(playerid, params[])
{
    if(Pdados[playerid][Logado] == false) return SendClientMessage(playerid, CINZA, "Voce nao pode usar esse comando");

    new id_procurado, rd;
    if(sscanf(params, "ii", id_procurado, rd)) return SendClientMessage(playerid, AZUL_CLARO, "Use /pagar [IDF] [QUANTIA]");
    if(rd < 1) return SendClientMessage(playerid, VERMELHO, "VALOR INVALIDO");
    if(GetPlayerMoney(playerid) < rd) return SendClientMessage(playerid, VERMELHO, "Voce nao tem esse dinheiro");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, VERMELHO, "Jogador offline.");

    // Impede o jogador de pagar a si mesmo
    if(id == playerid) return SendClientMessage(playerid, VERMELHO, "Voce nao pode pagar a si mesmo.");

    // Pega a posicao de quem vai pagar
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // Verifica se o jogador receptor (id) esta perto (raio de 5 metros)
    if(IsPlayerInRangeOfPoint(id, 5.0, x, y, z))
    {
        GivePlayerMoney(playerid, -rd);
        GivePlayerMoney(id, rd);

        format(String, sizeof(String), "%s te pagou %i", Nome(playerid), rd);
        SendClientMessage(id, AMARELO, String);
        SendClientMessage(playerid, AZUL_CLARO, "Pago com sucesso");
        
        SalvarDados(playerid);
        SalvarDados(id);
    }
    else
    {
        SendClientMessage(playerid, VERMELHO, "Voce esta muito longe desse jogador para pagar.");
    }
    return 1;
}

CMD:roupa(playerid,params[]){
    new i,idskin;
    i = GetPlayerInterior(playerid);
    if(i != 14)return 1;
    if(!(IsPlayerInRangeOfPoint(playerid,5,204.085601, -160.178436, 1000.523437)))return 1;
	if(sscanf(params,"i",idskin))return SendClientMessage(playerid,CINZA,"Use /roupa [ID DA SKIN]");
	i = GetPlayerMoney(playerid);
	if(i < 2000) return SendClientMessage(playerid,VERMELHO,"Voce precisa de 2000 para trocar de roupa");
	GivePlayerMoney(playerid,-2000);
	SetPlayerSkin(playerid,idskin);
	format(String,sizeof(String),"Voce mudou sua skin para %i",idskin);
	SendClientMessage(playerid,AZUL_CLARO,String);
	Pdados[playerid][Skin] = idskin;
	format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
	DOF2_SetInt(StringContas, "Skin", Pdados[playerid][Skin]);
	DOF2_SaveFile();
	return 1;
}
CMD:vendercarro(playerid){
	if(IsPlayerInAnyVehicle(playerid))
	{
  	if(GetPlayerVehicleID(playerid)<=existe)return SendClientMessage(playerid,AZUL_CLARO,"Voce nao pode vender esse veiculo");
	if(CarDados[GetPlayerVehicleID(playerid)][dono] == playerid){
	if(Dados[playerid][id1]==GetPlayerVehicleID(playerid)){
	new dinheiro = precovehicle(GetVehicleModel(GetPlayerVehicleID(playerid))) /2;
	DestroyVehicle(Dados[playerid][id1]);
 	Dados[playerid][id1] = -1;
	GivePlayerMoney(playerid,dinheiro);
	Dados[playerid][modelo1] = 0;
	SendClientMessage(playerid, AMARELO, "Seu veiculo foi vendido pela metade do preco que voce pagou");
	SalvarDados(playerid);
	return 1;
	}
	if(Dados[playerid][id2]==GetPlayerVehicleID(playerid)){
 	new dinheiro = precovehicle(GetVehicleModel(GetPlayerVehicleID(playerid))) /2;
 	DestroyVehicle(Dados[playerid][id2]);
 	Dados[playerid][id2] = -1;
	GivePlayerMoney(playerid,dinheiro);
	Dados[playerid][modelo1] = 0;
	SendClientMessage(playerid, AMARELO, "Seu veiculo foi vendido pela metade do preco que voce pagou");
	SalvarDados(playerid);
	return 1;
	}
    }
    }

	return 1;
}
CMD:ang(playerid,params[]){
	format(String,sizeof(String),"Aguarde %i segundos para usar o /ang",t);
	if(t != 0)return SendClientMessage(playerid,AZUL_CLARO,String);
    if(Pdados[playerid][Logado] == false)return SendClientMessage(playerid,CINZA,"Voce nao pode usar esse comando");
	new msg[128];
	if(GetPlayerMoney(playerid)<500)return SendClientMessage(playerid,VERMELHO,"Voce nao tem 500 para pagar o anuncio");
	GivePlayerMoney(playerid,-500);
	if(sscanf(params,"s",msg))return SendClientMessage(playerid,AZUL_CLARO,"Use /ang para fazer um anuncio");
	format(String,sizeof(String),"[Anuncio] %s(%i): %s",Nome(playerid),playerid,msg);
	SendClientMessageToAll(VERDE_CLARO,String);
	t = 15;
	SetTimer("tang",1000,false);
	return 1;
}
CMD:anv(playerid, params[])
{
	if(tvip[playerid] == 0){
    if(!Pdados[playerid][Vip]) return SendClientMessage(playerid, vermelho, "Voce nao e um jogador VIP");
	new msg[128];
	if(sscanf(params,"s",msg))return SendClientMessage(playerid, vermelho,"Use /anv [anuncio vip].");
	SendClientMessageToAll(branco, "____________________ {FFFF00}AVISO VIP {FFFFFF}____________________");
	format(String,sizeof(String),"Anuncio {FFFF00}%s. {FFFFFF}| [{FFFF00}VIP{FFFFFF}] (%s)", msg, Nome(playerid));
	SendClientMessageToAll(branco,String);
	tvip[playerid] = 1;
	SetTimerEx("TempoVip", 120000, true, "i", playerid);
	}else{
	SendClientMessage(playerid, CINZA, "Espere 2 minutos para poder anunciar novamente.");
	}
	return 1;
}
CMD:anvi(playerid, params[])
{
    if(!Pdados[playerid][YouTuber]) return SendClientMessage(playerid, vermelho, "Voce nao e um YouTuber");
	new msg[128];
	if(sscanf(params,"s",msg))return SendClientMessage(playerid, vermelho,"Use /anvi para divulgar seu video.");
	SendClientMessageToAll(0xff0000ff, "____________________ {FFFFFF}AVISO YOUTUBER {ff0000}____________________");
	format(String,sizeof(String),"Tema: {ff0000}%s.{FFFFFF}| [{ff0000}YouTuber{FFFFFF}] (%s)", msg, Nome(playerid));
	SendClientMessageToAll(branco,String);
	return 1;
}
CMD:anyt(playerid, params[])
{
    if(!Pdados[playerid][YouTuber]) return SendClientMessage(playerid, vermelho, "Voce nao e um YouTuber");
	new msg[128];
	if(sscanf(params,"s",msg))return SendClientMessage(playerid, vermelho,"Use /anyt [nome-do-canal].");
	SendClientMessageToAll(0xff0000ff, "____________________ {FFFFFF}DIVULGACAO DE CANAL {ff0000}____________________");
	format(String,sizeof(String),"Nome do canal: [{ff0000}%s{FFFFFF}] | [{ff0000}YouTuber{FFFFFF}]: (@%s)", msg, Nome(playerid));
	SendClientMessageToAll(branco,String);
	return 1;
}
CMD:gov(playerid, params[])
{
	if(Pdados[playerid][OrgID] >= 1 || Pdados[playerid][OrgID] <= 34){
	new msg[128];
	if(sscanf(params,"s",msg))return SendClientMessage(playerid, vermelho,"Use /gov [anuncio].");
	SendClientMessageToAll(AMARELO, "=-=-=-=-=-=-=-=-=-=-=-=-=-= AVISO ORG =-=-=-=-=-=-=-=-=-=-=-=-=-=");
	format(String,sizeof(String),"[{FFFF00}%s{FFFFFF}] {FFFF00}%s {FFFFFF}({FFFF00}@%s{FFFFFF})", NomeOrg(playerid), msg, Nome(playerid));
	SendClientMessageToAll(branco,String);
	}
	return 1;
}
CMD:ptr(playerid, params[])
{
    if(Pdados[playerid][OrgID] == 1 || Pdados[playerid][OrgID] == 2 || Pdados[playerid][OrgID] == 3 || Pdados[playerid][OrgID] == 4 || Pdados[playerid][OrgID] == 5 || Pdados[playerid][OrgID] == 6 || Pdados[playerid][OrgID] == 7 || Pdados[playerid][OrgID] == 8 || Pdados[playerid][OrgID] == 9 || Pdados[playerid][OrgID] == 10 || Pdados[playerid][OrgID] == 11 || Pdados[playerid][OrgID] == 12){
	format(String,sizeof(String),"~y~%s~w~ em patrulhamento.", NomeOrg(playerid), Nome(playerid));
	GameTextForAll(String, 10000, 4);
	}else{
	}
	return 1;
}
public tang(){
	if(t != 0){
		t--;
		SetTimer("tang",1000,false);
	}
	return 1;
}
// --- [ COMANDOS ] ---

CMD:dw(playerid, params[])
{
    if(!Pdados[playerid][Logado]) return SendClientMessage(playerid, CINZA, "Voce precisa estar logado.");
    
    new msg[128], f_str[144]; // 'f_str' para formatar
    if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Uso correto: /dw [mensagem]");

    if(VerificarFlood(playerid)) return 1;

    format(f_str, sizeof(f_str), "[DeepWeb] Anonimo: %s", msg);
    SendClientMessageToAll(CINZA, f_str);
    return 1;
}

CMD:occ(playerid, params[])
{
    if(!Pdados[playerid][Logado]) return SendClientMessage(playerid, CINZA, "Voce precisa estar logado.");
    
    new msg[128], f_str[144];
    if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Uso correto: /occ [texto OOC]");

    if(VerificarFlood(playerid)) return 1;

    format(f_str, sizeof(f_str), "(( [OOC] %s(%i): %s ))", Nome(playerid), playerid, msg);
    SendClientMessageToAll(LARANJA, f_str);
    return 1;
}

CMD:ds(playerid, params[])
{
    if(!Pdados[playerid][Logado]) return SendClientMessage(playerid, CINZA, "Voce precisa estar logado.");

    new msg[128], f_str[256];
    if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, AZUL_CLARO, "Uso correto: /ds [mensagem]");

    if(VerificarFlood(playerid)) return 1;

    if(Pdados[playerid][Admin] > 0 && Pdados[playerid][Trabalhando]) 
    {
        format(f_str, sizeof(f_str), "{1DACD6}[Discord] {FBA0E3}%s %s{FFFFFF}(%i): %s", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), playerid, msg);
    }
    else if(Pdados[playerid][YouTuber]) 
    {
        format(f_str, sizeof(f_str), "{1DACD6}[Discord] {FF0000}YT %s{FFFFFF}(%i): %s", Nome(playerid), playerid, msg);
    }
    else if(Pdados[playerid][Vip] == 1) 
    {
        format(f_str, sizeof(f_str), "{1DACD6}[Discord] {FFFF00}VIP %s{FFFFFF}(%i): %s", Nome(playerid), playerid, msg);
    }
    else 
    {
        format(f_str, sizeof(f_str), "{1DACD6}[Discord] {FFFFFF}%s(%i): %s", Nome(playerid), playerid, msg);
    }

    SendClientMessageToAll(AZUL_CLARO, f_str);
    return 1;
}


CMD:online(playerid){
		new corp,org;
		for(new i=0;i<MAX_PLAYERS;i++){
		if((Pdados[i][OrgID]>=1)&&(Pdados[i][OrgID]<=12)){
			corp++;
		}
		else if(Pdados[i][OrgID]>=13){
		    org++;
		}
		}
        format(String,sizeof(String),"{00BFFF}BCG: %i Jogadores online, %i Policiais e %i Criminosos", pOnline, corp, org);
        SendClientMessage(playerid,VERMELHO,String);
   	    return 1;
}
CMD:gps(playerid) {
    // Mudamos para DIALOG_STYLE_LIST para ficar clicavel e limpo
    ShowPlayerDialog(playerid, DIALOG_GPS, DIALOG_STYLE_LIST, "GPS BCG - Menu Principal", 
        "1. Locais Importantes\n2. Caixas Eletronicos Mais Proximos\n3. HQs de Organizacoes\n4. Agencias de Empregos", 
        "Selecionar", "Fechar"
    );

    // Mantendo suas variaveis de reset nativas da GM
    Pdados[playerid][Pizza] = 0;
    Pdados[playerid][Corrida] = 0;
    revista[playerid] = 0;
    ccimento[playerid] = 0;
    return 1;
}
CMD:relatorio(playerid,params[]){
	new msg[128];
	if(sscanf(params,"s",msg))return SendClientMessage(playerid,AZUL_CLARO,"Use /relatorio para falar com um adm");
	format(String,sizeof(String),"[Relatorio] %s(%i): %s",Nome(playerid),playerid,msg);
	SendClientMessage(playerid,AZUL_CLARO,"{00BFFF}BCG: Relatorio enviado com sucesso aguarde a resposta de um adm");
	for(new i = 0;i < MAX_PLAYERS; i++){
	    if(Pdados[i][Admin] > 0){
			SendClientMessage(i,AMARELO,String);
		}
	}
	return 1;
}
CMD:localizarv(playerid){
	String = "";
	switch(Dados[playerid][modelo1]){
	    //BMX
		case 510:{
			strcat(String,"{00FF00}BMX\n");
		}
	    //lambreta
		case 462:{
			strcat(String,"{00FF00}Biz\n");
		}
		//fcr900
		case 521:{
			strcat(String,"{00FF00}fcr-900\n");
		}
		//sanchez
		case 468:{
			strcat(String,"{00FF00}Sanchez\n");
		}
		//sultan
		case 560:{
			strcat(String,"{00FF00}Sultan\n");
		}
		//rancher
        case 400:{
            strcat(String,"{00FF00}BMW X7 2023\n");
        }
		case 489:{
			strcat(String,"{00FF00}BMW X6 Competition\n");
		}
		//blista
		case 496:{
			strcat(String,"{00FF00}Blista Compact\n");
		}
		//supergt
		case 506:{
			strcat(String,"{00FF00}Super GT\n");
		}
		//CLOVEr
		case 542:{
			strcat(String,"{00FF00}Clover\n");
		}
		//Sadler
		case 543:{
			strcat(String,"{00FF00}Hilux SRX 2017\n");
		}
		//Camper
		case 583:{
			strcat(String,"{00FF00}Kombi\n");
		}
		//Banshee
		case 429:{
			strcat(String,"{00FF00}Banshee\n");
		}
		//Bullet
		case 541:{
			strcat(String,"{00FF00}Bullet\n");
		}
		//Buffalo
		case 402:{
			strcat(String,"{00FF00}Buffalo\n");
		}
		//PCJ
		case 461:{
			strcat(String,"{00FF00}PCJ\n");
		}
		//Freeway
		case 463:{
			strcat(String,"{00FF00}Freeway\n");
		}
		//COMET
		case 480:{
			strcat(String,"{00FF00}comet\n");
		}
		//infernus
		case 411:{
			strcat(String,"{00FF00}infernus\n");
		}
		//Turismo
		case 451:{
			strcat(String,"{00FF00}Turismo\n");
		}
		//NRG
		case 522:{
			strcat(String,"{00FF00}NRG-500\n");
		}
		default:strcat(String,"{00FF00}Stot vazio\n");
	}
	switch(Dados[playerid][modelo2]){
	    //BMX
		case 510:{
			strcat(String,"{00FF00}BMX\n");
		}
	    //lambreta
		case 462:{
			strcat(String,"{00FF00}Biz\n");
		}
		//fcr900
		case 521:{
			strcat(String,"{00FF00}fcr-900\n");
		}
		//sanchez
		case 468:{
			strcat(String,"{00FF00}Sanchez\n");
		}
		//sultan
		case 560:{
			strcat(String,"{00FF00}Sultan\n");
		}
		//rancher
        case 400:{
            strcat(String,"{00FF00}BMW X7 2023\n");
        }
		case 489:{
			strcat(String,"{00FF00}BMW X6 Competition\n");
		}
		//blista
		case 496:{
			strcat(String,"{00FF00}Blista Compact\n");
		}
		//supergt
		case 506:{
			strcat(String,"{00FF00}Super GT\n");
		}
		//CLOVEr
		case 542:{
			strcat(String,"{00FF00}Clover\n");
		}
		//Sadler
		case 543:{
			strcat(String,"{00FF00}Hilux SRX 2017\n");
		}
		//Camper
		case 583:{
			strcat(String,"{00FF00}Kombi\n");
		}
		//Banshee
		case 429:{
			strcat(String,"{00FF00}Banshee\n");
		}
		//Bullet
		case 541:{
			strcat(String,"{00FF00}Bullet\n");
		}
		//Buffalo
		case 402:{
			strcat(String,"{00FF00}Buffalo\n");
		}
		//PCJ
		case 461:{
			strcat(String,"{00FF00}PCJ\n");
		}
		//Freeway
		case 463:{
			strcat(String,"{00FF00}Freeway\n");
		}
		//COMET
		case 480:{
			strcat(String,"{00FF00}comet\n");
		}
		//infernus
		case 411:{
			strcat(String,"{00FF00}infernus\n");
		}
		//Turismo
		case 451:{
			strcat(String,"{00FF00}Turismo\n");
		}
		//NRG
		case 522:{
			strcat(String,"{00FF00}NRG-500\n");
		}
		default:strcat(String,"\n{00FF00}Stot vazio");
	}
	ShowPlayerDialog(playerid,DIALOG_LOCALIZAR,DIALOG_STYLE_LIST,"{FFFF00}Localizar veiculos",String,"Aceitar","Recusar");
	return 1;
}

CMD:conce(playerid, params[])
{
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, CONCE_LOCAL_X, CONCE_LOCAL_Y, CONCE_LOCAL_Z))
        return SendClientMessage(playerid, -1, "{FF0000}[ERRO]:{FFFFFF} Voce nao esta no local da concessionaria.");

    AbrirMenuConcessionaria(playerid);
    return 1;
}

CMD:criargaragem(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;

    for(new i = 0; i < MAX_GARAGENS; i++)
    {
        if(!GaragemInfo[i][gCriada])
        {
            GetPlayerPos(playerid, GaragemInfo[i][gPosX], GaragemInfo[i][gPosY], GaragemInfo[i][gPosZ]);
            GaragemInfo[i][gCriada] = true;
            
            GaragemInfo[i][gPickup] = CreatePickup(1239, 1, GaragemInfo[i][gPosX], GaragemInfo[i][gPosY], GaragemInfo[i][gPosZ], -1);
            
            new str[128];
            format(str, sizeof(str), "{FFFF00}Garagem BCG #%d\n{FFFFFF}Use: /garagem", i);
            GaragemInfo[i][gLabel] = CreateDynamic3DTextLabel(str, -1, GaragemInfo[i][gPosX], GaragemInfo[i][gPosY], GaragemInfo[i][gPosZ]+0.5, 20.0);

            SalvarGaragem(i);
            return SendClientMessage(playerid, -1, "Garagem criada e salva com sucesso!");
        }
    }
    return 1;
}

CMD:guardarveiculo(playerid, params[])
{
    if(VeiculoGaragem[playerid] == 0) 
        return SendClientMessage(playerid, -1, "Voce nao tem um veiculo fora da garagem!");

    new vid = VeiculoGaragem[playerid];
    
    // Salva a gasolina atual na conta do player antes de destruir o veiculo
    if(SlotAtual[playerid] == 1) Dados[playerid][gasosa1] = GasolinaVeiculo[vid];
    else if(SlotAtual[playerid] == 2) Dados[playerid][gasosa2] = GasolinaVeiculo[vid];

    // Limpa o estado do motor na nossa variavel de controle global
    MotorLigado[vid] = false;
    GasolinaVeiculo[vid] = 0;

    // Deleta o Label do veiculo para nao clonar texto no mapa
    if(TextoDonoVeiculo[vid] != Text3D:INVALID_3DTEXT_ID) 
    {
        Delete3DTextLabel(TextoDonoVeiculo[vid]);
        TextoDonoVeiculo[vid] = Text3D:INVALID_3DTEXT_ID;
    }

    DestroyVehicle(vid);
    VeiculoGaragem[playerid] = 0;
    SlotAtual[playerid] = 0;
    
    SalvarDados(playerid);
    SendClientMessage(playerid, -1, "Veiculo guardado com sucesso!");
    return 1;
}

CMD:garagem(playerid, params[])
{
    new idg = -1;
    for(new i = 0; i < MAX_GARAGENS; i++)
    {
        if(GaragemInfo[i][gCriada] && IsPlayerInRangeOfPoint(playerid, 3.0, GaragemInfo[i][gPosX], GaragemInfo[i][gPosY], GaragemInfo[i][gPosZ]))
        {
            idg = i;
            break;
        }
    }

    if(idg == -1) return SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce nao esta proximo a nenhuma garagem.");

    new str_garagem[256], n1[100], n2[100];

    // Slot 1
    if(Dados[playerid][modelo1] >= 400 && Dados[playerid][modelo1] <= 611)
        format(n1, sizeof(n1), "{00FF00}%s {FFFFFF}(Combustivel: %d%%)", modelNames[Dados[playerid][modelo1]-400], Dados[playerid][gasosa1]);
    else 
        format(n1, sizeof(n1), "{FF0000}Slot 1 Vazio");

    // Slot 2
    if(Dados[playerid][modelo2] >= 400 && Dados[playerid][modelo2] <= 611)
        format(n2, sizeof(n2), "{00FF00}%s {FFFFFF}(Combustivel: %d%%)", modelNames[Dados[playerid][modelo2]-400], Dados[playerid][gasosa2]);
    else 
        format(n2, sizeof(n2), "{FF0000}Slot 2 Vazio");

    format(str_garagem, sizeof(str_garagem), "Slot 1: %s\nSlot 2: %s", n1, n2);
    ShowPlayerDialog(playerid, DIALOG_GARAGEM, DIALOG_STYLE_LIST, "{FFFF00}Garagem BCG - Seus Veiculos", str_garagem, "Puxar", "Fechar");
    return 1;
}

CMD:rg(playerid)
{
    new string[2600], path[64], sOrigem[32];
    new casaRG = -1;
    new totalSegundos = Pdados[playerid][SegundosJogados];
    new diasJ = totalSegundos / 86400;
    new horasJ = (totalSegundos % 86400) / 3600;
    new minutosJ = (totalSegundos % 3600) / 60;
    new segundosJ = totalSegundos % 60;
    new statusVip[32], statusSocio[32], statusYT[16], statusAdmin[16], statusDiscord[16];
    format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
    sOrigem[0] = EOS;
    if(DOF2_FileExists(path)) format(sOrigem, sizeof(sOrigem), "%s", DOF2_GetString(path, "Origem"));
    if(strlen(sOrigem) < 2) format(sOrigem, sizeof(sOrigem), "Nao informada");

    for(new i = 0; i < MAX_CASAS_BCG; i++)
    {
        if(CasaExisteBCG[i] && !strcmp(CasaDonoBCG[i], Nome(playerid), true))
        {
            casaRG = i;
            break;
        }
    }

    if(Pdados[playerid][Vip] > 0) format(statusVip, sizeof(statusVip), "{00FF00}SIM");
    else format(statusVip, sizeof(statusVip), "{FF3030}NAO");
    if(Pdados[playerid][Socio] > 0) format(statusSocio, sizeof(statusSocio), "{00FF00}SIM");
    else format(statusSocio, sizeof(statusSocio), "{FF3030}NAO");
    if(Pdados[playerid][YouTuber]) format(statusYT, sizeof(statusYT), "{00FF00}SIM");
    else format(statusYT, sizeof(statusYT), "{FF3030}NAO");
    if(Pdados[playerid][Admin] > 0) format(statusAdmin, sizeof(statusAdmin), "{00FF00}SIM");
    else format(statusAdmin, sizeof(statusAdmin), "{FF3030}NAO");
    if(Pdados[playerid][Discord] > 0) format(statusDiscord, sizeof(statusDiscord), "{00FF00}SIM");
    else format(statusDiscord, sizeof(statusDiscord), "{FF3030}NAO");

    format(string, sizeof(string), "{00BFFF}BrasilRP: {FFFFFF}Informacoes da Conta\n\n{FF3333}DADOS DA CONTA\n{FFFFFF}Nome: {BDBDBD}%s\n{FFFFFF}ID de Conta: {00BFFF}%05d\n{FFFFFF}Nivel: {BDBDBD}%d\n{FFFFFF}Sexo: {BDBDBD}%s\n{FFFFFF}Origem: {BDBDBD}%s\n{FFFFFF}Organizacao: {BDBDBD}%s {FFFFFF}({BDBDBD}%s{FFFFFF})\n{FFFFFF}Cargo: {BDBDBD}%s\n{FFFFFF}Discord: %s\n{FFFFFF}Tempo de Jogo: {BDBDBD}%dd %dh %dm e %ds\n\n",
        Nome(playerid), BCG_IDFixo[playerid], Pdados[playerid][Level],
        (Pdados[playerid][Genero] == 1) ? ("Masculino") : ("Feminino"), sOrigem,
        NomeOrg(playerid), NomeCargo(playerid), statusDiscord,
        diasJ, horasJ, minutosJ, segundosJ);

    if(casaRG != -1)
    {
        format(string, sizeof(string), "%s{FF3333}CASA\n{FFFFFF}Casas: {00FF00}Possui\n{FFFFFF}Dono: {00FF00}%s\n{FFFFFF}A venda: {FF3030}Nao\n{FFFFFF}Aluguel: {00BFFF}R$%d\n{FFFFFF}/CASA: {00BFFF}H\n\n",
            string, CasaDonoBCG[casaRG], CasaAluguelBCG[casaRG]);
    }
    else
    {
        strcat(string, "{FF3333}CASA\n{FFFFFF}Casas: {FF3030}Nao possui\n{FFFFFF}Dono: {FF3030}Nao possui\n{FFFFFF}A venda: {FF3030}Nao possui\n{FFFFFF}Aluguel: {FF3030}Nao possui\n{FFFFFF}/CASA: {00BFFF}H\n\n");
    }

    format(string, sizeof(string), "%s{FF3333}DADOS FINANCEIROS\n{FFFFFF}Dinheiro Limpo: {00FF00}R$%d\n{FFFFFF}Dinheiro Sujo: {00FF00}R$%d\n{FFFFFF}Banco: {00FF00}R$%d\n{FFFFFF}Coins: {00FF00}%d\n{FFFFFF}Bitcoin: {00FF00}0.00000000 (R$0)\n{FFFFFF}Multas: {00FF00}R$0\n\n",
        string, GetPlayerMoney(playerid), Pdados[playerid][DinheiroSujo], Pdados[playerid][Banco], Pdados[playerid][Coins]);

    format(string, sizeof(string), "%s{FF3333}STATUS\n{FFFFFF}Nivel Procurado: {BDBDBD}%d\n{FFFFFF}Estrelas: {BDBDBD}%d\n{FFFFFF}Mochila: {00FF00}%s\n{FFFFFF}PayDay: {00FF00}Disponivel\n{FFFFFF}Tempo Online: {BDBDBD}%dd %dh %dm e %ds\n{FFFFFF}Dispositivo: {BDBDBD}PC\n\n",
        string, Pdados[playerid][Estrelas], Pdados[playerid][Estrelas],
        Pdados[playerid][Mochila] ? ("SIM") : ("NAO"), diasJ, horasJ, minutosJ, segundosJ);

    format(string, sizeof(string), "%s{FF3333}TAGS IN-GAME\n{FFFFFF}Influencer: %s\n{FFFFFF}VIP: %s\n{FFFFFF}Socio: %s\n{FFFFFF}YouTuber: %s\n{FFFFFF}Admin: %s\n{FFFFFF}VPN: {FF3030}NAO\n{FFFFFF}Blacklist: {00FF00}NAO",
        string, statusYT, statusVip, statusSocio, statusYT, statusAdmin);

    TogglePlayerControllable(playerid, false);
    ShowPlayerDialog(playerid, 502, DIALOG_STYLE_MSGBOX, "{00BFFF}BrasilRP: {FFFFFF}Informacoes da Conta", string, "Fechar", "");
    return 1;
}
CMD:mostrarrg(playerid, params[])
{
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AZUL_CLARO, "Use /mostrarrg [IDF]");
    new id = BCG_PlayerPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "Jogador nao encontrado ou offline.");
    if(!IsPerto(playerid, id)) return SendClientMessage(playerid, -1, "Voce esta muito longe!");

    new string[2600], path[64], sOrigem[32];
    new totalSegundos = Pdados[id][SegundosJogados];
    new diasJ = totalSegundos / 86400;
    new horasJ = (totalSegundos % 86400) / 3600;
    new minutosJ = (totalSegundos % 3600) / 60;
    new segundosJ = totalSegundos % 60;
    new statusVip[32], statusSocio[32], statusYT[16], statusAdmin[16], statusDiscord[16];
    format(path, sizeof(path), "Contas/%s.txt", Nome(id));
    sOrigem[0] = EOS;
    if(DOF2_FileExists(path)) format(sOrigem, sizeof(sOrigem), "%s", DOF2_GetString(path, "Origem"));
    if(strlen(sOrigem) < 2) format(sOrigem, sizeof(sOrigem), "Nao informada");

    if(Pdados[id][Vip] > 0) format(statusVip, sizeof(statusVip), "{00FF00}SIM");
    else format(statusVip, sizeof(statusVip), "{FF3030}NAO");
    if(Pdados[id][Socio] > 0) format(statusSocio, sizeof(statusSocio), "{00FF00}SIM");
    else format(statusSocio, sizeof(statusSocio), "{FF3030}NAO");
    if(Pdados[id][YouTuber]) format(statusYT, sizeof(statusYT), "{00FF00}SIM");
    else format(statusYT, sizeof(statusYT), "{FF3030}NAO");
    if(Pdados[id][Admin] > 0) format(statusAdmin, sizeof(statusAdmin), "{00FF00}SIM");
    else format(statusAdmin, sizeof(statusAdmin), "{FF3030}NAO");
    if(Pdados[id][Discord] > 0) format(statusDiscord, sizeof(statusDiscord), "{00FF00}SIM");
    else format(statusDiscord, sizeof(statusDiscord), "{FF3030}NAO");

    format(string, sizeof(string), "{00BFFF}BrasilRP: {FFFFFF}Informacoes da Conta\n\n{FF3333}DADOS DA CONTA\n{FFFFFF}Nome: {BDBDBD}%s\n{FFFFFF}ID de Conta: {00BFFF}%05d\n{FFFFFF}Nivel: {BDBDBD}%d\n{FFFFFF}Sexo: {BDBDBD}%s\n{FFFFFF}Origem: {BDBDBD}%s\n{FFFFFF}Organizacao: {BDBDBD}%s {FFFFFF}({BDBDBD}%s{FFFFFF})\n{FFFFFF}Cargo: {BDBDBD}%s\n{FFFFFF}Discord: %s\n{FFFFFF}Tempo de Jogo: {BDBDBD}%dd %dh %dm e %ds\n\n",
        Nome(id), BCG_IDFixo[id], Pdados[id][Level],
        (Pdados[id][Genero] == 1) ? ("Masculino") : ("Feminino"), sOrigem,
        NomeOrg(id), NomeCargo(id), statusDiscord,
        diasJ, horasJ, minutosJ, segundosJ);

    format(string, sizeof(string), "%s{FF3333}DADOS FINANCEIROS\n{FFFFFF}Dinheiro Limpo: {00FF00}R$%d\n{FFFFFF}Dinheiro Sujo: {00FF00}R$%d\n{FFFFFF}Banco: {00FF00}R$%d\n{FFFFFF}Coins: {00FF00}%d\n{FFFFFF}Bitcoin: {00FF00}0.00000000 (R$0)\n{FFFFFF}Multas: {00FF00}R$0\n\n",
        string, GetPlayerMoney(id), Pdados[id][DinheiroSujo], Pdados[id][Banco], Pdados[id][Coins]);
    format(string, sizeof(string), "%s{FF3333}STATUS\n{FFFFFF}Nivel Procurado: {BDBDBD}%d\n{FFFFFF}Estrelas: {BDBDBD}%d\n{FFFFFF}Mochila: {00FF00}%s\n{FFFFFF}PayDay: {00FF00}Disponivel\n{FFFFFF}Tempo Online: {BDBDBD}%dd %dh %dm e %ds\n{FFFFFF}Dispositivo: {BDBDBD}PC\n\n",
        string, Pdados[id][Estrelas], Pdados[id][Estrelas], Pdados[id][Mochila] ? ("SIM") : ("NAO"), diasJ, horasJ, minutosJ, segundosJ);
    format(string, sizeof(string), "%s{FF3333}TAGS IN-GAME\n{FFFFFF}Influencer: %s\n{FFFFFF}VIP: %s\n{FFFFFF}Socio: %s\n{FFFFFF}YouTuber: %s\n{FFFFFF}Admin: %s\n{FFFFFF}VPN: {FF3030}NAO\n{FFFFFF}Blacklist: {00FF00}NAO",
        string, statusYT, statusVip, statusSocio, statusYT, statusAdmin);

    ShowPlayerDialog(playerid, 502, DIALOG_STYLE_MSGBOX, "{00BFFF}BrasilRP: {FFFFFF}Informacoes da Conta", string, "Fechar", "");
    return 1;
}

CMD:aviso(playerid, params[])
{
	new msg[128];
	if(!(ADM(playerid,2)))return 1;
	if(sscanf(params,"s",msg))return SendClientMessage(playerid, vermelho,"Use /aviso [anuncio].");
	SendClientMessageToAll(0x0097FFFF, "=-=-=-=-=-=-=-=-=-=-=-=-=-= {FFFFFF}Administracao {0097FF}=-=-=-=-=-=-=-=-=-=-=-=-=-=");
	format(String,sizeof(String),"Aviso: {FFFFFF}%s ({0097FF}@%s{FFFFFF})", msg, Nome(playerid));
	SendClientMessageToAll(0x0097FFFF,String);
	return 1;
}
CMD:aviso1(playerid,params[]){
	new str[128];
	if(!(ADM(playerid,2)))return 1;
	if(sscanf(params,"s",str))return SendClientMessage(playerid,CINZA,"Use /aviso [AVISO]");
	format(String,sizeof(String),"%s(%i) avisou: %s",Nome(playerid),playerid,str);
	MsgAdm(String);
	format(String,sizeof(String),"Aviso da administracao: %s",str);
	SendClientMessageToAll(ROXO,String);
	return 1;
}
CMD:skin(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, idskin;
    if(sscanf(params, "ii", id_procurado, idskin)) return SendClientMessage(playerid, CINZA, "Use: /skin [IDF] [ID DA SKIN]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    // Aplica a skin no jogo
    SetPlayerSkin(id, idskin);

    // Envia a mensagem para quem recebeu a skin
    format(String, sizeof(String), "O %s %s mudou sua skin para %i", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), idskin);
    SendClientMessage(id, AMARELO, String);

    // Salva na variavel e no arquivo do jogador que RECEBEU a skin (usando 'id')
    Pdados[id][Skin] = idskin;
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(id));
    DOF2_SetInt(StringContas, "Skin", Pdados[id][Skin]);
    DOF2_SaveFile();
    return 1;
}



CMD:comer(playerid, params[])
{
    if(g_DadosMorte[playerid][pEmComa]) return SendClientMessage(playerid, CINZA, "Voce nao pode comer enquanto estiver ferido.");

    Status_Fome[playerid] += 25.0;
    if(Status_Fome[playerid] > 100.0) Status_Fome[playerid] = 100.0;

    ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 1, 1, 0, 0, 1);
    format(String, sizeof(String), "{FF0000}[NECESSIDADES] {FFFFFF}Voce comeu e recuperou 25%% de fome. Agora: %.0f%%.", Status_Fome[playerid]);
    SendClientMessage(playerid, -1, String);

    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    DOF2_SetFloat(StringContas, "Status_Fome", Status_Fome[playerid]);
    DOF2_SaveFile();
    return 1;
}

CMD:beber(playerid, params[])
{
    if(g_DadosMorte[playerid][pEmComa]) return SendClientMessage(playerid, CINZA, "Voce nao pode beber enquanto estiver ferido.");

    Status_Sede[playerid] += 25.0;
    if(Status_Sede[playerid] > 100.0) Status_Sede[playerid] = 100.0;

    ApplyAnimation(playerid, "VENDING", "VEND_Drink2", 4.1, 0, 1, 1, 0, 0, 1);
    format(String, sizeof(String), "{FF0000}[NECESSIDADES] {FFFFFF}Voce bebeu e recuperou 25%% de sede. Agora: %.0f%%.", Status_Sede[playerid]);
    SendClientMessage(playerid, -1, String);

    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    DOF2_SetFloat(StringContas, "Status_Sede", Status_Sede[playerid]);
    DOF2_SaveFile();
    return 1;
}

CMD:dormir(playerid, params[])
{
    if(g_DadosMorte[playerid][pEmComa]) return SendClientMessage(playerid, CINZA, "Voce nao pode dormir enquanto estiver ferido.");

    Status_Sono[playerid] += 25.0;
    if(Status_Sono[playerid] > 100.0) Status_Sono[playerid] = 100.0;

    ApplyAnimation(playerid, "CRACK", "crckidle1", 4.1, 1, 0, 0, 1, 0, 0);
    format(String, sizeof(String), "{FF0000}[NECESSIDADES] {FFFFFF}Voce dormiu e recuperou 25%% de sono. Agora: %.0f%%.", Status_Sono[playerid]);
    SendClientMessage(playerid, -1, String);

    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    DOF2_SetFloat(StringContas, "Status_Sono", Status_Sono[playerid]);
    DOF2_SaveFile();
    return 1;
}

CMD:restaurarfome(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, CINZA, "Use: /restaurarfome [ID]");
    if(id < 0 || id >= MAX_PLAYERS || !IsPlayerConnected(id)) return SendClientMessage(playerid, CINZA, "ERRO: Esse jogador nao esta online.");

    Status_Fome[id] = 100.0;
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(id));
    DOF2_SetFloat(StringContas, "Status_Fome", 100.0);
    DOF2_SaveFile();

    SendClientMessage(id, -1, "{00FF00}[ADMIN] {FFFFFF}Sua fome foi restaurada para 100%.");
    format(String, sizeof(String), "{00FF00}[ADMIN] {FFFFFF}Voce restaurou a fome de %s [ID:%d].", Nome(id), id);
    SendClientMessage(playerid, -1, String);
    return 1;
}

CMD:restaurarsede(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id;
    if(sscanf(params, "i", id)) return SendClientMessage(playerid, CINZA, "Use: /restaurarsede [ID]");
    if(id < 0 || id >= MAX_PLAYERS || !IsPlayerConnected(id)) return SendClientMessage(playerid, CINZA, "ERRO: Esse jogador nao esta online.");

    Status_Sede[id] = 100.0;
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(id));
    DOF2_SetFloat(StringContas, "Status_Sede", 100.0);
    DOF2_SaveFile();

    SendClientMessage(id, -1, "{00FF00}[ADMIN] {FFFFFF}Sua sede foi restaurada para 100%.");
    format(String, sizeof(String), "{00FF00}[ADMIN] {FFFFFF}Voce restaurou a sede de %s [ID:%d].", Nome(id), id);
    SendClientMessage(playerid, -1, String);
    return 1;
}

CMD:resuadm(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id;
    if(sscanf(params, "i", id))
        return SendClientMessage(playerid, CINZA, "Use: /resuadm [ID]");

    if(id < 0 || id >= MAX_PLAYERS || !IsPlayerConnected(id))
        return SendClientMessage(playerid, CINZA, "ERRO: Esse jogador nao esta online.");

    if(!g_DadosMorte[id][pEmComa])
        return SendClientMessage(playerid, CINZA, "Esse jogador nao esta morto/em coma.");

    // Retira o jogador do estado de coma e devolve o controle.
    FinalizarComaGeral(id, false);
    SetPlayerHealth(id, 100.0);
    SetPlayerArmour(id, 0.0);
    TogglePlayerControllable(id, true);
    ClearAnimations(id);
    SetCameraBehindPlayer(id);

    format(String, sizeof(String), "{00FF00}[ADMIN] {FFFFFF}Voce foi revivido pelo administrador %s.", Nome(playerid));
    SendClientMessage(id, -1, String);

    format(String, sizeof(String), "{00FF00}[ADMIN] {FFFFFF}Voce reviveu %s [ID:%d].", Nome(id), id);
    SendClientMessage(playerid, -1, String);
    return 1;
}

CMD:reviver(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;
    new idfixo, id;
    if(sscanf(params, "i", idfixo)) return SendClientMessage(playerid, CINZA, "Use /reviver [IDF]");
    id = BCG_BuscarPorIDFixo(idfixo);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse ID fixo nao esta online.");
    if(!g_DadosMorte[id][pEmComa]) return SendClientMessage(playerid, CINZA, "Esse jogador nao esta morto/em coma.");
    FinalizarComaGeral(id, false);
    SetPlayerHealth(id, 100.0);
    TogglePlayerControllable(id, true);
    SetCameraBehindPlayer(id);
    format(String, sizeof String, "[ADMIN] Voce foi revivido por %s.", Nome(playerid));
    SendClientMessage(id, 0x00FF00FF, String);
    format(String, sizeof String, "[ADMIN] Voce reviveu %s [IDF:%d].", Nome(id), BCG_IDFixo[id]);
    SendClientMessage(playerid, 0x00BFFFFF, String);
    return 1;
}

CMD:deus(playerid, params[])
{
    // /deus e o comando que entra/sai do modo trabalho, por isso pode ser usado fora dele.
    if(Pdados[playerid][Admin] < 1)
        return SendClientMessage(playerid, -1, "{FF0000}[ERRO]{FFFFFF} Voce precisa ser admin para usar este comando!");
    if(!Pdados[playerid][Imortal])
    {
        Pdados[playerid][Imortal] = true;
        Pdados[playerid][Trabalhando] = true;
        BCG_SkinAntesDeus[playerid] = GetPlayerSkin(playerid);
        SetPlayerSkin(playerid, 217);
        SetPlayerHealth(playerid, 99999.0);
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, 0x00FF00FF, "[ADMIN] Voce esta em modo trabalho.");
    }
    else
    {
        Pdados[playerid][Imortal] = false;
        Pdados[playerid][Trabalhando] = false;
        SetPlayerHealth(playerid, 100.0);
        SetPlayerArmour(playerid, 0.0);
        if(BCG_SkinAntesDeus[playerid] > 0) SetPlayerSkin(playerid, BCG_SkinAntesDeus[playerid]);
        SendClientMessage(playerid, 0xFFCC00FF, "[ADMIN] Voce saiu do modo trabalho.");
    }
    return 1;
}

CMD:ir(playerid, params[])
{
    if(!(ADM(playerid, 1))) return 1;
    new idfixo, id, Float:x, Float:y, Float:z;
    if(sscanf(params, "i", idfixo)) return SendClientMessage(playerid, CINZA, "Use /ir [IDF]");
    id = BCG_BuscarPorIDFixo(idfixo);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse ID fixo nao esta online.");
    GetPlayerPos(id,x,y,z); SetPlayerInterior(playerid,GetPlayerInterior(id)); SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id)); SetPlayerPos(playerid,x+1.0,y,z);
    return 1;
}

CMD:trazer(playerid, params[])
{
    if(!(ADM(playerid, 1))) return 1;
    new idfixo, id, Float:x, Float:y, Float:z;
    if(sscanf(params, "i", idfixo)) return SendClientMessage(playerid, CINZA, "Use /trazer [IDF]");
    id = BCG_BuscarPorIDFixo(idfixo);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse ID fixo nao esta online.");
    GetPlayerPos(playerid,x,y,z); SetPlayerInterior(id,GetPlayerInterior(playerid)); SetPlayerVirtualWorld(id,GetPlayerVirtualWorld(playerid)); SetPlayerPos(id,x+1.0,y,z);
    return 1;
}

CMD:respawn(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    // 2. Formatacao da mensagem global
    new string[144]; // Tamanho ideal para mensagens do chat do SA-MP
    format(string, sizeof(string), "{00BFFF}BCG: O Admin {1BA5E0}%s{00C2EC} deu Respawn nos veiculos! Em 30 segundos irao para seus locais.", Nome(playerid));
    SendClientMessageToAll(AZUL_CLARO, string);

    // 3. Seguranca do Timer: Se ja houver um respawn correndo, mata o antigo e inicia este
    KillTimer(TimerRespawn);
    TimerRespawn = SetTimer("ttrespawn", 30000, false);
    
    return 1;
}

CMD:tv(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, AMARELO, "Use /tv [IDF]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, AMARELO, "JOGADOR OFFLINE");

    if(id == playerid) return SendClientMessage(playerid, AMARELO, "Voce nao pode se assistir!");

    SendClientMessage(playerid, AMARELO, "Para parar de assistir use /tvoff");
    TogglePlayerSpectating(playerid, 1);
    PlayerSpectatePlayer(playerid, id);
    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(id));
    return 1;
}

CMD:tvoff(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;
    TogglePlayerSpectating(playerid, 0);
    PlayerSpectatePlayer(playerid, playerid);
    PlayerSpectateVehicle(playerid, GetPlayerVehicleID(playerid));
    return 1;
}

CMD:dararma(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, armaid, municao;
    if(sscanf(params, "iii", id_procurado, armaid, municao)) return SendClientMessage(playerid, CINZA, "Use /dararma [IDF] [ID DA ARMA] [MUNICAO]");
    
    // Cargo 8 pode dar qualquer arma. Para os demais ADMs, mantem a restricao antiga.
    if(armaid == 18 && Pdados[playerid][Admin] < 8) return SendClientMessage(playerid, CINZA, "Arma proibida");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    GivePlayerWeapon(id, armaid, municao);
    if(id == playerid) return 1;

    format(String, sizeof(String), "O %s %s te deu %i municoes", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), municao);
    SendClientMessage(id, AMARELO, String);
    format(String, sizeof(String), "Voce deu %i de municoes para %s", municao, Nome(id));
    SendClientMessage(playerid, AZUL_CLARO, String);
    return 1;
}

CMD:tirararma(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /tirararma [IDF]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    ResetPlayerWeapons(id);
    if(id == playerid) return 1;

    format(String, sizeof(String), "O %s %s retirou suas armas", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, AMARELO, String);
    format(String, sizeof(String), "Voce tirou as armas de %s", Nome(id));
    SendClientMessage(playerid, AZUL_CLARO, String);
    return 1;
}

CMD:ban(playerid, params[])
{
    if(!(ADM(playerid, 2))) return 1;

    new idfixo, id, minutos, motivo[256], msg[384];
    if(sscanf(params, "iis", idfixo, minutos, motivo))
        return SendClientMessage(playerid, CINZA, "Use /ban [IDF] [TEMPO EM MINUTOS, 0 = PERMANENTE] [MOTIVO]");

    id = BCG_BuscarPorIDFixo(idfixo);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse ID fixo nao esta online.");
    if(minutos < 0) return SendClientMessage(playerid, CINZA, "Tempo invalido. Use 0 para permanente.");

    SalvarBanBCG(id, playerid, motivo, minutos);

    if(minutos == 0)
        format(msg, sizeof(msg), "%s foi banido permanentemente por %s. Admin: %s", Nome(id), motivo, Nome(playerid));
    else
        format(msg, sizeof(msg), "%s foi banido por %d minuto(s). Motivo: %s. Admin: %s", Nome(id), minutos, motivo, Nome(playerid));

    SendClientMessageToAll(AMARELO, msg);
    format(StringContas, sizeof(StringContas), "Banidos/%s.txt", Nome(id));
    MostrarBanimentoBCG(id, StringContas);
    return 1;
}

CMD:banip(playerid, params[])
{
    return cmd_ban(playerid, params);
}

CMD:kick(playerid, params[])
{   
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, motivo[128];
    if(sscanf(params, "is", id_procurado, motivo)) return SendClientMessage(playerid, CINZA, "Use /kick [IDF] [MOTIVO]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    format(String, sizeof(String), "Voce foi kickado pelo adm %s pelo motivo de %s", Nome(playerid), motivo);
    SendClientMessage(id, CINZA, String);
    format(String, sizeof(String), "%s foi kickado por %s", Nome(id), motivo);
    SendClientMessageToAll(AMARELO, String);
    Kick(id);
    return 1;
}

CMD:clima(playerid,params[]){
	new id;
	if(!(ADM(playerid,2)))return 1;
    if(sscanf(params,"i",id))return SendClientMessage(playerid,CINZA,"Use /clima [ID]");
    format(String,sizeof(String),"%s %s mudou o clima",NomeAdm(Pdados[playerid][Admin]),Nome(playerid));
    SendClientMessageToAll(AMARELO,String);
	SetWeather(id);
	return 1;
}
CMD:limparchat(playerid){
	if(!(ADM(playerid,2)))return 1;
	for(new a = 0; a < 100; a++)
    {
      SendClientMessageToAll(0xFFFFFFFF, " ");
    }
    format(String,sizeof(String),"~r~%s ~w~limpou o chat",Nome(playerid));
	GameTextForAll(String,2000,1);
	return 1;
}
CMD:cone(playerid,params[]){
    if(Pdados[playerid][OrgID] == 1 || Pdados[playerid][OrgID] == 2 || Pdados[playerid][OrgID] == 3 || Pdados[playerid][OrgID] == 4 || Pdados[playerid][OrgID] == 5 || Pdados[playerid][OrgID] == 6 || Pdados[playerid][OrgID] == 7 || Pdados[playerid][OrgID] == 8 || Pdados[playerid][OrgID] == 9 || Pdados[playerid][OrgID] == 10 || Pdados[playerid][OrgID] == 11 || Pdados[playerid][OrgID] == 12){
    new Float:xxX,Float:yyY,Float:zzZ,Float:aaA;
	GetPlayerPos(playerid, xxX, yyY, zzZ);
	GetPlayerFacingAngle(playerid, aaA);
	AddTrafficCone(playerid, Float:xxX,Float:yyY,Float:zzZ,Float:aaA);
 	Koniler[playerid] += 1;
 	}else{
 	}
	return 1;
}
stock AddTrafficCone(playerid, Float:x,Float:y,Float:z,Float:aa)
{
	new id = Koniler[playerid]+1;
	TrafikKoni[playerid][id] = CreateObject(1237, x, y, z-1.0, 0, 0, aa-90);
	return 1;
}
stock HataMesaji(playerid,icerik[])
{
	new yazi[256];
	format(yazi,sizeof(yazi),"{ff0000}>> [ERROR] {DCDCDC}%s {ff0000}<<",icerik);
	SendClientMessage(playerid,0xF6F6F6AA,yazi);
	return 1;
}
CMD:rcone(playerid,params[])
{
    if(Pdados[playerid][OrgID] == 1 || Pdados[playerid][OrgID] == 2 || Pdados[playerid][OrgID] == 3 || Pdados[playerid][OrgID] == 4 || Pdados[playerid][OrgID] == 5 || Pdados[playerid][OrgID] == 6 || Pdados[playerid][OrgID] == 7 || Pdados[playerid][OrgID] == 8 || Pdados[playerid][OrgID] == 9 || Pdados[playerid][OrgID] == 10 || Pdados[playerid][OrgID] == 11 || Pdados[playerid][OrgID] == 12){
    if(Koniler[playerid] == 0)
   	{
	HataMesaji(playerid,"Voce nao tem cones");
	return 1;
	}
	for(new i = 1; i < 11; i++)
	{
 	DestroyObject(TrafikKoni[playerid][i]);
	}
	Koniler[playerid] = 0;
	}
	return 1;
}
CMD:vida(playerid, params[])
{   
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, vida;
    if(sscanf(params, "ii", id_procurado, vida)) return SendClientMessage(playerid, CINZA, "Use /vida [IDF] [vida]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    SetPlayerHealth(id, vida);
    format(String, sizeof(String), "O %s %s te deu %i de vida.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), vida);
    SendClientMessage(id, AMARELO, String);
    SalvarDados(id); // Corrigido para salvar os dados do alvo
    return 1;
}

CMD:colete(playerid, params[])
{   
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, colete;
    if(sscanf(params, "ii", id_procurado, colete)) return SendClientMessage(playerid, CINZA, "Use /colete [IDF] [colete]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    SetPlayerArmour(id, colete);
    format(String, sizeof(String), "O %s %s te deu %i de colete.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), colete);
    SendClientMessage(id, AMARELO, String);
    SalvarDados(id); // Corrigido para salvar os dados do alvo
    return 1;
}

CMD:dargrana(playerid, params[])
{   
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, grana;
    if(sscanf(params, "ii", id_procurado, grana)) return SendClientMessage(playerid, CINZA, "Use /dargrana [IDF] [QUANTIA]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    GivePlayerMoney(id, grana);
    format(String, sizeof(String), "O %s %s te deu %i de dinheiro.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), grana);
    SendClientMessage(id, AMARELO, String);
    SalvarDados(id); // Corrigido para salvar os dados do alvo
    return 1;
}

CMD:removergrana(playerid, params[])
{   
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, grana;
    if(sscanf(params, "ii", id_procurado, grana)) return SendClientMessage(playerid, CINZA, "Use /removergrana [IDF] [QUANTIA]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    GivePlayerMoney(id, -grana);
    format(String, sizeof(String), "O %s %s removeu %i do seu dinheiro.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), grana);
    SendClientMessage(id, AMARELO, String);
    SalvarDados(id); // Corrigido para salvar os dados do alvo
    return 1;
}

CMD:removerbanco(playerid, params[])
{   
    if(!(ADM(playerid, 2))) return 1;

    new id_procurado, grana;
    if(sscanf(params, "ii", id_procurado, grana)) return SendClientMessage(playerid, CINZA, "Use /removerbanco [IDF] [QUANTIA]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    Pdados[id][Banco] -= grana;
    format(String, sizeof(String), "O %s %s removeu %i do seu dinheiro.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), grana);
    SendClientMessage(id, AMARELO, String);
    SalvarDados(id); // Corrigido para salvar os dados do alvo
    return 1;
}

CMD:trazertodos(playerid)
{
    if(!(ADM(playerid, 3))) return 1;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            SetPlayerPos(i, x + 1.0, y, z);
        }
    }
    return 1;
}

CMD:daryt(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /daryt [IDF]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");

    if(Pdados[id][YouTuber] == true) return SendClientMessage(playerid, AMARELO, "Esse player ja e um youtuber.");
    Pdados[id][YouTuber] = true;
    format(String, sizeof(String), "O %s %s lhe deu tag de YouTuber", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, AMARELO, String);
    format(String, sizeof(String), "O %s(%i) tag de YouTuber com sucesso", Nome(id), id);
    SendClientMessage(playerid, AZUL_CLARO, String);
    SalvarDados(id);
    return 1;
}

CMD:tiraryt(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /tiraryt [IDF]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");

    if(Pdados[id][YouTuber] == false) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao e youtuber");
    Pdados[id][YouTuber] = false;
    format(String, sizeof(String), "O %s %s removeu sua tag de YouTuber.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, AMARELO, String);
    format(String, sizeof(String), "O %s(%i) teve a tag de YouTuber removida.", Nome(id), id);
    SendClientMessage(playerid, AZUL_CLARO, String);
    SalvarDados(id);
    return 1;
}

CMD:darvip(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_procurado, vip;
    if(sscanf(params, "ii", id_procurado, vip)) return SendClientMessage(playerid, CINZA, "Use /darvip [IDF] [1-3]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");

    if(Pdados[id][Vip] == vip) return SendClientMessage(playerid, AZUL_CLARO, "Esse player ja tem esse nivel de vip");
    Pdados[id][Vip] = vip;
    
    if(Pdados[id][Vip] == 1){
        format(String, sizeof(String), "O %s %s lhe deu VIP Bronze, use /ajuda para saber os comandos.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
        SendClientMessage(id, AMARELO, String);
        format(String, sizeof(String), "O %s(%i) recebeu vip com sucesso", Nome(id), id);
        SendClientMessage(playerid, AZUL_CLARO, String);
    }
    if(Pdados[id][Vip] == 2){
        format(String, sizeof(String), "O %s %s lhe deu VIP Rubi, use /ajuda para saber os comandos.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
        SendClientMessage(id, AMARELO, String);
        format(String, sizeof(String), "O %s(%i) recebeu vip com sucesso", Nome(id), id);
        SendClientMessage(playerid, AZUL_CLARO, String);
    }
    if(Pdados[id][Vip] == 3){
        format(String, sizeof(String), "O %s %s lhe deu VIP BCG, use /ajuda para saber os comandos.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
        SendClientMessage(id, AMARELO, String);
        format(String, sizeof(String), "O %s(%i) recebeu vip com sucesso", Nome(id), id);
        SendClientMessage(playerid, AZUL_CLARO, String);
    }
    SalvarDados(id);
    return 1;
}

CMD:daradmin1(playerid, params[])
{
    if(!(ADM(playerid, 5))) return 1;
    new id_procurado, cargo;
    if(sscanf(params, "ii", id_procurado, cargo)) return SendClientMessage(playerid, CINZA, "Use /daradmin [IDF] [LEVEL]");
    if(cargo > 5) return SendClientMessage(playerid, CINZA, "Os cargos sao de 1~5");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");

    if(playerid == id) return 1;
    
    Pdados[id][Admin] = cargo;
    format(String, sizeof(String), "O player %s recebeu o cargo de %s", Nome(id), NomeAdm(cargo));
    SendClientMessage(playerid, AZUL_CLARO, String);
    format(String, sizeof(String), "Voce recebeu o cargo de %s do %s %s", NomeAdm(cargo), NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, AMARELO, String);
    SalvarDados(id); // Corrigido para salvar os dados do alvo correto
    return 1;
}

CMD:tirarvip(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /tirarvip [IDF]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");

    if(Pdados[id][Vip] == 0) return SendClientMessage(playerid, AZUL_CLARO, "Esse player nao e vip");
    Pdados[id][Vip] = 0;
    format(String, sizeof(String), "O %s %s removeu seu vip", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, AMARELO, String);
    format(String, sizeof(String), "O %s(%i) teve o vip removido com sucesso", Nome(id), id);
    SendClientMessage(playerid, AZUL_CLARO, String);
    SalvarDados(id);
    return 1;
}

CMD:irbase(playerid, params[])
{
    // Verifica se o jogador e administrador nivel 3 ou superior
    if(!(ADM(playerid, 3))) return 1;

    new string_dialog[1000]; // Tamanho suficiente para comportar os nomes das 33 orgs
    
    // Montando a lista de organizacoes para o Dialog
    format(string_dialog, sizeof(string_dialog), 
        "0 - Civil (Prefeitura)\n1 - Exercito Brasileiro\n2 - Bope\n3 - Tropa de Choque\n4 - Rota\n5 - PM\n6 - BAEP\n7 - Forca Tatica\n\
        8 - Policia Federal\n9 - Policia Civil\n10 - Policia Rodoviaria Federal\n11 - Rotam\n12 - Guarda Municipal\n13 - Governo\n\
        14 - Cidade Alerta\n15 - Medicos\n16 - Mafia Cosa Nostra\n17 - ALQAEDA\n18 - TALIBA\n19 - Mafia Yakusa\n20 - Cartel Medelin\n\
        21 - Triads\n22 - Faccao Mineira\n23 - Cartel de Cali\n24 - Comando Vermelho\n25 - Primeiro Comando da Capital\n\
        26 - Terceiro Comando Puro\n27 - Familia do Norte\n28 - Motoclube\n29 - B40\n30 - Milicia\n31 - ADA\n32 - Mayans\n33 Prefeitura"
    );

    // Mostra o dialogo em formato de lista para o administrador
    ShowPlayerDialog(playerid, DIALOG_IRBASE, DIALOG_STYLE_LIST, "Selecione a Base para Teleporte", string_dialog, "Teleportar", "Fechar");
    return 1;
}

CMD:darlider(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_procurado, org;
    if(sscanf(params, "ii", id_procurado, org)) return SendClientMessage(playerid, CINZA, "Use /darlider [IDF] [IDORG]");

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");
    
    if(Pdados[id][OrgID] != 0) return SendClientMessage(playerid, CINZA, "Esse player ja tem uma org. Use /rlider primeiro.");

    Pdados[id][OrgID] = org;
    Pdados[id][Cargo] = 5;
    SalvarDados(id);

    format(String, sizeof(String), "O %s %s lhe deu lider da %s", NomeAdm(Pdados[playerid][Admin]), Nome(playerid), GetNomeOrg(org));
    SendClientMessage(id, CINZA, String);

    format(String, sizeof(String), "O player %s recebeu lider da %s", Nome(id), GetNomeOrg(org));
    SendClientMessage(playerid, CINZA, String);

    SpawnPlayer(id);
    return 1;
}

CMD:rlider(playerid, params[]) 
{
    if(!(ADM(playerid, 3))) return 1;
    
    new id_procurado;
    if(sscanf(params, "i", id_procurado)) return SendClientMessage(playerid, CINZA, "Use /rlider [IDF]");
    
    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "Esse player esta offline");
    
    if(Pdados[id][OrgID] == 0) {
        return SendClientMessage(playerid, CINZA, "Este player nao pertence a nenhuma organizacao.");
    }

    Pdados[id][OrgID] = 0;
    Pdados[id][Cargo] = 0;
    
    format(String, sizeof(String), "O %s %s removeu voce da sua organizacao.", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(id, CINZA, String);
    
    format(String, sizeof(String), "Voce removeu o player %s da organizacao.", Nome(id));
    SendClientMessage(playerid, CINZA, String);
    
    SpawnPlayer(id);
    SalvarDados(id);
    return 1;
}


CMD:limparorg(playerid, params[]) {
    new org;
    if(!(ADM(playerid, 4))) return 1; 
    
    if(sscanf(params, "i", org)) return SendClientMessage(playerid, CINZA, "Use /limparorg [ID da Org]");
    if(org <= 0 || org > ORG_CUSTOM_FIM) return SendClientMessage(playerid, CINZA, "ID de organizacao invalido.");

    new count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            if(Pdados[i][OrgID] == org) {
                Pdados[i][OrgID] = 0;
                Pdados[i][Cargo] = 0;
                
                SendClientMessage(i, CINZA, "Sua organizacao foi resetada e voce foi removido.");
                SpawnPlayer(i);
                SalvarDados(i);
                count++;
            }
        }
    }

    if(org >= ORG_CUSTOM_INICIO && org <= ORG_CUSTOM_FIM && OrgCustomAtiva[org])
    {
        OrgCustomAtiva[org] = false;
        OrgCustomNome[org][0] = EOS;
        OrgCustomCor[org] = OrgCustomCores[org - ORG_CUSTOM_INICIO];
        BCG_SalvarOrgPersonalizada(org);
    }

    // AQUI: Usamos GetNomeOrg(org) para pegar o nome pelo numero que voce digitou
    format(String, sizeof(String), "[INFO] A organizacao %s foi resetada pelo Administrador %s.", GetNomeOrg(org), Nome(playerid));
    SendClientMessageToAll(0xFF6347AA, String);

    format(String, sizeof(String), "Voce limpou a %s. Membros online removidos: %d.", GetNomeOrg(org), count);
    SendClientMessage(playerid, CINZA, String);
    
    return 1;
}



CMD:trancarserver(playerid,params[]){
	new senha[128];
	if(!(ADM(playerid,4)))return 1;
	if(sscanf(params,"s",senha))return SendClientMessage(playerid,AZUL_CLARO,"Use /trancarserver [SENHA]");
	format(String, sizeof(String), "O %s %s trancou o servidor",NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
	SendClientMessageToAll(AZUL_CLARO,String);
	format(String,sizeof(String),"password %s",senha);
	SendRconCommand(String);
	return 1;
}
CMD:destrancarserver(playerid,params[]){
	if(!(ADM(playerid,4)))return 1;
	format(String, sizeof(String), "O %s %s destrancou o servidor",NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
	SendClientMessageToAll(AZUL_CLARO,String);
	format(String,sizeof(String),"password 0");
	SendRconCommand(String);
	return 1;
}
CMD:gmx(playerid)
{	if(!(ADM(playerid,4)))return 1;
	format(String, sizeof(String), "O %s %s Deu GMX no servidor, em 10 segundos ele sera reiniciado",NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
	SendClientMessageToAll(AZUL_CLARO,String);
   	
   	new i;
	while(i > MAX_PLAYERS){
   		SalvarDados(i);
   		i++;
   	}
   	SetTimerEx("tgmx",10000,false,"i",playerid);
	return 1;
}
public tgmx(playerid){
    format(String,sizeof(String),"O %s %s deu gmx no servidor",NomeAdm(Pdados[playerid][Admin]),Nome(playerid));
   	print(String);
	format(String,sizeof(String),"Servidor sendo reiniciado...");
	GameTextForAll(String, 5,1);
   	SendRconCommand("gmx");
	return 1;
}
CMD:creditos(playerid,params[])
{
    ShowPlayerDialog(playerid, DIALOG_NOVIDADES, DIALOG_STYLE_MSGBOX, "Creditos", "Creditos do Servidor:\n\n- Criador/Dono Lipe-fxp/Martins\nFundador Alemao/Daniel\nProgramador Lipee_fxp1/Martins", "OK", "");
    return 1;
}
CMD:daradmin(playerid, params[])
{   
    if(!(ADM(playerid, 5))) return 1;

    new id_procurado, cargo;
    if(sscanf(params, "ii", id_procurado, cargo)) return SendClientMessage(playerid, CINZA, "Use /daradmin [IDF] [LEVEL]");
    if(cargo > 5) return SendClientMessage(playerid, CINZA, "Os cargos sao de 1~5");

    // --- BUSCA PELO ID ---
    new Id = INVALID_PLAYER_ID;
    Id = BCG_BuscarPorIDFixo(id_procurado);
    if(Id == INVALID_PLAYER_ID) return SendClientMessage(playerid, CINZA, "ERRO: Esse player nao esta online.");

    if(playerid == Id) return 1;
    
    Pdados[Id][Admin] = cargo;
    format(String, sizeof(String), "O player %s recebeu o cargo de %s", Nome(Id), NomeAdm(cargo));
    SendClientMessage(playerid, AZUL_CLARO, String);
    format(String, sizeof(String), "Voce recebeu o cargo de %s do %s %s", NomeAdm(cargo), NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
    SendClientMessage(Id, AMARELO, String);
    SalvarDados(Id);
    return 1;
}

stock MsgPerto(playerid,cor,msg[]){
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	for(new i = 0;i<MAX_PLAYERS;i++){
		if(IsPlayerInRangeOfPoint(i,10,x,y,z)){
			SendClientMessage(i,cor,msg);
		}
	}
	return 1;
}
stock SkinORg(playerid){
	if(Pdados[playerid][OrgID] == 0)return Pdados[playerid][Skin];
	new skn = Pdados[playerid][OrgID];
	new skin = SkinOrg[skn][0];
	return skin;
}
stock CorOrg(playerid){
	if((Pdados[playerid][OrgID] >= 1)&&(Pdados[playerid][OrgID] <= 12)){
		return AZUL;
	}
	if(Pdados[playerid][OrgID] == 16){
		return ROXO;
	}
	return 1;
}
stock ADM(playerid, lvl)
{
	if(Pdados[playerid][Admin] == 0)
	{
		format(String, sizeof(String), "{FF0000}[ERRO]{FFFFFF}Voce precisa ser admin para usar este comando!");
		SendClientMessage(playerid, -1, String);
		return 0;
	}
	else if(Pdados[playerid][Admin] < lvl){
        format(String, sizeof(String), "{FF0000}[ERRO]{FFFFFF}Voce precisa ser %s para usar este comando!", NomeAdm(lvl));
		SendClientMessage(playerid, -1, String);
		return 0;
	}
    // Admin 1~7 so pode usar comandos administrativos em modo trabalho.
    // Cargo 8 pode usar comandos administrativos mesmo em modo play.
    if(Pdados[playerid][Admin] < 8 && !Pdados[playerid][Trabalhando])
    {
        SendClientMessage(playerid, -1, "{FF0000}[ERRO]{FFFFFF} Entre em modo trabalho usando /deus para usar comandos administrativos.");
        return 0;
    }
	return 1;
}
stock Emprego(playerid)
{   new e[56],lvl;
	lvl = Pdados[playerid][Trabalho];
	if(lvl == 0){
		e = "Desempregado";
		return e;
	}
	if(lvl == 1){
		e = "Entregador de pizza";
		return e;
	}
	if(lvl == 2){
		e = "Tecnico de Internet";
		return e;
	}
	if(lvl == 3){
		e = "Caminhoneiro";
		return e;
	}
	if(lvl == 4){
		e = "Motorista de onibus";
		return e;
	}
	if(lvl == 5){
		e = "Entregador de revista";
		return e;
	}
	if(lvl == 6){
		e = "Taxista";
		return e;
	}
	if(lvl == 7){
		e = "Transportador de cimento";
		return e;
	}
	if(lvl == 10){
		e = "IFOOD";
		return e;
	}
	return e;
}
stock IsPerto(playerid,id){
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	if(IsPlayerInRangeOfPoint(playerid,10,x,y,z)){
		return 1;
	}
	return 0;
}
stock MsgOrg(playerid,msg[]){
	for(new i = 0;i<MAX_PLAYERS;i++){
		if(Pdados[playerid][OrgID] == Pdados[i][OrgID]){
		    SendClientMessage(i,AZUL,msg);
		}
	}
	return 1;
}
stock MsgVip(playerid,msg[]){
	for(new i = 0;i<MAX_PLAYERS;i++){
		if(Pdados[playerid][Vip] == Pdados[i][Vip]){
		    SendClientMessage(i,AMARELO,msg);
		}
	}
	return 1;
}
stock NomeCarga(carro){
    new nomecarga[35];
	switch(CarDados[carro][carga]){
	    case 0: nomecarga = "Vazio";
	    case 1: nomecarga = "Materia-Prima";
	    case 2: nomecarga = "Materia-Prima";
	    case 3: nomecarga = "Maconha";
	    default: nomecarga = "Vazio";
	}
	return nomecarga;
}
stock NomeCargo(playerid){
	new CARGO[40];
	if(Pdados[playerid][OrgID] <= 12){
	    if(Pdados[playerid][Cargo] == 1){
			CARGO = "Recruta";
		}if(Pdados[playerid][Cargo] == 2){
			CARGO = "Soldado";
		}if(Pdados[playerid][Cargo] == 3){
			CARGO = "Coronel";
		}if(Pdados[playerid][Cargo] == 4){
			CARGO = "Sub-comandante";
		}if(Pdados[playerid][Cargo] == 5){
		    if(Pdados[playerid][OrgID] == 1){
                CARGO = "Marechal";
			}else{
				CARGO = "Comandante";
			}
		}
	}if(Pdados[playerid][OrgID] >= 16){
        if(Pdados[playerid][Cargo] == 1){
			CARGO = "Aprendiz";
		}if(Pdados[playerid][Cargo] == 2){
			CARGO = "Olheiro";
		}if(Pdados[playerid][Cargo] == 3){
			CARGO = "Fogueteiro";
		}if(Pdados[playerid][Cargo] == 4){
			CARGO = "Sub-Chefe";
		}if(Pdados[playerid][Cargo] == 5){
			CARGO = "Chefe";
		}

	}
	return CARGO;
}
stock NomeOrg(playerid)
{
    new string_org[40];
    format(string_org, sizeof(string_org), "%s", GetNomeOrg(Pdados[playerid][OrgID]));
    return string_org;
}

stock GetNomeOrg(orgid)
{
    new name[40];
    switch(orgid)
    {
        case 0: name = "Civil";
        case 1: name = "Exercito Brasileiro";
        case 2: name = "Bope";
        case 3: name = "Tropa de choque";
        case 4: name = "Rota";
        case 5: name = "PM";
        case 6: name = "BAEP";
        case 7: name = "Forca Tatica";
        case 8: name = "Policia Federal";
        case 9: name = "Policia Civil";
        case 10: name = "Policia Rodoviaria Federal";
        case 11: name = "Rotam";
        case 12: name = "Guarda Municipal";
        case 13: name = "Governo";
        case 14: name = "Cidade Alerta";
        case 15: name = "Medicos";
        case 16: name = "Mafia Cosa Nostra";
        case 17: name = "ALQAEDA";
        case 18: name = "TALIBA";
        case 19: name = "Mafia Yakusa";
        case 20: name = "Cartel Medelin";
        case 21: name = "Triads";
        case 22: name = "Faccao Mineira";
        case 23: name = "Cartel de Cali";
        case 24: name = "Comando Vermelho";
        case 25: name = "Primeiro Comando da Capital";
        case 26: name = "Terceiro Comando Puro";
        case 27: name = "Familia do Norte";
        case 28: name = "Motoclube";
        case 29: name = "B40";
        case 30: name = "Milicia";
        case 31: name = "ADA";
        case 32: name = "trembala";
        case 33: name = "Mecanico";
        case 34: name = "Prefeitura";
        default:
        {
            if(orgid >= ORG_CUSTOM_INICIO && orgid <= ORG_CUSTOM_FIM && OrgCustomAtiva[orgid])
                format(name, sizeof(name), "%s", OrgCustomNome[orgid]);
            else
                name = "Inexistente";
        }
    }
    return name;
}

stock MsgAdm(mensagem[])
{
	for(new i = 0; i < MAX_PLAYERS; ++i)
	{
	    if(Pdados[i][Admin] > 0)
	    {
			SendClientMessage(i, CINZA, mensagem);
		}
	}
	return 1;
}
stock NomeAdm(cargo)
{
	new name[35];
	if(cargo == 1) name = "Ajudante";
	if(cargo == 2) name = "Moderador";
	if(cargo == 3) name = "Super moderador";
	if(cargo == 4) name = "Adminstrador";
	if(cargo == 5) name = "Adminstrador corp";
	if(cargo == 6) name = "Adminstrador facc";
	if(cargo == 7) name = "Adminstrador geral";
	if(cargo == 8) name= "Scripter/IW";
	if(cargo == 9) name = "Gerente";
	if(cargo == 10) name = "Sub dono";
	if(cargo == 11) name = "Dono";
	if(cargo == 12) name= "Fundador";
	if(cargo == 13) name= "Criador/Scripter";
	return name;
}

stock Nome(playerid)
{   new nome[MAX_PLAYER_NAME];
	GetPlayerName(playerid,nome,24);
	return nome;
}
stock ZerarDados(playerid){
	Pdados[playerid][Banco] = 0;
	Pdados[playerid][Admin] = 0;
	Pdados[playerid][Grana] = 0;
	Pdados[playerid][OrgID] = 0;
	Pdados[playerid][Cargo] = 0;
	Pdados[playerid][Trabalho] = 0;
	Pdados[playerid][Coins] = 0;
	Pdados[playerid][Vip] = false;
	return 1;
}
stock SalvarDados(playerid)
{   
    new ip[25];
    GetPlayerIp(playerid, ip, sizeof(ip));
    Pdados[playerid][Grana] = GetPlayerMoney(playerid);
    Pdados[playerid][Estrelas] = GetPlayerWantedLevel(playerid);
    Pdados[playerid][Skin] = GetPlayerSkin(playerid);
    
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    DOF2_SetInt(StringContas, "Grana", GetPlayerMoney(playerid));
    DOF2_SetInt(StringContas, "Admin", Pdados[playerid][Admin]);
    DOF2_SetInt(StringContas, "Org", Pdados[playerid][OrgID]);
    DOF2_SetInt(StringContas, "Skin", Pdados[playerid][Skin]);
    DOF2_SetInt(StringContas, "Cargo", Pdados[playerid][Cargo]);
    DOF2_SetInt(StringContas, "Level", Pdados[playerid][Level]);
    DOF2_SetInt(StringContas, "Banco", Pdados[playerid][Banco]);
    DOF2_SetInt(StringContas, "Vip", Pdados[playerid][Vip]);
    DOF2_SetInt(StringContas, "Socio", Pdados[playerid][Socio]);
    DOF2_SetInt(StringContas, "CNH", Pdados[playerid][CNH]);
    DOF2_SetInt(StringContas, "CNHb", Pdados[playerid][CNHb]);
    DOF2_SetInt(StringContas, "CNHc", Pdados[playerid][CNHc]);
    DOF2_SetInt(StringContas, "Celular", Pdados[playerid][Celular]);
    DOF2_SetInt(StringContas, "Genero", Pdados[playerid][Genero]);
    DOF2_SetInt(StringContas, "Mochila", Pdados[playerid][Mochila]);
    DOF2_SetInt(StringContas, "cFerramentas", Pdados[playerid][cFerramentas]);
    DOF2_SetInt(StringContas, "Discord", Pdados[playerid][Discord]);
    DOF2_SetInt(StringContas, "Coins", Pdados[playerid][Coins]);
    DOF2_SetInt(StringContas, "Item_Medikit", Pdados[playerid][pItem_Medikit]);
    DOF2_SetInt(StringContas, "Item_Colete", Pdados[playerid][pItem_Colete]);
    DOF2_SetInt(StringContas, "Item_Galao", Pdados[playerid][pItem_Galao]);
    DOF2_SetInt(StringContas, "Item_KitReparo", Pdados[playerid][pItem_KitReparo]);
    DOF2_SetInt(StringContas, "Item_Blindagem", Pdados[playerid][pItem_Blindagem]);
    DOF2_SetInt(StringContas, "Item_Licencias", Pdados[playerid][pItem_Licencias]);
    DOF2_SetInt(StringContas, "Item_CaixaItens", Pdados[playerid][pItem_CaixaItens]);
    DOF2_SetInt(StringContas, "Item_Grafite", Pdados[playerid][pItem_Grafite]);
    DOF2_SetInt(StringContas, "Item_SlotInv", Pdados[playerid][pItem_SlotInv]);
    DOF2_SetInt(StringContas, "Item_Titulo", Pdados[playerid][pItem_Titulo]);
    DOF2_SetString(StringContas, "Texto_Titulo", Pdados[playerid][pTexto_Titulo]);
    DOF2_SetInt(StringContas, "Item_Portao", Pdados[playerid][pItem_Portao]);
    DOF2_SetInt(StringContas, "DinheiroSujo", Pdados[playerid][DinheiroSujo]);
    DOF2_SetInt(StringContas, "VipNivel", Pdados[playerid][pVip]);
    DOF2_SetInt(StringContas, "VipDias", Pdados[playerid][pDiasVip]);
    DOF2_SetInt(StringContas, "SocioNivel", Pdados[playerid][pSocio]);
    DOF2_SetInt(StringContas, "SocioDias", Pdados[playerid][pDiasSocio]);
    DOF2_SetInt(StringContas, "Patrocinador", Pdados[playerid][pPatrocinador]);
    DOF2_SetInt(StringContas, "PatrocinioDias", Pdados[playerid][pDiasPatrocinio]);
    DOF2_SetBool(StringContas, "Porte", Pdados[playerid][Porte]);
    DOF2_SetInt(StringContas, "DonoPostoID", Pdados[playerid][pDonoPostoID]);
    DOF2_SetInt(StringContas, "Gasosa1", Dados[playerid][gasosa1]);
    DOF2_SetInt(StringContas, "Gasosa2", Dados[playerid][gasosa2]);
    DOF2_SetString(StringContas, "PIN_Celular", SenhaCelular[playerid]);
    DOF2_SetInt(StringContas, "Adrenalina", Pdados[playerid][Adrenalina]);

    // =========================================================================
    // BLINDAGEM DAS COORDENADAS: SISTEMA DE MORTE
    // =========================================================================
    new Float:PosX, Float:PosY, Float:PosZ, Float:PosR;
    GetPlayerPos(playerid, PosX, PosY, PosZ);
    GetPlayerFacingAngle(playerid, PosR);

    Pdados[playerid][pDonoPostoID] = -1; // Reset inicial
    for(new i = 0; i < MAX_POSTOS; i++)
    {
        if(PostoInfo[i][pCriado] && strcmp(PostoInfo[i][pDono], Nome(playerid), true) == 0)
        {
            Pdados[playerid][pDonoPostoID] = i;
            break;
        }
    }
    
    if(ObjetoJBL[playerid] != INVALID_OBJECT_ID)
    {
        DOF2_SetInt(StringContas, "Item_JBL", Pdados[playerid][pItem_JBL] + 1);
    }
    else // Se estiver guardada normalmente na mochila
    {
        DOF2_SetInt(StringContas, "Item_JBL", Pdados[playerid][pItem_JBL]);
    }
    
    // === SALVAR ARMAS ===
    new armaID, municao, TagArma[20], TagAmmo[20];
    for (new i = 0; i < 13; i++) 
    {
        GetPlayerWeaponData(playerid, i, armaID, municao);
        
        format(TagArma, sizeof(TagArma), "Arma_Slot%d", i);
        format(TagAmmo, sizeof(TagAmmo), "Ammo_Slot%d", i);
        
        DOF2_SetInt(StringContas, TagArma, armaID);
        DOF2_SetInt(StringContas, TagAmmo, municao);
    }

    // Salva exatamente o local onde o jogador saiu.
    // Inclui interior e Virtual World para manter o jogador no mesmo local
    // mesmo quando ele estava dentro de uma casa/interior.
    DOF2_SetFloat(StringContas, "PosX", PosX);
    DOF2_SetFloat(StringContas, "PosY", PosY);
    DOF2_SetFloat(StringContas, "PosZ", PosZ);
    DOF2_SetFloat(StringContas, "PosR", PosR);
    DOF2_SetInt(StringContas, "PosInterior", GetPlayerInterior(playerid));
    DOF2_SetInt(StringContas, "PosWorld", GetPlayerVirtualWorld(playerid));

    DOF2_SetInt(StringContas, "Trabalho", Pdados[playerid][Trabalho]);
    DOF2_SetInt(StringContas, "YouTuber", Pdados[playerid][YouTuber]);
    DOF2_SetInt(StringContas, "Preso", Pdados[playerid][Preso]);
    DOF2_SetInt(StringContas, "Estrelas", Pdados[playerid][Estrelas]);
    DOF2_SetString(StringContas, "IP", ip);

    // Salvar dados da concessionaria externa
    format(Contas, sizeof(Contas), "Conse/%s.txt", Nome(playerid));
    DOF2_SetInt(Contas, "Carro1", Dados[playerid][modelo1]);
    DOF2_SetInt(Contas, "Carro2", Dados[playerid][modelo2]);
    DOF2_SetInt(Contas, "Cor1Carro1", Dados[playerid][cor11]);
    DOF2_SetInt(Contas, "Cor2Carro1", Dados[playerid][cor12]);
    DOF2_SetInt(Contas, "Cor1Carro2", Dados[playerid][cor21]);
    DOF2_SetInt(Contas, "Cor2Carro2", Dados[playerid][cor22]);

    // === SALVAR NECESSIDADES DO PERSONAGEM ===
    // IMPORTANTE: acima StringContas foi usado para a concessionaria (Conse/).
    // Voltamos para o arquivo da conta antes de salvar fome, sede e sono.
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    DOF2_SetFloat(StringContas, "Status_Fome", Status_Fome[playerid]);
    DOF2_SetFloat(StringContas, "Status_Sede", Status_Sede[playerid]);
    DOF2_SetFloat(StringContas, "Status_Energia", Status_Energia[playerid]);
    DOF2_SetFloat(StringContas, "Status_Sono", Status_Sono[playerid]);
    DOF2_SetInt(StringContas, "StatusNecessidades", 1);
    
    DOF2_SaveFile();
    return 1;
}

stock CarregarDados(playerid)
{
    // Usando a variavel global StringContas diretamente para evitar o warning 219
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));

    if(!DOF2_FileExists(StringContas)) return 0;

    // === CARREGAR NECESSIDADES DO PERSONAGEM ===
    // Contas antigas sem estas chaves recebem 100% apenas uma vez.
    if(DOF2_GetInt(StringContas, "StatusNecessidades") == 1)
    {
        Status_Fome[playerid] = DOF2_GetFloat(StringContas, "Status_Fome");
        Status_Sede[playerid] = DOF2_GetFloat(StringContas, "Status_Sede");
        Status_Energia[playerid] = DOF2_GetFloat(StringContas, "Status_Energia");
        Status_Sono[playerid] = DOF2_GetFloat(StringContas, "Status_Sono");

        // Corrige contas que ficaram presas no antigo estado de morte por fome/sede.
        // A versao anterior gravava exatamente 10% ao matar o jogador, fazendo o
        // proximo login carregar 10% e morrer novamente. Como fome e sede eram
        // resetadas juntas, 10/10 e tratado como esse estado antigo.
        if(Status_Fome[playerid] == 10.0 && Status_Sede[playerid] == 10.0)
        {
            Status_Fome[playerid] = 100.0;
            Status_Sede[playerid] = 100.0;
            DOF2_SetFloat(StringContas, "Status_Fome", 100.0);
            DOF2_SetFloat(StringContas, "Status_Sede", 100.0);
            DOF2_SaveFile();
        }
    }
    else
    {
        // Conta antiga: inicializa uma unica vez e grava a marca para nunca mais resetar.
        Status_Fome[playerid] = 100.0;
        Status_Sede[playerid] = 100.0;
        Status_Energia[playerid] = 100.0;
        Status_Sono[playerid] = 100.0;
        DOF2_SetFloat(StringContas, "Status_Fome", Status_Fome[playerid]);
        DOF2_SetFloat(StringContas, "Status_Sede", Status_Sede[playerid]);
        DOF2_SetFloat(StringContas, "Status_Energia", Status_Energia[playerid]);
        DOF2_SetFloat(StringContas, "Status_Sono", Status_Sono[playerid]);
        DOF2_SetInt(StringContas, "StatusNecessidades", 1);
        DOF2_SaveFile();
    }

    // Garantia contra valores fora da faixa.
    if(Status_Fome[playerid] < 0.0) Status_Fome[playerid] = 0.0;
    if(Status_Fome[playerid] > 100.0) Status_Fome[playerid] = 100.0;
    if(Status_Sede[playerid] < 0.0) Status_Sede[playerid] = 0.0;
    if(Status_Sede[playerid] > 100.0) Status_Sede[playerid] = 100.0;
    if(Status_Energia[playerid] < 0.0) Status_Energia[playerid] = 0.0;
    if(Status_Energia[playerid] > 100.0) Status_Energia[playerid] = 100.0;
    if(Status_Sono[playerid] < 0.0) Status_Sono[playerid] = 0.0;
    if(Status_Sono[playerid] > 100.0) Status_Sono[playerid] = 100.0;

    // Carregar os dados base do jogador
    Pdados[playerid][Matou]           = DOF2_GetInt(StringContas, "Matou");
    Pdados[playerid][Grana]           = DOF2_GetInt(StringContas, "Grana");
    Pdados[playerid][Admin]           = DOF2_GetInt(StringContas, "Admin");
    Pdados[playerid][OrgID]             = DOF2_GetInt(StringContas, "Org");
    Pdados[playerid][Cargo]           = DOF2_GetInt(StringContas, "Cargo");
    Pdados[playerid][Banco]           = DOF2_GetInt(StringContas, "Banco");
    Pdados[playerid][SegundosJogados] = DOF2_GetInt(StringContas, "SegundosJogados");
    Pdados[playerid][Skin]            = DOF2_GetInt(StringContas, "Skin");
    Pdados[playerid][Level]           = DOF2_GetInt(StringContas, "Level");
    
    // CORREcaO DO ERROR 022: Atribuicao de booleanos aceita pelo compilador
    Pdados[playerid][Vip]             = (DOF2_GetBool(StringContas, "Vip") ? true : false);
    Pdados[playerid][Socio]           = (DOF2_GetBool(StringContas, "Socio") ? true : false);
    
    Pdados[playerid][CNH]             = DOF2_GetInt(StringContas, "CNH");
    Pdados[playerid][CNHb]            = DOF2_GetInt(StringContas, "CNHb");
    Pdados[playerid][CNHc]            = DOF2_GetInt(StringContas, "CNHc");
    Pdados[playerid][Celular]         = DOF2_GetInt(StringContas, "Celular");
    Pdados[playerid][Genero]          = DOF2_GetInt(StringContas, "Genero");
    Pdados[playerid][Mochila]         = DOF2_GetInt(StringContas, "Mochila");
    Pdados[playerid][Mochila]         = 1; // Mochila integrada, sem compra.
    Pdados[playerid][cFerramentas]    = DOF2_GetInt(StringContas, "cFerramentas");
    Pdados[playerid][Discord]         = DOF2_GetInt(StringContas, "Discord");
    Pdados[playerid][Trabalho]        = DOF2_GetInt(StringContas, "Trabalho");
    Pdados[playerid][YouTuber]        = (DOF2_GetBool(StringContas, "YouTuber") == true) ? true : false;
    Pdados[playerid][Preso]           = DOF2_GetInt(StringContas, "Preso");
    Pdados[playerid][Estrelas]        = DOF2_GetInt(StringContas, "Estrelas");
    Pdados[playerid][Coins]           = DOF2_GetInt(StringContas, "Coins");
    
    // Carregar inventario e itens
    Pdados[playerid][pItem_Medikit]   = DOF2_GetInt(StringContas, "Item_Medikit");
    Pdados[playerid][pItem_Colete]    = DOF2_GetInt(StringContas, "Item_Colete");
    Pdados[playerid][pItem_Galao]     = DOF2_GetInt(StringContas, "Item_Galao");
    Pdados[playerid][pItem_KitReparo] = DOF2_GetInt(StringContas, "Item_KitReparo");
    Pdados[playerid][pItem_Blindagem] = DOF2_GetInt(StringContas, "Item_Blindagem");
    Pdados[playerid][pItem_Licencias] = DOF2_GetInt(StringContas, "Item_Licencias");
    Pdados[playerid][pItem_CaixaItens] = DOF2_GetInt(StringContas, "Item_CaixaItens");
    Pdados[playerid][pItem_Grafite]   = DOF2_GetInt(StringContas, "Item_Grafite");
    Pdados[playerid][pItem_SlotInv]   = DOF2_GetInt(StringContas, "Item_SlotInv");
    Pdados[playerid][pItem_Titulo]    = DOF2_GetInt(StringContas, "Item_Titulo");
    Pdados[playerid][Adrenalina] = DOF2_GetInt(StringContas, "Adrenalina");

    DOF2_GetString(StringContas, "Texto_Titulo", Pdados[playerid][pTexto_Titulo]);
    
    Pdados[playerid][pItem_JBL]       = DOF2_GetInt(StringContas, "Item_JBL");
    Pdados[playerid][pItem_Portao]    = DOF2_GetInt(StringContas, "Item_Portao");
    Pdados[playerid][DinheiroSujo] = DOF2_GetInt(StringContas, "DinheiroSujo");
    
    // Carregar Vips e Prazos
    Pdados[playerid][pVip]            = DOF2_GetInt(StringContas, "VipNivel");
    Pdados[playerid][pDiasVip]        = DOF2_GetInt(StringContas, "VipDias");
    Pdados[playerid][pSocio]          = DOF2_GetInt(StringContas, "SocioNivel");
    Pdados[playerid][pDiasSocio]      = DOF2_GetInt(StringContas, "SocioDias");
    Pdados[playerid][pPatrocinador]   = DOF2_GetInt(StringContas, "Patrocinador");
    Pdados[playerid][pDiasPatrocinio] = DOF2_GetInt(StringContas, "PatrocinioDias");
    
    // CORREcaO DO ERROR 022: Atribuicao de booleano para o Porte de Armas
    Pdados[playerid][Porte]           = (DOF2_GetBool(StringContas, "Porte") ? true : false);
    
    // Sistemas empresariais (Posto e combustiveis)
    Pdados[playerid][pDonoPostoID]    = DOF2_GetInt(StringContas, "DonoPostoID");
    Dados[playerid][gasosa1]          = DOF2_GetInt(StringContas, "Gasosa1");
    Dados[playerid][gasosa2]          = DOF2_GetInt(StringContas, "Gasosa2");
    
    format(SenhaCelular[playerid], 5, DOF2_GetString(StringContas, "PIN_Celular"));

    // Carregar dados da concessionaria externa
    format(Contas, sizeof(Contas), "Conse/%s.txt", Nome(playerid));
    if(DOF2_FileExists(Contas))
    {
        Dados[playerid][modelo1]      = DOF2_GetInt(Contas, "Carro1");
        Dados[playerid][modelo2]      = DOF2_GetInt(Contas, "Carro2");
        Dados[playerid][cor11]        = DOF2_GetInt(Contas, "Cor1Carro1");
        Dados[playerid][cor12]        = DOF2_GetInt(Contas, "Cor2Carro1");
        Dados[playerid][cor21]        = DOF2_GetInt(Contas, "Cor1Carro2");
        Dados[playerid][cor22]        = DOF2_GetInt(Contas, "Cor2Carro2");
    }
    return 1;
}



stock precovehicle(modelo){
	new a;
	switch(modelo){
		case 411: a = 1000000;
		case 510: a = 1000;
		case 496: a = 30000;
		case 462: a = 8000;
		case 506: a = 900000;
		case 542: a = 20000;
		case 543: a = 185000;
		case 521: a = 100000;
		case 468: a = 15000;
		case 560: a = 500000;
		case 489: a = 650000;
        case 400: a = 720000;
		case 483: a = 20000;
		case 429: a = 150000;
		case 541: a = 100000;
		case 402: a = 140000;
		case 461: a = 70000;
		case 463: a = 50000;
		case 480: a = 450000;
		case 451: a = 800000;
		case 522: a = 700000;
		default: a = 1000;

	}
	return a;
}
stock GetPlayerDistance(playerid,Float:x,Float:y,Float:z){
	new Float:pos[3],Float:distance;
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	if(x < 0){
		x *= -1;
	}
	if(y < 0){
		y *= -1;
	}
	if(pos[0] < 0){
		pos[0] *= -1;
	}
	if(pos[1] < 0){
		pos[1] *= -1;
	}
	distance = pos[0]+x+pos[1]+y+z;
	distance /=2;

	return floatround(distance,floatround_ceil);
}


stock GetDistanceBetweenPlayers(playerid,playerid2){
        new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
        new Float:dis;
        GetPlayerPos(playerid,x1,y1,z1);
        GetPlayerPos(playerid2,x2,y2,z2);
        dis = floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
        return floatround(dis);
}
stock Convert(playerid)
{
	new hours = 0, mins = 0, secs = 0, string[100];
    hours = floatround(playerid / 3600);
    mins = floatround((playerid / 60) - (hours * 60));
    secs = floatround(playerid - ((hours * 3600) + (mins * 60)));
    new days = 0;

	if(hours >= 24)
    {
    days = floatround((hours/24), floatround_floor);
    hours = hours % 24;
    }

	if(days > 0)
    {
        format(string, 0xD3F128FF, "%ddias, %dh %dm e %ds", days, hours, mins, secs);
    }
    else if(hours > 0)
    {
        format(string, 0xD3F128FF, "%s%d:%s%d:%s%d", (hours < 10) ? ("0") : (""), hours, (mins < 10) ? ("0"):(""), mins, (secs < 10) ? ("0"):(""), secs);
    }
    else
    {
    	format(string, 0xD3F128FF, "%s%d:%s%d:%s%d", (hours < 10) ? ("0") : (""), hours, (mins < 10) ? ("0"):(""), mins, (secs < 10) ? ("0"):(""), secs);
    }
    return string;
}

forward AtualizarTempo();
public AtualizarTempo()
{
        foreach(Player, i)
        {
                if(Pdados[i][pLogged] == 1)
                {
                        Pdados[i][pTemp]++;
                }
        }
        
        return 1;
}

//---------------armas nas costas dos player--------------//
stock GetWeaponModel(weaponid)
{
    switch(weaponid)
    {
        case 1:
            return 331;

        case 2..8:
            return weaponid+331;

        case 9:
            return 341;

        case 10..15:
            return weaponid+311;

        case 16..18:
            return weaponid+326;

        case 22..29:
            return weaponid+324;

        case 30,31:
            return weaponid+325;

        case 32:
            return 372;

        case 33..45:
            return weaponid+324;

        case 46:
            return 371;
    }
    return 0;
}
stock GivePlayerCash(playerid, quantia)
        {
                GivePlayerMoney(playerid, quantia);
                SetPVarInt(playerid, "Dinheiro", GetPlayerMoney(playerid));
        }
        public CheckMoney()
        {
                new strmsg[128], pName[MAX_PLAYER_NAME];
                for(new i = 0; i < MAX_PLAYERS; i++)
                {
                        if(GetPlayerMoney(i) > GetPVarInt(i, "Dinheiro"))
                        {
                                GetPlayerName(i, pName, sizeof(pName));
                                format(strmsg, sizeof(strmsg), "O %s foi kickado por fazer money hacker.", pName);
                                SendClientMessageToAll(vermelho, strmsg);
                                Kick(i);
                        }
                }
        }

stock PreloadAnims(playerid)//Anti bug animes :D
{
	ApplyAnimation(playerid,"ROB_BANK","CAT_Safe_Rob",4.1,1,0,0,0,0);
    return 1;
}
stock GetNomeMes(mes)
{
	new name[15];
	switch(mes)
	{
	    case 1:name = "Janeiro";
	    case 2:name = "Fevereiro";
	    case 3:name = "Marco";
	    case 4:name = "Abril";
	    case 5:name = "Maio";
	    case 6:name = "Junho";
	    case 7:name = "Julho";
	    case 8:name = "Agosto";
	    case 9:name = "Setembro";
	    case 10:name = "Outubro";
	    case 11:name = "Novembro";
	    case 12:name = "Dezembro";
	    default:name = "Nenhum";
	}
	return name;
}

// --- SISTEMA DE ATUALIZAcaO REAL ---
forward UpdateHUD();
public UpdateHUD()
{
    static danoNecessidade[MAX_PLAYERS];
    static contadorFomeSede[MAX_PLAYERS];

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && Pdados[i][Logado])
        {
            // Necessidades so funcionam depois do login.
            // Isso impede que o timer mexa na fome/sede durante a tela de login
            // e antes de CarregarDados() restaurar os valores salvos.
            // FOME e SEDE: diminuem exatamente 1% a cada 5 minutos.
            // UpdateHUD roda a cada 500ms: 600 ciclos = 5 minutos.
            contadorFomeSede[i]++;
            if(contadorFomeSede[i] >= 600)
            {
                contadorFomeSede[i] = 0;
                Status_Fome[i] -= 1.0;
                Status_Sede[i] -= 1.0;
            }

            // Sono e energia continuam com a queda original.
            Status_Energia[i] -= 0.0050;
            Status_Sono[i]    -= 0.0025;

            // Limites corretos: 0..100.
            if(Status_Fome[i] < 0.0) Status_Fome[i] = 0.0;
            if(Status_Sede[i] < 0.0) Status_Sede[i] = 0.0;
            if(Status_Energia[i] < 0.0) Status_Energia[i] = 0.0;
            if(Status_Sono[i] < 0.0) Status_Sono[i] = 0.0;
            if(Status_Fome[i] > 100.0) Status_Fome[i] = 100.0;
            if(Status_Sede[i] > 100.0) Status_Sede[i] = 100.0;
            if(Status_Energia[i] > 100.0) Status_Energia[i] = 100.0;
            if(Status_Sono[i] > 100.0) Status_Sono[i] = 100.0;

            // FOME/SEDE: a partir de 10% o jogador perde 2 de vida por segundo.
            // O UpdateHUD roda a cada 500ms, por isso contamos 2 ciclos para 1 segundo.
            danoNecessidade[i]++;
            if(danoNecessidade[i] >= 2)
            {
                danoNecessidade[i] = 0;

                if(!Pdados[i][Imortal] && !g_DadosMorte[i][pEmComa])
                {
                    if(Status_Fome[i] <= 10.0 || Status_Sede[i] <= 10.0)
                    {
                        new Float:vida;
                        GetPlayerHealth(i, vida);

                        // Ao chegar em 2% ou menos, o jogador MORRE.
                        // A mensagem informa qual necessidade causou a morte.
                        if(Status_Fome[i] <= 2.0)
                        {
                            g_MorreuPorFome[i] = true;
                            // A mensagem de fome foi substituida pela mensagem padrao de ferido em OnPlayerDeath.

                            // Depois de morrer de fome, o personagem renasce com
                            // as necessidades completas. Nunca salve 10% como estado
                            // permanente, pois isso fazia o proximo login carregar 10%.
                            Status_Fome[i] = 100.0;
                            Status_Sede[i] = 100.0;
                            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(i));
                            DOF2_SetFloat(StringContas, "Status_Fome", 100.0);
                            DOF2_SetFloat(StringContas, "Status_Sede", 100.0);
                            DOF2_SaveFile();

                            SetPlayerHealth(i, 0.0);
                        }
                        else if(Status_Sede[i] <= 2.0)
                        {
                            g_MorreuPorSede[i] = true;
                            // A mensagem de sede foi substituida pela mensagem padrao de ferido em OnPlayerDeath.

                            // Depois de morrer de sede, o personagem renasce com
                            // as necessidades completas. Nunca salve 10% como estado
                            // permanente, pois isso fazia o proximo login carregar 10%.
                            Status_Fome[i] = 100.0;
                            Status_Sede[i] = 100.0;
                            format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(i));
                            DOF2_SetFloat(StringContas, "Status_Fome", 100.0);
                            DOF2_SetFloat(StringContas, "Status_Sede", 100.0);
                            DOF2_SaveFile();

                            SetPlayerHealth(i, 0.0);
                        }
                        else
                        {
                            vida -= 2.0;
                            if(vida < 0.0) vida = 0.0;
                            SetPlayerHealth(i, vida);
                        }
                    }
                }
            }

            // Barras: 100% = cheia, 0% = vazia.
            UpdateBar(i, 0, Status_Fome[i]);
            UpdateBar(i, 1, Status_Sede[i]);
            UpdateBar(i, 2, Status_Sono[i]);

            // Velocimetro atualizado em tempo real enquanto dirige.
            if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
            {
                new vid = GetPlayerVehicleID(i);
                if(vid > 0 && !IsAbicycle(vid))
                {
                    new Float:vhealth;
                    new speed, fuel, hp;
                    GetVehicleHealth(vid, vhealth);
                    speed = floatround(GetVehicleSpeed(vid));
                    if(speed < 0) speed = 0;
                    if(speed > 999) speed = 999;
                    fuel = GasolinaVeiculo[vid];
                    if(fuel < 0) fuel = 0;
                    if(fuel > 100) fuel = 100;
                    hp = floatround(vhealth / 10.0);
                    if(hp < 0) hp = 0;
                    if(hp > 100) hp = 100;

                    new spd[8], fuelstr[8], hpstr[8];
                    format(spd, sizeof(spd), "%03d", speed);
                    format(fuelstr, sizeof(fuelstr), "%d", fuel);
                    format(hpstr, sizeof(hpstr), "%d", hp);
                    PlayerTextDrawSetString(i, cWspeedo[i][3], spd);
                    PlayerTextDrawSetString(i, cWspeedo[i][6], fuelstr);
                    PlayerTextDrawSetString(i, cWspeedo[i][8], hpstr);
                    new motorstr[32];
                    format(motorstr, sizeof motorstr, "HP | MOTOR: %s", MotorLigado[vid] ? "ON" : "OFF");
                    PlayerTextDrawSetString(i, cWspeedo[i][9], motorstr);
                }
            }
        }
    }
    return 1;
}

stock UpdateBar(playerid, barid, Float:value)
{
    new percentText[8];
    new valueIndex;

    if(value < 0.0) value = 0.0;
    if(value > 100.0) value = 100.0;

    format(percentText, sizeof(percentText), "%d%%", floatround(value, floatround_round));

    // 0 = FOME, 1 = SEDE, 2 = SONO
    valueIndex = barid * 2 + 1;

    PlayerTextDrawSetString(playerid, Text_Player[playerid][valueIndex], percentText);
    if(!BCG36Client[playerid])
    {
        PlayerTextDrawShow(playerid, Text_Player[playerid][valueIndex - 1]);
        PlayerTextDrawShow(playerid, Text_Player[playerid][valueIndex]);
    }
}



// ==========================================
// 1. TELA DE CARREGAMENTO (LOADING SCREEN)
// ==========================================
stock CriarTextDrawsLoading(playerid)
{
    // [0] Fundo Preto Solido Full Screen
    LoadingTD[playerid][0] = CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "box");
    PlayerTextDrawLetterSize(playerid, LoadingTD[playerid][0], 0.000000, 50.000000);
    PlayerTextDrawTextSize(playerid, LoadingTD[playerid][0], 640.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, LoadingTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, LoadingTD[playerid][0], -1);
    PlayerTextDrawUseBox(playerid, LoadingTD[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, LoadingTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, LoadingTD[playerid][0], 1);

    // [1] Caixa da Barra de Carregamento (Fundo)
    LoadingTD[playerid][1] = CreatePlayerTextDraw(playerid, 180.000000, 680.000000, "box");
    PlayerTextDrawLetterSize(playerid, LoadingTD[playerid][1], 0.000000, 0.800000);
    PlayerTextDrawTextSize(playerid, LoadingTD[playerid][1], 460.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, LoadingTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, LoadingTD[playerid][1], -1);
    PlayerTextDrawUseBox(playerid, LoadingTD[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, LoadingTD[playerid][1], 50);
    PlayerTextDrawFont(playerid, LoadingTD[playerid][1], 1);

    // [2] Progresso da Barra de Carregamento (Parte preenchida branca/cinza claro)
    LoadingTD[playerid][2] = CreatePlayerTextDraw(playerid, 180.000000, 680.000000, "box");
    PlayerTextDrawLetterSize(playerid, LoadingTD[playerid][2], 0.000000, 0.800000);
    PlayerTextDrawTextSize(playerid, LoadingTD[playerid][2], 280.000000, 0.000000); // Tamanho dinâmico do progresso
    PlayerTextDrawAlignment(playerid, LoadingTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, LoadingTD[playerid][2], -1);
    PlayerTextDrawUseBox(playerid, LoadingTD[playerid][2], 1);
    PlayerTextDrawBoxColor(playerid, LoadingTD[playerid][2], -1);
    PlayerTextDrawFont(playerid, LoadingTD[playerid][2], 1);

    // [3] Texto de Diretório / Status
    LoadingTD[playerid][3] = CreatePlayerTextDraw(playerid, 180.000000, 665.000000, "modulos/servidor/mapas.inc");
    PlayerTextDrawLetterSize(playerid, LoadingTD[playerid][3], 0.150000, 0.650000);
    PlayerTextDrawAlignment(playerid, LoadingTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, LoadingTD[playerid][3], 13158607);
    PlayerTextDrawFont(playerid, LoadingTD[playerid][3], 1);
    PlayerTextDrawSetOutline(playerid, LoadingTD[playerid][3], 0);
    PlayerTextDrawSetShadow(playerid, LoadingTD[playerid][3], 0);

    // [4] Frase de Rodapé / Dica
    LoadingTD[playerid][4] = CreatePlayerTextDraw(playerid, 320.000000, 715.000000, "Construa sua historia com calma: cada escolha tem consequencia.");
    PlayerTextDrawLetterSize(playerid, LoadingTD[playerid][4], 0.160000, 0.700000);
    PlayerTextDrawAlignment(playerid, LoadingTD[playerid][4], 2);
    PlayerTextDrawColor(playerid, LoadingTD[playerid][4], 13158607);
    PlayerTextDrawFont(playerid, LoadingTD[playerid][4], 1);
    PlayerTextDrawSetOutline(playerid, LoadingTD[playerid][4], 0);
    PlayerTextDrawSetShadow(playerid, LoadingTD[playerid][4], 0);
}

stock MostrarLoadingScreen(playerid)
{
    CriarTextDrawsLoading(playerid);
    for(new i = 0; i < MAX_LOADING_TD; i++)
    {
        PlayerTextDrawShow(playerid, LoadingTD[playerid][i]);
    }
}

stock OcultarLoadingScreen(playerid)
{
    for(new i = 0; i < MAX_LOADING_TD; i++)
    {
        PlayerTextDrawHide(playerid, LoadingTD[playerid][i]);
    }
}

// ==========================================
// 2. TELA DE LOGIN
// ==========================================
stock CriarTextDrawsLogin(playerid)
{
    // Tela de login basica e limpa.
    // Mantem os indices 11 e 12 como botao para nao alterar o sistema existente.

    // [1] Fundo escuro em tela inteira
    LoginTD[playerid][1] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "box");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][1], 0.0, 50.0);
    PlayerTextDrawTextSize(playerid, LoginTD[playerid][1], 640.0, 0.0);
    PlayerTextDrawUseBox(playerid, LoginTD[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, LoginTD[playerid][1], 0x101010EE);
    PlayerTextDrawFont(playerid, LoginTD[playerid][1], 1);

    // [2] Titulo central
    LoginTD[playerid][2] = CreatePlayerTextDraw(playerid, 320.0, 145.0, "BCG ROLEPLAY");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][2], 0.42, 1.7);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][2], 2);
    PlayerTextDrawColor(playerid, LoginTD[playerid][2], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, LoginTD[playerid][2], 2);
    PlayerTextDrawSetOutline(playerid, LoginTD[playerid][2], 1);

    // [3] Painel central
    LoginTD[playerid][3] = CreatePlayerTextDraw(playerid, 320.0, 180.0, "box");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][3], 0.0, 10.5);
    PlayerTextDrawTextSize(playerid, LoginTD[playerid][3], 435.0, 0.0);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][3], 2);
    PlayerTextDrawUseBox(playerid, LoginTD[playerid][3], 1);
    PlayerTextDrawBoxColor(playerid, LoginTD[playerid][3], 0x202020DD);
    PlayerTextDrawFont(playerid, LoginTD[playerid][3], 1);

    // [4] Rotulo
    LoginTD[playerid][4] = CreatePlayerTextDraw(playerid, 320.0, 195.0, "BEM-VINDO");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][4], 0.25, 1.0);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][4], 2);
    PlayerTextDrawColor(playerid, LoginTD[playerid][4], 0xBDBDBDFF);
    PlayerTextDrawFont(playerid, LoginTD[playerid][4], 1);

    // [5] Nome do jogador
    LoginTD[playerid][5] = CreatePlayerTextDraw(playerid, 320.0, 218.0, "Carregando...");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][5], 0.28, 1.15);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][5], 2);
    PlayerTextDrawColor(playerid, LoginTD[playerid][5], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, LoginTD[playerid][5], 2);

    // [6] Linha decorativa
    LoginTD[playerid][6] = CreatePlayerTextDraw(playerid, 320.0, 246.0, "box");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][6], 0.0, 0.12);
    PlayerTextDrawTextSize(playerid, LoginTD[playerid][6], 405.0, 0.0);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][6], 2);
    PlayerTextDrawUseBox(playerid, LoginTD[playerid][6], 1);
    PlayerTextDrawBoxColor(playerid, LoginTD[playerid][6], 0x707070FF);

    // [7] Instrucao
    LoginTD[playerid][7] = CreatePlayerTextDraw(playerid, 320.0, 263.0, "Clique em ENTRAR para continuar");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][7], 0.18, 0.8);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][7], 2);
    PlayerTextDrawColor(playerid, LoginTD[playerid][7], 0xC8C8C8FF);
    PlayerTextDrawFont(playerid, LoginTD[playerid][7], 1);

    // [8], [9], [10] vazios para preservar os indices usados pelo sistema
    for(new i = 8; i <= 10; i++)
    {
        LoginTD[playerid][i] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "_");
        PlayerTextDrawLetterSize(playerid, LoginTD[playerid][i], 0.0, 0.0);
        PlayerTextDrawColor(playerid, LoginTD[playerid][i], 0x00000000);
    }

    // [11] Botao
    LoginTD[playerid][11] = CreatePlayerTextDraw(playerid, 320.0, 295.0, "box");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][11], 0.0, 2.0);
    PlayerTextDrawTextSize(playerid, LoginTD[playerid][11], 405.0, 0.0);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][11], 2);
    PlayerTextDrawUseBox(playerid, LoginTD[playerid][11], 1);
    PlayerTextDrawBoxColor(playerid, LoginTD[playerid][11], 0xE8E8E8FF);
    PlayerTextDrawSetSelectable(playerid, LoginTD[playerid][11], true);

    // [12] Texto clicavel do botao
    LoginTD[playerid][12] = CreatePlayerTextDraw(playerid, 320.0, 301.0, "ENTRAR");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][12], 0.23, 0.95);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][12], 2);
    PlayerTextDrawColor(playerid, LoginTD[playerid][12], 0x202020FF);
    PlayerTextDrawFont(playerid, LoginTD[playerid][12], 2);
    PlayerTextDrawSetSelectable(playerid, LoginTD[playerid][12], true);

    // [13] Rodape simples
    LoginTD[playerid][13] = CreatePlayerTextDraw(playerid, 320.0, 350.0, "Use seu nome e senha cadastrados no servidor");
    PlayerTextDrawLetterSize(playerid, LoginTD[playerid][13], 0.16, 0.7);
    PlayerTextDrawAlignment(playerid, LoginTD[playerid][13], 2);
    PlayerTextDrawColor(playerid, LoginTD[playerid][13], 0x8A8A8AFF);
    PlayerTextDrawFont(playerid, LoginTD[playerid][13], 1);

    // [14] e [15] reservados
    for(new i = 14; i < MAX_LOGIN_TD; i++)
    {
        LoginTD[playerid][i] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "_");
        PlayerTextDrawLetterSize(playerid, LoginTD[playerid][i], 0.0, 0.0);
        PlayerTextDrawColor(playerid, LoginTD[playerid][i], 0x00000000);
    }
}

stock MostrarLoginScreen(playerid)
{
    CriarTextDrawsLogin(playerid);
    PlayerTextDrawSetString(playerid, LoginTD[playerid][5], Nome(playerid));
    for(new i = 1; i < MAX_LOGIN_TD; i++)
    {
        PlayerTextDrawShow(playerid, LoginTD[playerid][i]);
    }
    SelectTextDraw(playerid, 0xFFFFFFFF);
}

stock OcultarLoginScreen(playerid)
{
    for(new i = 1; i < MAX_LOGIN_TD; i++)
    {
        PlayerTextDrawHide(playerid, LoginTD[playerid][i]);
    }
}

// ==========================================
// 3. TELA DE REGISTRO
// ==========================================
stock CriarTextDrawsRegistro(playerid)
{
    // [1] Fundo Full Screen
    RegisterTD[playerid][1] = CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][1], 0.000000, 50.000000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][1], 640.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][1], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][1], 220);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][1], 1);

    // [2] Titulo REGISTRO
    RegisterTD[playerid][2] = CreatePlayerTextDraw(playerid, 55.000000, 130.000000, "REALISMO ROLEPLAY");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][2], 0.400000, 1.600000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][2], -1);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][2], 2);
    PlayerTextDrawSetOutline(playerid, RegisterTD[playerid][2], 0);
    PlayerTextDrawSetShadow(playerid, RegisterTD[playerid][2], 0);

    // [3] Caixa Usuario
    RegisterTD[playerid][3] = CreatePlayerTextDraw(playerid, 55.000000, 170.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][3], 0.000000, 1.500000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][3], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][3], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][3], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][3], 45);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][3], 1);

    RegisterTD[playerid][4] = CreatePlayerTextDraw(playerid, 120.000000, 174.000000, "Nome do Jogador");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][4], 0.180000, 0.750000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][4], -1);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][4], 1);

    // [5] Caixa Senha
    RegisterTD[playerid][5] = CreatePlayerTextDraw(playerid, 55.000000, 195.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][5], 0.000000, 1.500000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][5], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][5], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][5], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][5], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][5], 45);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][5], 1);

    RegisterTD[playerid][6] = CreatePlayerTextDraw(playerid, 120.000000, 199.000000, "Senha");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][6], 0.180000, 0.750000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][6], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][6], 13158607);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][6], 1);

    // [7] Caixa Confirmar Senha
    RegisterTD[playerid][7] = CreatePlayerTextDraw(playerid, 55.000000, 220.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][7], 0.000000, 1.500000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][7], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][7], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][7], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][7], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][7], 45);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][7], 1);

    RegisterTD[playerid][8] = CreatePlayerTextDraw(playerid, 120.000000, 224.000000, "Confirmar senha");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][8], 0.180000, 0.750000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][8], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][8], 13158607);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][8], 1);

    // [9] Caixa ID Discord
    RegisterTD[playerid][9] = CreatePlayerTextDraw(playerid, 55.000000, 245.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][9], 0.000000, 1.500000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][9], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][9], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][9], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][9], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][9], 45);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][9], 1);

    RegisterTD[playerid][10] = CreatePlayerTextDraw(playerid, 120.000000, 249.000000, "ID Discord (opcional)");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][10], 0.180000, 0.750000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][10], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][10], 13158607);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][10], 1);

    // [11] Caixa Gênero
    RegisterTD[playerid][11] = CreatePlayerTextDraw(playerid, 55.000000, 270.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][11], 0.000000, 1.500000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][11], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][11], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][11], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][11], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][11], 45);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][11], 1);

    RegisterTD[playerid][12] = CreatePlayerTextDraw(playerid, 120.000000, 274.000000, "Masculino");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][12], 0.180000, 0.750000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][12], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][12], 13158607);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][12], 1);

    // [13] Caixa Skin Selection
    RegisterTD[playerid][13] = CreatePlayerTextDraw(playerid, 55.000000, 295.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][13], 0.000000, 1.800000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][13], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][13], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][13], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][13], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][13], 45);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][13], 1);

    RegisterTD[playerid][14] = CreatePlayerTextDraw(playerid, 147.000000, 301.000000, "1");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][14], 0.200000, 0.850000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][14], 2);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][14], -1);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][14], 1);

    // [15] Botão SUBMETER
    RegisterTD[playerid][15] = CreatePlayerTextDraw(playerid, 55.000000, 325.000000, "box");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][15], 0.000000, 2.000000);
    PlayerTextDrawTextSize(playerid, RegisterTD[playerid][15], 240.000000, 0.000000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][15], 1);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][15], -1);
    PlayerTextDrawUseBox(playerid, RegisterTD[playerid][15], 1);
    PlayerTextDrawBoxColor(playerid, RegisterTD[playerid][15], 0xF7F2E7FF);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][15], 1);
    PlayerTextDrawSetSelectable(playerid, RegisterTD[playerid][15], true);

    RegisterTD[playerid][16] = CreatePlayerTextDraw(playerid, 147.000000, 332.000000, "Submeter");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][16], 0.200000, 0.850000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][16], 2);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][16], 50);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][16], 1);
    PlayerTextDrawSetSelectable(playerid, RegisterTD[playerid][16], true);

    // [17] Rodapé "Já tem conta? Entrar"
    RegisterTD[playerid][17] = CreatePlayerTextDraw(playerid, 147.000000, 355.000000, "Ja tem conta? Entrar");
    PlayerTextDrawLetterSize(playerid, RegisterTD[playerid][17], 0.160000, 0.700000);
    PlayerTextDrawAlignment(playerid, RegisterTD[playerid][17], 2);
    PlayerTextDrawColor(playerid, RegisterTD[playerid][17], 13158607);
    PlayerTextDrawFont(playerid, RegisterTD[playerid][17], 1);
    PlayerTextDrawSetSelectable(playerid, RegisterTD[playerid][17], true);
}

stock MostrarRegistroScreen(playerid)
{
    CriarTextDrawsRegistro(playerid);
    for(new i = 1; i < MAX_REGISTER_TD; i++)
    {
        if(RegisterTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
            PlayerTextDrawShow(playerid, RegisterTD[playerid][i]);
    }
    SelectTextDraw(playerid, 0x0080FFFF);
}

stock OcultarRegistroScreen(playerid)
{
    for(new i = 1; i < MAX_REGISTER_TD; i++)
    {
        if(RegisterTD[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
            PlayerTextDrawHide(playerid, RegisterTD[playerid][i]);
    }
}


stock ConverterTempo(segundos_totais)
{
    new horas, minutos, segundos, string[32];
    horas = (segundos_totais / 3600);
    minutos = (segundos_totais - (horas * 3600)) / 60;
    segundos = segundos_totais - ((horas * 3600) + (minutos * 60));
    
    format(string, sizeof(string), "%dh, %dm, %ds", horas, minutos, segundos);
    return string;
}
stock CriarPostosPadrao()
{
    // Postos fixos espalhados pelo mapa. Se ja existir um posto proximo, nao duplica.
    new const Float:posPostos[][3] = {
        {1007.0000, -939.0000, 42.2000},   // Los Santos - Ganton
        {1940.0000, -1775.0000, 13.4000},  // Los Santos - Idlewood
        {2115.0000, -1781.0000, 13.4000},  // Los Santos - Willowfield
        {-2029.0000, 156.0000, 28.8000},   // San Fierro - Downtown
        {-1676.0000, 414.0000, 7.2000},    // San Fierro - Doherty
        {2116.0000, 926.0000, 10.8000},    // Las Venturas - Redsands
        {1595.0000, 2195.0000, 10.8000},   // Las Venturas - Whitewood
        {2640.0000, 1100.0000, 10.8000},   // Las Venturas - Rockshore
        {655.0000, -564.0000, 16.3000}     // Flint County
    };

    for(new p = 0; p < sizeof(posPostos); p++)
    {
        new bool:jaExiste = false;
        for(new i = 0; i < MAX_POSTOS; i++)
        {
            if(PostoInfo[i][pCriado])
            {
                new Float:dx = PostoInfo[i][pPosX] - posPostos[p][0];
                new Float:dy = PostoInfo[i][pPosY] - posPostos[p][1];
                new Float:dz = PostoInfo[i][pPosZ] - posPostos[p][2];
                if((dx * dx) + (dy * dy) + (dz * dz) <= 36.0)
                {
                    jaExiste = true;
                    break;
                }
            }
        }
        if(jaExiste) continue;

        new slot = -1;
        for(new i = 0; i < MAX_POSTOS; i++)
        {
            if(!PostoInfo[i][pCriado])
            {
                slot = i;
                break;
            }
        }
        if(slot == -1) break;

        PostoInfo[slot][pCriado] = true;
        format(PostoInfo[slot][pDono], MAX_PLAYER_NAME, "Estado");
        PostoInfo[slot][pPrecoLitro] = 5;
        PostoInfo[slot][pPosX] = posPostos[p][0];
        PostoInfo[slot][pPosY] = posPostos[p][1];
        PostoInfo[slot][pPosZ] = posPostos[p][2];
        PostoInfo[slot][pCombustivel] = CAPACIDADE_MAX;
        PostoInfo[slot][pLucro] = 0;

        PostoInfo[slot][pPickup] = CreatePickup(1239, 1, PostoInfo[slot][pPosX], PostoInfo[slot][pPosY], PostoInfo[slot][pPosZ], -1);
        PostoInfo[slot][pLabel] = CreateDynamic3DTextLabel("Carregando posto...", -1, PostoInfo[slot][pPosX], PostoInfo[slot][pPosY], PostoInfo[slot][pPosZ] + 1.5, 25.0);
        AtualizarPosto(slot);
        SalvarPosto(slot);
    }
    return 1;
}

stock PostoProximo(playerid, Float:distancia_maxima = 8.0)
{
    new id = -1;
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    for(new i = 0; i < MAX_POSTOS; i++)
    {
        if(PostoInfo[i][pCriado] && IsPlayerInRangeOfPoint(playerid, distancia_maxima, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ]))
        {
            id = i;
            break;
        }
    }
    return id;
}

stock SalvarPosto(id) {
    if(!PostoInfo[id][pCriado]) return 0;
    new path[64];
    format(path, sizeof(path), PASTA_POSTOS, id);
    if(!DOF2_FileExists(path)) DOF2_CreateFile(path);
    DOF2_SetString(path, "Dono", PostoInfo[id][pDono]);
    DOF2_SetInt(path, "PrecoLitro", PostoInfo[id][pPrecoLitro]);
    DOF2_SetFloat(path, "PosX", PostoInfo[id][pPosX]);
    DOF2_SetFloat(path, "PosY", PostoInfo[id][pPosY]);
    DOF2_SetFloat(path, "PosZ", PostoInfo[id][pPosZ]);
    DOF2_SetInt(path, "Combustivel", PostoInfo[id][pCombustivel]);
    DOF2_SetInt(path, "Lucro", PostoInfo[id][pLucro]);
    DOF2_SaveFile();
    return 1;
}

stock AtualizarPosto(id) {
    if(!PostoInfo[id][pCriado]) return 0;
    
    new str_label[512]; // Espaco para o texto
    format(str_label, sizeof(str_label), 
        "{00BFFF}POSTO BCG #%d\n\n"\
        "{FFFFFF}Dono: {FFFF00}%s\n"\
        "{FFFFFF}Preco: {00FF00}$%d/L\n"\
        "{FFFFFF}Gasolina: %d/%dL\n\n"\
        "{777777}Use: /abastecer", 
        id, 
        PostoInfo[id][pDono], 
        PostoInfo[id][pPrecoLitro], 
        PostoInfo[id][pCombustivel], 
        CAPACIDADE_MAX
    );

    // Se estiver usando Streamer (Recomendado):
    UpdateDynamic3DTextLabelText(PostoInfo[id][pLabel], -1, str_label);
    
    // SE NaO TIVER STREAMER, use a linha abaixo e apague a de cima:
    // Update3DTextLabelText(PostoInfo[id][pLabel], -1, str_label);
    
    return 1;
}

// ================= [ COMANDOS DE JOGADOR ] =================





// ================= ADMIN V32: COMANDOS COMUNS =================
CMD:admins(playerid, params[])
{
    #pragma unused params
    new msg[144], count = 0;
    SendClientMessage(playerid, 0x00BFFFFF, "===== Administradores Online =====");
    foreach(Player, i)
    {
        if(IsPlayerConnected(i) && Pdados[i][Admin] > 0)
        {
            format(msg, sizeof msg, "%s %s | IDF: %d | %s", NomeAdm(Pdados[i][Admin]), Nome(i), BCG_IDFixo[i], Pdados[i][Trabalhando] ? ("Trabalhando") : ("Modo Play"));
            SendClientMessage(playerid, 0xFFFFFFFF, msg);
            count++;
        }
    }
    if(!count) SendClientMessage(playerid, 0xAAAAAAFF, "Nenhum administrador online.");
    return 1;
}

CMD:chamaradm(playerid, params[])
{
    #pragma unused params
    if(!ADM(playerid, 1)) return 1;
    ShowPlayerDialog(playerid, 19870, DIALOG_STYLE_MSGBOX, "Império Roleplay - Comandos Administrativos",
    "GERAL: /admins /deus /chamaradm /aviso /limparchat\nPLAYER (ID FIXO): /ir /trazer /reviver /kick /ban /tv /mostrarrg\nCONTROLE: /congelar /descongelar /slap /setinterior /setvw\nSTATUS: /vida /colete /skin /dararma /tirararma /dargrana /removergrana\nVEICULO: /repararv /virarv /respawn\nGESTAO: /darvip /tirarvip /daradmin /darlider /rlider\n\nAdmins 1-7 precisam estar em modo trabalho. Admin 8 pode usar em modo play.\nComandos de jogador usam ID FIXO.", "Fechar", "");
    return 1;
}

CMD:pix(playerid, params[])
{
    if(!Pdados[playerid][Logado])
        return SendClientMessage(playerid, VERMELHO, "[PIX] Voce precisa estar logado para usar o PIX.");

    new idf, alvo;
    if(sscanf(params, "i", idf))
        return SendClientMessage(playerid, AZUL_CLARO, "Use: /pix [ID do jogador]");

    alvo = BCG_BuscarPorIDFixo(idf);
    if(alvo == INVALID_PLAYER_ID)
        return SendClientMessage(playerid, VERMELHO, "[PIX] ID fixo offline ou inexistente.");

    if(alvo == playerid)
        return SendClientMessage(playerid, VERMELHO, "[PIX] Voce nao pode enviar PIX para voce mesmo.");

    PixDestino[playerid] = alvo;

    new nomeDestino[MAX_PLAYER_NAME], texto[192];
    GetPlayerName(alvo, nomeDestino, sizeof(nomeDestino));
    format(texto, sizeof(texto),
        "Destinatario: {00FF00}%s {FFFFFF}(ID %d)\n\nSeu saldo bancario: {00FF00}R$ %d\n\nDigite o valor que deseja enviar:",
        nomeDestino, idf, Pdados[playerid][Banco]);

    ShowPlayerDialog(playerid, DIALOG_BCG_PIX_VALOR, DIALOG_STYLE_INPUT,
        "{00FF00}PIX BCG", texto, "Enviar", "Cancelar");
    return 1;
}

CMD:congelar(playerid, params[])
{
    if(!ADM(playerid, 1)) return 1;
    new idf, id, msg[144];
    if(sscanf(params, "i", idf)) return SendClientMessage(playerid, -1, "Use: /congelar [ID FIXO]");
    id = BCG_BuscarPorIDFixo(idf);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "[ADMIN] ID fixo offline ou inexistente.");
    TogglePlayerControllable(id, false);
    format(msg, sizeof msg, "[ADMIN] %s [IDF:%d] foi congelado.", Nome(id), idf); SendClientMessage(playerid, 0x00BFFFFF, msg);
    SendClientMessage(id, 0xFF4040FF, "[ADMIN] Voce foi congelado por um administrador.");
    return 1;
}

CMD:descongelar(playerid, params[])
{
    if(!ADM(playerid, 1)) return 1;
    new idf, id, msg[144];
    if(sscanf(params, "i", idf)) return SendClientMessage(playerid, -1, "Use: /descongelar [ID FIXO]");
    id = BCG_BuscarPorIDFixo(idf);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "[ADMIN] ID fixo offline ou inexistente.");
    TogglePlayerControllable(id, true);
    format(msg, sizeof msg, "[ADMIN] %s [IDF:%d] foi descongelado.", Nome(id), idf); SendClientMessage(playerid, 0x00BFFFFF, msg);
    SendClientMessage(id, 0x40FF40FF, "[ADMIN] Voce foi descongelado por um administrador.");
    return 1;
}

CMD:slap(playerid, params[])
{
    if(!ADM(playerid, 2)) return 1;
    new idf, id; new Float:x, Float:y, Float:z;
    if(sscanf(params, "i", idf)) return SendClientMessage(playerid, -1, "Use: /slap [ID FIXO]");
    id = BCG_BuscarPorIDFixo(idf);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "[ADMIN] ID fixo offline ou inexistente.");
    GetPlayerPos(id, x, y, z); SetPlayerPos(id, x, y, z + 4.0); SetPlayerHealth(id, 90.0);
    SendClientMessage(playerid, 0x00BFFFFF, "[ADMIN] Slap aplicado.");
    return 1;
}

CMD:setinterior(playerid, params[])
{
    if(!ADM(playerid, 3)) return 1;
    new idf, interior, id;
    if(sscanf(params, "ii", idf, interior)) return SendClientMessage(playerid, -1, "Use: /setinterior [ID FIXO] [INTERIOR]");
    id = BCG_BuscarPorIDFixo(idf);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "[ADMIN] ID fixo offline ou inexistente.");
    SetPlayerInterior(id, interior); SendClientMessage(playerid, 0x00BFFFFF, "[ADMIN] Interior alterado.");
    return 1;
}

CMD:setvw(playerid, params[])
{
    if(!ADM(playerid, 3)) return 1;
    new idf, vw, id;
    if(sscanf(params, "ii", idf, vw)) return SendClientMessage(playerid, -1, "Use: /setvw [ID FIXO] [VIRTUAL WORLD]");
    id = BCG_BuscarPorIDFixo(idf);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "[ADMIN] ID fixo offline ou inexistente.");
    SetPlayerVirtualWorld(id, vw); SendClientMessage(playerid, 0x00BFFFFF, "[ADMIN] Virtual World alterado.");
    return 1;
}

CMD:repararv(playerid, params[])
{
    #pragma unused params
    if(!ADM(playerid, 1)) return 1;
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "[ADMIN] Entre em um veiculo.");
    RepairVehicle(GetPlayerVehicleID(playerid)); SendClientMessage(playerid, 0x40FF40FF, "[ADMIN] Veiculo reparado."); return 1;
}

CMD:virarv(playerid, params[])
{
    #pragma unused params
    if(!ADM(playerid, 1)) return 1;
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "[ADMIN] Entre em um veiculo.");
    new v=GetPlayerVehicleID(playerid); new Float:x,Float:y,Float:z,Float:a;
    GetVehiclePos(v,x,y,z); GetVehicleZAngle(v,a); SetVehiclePos(v,x,y,z+1.0); SetVehicleZAngle(v,a);
    SendClientMessage(playerid, 0x40FF40FF, "[ADMIN] Veiculo desvirado."); return 1;
}

CMD:jetpack(playerid, params[])
{
    #pragma unused params
    if(!ADM(playerid, 4)) return 1;
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK); SendClientMessage(playerid, 0x00BFFFFF, "[ADMIN] Jetpack ativado."); return 1;
}
// ================= FIM ADMIN V32 =================

CMD:abastecer(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, VERMELHO, "[POSTO] Voce precisa estar em um veiculo.");
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, VERMELHO, "[POSTO] Apenas o motorista pode abastecer.");

    new id = PostoProximo(playerid, 8.0);
    if(id == -1)
        return SendClientMessage(playerid, VERMELHO, "[POSTO] Voce precisa estar dentro de um posto de gasolina.");

    new litros;
    if(sscanf(params, "d", litros))
        return SendClientMessage(playerid, -1, "Use: /abastecer [litros]");
    if(litros <= 0)
        return SendClientMessage(playerid, VERMELHO, "[POSTO] Informe uma quantidade valida de litros.");

    new vehicleid = GetPlayerVehicleID(playerid);
    new combustivelAtual = GasolinaVeiculo[vehicleid];
    if(combustivelAtual < 0) combustivelAtual = 0;
    if(combustivelAtual >= MAX_COMBUSTIVEL)
        return SendClientMessage(playerid, AMARELO, "[POSTO] Seu tanque ja esta cheio.");

    new espaco = MAX_COMBUSTIVEL - combustivelAtual;
    if(litros > espaco) litros = espaco;
    if(litros > PostoInfo[id][pCombustivel]) litros = PostoInfo[id][pCombustivel];
    if(litros <= 0)
        return SendClientMessage(playerid, VERMELHO, "[POSTO] Este posto esta sem combustivel.");

    new custo = litros * PostoInfo[id][pPrecoLitro];
    if(GetPlayerMoney(playerid) < custo)
        return SendClientMessage(playerid, VERMELHO, "[POSTO] Voce nao possui dinheiro suficiente.");

    GivePlayerMoney(playerid, -custo);
    GasolinaVeiculo[vehicleid] = combustivelAtual + litros;
    PostoInfo[id][pCombustivel] -= litros;
    PostoInfo[id][pLucro] += custo;
    SalvarPosto(id);
    AtualizarPosto(id);

    new msg[160];
    format(msg, sizeof(msg), "{00FF00}[POSTO] {FFFFFF}Voce abasteceu {FFFF00}%dL {FFFFFF}por {00FF00}$%d{FFFFFF}. Tanque: {00FF00}%d%%.", litros, custo, GasolinaVeiculo[vehicleid]);
    SendClientMessage(playerid, -1, msg);
    return 1;
}

CMD:comprarposto(playerid, params[]) {
    new id_compra = -1;
    for(new i = 0; i < MAX_POSTOS; i++) {
        if(PostoInfo[i][pCriado] && IsPlayerInRangeOfPoint(playerid, 5.0, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ])) { 
            id_compra = i; break; 
        }
    }
    
    if(id_compra == -1) return SendClientMessage(playerid, VERMELHO, "Nao ha postos aqui.");
    if(strcmp(PostoInfo[id_compra][pDono], "Estado", true) != 0) return SendClientMessage(playerid, VERMELHO, "Ja tem dono!");
    if(GetPlayerMoney(playerid) < PRECO_COMPRA_BASE) return SendClientMessage(playerid, VERMELHO, "Sem dinheiro!");

    GivePlayerMoney(playerid, -PRECO_COMPRA_BASE);
    format(PostoInfo[id_compra][pDono], MAX_PLAYER_NAME, Nome(playerid));
    Pdados[playerid][pDonoPostoID] = id_compra; 
    
    SalvarPosto(id_compra);
    SalvarDados(playerid);
    AtualizarPosto(id_compra);
    return SendClientMessage(playerid, VERDE, "Posto comprado com sucesso!");
}

// ================= [ COMANDOS STAFF (LIPEE_FXP1) ] =================

CMD:criarposto(playerid, params[]) {
    if(!(ADM(playerid, 8))) return 1;
    
    new preco_l;
    if(sscanf(params, "d", preco_l)) return SendClientMessage(playerid, -1, "Uso: /criarposto [Preco do Litro]");
    
    for(new i = 0; i < MAX_POSTOS; i++) {
        if(!PostoInfo[i][pCriado]) {
            GetPlayerPos(playerid, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ]);
            
            format(PostoInfo[i][pDono], MAX_PLAYER_NAME, "Estado");
            PostoInfo[i][pPrecoLitro] = preco_l; 
            PostoInfo[i][pCombustivel] = 5000; 
            PostoInfo[i][pLucro] = 0;
            PostoInfo[i][pCriado] = true;
            
            // Cria o Pickup
            PostoInfo[i][pPickup] = CreatePickup(1239, 1, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ], -1);
            
            // Cria o Label com um texto temporario (o AtualizarPosto vai mudar ele em seguida)
            PostoInfo[i][pLabel] = CreateDynamic3DTextLabel("Carregando posto...", -1, PostoInfo[i][pPosX], PostoInfo[i][pPosY], PostoInfo[i][pPosZ]+1.5, 25.0);
            
            // AQUI ESTa O SEGREDO: Chama a funcao que monta o texto completo
            AtualizarPosto(i); 
            
            SalvarPosto(i); 
            SendClientMessage(playerid, VERDE, "Posto criado com sucesso!");
            return 1;
        }
    }
    return 1;
}

CMD:deletarposto(playerid, params[]) {
    if(!(ADM(playerid, 8))) return 1;
    
    new id_del;
    if(sscanf(params, "d", id_del)) return SendClientMessage(playerid, -1, "Uso: /deletarposto [ID]");
    if(id_del < 0 || id_del >= MAX_POSTOS || !PostoInfo[id_del][pCriado]) return SendClientMessage(playerid, VERMELHO, "ID invalido.");

    DestroyPickup(PostoInfo[id_del][pPickup]);
    Delete3DTextLabel(PostoInfo[id_del][pLabel]);
    
    new path[64];
    format(path, sizeof(path), PASTA_POSTOS, id_del);
    DOF2_RemoveFile(path);
    
    PostoInfo[id_del][pCriado] = false;
    return SendClientMessage(playerid, VERDE, "Posto deletado permanentemente!");
}

CMD:setarestoque(playerid, params[]) {
    if(!(ADM(playerid, 8))) return 1;
    
    new id_est, valor_est;
    if(sscanf(params, "dd", id_est, valor_est)) return SendClientMessage(playerid, -1, "Uso: /setarestoque [ID] [Quantidade]");
    if(!PostoInfo[id_est][pCriado]) return SendClientMessage(playerid, VERMELHO, "Posto nao existe.");
    
    PostoInfo[id_est][pCombustivel] = valor_est;
    SalvarPosto(id_est);
    AtualizarPosto(id_est);
    return SendClientMessage(playerid, VERDE, "Estoque alterado!");
}

CMD:savefiles(playerid, params[]) {
    if(!(ADM(playerid, 8))) return 1;
    for(new i = 0; i < MAX_POSTOS; i++) if(PostoInfo[i][pCriado]) SalvarPosto(i);
    return SendClientMessage(playerid, VERDE, "Arquivos de postos salvos!");
}

// ================= [ COMANDOS LOGISTICA ] =================




// ================= [ COMANDOS STAFF ADICIONAIS ] =================

CMD:mudarpreco(playerid, params[]) {
    if(!(ADM(playerid, 8))) return 1;

    new id_preco, novo_v;
    if(sscanf(params, "dd", id_preco, novo_v)) return SendClientMessage(playerid, -1, "Uso: /mudarpreco [ID] [Novo Preco]");
    if(id_preco < 0 || id_preco >= MAX_POSTOS || !PostoInfo[id_preco][pCriado]) return SendClientMessage(playerid, VERMELHO, "ID invalido.");

    PostoInfo[id_preco][pPrecoLitro] = novo_v;
    
    SalvarPosto(id_preco);
    AtualizarPosto(id_preco);
    
    new str_p[128];
    format(str_p, sizeof(str_p), "{00FF00}[BCG]: {FFFFFF}Preco do posto ID %d alterado para $%d.", id_preco, novo_v);
    SendClientMessage(playerid, -1, str_p);
    return 1;
}

CMD:mudardono(playerid, params[]) {
    if(!(ADM(playerid, 8))) return 1;

    new id_p_dono, novo_dono[MAX_PLAYER_NAME];
    if(sscanf(params, "ds[24]", id_p_dono, novo_dono)) return SendClientMessage(playerid, -1, "Uso: /mudardono [ID] [Nome_do_Dono]");
    if(id_p_dono < 0 || id_p_dono >= MAX_POSTOS || !PostoInfo[id_p_dono][pCriado]) return SendClientMessage(playerid, VERMELHO, "ID invalido.");

    // Atualiza o nome do dono no posto
    format(PostoInfo[id_p_dono][pDono], MAX_PLAYER_NAME, novo_dono);
    
    SalvarPosto(id_p_dono);
    AtualizarPosto(id_p_dono);

    new str_d[128];
    format(str_d, sizeof(str_d), "{00FF00}[BCG]: {FFFFFF}O dono do posto ID %d agora e: %s.", id_p_dono, novo_dono);
    SendClientMessage(playerid, -1, str_d);
    return 1;
}
CMD:ajudaposto(playerid, params[])
{
    new msg[500];
    strcat(msg, "{00BFFF}--- AJUDA SISTEMA DE POSTOS ---\n\n");
    strcat(msg, "{FFFFFF}/comprarposto - {777777}Compra o posto onde voce esta.\n");
    strcat(msg, "{FFFFFF}/abastecer [quantidade] - {777777}Abastece seu veiculo.\n");
    strcat(msg, "{FFFFFF}/tabletp - {777777}Abre o painel do dono (se voce for um).\n");
    strcat(msg, "{FFFFFF}/abastecerposto - {777777}Carrega o caminhao na refinaria.\n");
    strcat(msg, "{FFFFFF}/descarregar - {777777}Leva a gasolina ate um posto.\n");
    
    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "{00BFFF}Ajuda: Postos", msg, "Fechar", "");
    return 1;
}
CMD:painelposto(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;

    new lista[400];
    strcat(lista, "Criar Posto (Posicao atual)\n");
    strcat(lista, "Deletar Posto (Por ID)\n");
    strcat(lista, "Setar Estoque\n");
    strcat(lista, "Mudar Preco\n");
    strcat(lista, "Mudar Dono\n");
    strcat(lista, "Salvar Todos os Arquivos");

    ShowPlayerDialog(playerid, 2500, DIALOG_STYLE_LIST, "{FF0000}Painel Admin: Postos", lista, "Selecionar", "Fechar");
    return 1;
}

CMD:tabletp(playerid, params[])
{
    new id = Pdados[playerid][pDonoPostoID];
    if(id == -1) return SendClientMessage(playerid, VERMELHO, "Voce nao possui nenhum posto!");

    new msg[400];
    format(msg, sizeof(msg), 
        "{FFFFFF}Informacoes do Posto ID #%d\n\n"\
        "{FFFFFF}Estoque: {FFFF00}%d / %d L\n"\
        "{FFFFFF}Lucro p/ Sacar: {00FF00}$%d\n"\
        "{FFFFFF}Preco Atual: {00FF00}$%d/L", 
        id, PostoInfo[id][pCombustivel], CAPACIDADE_MAX, PostoInfo[id][pLucro], PostoInfo[id][pPrecoLitro]);

    // O primeiro botao agora e "Sacar Lucro"
    ShowPlayerDialog(playerid, 2501, DIALOG_STYLE_MSGBOX, "{00BFFF}Tablet: Gerenciamento", msg, "Sacar Lucro", "Fechar");
    return 1;
}

CMD:sacarlucro(playerid, params[])
{
    new id = Pdados[playerid][pDonoPostoID];

    if(id == -1) return SendClientMessage(playerid, VERMELHO, "Voce nao e dono de um posto.");
    
    // Verifica se ele esta perto do posto dele
    if(!IsPlayerInRangeOfPoint(playerid, 5.0, PostoInfo[id][pPosX], PostoInfo[id][pPosY], PostoInfo[id][pPosZ]))
    {
        return SendClientMessage(playerid, VERMELHO, "Voce precisa estar no seu posto para sacar o lucro!");
    }

    if(PostoInfo[id][pLucro] <= 0)
    {
        return SendClientMessage(playerid, VERMELHO, "Nao ha lucro acumulado para sacar.");
    }

    new valor = PostoInfo[id][pLucro];
    
    // Da o dinheiro pro player
    GivePlayerMoney(playerid, valor);
    
    // Zera o lucro do posto
    PostoInfo[id][pLucro] = 0;
    
    // Salva o arquivo do posto pra nao ter bug de duplicar grana
    SalvarPosto(id);
    AtualizarPosto(id);

    new str[128];
    format(str, sizeof(str), "{00FF00}[POSTO]: {FFFFFF}Voce sacou {00FF00}$%d {FFFFFF}de lucro do seu posto!", valor);
    SendClientMessage(playerid, -1, str);
    return 1;
}
CMD:bcgt(playerid, params[])
{
    // Apenas informativo, ja que o sistema esta em KM/H fixo no calculo
    SendClientMessage(playerid, -1, "O velocimetro BCG opera em KM/H.");
    return 1;
}



stock SalvarGaragem(id)
{
    new arquivo[64];
    format(arquivo, sizeof(arquivo), "Garagens/Garagem_%d.ini", id);
    if(!DOF2_FileExists(arquivo)) DOF2_CreateFile(arquivo);

    DOF2_SetFloat(arquivo, "PosX", GaragemInfo[id][gPosX]);
    DOF2_SetFloat(arquivo, "PosY", GaragemInfo[id][gPosY]);
    DOF2_SetFloat(arquivo, "PosZ", GaragemInfo[id][gPosZ]);
    DOF2_SetBool(arquivo, "Criada", true);
    DOF2_SaveFile();
    return 1;
}

stock CarregarGaragens()
{
    for(new i = 0; i < MAX_GARAGENS; i++)
    {
        new arquivo[64];
        format(arquivo, sizeof(arquivo), "Garagens/Garagem_%d.ini", i);
        if(DOF2_FileExists(arquivo))
        {
            GaragemInfo[i][gPosX] = DOF2_GetFloat(arquivo, "PosX");
            GaragemInfo[i][gPosY] = DOF2_GetFloat(arquivo, "PosY");
            GaragemInfo[i][gPosZ] = DOF2_GetFloat(arquivo, "PosZ");
            GaragemInfo[i][gCriada] = true;

            GaragemInfo[i][gPickup] = CreatePickup(1239, 1, GaragemInfo[i][gPosX], GaragemInfo[i][gPosY], GaragemInfo[i][gPosZ], -1);
            
            new str[64];
            format(str, sizeof(str), "{FFFF00}Garagem BCG #%d\n{FFFFFF}Use: /garagem", i);
            GaragemInfo[i][gLabel] = CreateDynamic3DTextLabel(str, -1, GaragemInfo[i][gPosX], GaragemInfo[i][gPosY], GaragemInfo[i][gPosZ]+0.5, 20.0);
        }
    }
    return 1;
}

stock VerificarFlood(playerid)
{
    msgs[playerid]++;
    SetTimerEx("Flood", 5000, false, "i", playerid);

    if(msgs[playerid] == 3) {
        SendClientMessage(playerid, VERMELHO, "[AVISO]: Evite o flood. Aguarde 5 segundos.");
        return 0; 
    }
    if(msgs[playerid] >= 4) {
        new str[128];
        format(str, sizeof(str), "Anticheat: %s foi kickado por flood no chat.", Nome(playerid));
        MsgAdm(str);
        Kick(playerid);
        return 1;
    }
    return 0;
}
CMD:agendarcoins(playerid, params[])
{
    new nomeAdmin[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nomeAdmin, sizeof(nomeAdmin));
    
    if(strcmp(nomeAdmin, "Lipee_fxp1", true) != 0)
    {
        return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Apenas o fundador Lipee_fxp1 pode usar este comando.");
    }

    new id_procurado, quantia, codigo[32];
    if(sscanf(params, "iis[32]", id_procurado, quantia, codigo)) 
    {
        return SendClientMessage(playerid, -1, "{AFAFAF}Use: /agendarcoins [IDF] [Quantidade] [Codigo]");
    }

    // --- BUSCA PELO ID ---
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Jogador offline.");

    // Grava na memoria interna usando o ID real do servidor (id)
    PlayerAgendamento[id][agAtivo] = true;
    PlayerAgendamento[id][agParaID] = id;
    PlayerAgendamento[id][agQuantidade] = quantia;
    format(PlayerAgendamento[id][agCodigo], 32, codigo);

    // Obtem o nome do jogador alvo para criar o arquivo personalizado
    new nomeAlvo[MAX_PLAYER_NAME], diretorio[64];
    GetPlayerName(id, nomeAlvo, sizeof(nomeAlvo));
    format(diretorio, sizeof(diretorio), "CoinsAgendados/%s.txt", nomeAlvo);

    // Cria o arquivo e salva as informacoes via DOF2
    if(!DOF2_FileExists(diretorio)) DOF2_CreateFile(diretorio);
    
    DOF2_SetInt(diretorio, "Quantidade", quantia);
    DOF2_SetString(diretorio, "Codigo", codigo);
    DOF2_SaveFile();

    // Feedback visual
    new str[256];
    format(str, sizeof(str), "{FFFFFF}ID do Alvo: {FFFF00}%d\n{FFFFFF}Jogador: {FFFF00}%s\n{FFFFFF}Quantidade: {00FF00}%d Coins\n{FFFFFF}Codigo: {00FFFF}%s\n\n{FFFFFF}Salvo em arquivo com sucesso!", id_procurado, nomeAlvo, quantia, codigo);
    ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_MSGBOX, "{FF0000}[INFO] Agendamento Gravado", str, "Fechar", "");

    SendClientMessage(id, -1, "{00FF00}[Loja]:{FFFFFF} Um pacote de Coins foi agendado e salvo para voce!");
    return 1;
}


CMD:darcoins(playerid, params[])
{
    // 1. Verificacao de Seguranca por Nome
    new pName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName, sizeof(pName));

    if(strcmp(pName, "Lipee_fxp1", true) != 0)
    {
        return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Apenas o administrador Lipee_fxp1 pode usar este comando.");
    }

    // 2. Parametros do Comando
    new id_procurado, quantidade;
    if(sscanf(params, "ii", id_procurado, quantidade)) // Mudado de 'u' para 'i' para receber o ID numerico
    {
        return SendClientMessage(playerid, -1, "{A9A9A9}[Uso]:{FFFFFF} /darcoins [IDF] [Quantidade]");
    }

    // 3. BUSCA PELO ID
    new id = INVALID_PLAYER_ID;
    id = BCG_BuscarPorIDFixo(id_procurado);
    if(id == INVALID_PLAYER_ID)
    {
        return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Jogador nao encontrado/online.");
    }

    if(quantidade <= 0)
    {
        return SendClientMessage(playerid, -1, "{FF0000}[Erro]:{FFFFFF} Insira uma quantidade valida de coins.");
    }

    // 4. Aplicacao dos Coins usando o ID real localizado
    Pdados[id][Coins] += quantidade;

    // Salva imediatamente na conta do alvo correto
    SalvarDados(id);

    // 5. Mensagens de Feedback
    new strAdmin[128], strTarget[128], targetName[MAX_PLAYER_NAME];
    GetPlayerName(id, targetName, sizeof(targetName));

    format(strAdmin, sizeof(strAdmin), "{00FF00}[Coins]:{FFFFFF} Voce deu %d coins para o jogador %s.", quantidade, targetName);
    SendClientMessage(playerid, -1, strAdmin);

    format(strTarget, sizeof(strTarget), "{00FF00}[Coins]:{FFFFFF} O administrador Lipee_fxp1 lhe deu %d coins.", quantidade);
    SendClientMessage(id, -1, strTarget);

    return 1;
}

stock AbrirMenuItens1(playerid)
{
    new str[3000];
    str[0] = '\0';
    strcat(str, "Item\tValor\tPromocional\n");
    strcat(str, "{FF8000}Comprar Dinheiro (Menu de Compra)\t-\t-\n");
    strcat(str, "{FF8000}Comprar Armas (Menu de Compra)\t-\t-\n");
    strcat(str, "1. Encher Vida\t{00FF00}2c\t-\n");
    strcat(str, "2. Encher Colete\t{00FF00}2c\t-\n");
    strcat(str, "3. Encher o Tanque\t{00FF00}1c\t-\n");
    strcat(str, "4. Sair do Emprego\t{00FF00}1c\t-\n");
    strcat(str, "5. Reparar Veiculo\t{00FF00}1c\t-\n");
    strcat(str, "6. Anuncio Personalizado\t{00FF00}1c\t-\n");
    strcat(str, "7. Limpar Ficha Criminal\t{00FF00}15c\t-\n");
    strcat(str, "8. Blindar Veiculo\t{00FF00}2c\t-\n");
    strcat(str, "9. Sair da Cadeia (COP)\t{00FF00}5c\t-\n");
    strcat(str, "10. Troca de Senha\t{00FF00}5c\t-\n");
    strcat(str, "11. Troca de Nick\t{00FF00}20c\t-\n");
    strcat(str, "12. Limpar Aviso Conta\t{00FF00}20c\t-\n");
    strcat(str, "13. Comprar Todas Licencas\t{00FF00}5c\t-\n");
    strcat(str, "14. Titulo Personalizado\t{00FF00}15c\t-\n");
    strcat(str, "15. Sair da Cadeia (ADM)\t{00FF00}10c\t-\n");
    strcat(str, "16. Portao\t{00FF00}20c\t-\n");
    strcat(str, "17. Caixa de Itens\t{00FF00}20c\t-\n");
    strcat(str, "18. Tunagem Temporaria\t{00FF00}2c\t-\n");
    strcat(str, "19. Tunagem Permanente\t{00FF00}4c\t-\n");
    strcat(str, "20. {FFFF00}>> PROXIMA PAGINA\t-\t-");

    ShowPlayerDialog(playerid, DIALOG_LOJA_ITENS_1, DIALOG_STYLE_TABLIST_HEADERS, "{FF0000}[BCG 4] {FFFFFF}Itens por Coins", str, "Comprar", "Voltar");
    return 1;
}

stock AbrirMenuItens2(playerid)
{
    new str[3000];
    str[0] = '\0';
    strcat(str, "Item\tValor\tPromocional\n");
    strcat(str, "12. Limpar Aviso Conta\t{00FF00}20c\t-\n");
    strcat(str, "13. Comprar Todas Licencas\t{00FF00}5c\t-\n");
    strcat(str, "14. Titulo Personalizado\t{00FF00}15c\t-\n");
    strcat(str, "15. Sair da Cadeia (ADM)\t{00FF00}10c\t-\n");
    strcat(str, "16. Portao\t{00FF00}20c\t-\n");
    strcat(str, "17. Caixa de Itens\t{00FF00}20c\t-\n");
    strcat(str, "18. Tunagem Temporaria\t{00FF00}2c\t-\n");
    strcat(str, "19. Tunagem Permanente\t{00FF00}4c\t-\n");
    strcat(str, "20. 50 horas cravado\t{00FF00}20c\t-\n");
    strcat(str, "21. Grafite\t{00FF00}15c\t-\n");
    strcat(str, "22. Limpar Historico Criminal\t{00FF00}20c\t-\n");
    strcat(str, "23. Sair Black List\t{00FF00}20c\t-\n");
    strcat(str, "24. Caixa de Som JBL\t{00FF00}30c\t-\n");
    strcat(str, "25. Numero Personalizado\t{00FF00}30c\t-\n");
    strcat(str, "26. Sair ORG sem Black\t{00FF00}25c\t-\n");
    strcat(str, "27. Remover Farda Cassada\t{00FF00}100c\t-\n");
    strcat(str, "28. +1 Slot de Inventario\t{00FF00}10c\t-\n");
    strcat(str, "29. Abrir Race\t{00FF00}5c\t-\n");
    strcat(str, "30. Abrir Derby\t{00FF00}5c\t-\n");
    strcat(str, "76. Desvincular Discord\t{00FF00}100c\t-\n");
    strcat(str, "77. Abrir Bomb TAG\t{00FF00}5c\t-");

    ShowPlayerDialog(playerid, DIALOG_LOJA_ITENS_2, DIALOG_STYLE_TABLIST_HEADERS, "{FF0000}[BCG] {FFFFFF}Itens por Coins", str, "Comprar", "Voltar");
    return 1;
}


forward TimerControleJBL();
public TimerControleJBL()
{
    new Float:jblX, Float:jblY, Float:jblZ;

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;

        new bool:pertoDeAlgumaJBL = false;
        new idDonoJBL = -1;

        // Varre todas as JBLs do servidor para ver se tem alguma perto do jogador 'i'
        for(new idxDono = 0; idxDono < MAX_PLAYERS; idxDono++)
        {
            if(ObjetoJBL[idxDono] != INVALID_OBJECT_ID && JBLLigada[idxDono] == true)
            {
                GetObjectPos(ObjetoJBL[idxDono], jblX, jblY, jblZ);
                
                JBLPos[idxDono][0] = jblX;
                JBLPos[idxDono][1] = jblY;
                JBLPos[idxDono][2] = jblZ;

                // Se o jogador 'i' estiver no raio de 35 metros da caixa do 'idxDono'
                if(IsPlayerInRangeOfPoint(i, 35.0, jblX, jblY, jblZ))
                {
                    pertoDeAlgumaJBL = true;
                    idDonoJBL = idxDono;
                    break; // Encontrou a caixa mais proxima dele, para o loop interno
                }
            }
        }

        // CASO 1: Ele esta perto da JBL e NaO estava ouvindo antes (Acabou de entrar no raio ou voltou para perto)
        if(pertoDeAlgumaJBL == true && OuvindoJBL[i] == false)
        {
            // Da o play novamente. No mobile, isso forca o canal de audio 3D a conectar de onde a musica esta agora
            PlayAudioStreamForPlayer(i, LinkJBL[idDonoJBL], JBLPos[idDonoJBL][0], JBLPos[idDonoJBL][1], JBLPos[idDonoJBL][2], 35.0, 1);
            OuvindoJBL[i] = true;
        }
        
        // CASO 2: Ele estava ouvindo, mas se afastou (Ficou a mais de 35 metros da caixa)
        else if(pertoDeAlgumaJBL == false && OuvindoJBL[i] == true)
        {
            // Limpa o canal de audio do jogador para ele nao ouvir nada longe dali
            StopAudioStreamForPlayer(i);
            OuvindoJBL[i] = false; // Permite que quando ele voltar, o CASO 1 seja executado de novo
        }
    }
    return 1;
}
CMD:abrirportao(playerid, params[])
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "[Uso]: /abrirportao [Senha]");

    new idProximo = -1;
    new Float:menorDistancia = 8.0; // Raio maximo de deteccao

    // Varre a array para achar qual portao esta fisicamente perto do player
    for(new p = 0; p < MAX_PORTOES_SERVIDO; p++)
    {
        if(PortaoInfo[p][pCriado] == true)
        {
            if(IsPlayerInRangeOfPoint(playerid, menorDistancia, PortaoInfo[p][pX], PortaoInfo[p][pY], PortaoInfo[p][pZ]))
            {
                idProximo = p;
                break; // Encontrou o portao correto
            }

        }
    }

    if(idProximo == -1) return SendClientMessage(playerid, 0xFF0000FF, "[Erro]: Voce nao esta perto de nenhum portao eletronico.");

    // Valida a senha do portao encontrado
    if(strcmp(params, PortaoInfo[idProximo][pSenha], false) == 0)
    {
        MoveObject(PortaoInfo[idProximo][pObjetoID], PortaoInfo[idProximo][pX], PortaoInfo[idProximo][pY], PortaoInfo[idProximo][pZ] - 5.0, 3.5, PortaoInfo[idProximo][pRotX], PortaoInfo[idProximo][pRotY], PortaoInfo[idProximo][pRotZ]);

        // Aviso no chat para todos: quem abriu e qual portao foi utilizado.
        new nomeJogador[MAX_PLAYER_NAME], avisoPortao[160];
        GetPlayerName(playerid, nomeJogador, sizeof(nomeJogador));
        format(avisoPortao, sizeof(avisoPortao), "{FFFFFF}%s abriu o portao ID %d. Dono: %s.", nomeJogador, idProximo, PortaoInfo[idProximo][pDono]);
        SendClientMessageToAll(0xFFFFFFFF, avisoPortao);

        SendClientMessage(playerid, 0x00FF00FF, "[Portao]: Senha correta! Fechando em 7 segundos.");

        // Configura qual ID o timer deve fechar
        SetTimerEx("FecharPortaoDinamico", 7000, false, "d", idProximo);
    }
    else
    {
        SendClientMessage(playerid, 0xFF0000FF, "[Portao]: Senha incorreta.");
    }
    return 1;
}

forward FecharPortaoDinamico(idp);
public FecharPortaoDinamico(idp)
{
    if(PortaoInfo[idp][pCriado] == true)
    {
        MoveObject(PortaoInfo[idp][pObjetoID], PortaoInfo[idp][pX], PortaoInfo[idp][pY], PortaoInfo[idp][pZ], 2.5, PortaoInfo[idp][pRotX], PortaoInfo[idp][pRotY], PortaoInfo[idp][pRotZ]);

        new avisoFechamento[144];
        format(avisoFechamento, sizeof(avisoFechamento), "{FFFFFF}Portao ID %d fechado. Dono: %s.", idp, PortaoInfo[idp][pDono]);
        SendClientMessageToAll(0xFFFFFFFF, avisoFechamento);
    }
    return 1;
}

forward DescontarDiasPremium();
public DescontarDiasPremium()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            new bool:atualizou = false;

            // Desconta VIP
            if(Pdados[i][pVip] > 0 && Pdados[i][pDiasVip] > 0)
            {
                Pdados[i][pDiasVip]--;
                if(Pdados[i][pDiasVip] <= 0) Pdados[i][pVip] = 0;
                atualizou = true;
            }

            // Desconta Socio
            if(Pdados[i][pSocio] > 0 && Pdados[i][pDiasSocio] > 0)
            {
                Pdados[i][pDiasSocio]--;
                if(Pdados[i][pDiasSocio] <= 0) Pdados[i][pSocio] = 0;
                atualizou = true;
            }

            // Desconta Patrocinador
            if(Pdados[i][pPatrocinador] > 0 && Pdados[i][pDiasPatrocinio] > 0)
            {
                Pdados[i][pDiasPatrocinio]--;
                if(Pdados[i][pDiasPatrocinio] <= 0) Pdados[i][pPatrocinador] = 0;
                atualizou = true;
            }

            if(atualizou) SalvarDados(i);
        }
    }
    return 1;
}
CMD:statuspremium(playerid, params[])
{
    new statusStr[400];
    format(statusStr, sizeof(statusStr), "{FFFFFF}--- Meus Planos e Beneficios Premium ---\n\n");

    // Exibicao VIP
    if(Pdados[playerid][pVip] > 0)
        format(statusStr, sizeof(statusStr), "%s{FFFFFF}Plano VIP: {00FF00}Ativo (Nivel %d) | {FFFF00}%d dias restantes\n", statusStr, Pdados[playerid][pVip], Pdados[playerid][pDiasVip]);
    else
        format(statusStr, sizeof(statusStr), "%s{FFFFFF}Plano VIP: {FF0000}Inativo\n", statusStr);

    // Exibicao SoCIO
    if(Pdados[playerid][pSocio] > 0)
        format(statusStr, sizeof(statusStr), "%s{FFFFFF}Plano Socio: {00FF00}Ativo (Nivel %d) | {FFFF00}%d dias restantes\n", statusStr, Pdados[playerid][pSocio], Pdados[playerid][pDiasSocio]);
    else
        format(statusStr, sizeof(statusStr), "%s{FFFFFF}Plano Socio: {FF0000}Inativo\n", statusStr);

    // Exibicao PATROCINADOR
    if(Pdados[playerid][pPatrocinador] > 0)
        format(statusStr, sizeof(statusStr), "%s{FFFFFF}Patrocinador: {00FF00}Ativo | {FFFF00}%d dias restantes\n", statusStr, Pdados[playerid][pDiasPatrocinio]);
    else
        format(statusStr, sizeof(statusStr), "%s{FFFFFF}Patrocinador: {FF0000}Inativo\n", statusStr);

    ShowPlayerDialog(playerid, 9945, DIALOG_STYLE_MSGBOX, "Status de Assinaturas", statusStr, "Fechar", "");
    return 1;
}
forward VerificarValidadePremium(playerid);
public VerificarValidadePremium(playerid)
{
    // Validacao do VIP
    if(Pdados[playerid][pVip] > 0 && Pdados[playerid][pDiasVip] <= 0)
    {
        Pdados[playerid][pVip] = 0;
        Pdados[playerid][pDiasVip] = 0;
        SendClientMessage(playerid, 0xFF0000FF, "[Premium]: Seu plano VIP expirou!");
        SalvarDados(playerid);
    }

    // Validacao do Socio
    if(Pdados[playerid][pSocio] > 0 && Pdados[playerid][pDiasSocio] <= 0)
    {
        Pdados[playerid][pSocio] = 0;
        Pdados[playerid][pDiasSocio] = 0;
        SendClientMessage(playerid, 0xFF0000FF, "[Premium]: Seu plano de Socio expirou!");
        SalvarDados(playerid);
    }

    // Validacao do Patrocinador
    if(Pdados[playerid][pPatrocinador] > 0 && Pdados[playerid][pDiasPatrocinio] <= 0)
    {
        Pdados[playerid][pPatrocinador] = 0;
        Pdados[playerid][pDiasPatrocinio] = 0;
        SendClientMessage(playerid, 0xFF0000FF, "[Premium]: Seu plano de Patrocinador expirou!");
        SalvarDados(playerid);
    }
    return 1;
}
CMD:entregarficha(playerid, params[])
{
    if(ccimento[playerid] != 2)
        return SendClientMessage(playerid, -1, "Voce nao tem nenhuma ficha de concreto para entregar aqui.");

    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendClientMessage(playerid, -1, "Voce precisa descer do caminhao e ir falar com o Mestre de Obras a pe.");

    if(!IsPlayerInRangeOfPoint(playerid, 4.0, Cimento_Bot_X, Cimento_Bot_Y, Cimento_Bot_Z))
        return SendClientMessage(playerid, -1, "Aproxime-se do Mestre de Obras para poder entregar os documentos.");

    ccimento[playerid] = 3; // Estado 3: Papeis em analise
    TogglePlayerControllable(playerid, 0); // Congela temporariamente

    // Anexa uma pasta de documentos na mao do jogador (Objeto 1210)
    SetPlayerAttachedObject(playerid, 9, 1210, 5, 0.10, 0.05, 0.0, -15.0, 0.0, 0.0, 1.0, 1.0, 1.0);
    
    // Animacao realista gesticulando e entregando papeis
    ApplyAnimation(playerid, "GANGS", "prtial_gngtlkD", 4.1, 1, 0, 0, 0, 0, 1);
    PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
    
    GameTextForPlayer(playerid, "~w~Conferindo Ficha...~n~~y~Aguarde 30s", CIMENTO_TEMPO_CONFERENCIA, 3);
    SendClientMessage(playerid, AZUL_CLARO, "[OBRA]: Voce entregou os documentos. Aguarde a analise da nota fiscal pelo engenheiro...");

    SetTimerEx("ValidarFichaCimento", CIMENTO_TEMPO_CONFERENCIA, false, "i", playerid);
    return 1;
}

CMD:dcimento(playerid, params[])
{
    if(ccimento[playerid] == 2 || ccimento[playerid] == 3)
        return SendClientMessage(playerid, -1, "Voce precisa primeiro validar sua ficha com o Mestre de Obras usando /entregarficha.");

    if(ccimento[playerid] != 4)
        return SendClientMessage(playerid, -1, "Voce nao tem uma carga aprovada para descarregar.");

    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        return SendClientMessage(playerid, -1, "Desca do caminhao e opere os controles externos de descarga a pe.");

    // Varredura para garantir que o caminhao esta perto
    new Float:cx, Float:cy, Float:cz, bool:caminhaoPerto = false;
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(GetVehicleModel(i) == CIMENTO_VEICULO_MODELO)
        {
            GetVehiclePos(i, cx, cy, cz);
            if(IsPlayerInRangeOfPoint(playerid, 8.0, cx, cy, cz))
            {
                caminhaoPerto = true;
                break;
            }
        }
    }

    if(!caminhaoPerto)
        return SendClientMessage(playerid, -1, "O seu caminhao de cimento precisa estar estacionado bem perto de voce!");

    ccimento[playerid] = 5; // Estado 5: Descarregando
    TogglePlayerControllable(playerid, 0);

    // Equipamentos de Seguranca Visuais (Capacete, oculos e Ferramenta)
    SetPlayerAttachedObject(playerid, 7, 18940, 2, 0.07, 0.0, 0.0, 0.0, 90.0, 90.0, 1.0, 1.0, 1.0); // Capacete
    SetPlayerAttachedObject(playerid, 8, 19011, 2, 0.08, 0.04, 0.0, 0.0, 90.0, 90.0, 1.0, 1.0, 1.0); // oculos
    SetPlayerAttachedObject(playerid, 9, 18632, 6, 0.1, 0.02, 0.0, -90.0, 0.0, 0.0, 1.0, 1.0, 1.0); // Ferramenta

    // Animacao trabalhando nas alavancas traseiras do misturador
    ApplyAnimation(playerid, "CAR", "FixBike_Loop", 4.1, 1, 0, 0, 0, 0, 1);
    
    // Efeito visual de poeira e detritos subindo no local
    CreateExplosion(Cimento_Obra_X, Cimento_Obra_Y, Cimento_Obra_Z - 1.0, 12, 0.0); 

    // Som continuo de motor a diesel trabalhando
    PlayerPlaySound(playerid, 1039, 0.0, 0.0, 0.0); 
    
    GameTextForPlayer(playerid, "~w~Descarregando Concreto...~n~~g~Valvulas Hydraulicas Abertas", CIMENTO_TEMPO_DESCARGA, 3);
    SendClientMessage(playerid, AZUL_CLARO, "[MAQUINaRIO]: Bomba de succao ativada! Injetando cimento composto na estrutura da obra...");

    SetTimerEx("TerminarDescargaCimento", CIMENTO_TEMPO_DESCARGA, false, "i", playerid);
    return 1;
}
forward ValidarFichaCimento(playerid);
public ValidarFichaCimento(playerid)
{
    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, 1);
    
    if(IsPlayerAttachedObjectSlotUsed(playerid, 9)) 
        RemovePlayerAttachedObject(playerid, 9); // Remove papel da mao

    if(ccimento[playerid] == 3)
    {
        ccimento[playerid] = 4; // Estado 4: Liberado para usar o /dcimento
        PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
        SendClientMessage(playerid, VERDE, "[M. OBRAS]: Documentacao aprovada e registrada! Va ate a lateral do caminhao e use /dcimento.");
    }
    return 1;
}

forward TerminarDescargaCimento(playerid);
public TerminarDescargaCimento(playerid)
{
    ClearAnimations(playerid);
    TogglePlayerControllable(playerid, 1);

    // Remove todos os acessorios de operario colocados temporariamente
    if(IsPlayerAttachedObjectSlotUsed(playerid, 7)) RemovePlayerAttachedObject(playerid, 7);
    if(IsPlayerAttachedObjectSlotUsed(playerid, 8)) RemovePlayerAttachedObject(playerid, 8);
    if(IsPlayerAttachedObjectSlotUsed(playerid, 9)) RemovePlayerAttachedObject(playerid, 9);

    if(ccimento[playerid] == 5)
    {
        ccimento[playerid] = 0; // Finaliza o ciclo do emprego
        PlayerPlaySound(playerid, 1147, 0.0, 0.0, 0.0); // Sirene de canteiro de obras finalizado
        
        new pagamento = CIMENTO_PAGAMENTO_BASE;
        if(Pdados[playerid][Vip] == 1)
        {
            pagamento *= 2;
            SendClientMessage(playerid, AZUL, "[VIP]: Voce recebeu bonus de 100% no seu pagamento de cimento.");
        }
        
        GivePlayerMoney(playerid, pagamento);
        
        new msg[128];
        format(msg, sizeof(msg), "[OBRA]: Descarga finalizada! Carga entregue com sucesso. Voce recebeu: R$%i.", pagamento);
        SendClientMessage(playerid, VERDE, msg);
    }
    return 1;
}
/* SampVoice callbacks desativados: dependiam de natives ausentes no include instalado. */

stock CriarCelularBase(playerid)
{
    // 0. CARCAcA FiSICA EXTERNA
    CelularCarcacaTD[playerid][0] = CreatePlayerTextDraw(playerid, 505.250, 171.500, "box");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][0], 0.000, 24.375);
    PlayerTextDrawTextSize(playerid, CelularCarcacaTD[playerid][0], 584.750, 0.000);
    PlayerTextDrawUseBox(playerid, CelularCarcacaTD[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, CelularCarcacaTD[playerid][0], 0x1A1A1CFF);

    // 1. TELA INTERNA / WALLPAPER BASE
    CelularCarcacaTD[playerid][1] = CreatePlayerTextDraw(playerid, 507.500, 174.500, "box");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][1], 0.000, 23.625);
    PlayerTextDrawTextSize(playerid, CelularCarcacaTD[playerid][1], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularCarcacaTD[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, CelularCarcacaTD[playerid][1], 0x650B0BFF);

    // 2. GRADIENTE AMBIENTAL MODERNIZADO
    CelularCarcacaTD[playerid][2] = CreatePlayerTextDraw(playerid, 507.500, 264.500, "box");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][2], 0.000, 14.625);
    PlayerTextDrawTextSize(playerid, CelularCarcacaTD[playerid][2], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularCarcacaTD[playerid][2], 1);
    PlayerTextDrawBoxColor(playerid, CelularCarcacaTD[playerid][2], 0x3D0505AA);

    // BARRA DE STATUS SUPERIOR FIXA
    CelularCarcacaTD[playerid][3] = CreatePlayerTextDraw(playerid, 510.500, 176.750, "VNA LTE");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][3], 0.075, 0.450);
    PlayerTextDrawColor(playerid, CelularCarcacaTD[playerid][3], 0xBBBBBBFF);
    PlayerTextDrawFont(playerid, CelularCarcacaTD[playerid][3], 1);

    CelularCarcacaTD[playerid][4] = CreatePlayerTextDraw(playerid, 545.000, 185.000, "CIDADE GRANDE");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][4], 0.105, 0.520);
    PlayerTextDrawColor(playerid, CelularCarcacaTD[playerid][4], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularCarcacaTD[playerid][4], 2);
    PlayerTextDrawFont(playerid, CelularCarcacaTD[playerid][4], 2);

    CelularCarcacaTD[playerid][5] = CreatePlayerTextDraw(playerid, 572.750, 176.750, "box");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][5], 0.000, 0.413);
    PlayerTextDrawTextSize(playerid, CelularCarcacaTD[playerid][5], 579.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularCarcacaTD[playerid][5], 1);
    PlayerTextDrawBoxColor(playerid, CelularCarcacaTD[playerid][5], 0x555555FF);

    CelularCarcacaTD[playerid][6] = CreatePlayerTextDraw(playerid, 573.500, 177.500, "box");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][6], 0.000, 0.262);
    PlayerTextDrawTextSize(playerid, CelularCarcacaTD[playerid][6], 578.000, 0.000);
    PlayerTextDrawUseBox(playerid, CelularCarcacaTD[playerid][6], 1);
    PlayerTextDrawBoxColor(playerid, CelularCarcacaTD[playerid][6], 0xFFFFFFFF);

    // 7. FUNDO PRETO PROTETOR DA BARRA DE NAVEGAcaO INFERIOR
    CelularCarcacaTD[playerid][7] = CreatePlayerTextDraw(playerid, 507.500, 360.500, "box");
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][7], 0.000, 2.025);
    PlayerTextDrawTextSize(playerid, CelularCarcacaTD[playerid][7], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularCarcacaTD[playerid][7], 1);
    PlayerTextDrawBoxColor(playerid, CelularCarcacaTD[playerid][7], 0x131315FF); // Preto Puro Solido

    // VISUAIS DOS BOToES INFERIORES FIXOS
    CelularCarcacaTD[playerid][8] = CreatePlayerTextDraw(playerid, 518.750, 365.750, "|||"); 
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][8], 0.112, 0.637);
    PlayerTextDrawColor(playerid, CelularCarcacaTD[playerid][8], 0xCCCCCCFF);
    PlayerTextDrawFont(playerid, CelularCarcacaTD[playerid][8], 1);

    CelularCarcacaTD[playerid][9] = CreatePlayerTextDraw(playerid, 545.000, 365.750, "O"); 
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][9], 0.135, 0.637);
    PlayerTextDrawColor(playerid, CelularCarcacaTD[playerid][9], 0xCCCCCCFF);
    PlayerTextDrawAlignment(playerid, CelularCarcacaTD[playerid][9], 2);
    PlayerTextDrawFont(playerid, CelularCarcacaTD[playerid][9], 1);

    CelularCarcacaTD[playerid][10] = CreatePlayerTextDraw(playerid, 567.500, 365.750, "<"); 
    PlayerTextDrawLetterSize(playerid, CelularCarcacaTD[playerid][10], 0.135, 0.637);
    PlayerTextDrawColor(playerid, CelularCarcacaTD[playerid][10], 0xCCCCCCFF);
    PlayerTextDrawFont(playerid, CelularCarcacaTD[playerid][10], 1);

    return 1;
}


stock CriarTelaHome(playerid)
{
    // =========================================================
    // TELA INICIAL - CIDADE GRANDE ROLEPLAY
    // Layout inspirado diretamente na referencia enviada.
    // 3 apps na primeira linha, 4 na segunda e 3 na terceira.
    // =========================================================

    // RELOGIO
    CelularHomeTD[playerid][0] = CreatePlayerTextDraw(playerid, 545.000, 195.000, "22:44");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][0], 0.300, 1.125);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][0], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][0], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][0], 3);

    // MARCA DA CIDADE NO FUNDO
    CelularHomeTD[playerid][1] = CreatePlayerTextDraw(playerid, 545.000, 213.000, "CIDADE GRANDE");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][1], 0.145, 0.700);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][1], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][1], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][1], 2);

    CelularHomeTD[playerid][2] = CreatePlayerTextDraw(playerid, 545.000, 226.000, "ROLEPLAY");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][2], 0.080, 0.450);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][2], 0xD6D6D6FF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][2], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][2], 1);

    // ESTRELAS DECORATIVAS
    CelularHomeTD[playerid][3] = CreatePlayerTextDraw(playerid, 545.000, 236.000, "*****");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][3], 0.105, 0.520);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][3], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][3], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][3], 2);

    // =========================================================
    // APLICATIVOS - LINHA 1 (3)
    // =========================================================

    // WHATSAPP
    CelularHomeTD[playerid][4] = CreatePlayerTextDraw(playerid, 514.000, 250.000, "LD_CHAT:goodcha");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][4], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][4], 12.000, 12.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][4], 0x19C463FF);
    CelularHomeTD[playerid][5] = CreatePlayerTextDraw(playerid, 520.000, 263.000, "WHATSAPP");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][5], 0.050, 0.330);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][5], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][5], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][5], 1);

    // S.O.S.
    CelularHomeTD[playerid][6] = CreatePlayerTextDraw(playerid, 538.000, 250.000, "LD_CHAT:goodcha");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][6], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][6], 12.000, 12.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][6], 0xD33A32FF);
    CelularHomeTD[playerid][7] = CreatePlayerTextDraw(playerid, 544.000, 263.000, "S.O.S.");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][7], 0.050, 0.330);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][7], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][7], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][7], 1);

    // GPS
    CelularHomeTD[playerid][8] = CreatePlayerTextDraw(playerid, 562.000, 250.000, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][8], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][8], 12.000, 12.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][8], 0xE94B3CFF);
    CelularHomeTD[playerid][9] = CreatePlayerTextDraw(playerid, 568.000, 263.000, "GPS");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][9], 0.050, 0.330);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][9], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][9], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][9], 1);

    // =========================================================
    // APLICATIVOS - LINHA 2 (4)
    // =========================================================

    // BANCO
    CelularHomeTD[playerid][10] = CreatePlayerTextDraw(playerid, 510.000, 280.000, "LD_CHAT:goodcha");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][10], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][10], 11.000, 11.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][10], 0x24B85AFF);
    CelularHomeTD[playerid][11] = CreatePlayerTextDraw(playerid, 515.500, 292.500, "BANCO");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][11], 0.045, 0.300);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][11], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][11], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][11], 1);

    // BITCOIN
    CelularHomeTD[playerid][12] = CreatePlayerTextDraw(playerid, 529.000, 280.000, "LD_BEAT:chit");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][12], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][12], 11.000, 11.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][12], 0xF4A900FF);
    CelularHomeTD[playerid][13] = CreatePlayerTextDraw(playerid, 534.500, 292.500, "BITCOIN");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][13], 0.040, 0.300);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][13], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][13], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][13], 1);

    // SPOTIFY
    CelularHomeTD[playerid][14] = CreatePlayerTextDraw(playerid, 548.000, 280.000, "LD_CHAT:goodcha");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][14], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][14], 11.000, 11.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][14], 0x16B94AFF);
    CelularHomeTD[playerid][15] = CreatePlayerTextDraw(playerid, 553.500, 292.500, "SPOTIFY");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][15], 0.045, 0.300);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][15], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][15], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][15], 1);

    // MENSAGENS
    CelularHomeTD[playerid][16] = CreatePlayerTextDraw(playerid, 567.000, 280.000, "LD_CHAT:goodcha");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][16], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][16], 11.000, 11.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][16], 0xE74C3CFF);
    CelularHomeTD[playerid][17] = CreatePlayerTextDraw(playerid, 572.500, 292.500, "MENSAGENS");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][17], 0.035, 0.300);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][17], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][17], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][17], 1);

    // =========================================================
    // APLICATIVOS - LINHA 3 (3)
    // =========================================================

    // TELEFONE
    CelularHomeTD[playerid][18] = CreatePlayerTextDraw(playerid, 514.000, 311.000, "LD_CHAT:goodcha");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][18], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][18], 12.000, 12.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][18], 0x21C45AFF);
    CelularHomeTD[playerid][19] = CreatePlayerTextDraw(playerid, 520.000, 324.000, "TELEFONE");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][19], 0.045, 0.330);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][19], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][19], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][19], 1);

    // CONTATOS
    CelularHomeTD[playerid][20] = CreatePlayerTextDraw(playerid, 538.000, 311.000, "LD_DUAL:2:light");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][20], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][20], 12.000, 12.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][20], 0x3498DBFF);
    CelularHomeTD[playerid][21] = CreatePlayerTextDraw(playerid, 544.000, 324.000, "CONTATOS");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][21], 0.045, 0.330);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][21], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][21], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][21], 1);

    // CAMERA
    CelularHomeTD[playerid][22] = CreatePlayerTextDraw(playerid, 562.000, 311.000, "LD_DUAL:2:light");
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][22], 4);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][22], 12.000, 12.000);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][22], 0xF2F2F2FF);
    CelularHomeTD[playerid][23] = CreatePlayerTextDraw(playerid, 568.000, 324.000, "CAMERA");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][23], 0.045, 0.330);
    PlayerTextDrawColor(playerid, CelularHomeTD[playerid][23], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularHomeTD[playerid][23], 2);
    PlayerTextDrawFont(playerid, CelularHomeTD[playerid][23], 1);

    // =========================================================
    // AREAS DE CLIQUE DOS 10 APLICATIVOS (24-33)
    // =========================================================
    new Float:cx[10] = {510.0, 528.0, 546.0, 506.0, 523.0, 540.0, 557.0, 510.0, 528.0, 546.0};
    new Float:cy[10] = {248.0, 248.0, 248.0, 278.0, 278.0, 278.0, 278.0, 309.0, 309.0, 309.0};
    new Float:cx2[10] = {528.0, 546.0, 564.0, 523.0, 540.0, 557.0, 574.0, 528.0, 546.0, 564.0};
    new Float:cy2[10] = {272.0, 272.0, 272.0, 302.0, 302.0, 302.0, 302.0, 333.0, 333.0, 333.0};
    for(new a = 0; a < 10; a++)
    {
        CelularHomeTD[playerid][24 + a] = CreatePlayerTextDraw(playerid, cx[a], cy[a], " ");
        PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][24 + a], 0.000, 1.400);
        PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][24 + a], cx2[a], cy2[a]);
        PlayerTextDrawSetSelectable(playerid, CelularHomeTD[playerid][24 + a], 1);
    }

    // NAVEGACAO INFERIOR (34-36)
    CelularHomeTD[playerid][34] = CreatePlayerTextDraw(playerid, 512.000, 360.000, " ");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][34], 0.000, 1.700);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][34], 532.000, 383.000);
    PlayerTextDrawSetSelectable(playerid, CelularHomeTD[playerid][34], 1);

    CelularHomeTD[playerid][35] = CreatePlayerTextDraw(playerid, 536.000, 360.000, " ");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][35], 0.000, 1.700);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][35], 554.000, 383.000);
    PlayerTextDrawSetSelectable(playerid, CelularHomeTD[playerid][35], 1);

    CelularHomeTD[playerid][36] = CreatePlayerTextDraw(playerid, 559.000, 360.000, " ");
    PlayerTextDrawLetterSize(playerid, CelularHomeTD[playerid][36], 0.000, 1.700);
    PlayerTextDrawTextSize(playerid, CelularHomeTD[playerid][36], 578.000, 383.000);
    PlayerTextDrawSetSelectable(playerid, CelularHomeTD[playerid][36], 1);

    return 1;
}

stock CriarTelaBloqueio(playerid)
{
    // Limpa os dados de tentativa anteriores ao abrir
    SenhaInput[playerid][0] = '\0';

    // 0: Fundo da Tela de Bloqueio (Alinhado com a base do celular)
    CelularBloqueioTD[playerid][0] = CreatePlayerTextDraw(playerid, 509.750, 176.750, "box");
    PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][0], 0.000, 23.100);
    PlayerTextDrawTextSize(playerid, CelularBloqueioTD[playerid][0], 580.250, 0.000);
    PlayerTextDrawUseBox(playerid, CelularBloqueioTD[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, CelularBloqueioTD[playerid][0], 0x0A0A0BFF); // Preto Puro Solido

    // 1: Texto de Instrucao Superior
    new msgTop[32];
    if(strlen(SenhaCelular[playerid]) < 4) msgTop = "CRIE UM PIN DE 4 DIGITOS";
    else msgTop = "INSIRA O SEU PIN";

    CelularBloqueioTD[playerid][1] = CreatePlayerTextDraw(playerid, 545.000, 200.750, msgTop);
    PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][1], 0.105, 0.562);
    PlayerTextDrawColor(playerid, CelularBloqueioTD[playerid][1], 0xAAAAAAFF);
    PlayerTextDrawAlignment(playerid, CelularBloqueioTD[playerid][1], 2);
    PlayerTextDrawFont(playerid, CelularBloqueioTD[playerid][1], 2);

    // 2: Visor Oculto Dynamic (_ _ _ _)
    CelularBloqueioTD[playerid][2] = CreatePlayerTextDraw(playerid, 545.000, 215.750, "_ _ _ _");
    PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][2], 0.210, 0.975);
    PlayerTextDrawColor(playerid, CelularBloqueioTD[playerid][2], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularBloqueioTD[playerid][2], 2);
    PlayerTextDrawFont(playerid, CelularBloqueioTD[playerid][2], 2);

    // =========================================================
    // GRADE MATEMaTICA CENTRALIZADA DO KEYPAD (IDs de 3 a 11)
    // =========================================================
    new Float:x_start = 518.000000; 
    new Float:y_start = 230.000000;
    new Float:x_spacing = 27.000000;
    new Float:y_spacing = 28.000000;
    new numStr[2], td_id = 3;

    for(new i = 0; i < 9; i++)
    {
        new Float:x_pos = x_start + ((i % 3) * x_spacing);
        new Float:y_pos = y_start + ((i / 3) * y_spacing);
        
        valstr(numStr, i + 1);
        CelularBloqueioTD[playerid][td_id] = CreatePlayerTextDraw(playerid, x_pos, y_pos, numStr);
        PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][td_id], 0.180, 0.825);
        PlayerTextDrawColor(playerid, CelularBloqueioTD[playerid][td_id], 0xFFFFFFFF);
        PlayerTextDrawAlignment(playerid, CelularBloqueioTD[playerid][td_id], 2);
        PlayerTextDrawFont(playerid, CelularBloqueioTD[playerid][td_id], 2);
        PlayerTextDrawSetSelectable(playerid, CelularBloqueioTD[playerid][td_id], 1);
        // Ajuste de colisao de cliques invisiveis (Evita clicar em dois botoes ao mesmo tempo)
        PlayerTextDrawTextSize(playerid, CelularBloqueioTD[playerid][td_id], 10.500, 13.500); 
        td_id++;
    }

    // 12: Botao do Numero 0 (Centralizado Abaixo)
    CelularBloqueioTD[playerid][12] = CreatePlayerTextDraw(playerid, 545.000, 305.000, "0");
    PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][12], 0.180, 0.825);
    PlayerTextDrawColor(playerid, CelularBloqueioTD[playerid][12], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularBloqueioTD[playerid][12], 2);
    PlayerTextDrawFont(playerid, CelularBloqueioTD[playerid][12], 2);
    PlayerTextDrawSetSelectable(playerid, CelularBloqueioTD[playerid][12], 1);
    PlayerTextDrawTextSize(playerid, CelularBloqueioTD[playerid][12], 10.500, 13.500);

    // 13: Botao Apagar Corrigido (<)
    CelularBloqueioTD[playerid][13] = CreatePlayerTextDraw(playerid, 524.750, 305.000, "<");
    PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][13], 0.165, 0.825);
    PlayerTextDrawColor(playerid, CelularBloqueioTD[playerid][13], 0xE74C3CFF); 
    PlayerTextDrawAlignment(playerid, CelularBloqueioTD[playerid][13], 2);
    PlayerTextDrawFont(playerid, CelularBloqueioTD[playerid][13], 2);
    PlayerTextDrawSetSelectable(playerid, CelularBloqueioTD[playerid][13], 1);
    PlayerTextDrawTextSize(playerid, CelularBloqueioTD[playerid][13], 10.500, 13.500);

    // 14: Botao Confirmar Corrigido (V)
    CelularBloqueioTD[playerid][14] = CreatePlayerTextDraw(playerid, 565.250, 305.000, "V");
    PlayerTextDrawLetterSize(playerid, CelularBloqueioTD[playerid][14], 0.165, 0.825);
    PlayerTextDrawColor(playerid, CelularBloqueioTD[playerid][14], 0x2ECC71FF); 
    PlayerTextDrawAlignment(playerid, CelularBloqueioTD[playerid][14], 2);
    PlayerTextDrawFont(playerid, CelularBloqueioTD[playerid][14], 2);
    PlayerTextDrawSetSelectable(playerid, CelularBloqueioTD[playerid][14], 1);
    PlayerTextDrawTextSize(playerid, CelularBloqueioTD[playerid][14], 10.500, 13.500);

    return 1;
}


stock CriarTelaConfiguracoes(playerid)
{
    // Fundo do Menu (Respeitando perfeitamente o inicio da barra inferior fixa as 388.00)
    CelularConfigTD[playerid][0] = CreatePlayerTextDraw(playerid, 507.500, 185.000, "box");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][0], 0.000, 19.500); 
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][0], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularConfigTD[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, CelularConfigTD[playerid][0], 0x0A0A0CFF); 

    CelularConfigTD[playerid][1] = CreatePlayerTextDraw(playerid, 545.000, 189.500, "Settings");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][1], 0.180, 0.825);
    PlayerTextDrawColor(playerid, CelularConfigTD[playerid][1], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularConfigTD[playerid][1], 2);
    PlayerTextDrawFont(playerid, CelularConfigTD[playerid][1], 1);

    // CARDS CONFIG
    CelularConfigTD[playerid][2] = CreatePlayerTextDraw(playerid, 511.250, 208.250, "box");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][2], 0.000, 1.650);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][2], 578.750, 0.000);
    PlayerTextDrawUseBox(playerid, CelularConfigTD[playerid][2], 1);
    PlayerTextDrawBoxColor(playerid, CelularConfigTD[playerid][2], 0x1C1C1EFF);

    CelularConfigTD[playerid][3] = CreatePlayerTextDraw(playerid, 515.750, 212.750, "Mudar Papel de Parede");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][3], 0.098, 0.562);
    PlayerTextDrawColor(playerid, CelularConfigTD[playerid][3], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, CelularConfigTD[playerid][3], 1);

    CelularConfigTD[playerid][4] = CreatePlayerTextDraw(playerid, 511.250, 227.000, "box");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][4], 0.000, 1.650);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][4], 578.750, 0.000);
    PlayerTextDrawUseBox(playerid, CelularConfigTD[playerid][4], 1);
    PlayerTextDrawBoxColor(playerid, CelularConfigTD[playerid][4], 0x1C1C1EFF);

    CelularConfigTD[playerid][5] = CreatePlayerTextDraw(playerid, 515.750, 231.500, "Alterar Senha (PIN)");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][5], 0.098, 0.562);
    PlayerTextDrawColor(playerid, CelularConfigTD[playerid][5], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, CelularConfigTD[playerid][5], 1);

    CelularConfigTD[playerid][6] = CreatePlayerTextDraw(playerid, 511.250, 245.750, "box");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][6], 0.000, 1.650);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][6], 578.750, 0.000);
    PlayerTextDrawUseBox(playerid, CelularConfigTD[playerid][6], 1);
    PlayerTextDrawBoxColor(playerid, CelularConfigTD[playerid][6], 0x1C1C1EFF);

    CelularConfigTD[playerid][7] = CreatePlayerTextDraw(playerid, 515.750, 250.250, "Sons e Notificacoes");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][7], 0.098, 0.562);
    PlayerTextDrawColor(playerid, CelularConfigTD[playerid][7], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, CelularConfigTD[playerid][7], 1);

    // DETECTORES DE CLIQUE INVISiVEIS DO APP
    CelularConfigTD[playerid][8] = CreatePlayerTextDraw(playerid, 511.250, 208.250, " ");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][8], 0.000, 1.650);
    PlayerTextDrawSetSelectable(playerid, CelularConfigTD[playerid][8], 1);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][8], 578.750, 83.000);

    CelularConfigTD[playerid][9] = CreatePlayerTextDraw(playerid, 511.250, 227.000, " ");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][9], 0.000, 1.650);
    PlayerTextDrawSetSelectable(playerid, CelularConfigTD[playerid][9], 1);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][9], 578.750, 83.000);

    CelularConfigTD[playerid][10] = CreatePlayerTextDraw(playerid, 511.250, 245.750, " ");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][10], 0.000, 1.650);
    PlayerTextDrawSetSelectable(playerid, CelularConfigTD[playerid][10], 1);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][10], 578.750, 83.000);

    // GATILHOS VIRTUAIS DOS BOToES INFERIORES
    CelularConfigTD[playerid][11] = CreatePlayerTextDraw(playerid, 509.750, 362.750, " "); // |||
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][11], 0.000, 1.050);
    PlayerTextDrawSetSelectable(playerid, CelularConfigTD[playerid][11], 1);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][11], 532.250, 80.000);

    CelularConfigTD[playerid][12] = CreatePlayerTextDraw(playerid, 533.750, 362.750, " "); // O
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][12], 0.000, 1.050);
    PlayerTextDrawSetSelectable(playerid, CelularConfigTD[playerid][12], 1);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][12], 556.250, 80.000);

    CelularConfigTD[playerid][13] = CreatePlayerTextDraw(playerid, 557.750, 362.750, " "); // <
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][13], 0.000, 1.050);
    PlayerTextDrawSetSelectable(playerid, CelularConfigTD[playerid][13], 1);
    PlayerTextDrawTextSize(playerid, CelularConfigTD[playerid][13], 580.250, 80.000);

    CelularConfigTD[playerid][14] = CreatePlayerTextDraw(playerid, 545.000, 348.500, "iOS Mobile Build v21");
    PlayerTextDrawLetterSize(playerid, CelularConfigTD[playerid][14], 0.068, 0.413);
    PlayerTextDrawColor(playerid, CelularConfigTD[playerid][14], 0x444446FF);
    PlayerTextDrawAlignment(playerid, CelularConfigTD[playerid][14], 2);
    PlayerTextDrawFont(playerid, CelularConfigTD[playerid][14], 1);

    return 1;
}


stock CriarTelaWhatsApp(playerid)
{
    // [0] Fundo Branco do WhatsApp
    CelularWhatsTD[playerid][0] = CreatePlayerTextDraw(playerid, 507.500, 185.000, "box");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][0], 0.000, 19.500);
    PlayerTextDrawTextSize(playerid, CelularWhatsTD[playerid][0], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularWhatsTD[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, CelularWhatsTD[playerid][0], 0xF4F5F7FF);

    // [1] Header Verde Superior
    CelularWhatsTD[playerid][1] = CreatePlayerTextDraw(playerid, 507.500, 185.000, "box");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][1], 0.000, 2.625);
    PlayerTextDrawTextSize(playerid, CelularWhatsTD[playerid][1], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularWhatsTD[playerid][1], 1);
    PlayerTextDrawBoxColor(playerid, CelularWhatsTD[playerid][1], 0x075E54FF);

    // [2] Texto "WhatsApp" principal
    CelularWhatsTD[playerid][2] = CreatePlayerTextDraw(playerid, 511.250, 189.500, "WhatsApp");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][2], 0.165, 0.750);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][2], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][2], 1);

    // [3] Fundo das Sub-abas (CHATS, STATUS, CALLS)
    CelularWhatsTD[playerid][3] = CreatePlayerTextDraw(playerid, 507.500, 208.250, "box");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][3], 0.000, 1.050);
    PlayerTextDrawTextSize(playerid, CelularWhatsTD[playerid][3], 582.500, 0.000);
    PlayerTextDrawUseBox(playerid, CelularWhatsTD[playerid][3], 1);
    PlayerTextDrawBoxColor(playerid, CelularWhatsTD[playerid][3], 0x128C7EFF);

    // [4] Aba CHATS
    CelularWhatsTD[playerid][4] = CreatePlayerTextDraw(playerid, 522.500, 211.250, "CHATS");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][4], 0.098, 0.525);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][4], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularWhatsTD[playerid][4], 2);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][4], 1);

    // [5] Aba STATUS
    CelularWhatsTD[playerid][5] = CreatePlayerTextDraw(playerid, 545.000, 211.250, "STATUS");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][5], 0.098, 0.525);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][5], 0xB3FFFFFF);
    PlayerTextDrawAlignment(playerid, CelularWhatsTD[playerid][5], 2);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][5], 1);

    // [6] Aba CALLS
    CelularWhatsTD[playerid][6] = CreatePlayerTextDraw(playerid, 567.500, 211.250, "CALLS");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][6], 0.098, 0.525);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][6], 0xB3FFFFFF);
    PlayerTextDrawAlignment(playerid, CelularWhatsTD[playerid][6], 2);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][6], 1);

    // [7] Card do chat do contato
    CelularWhatsTD[playerid][7] = CreatePlayerTextDraw(playerid, 509.000, 222.500, "box");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][7], 0.000, 1.950);
    PlayerTextDrawTextSize(playerid, CelularWhatsTD[playerid][7], 581.000, 0.000);
    PlayerTextDrawUseBox(playerid, CelularWhatsTD[playerid][7], 1);
    PlayerTextDrawBoxColor(playerid, CelularWhatsTD[playerid][7], 0xFFFFFFFF);

    // [8] Foto de Perfil (icone)
    CelularWhatsTD[playerid][8] = CreatePlayerTextDraw(playerid, 512.000, 225.500, "ld_beat:chit");
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][8], 4);
    PlayerTextDrawTextSize(playerid, CelularWhatsTD[playerid][8], 11.250, 11.250);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][8], 0x075E5499);

    // [9] NOME DO CONTATO (Corrigido tamanho e alinhamento Y: 207.0)
    CelularWhatsTD[playerid][9] = CreatePlayerTextDraw(playerid, 527.000, 224.750, "Suporte do Servidor");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][9], 0.120, 0.562); 
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][9], 0x111111FF);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][9], 1);

    // [10] MENSAGEM DO CHAT (Abaixada para Y: 217.0 para nao embolar com o nome!)
    CelularWhatsTD[playerid][10] = CreatePlayerTextDraw(playerid, 527.000, 232.250, "Ola! Como posso te ajudar?");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][10], 0.098, 0.488);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][10], 0x777777FF);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][10], 1);

    // [11] HORaRIO DA MENSAGEM (Y: 207.0 a direita)
    CelularWhatsTD[playerid][11] = CreatePlayerTextDraw(playerid, 578.000, 224.750, "14:32");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][11], 0.098, 0.488);
    PlayerTextDrawColor(playerid, CelularWhatsTD[playerid][11], 0x128C7EFF);
    PlayerTextDrawAlignment(playerid, CelularWhatsTD[playerid][11], 3);
    PlayerTextDrawFont(playerid, CelularWhatsTD[playerid][11], 1);

    // [12] area de Clique Invisivel do Contato
    CelularWhatsTD[playerid][12] = CreatePlayerTextDraw(playerid, 509.000, 222.500, " ");
    PlayerTextDrawLetterSize(playerid, CelularWhatsTD[playerid][12], 0.000, 1.950);
    PlayerTextDrawSetSelectable(playerid, CelularWhatsTD[playerid][12], 1);
    PlayerTextDrawTextSize(playerid, CelularWhatsTD[playerid][12], 581.000, 84.500);

    return 1;
}



stock CriarTelaInstagram(playerid)
{
    // Fundo Interno do App (Cinza Escuro integrado com o Layout Realista)
    CelularInstaTD[playerid][0] = CreatePlayerTextDraw(playerid, 509.750, 188.000, "box");
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][0], 0.000, 18.750);
    PlayerTextDrawTextSize(playerid, CelularInstaTD[playerid][0], 580.250, 0.000);
    PlayerTextDrawUseBox(playerid, CelularInstaTD[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, CelularInstaTD[playerid][0], 0x151516FF);

    // Logo Superior: Instagram
    CelularInstaTD[playerid][1] = CreatePlayerTextDraw(playerid, 512.750, 192.500, "Instagram");
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][1], 0.210, 0.900);
    PlayerTextDrawColor(playerid, CelularInstaTD[playerid][1], 0xE1306CFF);
    PlayerTextDrawFont(playerid, CelularInstaTD[playerid][1], 3);

    // Botao Fechar (X) no topo direito interno do app
    CelularInstaTD[playerid][2] = CreatePlayerTextDraw(playerid, 569.750, 192.500, "X");
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][2], 0.165, 0.825);
    PlayerTextDrawColor(playerid, CelularInstaTD[playerid][2], 0x888888FF);
    PlayerTextDrawFont(playerid, CelularInstaTD[playerid][2], 2);
    PlayerTextDrawSetSelectable(playerid, CelularInstaTD[playerid][2], 1);
    PlayerTextDrawTextSize(playerid, CelularInstaTD[playerid][2], 442.500, 9.000);

    // Identificacao do Usuario Logado
    new strUser[45];
    if(InstaDados[playerid][TemContaInsta] == false) format(strUser, sizeof(strUser), "Perfil: Offline");
    else format(strUser, sizeof(strUser), "@%s", InstaDados[playerid][InstaUser]);
    CelularInstaTD[playerid][3] = CreatePlayerTextDraw(playerid, 512.750, 215.750, strUser);
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][3], 0.128, 0.712);
    PlayerTextDrawColor(playerid, CelularInstaTD[playerid][3], 0xFFFFFFFF);
    PlayerTextDrawFont(playerid, CelularInstaTD[playerid][3], 2);

    // Estatisticas Sociais 
    new strStats[96];
    if(InstaDados[playerid][TemContaInsta] == false) format(strStats, sizeof(strStats), "Crie uma conta para~n~interagir no app.");
    else format(strStats, sizeof(strStats), "Seguidores: %d~n~Seguindo: %d", InstaDados[playerid][InstaSeguidores], InstaDados[playerid][InstaSeguindo]);
    CelularInstaTD[playerid][4] = CreatePlayerTextDraw(playerid, 512.750, 234.500, strStats);
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][4], 0.112, 0.637);
    PlayerTextDrawColor(playerid, CelularInstaTD[playerid][4], 0xAAAAAAFF);
    PlayerTextDrawFont(playerid, CelularInstaTD[playerid][4], 1);

    // Caixa do Botao Azul de Acao Dinamico (Configurado corretamente para clique)
    CelularInstaTD[playerid][5] = CreatePlayerTextDraw(playerid, 512.750, 343.250, "box");
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][5], 0.000, 1.725);
    PlayerTextDrawTextSize(playerid, CelularInstaTD[playerid][5], 577.250, 0.000);
    PlayerTextDrawUseBox(playerid, CelularInstaTD[playerid][5], 1);
    PlayerTextDrawBoxColor(playerid, CelularInstaTD[playerid][5], 0x3897F0FF);
    PlayerTextDrawSetSelectable(playerid, CelularInstaTD[playerid][5], 1);

    // Rotulo do Botao Azul de Acao
    new btnStr[32];
    if(InstaDados[playerid][TemContaInsta] == false) format(btnStr, sizeof(btnStr), "CRIAR CONTA");
    else format(btnStr, sizeof(btnStr), "POSTAR STORIES");
    CelularInstaTD[playerid][6] = CreatePlayerTextDraw(playerid, 545.000, 348.500, btnStr);
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][6], 0.112, 0.637);
    PlayerTextDrawColor(playerid, CelularInstaTD[playerid][6], 0xFFFFFFFF);
    PlayerTextDrawAlignment(playerid, CelularInstaTD[playerid][6], 2);
    PlayerTextDrawFont(playerid, CelularInstaTD[playerid][6], 2);

    // Linha Invisivel de TextSize de Seguranca sobreposta ao botao azul para perfeito funcionamento do clique
    CelularInstaTD[playerid][7] = CreatePlayerTextDraw(playerid, 512.750, 343.250, " ");
    PlayerTextDrawLetterSize(playerid, CelularInstaTD[playerid][7], 0.000, 1.725);
    PlayerTextDrawSetSelectable(playerid, CelularInstaTD[playerid][7], 1);
    PlayerTextDrawTextSize(playerid, CelularInstaTD[playerid][7], 577.250, 84.500);
    return 1;
}

stock BCG_AbrirCelularVisual(playerid)
{
    return BCG38Open(playerid);
}

CMD:celular(playerid, params[])
{
    if(BCG36Client[playerid]) return BCG36Phone(playerid);
    BCG_AbrirCelularVisual(playerid);
    return 1;
}


forward CarregarInstagram(playerid);
public CarregarInstagram(playerid)
{
    new File[150]; format(File, sizeof(File), "Instagram/%s.ini", Nome(playerid));
    if(DOF2_FileExists(File))
    {
        InstaDados[playerid][TemContaInsta] = true;
        format(InstaDados[playerid][InstaUser], 32, "%s", DOF2_GetString(File, "Usuario"));
        InstaDados[playerid][InstaSeguidores] = DOF2_GetInt(File, "Seguidores");
        InstaDados[playerid][InstaSeguindo] = DOF2_GetInt(File, "Seguindo");
    }
    else
    {
        InstaDados[playerid][TemContaInsta] = false;
        format(InstaDados[playerid][InstaUser], 32, "Nenhum");
        InstaDados[playerid][InstaSeguidores] = 0;
        InstaDados[playerid][InstaSeguindo] = 0;
    }
    return 1;
}

forward SalvarInstagram(playerid);
public SalvarInstagram(playerid)
{
    if(InstaDados[playerid][TemContaInsta] == false) return 1;
    
    new File[150]; format(File, sizeof(File), "Instagram/%s.ini", Nome(playerid));
    if(!DOF2_FileExists(File)) DOF2_CreateFile(File);
    
    DOF2_SetString(File, "Usuario", InstaDados[playerid][InstaUser]);
    DOF2_SetInt(File, "Seguidores", InstaDados[playerid][InstaSeguidores]);
    DOF2_SetInt(File, "Seguindo", InstaDados[playerid][InstaSeguindo]);
    DOF2_SaveFile();
    return 1;
}
forward GetPlayerOrgID(playerid);
public GetPlayerOrgID(playerid)
{
    return Pdados[playerid][OrgID];
}
// Funcao para exibir o menu do Admin (Apenas 3 opcoes agora)
forward MostrarMenuCriarOrg(playerid);
public MostrarMenuCriarOrg(playerid)
{
    new string_dialog[300];
    format(string_dialog, sizeof(string_dialog), 
        "1. Definir Local do Comando %s\n2. Definir Local do Spawn do Carro %s\n{00FF00}3. Confirmar e Salvar Garagem",
        (RegistrouLocalComando[playerid] == 1) ? ("{00FF00}[OK]") : ("{FF0000}[Pendente]"),
        (RegistrouLocalSpawn[playerid] == 1) ? ("{00FF00}[OK]") : ("{FF0000}[Pendente]")
    );

    new titulo[64];
    format(titulo, sizeof(titulo), "Configurando Org ID: %d", TempCriarOrgID[playerid]);
    ShowPlayerDialog(playerid, DIALOG_MENU_BASE_ORG, DIALOG_STYLE_LIST, titulo, string_dialog, "Selecionar", "Fechar");
    return 1;
}

// Funcao que spawna o carro selecionado e joga o player dentro
stock SpawnarCarroDaGaragem(playerid, orgid, modelo_veic, Float:x, Float:y, Float:z, Float:angle)
{
    new carid = CreateVehicle(modelo_veic, x, y, z, angle, -1, -1, -1);
    
    // Integracao com os sistemas da sua GM
    GasolinaVeiculo[carid] = 100; 
    MotorLigado[carid] = false;   

    new engine, lights, alarm, v_doors, v_bonnet, v_boot, objective;
    GetVehicleParamsEx(carid, engine, lights, alarm, v_doors, v_bonnet, v_boot, objective);
    SetVehicleParamsEx(carid, VEHICLE_PARAMS_OFF, lights, alarm, v_doors, v_bonnet, v_boot, objective);

    // Cria o 3DTextLabel com o nome da Organizacao puxado da sua GM
    new label_text[128];
    format(label_text, sizeof(label_text), "Veiculo de Organizacao\n{00FFF0}%s", GetNomeOrg(orgid));
    new Text3D:carLabel = Create3DTextLabel(label_text, 0xFFFFFFFF, 0.0, 0.0, 0.0, 18.0, 0, 1);
    Attach3DTextLabelToVehicle(carLabel, carid, 0.0, 0.0, 0.85);

    // Joga o player direto no banco do motorista
    PutPlayerInVehicle(playerid, carid, 0);
    return carid;
}
CMD:criarsporg(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_org;
    if(sscanf(params, "i", id_org)) return SendClientMessage(playerid, CINZA, "Use /criarsporg [ID DA ORG]");
    if(id_org < 1 || id_org > 32) return SendClientMessage(playerid, CINZA, "ID de organizacao invalido (1 a 32).");

    TempCriarOrgID[playerid] = id_org;
    RegistrouLocalComando[playerid] = 0;
    RegistrouLocalSpawn[playerid] = 0;

    MostrarMenuCriarOrg(playerid);
    return 1;
}
forward CarregarGaragens_Pickups();
public CarregarGaragens_Pickups()
{
    new filename[64], line[200];
    new Float:cx, Float:cy, Float:cz;
    new Float:sx, Float:sy, Float:sz, Float:sa;
    new File:file;

    for(new org = 1; org <= 32; org++)
    {
        format(filename, sizeof(filename), "CarOrgs/Org_%d.txt", org);
        
        if(fexist(filename))
        {
            file = fopen(filename, io_read);
            if(fread(file, line))
            {
                new len = strlen(line);
                if(line[len - 1] == '\r' || line[len - 1] == '\n') line[len - 1] = 0;
                if(line[len - 2] == '\r' || line[len - 2] == '\n') line[len - 2] = 0;

                if(!sscanf(line, "p<|>fffffff", cx, cy, cz, sx, sy, sz, sa))
                {
                    // Destroi os antigos se ja existirem (evita bugs ao relogar/reiniciar)
                    if(PickupGaragemOrg[org] != 0) DestroyPickup(PickupGaragemOrg[org]);
                    if(TextoGaragemOrg[org] != Text3D:0) Delete3DTextLabel(TextoGaragemOrg[org]);

                    // Cria o Pickup (ID 1239 e a pastinha de informacoes, mude se quiser)
                    PickupGaragemOrg[org] = CreatePickup(1239, 1, cx, cy, cz, -1);

                    // Cria o Texto 3D flutuando no local do comando
                    new string_label[128];
                    format(string_label, sizeof(string_label), "{00FFF0}[ Garagem %s ]\n{FFFFFF}Aperte {00FF00}F {FFFFFF}para acessar", GetNomeOrg(org));
                    TextoGaragemOrg[org] = Create3DTextLabel(string_label, 0xFFFFFFFF, cx, cy, cz + 0.5, 15.0, 0, 1);
                }
            }
            fclose(file);
        }
    }
    print(">> [SISTEMA] Pickups e Textos 3D das garagens carregados.");
    return 1;
}
// Funcao utilitaria interna para atualizar objetos e 3D texts
forward RecriarEstruturaCaixa(id);
public RecriarEstruturaCaixa(id) {
    if(IsValidDynamicObject(g_CaixasDados[id][cxObjeto])) DestroyDynamicObject(g_CaixasDados[id][cxObjeto]);
    if(IsValidDynamicPickup(g_CaixasDados[id][cxPickup])) DestroyDynamicPickup(g_CaixasDados[id][cxPickup]);
    if(IsValidDynamic3DTextLabel(g_CaixasDados[id][cxText])) DestroyDynamic3DTextLabel(g_CaixasDados[id][cxText]);

    g_CaixasDados[id][cxObjeto] = CreateDynamicObject(19324, g_CaixasDados[id][cxX], g_CaixasDados[id][cxY], g_CaixasDados[id][cxZ] - 0.3, 0.0, 0.0, g_CaixasDados[id][cxA]);

    // Marcador $ dourado na frente do caixa. O H e detectado neste ponto.
    new Float:mx, Float:my, Float:mz;
    mx = g_CaixasDados[id][cxX] - (1.25 * floatsin(-g_CaixasDados[id][cxA], degrees));
    my = g_CaixasDados[id][cxY] - (1.25 * floatcos(-g_CaixasDados[id][cxA], degrees));
    mz = g_CaixasDados[id][cxZ];
    g_CaixasDados[id][cxPickup] = CreateDynamicPickup(1274, 1, mx, my, mz - 0.55, -1, -1, -1, 25.0);

    new str[128];
    format(str, sizeof(str), "{00BFFF}Caixa Eletr\xf4nico {FFFFFF}[%d]\n{FFFFFF}Pressione {FFFF00}'H' {FFFFFF}para acessar", id);
    g_CaixasDados[id][cxText] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, mx, my, mz + 0.05, 8.0);
    return 1;
}

// Substitua o bloco antigo por este codigo corrigido:
public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
    // Verifica se a resposta foi a de salvar (clique no disquete)
    if(response == EDIT_RESPONSE_FINAL) 
    {
        new id = Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID);
        if(id >= 0 && id < MAX_CAIXAS && g_CaixasDados[id][cxExiste]) 
        {
            g_CaixasDados[id][cxX] = x;
            g_CaixasDados[id][cxY] = y;
            g_CaixasDados[id][cxZ] = z;
            g_CaixasDados[id][cxA] = rz;

            new query[200];
            format(query, sizeof(query), "UPDATE caixas SET X = %f, Y = %f, Z = %f, A = %f WHERE ID = %d", x, y, z, rz, id);
            db_query(g_DB_Caixas, query);

            RecriarEstruturaCaixa(id);
            SendClientMessage(playerid, 0x00FF00AA, "[SISTEMA] Posicao do Caixa Eletronico atualizada e salva!");
        }
    }
    
    // Se voce ja tiver essa callback para editar outros objetos na sua GM, 
    // adicione apenas o codigo de cima dentro da sua "OnPlayerEditDynamicObject" existente.
    return 1;
}


// --- COMANDOS ---

CMD:criarcaixa(playerid, params[]) {
    if(!(ADM(playerid, 4))) return 1;
    new slot = -1;
    for(new i = 0; i < MAX_CAIXAS; i++) {
        if(!g_CaixasDados[i][cxExiste]) { slot = i; break; }
    }
    if(slot == -1) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Limite maximo de caixas atingido.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    g_CaixasDados[slot][cxX] = x; g_CaixasDados[slot][cxY] = y; g_CaixasDados[slot][cxZ] = z; g_CaixasDados[slot][cxA] = a; 
    g_CaixasDados[slot][cxExiste] = true;

    RecriarEstruturaCaixa(slot);

    new query[180];
    format(query, sizeof(query), "INSERT INTO caixas (ID, X, Y, Z, A) VALUES (%d, %f, %f, %f, %f)", slot, x, y, z, a);
    db_query(g_DB_Caixas, query);

    new msg[128];
    format(msg, sizeof(msg), "[SUCESSO] Caixa Eletronico ID: %d criado EXATAMENTE na sua posicao e angulo!", slot);
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}

CMD:deletarcaixa(playerid, params[]) {
    if(!(ADM(playerid, 4))) return 1;
    new idProximo = -1;
    for(new i = 0; i < MAX_CAIXAS; i++) {
        if(g_CaixasDados[i][cxExiste] && IsPlayerInRangeOfPoint(playerid, 3.0, g_CaixasDados[i][cxX], g_CaixasDados[i][cxY], g_CaixasDados[i][cxZ])) { idProximo = i; break; }
    }
    if(idProximo == -1) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao esta perto de nenhum caixa criado.");

    if(IsValidDynamicObject(g_CaixasDados[idProximo][cxObjeto])) DestroyDynamicObject(g_CaixasDados[idProximo][cxObjeto]);
    if(IsValidDynamicPickup(g_CaixasDados[idProximo][cxPickup])) DestroyDynamicPickup(g_CaixasDados[idProximo][cxPickup]);
    if(IsValidDynamic3DTextLabel(g_CaixasDados[idProximo][cxText])) DestroyDynamic3DTextLabel(g_CaixasDados[idProximo][cxText]);

    new query[100];
    format(query, sizeof(query), "DELETE FROM caixas WHERE ID = %d", idProximo);
    db_query(g_DB_Caixas, query);
    g_CaixasDados[idProximo][cxExiste] = false;
    
    SendClientMessage(playerid, 0x00FF00AA, "[SISTEMA] Caixa Eletronico deletado.");
    return 1;
}

CMD:editarcaixa(playerid, params[]) {
    if(!(ADM(playerid, 4))) return 1;
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, 0xFFFF00AA, "[USO] /editarcaixa [ID]");
    if(id < 0 || id >= MAX_CAIXAS || !g_CaixasDados[id][cxExiste]) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] ID invalido.");

    Streamer_SetIntData(STREAMER_TYPE_OBJECT, g_CaixasDados[id][cxObjeto], E_STREAMER_EXTRA_ID, id);
    EditDynamicObject(playerid, g_CaixasDados[id][cxObjeto]);
    return 1;
}
public Float:DistanceToPoint(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
    return floatsqroot(((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)) + ((z1 - z2) * (z1 - z2)));
}
stock BCG_CaixaEletronicoProximo(playerid, Float:distancia_maxima = 3.0)
{
    new id = -1;
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    for(new i = 0; i < MAX_CAIXAS; i++)
    {
        if(g_CaixasDados[i][cxExiste])
        {
            new Float:mx, Float:my, Float:mz;
            mx = g_CaixasDados[i][cxX] - (1.25 * floatsin(-g_CaixasDados[i][cxA], degrees));
            my = g_CaixasDados[i][cxY] - (1.25 * floatcos(-g_CaixasDados[i][cxA], degrees));
            mz = g_CaixasDados[i][cxZ];
            if(DistanceToPoint(px, py, pz, mx, my, mz) <= distancia_maxima)
            {
                id = i;
                break;
            }
        }
    }
    return id;
}

stock BCG_EhCaixaFixo(playerid)
{
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 1735.0466, -1605.6649, 13.5469)) return 1;
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 1479.6907, -1718.0627, 14.0469)) return 1;
    if(IsPlayerInRangeOfPoint(playerid, 3.0, 1362.5693, -1748.7300, 13.5324)) return 1;
    return 0;
}

stock BCG_UsarCaixaEletronico(playerid)
{
    if(!Pdados[playerid][Logado]) return SendClientMessage(playerid, -1, "{FF3030}[CAIXA ELETRONICO]{FFFFFF} Voce precisa estar logado.");
    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "{FF3030}[CAIXA ELETRONICO]{FFFFFF} Saia do veiculo para usar o caixa.");

    new id = BCG_CaixaEletronicoProximo(playerid, 3.5);
    if(id == -1 && !BCG_EhCaixaFixo(playerid))
        return SendClientMessage(playerid, -1, "{FF3030}[CAIXA ELETRONICO]{FFFFFF} Voce nao esta perto de um caixa eletronico.");

    OpenBancoInterface(playerid);
    return 1;
}

stock OpenBancoInterface(playerid)
{
    new menu[256];
    format(menu, sizeof(menu), "{FF3030}[1] {FFFFFF}Transferncia bancria (PIX)\n{FF3030}[2] {FFFFFF}Sacar dinheiro\n{FF3030}[3] {FFFFFF}Depositar dinheiro\n\n{FFFFFF}Saldo: {33CC66}R$%d", Pdados[playerid][Banco]);
    ShowPlayerDialog(playerid, DIALOG_BANCO, DIALOG_STYLE_LIST, "Imprio Roleplay: Caixa Eletrnico", menu, "Selecionar", "Cancelar");
    return 1;
}

stock UpdateBancoValores(playerid)
{
    if(g_MenuBancoAberto[playerid] == MENU_BANCO_FECHADO) return;

    PlayerTextDrawDestroy(playerid, PTD_ValoresDinamicos[playerid][0]);
    PlayerTextDrawDestroy(playerid, PTD_ValoresDinamicos[playerid][1]);

    new str[64];
    // Texto Dinamico: Saldo Bancario
    format(str, sizeof(str), "Saldo Bancario:~n~~r~R$ %d", Pdados[playerid][Banco]);
    PTD_ValoresDinamicos[playerid][0] = CreatePlayerTextDraw(playerid, 175.0, 170.0, str);
    PlayerTextDrawFont(playerid, PTD_ValoresDinamicos[playerid][0], 1);
    PlayerTextDrawLetterSize(playerid, PTD_ValoresDinamicos[playerid][0], 0.24, 1.05);
    PlayerTextDrawColor(playerid, PTD_ValoresDinamicos[playerid][0], 0xFFFFFFFF);
    PlayerTextDrawShow(playerid, PTD_ValoresDinamicos[playerid][0]);

    // Texto Dinamico: Saldo Carteira
    format(str, sizeof(str), "Saldo Carteira:~n~~g~R$ %d", GetPlayerMoney(playerid));
    PTD_ValoresDinamicos[playerid][1] = CreatePlayerTextDraw(playerid, 175.0, 205.0, str);
    PlayerTextDrawFont(playerid, PTD_ValoresDinamicos[playerid][1], 1);
    PlayerTextDrawLetterSize(playerid, PTD_ValoresDinamicos[playerid][1], 0.24, 1.05);
    PlayerTextDrawColor(playerid, PTD_ValoresDinamicos[playerid][1], 0xFFFFFFFF);
    PlayerTextDrawShow(playerid, PTD_ValoresDinamicos[playerid][1]);
}

stock CloseBancoInterface(playerid)
{
    // Destroi o fundo principal
    if(PTD_BancoFundo[playerid] != PlayerText:INVALID_TEXT_DRAW) {
        PlayerTextDrawHide(playerid, PTD_BancoFundo[playerid]);
        PlayerTextDrawDestroy(playerid, PTD_BancoFundo[playerid]);
        PTD_BancoFundo[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }

    // Destroi a caixinha do cartao
    if(PTD_BancoCartao[playerid] != PlayerText:INVALID_TEXT_DRAW) {
        PlayerTextDrawHide(playerid, PTD_BancoCartao[playerid]);
        PlayerTextDrawDestroy(playerid, PTD_BancoCartao[playerid]);
        PTD_BancoCartao[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }

    // NOVO: Destroi TODAS as informacoes escritas no cartao (0 a 5)
    for(new i = 0; i < 6; i++) {
        if(PTD_BancoInfos[playerid][i] != PlayerText:INVALID_TEXT_DRAW) {
            PlayerTextDrawHide(playerid, PTD_BancoInfos[playerid][i]);
            PlayerTextDrawDestroy(playerid, PTD_BancoInfos[playerid][i]);
            PTD_BancoInfos[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    // Destroi os saldos dinamicos
    for(new i = 0; i < 2; i++) {
        if(PTD_ValoresDinamicos[playerid][i] != PlayerText:INVALID_TEXT_DRAW) {
            PlayerTextDrawHide(playerid, PTD_ValoresDinamicos[playerid][i]);
            PlayerTextDrawDestroy(playerid, PTD_ValoresDinamicos[playerid][i]);
            PTD_ValoresDinamicos[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    // Destroi os botoes clicaveis
    for(new i = 0; i < 6; i++) {
        if(PTD_BancoBotoes[playerid][i] != PlayerText:INVALID_TEXT_DRAW) {
            PlayerTextDrawHide(playerid, PTD_BancoBotoes[playerid][i]);
            PlayerTextDrawDestroy(playerid, PTD_BancoBotoes[playerid][i]);
            PTD_BancoBotoes[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }

    TogglePlayerControllable(playerid, 1); // Descongela o jogador
    CancelSelectTextDraw(playerid); // Some com a setinha do mouse
    g_MenuBancoAberto[playerid] = MENU_BANCO_FECHADO;
}

stock AdicionarAoExtrato(playerid, const tipo[], valor)
{
    // Empurra os registros antigos para baixo para dar espaco ao novo no indice 0
    format(g_HistoricoBanco[playerid][2][exTipo], 24, g_HistoricoBanco[playerid][1][exTipo]);
    g_HistoricoBanco[playerid][2][exValor] = g_HistoricoBanco[playerid][1][exValor];

    format(g_HistoricoBanco[playerid][1][exTipo], 24, g_HistoricoBanco[playerid][0][exTipo]);
    g_HistoricoBanco[playerid][1][exValor] = g_HistoricoBanco[playerid][0][exValor];

    format(g_HistoricoBanco[playerid][0][exTipo], 24, tipo);
    g_HistoricoBanco[playerid][0][exValor] = valor;
}

stock CarregarLocaisEquipar()
{
    if(!DOF2_FileExists(ARQUIVO_LOCAIS)) DOF2_CreateFile(ARQUIVO_LOCAIS);

    new chave[32], infoStr[128];
    for(new i = 0; i < MAX_ORGS; i++)
    {
        format(chave, sizeof(chave), "Org_%d_Criado", i);
        if(DOF2_GetInt(ARQUIVO_LOCAIS, chave) == 1)
        {
            format(chave, sizeof(chave), "Org_%d_X", i); LocalEquipar[i][lcX] = DOF2_GetFloat(ARQUIVO_LOCAIS, chave);
            format(chave, sizeof(chave), "Org_%d_Y", i); LocalEquipar[i][lcY] = DOF2_GetFloat(ARQUIVO_LOCAIS, chave);
            format(chave, sizeof(chave), "Org_%d_Z", i); LocalEquipar[i][lcZ] = DOF2_GetFloat(ARQUIVO_LOCAIS, chave);
            
            LocalEquipar[i][lcCriado] = true;
            LocalEquipar[i][lcPickupID] = CreatePickup(1239, 1, LocalEquipar[i][lcX], LocalEquipar[i][lcY], LocalEquipar[i][lcZ], -1);
            
            format(infoStr, sizeof(infoStr), "{F1C40F}====== [ LOCAL DE EQUIPAR ] ======\n{FFFFFF}Organizacao ID: {3498DB}%d\n{AMARELO}Aperte 'F' ou use /equipar", i);
            LocalEquipar[i][lcTextID] = Create3DTextLabel(infoStr, 0xFFFFFFFF, LocalEquipar[i][lcX], LocalEquipar[i][lcY], LocalEquipar[i][lcZ] + 0.5, 15.0, 0, 0);
        }
    }
    return 1;
}

stock SalvarLocalEquipar(orgid)
{
    new chave[32];
    if(LocalEquipar[orgid][lcCriado])
    {
        format(chave, sizeof(chave), "Org_%d_Criado", orgid); DOF2_SetInt(ARQUIVO_LOCAIS, chave, 1);
        format(chave, sizeof(chave), "Org_%d_X", orgid); DOF2_SetFloat(ARQUIVO_LOCAIS, chave, LocalEquipar[orgid][lcX]);
        format(chave, sizeof(chave), "Org_%d_Y", orgid); DOF2_SetFloat(ARQUIVO_LOCAIS, chave, LocalEquipar[orgid][lcY]);
        format(chave, sizeof(chave), "Org_%d_Z", orgid); DOF2_SetFloat(ARQUIVO_LOCAIS, chave, LocalEquipar[orgid][lcZ]);
    }
    else
    {
        format(chave, sizeof(chave), "Org_%d_Criado", orgid); DOF2_SetInt(ARQUIVO_LOCAIS, chave, 0);
    }
    DOF2_SaveFile();
    return 1;
}

stock BCG_EncontrarOrgPorNome(const nome[])
{
    // Nomes atuais exibidos na aba GANGSTER do /orgs.
    if(strcmp(nome, "Os 4M", true) == 0) return 24;
    if(strcmp(nome, "holanda 2.0", true) == 0) return 25;
    if(strcmp(nome, "Os pecinhas", true) == 0) return 26;
    if(strcmp(nome, "Us guri", true) == 0) return 27;
    if(strcmp(nome, "Real td7", true) == 0) return 28;
    if(strcmp(nome, "amigos dos amigos", true) == 0) return 29;
    if(strcmp(nome, "bad Boys", true) == 0) return 30;
    if(strcmp(nome, "Os rlk", true) == 0) return 31;
    if(strcmp(nome, "trembala", true) == 0) return 32;

    new nomeAtual[40];
    for(new i = 1; i < MAX_ORGS; i++)
    {
        if(i >= ORG_CUSTOM_INICIO && i <= ORG_CUSTOM_FIM && !OrgCustomAtiva[i]) continue;
        format(nomeAtual, sizeof(nomeAtual), "%s", GetNomeOrg(i));
        if(strcmp(nomeAtual, nome, true) == 0) return i;
    }
    return -1;
}

stock BCG_SalvarCofreOrg(orgid)
{
    if(orgid <= 0 || orgid >= MAX_ORGS) return 0;
    if(!DOF2_FileExists(ARQUIVO_COFRES_ORG)) DOF2_CreateFile(ARQUIVO_COFRES_ORG);

    new chave[40];
    format(chave, sizeof(chave), "Org_%d_Criado", orgid); DOF2_SetInt(ARQUIVO_COFRES_ORG, chave, CofreOrg[orgid][cfCriado] ? 1 : 0);
    format(chave, sizeof(chave), "Org_%d_X", orgid); DOF2_SetFloat(ARQUIVO_COFRES_ORG, chave, CofreOrg[orgid][cfX]);
    format(chave, sizeof(chave), "Org_%d_Y", orgid); DOF2_SetFloat(ARQUIVO_COFRES_ORG, chave, CofreOrg[orgid][cfY]);
    format(chave, sizeof(chave), "Org_%d_Z", orgid); DOF2_SetFloat(ARQUIVO_COFRES_ORG, chave, CofreOrg[orgid][cfZ]);
    format(chave, sizeof(chave), "Org_%d_Nome", orgid); DOF2_SetString(ARQUIVO_COFRES_ORG, chave, CofreOrg[orgid][cfNome]);
    for(new slot = 0; slot < 13; slot++)
    {
        format(chave, sizeof(chave), "Org_%d_Arma_%d", orgid, slot); DOF2_SetInt(ARQUIVO_COFRES_ORG, chave, CofreOrgArma[orgid][slot]);
        format(chave, sizeof(chave), "Org_%d_Ammo_%d", orgid, slot); DOF2_SetInt(ARQUIVO_COFRES_ORG, chave, CofreOrgAmmo[orgid][slot]);
    }
    DOF2_SaveFile();
    return 1;
}

stock BCG_CarregarCofresOrg()
{
    if(!DOF2_FileExists(ARQUIVO_COFRES_ORG)) DOF2_CreateFile(ARQUIVO_COFRES_ORG);
    new chave[40], infoStr[160];
    for(new i = 1; i < MAX_ORGS; i++)
    {
        format(chave, sizeof(chave), "Org_%d_Criado", i);
        if(DOF2_GetInt(ARQUIVO_COFRES_ORG, chave) != 1) continue;

        CofreOrg[i][cfCriado] = true;
        CofreOrg[i][cfOrgID] = i;
        format(chave, sizeof(chave), "Org_%d_X", i); CofreOrg[i][cfX] = DOF2_GetFloat(ARQUIVO_COFRES_ORG, chave);
        format(chave, sizeof(chave), "Org_%d_Y", i); CofreOrg[i][cfY] = DOF2_GetFloat(ARQUIVO_COFRES_ORG, chave);
        format(chave, sizeof(chave), "Org_%d_Z", i); CofreOrg[i][cfZ] = DOF2_GetFloat(ARQUIVO_COFRES_ORG, chave);
        format(chave, sizeof(chave), "Org_%d_Nome", i); format(CofreOrg[i][cfNome], 40, "%s", DOF2_GetString(ARQUIVO_COFRES_ORG, chave));

        for(new slot = 0; slot < 13; slot++)
        {
            format(chave, sizeof(chave), "Org_%d_Arma_%d", i, slot); CofreOrgArma[i][slot] = DOF2_GetInt(ARQUIVO_COFRES_ORG, chave);
            format(chave, sizeof(chave), "Org_%d_Ammo_%d", i, slot); CofreOrgAmmo[i][slot] = DOF2_GetInt(ARQUIVO_COFRES_ORG, chave);
        }

        CofreOrg[i][cfPickupID] = CreatePickup(1239, 1, CofreOrg[i][cfX], CofreOrg[i][cfY], CofreOrg[i][cfZ], -1);
        format(infoStr, sizeof(infoStr), "{FFD700}====== [ COFRE DA ORG ] ======\n{FFFFFF}%s\n{FFFF00}/cofre - Guardar/retirar armas", GetNomeOrg(i));
        CofreOrg[i][cfTextID] = Create3DTextLabel(infoStr, 0xFFFFFFFF, CofreOrg[i][cfX], CofreOrg[i][cfY], CofreOrg[i][cfZ] + 0.5, 15.0, 0, 0);
    }
    return 1;
}

CMD:criarcofre(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    if(strfind(params, "da org ", true) != 0)
        return SendClientMessage(playerid, 0x95A5A6FF, "Uso correto: /criarcofre da org [nome da organizacao]");

    new nomeOrg[40];
    strmid(nomeOrg, params, 7, strlen(params), sizeof(nomeOrg));
    if(strlen(nomeOrg) < 2) return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Informe o nome da organizacao.");

    new orgid = BCG_EncontrarOrgPorNome(nomeOrg);
    if(orgid == -1) return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Organizacao nao encontrada. Use o nome exatamente como aparece no /orgs.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(CofreOrg[orgid][cfCriado])
    {
        DestroyPickup(CofreOrg[orgid][cfPickupID]);
        Delete3DTextLabel(CofreOrg[orgid][cfTextID]);
    }
    CofreOrg[orgid][cfCriado] = true;
    CofreOrg[orgid][cfOrgID] = orgid;
    CofreOrg[orgid][cfX] = x;
    CofreOrg[orgid][cfY] = y;
    CofreOrg[orgid][cfZ] = z;
    format(CofreOrg[orgid][cfNome], 40, "%s", GetNomeOrg(orgid));
    CofreOrg[orgid][cfPickupID] = CreatePickup(1239, 1, x, y, z, -1);
    new infoStr[160];
    format(infoStr, sizeof(infoStr), "{FFD700}====== [ COFRE DA ORG ] ======\n{FFFFFF}%s\n{FFFF00}/cofre - Guardar/retirar armas", GetNomeOrg(orgid));
    CofreOrg[orgid][cfTextID] = Create3DTextLabel(infoStr, 0xFFFFFFFF, x, y, z + 0.5, 15.0, 0, 0);
    BCG_SalvarCofreOrg(orgid);

    format(infoStr, sizeof(infoStr), "[COFRE] Cofre da org %s criado nesta posicao.", GetNomeOrg(orgid));
    SendClientMessage(playerid, 0x2ECC71FF, infoStr);
    return 1;
}

CMD:criarequipar(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    if(strfind(params, "da org ", true) != 0)
        return SendClientMessage(playerid, 0x95A5A6FF, "Uso correto: /criarequipar da org [nome da organizacao]");

    new nomeOrg[40];
    strmid(nomeOrg, params, 7, strlen(params), sizeof(nomeOrg));
    if(strlen(nomeOrg) < 2) return SendClientMessage(playerid, 0xE74C3CFF, "[EQUIPAR] Informe o nome da organizacao.");

    new orgid = BCG_EncontrarOrgPorNome(nomeOrg);
    if(orgid == -1) return SendClientMessage(playerid, 0xE74C3CFF, "[EQUIPAR] Organizacao nao encontrada. Use o nome exatamente como aparece no /orgs.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(LocalEquipar[orgid][lcCriado])
    {
        DestroyPickup(LocalEquipar[orgid][lcPickupID]);
        Delete3DTextLabel(LocalEquipar[orgid][lcTextID]);
    }
    LocalEquipar[orgid][lcX] = x;
    LocalEquipar[orgid][lcY] = y;
    LocalEquipar[orgid][lcZ] = z;
    LocalEquipar[orgid][lcCriado] = true;
    LocalEquipar[orgid][lcPickupID] = CreatePickup(1239, 1, x, y, z, -1);
    new infoStr[160];
    format(infoStr, sizeof(infoStr), "{00FFFF}====== [ EQUIPAR DA ORG ] ======\n{FFFFFF}%s\n{FFFF00}Use /equipar para pegar as armas", GetNomeOrg(orgid));
    LocalEquipar[orgid][lcTextID] = Create3DTextLabel(infoStr, 0xFFFFFFFF, x, y, z + 0.5, 15.0, 0, 0);
    SalvarLocalEquipar(orgid);

    format(infoStr, sizeof(infoStr), "[EQUIPAR] Ponto de equipar da org %s criado nesta posicao.", GetNomeOrg(orgid));
    SendClientMessage(playerid, 0x2ECC71FF, infoStr);
    return 1;
}

CMD:cofre(playerid, params[])
{
    new orgid = Pdados[playerid][OrgID];
    if(orgid <= 0 || orgid >= MAX_ORGS) return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Voce nao pertence a uma organizacao.");
    if(!CofreOrg[orgid][cfCriado]) return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Sua organizacao nao possui um cofre criado.");
    if(!IsPlayerInRangeOfPoint(playerid, 4.0, CofreOrg[orgid][cfX], CofreOrg[orgid][cfY], CofreOrg[orgid][cfZ]))
        return SendClientMessage(playerid, 0xE74C3CFF, "[COFRE] Voce precisa estar no cofre da sua organizacao.");

    ShowPlayerDialog(playerid, DIALOG_COFRE_ORG, DIALOG_STYLE_LIST, "{FFD700}COFRE DA ORGANIZACAO",
        "Guardar minhas armas\nRetirar armas da organizacao", "Selecionar", "Fechar");
    return 1;
}

CMD:criarlcq(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    
    new tipo[12];
    if(sscanf(params, "s[12]", tipo)) return SendClientMessage(playerid, 0x95A5A6FF, "Uso correto: /criarlcq [corp] ou [ID da Organizacao]");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // =========================================================================
    // SE DIGITAR "corp": CRIA O PONTO PARA TODAS AS CORPORAcoES (1 a 12)
    // =========================================================================
    if(strcmp(tipo, "corp", true) == 0)
    {
        for(new i = 1; i <= 12; i++)
        {
            if(LocalEquipar[i][lcCriado])
            {
                DestroyPickup(LocalEquipar[i][lcPickupID]);
                Delete3DTextLabel(LocalEquipar[i][lcTextID]);
            }

            LocalEquipar[i][lcX] = x;
            LocalEquipar[i][lcY] = y;
            LocalEquipar[i][lcZ] = z;
            LocalEquipar[i][lcCriado] = true;
            
            // Cria apenas visualmente no mapa um pickup e texto padrao unificado
            if(i == 1) 
            {
                LocalEquipar[i][lcPickupID] = CreatePickup(1239, 1, x, y, z, -1);
                
                new infoStr[128];
                format(infoStr, sizeof(infoStr), "{F1C40F}====== [ LOCAL DE EQUIPAR ] ======\n{FFFFFF}Organizacao: {3498DB}Todas as Corporacoes\n{FFFF00}Aperte 'F' ou use /equipar");
                LocalEquipar[i][lcTextID] = Create3DTextLabel(infoStr, 0xFFFFFFFF, x, y, z + 0.5, 15.0, 0, 0);
            }
            SalvarLocalEquipar(i);
        }
        SendClientMessage(playerid, 0x2ECC71FF, "[SUCESSO]: Ponto de equipar integrado criado para todas as CORPS (1 a 12)!");
        return 1;
    }
    // =========================================================================
    // SE FOR UM NuMERO: CRIA APENAS PARA A FACcaO ESPECiFICA (13 a 33)
    // =========================================================================
    else
    {
        new orgid = strval(tipo);
        if(orgid < 13 || orgid > 33) return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO]: Use 'corp' ou IDs validos de faccao (13 a 33)!");

        if(LocalEquipar[orgid][lcCriado])
        {
            DestroyPickup(LocalEquipar[orgid][lcPickupID]);
            Delete3DTextLabel(LocalEquipar[orgid][lcTextID]);
        }

        LocalEquipar[orgid][lcX] = x;
        LocalEquipar[orgid][lcY] = y;
        LocalEquipar[orgid][lcZ] = z;
        LocalEquipar[orgid][lcCriado] = true;

        LocalEquipar[orgid][lcPickupID] = CreatePickup(1239, 1, x, y, z, -1);
        
        new infoStr[128];
        format(infoStr, sizeof(infoStr), "{F1C40F}====== [ LOCAL DE EQUIPAR ] ======\n{FFFFFF}Organizacao ID: {3498DB}%d\n{FFFF00}Aperte 'F' ou use /equipar", orgid);
        LocalEquipar[orgid][lcTextID] = Create3DTextLabel(infoStr, 0xFFFFFFFF, x, y, z + 0.5, 15.0, 0, 0);

        SalvarLocalEquipar(orgid);

        format(infoStr, sizeof(infoStr), "[SUCESSO]: Local de equipar da Faccao %d criado com sucesso!", orgid);
        SendClientMessage(playerid, 0x2ECC71FF, infoStr);
    }
    return 1;
}

CMD:apagarlcq(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    
    new orgid;
    if(sscanf(params, "i", orgid)) return SendClientMessage(playerid, 0x95A5A6FF, "Uso correto: /apagarlcq [ID da Organizacao]");
    if(!LocalEquipar[orgid][lcCriado]) return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO]: Esta organizacao nao possui um ponto de equipar definido!");

    DestroyPickup(LocalEquipar[orgid][lcPickupID]);
    Delete3DTextLabel(LocalEquipar[orgid][lcTextID]);
    
    LocalEquipar[orgid][lcCriado] = false;
    SalvarLocalEquipar(orgid);

    SendClientMessage(playerid, 0x2ECC71FF, "[SUCESSO]: Ponto de equipar removido e arquivo atualizado!");
    return 1;
}

CMD:ajudalcq(playerid, params[])
{
    SendClientMessage(playerid, 0xF1C40FFF, "====== AJUDA GERENCIAMENTO DE EQUIPAR ======");
    SendClientMessage(playerid, -1, "/criarlcq [id] - Cria o pickup 1239 e texto 3D na sua posicao.");
    SendClientMessage(playerid, -1, "/apagarlcq [id] - Deleta o local da org selecionada.");
    SendClientMessage(playerid, -1, "/vertodoslcq - Exibe no chat os locais ativos.");
    return 1;
}

CMD:vertodoslcq(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    
    SendClientMessage(playerid, 0x3498DBFF, "=== Locais de Equipar Ativos ===");
    new str[128], count = 0;
    for(new i = 0; i < MAX_ORGS; i++)
    {
        if(LocalEquipar[i][lcCriado])
        {
            format(str, sizeof(str), "» Org ID: %d | Coordenadas: X: %.2f, Y: %.2f, Z: %.2f", i, LocalEquipar[i][lcX], LocalEquipar[i][lcY], LocalEquipar[i][lcZ]);
            SendClientMessage(playerid, -1, str);
            count++;
        }
    }
    if(count == 0) SendClientMessage(playerid, 0xE74C3CFF, "Nenhum ponto registrado no servidor.");
    return 1;
}


CMD:pegarbike(playerid, params[]) // Adicione [] aqui
{
    RealizarPegarBike(playerid);
    return 1;
}

CMD:criarspa(playerid, params)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < MAX_SPAWN_BIKES; i++)
    {
        if(!SpawnBikeInfo[i][spAtivo])
        {
            SpawnBikeInfo[i][spAtivo] = true;
            SpawnBikeInfo[i][spX] = x; SpawnBikeInfo[i][spY] = y; SpawnBikeInfo[i][spZ] = z;
            SpawnBikeInfo[i][spTextID] = CreateDynamic3DTextLabel("Spawn Civil", -1, x, y, z, 15.0);
            SpawnBikeInfo[i][spPickupID] = CreateDynamicPickup(1239, 1, x, y, z);
            return SendClientMessage(playerid, -1, "Spawn criado com sucesso!");
        }
    }
    return 1;
}
stock CarregarSpawnsBikes()
{
    new string[64];
    for(new i = 0; i < MAX_SPAWN_BIKES; i++)
    {
        format(string, sizeof(string), "SpawnsBikes/Spawn_%d.ini", i);
        if(DOF2_FileExists(string))
        {
            SpawnBikeInfo[i][spAtivo] = true;
            SpawnBikeInfo[i][spX] = DOF2_GetFloat(string, "X");
            SpawnBikeInfo[i][spY] = DOF2_GetFloat(string, "Y");
            SpawnBikeInfo[i][spZ] = DOF2_GetFloat(string, "Z");
            SpawnBikeInfo[i][spTextID] = CreateDynamic3DTextLabel("{FF3030}SPAWN DE QUAD{FFFFFF}\nAperte {FFFF00}H{FFFFFF} para pegar um Quad", -1, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ], 15.0);
            SpawnBikeInfo[i][spPickupID] = CreateDynamicPickup(1239, 1, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ]);
        }
    }
}
// Funcao que faz o trabalho real (sem ser um comando)
stock RealizarPegarBike(playerid)
{
    new Float:pos[4];
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    GetPlayerFacingAngle(playerid, pos[3]);
    new bike = CreateVehicle(471, pos[0], pos[1], pos[2]+1, pos[3], 3, 3, 60); // Quad
    PutPlayerInVehicle(playerid, bike, 0);
    VeiculoPlayer[playerid] = bike;
    LatariaHealth[bike] = 1000.0;
    LatariaPanels[bike] = 0;
    LatariaDoors[bike] = 0;
    LatariaLights[bike] = 0;
    LatariaTires[bike] = 0;
    SendClientMessage(playerid, 0xFF3030FF, "[QUAD] Quad retirado. Use /lataria para conferir o estado da lataria.");

    return 1;
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    new panels, doors, lights, tires;
    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
    LatariaPanels[vehicleid] = panels;
    LatariaDoors[vehicleid] = doors;
    LatariaLights[vehicleid] = lights;
    LatariaTires[vehicleid] = tires;
    GetVehicleHealth(vehicleid, LatariaHealth[vehicleid]);

    if(playerid != INVALID_PLAYER_ID && IsPlayerConnected(playerid))
    {
        new msg[144], estado[24];
        new Float:hp = LatariaHealth[vehicleid];
        if(hp >= 850.0) format(estado, sizeof estado, "BOA");
        else if(hp >= 600.0) format(estado, sizeof estado, "AMASSADA");
        else if(hp >= 350.0) format(estado, sizeof estado, "DANIFICADA");
        else format(estado, sizeof estado, "CRITICA");
        format(msg, sizeof msg, "[LATARIA] Estado: %s | Integridade: %.0f/1000", estado, hp);
        SendClientMessage(playerid, 0xFFD700FF, msg);
    }
    return 1;
}


CMD:quad(playerid, params[])
{
    for(new i = 0; i < MAX_SPAWN_BIKES; i++)
    {
        if(SpawnBikeInfo[i][spAtivo] &&
           IsPlayerInRangeOfPoint(playerid, 4.0, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ]))
        {
            RealizarPegarBike(playerid);
            return 1;
        }
    }
    return SendClientMessage(playerid, 0xFF3030FF, "[QUAD] Chegue perto do Spawn de Quad e aperte H.");
}







CMD:lataria(playerid, params[])
{
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, 0xFF3030FF, "[LATARIA] Voce precisa estar em um veiculo.");

    new vehicleid = GetPlayerVehicleID(playerid);
    new panels, doors, lights, tires, estado[24], msg[180];
    new Float:hp;
    GetVehicleHealth(vehicleid, hp);
    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

    if(hp >= 850.0) format(estado, sizeof estado, "BOA");
    else if(hp >= 600.0) format(estado, sizeof estado, "AMASSADA");
    else if(hp >= 350.0) format(estado, sizeof estado, "DANIFICADA");
    else format(estado, sizeof estado, "CRITICA");

    format(msg, sizeof msg, "[LATARIA] %s | Integridade %.0f/1000 | Paineis:%d | Portas:%d | Farois:%d | Pneus:%d",
        estado, hp, panels, doors, lights, tires);
    SendClientMessage(playerid, 0xFFD700FF, msg);
    return 1;
}

stock AbrirMenuConcessionaria(playerid)
{
    // Salva a posicao original do player para retornar apos o test-drive ou fechar
    GetPlayerPos(playerid, PosicaoOriginalPlayer[playerid][0], PosicaoOriginalPlayer[playerid][1], PosicaoOriginalPlayer[playerid][2]);
    GetPlayerFacingAngle(playerid, PosicaoOriginalPlayer[playerid][3]);

    ShowPlayerDialog(playerid, DIALOG_CONCE_MAIN, DIALOG_STYLE_LIST, 
        "{00FF00}CAR SHOP - NOME DO SERVIDOR", 
        "1. Carros\n2. Motos\n3. Outros (Vans/Bikes)\nSair", 
        "Selecionar", "Cancelar");
    return 1;
}
stock IniciarTestDrive(playerid, modelid)
{
    EmTestDrive[playerid] = true;

    // Remove o player da area comum e coloca no veiculo de teste
    TogglePlayerControllable(playerid, 0);
    
    new vid = CreateVehicle(modelid, TEST_SPAWN_X, TEST_SPAWN_Y, TEST_SPAWN_Z, TEST_SPAWN_A, 1, 1, 60000);
    PutPlayerInVehicle(playerid, vid, 0);
    
    TogglePlayerControllable(playerid, 1);

    SendClientMessage(playerid, -1, "{00FF00}[TEST-DRIVE]: {FFFFFF}Seu test-drive comecou! Voce tem {FFFF00}30 segundos{FFFFFF}.");

    // Agenda o termino do test-drive para daqui a 30 segundos (30000 milissegundos)
    TimerTestDrive[playerid] = SetTimerEx("FimTestDrive", 30000, false, "ii", playerid, vid);
    return 1;
}

forward FimTestDrive(playerid, vehicleid);
public FimTestDrive(playerid, vehicleid)
{
    if(!EmTestDrive[playerid]) return 1;

    EmTestDrive[playerid] = false;

    // Destroi o veiculo de test-drive
    DestroyVehicle(vehicleid);

    // Retorna o jogador para a posicao original onde ele abriu a concessionaria
    SetPlayerPos(playerid, PosicaoOriginalPlayer[playerid][0], PosicaoOriginalPlayer[playerid][1], PosicaoOriginalPlayer[playerid][2]);
    SetPlayerFacingAngle(playerid, PosicaoOriginalPlayer[playerid][3]);
    SetPlayerInterior(playerid, 0);

    SendClientMessage(playerid, -1, "{FFFF00}[TEST-DRIVE]: {FFFFFF}Seu tempo de test-drive acabou. Esperamos que tenha gostado!");
    return 1;
}
stock GetDefaultModelForOrg(orgid_param, slot_param)
{
    if(orgid_param == 15) // SAMU (Ambulancia)
    {
        return 416; 
    }
    else if(orgid_param == 33) // Mecanico 
    {
        new const mecv[4] = {525, 525, 413, 400};
        return mecv[slot_param];
    }
    else if((orgid_param >= 16 && orgid_param <= 32) || orgid_param == 28 || orgid_param == 29 || orgid_param == 30) // Faccões / Gangues
    {
        new const crimv[4] = {567, 482, 468, 587};
        return crimv[slot_param];
    }
    else // Policias, Exercito e demais Corporacões
    {
        new const corpov[4] = {596, 598, 427, 490};
        return corpov[slot_param];
    }
}

// ----------------------------------------------------------------------------
// FUNcÕES DE SALVAMENTO E CARREGAMENTO (DOF2) COM 3DTEXT E PICKUP
// ----------------------------------------------------------------------------
stock SalvarVeiculosOrg()
{
    new caminho[64];
    for(new org = 0; org < MAX_ORGS_VEHICLES; org++)
    {
        for(new slot = 0; slot < MAX_VEHS_PER_ORG; slot++)
        {
            if(OrgVehicles[org][slot][ovCriado])
            {
                format(caminho, sizeof(caminho), "Corporacoes/Veiculos/Org_%d_Slot_%d.ini", org, slot);
                
                if(!DOF2_FileExists(caminho))
                {
                    DOF2_CreateFile(caminho);
                }

                DOF2_SetInt(caminho, "Criado", OrgVehicles[org][slot][ovCriado]);
                DOF2_SetInt(caminho, "OrgID", OrgVehicles[org][slot][ovOrgID]);
                DOF2_SetInt(caminho, "ModelID", OrgVehicles[org][slot][ovModelID]);
                DOF2_SetFloat(caminho, "SpawnX", OrgVehicles[org][slot][ovSpawnX]);
                DOF2_SetFloat(caminho, "SpawnY", OrgVehicles[org][slot][ovSpawnY]);
                DOF2_SetFloat(caminho, "SpawnZ", OrgVehicles[org][slot][ovSpawnZ]);
                DOF2_SetFloat(caminho, "SpawnA", OrgVehicles[org][slot][ovSpawnA]);
            }
        }
    }
    DOF2_SaveFile();
}

stock CarregarVeiculosOrg()
{
    new caminho[64];
    for(new org = 0; org < MAX_ORGS_VEHICLES; org++)
    {
        for(new slot = 0; slot < MAX_VEHS_PER_ORG; slot++)
        {
            format(caminho, sizeof(caminho), "Corporacoes/Veiculos/Org_%d_Slot_%d.ini", org, slot);
            
            if(DOF2_FileExists(caminho))
            {
                OrgVehicles[org][slot][ovCriado] = DOF2_GetInt(caminho, "Criado");
                OrgVehicles[org][slot][ovOrgID] = DOF2_GetInt(caminho, "OrgID");
                OrgVehicles[org][slot][ovModelID] = DOF2_GetInt(caminho, "ModelID");
                OrgVehicles[org][slot][ovSpawnX] = DOF2_GetFloat(caminho, "SpawnX");
                OrgVehicles[org][slot][ovSpawnY] = DOF2_GetFloat(caminho, "SpawnY");
                OrgVehicles[org][slot][ovSpawnZ] = DOF2_GetFloat(caminho, "SpawnZ");
                OrgVehicles[org][slot][ovSpawnA] = DOF2_GetFloat(caminho, "SpawnA");
                OrgVehicles[org][slot][ovSpawnID] = 0; 

                // Criacao do 3DTextLabel dinamico e do Pickup ao carregar do arquivo
                new string_label[128], nome_org_txt[40];
                nome_org_txt = GetNomeOrg(org);

                format(string_label, sizeof(string_label), "{00BFFF}[ Spawn Orgs: %s ]\n{FFFFFF}Aperte 'F'", nome_org_txt);
                
                // Se estiver usando Streamer Plugin (CreateDynamic3DTextLabel / CreateDynamicPickup)
                OrgVehicles[org][slot][ovLabelID] = CreateDynamic3DTextLabel(string_label, -1, OrgVehicles[org][slot][ovSpawnX], OrgVehicles[org][slot][ovSpawnY], OrgVehicles[org][slot][ovSpawnZ] + 0.5, 20.0);
                OrgVehicles[org][slot][ovPickupID] = CreateDynamicPickup(1239, 1, OrgVehicles[org][slot][ovSpawnX], OrgVehicles[org][slot][ovSpawnY], OrgVehicles[org][slot][ovSpawnZ]);
            }
        }
    }
    print("[SERVER]: Veiculos e spawns de corporacões carregados com sucesso via DOF2.");
}

// ----------------------------------------------------------------------------
// COMANDO: /CRIAVEICULOORG
// ----------------------------------------------------------------------------
CMD:criaveiculoorg(playerid, params[])
{
    // Adicione sua verificação de ADM aqui se necessário (Ex: if(Pdados[playerid][Admin] < 4) return ...)

    new orgid_cmd = Pdados[playerid][OrgID];
    if(orgid_cmd <= 0)
        return SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Voce nao pertence a nenhuma organizacao para criar um veiculo dela.");

    // Procura automaticamente o primeiro slot livre (de 0 a 3) que a organização ainda não usou
    new slot_livre = -1;
    for(new i = 0; i < MAX_VEHS_PER_ORG; i++)
    {
        if(!OrgVehicles[orgid_cmd][i][ovCriado])
        {
            slot_livre = i;
            break;
        }
    }

    if(slot_livre == -1)
        return SendClientMessage(playerid, -1, "{FF0000}[ERRO]: {FFFFFF}Sua organizacao já atingiu o limite maximo de 4 veículos criados!");

    EditandoOrgVeh[playerid][0] = orgid_cmd;
    EditandoOrgVeh[playerid][1] = slot_livre;

    new string_dialogo[256], nomeorg[40];
    nomeorg = GetNomeOrg(orgid_cmd);

    format(string_dialogo, sizeof(string_dialogo), 
        "{FFFFFF}Organizacao Detectada: {00FF00}%s {999999}(ID: %d)\n{FFFFFF}Slot Automatico: {FFFF00}%d\n\n{FFFFFF}Deseja registrar o ponto atual como o local onde\nos membros da sua org apertam {00FFFF}F{FFFFFF} para pegar este veiculo?", 
        nomeorg, orgid_cmd, slot_livre);

    ShowPlayerDialog(playerid, DIALOG_CRIAR_ORG_VEH, DIALOG_STYLE_MSGBOX, "{FFFF00}Gerenciamento - Veiculos de Org", string_dialogo, "Salvar", "Cancelar");
    return 1;
}
CMD:invteste(playerid, params[]) 
{
    if (!IsInventoryOpen[playerid]) 
    {
        OpenCustomInventory(playerid);
    } 
    else
    {
        CloseCustomInventory(playerid);
    }
    return 1;
}

stock OpenCustomInventory(playerid) {
    if(BCG36Client[playerid]){BCG43Inventory(playerid);return;}
    if(IsInventoryOpen[playerid]) return;
    IsInventoryOpen[playerid] = true;
    SelectedInventorySlot[playerid] = -1;
    
    // Congela o jogador ao abrir o inventário
    TogglePlayerControllable(playerid, 0);
    
    new Float:startX = 125.000;
    new Float:startY = 170.000;
    
    // Criação dos 20 quadrados dos slots
    for(new i = 0; i < 20; i++) {
        new col = i % 5;
        new row = i / 5;
        
        GARISBAWAH[playerid][i] = CreatePlayerTextDraw(playerid, startX + (col * 40.0), startY + (row * 56.0), "LD_SPAC:white");
        PlayerTextDrawTextSize(playerid, GARISBAWAH[playerid][i], 39.000, 50.000);
        PlayerTextDrawAlignment(playerid, GARISBAWAH[playerid][i], 1);
        PlayerTextDrawColor(playerid, GARISBAWAH[playerid][i], 0x750A0AE8);
        PlayerTextDrawSetShadow(playerid, GARISBAWAH[playerid][i], 0);
        PlayerTextDrawSetOutline(playerid, GARISBAWAH[playerid][i], 0);
        PlayerTextDrawBackgroundColor(playerid, GARISBAWAH[playerid][i], 255);
        PlayerTextDrawFont(playerid, GARISBAWAH[playerid][i], 4);
        PlayerTextDrawSetProportional(playerid, GARISBAWAH[playerid][i], 1);
        PlayerTextDrawSetSelectable(playerid, GARISBAWAH[playerid][i], 1);

        // Preview do modelo 3D do item no slot (só renderiza se houver quantidade > 0)
        INVSLOTPREVIEW[playerid][i] = CreatePlayerTextDraw(playerid, startX + (col * 40.0) + 2.0, startY + (row * 56.0) + 5.0, "Preview_Model");
        PlayerTextDrawFont(playerid, INVSLOTPREVIEW[playerid][i], 5);
        PlayerTextDrawLetterSize(playerid, INVSLOTPREVIEW[playerid][i], 0.600000, 2.000000);
        PlayerTextDrawTextSize(playerid, INVSLOTPREVIEW[playerid][i], 35.000000, 40.000000);
        PlayerTextDrawSetOutline(playerid, INVSLOTPREVIEW[playerid][i], 0);
        PlayerTextDrawSetShadow(playerid, INVSLOTPREVIEW[playerid][i], 0);
        PlayerTextDrawAlignment(playerid, INVSLOTPREVIEW[playerid][i], 1);
        PlayerTextDrawColor(playerid, INVSLOTPREVIEW[playerid][i], -1);
        PlayerTextDrawBackgroundColor(playerid, INVSLOTPREVIEW[playerid][i], 0);
        PlayerTextDrawUseBox(playerid, INVSLOTPREVIEW[playerid][i], 0);
        PlayerTextDrawSetProportional(playerid, INVSLOTPREVIEW[playerid][i], 1);
        PlayerTextDrawSetSelectable(playerid, INVSLOTPREVIEW[playerid][i], 0);
        
        if(PlayerInventory[playerid][i][itemQuantity] > 0) {
            PlayerTextDrawSetPreviewModel(playerid, INVSLOTPREVIEW[playerid][i], PlayerInventory[playerid][i][itemModel]);
            PlayerTextDrawSetPreviewRot(playerid, INVSLOTPREVIEW[playerid][i], -10.000000, 0.000000, -20.000000, 1.000000);
        } else {
            PlayerTextDrawSetPreviewModel(playerid, INVSLOTPREVIEW[playerid][i], 0);
        }
    }

	INVNAME[playerid][0] = CreatePlayerTextDraw(playerid, 118.000, 96.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVNAME[playerid][0], 213.000, 300.000);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][0], 1);
	PlayerTextDrawColor(playerid, INVNAME[playerid][0], 0x220202AA);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][0], 255);
	PlayerTextDrawFont(playerid, INVNAME[playerid][0], 4);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][0], 1);

	INVNAME[playerid][1] = CreatePlayerTextDraw(playerid, 125.000, 115.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVNAME[playerid][1], 199.000, 3.000);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][1], 1);
	PlayerTextDrawColor(playerid, INVNAME[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][1], 255);
	PlayerTextDrawFont(playerid, INVNAME[playerid][1], 4);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][1], 1);

	INVNAME[playerid][2] = CreatePlayerTextDraw(playerid, 126.000, 115.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVNAME[playerid][2], 165.000, 3.000);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][2], 1);
	PlayerTextDrawColor(playerid, INVNAME[playerid][2], 0x750A0AE8);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][2], 255);
	PlayerTextDrawFont(playerid, INVNAME[playerid][2], 4);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][2], 1);

	INVNAME[playerid][3] = CreatePlayerTextDraw(playerid, 126.000, 105.000, "Inventario");
	PlayerTextDrawLetterSize(playerid, INVNAME[playerid][3], 0.140, 0.898);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][3], 1);
	PlayerTextDrawColor(playerid, INVNAME[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][3], 150);
	PlayerTextDrawFont(playerid, INVNAME[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][3], 1);

	INVNAME[playerid][4] = CreatePlayerTextDraw(playerid, 324.000, 105.000, "100/300");
	PlayerTextDrawLetterSize(playerid, INVNAME[playerid][4], 0.140, 0.699);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][4], 3);
	PlayerTextDrawColor(playerid, INVNAME[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][4], 150);
	PlayerTextDrawFont(playerid, INVNAME[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][4], 1);

	INVNAME[playerid][5] = CreatePlayerTextDraw(playerid, 295.000, 104.000, "H");
	PlayerTextDrawLetterSize(playerid, INVNAME[playerid][5], 0.200, 0.898);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][5], 3);
	PlayerTextDrawColor(playerid, INVNAME[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][5], 150);
	PlayerTextDrawFont(playerid, INVNAME[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][5], 1);

    INVNAME[playerid][6] = CreatePlayerTextDraw(playerid, 126.000, 370.000, "Nenhum item selecionado");
	PlayerTextDrawLetterSize(playerid, INVNAME[playerid][6], 0.150, 0.800);
	PlayerTextDrawAlignment(playerid, INVNAME[playerid][6], 1);
	PlayerTextDrawColor(playerid, INVNAME[playerid][6], 0xFFFFFFFF);
	PlayerTextDrawSetShadow(playerid, INVNAME[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, INVNAME[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, INVNAME[playerid][6], 150);
	PlayerTextDrawFont(playerid, INVNAME[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, INVNAME[playerid][6], 1);

    INVINFO[playerid][0] = CreatePlayerTextDraw(playerid, 347.000, 168.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVINFO[playerid][0], 55.000, 160.000);
	PlayerTextDrawAlignment(playerid, INVINFO[playerid][0], 1);
	PlayerTextDrawColor(playerid, INVINFO[playerid][0], 0x220202AA);
	PlayerTextDrawSetShadow(playerid, INVINFO[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, INVINFO[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, INVINFO[playerid][0], 255);
	PlayerTextDrawFont(playerid, INVINFO[playerid][0], 4);
	PlayerTextDrawSetProportional(playerid, INVINFO[playerid][0], 1);

	// USAR
	INVINFO[playerid][1] = CreatePlayerTextDraw(playerid, 352.000, 174.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVINFO[playerid][1], 45.000, 18.000);
	PlayerTextDrawAlignment(playerid, INVINFO[playerid][1], 1);
	PlayerTextDrawColor(playerid, INVINFO[playerid][1], 0x750A0AE8);
	PlayerTextDrawSetShadow(playerid, INVINFO[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, INVINFO[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, INVINFO[playerid][1], 255);
	PlayerTextDrawFont(playerid, INVINFO[playerid][1], 4);
	PlayerTextDrawSetProportional(playerid, INVINFO[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, INVINFO[playerid][1], 1);

    INVINFO[playerid][5] = CreatePlayerTextDraw(playerid, 374.000, 179.000, "USAR");
    PlayerTextDrawLetterSize(playerid, INVINFO[playerid][5], 0.150, 0.799);
    PlayerTextDrawAlignment(playerid, INVINFO[playerid][5], 2);
    PlayerTextDrawColor(playerid, INVINFO[playerid][5], -1);
    PlayerTextDrawSetShadow(playerid, INVINFO[playerid][5], 0);
    PlayerTextDrawSetOutline(playerid, INVINFO[playerid][5], 0);
    PlayerTextDrawFont(playerid, INVINFO[playerid][5], 1);
    PlayerTextDrawSetProportional(playerid, INVINFO[playerid][5], 1);

	// ENVIAR
	INVINFO[playerid][2] = CreatePlayerTextDraw(playerid, 352.000, 195.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVINFO[playerid][2], 45.000, 18.000);
	PlayerTextDrawAlignment(playerid, INVINFO[playerid][2], 1);
	PlayerTextDrawColor(playerid, INVINFO[playerid][2], 0x750A0AE8);
	PlayerTextDrawSetShadow(playerid, INVINFO[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, INVINFO[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, INVINFO[playerid][2], 255);
	PlayerTextDrawFont(playerid, INVINFO[playerid][2], 4);
	PlayerTextDrawSetProportional(playerid, INVINFO[playerid][2], 1);
	PlayerTextDrawSetSelectable(playerid, INVINFO[playerid][2], 1);

    INVINFO[playerid][6] = CreatePlayerTextDraw(playerid, 374.000, 200.000, "ENVIAR");
    PlayerTextDrawLetterSize(playerid, INVINFO[playerid][6], 0.150, 0.799);
    PlayerTextDrawAlignment(playerid, INVINFO[playerid][6], 2);
    PlayerTextDrawColor(playerid, INVINFO[playerid][6], -1);
    PlayerTextDrawSetShadow(playerid, INVINFO[playerid][6], 0);
    PlayerTextDrawSetOutline(playerid, INVINFO[playerid][6], 0);
    PlayerTextDrawFont(playerid, INVINFO[playerid][6], 1);
    PlayerTextDrawSetProportional(playerid, INVINFO[playerid][6], 1);

	// LIXO
	INVINFO[playerid][3] = CreatePlayerTextDraw(playerid, 352.000, 216.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVINFO[playerid][3], 45.000, 18.000);
	PlayerTextDrawAlignment(playerid, INVINFO[playerid][3], 1);
	PlayerTextDrawColor(playerid, INVINFO[playerid][3], 0x750A0AE8);
	PlayerTextDrawSetShadow(playerid, INVINFO[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, INVINFO[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, INVINFO[playerid][3], 255);
	PlayerTextDrawFont(playerid, INVINFO[playerid][3], 4);
	PlayerTextDrawSetProportional(playerid, INVINFO[playerid][3], 1);
	PlayerTextDrawSetSelectable(playerid, INVINFO[playerid][3], 1);

    INVINFO[playerid][7] = CreatePlayerTextDraw(playerid, 374.000, 221.000, "LIXO");
    PlayerTextDrawLetterSize(playerid, INVINFO[playerid][7], 0.150, 0.799);
    PlayerTextDrawAlignment(playerid, INVINFO[playerid][7], 2);
    PlayerTextDrawColor(playerid, INVINFO[playerid][7], -1);
    PlayerTextDrawSetShadow(playerid, INVINFO[playerid][7], 0);
    PlayerTextDrawSetOutline(playerid, INVINFO[playerid][7], 0);
    PlayerTextDrawFont(playerid, INVINFO[playerid][7], 1);
    PlayerTextDrawSetProportional(playerid, INVINFO[playerid][7], 1);

	// INFO
	INVINFO[playerid][4] = CreatePlayerTextDraw(playerid, 352.000, 237.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVINFO[playerid][4], 45.000, 18.000);
	PlayerTextDrawAlignment(playerid, INVINFO[playerid][4], 1);
	PlayerTextDrawColor(playerid, INVINFO[playerid][4], 0x750A0AE8);
	PlayerTextDrawSetShadow(playerid, INVINFO[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, INVINFO[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, INVINFO[playerid][4], 255);
	PlayerTextDrawFont(playerid, INVINFO[playerid][4], 4);
	PlayerTextDrawSetProportional(playerid, INVINFO[playerid][4], 1);
	PlayerTextDrawSetSelectable(playerid, INVINFO[playerid][4], 1);

    INVINFO[playerid][8] = CreatePlayerTextDraw(playerid, 374.000, 242.000, "INFO");
    PlayerTextDrawLetterSize(playerid, INVINFO[playerid][8], 0.150, 0.799);
    PlayerTextDrawAlignment(playerid, INVINFO[playerid][8], 2);
    PlayerTextDrawColor(playerid, INVINFO[playerid][8], -1);
    PlayerTextDrawSetShadow(playerid, INVINFO[playerid][8], 0);
    PlayerTextDrawSetOutline(playerid, INVINFO[playerid][8], 0);
    PlayerTextDrawFont(playerid, INVINFO[playerid][8], 1);
    PlayerTextDrawSetProportional(playerid, INVINFO[playerid][8], 1);

    // FECHAR
    INVINFO[playerid][9] = CreatePlayerTextDraw(playerid, 352.000, 258.000, "LD_SPAC:white");
	PlayerTextDrawTextSize(playerid, INVINFO[playerid][9], 45.000, 18.000);
	PlayerTextDrawAlignment(playerid, INVINFO[playerid][9], 1);
	PlayerTextDrawColor(playerid, INVINFO[playerid][9], 0x750A0AE8);
	PlayerTextDrawSetShadow(playerid, INVINFO[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, INVINFO[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, INVINFO[playerid][9], 255);
	PlayerTextDrawFont(playerid, INVINFO[playerid][9], 4);
	PlayerTextDrawSetProportional(playerid, INVINFO[playerid][9], 1);
	PlayerTextDrawSetSelectable(playerid, INVINFO[playerid][9], 1);

    INVINFO[playerid][10] = CreatePlayerTextDraw(playerid, 374.000, 263.000, "FECHAR");
    PlayerTextDrawLetterSize(playerid, INVINFO[playerid][10], 0.150, 0.799);
    PlayerTextDrawAlignment(playerid, INVINFO[playerid][10], 2);
    PlayerTextDrawColor(playerid, INVINFO[playerid][10], -1);
    PlayerTextDrawSetShadow(playerid, INVINFO[playerid][10], 0);
    PlayerTextDrawSetOutline(playerid, INVINFO[playerid][10], 0);
    PlayerTextDrawFont(playerid, INVINFO[playerid][10], 1);
    PlayerTextDrawSetProportional(playerid, INVINFO[playerid][10], 1);

    for(new i = 0; i < 20; i++) {
        PlayerTextDrawShow(playerid, GARISBAWAH[playerid][i]);
        PlayerTextDrawShow(playerid, INVSLOTPREVIEW[playerid][i]);
    }
    for(new i = 0; i < 7; i++) {
        PlayerTextDrawShow(playerid, INVNAME[playerid][i]);
    }
    for(new i = 0; i < 11; i++) {
        PlayerTextDrawShow(playerid, INVINFO[playerid][i]);
    }

	SelectTextDraw(playerid, 0xA3B4C2FF);
}

stock CloseCustomInventory(playerid) {
    if(!IsInventoryOpen[playerid]) return;
    IsInventoryOpen[playerid] = false;
    SelectedInventorySlot[playerid] = -1;
    
    // Descongela o jogador ao fechar o inventário
    TogglePlayerControllable(playerid, 1);
    
    for(new i = 0; i < 20; i++) {
        PlayerTextDrawDestroy(playerid, GARISBAWAH[playerid][i]);
        PlayerTextDrawDestroy(playerid, INVSLOTPREVIEW[playerid][i]);
    }
    for(new i = 0; i < 7; i++) {
        PlayerTextDrawDestroy(playerid, INVNAME[playerid][i]);
    }
    for(new i = 0; i < 11; i++) {
        PlayerTextDrawDestroy(playerid, INVINFO[playerid][i]);
    }
    
    CancelSelectTextDraw(playerid);
}

// Adiciona itens comprados diretamente no inventário livre
stock GivePlayerItem(playerid, const name[], itemModelLocal, quantity) {
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++) {
        if(PlayerInventory[playerid][i][itemQuantity] == 0) {
            format(PlayerInventory[playerid][i][itemName], 32, "%s", name);
            PlayerInventory[playerid][i][itemModel] = itemModelLocal; // Corrigido aqui
            PlayerInventory[playerid][i][itemQuantity] = quantity;
            PlayerInventory[playerid][i][itemIsEquipment] = true;
            return 1;
        }
    }
    return 0; // Inventário cheio
}
stock InitMorteFiveM() {
    g_DB_Morte = db_open("coma_persistente.db");
    db_query(g_DB_Morte, "CREATE TABLE IF NOT EXISTS comas (Nome TEXT UNIQUE, EmComa INTEGER, X REAL, Y REAL, Z REAL, A REAL, VW INTEGER, INT INTEGER)");
    
    for(new i = 0; i < MAX_PLAYERS; i++) {
        TD_MorteFundo[i]  = Text:INVALID_TEXT_DRAW;
        TD_MortePainel[i]  = Text:INVALID_TEXT_DRAW;
        TD_MorteIcone[i]   = Text:INVALID_TEXT_DRAW;
        TD_MorteTitulo[i]  = Text:INVALID_TEXT_DRAW;
        TD_MorteLinha[i]   = Text:INVALID_TEXT_DRAW;
        TD_MorteTexto[i]   = Text:INVALID_TEXT_DRAW;
        TD_MorteAviso[i]   = Text:INVALID_TEXT_DRAW;
        TD_MorteBotaoDesistir[i] = Text:INVALID_TEXT_DRAW;
        TD_MorteBotaoDesistirTxt[i] = Text:INVALID_TEXT_DRAW;
        TD_MorteBotaoMedico[i] = Text:INVALID_TEXT_DRAW;
        TD_MorteBotaoMedicoTxt[i] = Text:INVALID_TEXT_DRAW;
    }
    return 1;
}

// Função para Fechar o Banco (Chamar em OnGameModeExit)
stock ExitMorteFiveM() {
    db_close(g_DB_Morte);
    return 1;
}

stock CriarTextDrawsMortePlayer(playerid) {
    DestruirTextDrawsMortePlayer(playerid);

    // Tela de ferido inspirada na referencia enviada: fundo escurecido,
    // texto central e dois botoes de acao.
    TD_MorteFundo[playerid] = TextDrawCreate(0.0, 0.0, "ld_spac:white");
    TextDrawFont(TD_MorteFundo[playerid], 4);
    TextDrawColor(TD_MorteFundo[playerid], 0x000000A8);
    TextDrawTextSize(TD_MorteFundo[playerid], 640.0, 480.0);

    // Titulo.
    TD_MorteTitulo[playerid] = TextDrawCreate(320.0, 185.0, "VOCE ESTA GRAVEMENTE FERIDO");
    TextDrawFont(TD_MorteTitulo[playerid], 3);
    TextDrawLetterSize(TD_MorteTitulo[playerid], 0.43, 1.65);
    TextDrawColor(TD_MorteTitulo[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_MorteTitulo[playerid], 2);
    TextDrawSetOutline(TD_MorteTitulo[playerid], 2);
    TextDrawSetProportional(TD_MorteTitulo[playerid], 1);

    // Contador em vermelho.
    TD_MorteTexto[playerid] = TextDrawCreate(320.0, 225.0, "03:00");
    TextDrawFont(TD_MorteTexto[playerid], 3);
    TextDrawLetterSize(TD_MorteTexto[playerid], 0.48, 1.75);
    TextDrawColor(TD_MorteTexto[playerid], 0xFF3030FF);
    TextDrawAlignment(TD_MorteTexto[playerid], 2);
    TextDrawSetOutline(TD_MorteTexto[playerid], 2);
    TextDrawSetProportional(TD_MorteTexto[playerid], 1);

    // Texto explicativo.
    TD_MorteAviso[playerid] = TextDrawCreate(320.0, 265.0, "Voce esta gravemente ferido. Quando esse tempo acabar, voce pode\naceitar a morte e ir para o hospital. Se desconectar, voltara\na mesma posicao onde esta morto ao realizar o login.");
    TextDrawFont(TD_MorteAviso[playerid], 1);
    TextDrawLetterSize(TD_MorteAviso[playerid], 0.20, 0.92);
    TextDrawColor(TD_MorteAviso[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_MorteAviso[playerid], 2);
    TextDrawSetOutline(TD_MorteAviso[playerid], 1);
    TextDrawSetProportional(TD_MorteAviso[playerid], 1);

    // Botao vermelho: desistir/morte.
    TD_MorteBotaoDesistir[playerid] = TextDrawCreate(235.0, 320.0, "ld_spac:white");
    TextDrawFont(TD_MorteBotaoDesistir[playerid], 4);
    TextDrawColor(TD_MorteBotaoDesistir[playerid], 0xE62B2BFF);
    TextDrawTextSize(TD_MorteBotaoDesistir[playerid], 170.0, 30.0);
    TextDrawSetSelectable(TD_MorteBotaoDesistir[playerid], 1);

    TD_MorteBotaoDesistirTxt[playerid] = TextDrawCreate(320.0, 327.0, "DESISTIR AGORA");
    TextDrawFont(TD_MorteBotaoDesistirTxt[playerid], 2);
    TextDrawLetterSize(TD_MorteBotaoDesistirTxt[playerid], 0.24, 1.0);
    TextDrawColor(TD_MorteBotaoDesistirTxt[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_MorteBotaoDesistirTxt[playerid], 2);
    TextDrawSetOutline(TD_MorteBotaoDesistirTxt[playerid], 1);
    TextDrawSetProportional(TD_MorteBotaoDesistirTxt[playerid], 1);
    TextDrawSetSelectable(TD_MorteBotaoDesistirTxt[playerid], 1);

    // Botao verde: chamar medico.
    TD_MorteBotaoMedico[playerid] = TextDrawCreate(235.0, 362.0, "ld_spac:white");
    TextDrawFont(TD_MorteBotaoMedico[playerid], 4);
    TextDrawColor(TD_MorteBotaoMedico[playerid], 0x20B84AFF);
    TextDrawTextSize(TD_MorteBotaoMedico[playerid], 170.0, 30.0);
    TextDrawSetSelectable(TD_MorteBotaoMedico[playerid], 1);

    TD_MorteBotaoMedicoTxt[playerid] = TextDrawCreate(320.0, 369.0, "CHAMAR MEDICO");
    TextDrawFont(TD_MorteBotaoMedicoTxt[playerid], 2);
    TextDrawLetterSize(TD_MorteBotaoMedicoTxt[playerid], 0.24, 1.0);
    TextDrawColor(TD_MorteBotaoMedicoTxt[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_MorteBotaoMedicoTxt[playerid], 2);
    TextDrawSetOutline(TD_MorteBotaoMedicoTxt[playerid], 1);
    TextDrawSetProportional(TD_MorteBotaoMedicoTxt[playerid], 1);
    TextDrawSetSelectable(TD_MorteBotaoMedicoTxt[playerid], 1);

    return 1;
}

stock DestruirTextDrawsMortePlayer(playerid) {
    if(TD_MorteFundo[playerid] != Text:INVALID_TEXT_DRAW)  { TextDrawDestroy(TD_MorteFundo[playerid]); TD_MorteFundo[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MortePainel[playerid] != Text:INVALID_TEXT_DRAW)  { TextDrawDestroy(TD_MortePainel[playerid]); TD_MortePainel[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteIcone[playerid] != Text:INVALID_TEXT_DRAW)   { TextDrawDestroy(TD_MorteIcone[playerid]); TD_MorteIcone[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteTitulo[playerid] != Text:INVALID_TEXT_DRAW)  { TextDrawDestroy(TD_MorteTitulo[playerid]); TD_MorteTitulo[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteLinha[playerid] != Text:INVALID_TEXT_DRAW)   { TextDrawDestroy(TD_MorteLinha[playerid]); TD_MorteLinha[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteTexto[playerid] != Text:INVALID_TEXT_DRAW)   { TextDrawDestroy(TD_MorteTexto[playerid]); TD_MorteTexto[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteAviso[playerid] != Text:INVALID_TEXT_DRAW)   { TextDrawDestroy(TD_MorteAviso[playerid]); TD_MorteAviso[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteBotaoDesistir[playerid] != Text:INVALID_TEXT_DRAW) { TextDrawDestroy(TD_MorteBotaoDesistir[playerid]); TD_MorteBotaoDesistir[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteBotaoDesistirTxt[playerid] != Text:INVALID_TEXT_DRAW) { TextDrawDestroy(TD_MorteBotaoDesistirTxt[playerid]); TD_MorteBotaoDesistirTxt[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteBotaoMedico[playerid] != Text:INVALID_TEXT_DRAW) { TextDrawDestroy(TD_MorteBotaoMedico[playerid]); TD_MorteBotaoMedico[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteBotaoMedicoTxt[playerid] != Text:INVALID_TEXT_DRAW) { TextDrawDestroy(TD_MorteBotaoMedicoTxt[playerid]); TD_MorteBotaoMedicoTxt[playerid] = Text:INVALID_TEXT_DRAW; }
}

stock VerificarComaAoEntrar(playerid) {
    new name[MAX_PLAYER_NAME], query[128], DBResult:res;
    GetPlayerName(playerid, name, sizeof(name));
    
    format(query, sizeof(query), "SELECT * FROM comas WHERE Nome = '%s'", name);
    res = db_query(g_DB_Morte, query);
    
    if(db_num_rows(res) > 0) {
        new statusComa = db_get_field_assoc_int(res, "EmComa");
        if(statusComa == 1) {
            g_DadosMorte[playerid][pEmComa] = true;
            g_DadosMorte[playerid][pMortoX] = db_get_field_assoc_float(res, "X");
            g_DadosMorte[playerid][pMortoY] = db_get_field_assoc_float(res, "Y");
            g_DadosMorte[playerid][pMortoZ] = db_get_field_assoc_float(res, "Z");
            g_DadosMorte[playerid][pMortoA] = db_get_field_assoc_float(res, "A");
            g_DadosMorte[playerid][pMortoVirtualWorld] = db_get_field_assoc_int(res, "VW");
            g_DadosMorte[playerid][pMortoInterior] = db_get_field_assoc_int(res, "INT");
            
            g_DadosMorte[playerid][pTempoRestanteComa] = SEGUNDOS_COMA;
            g_DadosMorte[playerid][pTempoRestanteDesistir] = SEGUNDOS_DESISTIR;
            g_DadosMorte[playerid][pPodeDesistir] = false;

            KillTimer(g_DadosMorte[playerid][pTimerCicloSegundo]);
            g_DadosMorte[playerid][pTimerCicloSegundo] = SetTimerEx("OnComaSecondUpdate", 1000, true, "d", playerid);

            AplicarEfeitosDeComa(playerid);
        }
    }
    db_free_result(res);
    return 1;
}

stock SalvarComaAoSair(playerid) {
    new name[MAX_PLAYER_NAME], query[300];
    GetPlayerName(playerid, name, sizeof(name));

    if(g_DadosMorte[playerid][pEmComa]) {
        format(query, sizeof(query), "INSERT OR REPLACE INTO comas (Nome, EmComa, X, Y, Z, A, VW, INT) VALUES ('%s', 1, %f, %f, %f, %f, %d, %d)",
            name, g_DadosMorte[playerid][pMortoX], g_DadosMorte[playerid][pMortoY], g_DadosMorte[playerid][pMortoZ], 
            g_DadosMorte[playerid][pMortoA], g_DadosMorte[playerid][pMortoVirtualWorld], g_DadosMorte[playerid][pMortoInterior]);
        db_query(g_DB_Morte, query);
    } else {
        format(query, sizeof(query), "DELETE FROM comas WHERE Nome = '%s'", name);
        db_query(g_DB_Morte, query);
    }
    
    KillTimer(g_DadosMorte[playerid][pTimerCicloSegundo]);
    DestruirTextDrawsMortePlayer(playerid);
    return 1;
}

stock IniciarEstadoComa(playerid) {
    GetPlayerPos(playerid, g_DadosMorte[playerid][pMortoX], g_DadosMorte[playerid][pMortoY], g_DadosMorte[playerid][pMortoZ]);
    GetPlayerFacingAngle(playerid, g_DadosMorte[playerid][pMortoA]);
    
    g_DadosMorte[playerid][pMortoVirtualWorld] = GetPlayerVirtualWorld(playerid);
    g_DadosMorte[playerid][pMortoInterior] = GetPlayerInterior(playerid);
    g_DadosMorte[playerid][pEmComa] = true;
    g_DadosMorte[playerid][pPodeDesistir] = false;

    g_DadosMorte[playerid][pTempoRestanteComa] = SEGUNDOS_COMA;
    g_DadosMorte[playerid][pTempoRestanteDesistir] = SEGUNDOS_DESISTIR;

    KillTimer(g_DadosMorte[playerid][pTimerCicloSegundo]);
    g_DadosMorte[playerid][pTimerCicloSegundo] = SetTimerEx("OnComaSecondUpdate", 1000, true, "d", playerid);
    return 1;
}

stock AplicarEfeitosDeComa(playerid) {
    new Float:x = g_DadosMorte[playerid][pMortoX];
    new Float:y = g_DadosMorte[playerid][pMortoY];
    new Float:z = g_DadosMorte[playerid][pMortoZ];

    SetPlayerPos(playerid, x, y, z);
    SetPlayerFacingAngle(playerid, g_DadosMorte[playerid][pMortoA]);
    SetPlayerVirtualWorld(playerid, g_DadosMorte[playerid][pMortoVirtualWorld]);
    SetPlayerInterior(playerid, g_DadosMorte[playerid][pMortoInterior]);

    TogglePlayerControllable(playerid, false);
    ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 1, 0); 

    CriarTextDrawsMortePlayer(playerid);
    TextDrawShowForPlayer(playerid, TD_MorteFundo[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteTitulo[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteAviso[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteBotaoDesistir[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteBotaoDesistirTxt[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteBotaoMedico[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteBotaoMedicoTxt[playerid]);
    SelectTextDraw(playerid, 0xFFFFFFFF);
    
    AtualizarTextDrawTempo(playerid);

    SetTimerEx("SetarCameraMorteSegura", 250, false, "d", playerid);

    if(!IsValidDynamicObject(g_DadosMorte[playerid][pObjetoMaca])) {
        g_DadosMorte[playerid][pObjetoMaca] = CreateDynamicObject(19949, x, y, z - 0.95, 0.0, 0.0, g_DadosMorte[playerid][pMortoA]);
    }
    return 1;
}

forward SetarCameraMorteSegura(playerid);
public SetarCameraMorteSegura(playerid) {
    if(!g_DadosMorte[playerid][pEmComa]) return 0;
    new Float:x = g_DadosMorte[playerid][pMortoX];
    new Float:y = g_DadosMorte[playerid][pMortoY];
    new Float:z = g_DadosMorte[playerid][pMortoZ];
    
    SetPlayerCameraPos(playerid, x, y + 2.0, z + 4.8);
    SetPlayerCameraLookAt(playerid, x, y, z, CAMERA_CUT);
    return 1;
}

static stock AtualizarTextDrawTempo(playerid) {
    if(!g_DadosMorte[playerid][pEmComa]) return 0;

    new str[64];
    new minutosComa = g_DadosMorte[playerid][pTempoRestanteComa] / 60;
    new seg = g_DadosMorte[playerid][pTempoRestanteComa] % 60;
    format(str, sizeof(str), "%02d:%02d", minutosComa, seg);
    
    TextDrawSetString(TD_MorteTexto[playerid], str);
    TextDrawShowForPlayer(playerid, TD_MorteTexto[playerid]);
    return 1;
}

forward OnComaSecondUpdate(playerid);
public OnComaSecondUpdate(playerid) {
    if(!g_DadosMorte[playerid][pEmComa]) {
        KillTimer(g_DadosMorte[playerid][pTimerCicloSegundo]);
        return 0;
    }

    if(!g_DadosMorte[playerid][pPodeDesistir]) {
        g_DadosMorte[playerid][pTempoRestanteDesistir]--;
        if(g_DadosMorte[playerid][pTempoRestanteDesistir] <= 0) {
            g_DadosMorte[playerid][pPodeDesistir] = true;
            SendClientMessage(playerid, 0x00FF00AA, "[VITAIS] Seus batimentos estabilizaram. O comando /desistir foi liberado!");
        }
    }

    g_DadosMorte[playerid][pTempoRestanteComa]--;
    AtualizarTextDrawTempo(playerid);

    if(g_DadosMorte[playerid][pTempoRestanteComa] <= 0) {
        KillTimer(g_DadosMorte[playerid][pTimerCicloSegundo]);
        FinalizarComaGeral(playerid, true);
    }
    return 1;
}

stock InterceptalSpawnMorte(playerid) {
    if(g_DadosMorte[playerid][pEmComa]) {
        AplicarEfeitosDeComa(playerid);
        return 1;
    }
    return 0;
}

stock FinalizarComaGeral(playerid, bool:mandarHospital) {
    g_DadosMorte[playerid][pEmComa] = false;
    g_DadosMorte[playerid][pPodeDesistir] = false;
    
    KillTimer(g_DadosMorte[playerid][pTimerCicloSegundo]);
    
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    SetCameraBehindPlayer(playerid);

    if(IsValidDynamicObject(g_DadosMorte[playerid][pObjetoMaca])) {
        DestroyDynamicObject(g_DadosMorte[playerid][pObjetoMaca]);
        g_DadosMorte[playerid][pObjetoMaca] = INVALID_OBJECT_ID;
    }

    CancelSelectTextDraw(playerid);
    DestruirTextDrawsMortePlayer(playerid);

    new name[MAX_PLAYER_NAME], query[100];
    GetPlayerName(playerid, name, sizeof(name));
    format(query, sizeof(query), "DELETE FROM comas WHERE Nome = '%s'", name);
    db_query(g_DB_Morte, query);

    if(mandarHospital) {
        SetPlayerPos(playerid, 1172.0, -1323.0, 15.0); 
        SetPlayerHealth(playerid, 65.0);
        SendClientMessage(playerid, 0x00FF00AA, "[HOSPITAL] Voce recebeu tratamento emergencial e seus ferimentos foram fechados.");
    }
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(!g_DadosMorte[playerid][pEmComa]) return 0;

    if(clickedid == TD_MorteBotaoMedico[playerid] || clickedid == TD_MorteBotaoMedicoTxt[playerid])
    {
        new string[160], pName[MAX_PLAYER_NAME];
        GetPlayerName(playerid, pName, sizeof(pName));
        SendClientMessage(playerid, 0x33CCFFFF, "[EMERGENCIA] Voce chamou os medicos. Aguarde atendimento!");
        format(string, sizeof(string), "[RADIO] Vitima %s esta gravemente ferida e solicitou atendimento.", pName);
        foreach(new i : Player)
        {
            if(Pdados[i][OrgID] == 15) SendClientMessage(i, 0xFFFF00FF, string);
        }
        return 1;
    }

    if(clickedid == TD_MorteBotaoDesistir[playerid] || clickedid == TD_MorteBotaoDesistirTxt[playerid])
    {
        if(!g_DadosMorte[playerid][pPodeDesistir])
        {
            SendClientMessage(playerid, 0xFF3030FF, "[ERRO] Aguarde o tempo de desistir terminar.");
            return 1;
        }
        CancelSelectTextDraw(playerid);
        FinalizarComaGeral(playerid, true);
        return 1;
    }
    return 0;
}

// ==========================================
// CALLBACKS DO GM PRINCIPAL PARA INTEGRAR
// ==========================================

// Cole dentro de OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

stock TratarTeclaMorte(playerid, newkeys, oldkeys) {
    if(g_DadosMorte[playerid][pEmComa]) {
        if(PRESSED(KEY_WALK)) { // Tecla G / Andar aciona o pedido de ajuda aos médicos
            SendClientMessage(playerid, 0x33CCFFAA, "[EMERGENCIA] Voce chamou os paramédicos locais. Aguarde atendimento!");
            
            new string[140], pName[MAX_PLAYER_NAME];
            GetPlayerName(playerid, pName, sizeof(pName));
            format(string, sizeof(string), "[RADIO] Vitima %s esta desacordada! Verifique o mapa.", pName);
            
            // Loop para avisar apenas os membros da organização médica (ID 15)
            foreach(new i : Player) {
                // Altere 'PlayerInfo[i][pMembro]' se a sua variável de org tiver outro nome no seu gamemode
                if(Pdados[i][OrgID] == 15) {
                    SendClientMessage(i, 0xFFFF00AA, string);
                }
            }
        }
    }
    return 1;
}


// Comando /desistir integrado
CMD:desistir(playerid, params[]) {
    if(!g_DadosMorte[playerid][pEmComa]) {
        return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao esta acidentado no chao.");
    }
    if(!g_DadosMorte[playerid][pPodeDesistir]) {
        new msg[128];
        format(msg, sizeof(msg), "[ERRO] Seus sinais vitais estao instaveis. Aguarde %d segundos para desistir.", g_DadosMorte[playerid][pTempoRestanteDesistir]);
        return SendClientMessage(playerid, 0xFF0000AA, msg);
    }

    FinalizarComaGeral(playerid, true);
    return 1;
}

forward OnPlayerFinishLoading(playerid);
public OnPlayerFinishLoading(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(!g_LoadingAtivo[playerid]) return 0;

    g_LoadingAtivo[playerid] = false;

    // Remove definitivamente o fundo preto da tela de carregamento.
    OcultarLoadingScreen(playerid);

    if(Pdados[playerid][Logado])
        return 1;


    // Tela de boas-vindas no estilo Brasil RolePlay da referencia enviada.
    SetPlayerCameraPos(playerid, 1245.0, -2035.0, 70.0);
    SetPlayerCameraLookAt(playerid, 1180.0, -1980.0, 35.0);

    SendClientMessage(playerid, 0x00BFFFFF, "BrasilIRP: Bem-vindo ao Brasil RolePlay.");
    SendClientMessage(playerid, 0x00BFFFFF, "BrasilIRP: Aguarde enquanto o servidor carrega as informacoes da sua conta...");
    SendClientMessage(playerid, 0x00BFFFFF, "BrasilIRP: Pressione B para falar em chat local!");

    // Sem painel preto de boas-vindas: abre direto o login/registro.
    new nomeJogador[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nomeJogador, sizeof(nomeJogador));
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", nomeJogador);

    if(DOF2_FileExists(StringContas))
    {
        format(String, sizeof(String), "{FFFFFF}Conta: {FF3030}%s\\n{FFFFFF}Digite sua senha para entrar:", nomeJogador);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{FF3030}Brasil Cidade Grande - Login", String, "Entrar", "Sair");
    }
    else
    {
        format(String, sizeof(String), "{FFFFFF}Conta: {FF3030}%s\\n{FFFFFF}Crie uma senha para registrar:", nomeJogador);
        ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "{FF3030}Brasil Cidade Grande - Registro", String, "Registrar", "Sair");
    }

    return 1;
}








CMD:ligar(playerid, params[])
{
    if(!Pdados[playerid][pLogged] || Pdados[playerid][Celular]!=1) return 1;
    new id;
    if(sscanf(params, "i", id))
        return SendClientMessage(playerid, -1, "[CELULAR] Use: /ligar [ID]");
    if(id<0 || id>=MAX_PLAYERS || !IsPlayerConnected(id) || !Pdados[id][pLogged] || Pdados[id][Celular]!=1 || id == playerid)
        return SendClientMessage(playerid, -1, "[CELULAR] ID invalido.");

    if(BCGCelularLigacao[playerid]!=INVALID_PLAYER_ID || BCGCelularLigacao[id]!=INVALID_PLAYER_ID) return SendClientMessage(playerid,-1,"[CELULAR] Linha ocupada.");
    BCGCelularLigacao[playerid] = id;
    BCGCelularLigacao[id] = playerid;
    SendClientMessage(playerid, 0xFFFF00FF, "[CELULAR] Ligacao efetuada.");
    SendClientMessage(id, 0xFFFF00FF, "[CELULAR] Seu celular esta tocando. Use /atender ou /desligar.");
    return 1;
}

CMD:atender(playerid, params[])
{
    new id = BCGCelularLigacao[playerid];
    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "[CELULAR] Nenhuma ligacao recebida.");
    SendClientMessage(playerid, 0x00FF00FF, "[CELULAR] Ligacao atendida. Use /c [mensagem].");
    SendClientMessage(id, 0x00FF00FF, "[CELULAR] O jogador atendeu a ligacao. Use /c [mensagem].");
    return 1;
}

CMD:desligar(playerid, params[])
{
    new id = BCGCelularLigacao[playerid];
    BCGCelularLigacao[playerid] = INVALID_PLAYER_ID;
    if(IsPlayerConnected(id))
    {
        BCGCelularLigacao[id] = INVALID_PLAYER_ID;
        SendClientMessage(id, 0xFF3030FF, "[CELULAR] Ligacao finalizada.");
    }
    SendClientMessage(playerid, 0xFF3030FF, "[CELULAR] Ligacao finalizada.");
    return 1;
}

CMD:c(playerid, params[])
{
    new id = BCGCelularLigacao[playerid];
    if(!IsPlayerConnected(id))
        return SendClientMessage(playerid, -1, "[CELULAR] Voce nao esta em uma ligacao.");
    if(isnull(params))
        return SendClientMessage(playerid, -1, "[CELULAR] Use: /c [mensagem]");

    new msg[160];
    format(msg, sizeof msg, "[Celular] ID %d: %s", playerid, params);
    SendClientMessage(playerid, 0xFFFF00FF, msg);
    SendClientMessage(id, 0xFFFF00FF, msg);
    return 1;
}

CMD:sms(playerid, params[])
{
    new id, texto[128];
    if(sscanf(params, "is[128]", id, texto))
        return SendClientMessage(playerid, -1, "[SMS] Use: /sms [ID] [mensagem]");
    if(!IsPlayerConnected(id) || id == playerid)
        return SendClientMessage(playerid, -1, "[SMS] ID invalido.");

    new msg[180];
    format(msg, sizeof msg, "[SMS] ID %d: %s", playerid, texto);
    SendClientMessage(id, 0x00DFFFFF, msg);
    format(msg, sizeof msg, "[SMS] para ID %d: %s", id, texto);
    SendClientMessage(playerid, 0x00DFFFFF, msg);
    return 1;
}

CMD:anuncio(playerid, params[])
{
    if(isnull(params))
        return SendClientMessage(playerid, -1, "[ANUNCIO] Use: /anuncio [texto]");
    new msg[180];
    format(msg, sizeof msg, "[ANUNCIO] ID %d: %s", playerid, params);
    SendClientMessageToAll(0xFFFF00FF, msg);
    return 1;
}

// ==========================================================
// /CRACK 1-5 = DEITAR | F/ENTER = LEVANTAR
// ==========================================================
CMD:crack(playerid, params[])
{
    if(!IsPlayerConnected(playerid)) return 0;

    if(IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, 0xFF3030FF, "[CRACK] Saia do veiculo antes de usar este comando.");

    if(isnull(params))
        return SendClientMessage(playerid, -1, "[CRACK] Use: /crack 1, /crack 2, /crack 3, /crack 4 ou /crack 5 para deitar. Use /crack 0 para levantar.");

    new anim;
    if(sscanf(params, "i", anim))
        return SendClientMessage(playerid, 0xFF3030FF, "[CRACK] Valor invalido. Use de 0 a 5.");

    // 0 = levantar.
    if(anim == 0)
    {
        ClearAnimations(playerid, 1);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
        TogglePlayerControllable(playerid, true);
        g_PlayerCrack[playerid] = false;
        SendClientMessage(playerid, 0x00FF00FF, "[CRACK] Voce levantou.");
        return 1;
    }

    // 1-5 sao aceitos como variantes do comando /crack.
    // A animacao CRACK/crckdeth2 e usada como base estavel para todos
    // os modos, evitando nomes de animacoes inexistentes no GTA SA.
    if(anim < 1 || anim > 5)
        return SendClientMessage(playerid, 0xFF3030FF, "[CRACK] Use /crack 1, 2, 3, 4 ou 5 para deitar. /crack 0 para levantar.");

    ClearAnimations(playerid, 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);

    ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.1, 0, 0, 0, 1, 0, 1);
    g_PlayerCrack[playerid] = true;

    // Nao bloqueia o ped: alguns clientes param a animacao ao receber
    // TogglePlayerControllable(false). O estado e mantido pelo sistema
    // e /crack 0 limpa a animacao.
    SendClientMessage(playerid, 0x00FF00FF, "[CRACK] Voce esta deitado. Use /crack 0 para levantar.");
    return 1;
}

// ==========================================================
// DAMAGE INFORMER - mostra dano para atacante e vitima
// ==========================================================
stock BCG_GetBodyPartName(bodypart, dest[], size)
{
    switch(bodypart)
    {
        case 3: format(dest, size, "Tronco");
        case 4: format(dest, size, "Virilha");
        case 5: format(dest, size, "Braco esquerdo");
        case 6: format(dest, size, "Braco direito");
        case 7: format(dest, size, "Perna esquerda");
        case 8: format(dest, size, "Perna direita");
        case 9: format(dest, size, "Cabeca");
        default: format(dest, size, "Corpo");
    }
    return 1;
}

stock BCG_GetDamageWeaponName(weaponid, dest[], size)
{
    switch(weaponid)
    {
        case 0:  format(dest, size, "Punho");
        case 22: format(dest, size, "9mm");
        case 23: format(dest, size, "9mm Silenciada");
        case 24: format(dest, size, "Deagle");
        case 25: format(dest, size, "Shotgun");
        case 26: format(dest, size, "Sawnoff");
        case 27: format(dest, size, "Combat Shotgun");
        case 28: format(dest, size, "UZI");
        case 29: format(dest, size, "MP5");
        case 30: format(dest, size, "AK-47");
        case 31: format(dest, size, "M4");
        case 32: format(dest, size, "TEC-9");
        case 33: format(dest, size, "Rifle");
        case 34: format(dest, size, "Sniper");
        case 37: format(dest, size, "Lanca-chamas");
        case 41: format(dest, size, "Spray");
        case 42: format(dest, size, "Extintor");
        case 49: format(dest, size, "Veiculo");
        case 50: format(dest, size, "Helice");
        case 51: format(dest, size, "Explosao");
        case 53: format(dest, size, "Afogamento");
        case 54: format(dest, size, "Queda");
        default:
        {
            GetWeaponName(weaponid, dest, size);
            if(!strlen(dest)) format(dest, size, "Arma %d", weaponid);
        }
    }
    return 1;
}

// ============================================================================
// ANTI-AIM SERVER-SIDE
// Nao tenta ler arquivos do cliente. Detecta padroes muito suspeitos de acertos
// na cabeca e avisa a administracao. Cargo 8 e ignorado pelo detector.
// ============================================================================
new BCG_AimHeadStreak[MAX_PLAYERS];
new BCG_AimLastHeadTick[MAX_PLAYERS];
new BCG_AimSuspeita[MAX_PLAYERS];

stock BCG_AntiAimRegistrar(playerid, weaponid, bodypart)
{
    if(Pdados[playerid][Admin] >= 8) return 1;
    if(weaponid < 22 || weaponid > 34) return 1;

    new agora = GetTickCount();
    if(bodypart == 9)
    {
        if(agora - BCG_AimLastHeadTick[playerid] <= 12000) BCG_AimHeadStreak[playerid]++;
        else BCG_AimHeadStreak[playerid] = 1;
        BCG_AimLastHeadTick[playerid] = agora;

        if(BCG_AimHeadStreak[playerid] >= 5)
        {
            BCG_AimSuspeita[playerid]++;
            new aviso[180];
            format(aviso, sizeof aviso, "{FF3030}[ANTI-AIM] {FFFFFF}%s [IDF:%d] fez %d headshots em sequencia. Suspeita: %d.", Nome(playerid), BCG_IDFixo[playerid], BCG_AimHeadStreak[playerid], BCG_AimSuspeita[playerid]);
            for(new a = 0; a < MAX_PLAYERS; a++)
            {
                if(IsPlayerConnected(a) && Pdados[a][Admin] > 0) SendClientMessage(a, -1, aviso);
            }
            // Nao bane automaticamente: evita falso positivo. Reinicia a janela e continua monitorando.
            BCG_AimHeadStreak[playerid] = 0;
        }
    }
    else if(agora - BCG_AimLastHeadTick[playerid] > 4000)
    {
        BCG_AimHeadStreak[playerid] = 0;
    }
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(damagedid)) return 1;

    BCG_AntiAimRegistrar(playerid, weaponid, bodypart);

    // Detectores de combate: rapid-fire, dano impossivel e proporcao de headshots.
    if(Pdados[playerid][Admin] < 8)
    {
        new agoraAC = GetTickCount();
        BCG_AC_Hits[playerid]++;
        if(bodypart == 9) BCG_AC_HeadHits[playerid]++;
        if(BCG_AC_LastDamageTick[playerid] != 0 && agoraAC - BCG_AC_LastDamageTick[playerid] < 55) BCG_AC_RapidHits[playerid]++;
        else if(agoraAC - BCG_AC_LastDamageTick[playerid] > 1200) BCG_AC_RapidHits[playerid] = 0;
        BCG_AC_LastDamageTick[playerid] = agoraAC;
        if(BCG_AC_RapidHits[playerid] >= 5)
        {
            BCG_AC_AlertarAdmins(playerid, "RAPID FIRE", "acertos em intervalo impossivelmente curto");
            BCG_AC_RapidHits[playerid] = 0;
        }
        if(amount > 180.0 && weaponid >= 22 && weaponid <= 34)
            BCG_AC_AlertarAdmins(playerid, "DAMAGE HACK", "dano de arma de fogo acima do esperado");
        if(BCG_AC_Hits[playerid] >= 12)
        {
            if(BCG_AC_HeadHits[playerid] * 100 / BCG_AC_Hits[playerid] >= 85)
                BCG_AC_AlertarAdmins(playerid, "AIMBOT", "85% ou mais dos acertos foram na cabeca");
            BCG_AC_Hits[playerid] = 0;
            BCG_AC_HeadHits[playerid] = 0;
        }
    }

    new arma[32], parte[24], msg[160];
    BCG_GetDamageWeaponName(weaponid, arma, sizeof arma);
    BCG_GetBodyPartName(bodypart, parte, sizeof parte);

    format(msg, sizeof msg, "-DamageInformer- Voce fez %.0f de dano em ID %d com %s (%s)", amount, BCG_IDFixo[damagedid], arma, parte);
    SendClientMessage(playerid, 0xFFFFFFFF, msg);
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if(issuerid == INVALID_PLAYER_ID || !IsPlayerConnected(issuerid)) return 1;

    new arma[32], parte[24], msg[160];
    BCG_GetDamageWeaponName(weaponid, arma, sizeof arma);
    BCG_GetBodyPartName(bodypart, parte, sizeof parte);

    format(msg, sizeof msg, "-DamageInformer- ID %d fez %.0f de dano em voce com %s (%s)", BCG_IDFixo[issuerid], amount, arma, parte);
    SendClientMessage(playerid, 0xFFFFFFFF, msg);
    return 1;
}

// ============================================================================
// BCG V2 - CAMADA MODERNA DE SISTEMAS
// ============================================================================
// Esta camada e aditiva: aproveita Pdados, Dados, a loja, garagem e conce
// existentes, sem substituir os sistemas antigos nem duplicar seus comandos.

#define BCG_V2_DLG_HOME        21000
#define BCG_V2_DLG_LOJA        21001
#define BCG_V2_DLG_GARAGEM     21002
#define BCG_V2_DLG_COINS       21003
#define BCG_V2_DLG_INFO        21004
#define BCG_V2_DLG_COIN_ADMIN  21005

new BCG_V2_LastTick[MAX_PLAYERS];
new BCG_V2_LastVehicle[MAX_PLAYERS];
new bool:BCG_V2_MenuAberto[MAX_PLAYERS];

stock BCG_V2_ShowInfo(playerid, titulo[], texto[])
{
    ShowPlayerDialog(playerid, BCG_V2_DLG_INFO, DIALOG_STYLE_MSGBOX, titulo, texto, "OK", "");
    return 1;
}

stock BCG_AbrirPainelV2(playerid)
{
    new nome[MAX_PLAYER_NAME], texto[1200];
    GetPlayerName(playerid, nome, sizeof(nome));

    format(texto, sizeof(texto),
        "{00BFFF}PERFIL\n{FFFFFF}%s  |  ID %05d\n\n{FFFFFF}Dinheiro: {00FF00}R$%d\n{FFFFFF}Banco: {00FF00}R$%d\n{FFFFFF}Coins: {FFD700}%d\n{FFFFFF}Nivel: {00BFFF}%d\n\n{00BFFF}ACESSOS\n{FFFFFF}Loja Premium\nGaragem\nConcessionaria\nStatus do veiculo\nCentral de Coins\nLoja classica",
        nome, BCG_IDFixo[playerid], GetPlayerMoney(playerid), Pdados[playerid][Banco], Pdados[playerid][Coins], Pdados[playerid][Level]);

    BCG_V2_MenuAberto[playerid] = true;
    ShowPlayerDialog(playerid, BCG_V2_DLG_HOME, DIALOG_STYLE_LIST,
        "{00BFFF}CIDADE GRANDE | CENTRAL", texto, "ABRIR", "FECHAR");
    return 1;
}

stock BCG_AbrirLojaV2(playerid)
{
    new texto[1400];
    format(texto, sizeof(texto),
        "{FFD700}SEUS COINS: {FFFFFF}%d\n\n{FFFFFF}Medkit\t{FFD700}3 C\nColete\t{FFD700}3 C\nGalao de combustivel\t{FFD700}2 C\nKit de reparo\t{FFD700}4 C\nBlindagem\t{FFD700}6 C\nAdrenalina\t{FFD700}5 C\nJBL\t{FFD700}12 C\nPortao\t{FFD700}15 C\nTitulo personalizado\t{FFD700}10 C\nSlot de inventario\t{FFD700}8 C\n\n{00BFFF}VIP / SOCIO / VIP ORG / VEICULOS\n{FFFFFF}Use o menu completo da loja classica para essas categorias.",
        Pdados[playerid][Coins]);
    ShowPlayerDialog(playerid, BCG_V2_DLG_LOJA, DIALOG_STYLE_TABLIST_HEADERS,
        "{00BFFF}CIDADE GRANDE | LOJA PREMIUM", texto, "COMPRAR", "VOLTAR");
    return 1;
}

stock BCG_V2_ComprarItem(playerid, item)
{
    new precoItem, quantidade = 1, nomeItem[32];

    switch(item)
    {
        case 0: { precoItem = 3;  format(nomeItem, sizeof nomeItem, "Medkit"); }
        case 1: { precoItem = 3;  format(nomeItem, sizeof nomeItem, "Colete"); }
        case 2: { precoItem = 2;  format(nomeItem, sizeof nomeItem, "Galao"); }
        case 3: { precoItem = 4;  format(nomeItem, sizeof nomeItem, "Kit de reparo"); }
        case 4: { precoItem = 6;  format(nomeItem, sizeof nomeItem, "Blindagem"); }
        case 5: { precoItem = 5;  format(nomeItem, sizeof nomeItem, "Adrenalina"); }
        case 6: { precoItem = 12; format(nomeItem, sizeof nomeItem, "JBL"); }
        case 7: { precoItem = 15; format(nomeItem, sizeof nomeItem, "Portao"); }
        case 8: { precoItem = 10; format(nomeItem, sizeof nomeItem, "Titulo"); }
        case 9: { precoItem = 8;  format(nomeItem, sizeof nomeItem, "Slot de inventario"); }
        default: return 0;
    }

    if(Pdados[playerid][Coins] < precoItem)
        return SendClientMessage(playerid, 0xFF3030FF, "[LOJA] Voce nao possui Coins suficientes.");

    // Limites simples para impedir estoque absurdo e manter a economia estavel.
    if(item == 0 && Pdados[playerid][pItem_Medikit] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Medkits atingido.");
    if(item == 1 && Pdados[playerid][pItem_Colete] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Coletes atingido.");
    if(item == 2 && Pdados[playerid][pItem_Galao] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Galoes atingido.");
    if(item == 3 && Pdados[playerid][pItem_KitReparo] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Kits atingido.");
    if(item == 4 && Pdados[playerid][pItem_Blindagem] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Blindagens atingido.");
    if(item == 5 && Pdados[playerid][Adrenalina] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Adrenalinas atingido.");
    if(item == 6 && Pdados[playerid][pItem_JBL] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de JBLs atingido.");
    if(item == 7 && Pdados[playerid][pItem_Portao] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Portoes atingido.");
    if(item == 8 && Pdados[playerid][pItem_Titulo] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Titulos atingido.");
    if(item == 9 && Pdados[playerid][pItem_SlotInv] >= 50) return SendClientMessage(playerid, -1, "[LOJA] Limite de Slots atingido.");

    Pdados[playerid][Coins] -= precoItem;

    switch(item)
    {
        case 0: Pdados[playerid][pItem_Medikit] += quantidade;
        case 1: Pdados[playerid][pItem_Colete] += quantidade;
        case 2: Pdados[playerid][pItem_Galao] += quantidade;
        case 3: Pdados[playerid][pItem_KitReparo] += quantidade;
        case 4: Pdados[playerid][pItem_Blindagem] += quantidade;
        case 5: Pdados[playerid][Adrenalina] += quantidade;
        case 6: Pdados[playerid][pItem_JBL] += quantidade;
        case 7: Pdados[playerid][pItem_Portao] += quantidade;
        case 8:
        {
            Pdados[playerid][pItem_Titulo] += quantidade;
            if(!strlen(Pdados[playerid][pTexto_Titulo])) format(Pdados[playerid][pTexto_Titulo], 32, "Cidade Grande");
        }
        case 9: Pdados[playerid][pItem_SlotInv] += quantidade;
    }

    SalvarDados(playerid);

    new msg[160];
    format(msg, sizeof msg, "[LOJA] Compra concluida: %s por %d Coins. Saldo: %d Coins.", nomeItem, precoItem, Pdados[playerid][Coins]);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    return 1;
}

stock BCG_V2_StatusGaragem(playerid)
{
    new a[256], b[256], texto[700], ativo[24];
    if(Dados[playerid][modelo1] >= 400 && Dados[playerid][modelo1] <= 611)
        format(a, sizeof a, "Slot 1: %s | Combustivel %d%%", modelNames[Dados[playerid][modelo1] - 400], Dados[playerid][gasosa1]);
    else format(a, sizeof a, "Slot 1: VAZIO");

    if(Dados[playerid][modelo2] >= 400 && Dados[playerid][modelo2] <= 611)
        format(b, sizeof b, "Slot 2: %s | Combustivel %d%%", modelNames[Dados[playerid][modelo2] - 400], Dados[playerid][gasosa2]);
    else format(b, sizeof b, "Slot 2: VAZIO");

    if(VeiculoGaragem[playerid] > 0 && VeiculoGaragem[playerid] < MAX_VEHICLES && GetVehicleModel(VeiculoGaragem[playerid]) != 0)
        format(ativo, sizeof ativo, "FORA DA GARAGEM");
    else
        format(ativo, sizeof ativo, "GUARDADO");

    format(texto, sizeof texto, "{00BFFF}GARAGEM BCG\n\n{FFFFFF}%s\n%s\n\nVeiculo ativo: %s\nSlot ativo: %d",
        a, b, ativo, SlotAtual[playerid]);
    return BCG_V2_ShowInfo(playerid, "{00BFFF}CIDADE GRANDE | GARAGEM", texto);
}

stock BCG_AbrirGaragemV2(playerid)
{
    new texto[800], s1[180], s2[180];
    if(Dados[playerid][modelo1] >= 400 && Dados[playerid][modelo1] <= 611)
        format(s1, sizeof s1, "Retirar Slot 1 | %s | %d%%", modelNames[Dados[playerid][modelo1]-400], Dados[playerid][gasosa1]);
    else format(s1, sizeof s1, "Retirar Slot 1 | Vazio");
    if(Dados[playerid][modelo2] >= 400 && Dados[playerid][modelo2] <= 611)
        format(s2, sizeof s2, "Retirar Slot 2 | %s | %d%%", modelNames[Dados[playerid][modelo2]-400], Dados[playerid][gasosa2]);
    else format(s2, sizeof s2, "Retirar Slot 2 | Vazio");

    format(texto, sizeof texto, "%s\n%s\nGuardar veiculo atual\nStatus da garagem", s1, s2);
    ShowPlayerDialog(playerid, BCG_V2_DLG_GARAGEM, DIALOG_STYLE_LIST,
        "{00BFFF}CIDADE GRANDE | GARAGEM", texto, "SELECIONAR", "VOLTAR");
    return 1;
}

stock BCG_GerarPedidoCoins()
{
    return random(899999) + 100000;
}

stock BCG_ExpirarCoinsSeNecessario(playerid)
{
    if(!PlayerAgendamento[playerid][agAtivo]) return 0;
    if(PlayerAgendamento[playerid][agExpiraEm] > gettime()) return 0;

    new nomeJogador[MAX_PLAYER_NAME], arquivo[96];
    GetPlayerName(playerid, nomeJogador, sizeof nomeJogador);
    format(arquivo, sizeof arquivo, "CoinsAgendados/%s.txt", nomeJogador);
    if(DOF2_FileExists(arquivo)) DOF2_RemoveFile(arquivo);

    PlayerAgendamento[playerid][agAtivo] = false;
    PlayerAgendamento[playerid][agQuantidade] = 0;
    PlayerAgendamento[playerid][agCodigo][0] = EOS;
    PlayerAgendamento[playerid][agStatus] = 3;
    SendClientMessage(playerid, 0xFFB000FF, "[COINS] Seu pedido expirou. Solicite um novo agendamento.");
    return 1;
}

stock BCG_V2_AgendarCoins(playerid, idfixo, quantia, codigo[])
{
    if(Pdados[playerid][Admin] < 8)
        return SendClientMessage(playerid, 0xFF3030FF, "[COINS] Sem permissao.");

    if(idfixo < 10000 || idfixo > 99999 || quantia <= 0 || quantia > BCG_COINS_MAX_QUANTIDADE)
        return SendClientMessage(playerid, -1, "[COINS] IDF ou quantidade invalidos.");

    if(strlen(codigo) < 4 || strlen(codigo) > 31)
        return SendClientMessage(playerid, -1, "[COINS] O codigo deve ter de 4 a 31 caracteres.");

    new id = BCG_BuscarPorIDFixo(idfixo);
    if(id == INVALID_PLAYER_ID)
        return SendClientMessage(playerid, -1, "[COINS] O jogador precisa estar online para receber o agendamento.");

    BCG_ExpirarCoinsSeNecessario(id);
    if(PlayerAgendamento[id][agAtivo])
        return SendClientMessage(playerid, 0xFF3030FF, "[COINS] Este jogador ja possui um pedido pendente.");

    new nomeAlvo[MAX_PLAYER_NAME], nomeAdmin[MAX_PLAYER_NAME], arquivo[96];
    GetPlayerName(id, nomeAlvo, sizeof nomeAlvo);
    GetPlayerName(playerid, nomeAdmin, sizeof nomeAdmin);
    format(arquivo, sizeof arquivo, "CoinsAgendados/%s.txt", nomeAlvo);

    if(!DOF2_FileExists(arquivo)) DOF2_CreateFile(arquivo);

    new pedido = BCG_GerarPedidoCoins();
    new criado = gettime();
    new expira = criado + BCG_COINS_EXPIRACAO;

    DOF2_SetInt(arquivo, "Quantidade", quantia);
    DOF2_SetInt(arquivo, "IDF", idfixo);
    DOF2_SetInt(arquivo, "JogadorID", id);
    DOF2_SetInt(arquivo, "Pedido", pedido);
    DOF2_SetString(arquivo, "Codigo", codigo);
    DOF2_SetString(arquivo, "CriadoPor", nomeAdmin);
    DOF2_SetInt(arquivo, "CriadoEm", criado);
    DOF2_SetInt(arquivo, "ExpiraEm", expira);
    DOF2_SetInt(arquivo, "Tentativas", 0);
    DOF2_SetInt(arquivo, "Status", 1);
    DOF2_SaveFile();

    PlayerAgendamento[id][agAtivo] = true;
    PlayerAgendamento[id][agParaID] = id;
    PlayerAgendamento[id][agQuantidade] = quantia;
    format(PlayerAgendamento[id][agCodigo], 32, "%s", codigo);
    PlayerAgendamento[id][agPedido] = pedido;
    PlayerAgendamento[id][agCriadoEm] = criado;
    PlayerAgendamento[id][agExpiraEm] = expira;
    PlayerAgendamento[id][agTentativas] = 0;
    PlayerAgendamento[id][agStatus] = 1;
    format(PlayerAgendamento[id][agCriadoPor], MAX_PLAYER_NAME, "%s", nomeAdmin);
    BCG_CoinsUltimoPedido[id] = pedido;

    new msg[220];
    format(msg, sizeof msg, "[COINS] Pedido #%06d criado | %d Coins | validade: 7 dias.", pedido, quantia);
    SendClientMessage(playerid, 0x00FF00FF, msg);
    SendClientMessage(id, 0x00BFFFFF, "[COINS] Pacote pendente. Use /coinspedido para consultar.");
    return 1;
}

stock BCG_CancelarAgendamentoCoins(playerid)
{
    if(!PlayerAgendamento[playerid][agAtivo])
        return SendClientMessage(playerid, 0xFFD700FF, "[COINS] Nao existe pedido pendente.");

    new nomeJogador[MAX_PLAYER_NAME], arquivo[96];
    GetPlayerName(playerid, nomeJogador, sizeof nomeJogador);
    format(arquivo, sizeof arquivo, "CoinsAgendados/%s.txt", nomeJogador);
    if(DOF2_FileExists(arquivo)) DOF2_RemoveFile(arquivo);

    PlayerAgendamento[playerid][agAtivo] = false;
    PlayerAgendamento[playerid][agQuantidade] = 0;
    PlayerAgendamento[playerid][agCodigo][0] = EOS;
    PlayerAgendamento[playerid][agPedido] = 0;
    PlayerAgendamento[playerid][agStatus] = 2;
    PlayerAgendamento[playerid][agTentativas] = 0;
    PlayerAgendamento[playerid][agCriadoPor][0] = EOS;
    SalvarDados(playerid);

    return SendClientMessage(playerid, 0x00FF00FF, "[COINS] Pedido cancelado com sucesso.");
}

stock BCG_MostrarStatusCoins(playerid)
{
    BCG_ExpirarCoinsSeNecessario(playerid);

    if(!PlayerAgendamento[playerid][agAtivo])
        return SendClientMessage(playerid, 0xFFD700FF, "[COINS] Nenhum pedido pendente.");

    new restante = PlayerAgendamento[playerid][agExpiraEm] - gettime();
    if(restante < 0) restante = 0;

    new dias = restante / 86400;
    new horas = (restante % 86400) / 3600;
    new texto[600];
    format(texto, sizeof texto,
        "{FFD700}CENTRAL DE COINS\\n\\n{FFFFFF}Pedido: {00BFFF}#%06d\\n{FFFFFF}Quantidade: {00FF00}%d Coins\\n{FFFFFF}Criado por: {00BFFF}%s\\n{FFFFFF}Tentativas: {FFFF00}%d/%d\\n{FFFFFF}Validade: {FFFF00}%dd %dh\\n{FFFFFF}Status: {00FF00}PENDENTE\\n\\n{AFAFAF}Use /resgatarcoins para informar o codigo.",
        PlayerAgendamento[playerid][agPedido],
        PlayerAgendamento[playerid][agQuantidade],
        PlayerAgendamento[playerid][agCriadoPor],
        PlayerAgendamento[playerid][agTentativas],
        BCG_COINS_MAX_TENTATIVAS,
        dias, horas);
    return BCG_V2_ShowInfo(playerid, "{FFD700}CIDADE GRANDE | COINS", texto);
}

stock BCG_ModernTick(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new agora = GetTickCount();
    if(BCG_V2_LastTick[playerid] != 0 && agora - BCG_V2_LastTick[playerid] < 500) return 1;
    BCG_V2_LastTick[playerid] = agora;

    if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        new vid = GetPlayerVehicleID(playerid);
        if(vid < 1 || vid >= MAX_VEHICLES || GetVehicleModel(vid) == 0) return 1;
        if(vid != BCG_V2_LastVehicle[playerid])
        {
            BCG_V2_LastVehicle[playerid] = vid;
            new nomeVeiculo[32], aviso[100];
            GetVehicleName(vid, nomeVeiculo, sizeof nomeVeiculo);
            format(aviso, sizeof aviso, "[VEICULO] %s | Combustivel %d%%", nomeVeiculo, GasolinaVeiculo[vid]);
            SendClientMessage(playerid, 0x00BFFFFF, aviso);
        }
    }
    else BCG_V2_LastVehicle[playerid] = 0;
    return 1;
}

stock BCG_HandleModernDialog(playerid, dialogid, response, listitem, const inputtext[])
{
    #pragma unused inputtext
    if(dialogid == BCG_V2_DLG_HOME)
    {
        if(!response) { BCG_V2_MenuAberto[playerid] = false; return 1; }
        switch(listitem)
        {
            case 0: BCG_AbrirLojaV2(playerid);
            case 1: BCG_AbrirGaragemV2(playerid);
            case 2:
            {
                if(!IsPlayerInRangeOfPoint(playerid, 8.0, CONCE_LOCAL_X, CONCE_LOCAL_Y, CONCE_LOCAL_Z))
                    return SendClientMessage(playerid, 0xFF3030FF, "[CONCE] Va ate a concessionaria para abrir o sistema.");
                AbrirMenuConcessionaria(playerid);
            }
            case 3: BCG_V2_StatusGaragem(playerid);
            case 4:
            {
                new texto[420];
                format(texto, sizeof texto, "{FFD700}Coins atuais: {FFFFFF}%d\n\n{FFFFFF}Resgate: use o codigo recebido no pacote.\nComando: /resgatarcoins\n\n{00BFFF}Agendamento administrativo: /agendarcoins2 [IDF] [QTD] [CODIGO]", Pdados[playerid][Coins]);
                ShowPlayerDialog(playerid, BCG_V2_DLG_COINS, DIALOG_STYLE_MSGBOX, "{FFD700}CIDADE GRANDE | COINS", texto, "RESGATAR", "VOLTAR");
            }
            case 5: ShowPlayerDialog(playerid, DIALOG_LOJA_PRINCIPAL, DIALOG_STYLE_LIST, "{00BFFF}CIDADE GRANDE | LOJA CLASSICA", "Como adquirir Coins\nVantagens VIP/Socio\nResgatar Coins\nComprar Socio\nComprar VIP\nVIP para ORG\nItens\nVeiculos\nVeiculos Premium\nFamilias\nCupom", "ABRIR", "FECHAR");
        }
        return 1;
    }

    if(dialogid == BCG_V2_DLG_LOJA)
    {
        if(!response) return BCG_AbrirPainelV2(playerid);
        return BCG_V2_ComprarItem(playerid, listitem);
    }

    if(dialogid == BCG_V2_DLG_GARAGEM)
    {
        if(!response) return BCG_AbrirPainelV2(playerid);
        if(listitem == 0 || listitem == 1)
        {
            new texto[300], modelo = (listitem == 0) ? Dados[playerid][modelo1] : Dados[playerid][modelo2];
            if(modelo < 400 || modelo > 611) return SendClientMessage(playerid, 0xFF3030FF, "[GARAGEM] Este slot esta vazio.");
            format(texto, sizeof texto, "Slot %d selecionado. O sistema original da garagem sera aberto para manter toda a logica de spawn, gasolina e salvamento.", listitem + 1);
            ShowPlayerDialog(playerid, DIALOG_GARAGEM, DIALOG_STYLE_LIST, "{00BFFF}GARAGEM | RETIRAR VEICULO", "Retirar Slot 1\nRetirar Slot 2", "PUXAR", "FECHAR");
            return 1;
        }
        if(listitem == 2) return BCG_GuardarVeiculoInterno(playerid);
        if(listitem == 3) return BCG_V2_StatusGaragem(playerid);
        return 1;
    }

    if(dialogid == BCG_V2_DLG_COINS)
    {
        if(!response) return BCG_AbrirPainelV2(playerid);
        ShowPlayerDialog(playerid, DIALOG_RESGATAR_COINS, DIALOG_STYLE_INPUT, "{FFD700}RESGATAR COINS", "Digite o codigo do seu pacote:", "VERIFICAR", "VOLTAR");
        return 1;
    }
    return 0;
}

// Wrapper para guardar o veiculo sem duplicar o comando existente.
stock BCG_GuardarVeiculoInterno(playerid)
{
    if(VeiculoGaragem[playerid] == 0)
        return SendClientMessage(playerid, 0xFF3030FF, "[GARAGEM] Voce nao tem veiculo fora da garagem.");

    new vid = VeiculoGaragem[playerid];
    if(vid < 1 || vid >= MAX_VEHICLES || GetVehicleModel(vid) == 0)
    {
        VeiculoGaragem[playerid] = 0;
        SlotAtual[playerid] = 0;
        return SendClientMessage(playerid, 0xFF3030FF, "[GARAGEM] O veiculo ativo nao existe mais. O estado foi sincronizado.");
    }
    if(SlotAtual[playerid] == 1) Dados[playerid][gasosa1] = GasolinaVeiculo[vid];
    else if(SlotAtual[playerid] == 2) Dados[playerid][gasosa2] = GasolinaVeiculo[vid];

    MotorLigado[vid] = false;
    GasolinaVeiculo[vid] = 0;
    if(TextoDonoVeiculo[vid] != Text3D:INVALID_3DTEXT_ID)
    {
        Delete3DTextLabel(TextoDonoVeiculo[vid]);
        TextoDonoVeiculo[vid] = Text3D:INVALID_3DTEXT_ID;
    }
    DestroyVehicle(vid);
    VeiculoGaragem[playerid] = 0;
    SlotAtual[playerid] = 0;
    SalvarDados(playerid);
    SendClientMessage(playerid, 0x00FF00FF, "[GARAGEM] Veiculo guardado e dados salvos.");
    return 1;
}

CMD:painel(playerid, params[])
{
    #pragma unused params
    return BCG_AbrirPainelV2(playerid);
}

CMD:loja2(playerid, params[])
{
    #pragma unused params
    return BCG_AbrirLojaV2(playerid);
}

CMD:garagem2(playerid, params[])
{
    #pragma unused params
    return BCG_AbrirGaragemV2(playerid);
}

CMD:statusveiculo(playerid, params[])
{
    #pragma unused params
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "[VEICULO] Entre em um veiculo para consultar o status.");
    new vid = GetPlayerVehicleID(playerid), nomeVeiculo[32], msg[220], Float:hp;
    if(vid < 1 || vid >= MAX_VEHICLES || GetVehicleModel(vid) == 0)
        return SendClientMessage(playerid, 0xFF3030FF, "[VEICULO] ID de veiculo invalido.");
    GetVehicleName(vid, nomeVeiculo, sizeof nomeVeiculo);
    GetVehicleHealth(vid, hp);
    format(msg, sizeof msg, "[VEICULO] %s | ID %d | Velocidade %.0f km/h | HP %.0f | Combustivel %d%% | Motor %s",
        nomeVeiculo, vid, GetVehicleSpeed(vid), hp, GasolinaVeiculo[vid], MotorLigado[vid] ? "ON" : "OFF");
    return SendClientMessage(playerid, 0x00BFFFFF, msg);
}

CMD:agendarcoins2(playerid, params[])
{
    new idf, quantidade, codigo[32];
    if(sscanf(params, "iis[32]", idf, quantidade, codigo))
        return SendClientMessage(playerid, -1, "[COINS] Use: /agendarcoins2 [IDF] [QUANTIDADE] [CODIGO]");
    return BCG_V2_AgendarCoins(playerid, idf, quantidade, codigo);
}

CMD:coinspedido(playerid, params[])
{
    #pragma unused params
    return BCG_MostrarStatusCoins(playerid);
}

CMD:cancelarcoins(playerid, params[])
{
    #pragma unused params
    return BCG_CancelarAgendamentoCoins(playerid);
}

CMD:cancelaragendamento(playerid, params[])
{
    if(Pdados[playerid][Admin] < 8)
        return SendClientMessage(playerid, 0xFF3030FF, "[COINS] Sem permissao.");

    new idf;
    if(sscanf(params, "i", idf))
        return SendClientMessage(playerid, -1, "[COINS] Use: /cancelaragendamento [IDF]");

    new alvo = BCG_BuscarPorIDFixo(idf);
    if(alvo == INVALID_PLAYER_ID)
        return SendClientMessage(playerid, 0xFF3030FF, "[COINS] Jogador offline.");

    return BCG_CancelarAgendamentoCoins(alvo);
}

CMD:conce2(playerid, params[])
{
    #pragma unused params
    if(!IsPlayerInRangeOfPoint(playerid, 8.0, CONCE_LOCAL_X, CONCE_LOCAL_Y, CONCE_LOCAL_Z))
        return SendClientMessage(playerid, 0xFF3030FF, "[CONCE] Voce nao esta na concessionaria.");
    AbrirMenuConcessionaria(playerid);
    return 1;
}



// ============================================================================
// BCG CIDADE V3 - FAMILIAS / CASAS / PRISAO / VEICULOS / GUERRAS
// ============================================================================

stock BCG_SalvarFamilia(id)
{
    if(id < 0 || id >= MAX_FAMILIAS_BCG) return 0;
    if(!DOF2_FileExists(ARQ_FAMILIAS_BCG)) DOF2_CreateFile(ARQ_FAMILIAS_BCG);

    new k[48];
    format(k, sizeof k, "F%d_Ativa", id); DOF2_SetInt(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famAtiva] ? 1 : 0);
    format(k, sizeof k, "F%d_Nome", id); DOF2_SetString(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famNome]);
    format(k, sizeof k, "F%d_Lider", id); DOF2_SetString(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famLider]);
    format(k, sizeof k, "F%d_Cor", id); DOF2_SetInt(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famCor]);
    format(k, sizeof k, "F%d_Cofre", id); DOF2_SetInt(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famCofre]);
    format(k, sizeof k, "F%d_X", id); DOF2_SetFloat(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famX]);
    format(k, sizeof k, "F%d_Y", id); DOF2_SetFloat(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famY]);
    format(k, sizeof k, "F%d_Z", id); DOF2_SetFloat(ARQ_FAMILIAS_BCG, k, FamiliaBCG[id][famZ]);
    DOF2_SaveFile();
    return 1;
}

stock BCG_AtualizarFamiliaVisual(id)
{
    if(id < 0 || id >= MAX_FAMILIAS_BCG || !FamiliaBCG[id][famAtiva]) return 0;
    if(FamiliaBCG[id][famPickup] != 0) DestroyPickup(FamiliaBCG[id][famPickup]);
    if(_:FamiliaBCG[id][famLabel] != 0) Delete3DTextLabel(FamiliaBCG[id][famLabel]);

    FamiliaBCG[id][famPickup] = CreatePickup(1239, 1, FamiliaBCG[id][famX], FamiliaBCG[id][famY], FamiliaBCG[id][famZ], -1);
    new familiaTexto[180];
    format(familiaTexto, sizeof familiaTexto, "{FFD700}[ FAMILIA ]\n{FFFFFF}%s\n{00FF00}Lider: %s\n{FFFFFF}Cofre: R$%d\n{FFFF00}/familia", FamiliaBCG[id][famNome], FamiliaBCG[id][famLider], FamiliaBCG[id][famCofre]);
    FamiliaBCG[id][famLabel] = Create3DTextLabel(familiaTexto, -1, FamiliaBCG[id][famX], FamiliaBCG[id][famY], FamiliaBCG[id][famZ] + 0.5, 20.0, 0, 0);
    return 1;
}

stock BCG_CarregarFamilias()
{
    if(!DOF2_FileExists(ARQ_FAMILIAS_BCG)) DOF2_CreateFile(ARQ_FAMILIAS_BCG);
    new k[48];
    for(new i = 0; i < MAX_FAMILIAS_BCG; i++)
    {
        FamiliaBCG[i][famAtiva] = false;
        FamiliaBCG[i][famPickup] = 0;
        FamiliaBCG[i][famLabel] = Text3D:0;
        format(k, sizeof k, "F%d_Ativa", i);
        if(DOF2_GetInt(ARQ_FAMILIAS_BCG, k) != 1) continue;

        FamiliaBCG[i][famAtiva] = true;
        format(k, sizeof k, "F%d_Nome", i); format(FamiliaBCG[i][famNome], 32, "%s", DOF2_GetString(ARQ_FAMILIAS_BCG, k));
        format(k, sizeof k, "F%d_Lider", i); format(FamiliaBCG[i][famLider], MAX_PLAYER_NAME, "%s", DOF2_GetString(ARQ_FAMILIAS_BCG, k));
        format(k, sizeof k, "F%d_Cor", i); FamiliaBCG[i][famCor] = DOF2_GetInt(ARQ_FAMILIAS_BCG, k);
        format(k, sizeof k, "F%d_Cofre", i); FamiliaBCG[i][famCofre] = DOF2_GetInt(ARQ_FAMILIAS_BCG, k);
        format(k, sizeof k, "F%d_X", i); FamiliaBCG[i][famX] = DOF2_GetFloat(ARQ_FAMILIAS_BCG, k);
        format(k, sizeof k, "F%d_Y", i); FamiliaBCG[i][famY] = DOF2_GetFloat(ARQ_FAMILIAS_BCG, k);
        format(k, sizeof k, "F%d_Z", i); FamiliaBCG[i][famZ] = DOF2_GetFloat(ARQ_FAMILIAS_BCG, k);
        BCG_AtualizarFamiliaVisual(i);
    }
    return 1;
}

CMD:criarfamilia(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    new lider, nome[32];
    if(sscanf(params, "us[32]", lider, nome))
        return SendClientMessage(playerid, -1, "[FAMILIA] Use: /criarfamilia [playerid] [nome]");
    if(!IsPlayerConnected(lider)) return SendClientMessage(playerid, 0xE74C3CFF, "[FAMILIA] Jogador invalido.");

    new id = -1;
    for(new i = 0; i < MAX_FAMILIAS_BCG; i++) if(!FamiliaBCG[i][famAtiva]) { id = i; break; }
    if(id == -1) return SendClientMessage(playerid, 0xE74C3CFF, "[FAMILIA] Limite atingido.");

    FamiliaBCG[id][famAtiva] = true;
    format(FamiliaBCG[id][famNome], 32, "%s", nome);
    format(FamiliaBCG[id][famLider], MAX_PLAYER_NAME, "%s", Nome(lider));
    FamiliaBCG[id][famCor] = random(0xFFFFFF) | 0x000000FF;
    FamiliaBCG[id][famCofre] = 0;
    GetPlayerPos(playerid, FamiliaBCG[id][famX], FamiliaBCG[id][famY], FamiliaBCG[id][famZ]);
    PlayerFamiliaBCG[lider] = id + 1;
    BCG_SalvarFamilia(id);
    BCG_AtualizarFamiliaVisual(id);

    new msg[144];
    format(msg, sizeof msg, "[FAMILIA] %s criada. ID %d | Lider: %s", nome, id + 1, Nome(lider));
    SendClientMessageToAll(0xFFD700FF, msg);
    return 1;
}

CMD:familia(playerid, params[])
{
    #pragma unused params
    new fid = PlayerFamiliaBCG[playerid] - 1;
    if(fid < 0 || fid >= MAX_FAMILIAS_BCG || !FamiliaBCG[fid][famAtiva])
        return SendClientMessage(playerid, -1, "[FAMILIA] Voce nao pertence a uma familia.");
    new msg[180];
    format(msg, sizeof msg, "[FAMILIA] %s | Lider %s | Cofre R$%d | ID %d", FamiliaBCG[fid][famNome], FamiliaBCG[fid][famLider], FamiliaBCG[fid][famCofre], fid + 1);
    return SendClientMessage(playerid, FamiliaBCG[fid][famCor], msg);
}

CMD:convidarfamilia(playerid, params[])
{
    new fid = PlayerFamiliaBCG[playerid] - 1, alvo;
    if(fid < 0 || fid >= MAX_FAMILIAS_BCG) return SendClientMessage(playerid, -1, "[FAMILIA] Sem familia.");
    if(strcmp(FamiliaBCG[fid][famLider], Nome(playerid), true) != 0) return SendClientMessage(playerid, -1, "[FAMILIA] Somente o lider.");
    if(sscanf(params, "u", alvo) || !IsPlayerConnected(alvo)) return SendClientMessage(playerid, -1, "[FAMILIA] Use: /convidarfamilia [id]");
    PlayerFamiliaBCG[alvo] = fid + 1;
    SendClientMessage(alvo, FamiliaBCG[fid][famCor], "[FAMILIA] Voce entrou na familia.");
    return 1;
}

CMD:cofrefamilia(playerid, params[])
{
    new fid = PlayerFamiliaBCG[playerid] - 1, acao[12], valor;
    if(fid < 0 || fid >= MAX_FAMILIAS_BCG) return SendClientMessage(playerid, -1, "[FAMILIA] Sem familia.");
    if(!IsPlayerInRangeOfPoint(playerid, 4.0, FamiliaBCG[fid][famX], FamiliaBCG[fid][famY], FamiliaBCG[fid][famZ]))
        return SendClientMessage(playerid, -1, "[FAMILIA] Va ate a sede da familia.");
    if(sscanf(params, "s[12]i", acao, valor) || valor <= 0)
        return SendClientMessage(playerid, -1, "[FAMILIA] /cofrefamilia [depositar/sacar] [valor]");

    if(!strcmp(acao, "depositar", true))
    {
        if(GetPlayerMoney(playerid) < valor) return SendClientMessage(playerid, -1, "[FAMILIA] Dinheiro insuficiente.");
        GivePlayerMoney(playerid, -valor);
        FamiliaBCG[fid][famCofre] += valor;
    }
    else if(!strcmp(acao, "sacar", true))
    {
        if(strcmp(FamiliaBCG[fid][famLider], Nome(playerid), true) != 0) return SendClientMessage(playerid, -1, "[FAMILIA] Somente o lider pode sacar.");
        if(FamiliaBCG[fid][famCofre] < valor) return SendClientMessage(playerid, -1, "[FAMILIA] Saldo insuficiente.");
        FamiliaBCG[fid][famCofre] -= valor;
        GivePlayerMoney(playerid, valor);
    }
    else return SendClientMessage(playerid, -1, "[FAMILIA] Acao invalida.");

    BCG_SalvarFamilia(fid);
    BCG_AtualizarFamiliaVisual(fid);
    return SendClientMessage(playerid, 0x2ECC71FF, "[FAMILIA] Operacao realizada.");
}

CMD:roubarcasa(playerid, params[])
{
    #pragma unused params
    new casa = BCG_CasaProxima(playerid, 5.0);
    if(casa == -1 || strlen(CasaDonoBCG[casa]) == 0) return SendClientMessage(playerid, -1, "[ROUBO] Nenhuma casa ocupada proxima.");
    if(!strcmp(CasaDonoBCG[casa], Nome(playerid), true)) return SendClientMessage(playerid, -1, "[ROUBO] Voce nao pode roubar sua propria casa.");
    if(CasaRouboCooldownBCG[casa] > gettime()) return SendClientMessage(playerid, -1, "[ROUBO] Esta casa foi roubada recentemente.");
    if(CasaRoubandoBCG[playerid]) return SendClientMessage(playerid, -1, "[ROUBO] Voce ja esta em uma acao.");

    CasaRoubandoBCG[playerid] = true;
    CasaRouboAlvoBCG[playerid] = casa;
    CasaRouboInicioBCG[playerid] = gettime();
    SetPlayerWantedLevel(playerid, GetPlayerWantedLevel(playerid) + 2);
    SendClientMessage(playerid, 0xE74C3CFF, "[ROUBO] Arrombamento iniciado. Fique perto da casa por 30 segundos.");
    return 1;
}

CMD:finalizarroubocasa(playerid, params[])
{
    #pragma unused params
    if(!CasaRoubandoBCG[playerid]) return SendClientMessage(playerid, -1, "[ROUBO] Nenhum roubo ativo.");
    new casa = CasaRouboAlvoBCG[playerid];
    if(gettime() - CasaRouboInicioBCG[playerid] < 30) return SendClientMessage(playerid, -1, "[ROUBO] Ainda nao terminou o arrombamento.");
    if(!IsPlayerInRangeOfPoint(playerid, 8.0, CasaXBCG[casa], CasaYBCG[casa], CasaZBCG[casa]))
    {
        CasaRoubandoBCG[playerid] = false;
        return SendClientMessage(playerid, -1, "[ROUBO] Roubo cancelado: voce se afastou.");
    }

    new ganho = 500 + random(2501);
    GivePlayerMoney(playerid, ganho);
    CasaRouboCooldownBCG[casa] = gettime() + 1800;
    CasaRoubandoBCG[playerid] = false;
    new msg[128]; format(msg, sizeof msg, "[ROUBO] Voce encontrou R$%d. A casa entrou em cooldown de 30 minutos.", ganho);
    SendClientMessage(playerid, 0xF1C40FFF, msg);
    return 1;
}

CMD:missaoprisao(playerid, params[])
{
    #pragma unused params
    if(Pdados[playerid][Preso] != 1) return SendClientMessage(playerid, -1, "[PRISAO] Voce nao esta preso.");
    if(PrisaoMissaoBCG[playerid]) return SendClientMessage(playerid, -1, "[PRISAO] Missao ja ativa.");

    PrisaoMissaoBCG[playerid] = true;
    PrisaoEtapaBCG[playerid] = 0;
    PrisaoRecompensaBCG[playerid] = 250;
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerCheckpoint(playerid, x + 4.0, y, z, 2.5);
    return SendClientMessage(playerid, 0xF1C40FFF, "[PRISAO] Trabalho comunitario iniciado. Complete 4 tarefas.");
}

stock BCG_SalvarVeiculoPickup(id)
{
    if(id < 0 || id >= MAX_VEIC_PICKUPS_BCG) return 0;
    if(!DOF2_FileExists(ARQ_VEICPICK_BCG)) DOF2_CreateFile(ARQ_VEICPICK_BCG);
    new k[48];
    format(k, sizeof k, "V%d_Ativo", id); DOF2_SetInt(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpAtivo] ? 1 : 0);
    format(k, sizeof k, "V%d_Org", id); DOF2_SetInt(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpOrg]);
    format(k, sizeof k, "V%d_Trabalho", id); DOF2_SetInt(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpTrabalho]);
    format(k, sizeof k, "V%d_Modelo", id); DOF2_SetInt(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpModelo]);
    format(k, sizeof k, "V%d_Cor1", id); DOF2_SetInt(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpCor1]);
    format(k, sizeof k, "V%d_Cor2", id); DOF2_SetInt(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpCor2]);
    format(k, sizeof k, "V%d_X", id); DOF2_SetFloat(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpX]);
    format(k, sizeof k, "V%d_Y", id); DOF2_SetFloat(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpY]);
    format(k, sizeof k, "V%d_Z", id); DOF2_SetFloat(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpZ]);
    format(k, sizeof k, "V%d_A", id); DOF2_SetFloat(ARQ_VEICPICK_BCG, k, VeicPickupBCG[id][vpA]);
    DOF2_SaveFile();
    return 1;
}

stock BCG_CriarVisualVeicPickup(id)
{
    if(!VeicPickupBCG[id][vpAtivo]) return 0;
    VeicPickupBCG[id][vpPickup] = CreatePickup(1239, 1, VeicPickupBCG[id][vpX], VeicPickupBCG[id][vpY], VeicPickupBCG[id][vpZ], -1);
    new veiculoTexto[160];
    if(VeicPickupBCG[id][vpOrg] > 0)
        format(veiculoTexto, sizeof veiculoTexto, "{00BFFF}[ VEICULO DA ORG ]\n{FFFFFF}%s\n{FFFF00}/veiculoorg", GetNomeOrg(VeicPickupBCG[id][vpOrg]));
    else
        format(veiculoTexto, sizeof veiculoTexto, "{00BFFF}[ VEICULO DE EMPREGO ]\n{FFFFFF}Emprego ID %d\n{FFFF00}/veiculoemprego", VeicPickupBCG[id][vpTrabalho]);
    VeicPickupBCG[id][vpLabel] = Create3DTextLabel(veiculoTexto, -1, VeicPickupBCG[id][vpX], VeicPickupBCG[id][vpY], VeicPickupBCG[id][vpZ] + 0.5, 20.0, 0, 0);
    return 1;
}

stock BCG_CarregarVeiculosPickup()
{
    if(!DOF2_FileExists(ARQ_VEICPICK_BCG)) DOF2_CreateFile(ARQ_VEICPICK_BCG);
    new k[48];
    for(new i = 0; i < MAX_VEIC_PICKUPS_BCG; i++)
    {
        VeicPickupBCG[i][vpAtivo] = false;
        format(k, sizeof k, "V%d_Ativo", i);
        if(DOF2_GetInt(ARQ_VEICPICK_BCG, k) != 1) continue;
        VeicPickupBCG[i][vpAtivo] = true;
        format(k, sizeof k, "V%d_Org", i); VeicPickupBCG[i][vpOrg] = DOF2_GetInt(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_Trabalho", i); VeicPickupBCG[i][vpTrabalho] = DOF2_GetInt(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_Modelo", i); VeicPickupBCG[i][vpModelo] = DOF2_GetInt(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_Cor1", i); VeicPickupBCG[i][vpCor1] = DOF2_GetInt(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_Cor2", i); VeicPickupBCG[i][vpCor2] = DOF2_GetInt(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_X", i); VeicPickupBCG[i][vpX] = DOF2_GetFloat(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_Y", i); VeicPickupBCG[i][vpY] = DOF2_GetFloat(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_Z", i); VeicPickupBCG[i][vpZ] = DOF2_GetFloat(ARQ_VEICPICK_BCG, k);
        format(k, sizeof k, "V%d_A", i); VeicPickupBCG[i][vpA] = DOF2_GetFloat(ARQ_VEICPICK_BCG, k);
        BCG_CriarVisualVeicPickup(i);
    }
    return 1;
}

CMD:criarveiculoorg(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    new org, modelo, c1, c2;
    if(sscanf(params, "iiii", org, modelo, c1, c2))
        return SendClientMessage(playerid, -1, "[VEICULO] /criarveiculoorg [org] [modelo] [cor1] [cor2]");
    if(org <= 0 || org >= MAX_ORGS || modelo < 400 || modelo > 611) return SendClientMessage(playerid, -1, "[VEICULO] Dados invalidos.");

    new id = -1;
    for(new i = 0; i < MAX_VEIC_PICKUPS_BCG; i++) if(!VeicPickupBCG[i][vpAtivo]) { id = i; break; }
    if(id == -1) return SendClientMessage(playerid, -1, "[VEICULO] Limite de pickups atingido.");

    VeicPickupBCG[id][vpAtivo] = true; VeicPickupBCG[id][vpOrg] = org; VeicPickupBCG[id][vpTrabalho] = 0;
    VeicPickupBCG[id][vpModelo] = modelo; VeicPickupBCG[id][vpCor1] = c1; VeicPickupBCG[id][vpCor2] = c2;
    GetPlayerPos(playerid, VeicPickupBCG[id][vpX], VeicPickupBCG[id][vpY], VeicPickupBCG[id][vpZ]);
    GetPlayerFacingAngle(playerid, VeicPickupBCG[id][vpA]);
    BCG_SalvarVeiculoPickup(id); BCG_CriarVisualVeicPickup(id);
    return SendClientMessage(playerid, 0x2ECC71FF, "[VEICULO] Pickup de veiculo da org criado.");
}

CMD:criarveiculoemprego(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    new trab, modelo, c1, c2;
    if(sscanf(params, "iiii", trab, modelo, c1, c2))
        return SendClientMessage(playerid, -1, "[VEICULO] /criarveiculoemprego [emprego] [modelo] [cor1] [cor2]");
    if(trab <= 0 || modelo < 400 || modelo > 611) return SendClientMessage(playerid, -1, "[VEICULO] Dados invalidos.");

    new id = -1;
    for(new i = 0; i < MAX_VEIC_PICKUPS_BCG; i++) if(!VeicPickupBCG[i][vpAtivo]) { id = i; break; }
    if(id == -1) return SendClientMessage(playerid, -1, "[VEICULO] Limite de pickups atingido.");

    VeicPickupBCG[id][vpAtivo] = true; VeicPickupBCG[id][vpOrg] = 0; VeicPickupBCG[id][vpTrabalho] = trab;
    VeicPickupBCG[id][vpModelo] = modelo; VeicPickupBCG[id][vpCor1] = c1; VeicPickupBCG[id][vpCor2] = c2;
    GetPlayerPos(playerid, VeicPickupBCG[id][vpX], VeicPickupBCG[id][vpY], VeicPickupBCG[id][vpZ]);
    GetPlayerFacingAngle(playerid, VeicPickupBCG[id][vpA]);
    BCG_SalvarVeiculoPickup(id); BCG_CriarVisualVeicPickup(id);
    return SendClientMessage(playerid, 0x2ECC71FF, "[VEICULO] Pickup de veiculo do emprego criado.");
}

stock BCG_PickupVeiculoProximo(playerid)
{
    for(new i = 0; i < MAX_VEIC_PICKUPS_BCG; i++)
        if(VeicPickupBCG[i][vpAtivo] && IsPlayerInRangeOfPoint(playerid, 4.0, VeicPickupBCG[i][vpX], VeicPickupBCG[i][vpY], VeicPickupBCG[i][vpZ])) return i;
    return -1;
}

stock BCG_SpawnVeiculoServico(playerid, id)
{
    if(VeiculoServicoBCG[playerid] > 0 && GetVehicleModel(VeiculoServicoBCG[playerid]) != 0)
        DestroyVehicle(VeiculoServicoBCG[playerid]);

    new Float:x = VeicPickupBCG[id][vpX] + 3.0;
    new Float:y = VeicPickupBCG[id][vpY];
    new Float:z = VeicPickupBCG[id][vpZ] + 0.5;
    VeiculoServicoBCG[playerid] = CreateVehicle(VeicPickupBCG[id][vpModelo], x, y, z, VeicPickupBCG[id][vpA], VeicPickupBCG[id][vpCor1], VeicPickupBCG[id][vpCor2], 300);
    PutPlayerInVehicle(playerid, VeiculoServicoBCG[playerid], 0);
    return 1;
}

CMD:veiculoorg(playerid, params[])
{
    #pragma unused params
    new id = BCG_PickupVeiculoProximo(playerid);
    if(id == -1 || VeicPickupBCG[id][vpOrg] <= 0) return SendClientMessage(playerid, -1, "[VEICULO] Va ao pickup da sua org.");
    if(Pdados[playerid][OrgID] != VeicPickupBCG[id][vpOrg]) return SendClientMessage(playerid, -1, "[VEICULO] Este veiculo nao pertence a sua org.");
    BCG_SpawnVeiculoServico(playerid, id);
    return SendClientMessage(playerid, 0x2ECC71FF, "[VEICULO] Veiculo da organizacao retirado.");
}

CMD:veiculoemprego(playerid, params[])
{
    #pragma unused params
    new id = BCG_PickupVeiculoProximo(playerid);
    if(id == -1 || VeicPickupBCG[id][vpTrabalho] <= 0) return SendClientMessage(playerid, -1, "[VEICULO] Va ao pickup do emprego.");
    if(Pdados[playerid][Trabalho] != VeicPickupBCG[id][vpTrabalho]) return SendClientMessage(playerid, -1, "[VEICULO] Este veiculo nao pertence ao seu emprego.");
    BCG_SpawnVeiculoServico(playerid, id);
    return SendClientMessage(playerid, 0x2ECC71FF, "[VEICULO] Veiculo de trabalho retirado.");
}

CMD:guardarveiculoservico(playerid, params[])
{
    #pragma unused params
    if(VeiculoServicoBCG[playerid] <= 0 || GetVehicleModel(VeiculoServicoBCG[playerid]) == 0)
        return SendClientMessage(playerid, -1, "[VEICULO] Nenhum veiculo de servico ativo.");
    DestroyVehicle(VeiculoServicoBCG[playerid]);
    VeiculoServicoBCG[playerid] = 0;
    return SendClientMessage(playerid, 0x2ECC71FF, "[VEICULO] Veiculo de servico devolvido.");
}

CMD:criarguerra(playerid, params[])
{
    if(!(ADM(playerid, 8))) return 1;
    new orgA, orgB, minutos, Float:raio;
    if(sscanf(params, "iiif", orgA, orgB, minutos, raio))
        return SendClientMessage(playerid, -1, "[GUERRA] /criarguerra [orgA] [orgB] [minutos] [raio]");
    if(orgA <= 0 || orgB <= 0 || orgA == orgB || minutos < 1 || raio < 20.0) return SendClientMessage(playerid, -1, "[GUERRA] Dados invalidos.");

    new id = -1;
    for(new i = 0; i < MAX_GUERRAS_BCG; i++) if(!GuerraBCG[i][gwAtiva]) { id = i; break; }
    if(id == -1) return SendClientMessage(playerid, -1, "[GUERRA] Limite de guerras simultaneas.");

    GuerraBCG[id][gwAtiva] = true; GuerraBCG[id][gwOrgA] = orgA; GuerraBCG[id][gwOrgB] = orgB;
    GuerraBCG[id][gwPontosA] = 0; GuerraBCG[id][gwPontosB] = 0;
    GuerraBCG[id][gwInicio] = gettime(); GuerraBCG[id][gwDuracao] = minutos * 60; GuerraBCG[id][gwRaio] = raio;
    GetPlayerPos(playerid, GuerraBCG[id][gwX], GuerraBCG[id][gwY], GuerraBCG[id][gwZ]);

    new msg[180];
    format(msg, sizeof msg, "[GUERRA] #%d iniciada: %s x %s | %d min | raio %.0fm", id + 1, GetNomeOrg(orgA), GetNomeOrg(orgB), minutos, raio);
    SendClientMessageToAll(0xE74C3CFF, msg);
    return 1;
}

CMD:pontoguerra(playerid, params[])
{
    #pragma unused params
    new org = Pdados[playerid][OrgID];
    for(new i = 0; i < MAX_GUERRAS_BCG; i++)
    {
        if(!GuerraBCG[i][gwAtiva]) continue;
        if(gettime() >= GuerraBCG[i][gwInicio] + GuerraBCG[i][gwDuracao])
        {
            GuerraBCG[i][gwAtiva] = false;
            SendClientMessageToAll(0xFFD700FF, "[GUERRA] Uma guerra territorial foi encerrada pelo tempo.");
            continue;
        }
        if(org != GuerraBCG[i][gwOrgA] && org != GuerraBCG[i][gwOrgB]) continue;
        if(!IsPlayerInRangeOfPoint(playerid, GuerraBCG[i][gwRaio], GuerraBCG[i][gwX], GuerraBCG[i][gwY], GuerraBCG[i][gwZ]))
            return SendClientMessage(playerid, -1, "[GUERRA] Voce esta fora da area.");

        if(org == GuerraBCG[i][gwOrgA]) GuerraBCG[i][gwPontosA]++;
        else GuerraBCG[i][gwPontosB]++;

        new msg[160];
        format(msg, sizeof msg, "[GUERRA] %s %d x %d %s", GetNomeOrg(GuerraBCG[i][gwOrgA]), GuerraBCG[i][gwPontosA], GuerraBCG[i][gwPontosB], GetNomeOrg(GuerraBCG[i][gwOrgB]));
        SendClientMessageToAll(0xE74C3CFF, msg);
        return 1;
    }
    return SendClientMessage(playerid, -1, "[GUERRA] Sua org nao participa de uma guerra ativa.");
}

CMD:statusguerra(playerid, params[])
{
    #pragma unused params
    for(new i = 0; i < MAX_GUERRAS_BCG; i++)
    {
        if(!GuerraBCG[i][gwAtiva]) continue;
        new restante = (GuerraBCG[i][gwInicio] + GuerraBCG[i][gwDuracao]) - gettime();
        if(restante < 0) restante = 0;
        new msg[180];
        format(msg, sizeof msg, "[GUERRA #%d] %s %d x %d %s | Restante %d min", i + 1, GetNomeOrg(GuerraBCG[i][gwOrgA]), GuerraBCG[i][gwPontosA], GuerraBCG[i][gwPontosB], GetNomeOrg(GuerraBCG[i][gwOrgB]), restante / 60);
        SendClientMessage(playerid, 0xFFD700FF, msg);
    }
    return 1;
}



// ============================================================================
// BCG V4 ULTRA - PAINEL CENTRAL / TABLET / EMPREGOS / SEGURANCA
// ============================================================================

stock BCGV4_NomeJob(id, dest[], size)
{
    switch(id)
    {
        case 1: format(dest, size, "Pizzaiolo");
        case 2: format(dest, size, "Caminhoneiro");
        case 3: format(dest, size, "Lixeiro");
        case 4: format(dest, size, "Motoboy");
        case 5: format(dest, size, "Mecanico");
        case 6: format(dest, size, "Taxista");
        case 7: format(dest, size, "Construtor");
        case 8: format(dest, size, "Entregador");
        case 9: format(dest, size, "Motorista");
        case 10: format(dest, size, "Pescador");
        default: format(dest, size, "Desempregado");
    }
    return 1;
}

stock BCGV4_Tablet(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_BCG_TABLET, DIALOG_STYLE_LIST,
        "{00BFFF}BCG OS 4.0 | TABLET",
        "Organizacao / CORP\nEmprego / Expediente\nCentral de Empregos 2.0\n/checkatt - Atualizacoes\nSeguranca / Anti-Cheat\nCentral de Coins",
        "ABRIR", "FECHAR");
    return 1;
}

stock BCGV4_TabletOrg(playerid)
{
    if(Pdados[playerid][OrgID] <= 0)
        return SendClientMessage(playerid, 0xE74C3CFF, "[TABLET] Voce nao pertence a uma ORG/CORP.");

    new titulo[96];
    format(titulo, sizeof titulo, "{00BFFF}BCG OS | %s", GetNomeOrg(Pdados[playerid][OrgID]));
    ShowPlayerDialog(playerid, DIALOG_BCG_TABLET_ORG, DIALOG_STYLE_LIST, titulo,
        "Membros online\nEquipamentos\nRetirar veiculo da ORG\nGuardar veiculo\nGuerra territorial\nFamilia\nCofre da familia",
        "ABRIR", "VOLTAR");
    return 1;
}

stock BCGV4_TabletEmprego(playerid)
{
    new job[24], titulo[96];
    BCGV4_NomeJob(Pdados[playerid][Trabalho], job, sizeof job);
    format(titulo, sizeof titulo, "{00BFFF}EMPREGO | %s", job);
    ShowPlayerDialog(playerid, DIALOG_BCG_TABLET_JOB, DIALOG_STYLE_LIST, titulo,
        "Trocar profissao\nIniciar expediente\nStatus do expediente\nRetirar veiculo\nGuardar veiculo\nFinalizar expediente",
        "ABRIR", "VOLTAR");
    return 1;
}

stock BCGV4_AbrirEmpregos(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_BCG_JOBS2, DIALOG_STYLE_LIST,
        "{00BFFF}CIDADE GRANDE | EMPREGOS 2.0",
        "Pizzaiolo\nCaminhoneiro\nLixeiro\nMotoboy\nMecanico\nTaxista\nConstrutor\nEntregador\nMotorista\nPescador",
        "ESCOLHER", "FECHAR");
    return 1;
}

stock BCGV4_CheckAtt(playerid)
{
    new texto[2000];
    texto[0] = EOS;
    strcat(texto, "{00BFFF}BCG CIDADE V4 ULTRA\n\n", sizeof texto);
    strcat(texto, "{FFD700}CORE\n{FFFFFF}", sizeof texto);
    strcat(texto, "- Base V3 preservada; sistemas novos sao aditivos\n", sizeof texto);
    strcat(texto, "- Compatibilidade com Pawn 3.2.3664\n", sizeof texto);
    strcat(texto, "- Remocao total de chamadas IsValidVehicle\n", sizeof texto);
    strcat(texto, "- Validacoes extras em veiculos e dialogs\n\n", sizeof texto);
    strcat(texto, "{FFD700}ORGS / CORPS\n{FFFFFF}", sizeof texto);
    strcat(texto, "- Tablet operacional /tablet\n", sizeof texto);
    strcat(texto, "- Membros, equipamentos, guerra, familia e cofres\n", sizeof texto);
    strcat(texto, "- Veiculos por pickup em vez de depender de carros espalhados\n\n", sizeof texto);
    strcat(texto, "{FFD700}EMPREGOS 2.0\n{FFFFFF}", sizeof texto);
    strcat(texto, "- 10 profissoes integradas\n", sizeof texto);
    strcat(texto, "- Expediente, tarefas, ganhos e progresso\n", sizeof texto);
    strcat(texto, "- Tablet de emprego e veiculo profissional\n\n", sizeof texto);
    strcat(texto, "{FFD700}ECONOMIA / COINS / LOJA\n{FFFFFF}", sizeof texto);
    strcat(texto, "- Pedidos de Coins com ID, validade e tentativas\n", sizeof texto);
    strcat(texto, "- Resgate protegido e cancelamento\n", sizeof texto);
    strcat(texto, "- Loja com funcoes reais e validacoes\n\n", sizeof texto);
    strcat(texto, "{FFD700}RP\n{FFFFFF}", sizeof texto);
    strcat(texto, "- Familias, sede e cofre\n", sizeof texto);
    strcat(texto, "- Roubo de casas com cooldown\n", sizeof texto);
    strcat(texto, "- Prisao com trabalho comunitario\n", sizeof texto);
    strcat(texto, "- Guerra territorial\n\n", sizeof texto);
    strcat(texto, "{FFD700}SEGURANCA\n{FFFFFF}", sizeof texto);
    strcat(texto, "- Anti-aim, rapid-fire e damage checks preservados\n", sizeof texto);
    strcat(texto, "- AC V4 monitora deslocamento suspeito e gera score\n", sizeof texto);
    strcat(texto, "- Administracao pode consultar /acstatus2", sizeof texto);
    ShowPlayerDialog(playerid, DIALOG_BCG_CHECKATT, DIALOG_STYLE_MSGBOX,
        "{00BFFF}/checkatt | CHANGELOG", texto, "OK", "");
    return 1;
}

stock BCGV4_ACStatus(playerid)
{
    new texto[500];
    format(texto, sizeof texto, "{00BFFF}ANTI-CHEAT V4\n\n{FFFFFF}Score: {FFD700}%d\n{FFFFFF}Anti-Aim: {00FF00}ATIVO\n{FFFFFF}Rapid Fire: {00FF00}ATIVO\n{FFFFFF}Damage Check: {00FF00}ATIVO\n{FFFFFF}Movimento: {00FF00}ATIVO\n{FFFFFF}Explosivos: {00FF00}MONITORADOS\n\n{AFAFAF}Alertas nao geram ban automatico para reduzir falso positivo.", BCGV4_ACScore[playerid]);
    ShowPlayerDialog(playerid, DIALOG_BCG_ACSTATUS, DIALOG_STYLE_MSGBOX,
        "{00BFFF}BCG | SEGURANCA", texto, "OK", "");
    return 1;
}

stock BCGV4_ACAlert(playerid, motivo[])
{
    BCGV4_ACScore[playerid]++;
    new msg[180];
    format(msg, sizeof msg, "{FF3030}[AC-V4] {FFFFFF}%s [IDF:%d] | %s | score %d",
        Nome(playerid), BCG_IDFixo[playerid], motivo, BCGV4_ACScore[playerid]);
    for(new i = 0; i < MAX_PLAYERS; i++)
        if(IsPlayerConnected(i) && Pdados[i][Admin] > 0) SendClientMessage(i, -1, msg);
    return 1;
}

stock BCGV4_AntiCheatTick(playerid)
{
    if(Pdados[playerid][Admin] >= 8 || !Pdados[playerid][Logado]) return 1;
    new now = GetTickCount();
    if(now - BCGV4_ACLastTick[playerid] < 1800) return 1;
    BCGV4_ACLastTick[playerid] = now;

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(BCGV4_ACX[playerid] != 0.0 && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
        new Float:dx = x - BCGV4_ACX[playerid];
        new Float:dy = y - BCGV4_ACY[playerid];
        new Float:dz = z - BCGV4_ACZ[playerid];
        new Float:d = floatsqroot((dx * dx) + (dy * dy) + (dz * dz));
        if(d > 220.0 && Pdados[playerid][Preso] == 0)
            BCGV4_ACAlert(playerid, "deslocamento anormal");
    }
    BCGV4_ACX[playerid] = x;
    BCGV4_ACY[playerid] = y;
    BCGV4_ACZ[playerid] = z;
    return 1;
}

stock BCGV4_PagamentoJob(job)
{
    switch(job)
    {
        case 1: return 350 + random(251);
        case 2: return 900 + random(501);
        case 3: return 450 + random(301);
        case 4: return 400 + random(301);
        case 5: return 550 + random(451);
        case 6: return 300 + random(401);
        case 7: return 650 + random(451);
        case 8: return 450 + random(351);
        case 9: return 500 + random(401);
        case 10: return 350 + random(551);
    }
    return 0;
}

stock BCGV4_NovaTarefa(playerid)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    SetPlayerCheckpoint(playerid, x + float(random(51) - 25), y + float(random(51) - 25), z, 3.5);
    return 1;
}

CMD:tablet(playerid, params[])
{
    #pragma unused params
    return BCGV4_Tablet(playerid);
}

CMD:tabletorg(playerid, params[])
{
    #pragma unused params
    return BCGV4_TabletOrg(playerid);
}

CMD:tabletcorp(playerid, params[])
{
    #pragma unused params
    return BCGV4_TabletOrg(playerid);
}

CMD:tabletemprego(playerid, params[])
{
    #pragma unused params
    return BCGV4_TabletEmprego(playerid);
}

CMD:checkatt(playerid, params[])
{
    #pragma unused params
    return BCGV4_CheckAtt(playerid);
}

CMD:empregos2(playerid, params[])
{
    #pragma unused params
    return BCGV4_AbrirEmpregos(playerid);
}

CMD:iniciarexpediente(playerid, params[])
{
    #pragma unused params
    if(Pdados[playerid][Trabalho] < 1 || Pdados[playerid][Trabalho] > 10)
        return SendClientMessage(playerid, -1, "[EMPREGO] Escolha uma profissao em /empregos2.");
    if(Pdados[playerid][Trabalhando])
        return SendClientMessage(playerid, -1, "[EMPREGO] Expediente ja esta ativo.");

    Pdados[playerid][Trabalhando] = true;
    BCGV4_JobEntregas[playerid] = 0;
    BCGV4_JobGanhos[playerid] = 0;
    BCGV4_JobInicio[playerid] = gettime();
    BCGV4_NovaTarefa(playerid);
    SendClientMessage(playerid, 0x2ECC71FF, "[EMPREGO] Expediente iniciado. Va ao checkpoint e use /tarefa concluida.");
    return 1;
}

CMD:tarefa(playerid, params[])
{
    #pragma unused params
    if(!Pdados[playerid][Trabalhando])
        return SendClientMessage(playerid, -1, "[EMPREGO] Use /iniciarexpediente primeiro.");

    new pagamento = BCGV4_PagamentoJob(Pdados[playerid][Trabalho]);
    GivePlayerMoney(playerid, pagamento);
    BCGV4_JobEntregas[playerid]++;
    BCGV4_JobGanhos[playerid] += pagamento;
    BCGV4_NovaTarefa(playerid);

    new msg[144];
    format(msg, sizeof msg, "[EMPREGO] Tarefa %d concluida | +R$%d | Proxima rota marcada.",
        BCGV4_JobEntregas[playerid], pagamento);
    SendClientMessage(playerid, 0x2ECC71FF, msg);
    return 1;
}

CMD:statusjob2(playerid, params[])
{
    #pragma unused params
    new job[24], msg[180], minutos = 0;
    BCGV4_NomeJob(Pdados[playerid][Trabalho], job, sizeof job);
    if(BCGV4_JobInicio[playerid] > 0) minutos = (gettime() - BCGV4_JobInicio[playerid]) / 60;
    format(msg, sizeof msg, "[EMPREGO] %s | Tarefas %d | Ganhos R$%d | %d min | Expediente %s",
        job, BCGV4_JobEntregas[playerid], BCGV4_JobGanhos[playerid], minutos,
        Pdados[playerid][Trabalhando] ? ("ATIVO") : ("FECHADO"));
    return SendClientMessage(playerid, 0x00BFFFFF, msg);
}

CMD:finalizarexpediente(playerid, params[])
{
    #pragma unused params
    if(!Pdados[playerid][Trabalhando])
        return SendClientMessage(playerid, -1, "[EMPREGO] Nenhum expediente ativo.");
    Pdados[playerid][Trabalhando] = false;
    DisablePlayerCheckpoint(playerid);
    SalvarDados(playerid);
    new msg[144];
    format(msg, sizeof msg, "[EMPREGO] Expediente encerrado | %d tarefas | R$%d.",
        BCGV4_JobEntregas[playerid], BCGV4_JobGanhos[playerid]);
    return SendClientMessage(playerid, 0x2ECC71FF, msg);
}

CMD:acstatus2(playerid, params[])
{
    new alvo;
    if(Pdados[playerid][Admin] < 1) return 1;
    if(sscanf(params, "u", alvo) || !IsPlayerConnected(alvo))
        return SendClientMessage(playerid, -1, "[AC] /acstatus2 [id]");
    new msg[160];
    format(msg, sizeof msg, "[AC-V4] %s | Score %d | AntiAim %d | Rapid %d",
        Nome(alvo), BCGV4_ACScore[alvo], BCG_AimSuspeita[alvo], BCG_AC_RapidHits[alvo]);
    return SendClientMessage(playerid, 0xFFD700FF, msg);
}

CMD:resetac2(playerid, params[])
{
    new alvo;
    if(Pdados[playerid][Admin] < 8) return 1;
    if(sscanf(params, "u", alvo) || !IsPlayerConnected(alvo))
        return SendClientMessage(playerid, -1, "[AC] /resetac2 [id]");
    BCGV4_ACScore[alvo] = 0;
    BCG_AimSuspeita[alvo] = 0;
    BCG_AC_RapidHits[alvo] = 0;
    return SendClientMessage(playerid, 0x2ECC71FF, "[AC] Score resetado.");
}

// ===================== BCG V036 =====================
public BCG36Enter(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    format(StringContas, sizeof(StringContas), "Contas/%s.txt", Nome(playerid));
    if(DOF2_GetInt(StringContas, "BCG36CadastroIniciado") && !DOF2_GetInt(StringContas, "BCG36CadastroCompleto"))
    {
        SetPVarInt(playerid, "BCG_NOVA_CONTA", 1);
        CarregarDados(playerid);
        Pdados[playerid][Logado] = true;
        return ShowPlayerDialog(playerid, DIALOG_GMAIL_BCG, DIALOG_STYLE_INPUT, "Vincular Gmail", "Conclua seu cadastro para entrar na cidade.", "Vincular", "Sair");
    }
    CarregarDados(playerid);
    VerificarValidadePremium(playerid);

    new Float:PosX = DOF2_GetFloat(StringContas, "PosX");
    new Float:PosY = DOF2_GetFloat(StringContas, "PosY");
    new Float:PosZ = DOF2_GetFloat(StringContas, "PosZ");
    new Float:PosR = DOF2_GetFloat(StringContas, "PosR");
    new skin = Pdados[playerid][Skin];
    new ultimoInterior = DOF2_GetInt(StringContas, "PosInterior");
    new ultimoWorld = DOF2_GetInt(StringContas, "PosWorld");

    // Contas antigas nao possuem essas chaves. Nesse caso o jogador
    // continua no mundo/interior padrao sem quebrar o login.
    if(ultimoInterior < 0) ultimoInterior = 0;
    if(ultimoWorld < 0) ultimoWorld = 0;

    // O OnPlayerSpawn valida este estado. Marque como logado
    // antes do SpawnPlayer para evitar kick indevido.
    Pdados[playerid][Logado] = true;
    Pdados[playerid][pLogged] = 1;
    logado[playerid] = true;

    SetSpawnInfo(playerid, 0, skin, PosX, PosY, PosZ, PosR, 0, 0, 0, 0, 0, 0);
    SetCameraBehindPlayer(playerid);
    TogglePlayerControllable(playerid, 1);
    SpawnPlayer(playerid);

    // O OnPlayerSpawn prepara o jogador no mundo 0. Depois do SpawnPlayer
    // restauramos o interior e Virtual World salvos da ultima sessao.
    SetPlayerSkin(playerid, skin);
    SetPlayerInterior(playerid, ultimoInterior);
    SetPlayerVirtualWorld(playerid, ultimoWorld);
    SetPlayerPos(playerid, PosX, PosY, PosZ);
    SetPlayerFacingAngle(playerid, PosR);
    SetCameraBehindPlayer(playerid);
    
    ResetPlayerWeapons(playerid); 
    new arma_id_temp, muni_temp, tag_arma[24], tag_muni[24];

    for(new i = 0; i < 13; i++) 
    {
        format(tag_arma, sizeof(tag_arma), "Arma_Slot%d", i);
        format(tag_muni, sizeof(tag_muni), "Ammo_Slot%d", i);    
        
        arma_id_temp = DOF2_GetInt(StringContas, tag_arma);
        muni_temp = DOF2_GetInt(StringContas, tag_muni);
    
        if(arma_id_temp > 0 && muni_temp > 0)
        {
            GivePlayerWeapon(playerid, arma_id_temp, muni_temp);
        }
    }   
    
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, Pdados[playerid][Grana]);
    Pdados[playerid][Logado] = true;
    if(Pdados[playerid][Celular] == 1) BCG38EnsureNumber(playerid);
    if(BCG36Client[playerid]) SendClientMessage(playerid, -1, "[BCG:UI]AUTH|OK");
    BCG36LastHud[playerid][0] = EOS;
    if(BCG36Client[playerid]) BCG42HideLegacyHud(playerid);
    BCG36Tick();
    
    if(Pdados[playerid][Admin] > 0)
    {
        format(String, sizeof(String), "Logado como %s", NomeAdm(Pdados[playerid][Admin]));
        SendClientMessage(playerid, AZUL_CLARO, String);
        format(String, sizeof(String), "~r~%s: ~w~%s", NomeAdm(Pdados[playerid][Admin]), Nome(playerid));
        GameTextForAll(String, 1000, 1);
    }

    return 1;
}

public BCG36Selector(playerid)
{
    if(!BCG36Authenticated[playerid]) return 0;
    Pdados[playerid][pLogged] = 0;
    TogglePlayerControllable(playerid, false);
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 10000 + playerid);
    SetPlayerPos(playerid, 1685.4423, -2332.4685, 13.5469);
    SetPlayerFacingAngle(playerid, 180.0);
    SetPlayerSkin(playerid, Pdados[playerid][Skin]);
    SetPlayerCameraPos(playerid, 1685.4423, -2336.8, 14.3);
    SetPlayerCameraLookAt(playerid, 1685.4423, -2332.4685, 14.2);
    new path[64], nascimento[16], origem[32], packet[230], first[25], last[25], character[51];
    format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
    format(first, sizeof(first), "%s", DOF2_GetString(path, "NomePersonagem"));
    format(last, sizeof(last), "%s", DOF2_GetString(path, "SobrenomePersonagem"));
    if(strlen(first) && strlen(last)) format(character, sizeof(character), "%s %s", first, last);
    else format(character, sizeof(character), "%s", Nome(playerid));
    format(nascimento, sizeof(nascimento), "%s", DOF2_GetString(path, "Nascimento"));
    format(origem, sizeof(origem), "%s", DOF2_GetString(path, "Nacionalidade"));
    format(packet, sizeof(packet), "[BCG:UI]PROFILE|%s|%s|%s|%d|%d|%d", character, nascimento, origem,
        Pdados[playerid][Skin], Pdados[playerid][Grana], Pdados[playerid][Banco]);
    SendClientMessage(playerid, -1, packet);
    ShowPlayerDialog(playerid, 23601, DIALOG_STYLE_LIST, "Selecione o personagem", Nome(playerid), "Nascer", "Sair");
    return 1;
}

public BCG36Phone(playerid)
{
    if(BCG43InvOpen[playerid])BCG43InvClose(playerid);
    return BCG38Open(playerid);
}

public BCG36Dialog(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 23601)
    {
        if(!BCG36Authenticated[playerid]) return 1;
        if(!response) { Kick(playerid); return 1; }
        if(listitem != 0) return BCG36Selector(playerid);
        BCG36Authenticated[playerid] = false;
        return BCG36Enter(playerid);
    }
    if(dialogid == 23602)
    {
        if(!GetPVarInt(playerid, "BCG_NOVA_CONTA")) return 1;
        if(!response) { Kick(playerid); return 1; }
        new birth[16], country[32], first[25], last[25], gender, dd, mm, yy;
        if(sscanf(inputtext, "p<|>s[16]s[32]s[25]s[25]i", birth, country, first, last, gender) || sscanf(birth, "p</>iii", dd, mm, yy))
            return ShowPlayerDialog(playerid, 23602, DIALOG_STYLE_INPUT, "Novo personagem", "Data invalida. Use DD/MM/AAAA.", "Confirmar", "Sair");
        if(strlen(birth) != 10 || birth[2] != '/' || birth[5] != '/' || gender < 0 || gender > 1 || !BCG36Name(first) || !BCG36Name(last))
            return ShowPlayerDialog(playerid, 23602, DIALOG_STYLE_INPUT, "Novo personagem", "Confira nome, sobrenome e data.", "Confirmar", "Sair");
        for(new k = 0; k < 10; k++) if(k != 2 && k != 5 && (birth[k] < '0' || birth[k] > '9'))
            return ShowPlayerDialog(playerid, 23602, DIALOG_STYLE_INPUT, "Novo personagem", "Data invalida.", "Confirmar", "Sair");
        new days = 31;
        if(mm == 4 || mm == 6 || mm == 9 || mm == 11) days = 30;
        if(mm == 2) days = ((yy % 4 == 0 && yy % 100 != 0) || yy % 400 == 0) ? 29 : 28;
        new nowY, nowM, nowD;
        getdate(nowY, nowM, nowD);
        if(yy < 1900 || yy > nowY || mm < 1 || mm > 12 || dd < 1 || dd > days ||
            (yy == nowY && (mm > nowM || (mm == nowM && dd > nowD))) ||
            (strcmp(country, "Brasileira", false) && strcmp(country, "Portuguesa", false) && strcmp(country, "Outra", false)))
            return ShowPlayerDialog(playerid, 23602, DIALOG_STYLE_INPUT, "Novo personagem", "Confira nascimento e nacionalidade.", "Confirmar", "Sair");
        new path[64]; format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
        DOF2_SetString(path, "NomePersonagem", first);
        DOF2_SetString(path, "SobrenomePersonagem", last);
        DOF2_SetString(path, "Nascimento", birth);
        DOF2_SetString(path, "Nacionalidade", country);
        DOF2_WriteFile();
        return OnDialogResponse(playerid, DIALOG_GENERO_BCG, 1, gender, "");
    }
    if(!Pdados[playerid][Logado] || GetPVarInt(playerid, "BCG_NOVA_CONTA")) return 1;
    if(dialogid == 23600)
    {
        if(!response || listitem < 0 || listitem > 9) return 1;
        switch(listitem)
        {
            case 0: return OnDialogResponse(playerid, DIALOG_BCG_CELULAR, 1, 0, "");
            case 1: return OnDialogResponse(playerid, DIALOG_BCG_CELULAR, 1, 1, "");
            case 2: return ShowPlayerDialog(playerid, 23606, DIALOG_STYLE_LIST, "CELULAR BCG | Ligacoes", "Ligar\nAtender\nDesligar", "Confirmar", "Voltar");
            case 3: return cmd_gps(playerid);
            case 4: return OnDialogResponse(playerid, DIALOG_BCG_CELULAR, 1, 4, "");
            case 5: return cmd_banco(playerid);
            case 6: return cmd_mochila(playerid, "");
            case 7:
            {
                new path[64], note[256]; format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
                format(note, sizeof(note), "%s", DOF2_GetString(path, "BCGNota"));
                return ShowPlayerDialog(playerid, 23603, DIALOG_STYLE_INPUT, "CELULAR BCG | Notas", note, "Salvar", "Voltar");
            }
            case 8: return ShowPlayerDialog(playerid, 23604, DIALOG_STYLE_MSGBOX, "CELULAR BCG | Calculadora", "Calculadora", "Voltar", "Fechar");
            case 9: return ShowPlayerDialog(playerid, 23605, DIALOG_STYLE_MSGBOX, "CELULAR BCG | Configuracoes", "Preferencias do celular", "Voltar", "Fechar");
        }
    }
    if(dialogid == 23606)
    {
        if(!response) return BCG36Phone(playerid);
        switch(listitem)
        {
            case 0: return OnDialogResponse(playerid, DIALOG_BCG_CELULAR, 1, 2, "");
            case 1: { cmd_atender(playerid, ""); return BCG36Phone(playerid); }
            case 2: { cmd_desligar(playerid, ""); return BCG36Phone(playerid); }
        }
        return 1;
    }
    if(dialogid == 23603 && response)
    {
        new path[64]; format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
        DOF2_SetString(path, "BCGNota", inputtext);
        DOF2_WriteFile();
    }
    if(response) return BCG36Phone(playerid);
    return 1;
}

stock BCG42HideLegacyHud(playerid)
{
    for(new i = 0; i < 6; i++) PlayerTextDrawHide(playerid, Text_Player[playerid][i]);
    for(new i = 0; i < 10; i++) PlayerTextDrawHide(playerid, cWspeedo[playerid][i]);
    TextDrawHideForPlayer(playerid, BCG_MarcaServidor);
    TextDrawHideForPlayer(playerid, BCG_MarcaEstrelas);
    TextDrawHideForPlayer(playerid, BCG_MarcaRoleplay);
    TextDrawHideForPlayer(playerid, BCG_MarcaDataHora);
    return 1;
}

stock BCG42Authenticated(playerid, bool:restore)
{
    BCG36Attempts[playerid] = 0;
    OcultarLoginScreen(playerid);
    OcultarRegistroScreen(playerid);
    CancelSelectTextDraw(playerid);
    ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "", "", "", "");
    SendClientMessage(playerid, -1, "[BCG:UI]AUTH|OK");
    BCG36Authenticated[playerid] = true;
    CarregarDados(playerid);
    TogglePlayerControllable(playerid, false);
    new path[64]; format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
    if(DOF2_GetInt(path, "BCG36CadastroIniciado") && !DOF2_GetInt(path, "BCG36CadastroCompleto"))
    { BCG36Authenticated[playerid] = false; return BCG36Enter(playerid); }
    if(restore) { BCG36Authenticated[playerid] = false; return BCG36Enter(playerid); }
    return BCG36Selector(playerid);
}

CMD:pegarcarro(playerid, params[])
{
    if(!Pdados[playerid][Logado]) return SendClientMessage(playerid, -1, "[ERRO] Entre na sua conta primeiro.");
    new bcg43SpawnModel;
    if(sscanf(params, "i", bcg43SpawnModel)) return SendClientMessage(playerid, -1, "[ERRO] Use /pegarcarro [ID do modelo: 400 a 611].");
    if(bcg43SpawnModel < 400 || bcg43SpawnModel > 611) return SendClientMessage(playerid, -1, "[ERRO] Modelo invalido. Use um ID entre 400 e 611.");
    if(GetPlayerInterior(playerid) != 0) return SendClientMessage(playerid, -1, "[VEICULO] Saia do interior para criar o veiculo.");
    if(GetPVarInt(playerid, "BCG43CarNext") > gettime()) return SendClientMessage(playerid, -1, "[ERRO] Aguarde 5 segundos entre os pedidos.");
    new Float:bcg43SpawnX, Float:bcg43SpawnY, Float:bcg43SpawnZ, Float:bcg43SpawnAngle;
    GetPlayerPos(playerid, bcg43SpawnX, bcg43SpawnY, bcg43SpawnZ);
    GetPlayerFacingAngle(playerid, bcg43SpawnAngle);
    bcg43SpawnX += 4.0 * floatsin(-bcg43SpawnAngle, degrees);
    bcg43SpawnY += 4.0 * floatcos(-bcg43SpawnAngle, degrees);
    BCG47ReleaseVehicle(playerid);
    new bcg43SpawnVehicle = CreateVehicle(bcg43SpawnModel, bcg43SpawnX, bcg43SpawnY, bcg43SpawnZ + 0.5, bcg43SpawnAngle, -1, -1, 300);
    if(bcg43SpawnVehicle == INVALID_VEHICLE_ID || bcg43SpawnVehicle == 0) return SendClientMessage(playerid, -1, "[ERRO] Nao foi possivel criar o veiculo.");
    BCG47TempVehicle[playerid]=bcg43SpawnVehicle;BCG47TempOwner[bcg43SpawnVehicle]=playerid;BCG47TempActive[bcg43SpawnVehicle]=true;
    SetVehicleVirtualWorld(bcg43SpawnVehicle, GetPlayerVirtualWorld(playerid));
    GasolinaVeiculo[bcg43SpawnVehicle] = 100;
    MotorLigado[bcg43SpawnVehicle] = false;
    SetVehicleParamsEx(bcg43SpawnVehicle, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);
    SetPVarInt(playerid, "BCG43CarNext", gettime() + 5);
    new bcg43SpawnNotice[128];
    format(bcg43SpawnNotice, sizeof(bcg43SpawnNotice), "[VEICULO] %s criado! Modelo: %d | Veiculo: %d.", modelNames[bcg43SpawnModel - 400], bcg43SpawnModel, bcg43SpawnVehicle);
    SendClientMessage(playerid, -1, bcg43SpawnNotice);
    return 1;
}

CMD:bcgauth42(playerid, params[])
{
    if(!BCG36Client[playerid]) return 1;
    new bcg42AuthAction[10], bcg42SessionToken[65], path[64], hash[65], stored[65], salt[65];
    if(sscanf(params, "s[10]s[65]", bcg42AuthAction, bcg42SessionToken) || strlen(bcg42SessionToken) != 64) return 1;
    for(new i = 0; i < 64; i++) if(!((bcg42SessionToken[i] >= '0' && bcg42SessionToken[i] <= '9') || (bcg42SessionToken[i] >= 'a' && bcg42SessionToken[i] <= 'f'))) return 1;
    format(path, sizeof(path), "Contas/%s.txt", Nome(playerid));
    if(!DOF2_FileExists(path)) return SendClientMessage(playerid, -1, "[BCG:UI]AUTH|FAIL");
    // A changed password invalidates the remembered session. Only the hash is stored on the server.
    format(salt, sizeof(salt), "%s", DOF2_GetString(path, "Senha"));
    SHA256_PassHash(bcg42SessionToken, salt, hash, sizeof(hash));
    if(!strcmp(bcg42AuthAction, "remember", false))
    {
        if(!Pdados[playerid][Logado] && !BCG36Authenticated[playerid]) return 1;
        DOF2_SetString(path, "BCG42SessionHash", hash);
        DOF2_SetInt(path, "BCG42SessionExpires", gettime() + 2592000);
        DOF2_WriteFile();
        return 1;
    }
    if(strcmp(bcg42AuthAction, "resume", false) || Pdados[playerid][Logado] || BCG36Authenticated[playerid] || BCG36Attempts[playerid] >= 5) return 1;
    BCG36Attempts[playerid]++;
    format(stored, sizeof(stored), "%s", DOF2_GetString(path, "BCG42SessionHash"));
    if(strlen(stored) != 64 || strcmp(hash, stored, false) || DOF2_GetInt(path, "BCG42SessionExpires") <= gettime())
        return SendClientMessage(playerid, -1, "[BCG:UI]AUTH|FAIL");
    return BCG42Authenticated(playerid, true);
}

CMD:bcgui31(playerid, params[])
{
    if(!CG52Approved[playerid])return CG52Challenge(playerid);
    // SA-MP strcmp returns zero for an empty string: an empty handshake must NOT disable the UI.
    if(strlen(params) == 3 && params[0] == 'o' && params[1] == 'f' && params[2] == 'f')
    {
        BCG36Client[playerid] = false;
        return 1;
    }
    new accountPacket[64];
    format(accountPacket, sizeof(accountPacket), "[BCG:UI]ACCOUNT|%s", Nome(playerid));
    SendClientMessage(playerid, -1, accountPacket);
    BCG36Client[playerid] = true;
    BCG36LastHud[playerid][0] = EOS;
    SendClientMessage(playerid, -1, "[BCG:UI]ACK|47");
    if(Pdados[playerid][Logado]) BCG47Load(playerid);
    for(new bcg47Other=0;bcg47Other<MAX_PLAYERS;bcg47Other++) if(bcg47Other!=playerid && IsPlayerConnected(bcg47Other) && IsPlayerStreamedIn(bcg47Other,playerid)) BCG47Packet(bcg47Other,playerid);
    BCG36Tick();
    BCG42HideLegacyHud(playerid);
    new authPacket[100];
    format(authPacket, sizeof(authPacket), "[BCG:UI]AUTH|REQUEST|%s|%d", Nome(playerid), BCG38Instance);
    if(!Pdados[playerid][Logado] && !BCG36Authenticated[playerid]) SendClientMessage(playerid, -1, authPacket);
    if(!Pdados[playerid][Logado])
    {
        OcultarLoginScreen(playerid);
        OcultarRegistroScreen(playerid);
        OcultarLoadingScreen(playerid);
    }
    return 1;
}

CMD:bcgui36(playerid, params[])
{
    if(!params[0] || params[0] == '\1') return 1;
    if(BCG36Authenticated[playerid] && !strcmp(params, "look", false))
    {
        SetPVarInt(playerid, "BCG42_EDIT", 1);
        SetPVarInt(playerid, "BCG36_PREVIEW", 1);
        return ShowPlayerDialog(playerid, DIALOG_PERSONAGEM_BCG, DIALOG_STYLE_LIST, "Aparencia do personagem", "Modular (roupa intima)\nCasual\nRua\nEsportivo\nClassico", "Salvar", "Voltar");
    }
    if((GetPVarInt(playerid, "BCG_NOVA_CONTA") || BCG36Authenticated[playerid]) && GetPVarInt(playerid, "BCG36_PREVIEW"))
    {
        new bcgPreviewAction[12], bcgPreviewSlot;
        if(!sscanf(params, "s[12]i", bcgPreviewAction, bcgPreviewSlot) && !strcmp(bcgPreviewAction, "preview", false) && bcgPreviewSlot >= 0 && bcgPreviewSlot < 5)
        {
            new male[5] = {0, 293, 20, 21, 23}, female[5] = {298, 12, 13, 31, 41};
            SetPlayerSkin(playerid, Pdados[playerid][Genero] == 1 ? male[bcgPreviewSlot] : female[bcgPreviewSlot]);
        }
        if(!sscanf(params, "s[12]i", bcgPreviewAction, bcgPreviewSlot) && !strcmp(bcgPreviewAction, "turn", false) && bcgPreviewSlot >= 0 && bcgPreviewSlot < 8)
            SetPlayerFacingAngle(playerid, float(bcgPreviewSlot * 45));
        return 1;
    }
    if(!Pdados[playerid][pLogged] || GetPVarInt(playerid, "BCG_NOVA_CONTA")) return 1;
    if(!strcmp(params, "sound 1", false)) { SetPVarInt(playerid, "BCG36Silent", 0); return 1; }
    if(!strcmp(params, "sound 0", false)) { SetPVarInt(playerid, "BCG36Silent", 1); return 1; }
    if(GetTickCount()-BCG36LastAction[playerid] < 350) return 1;
    BCG36LastAction[playerid] = GetTickCount();
    if(!strcmp(params, "weapon", false))
    {
        new bcg45Current = GetPlayerWeapon(playerid), bcg45Slot = 0, bcg45Weapon, bcg45Ammo;
        for(new bcg45I = 0; bcg45I < 13; bcg45I++)
        {
            GetPlayerWeaponData(playerid, bcg45I, bcg45Weapon, bcg45Ammo);
            if(bcg45Weapon == bcg45Current) { bcg45Slot = bcg45I; break; }
        }
        for(new bcg45Step = 1; bcg45Step <= 13; bcg45Step++)
        {
            new bcg45Next = (bcg45Slot + bcg45Step) % 13;
            GetPlayerWeaponData(playerid, bcg45Next, bcg45Weapon, bcg45Ammo);
            if(bcg45Next == 0) { SetPlayerArmedWeapon(playerid, 0); return 1; }
            if(bcg45Weapon > 0 && bcg45Ammo > 0) { SetPlayerArmedWeapon(playerid, bcg45Weapon); return 1; }
        }
        return 1;
    }
    if(!strcmp(params, "wardrobe", false)) return cmd_bcglook47(playerid,"open");
    if(!strcmp(params, "phone", false)) return BCG36Phone(playerid);
    if(!strcmp(params,"lights",false)) {
        if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)return SendClientMessage(playerid,-1,"[ERRO] Apenas o motorista controla os farois.");
        new v=GetPlayerVehicleID(playerid),engine,lights,alarm,doors,bonnet,boot,objective;
        GetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
        lights=(lights==1)?0:1;SetVehicleParamsEx(v,engine,lights,alarm,doors,bonnet,boot,objective);
        return SendClientMessage(playerid,-1,lights?"[SUCESSO] Farois ligados.":"[SUCESSO] Farois desligados.");
    }
    if(!strcmp(params, "motor", false)) return cmd_motor(playerid);
    if(!strcmp(params, "trancar", false)) return cmd_trancar(playerid, "");
    if(!strcmp(params, "gps", false)) return cmd_gps(playerid);
    if(!strcmp(params, "inventory", false))return BCG43Inventory(playerid);
    if(!strcmp(params, "inv close", false) || !strfind(params,"use ",false) || !strfind(params,"send ",false) || !strfind(params,"drop ",false) || !strfind(params,"assign ",false) || !strfind(params,"quick ",false))return BCG43InvAction(playerid,params);
    if(!strcmp(params, "mochila", false)) return cmd_mochila(playerid, "");
    return 1;
}

public BCG36Tick()
{
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if(!IsPlayerConnected(playerid) || !BCG36Client[playerid]) continue;
        new vehicle = GetPlayerVehicleID(playerid), speed, fuel = -1, engine = -1, hp = -1;
        if(vehicle > 0 && vehicle < MAX_VEHICLES)
        {
            speed = floatround(GetVehicleSpeed(vehicle));
            fuel = GasolinaVeiculo[vehicle];
            engine = MotorLigado[vehicle] ? 1 : 0;
            new Float:health; GetVehicleHealth(vehicle, health); hp = floatround(health / 10.0);
        }
        new data[180], packet[192];
        new playing = Pdados[playerid][pLogged] && !GetPVarInt(playerid, "BCG_NOVA_CONTA");
        format(data, sizeof(data), "%d|%d|%d|%d|Cidade Grande|%d|%d|%d|%d|%d|%d|%d|%d",
            GetPlayerMoney(playerid), Pdados[playerid][Banco], floatround(Status_Fome[playerid]), floatround(Status_Sede[playerid]),
            vehicle, speed, fuel, engine, hp, floatround(Status_Energia[playerid]), GetPlayerWeapon(playerid), playing);
        if(Pdados[playerid][Logado] && !GetPVarInt(playerid,"BCG43QuickReady")){SetPVarInt(playerid,"BCG43QuickReady",1);BCG43Inventory(playerid,false);}
        if(!BCG36LastHud[playerid][0] || strcmp(data, BCG36LastHud[playerid], false) || GetTickCount()-BCG39LastHudSent[playerid]>=10000)
        {
            BCG39LastHudSent[playerid]=GetTickCount();
            format(BCG36LastHud[playerid], 180, "%s", data);
            format(packet, sizeof(packet), "[BCG:HUD]%s", data);
            SendClientMessage(playerid, -1, packet);
        }
    }
    return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
    if(!strcmp(cmdtext,"/bcgaccess52 ",true,13)){CG52Verify(playerid,cmdtext[13]);return 0;}
    if(!CG52Approved[playerid]){CG52Challenge(playerid);return 0;}
    if(!strcmp(cmdtext,"/bcgauth42",true,10) && cmdtext[10]==' ') { cmd_bcgauth42(playerid,cmdtext[11]); return 0; }
    if(!strcmp(cmdtext,"/bcgphone38",true,11) && cmdtext[11]==' ') { cmd_bcgphone38(playerid,cmdtext[12]); return 0; }

    if(!strcmp(cmdtext, "/bcgui31", true, 8) && (cmdtext[8] == EOS || cmdtext[8] == ' '))
    {
        if(cmdtext[8] == EOS) cmd_bcgui31(playerid, "");
        else cmd_bcgui31(playerid, cmdtext[9]);
        return 0;
    }
    if(!strcmp(cmdtext, "/bcgui36", true, 8) && (cmdtext[8] == EOS || cmdtext[8] == ' '))
    {
        if(cmdtext[8] == EOS) cmd_bcgui36(playerid, "");
        else cmd_bcgui36(playerid, cmdtext[9]);
        return 0;
    }
    if(!Pdados[playerid][pLogged] || GetPVarInt(playerid, "BCG_NOVA_CONTA"))
    {
        SendClientMessage(playerid, 0xE8A85BFF, "Conclua o login e a criacao do personagem primeiro.");
        return 0;
    }
    return 1;
}

stock BCG36Name(const value[])
{
    new length = strlen(value);
    if(length < 2 || length > 24) return 0;
    for(new i = 0; i < length; i++)
    {
        new c = value[i];
        if(!((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c >= 192 || c == ' ' || c == '-')) return 0;
    }
    return 1;
}

CMD:inventario(playerid,params[]) { return cmd_mochila(playerid,params); }

public CG52CanVoice(playerid){return IsPlayerConnected(playerid)&&CG52Approved[playerid]&&Pdados[playerid][pLogged]&&!GetPVarInt(playerid,"BCG_NOVA_CONTA");}

