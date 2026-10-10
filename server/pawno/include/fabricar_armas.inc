#if defined _fabricar_armas_included
    #endinput
#endif
#define _fabricar_armas_included

#include <a_samp>
#include <a_sampdb>
#include <streamer>

// --- Configuracões Avancadas FiveM Style ---
#define MAX_FABRICAS         5       
#define TEMPO_FABRICACAO_MS  10000   // Aumentado para 10 segundos para maior realismo
#define RAIO_FABRICA         2.5     // Raio reduzido para exigir proximidade real da bancada
#define CUSTO_METAIS         1500    
#define DIALOG_FABRICAR_ARMAS 2575

enum E_DADOS_FABRICA {
    bool:fabExiste,
    Float:fabX,
    Float:fabY,
    Float:fabZ,
    fabObjeto,
    Text3D:fabText3D
}

enum E_PLAYER_FABRICA {
    bool:pFabricando,
    pFabricaID,
    pArmaEscolhida,
    pTimerProgresso,
    pContadorProgresso,
    pEfeitoParticula[2]
}

new g_Fabricas[MAX_FABRICAS][E_DADOS_FABRICA];
new g_PlayerFabrica[MAX_PLAYERS][E_PLAYER_FABRICA];
static DB:g_DB_Fabricas;

// TextDraws da Progressbar Minimalista (Estilo NUI do FiveM)
new Text:TD_FabFundo[MAX_PLAYERS];
new Text:TD_FabBarra[MAX_PLAYERS];
new Text:TD_FabTexto[MAX_PLAYERS];

// --- Verificacao de Gangster ---
stock IsPlayerGangForFab(orgid) {
    switch(orgid) {
        case 24, 25, 26, 27, 29, 31: return 1; 
    }
    return 0;
}

// --- Funcões do Banco de Dados ---
stock GetPlayerMetaisDoBanco(playerid) {
    new name[MAX_PLAYER_NAME], query[150], DBResult:res, metais = 0;
    GetPlayerName(playerid, name, sizeof(name));

    format(query, sizeof(query), "SELECT Materiais FROM progresso WHERE Nome = '%s'", name);
    res = db_query(g_DB_Fabricas, query);

    if(db_num_rows(res) > 0) {
        metais = db_get_field_assoc_int(res, "Materiais");
    }
    db_free_result(res);
    return metais;
}

stock DeduzirMetaisDoBanco(playerid, quantidade) {
    new name[MAX_PLAYER_NAME], query[200], atuais;
    GetPlayerName(playerid, name, sizeof(name));
    
    atuais = GetPlayerMetaisDoBanco(playerid);
    new novoTotal = atuais - quantidade;
    if(novoTotal < 0) novoTotal = 0;

    format(query, sizeof(query), "UPDATE progresso SET Materiais = %d WHERE Nome = '%s'", novoTotal, name);
    db_query(g_DB_Fabricas, query);
    return 1;
}

stock InitFabricarArmasDB() {
    g_DB_Fabricas = db_open("rotas_gangsters_v3.db"); 
    db_query(g_DB_Fabricas, "CREATE TABLE IF NOT EXISTS fabricas_armas (ID INTEGER PRIMARY KEY, X REAL, Y REAL, Z REAL)");
    
    CarregarFabricasDoBanco();
    return 1;
}

stock ExitFabricarArmasDB() {
    db_close(g_DB_Fabricas);
    return 1;
}

static stock CarregarFabricasDoBanco() {
    new DBResult:res = db_query(g_DB_Fabricas, "SELECT ID, X, Y, Z FROM fabricas_armas");
    new rows = db_num_rows(res);
    
    for(new i = 0; i < rows; i++) {
        new id = db_get_field_assoc_int(res, "ID");
        if(id >= 0 && id < MAX_FABRICAS) {
            g_Fabricas[id][fabX] = db_get_field_assoc_float(res, "X");
            g_Fabricas[id][fabY] = db_get_field_assoc_float(res, "Y");
            g_Fabricas[id][fabZ] = db_get_field_assoc_float(res, "Z");
            g_Fabricas[id][fabExiste] = true;
            
            CriarElementosVisuaisFabrica(id);
        }
        db_next_row(res);
    }
    db_free_result(res);
}

