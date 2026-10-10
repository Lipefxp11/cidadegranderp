#if defined _pericia_fivem_included
    #endinput
#endif
#define _pericia_fivem_included

#include <a_samp>
#include <a_sampdb>
#include <streamer>

// --- Configurações Gerais ---
#define MAX_EVIDENCIAS       50
#define RAIO_ANALISE         2.5
#define DIALOG_RELATORIO     3110

enum E_DADOS_EVIDENCIA {
    bool:evAtiva,
    Float:evX,
    Float:evY,
    Float:evZ,
    evVitima[MAX_PLAYER_NAME],
    evArmaID,
    evObjetoCorpo,
    evObjetoSangue,
    evObjetoCapsula,
    Text3D:evText3D
}

enum E_PLAYER_PERITO {
    bool:pEscaneando,
    pEvidencialAlvo,
    pTimerProgresso,
    pContador
}

new g_Evidencias[MAX_EVIDENCIAS][E_DADOS_EVIDENCIA];
new g_PlayerPerito[MAX_PLAYERS][E_PLAYER_PERITO];

// TextDraws do Scanner de Evidências (Estilo Interface Digital NUI)
new Text:TD_ScanFundo[MAX_PLAYERS];
new Text:TD_ScanBarra[MAX_PLAYERS];
new Text:TD_ScanTexto[MAX_PLAYERS];

// --- Verificação de Funções da Polícia / Perícia ---
stock IsPlayerPerito(playerid) {
    new orgid = CallLocalFunction("GetPlayerOrgID", "d", playerid); 
    // Coloque aqui os IDs das organizações policiais/perícia do seu servidor
    switch(orgid) {
        case 1, 2, 3: return 1; 
    }
    return 0;
}

// --- Criação Automática da Cena do Crime (Chamar no OnPlayerDeath) ---
stock RegistrarCenaDoCrime(playerid, killerid, reason) {
    new slot = -1;
    for(new i = 0; i < MAX_EVIDENCIAS; i++) {
        if(!g_Evidencias[i][evAtiva]) { slot = i; break; }
    }
    if(slot == -1) return 0; // Limite de evidências no mapa atingido

    new Float:x, Float:y, Float:z, Float:fa;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, fa);

    g_Evidencias[slot][evAtiva] = true;
    g_Evidencias[slot][evX] = x;
    g_Evidencias[slot][evY] = y;
    g_Evidencias[slot][evZ] = z;
    GetPlayerName(playerid, g_Evidencias[slot][evVitima], MAX_PLAYER_NAME);
    g_Evidencias[slot][evArmaID] = (killerid != INVALID_PLAYER_ID) ? reason : 0;

    // Criando Elementos Visuais na Cena (Corpo no chão, Sangue e Cápsula)
    g_Evidencias[slot][evObjetoCorpo] = CreateDynamicObject(2908, x, y, z - 0.9, 0.0, 90.0, fa); // Objeto de corpo estendido
    g_Evidencias[slot][evObjetoSangue] = CreateDynamicObject(19836, x, y, z - 0.95, 0.0, 0.0, 0.0); // Mancha de sangue
    g_Evidencias[slot][evObjetoCapsula] = CreateDynamicObject(3044, x + 0.5, y + 0.5, z - 0.95, 0.0, 0.0, 0.0); // Cápsula deflagrada

    new str[128];
    format(str, sizeof(str), "{FF3333}[CENA DE CRIME]\n{FFFFFF}Evidência #%d\n{757575}Pressione [F / ENTER] para Escanear", slot);
    g_Evidencias[slot][evText3D] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, x, y, z - 0.4, 10.0);
    return 1;
}