stock CriarElementosVisuaisFabrica(id) {
    if(IsValidDynamicPickup(g_Fabricas[id][fabObjeto])) DestroyDynamicPickup(g_Fabricas[id][fabObjeto]);
    if(IsValidDynamic3DTextLabel(g_Fabricas[id][fabText3D])) DestroyDynamic3DTextLabel(g_Fabricas[id][fabText3D]);

    // Pickup Invisivel (para usar apenas o texto 3D limpo estilo FiveM)
    g_Fabricas[id][fabObjeto] = CreateDynamicPickup(2964, 1, g_Fabricas[id][fabX], g_Fabricas[id][fabY], g_Fabricas[id][fabZ], -1, -1, -1);
    
    new str[180];
    format(str, sizeof(str), "{00AFFF}• BANCADA DE TRABALHO •\n{FFFFFF}Pressione {00AFFF}[E]{FFFFFF} para acessar o menu\n{757575}Custo da liga metalica: %d materiais", CUSTO_METAIS);
    g_Fabricas[id][fabText3D] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, g_Fabricas[id][fabX], g_Fabricas[id][fabY], g_Fabricas[id][fabZ], 15.0);
}

stock DestruirElementosVisuaisFabrica(id) {
    if(IsValidDynamicPickup(g_Fabricas[id][fabObjeto])) DestroyDynamicPickup(g_Fabricas[id][fabObjeto]);
    if(IsValidDynamic3DTextLabel(g_Fabricas[id][fabText3D])) DestroyDynamic3DTextLabel(g_Fabricas[id][fabText3D]);
    g_Fabricas[id][fabObjeto] = -1;
    g_Fabricas[id][fabText3D] = Text3D:-1;
}

// --- Progressbar Minimalista Estilo FiveM NUI ---
stock CriarTextDrawsFabrica(playerid) {
    // Background Fino Escuro
    TD_FabFundo[playerid] = TextDrawCreate(220.0, 380.0, "ld_spac:white");
    TextDrawFont(TD_FabFundo[playerid], 4);
    TextDrawColor(TD_FabFundo[playerid], 0x111111BB);
    TextDrawTextSize(TD_FabFundo[playerid], 200.0, 8.0);

    // Barra Interna Azul Neon Cyan
    TD_FabBarra[playerid] = TextDrawCreate(220.0, 380.0, "ld_spac:white");
    TextDrawFont(TD_FabBarra[playerid], 4);
    TextDrawColor(TD_FabBarra[playerid], 0x00E5FFCC); 
    TextDrawTextSize(TD_FabBarra[playerid], 0.0, 8.0); 

    // Texto Centralizado acima da barra
    TD_FabTexto[playerid] = TextDrawCreate(320.0, 365.0, "PREPARANDO MAQUINaRIO...");
    TextDrawFont(TD_FabTexto[playerid], 1);
    TextDrawLetterSize(TD_FabTexto[playerid], 0.20, 1.0);
    TextDrawColor(TD_FabTexto[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_FabTexto[playerid], 2);
    TextDrawSetOutline(TD_FabTexto[playerid], 1);
}

stock ExibirProgressBarFabrica(playerid) {
    TextDrawShowForPlayer(playerid, TD_FabFundo[playerid]);
    TextDrawShowForPlayer(playerid, TD_FabBarra[playerid]);
    TextDrawShowForPlayer(playerid, TD_FabTexto[playerid]);
}

stock OcultarProgressBarFabrica(playerid) {
    TextDrawHideForPlayer(playerid, TD_FabFundo[playerid]);
    TextDrawHideForPlayer(playerid, TD_FabBarra[playerid]);
    TextDrawHideForPlayer(playerid, TD_FabTexto[playerid]);
}

stock LimparDadosFabricacaoJogador(playerid) {
    if(g_PlayerFabrica[playerid][pTimerProgresso] != 0) {
        KillTimer(g_PlayerFabrica[playerid][pTimerProgresso]);
        g_PlayerFabrica[playerid][pTimerProgresso] = 0;
    }
    
    // Remove os efeitos visuais e objetos acoplados (Caixas/Faiscas)
    if(IsValidDynamicObject(g_PlayerFabrica[playerid][pEfeitoParticula][0])) DestroyDynamicObject(g_PlayerFabrica[playerid][pEfeitoParticula][0]);
    if(IsValidDynamicObject(g_PlayerFabrica[playerid][pEfeitoParticula][1])) DestroyDynamicObject(g_PlayerFabrica[playerid][pEfeitoParticula][1]);
    RemovePlayerAttachedObject(playerid, 9);

    OcultarProgressBarFabrica(playerid);
    
    TextDrawDestroy(TD_FabFundo[playerid]);
    TextDrawDestroy(TD_FabBarra[playerid]);
    TextDrawDestroy(TD_FabTexto[playerid]);

    g_PlayerFabrica[playerid][pFabricando] = false;
    g_PlayerFabrica[playerid][pFabricaID] = -1;
    g_PlayerFabrica[playerid][pArmaEscolhida] = 0;
    g_PlayerFabrica[playerid][pContadorProgresso] = 0;
}

// --- Timer Dinamico com Efeitos de Som e Particulas (FiveM Style) ---
forward OnUpdateFabricacaoArma(playerid);
public OnUpdateFabricacaoArma(playerid) {
    if(!g_PlayerFabrica[playerid][pFabricando]) {
        LimparDadosFabricacaoJogador(playerid);
        return 0;
    }

    g_PlayerFabrica[playerid][pContadorProgresso]++;
    new pct = g_PlayerFabrica[playerid][pContadorProgresso];

    if(pct <= 100) {
        // Atualiza a barra proporcionalmente ao novo tamanho (200.0 pixels de largura)
        new Float:novoTamanhoAzul = (Float:pct / 100.0) * 200.0;
        TextDrawTextSize(TD_FabBarra[playerid], novoTamanhoAzul, 8.0);
        TextDrawShowForPlayer(playerid, TD_FabBarra[playerid]);

        new str[50];
        if(pct < 30) {
            format(str, sizeof(str), "DERRETENDO SUPRIMENTOS... %d%%", pct);
            if(pct % 10 == 0) PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0); // Som metalico continuo
        }
        else if(pct < 65) {
            format(str, sizeof(str), "PRENSANDO COMPONENTES... %d%%", pct);
            if(pct % 12 == 0) PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0); // Som de engrenagem mecanica
        }
        else {
            format(str, sizeof(str), "MONTANDO MECANISMO DE DISPARO... %d%%", pct);
            if(pct % 8 == 0) PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);  // Som de encaixe tatico
        }

        TextDrawSetString(TD_FabTexto[playerid], str);
        TextDrawShowForPlayer(playerid, TD_FabTexto[playerid]);
    } else {
        // Conclusao com sucesso
        KillTimer(g_PlayerFabrica[playerid][pTimerProgresso]);
        g_PlayerFabrica[playerid][pTimerProgresso] = 0;
        
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);
        OcultarProgressBarFabrica(playerid);

        new arma = g_PlayerFabrica[playerid][pArmaEscolhida];
        
        DeduzirMetaisDoBanco(playerid, CUSTO_METAIS);
        GivePlayerWeapon(playerid, arma, 120); 
        
        PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0); // Som de missao concluida do GTA

        SendClientMessage(playerid, 0x00FF00AA, "[⚙️] Producao concluida com sucesso. Equipamento pronto no inventario.");
        LimparDadosFabricacaoJogador(playerid);
    }
    return 1;
}

// --- COMANDOS ADMINISTRATIVOS ---