// --- Interface Visual do Scanner ---
stock CriarTextDrawsScanner(playerid) {
    TD_ScanFundo[playerid] = TextDrawCreate(240.0, 390.0, "ld_spac:white");
    TextDrawFont(TD_ScanFundo[playerid], 4);
    TextDrawColor(TD_ScanFundo[playerid], 0x11111199);
    TextDrawTextSize(TD_ScanFundo[playerid], 160.0, 6.0);

    TD_ScanBarra[playerid] = TextDrawCreate(240.0, 390.0, "ld_spac:white");
    TextDrawFont(TD_ScanBarra[playerid], 4);
    TextDrawColor(TD_ScanBarra[playerid], 0x33FF33CC); // Verde Fluorescente Digital
    TextDrawTextSize(TD_ScanBarra[playerid], 0.0, 6.0);

    TD_ScanTexto[playerid] = TextDrawCreate(320.0, 375.0, "ANALISANDO MATERIAL GENÉTICO...");
    TextDrawFont(TD_ScanTexto[playerid], 1);
    TextDrawLetterSize(TD_ScanTexto[playerid], 0.18, 0.8);
    TextDrawColor(TD_ScanTexto[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_ScanTexto[playerid], 2);
    TextDrawSetOutline(TD_ScanTexto[playerid], 1);
}

stock ExibirScanner(playerid) {
    TextDrawShowForPlayer(playerid, TD_ScanFundo[playerid]);
    TextDrawShowForPlayer(playerid, TD_ScanBarra[playerid]);
    TextDrawShowForPlayer(playerid, TD_ScanTexto[playerid]);
}

stock OcultarScanner(playerid) {
    TextDrawHideForPlayer(playerid, TD_ScanFundo[playerid]);
    TextDrawHideForPlayer(playerid, TD_ScanBarra[playerid]);
    TextDrawHideForPlayer(playerid, TD_ScanTexto[playerid]);
}

stock LimparDadosScanner(playerid) {
    if(g_PlayerPerito[playerid][pTimerProgresso] != 0) {
        KillTimer(g_PlayerPerito[playerid][pTimerProgresso]);
        g_PlayerPerito[playerid][pTimerProgresso] = 0;
    }
    OcultarScanner(playerid);
    TextDrawDestroy(TD_ScanFundo[playerid]);
    TextDrawDestroy(TD_ScanBarra[playerid]);
    TextDrawDestroy(TD_ScanTexto[playerid]);
    g_PlayerPerito[playerid][pEscaneando] = false;
}

// --- Processamento da Análise Tática ---
forward OnUpdateScanner(playerid);
public OnUpdateScanner(playerid) {
    if(!g_PlayerPerito[playerid][pEscaneando]) return 0;

    g_PlayerPerito[playerid][pContador]++;
    new pct = g_PlayerPerito[playerid][pContador];
    new idEv = g_PlayerPerito[playerid][pEvidencialAlvo];

    if(pct <= 100) {
        new Float:tamanho = (Float:pct / 100.0) * 160.0;
        TextDrawTextSize(TD_ScanBarra[playerid], tamanho, 6.0);
        TextDrawShowForPlayer(playerid, TD_ScanBarra[playerid]);

        new str[50];
        if(pct < 40) format(str, sizeof(str), "COLETANDO AMOSTRAS: %d%%", pct);
        else if(pct < 80) format(str, sizeof(str), "DECODIFICANDO CALIBRE: %d%%", pct);
        else format(str, sizeof(str), "CONCLUINDO LAUDO: %d%%", pct);
        
        TextDrawSetString(TD_ScanTexto[playerid], str);
        if(pct % 5 == 0) PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0); // Som de bip digital
    } else {
        // Scanner Concluído
        LimparDadosScanner(playerid);
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);
        
        // Formata o Menu de Laudo Balístico/Pericial estilo FiveM NUI
        new dialogStr[300], nomeArma[32];
        GetWeaponName(g_Evidencias[idEv][evArmaID], nomeArma, sizeof(nomeArma));
        if(g_Evidencias[idEv][evArmaID] == 0) format(nomeArma, sizeof(nomeArma), "Causa Desconhecida");

        format(dialogStr, sizeof(dialogStr), 
            "{FFFFFF}Célula de Identificação: {FF3333}#%d\n\n\
            {FFFFFF}Vítima Catalogada: {FFFF00}%s\n\
            {FFFFFF}Rastro de Balística: {00FF00}%s (ID: %d)\n\n\
            {757575}Pressione 'Limpar' para arquivar e recolher a cena.", 
            idEv, g_Evidencias[idEv][evVitima], nomeArma, g_Evidencias[idEv][evArmaID]
        );

        ShowPlayerDialog(playerid, DIALOG_RELATORIO, DIALOG_STYLE_MSGBOX, "📋 LAUDO TÁTICO DA PERÍCIA", dialogStr, "Limpar", "Fechar");
    }
    return 1;
}

// --- Detecção de Teclas Multiplataforma (PC/Mobile) ---
stock ProcessarTeclasPericia(playerid, newkeys) {
    if((newkeys & KEY_SECONDARY_ATTACK) && !g_PlayerPerito[playerid][pEscaneando]) { // Tecla F / ENTER
        if(!IsPlayerPerito(playerid)) return 0;

        new idEv = -1;
        for(new i = 0; i < MAX_EVIDENCIAS; i++) {
            if(g_Evidencias[i][evAtiva] && IsPlayerInRangeOfPoint(playerid, RAIO_ANALISE, g_Evidencias[i][evX], g_Evidencias[i][evY], g_Evidencias[i][evZ])) {
                idEv = i;
                break;
            }
        }

        if(idEv == -1) return 0;

        g_PlayerPerito[playerid][pEscaneando] = true;
        g_PlayerPerito[playerid][pEvidencialAlvo] = idEv;
        g_PlayerPerito[playerid][pContador] = 0;

        CriarTextDrawsScanner(playerid);
        ExibirScanner(playerid);

        TogglePlayerControllable(playerid, false);
        ApplyAnimation(playerid, "MEDIC", "CPR", 4.0, 1, 0, 0, 0, 0); // Animação examinando o chão

        g_PlayerPerito[playerid][pTimerProgresso] = SetTimerEx("OnUpdateScanner", 60, true, "d", playerid);
        return 1;
    }
    return 0;
}

// --- Callback para Processar a Resposta do Relatório ---
stock ProcessarDialogPericia(playerid, dialogid, response) {
    if(dialogid == DIALOG_RELATORIO) {
        if(response) { // Clicou em "Limpar"
            new idEv = g_PlayerPerito[playerid][pEvidencialAlvo];
            if(idEv != -1 && g_Evidencias[idEv][evAtiva]) {
                
                // Remove fisicamente todos os objetos e marcações do mapa
                DestroyDynamicObject(g_Evidencias[idEv][evObjetoCorpo]);
                DestroyDynamicObject(g_Evidencias[idEv][evObjetoSangue]);
                DestroyDynamicObject(g_Evidencias[idEv][evObjetoCapsula]);
                DestroyDynamic3DTextLabel(g_Evidencias[idEv][evText3D]);

                g_Evidencias[idEv][evAtiva] = false;
                SendClientMessage(playerid, 0x00FF00AA, "[PERÍCIA] Cena de crime limpa e arquivada com sucesso.");
                PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
            }
        }
        g_PlayerPerito[playerid][pEvidencialAlvo] = -1;
        return 1;
    }
    return 0;
}