CMD:criarfabarma(playerid, params[]) {
    new livre = -1;
    for(new i = 0; i < MAX_FABRICAS; i++) {
        if(!g_Fabricas[i][fabExiste]) {
            livre = i;
            break;
        }
    }

    if(livre == -1) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Limite de fabricas atingido.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    g_Fabricas[livre][fabX] = x;
    g_Fabricas[livre][fabY] = y;
    g_Fabricas[livre][fabZ] = z;
    g_Fabricas[livre][fabExiste] = true;

    CriarElementosVisuaisFabrica(livre);

    new query[150];
    format(query, sizeof(query), "INSERT OR REPLACE INTO fabricas_armas (ID, X, Y, Z) VALUES (%d, %f, %f, %f)", livre, x, y, z);
    db_query(g_DB_Fabricas, query);

    new msg[128];
    format(msg, sizeof(msg), "[ADMIN] Fabrica de Armas ID %d criada com sucesso!", livre);
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}

CMD:deletarfabarma(playerid, params[]) {
    if(isnull(params)) return SendClientMessage(playerid, 0xFF0000AA, "[USO] /deletarfabarma [ID]");
    new id = strval(params);

    if(id < 0 || id >= MAX_FABRICAS || !g_Fabricas[id][fabExiste]) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] ID inexistente.");

    DestruirElementosVisuaisFabrica(id);
    g_Fabricas[id][fabExiste] = false;

    new query[100];
    format(query, sizeof(query), "DELETE FROM fabricas_armas WHERE ID = %d", id);
    db_query(g_DB_Fabricas, query);

    SendClientMessage(playerid, 0xFF0000AA, "[ADMIN] Fabrica removida.");
    return 1;
}

CMD:editfabarma(playerid, params[]) {
    if(isnull(params)) return SendClientMessage(playerid, 0xFF0000AA, "[USO] /editfabarma [ID]");
    new id = strval(params);

    if(id < 0 || id >= MAX_FABRICAS || !g_Fabricas[id][fabExiste]) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] ID invalido.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    g_Fabricas[id][fabX] = x;
    g_Fabricas[id][fabY] = y;
    g_Fabricas[id][fabZ] = z;

    CriarElementosVisuaisFabrica(id);

    new query[150];
    format(query, sizeof(query), "UPDATE fabricas_armas SET X = %f, Y = %f, Z = %f WHERE ID = %d", x, y, z, id);
    db_query(g_DB_Fabricas, query);

    SendClientMessage(playerid, 0x00FFFFAA, "[ADMIN] Posicao reajustada.");
    return 1;
}

// --- INTERAcaO COM TECLA (Substituindo o comando digitado por clique da tecla 'E') ---
stock ProcessarTeclaFabricaArmas(playerid, newkeys) {
    if(newkeys & KEY_SECONDARY_ATTACK) { // Tecla F / ENTER (Equivalente ao 'E' a pe)
        if(g_PlayerFabrica[playerid][pFabricando]) return 1;

        new fabID = -1;
        for(new i = 0; i < MAX_FABRICAS; i++) {
            if(g_Fabricas[i][fabExiste] && IsPlayerInRangeOfPoint(playerid, RAIO_FABRICA, g_Fabricas[i][fabX], g_Fabricas[i][fabY], g_Fabricas[i][fabZ])) {
                fabID = i;
                break;
            }
        }

        if(fabID == -1) return 0; // Nao esta perto de nenhuma bancada
        if(IsPlayerInAnyVehicle(playerid)) return 1;

        new org = CallLocalFunction("GetPlayerOrgID", "d", playerid); 
        if(!IsPlayerGangForFab(org)) {
            SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao possui os contatos necessarios para operar este maquinario!");
            return 1;
        }

        new metaisDisponiveis = GetPlayerMetaisDoBanco(playerid);
        if(metaisDisponiveis < CUSTO_METAIS) {
            new msg[150];
            format(msg, sizeof(msg), "[BANCADA] Materia-prima insuficiente! Voce precisa de %d materiais. Estoque atual: {FFFF00}%d", CUSTO_METAIS, metaisDisponiveis);
            SendClientMessage(playerid, 0xFF0000AA, msg);
            return 1;
        }

        g_PlayerFabrica[playerid][pFabricaID] = fabID;

        // Menu de Contexto Limpo e Moderno
        ShowPlayerDialog(playerid, DIALOG_FABRICAR_ARMAS, DIALOG_STYLE_LIST, 
            "SISTEMA DE ARMAMENTOS ILICITOS", 
            "{FFFFFF}Produzir: {00AFFF}Desert Eagle\n{FFFFFF}Produzir: {00AFFF}MP5\n{FFFFFF}Produzir: {00AFFF}M4\n{FFFFFF}Produzir: {00AFFF}AK-47", 
            "Confirmar", "Fechar"
        );
        return 1;
    }
    return 0;
}

// --- CALLBACK PROCESSADOR DA DIALOG ---
forward Fab_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
public Fab_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == DIALOG_FABRICAR_ARMAS) {
        if(!response) {
            g_PlayerFabrica[playerid][pFabricaID] = -1;
            return 1;
        }

        new fabID = g_PlayerFabrica[playerid][pFabricaID];
        if(fabID == -1 || !IsPlayerInRangeOfPoint(playerid, RAIO_FABRICA, g_Fabricas[fabID][fabX], g_Fabricas[fabID][fabY], g_Fabricas[fabID][fabZ])) {
            SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Operacao interrompida: Distante da bancada.");
            g_PlayerFabrica[playerid][pFabricaID] = -1;
            return 1;
        }

        new metaisDisponiveis = GetPlayerMetaisDoBanco(playerid);
        if(metaisDisponiveis < CUSTO_METAIS) {
            return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao possui mais os materiais!");
        }

        new armaID = 0;
        switch(listitem) {
            case 0: armaID = 24; 
            case 1: armaID = 29; 
            case 2: armaID = 31; 
            case 3: armaID = 30; 
        }

        g_PlayerFabrica[playerid][pFabricando] = true;
        g_PlayerFabrica[playerid][pArmaEscolhida] = armaID;
        g_PlayerFabrica[playerid][pContadorProgresso] = 0;

        CriarTextDrawsFabrica(playerid);
        ExibirProgressBarFabrica(playerid);

        // Trava as acões do jogador para simular foco na producao
        TogglePlayerControllable(playerid, false);
        ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 1, 0, 0, 0, TEMPO_FABRICACAO_MS);

        // [DETALHE FIVEM] Anexa uma caixa de pecas mecanicas (ID 2912) nas maos do jogador enquanto fabrica
        SetPlayerAttachedObject(playerid, 9, 2912, 6, 0.086000, 0.407999, -0.010000, 0.000000, 105.700019, 0.000000, 1.000000, 1.000000, 1.000000);

        // [DETALHE FIVEM] Cria um objeto temporario de faiscas de metalurgica (ID 18725) em cima da bancada
        g_PlayerFabrica[playerid][pEfeitoParticula][0] = CreateDynamicObject(18725, g_Fabricas[fabID][fabX], g_Fabricas[fabID][fabY], g_Fabricas[fabID][fabZ] - 0.4, 0.0, 0.0, 0.0);
        g_PlayerFabrica[playerid][pEfeitoParticula][1] = CreateDynamicObject(18733, g_Fabricas[fabID][fabX], g_Fabricas[fabID][fabY], g_Fabricas[fabID][fabZ] - 0.2, 0.0, 0.0, 0.0); // Fumaca mecanica

        // Inicia o timer sincronizado de atualizacao por porcentagem (10000ms / 100 ticks = 100ms)
        g_PlayerFabrica[playerid][pTimerProgresso] = SetTimerEx("OnUpdateFabricacaoArma", 100, true, "d", playerid);
        return 1;
    }
    return 0;
}
