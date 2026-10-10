#if defined _desmanche_fivem_included
    #endinput
#endif
#define _desmanche_fivem_included

#include <a_samp>
#include <a_sampdb>
#include <streamer>

// --- Configuracões Gerais ---
#define MAX_DESMANCHES       5
#define RAIO_INTERACTION     3.5
#define DIALOG_DESMANCHE_ADM 2910

enum E_DADOS_DESMANCHE {
    bool:desExiste,
    Float:desX,
    Float:desY,
    Float:desZ,
    desArea,
    Text3D:desText3D
}

enum E_PLAYER_DESMANCHE {
    bool:pDesmanchando,
    pDesmancheID,
    pEtapaAtual,
    pTimerProgresso,
    pContadorProgresso,
    pVeiculoAlvo,
    pCheckID,
    Float:pCheckX,
    Float:pCheckY,
    Float:pCheckZ,
    bool:pAguardandoTecla // TRAVA ANTI-FLOOD: Impede pular etapas de uma vez
}

new g_Desmanches[MAX_DESMANCHES][E_DADOS_DESMANCHE];
new g_PlayerDesmanche[MAX_PLAYERS][E_PLAYER_DESMANCHE];
static DB:g_DB_Desmanche;

// TextDraws da Barra de Progresso do Trabalho
new Text:TD_DesFundo[MAX_PLAYERS];
new Text:TD_DesBarra[MAX_PLAYERS];
new Text:TD_DesTexto[MAX_PLAYERS];

// --- Verificacao de Organizacões ---
stock PodeDesmanchar(playerid) {
    new orgid = CallLocalFunction("GetPlayerOrgID", "d", playerid); 
    switch(orgid) {
        case 24, 25, 26, 27, 29, 31: return 1; 
    }
    return 0;
}

stock IsValidVehicleEx(vehicleid) {
    if(vehicleid == 0 || vehicleid == INVALID_VEHICLE_ID) return 0;
    new Float:x, Float:y, Float:z;
    GetVehiclePos(vehicleid, x, y, z);
    if(x == 0.0 && y == 0.0 && z == 0.0) return 0;
    return 1;
}

// --- Inicializacao do Banco de Dados ---
stock InitDesmancheFiveMDB() {
    g_DB_Desmanche = db_open("desmanche_fivem.db");
    db_query(g_DB_Desmanche, "CREATE TABLE IF NOT EXISTS locais (ID INTEGER PRIMARY KEY, X REAL, Y REAL, Z REAL)");
    db_query(g_DB_Desmanche, "CREATE TABLE IF NOT EXISTS inventario_pecas (Nome TEXT UNIQUE, Portas INTEGER, Capos INTEGER, Motores INTEGER, Chassis INTEGER)");
    
    CarregarDesmanchesDoBanco();
    return 1;
}

stock ExitDesmancheFiveMDB() {
    db_close(g_DB_Desmanche);
    return 1;
}

forward CriarElementosDesmanche(id);

static stock CarregarDesmanchesDoBanco() {
    new DBResult:res = db_query(g_DB_Desmanche, "SELECT ID, X, Y, Z FROM locais");
    new rows = db_num_rows(res);
    
    for(new i = 0; i < rows; i++) {
        new id = db_get_field_assoc_int(res, "ID");
        if(id >= 0 && id < MAX_DESMANCHES) {
            g_Desmanches[id][desX] = db_get_field_assoc_float(res, "X");
            g_Desmanches[id][desY] = db_get_field_assoc_float(res, "Y");
            g_Desmanches[id][desZ] = db_get_field_assoc_float(res, "Z");
            g_Desmanches[id][desExiste] = true;
            
            CriarElementosDesmanche(id);
        }
        db_next_row(res);
    }
    db_free_result(res);
}

public CriarElementosDesmanche(id) {
    if(IsValidDynamic3DTextLabel(g_Desmanches[id][desText3D])) DestroyDynamic3DTextLabel(g_Desmanches[id][desText3D]);
    if(IsValidDynamicArea(g_Desmanches[id][desArea])) DestroyDynamicArea(g_Desmanches[id][desArea]);

    new str[180];
    format(str, sizeof(str), "{00E5FF}DESMANCHE OFICIAL\n{FFFFFF}Vaga: {FFFF00}%d\n{FFFFFF}Estacione e pressione {00E5FF}[F / ENTER]{FFFFFF} para preparar o veiculo", id);
    g_Desmanches[id][desText3D] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, g_Desmanches[id][desX], g_Desmanches[id][desY], g_Desmanches[id][desZ], 15.0);
    g_Desmanches[id][desArea] = CreateDynamicCircle(g_Desmanches[id][desX], g_Desmanches[id][desY], RAIO_INTERACTION);
    return 1;
}

stock SalvarPecasNoInventario(playerid, const tipoPeca[]) {
    new name[MAX_PLAYER_NAME], query[250], DBResult:res, atuais = 0;
    GetPlayerName(playerid, name, sizeof(name));

    format(query, sizeof(query), "INSERT OR IGNORE INTO inventario_pecas (Nome, Portas, Capos, Motores, Chassis) VALUES ('%s', 0, 0, 0, 0)", name);
    db_query(g_DB_Desmanche, query);

    format(query, sizeof(query), "SELECT %s FROM inventario_pecas WHERE Nome = '%s'", tipoPeca, name);
    res = db_query(g_DB_Desmanche, query);
    if(db_num_rows(res) > 0) {
        atuais = db_get_field_assoc_int(res, tipoPeca);
    }
    db_free_result(res);

    format(query, sizeof(query), "UPDATE inventario_pecas SET %s = %d WHERE Nome = '%s'", tipoPeca, (atuais + 1), name);
    db_query(g_DB_Desmanche, query);
}

// --- Interface de Progresso (TextDraws) ---
stock CriarTextDrawsDesmanche(playerid) {
    // Destrói se ja existirem na tela para evitar sobreposicao estatica
    TextDrawDestroy(TD_DesFundo[playerid]);
    TextDrawDestroy(TD_DesBarra[playerid]);
    TextDrawDestroy(TD_DesTexto[playerid]);

    TD_DesFundo[playerid] = TextDrawCreate(220.0, 390.0, "ld_spac:white");
    TextDrawFont(TD_DesFundo[playerid], 4);
    TextDrawColor(TD_DesFundo[playerid], 0x222222CC);
    TextDrawTextSize(TD_DesFundo[playerid], 200.0, 7.0);

    TD_DesBarra[playerid] = TextDrawCreate(220.0, 390.0, "ld_spac:white");
    TextDrawFont(TD_DesBarra[playerid], 4);
    TextDrawColor(TD_DesBarra[playerid], 0x00E5FFFF); 
    TextDrawTextSize(TD_DesBarra[playerid], 0.0, 7.0);

    TD_DesTexto[playerid] = TextDrawCreate(320.0, 375.0, "REMOVENDO COMPONENTE...");
    TextDrawFont(TD_DesTexto[playerid], 1);
    TextDrawLetterSize(TD_DesTexto[playerid], 0.20, 0.9);
    TextDrawColor(TD_DesTexto[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_DesTexto[playerid], 2);
    TextDrawSetOutline(TD_DesTexto[playerid], 1);
}

stock ExibirProgresso(playerid) {
    TextDrawShowForPlayer(playerid, TD_DesFundo[playerid]);
    TextDrawShowForPlayer(playerid, TD_DesBarra[playerid]);
    TextDrawShowForPlayer(playerid, TD_DesTexto[playerid]);
}

stock OcultarProgresso(playerid) {
    TextDrawHideForPlayer(playerid, TD_DesFundo[playerid]);
    TextDrawHideForPlayer(playerid, TD_DesBarra[playerid]);
    TextDrawHideForPlayer(playerid, TD_DesTexto[playerid]);
}

stock DestruirTextDrawsDesmanche(playerid) {
    TextDrawDestroy(TD_DesFundo[playerid]);
    TextDrawDestroy(TD_DesBarra[playerid]);
    TextDrawDestroy(TD_DesTexto[playerid]);
    TD_DesFundo[playerid] = Text:INVALID_TEXT_DRAW;
    TD_DesBarra[playerid] = Text:INVALID_TEXT_DRAW;
    TD_DesTexto[playerid] = Text:INVALID_TEXT_DRAW;
}

// --- Gerador Dinamico de Checkpoints ao redor do Carro ---
stock GerarCheckpointPeca(playerid) {
    new veh = g_PlayerDesmanche[playerid][pVeiculoAlvo];
    if(!IsValidVehicleEx(veh)) {
        ResetarDesmanchePlayer(playerid);
        return 0;
    }

    new Float:vx, Float:vy, Float:vz, Float:va;
    GetVehiclePos(veh, vx, vy, vz);
    GetVehicleZAngle(veh, va); 

    new Float:cx, Float:cy;
    new etapa = g_PlayerDesmanche[playerid][pEtapaAtual];
    
    DisablePlayerCheckpoint(playerid); // Limpa checkpoint residual antigo

    switch(etapa) {
        case 1: { // Pneu Dianteiro Esquerdo
            cx = vx + (1.2 * floatsin(-va + 90.0, degrees)) + (1.5 * floatsin(-va, degrees));
            cy = vy + (1.2 * floatcos(-va + 90.0, degrees)) + (1.5 * floatcos(-va, degrees));
            g_PlayerDesmanche[playerid][pCheckX] = cx; g_PlayerDesmanche[playerid][pCheckY] = cy; g_PlayerDesmanche[playerid][pCheckZ] = vz;
            SetPlayerCheckpoint(playerid, cx, cy, vz, 1.5);
            SendClientMessage(playerid, 0x00FFFFAA, "[MECÂNICA] Va ate o checkpoint no {FFFF00}Pneu Dianteiro{00FFFF} e pressione [F / ENTER]");
        }
        case 2: { // Capô / Motor
            cx = vx + (1.8 * floatsin(-va, degrees));
            cy = vy + (1.8 * floatcos(-va, degrees));
            g_PlayerDesmanche[playerid][pCheckX] = cx; g_PlayerDesmanche[playerid][pCheckY] = cy; g_PlayerDesmanche[playerid][pCheckZ] = vz;
            SetPlayerCheckpoint(playerid, cx, cy, vz, 1.5);
            SendClientMessage(playerid, 0x00FFFFAA, "[MECÂNICA] Va ate o checkpoint no {FFFF00}Capô (Motor){00FFFF} e pressione [F / ENTER]");
        }
        case 3: { // Porta Lateral Direita
            cx = vx + (1.2 * floatsin(-va - 90.0, degrees));
            cy = vy + (1.2 * floatcos(-va - 90.0, degrees));
            g_PlayerDesmanche[playerid][pCheckX] = cx; g_PlayerDesmanche[playerid][pCheckY] = cy; g_PlayerDesmanche[playerid][pCheckZ] = vz;
            SetPlayerCheckpoint(playerid, cx, cy, vz, 1.5);
            SendClientMessage(playerid, 0x00FFFFAA, "[MECÂNICA] Va ate o checkpoint na {FFFF00}Porta Direita{00FFFF} e pressione [F / ENTER]");
        }
        case 4: { // Porta-Malas / Chassi
            cx = vx + (1.8 * floatsin(-va + 180.0, degrees));
            cy = vy + (1.8 * floatcos(-va + 180.0, degrees));
            g_PlayerDesmanche[playerid][pCheckX] = cx; g_PlayerDesmanche[playerid][pCheckY] = cy; g_PlayerDesmanche[playerid][pCheckZ] = vz;
            SetPlayerCheckpoint(playerid, cx, cy, vz, 1.5);
            SendClientMessage(playerid, 0x00FFFFAA, "[MECÂNICA] Va ate o checkpoint na {FFFF00}Traseira (Chassi){00FFFF} e pressione [F / ENTER]");
        }
    }
    g_PlayerDesmanche[playerid][pAguardandoTecla] = false; // Libera a tecla para a nova etapa
    return 1;
}

// --- Loop de Desmontagem da Peca ---
forward OnUpdateDesmancheProgresso(playerid);
public OnUpdateDesmancheProgresso(playerid) {
    if(!g_PlayerDesmanche[playerid][pDesmanchando]) return 0;

    g_PlayerDesmanche[playerid][pContadorProgresso] += 4;
    new pct = g_PlayerDesmanche[playerid][pContadorProgresso];
    new veh = g_PlayerDesmanche[playerid][pVeiculoAlvo];

    if(pct <= 100) {
        new Float:tamanho = (Float:pct / 100.0) * 200.0;
        TextDrawTextSize(TD_DesBarra[playerid], tamanho, 7.0);
        TextDrawShowForPlayer(playerid, TD_DesBarra[playerid]);
        
        if(pct % 20 == 0) PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
    } else {
        KillTimer(g_PlayerDesmanche[playerid][pTimerProgresso]);
        OcultarProgresso(playerid);
        DestruirTextDrawsDesmanche(playerid);
        
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);
        RemovePlayerAttachedObject(playerid, 9);

        new etapa = g_PlayerDesmanche[playerid][pEtapaAtual];
        if(IsValidVehicleEx(veh)) {
            switch(etapa) {
                case 1: {
                    UpdateVehicleDamageStatus(veh, 0, 0, 3, 0); 
                    SalvarPecasNoInventario(playerid, "Portas");
                    SendClientMessage(playerid, 0x3498DBFF, "[+] Rodas e eixos removidos.");
                }
                case 2: {
                    UpdateVehicleDamageStatus(veh, 0, 0, 0, 2); 
                    SalvarPecasNoInventario(playerid, "Capos");
                    SendClientMessage(playerid, 0x3498DBFF, "[+] Bloco do motor icado.");
                }
                case 3: {
                    SalvarPecasNoInventario(playerid, "Motores");
                    SendClientMessage(playerid, 0x3498DBFF, "[+] Portas e fiacao extraidas.");
                }
                case 4: {
                    SalvarPecasNoInventario(playerid, "Chassis");
                    DestroyVehicle(veh); 
                    
                    SendClientMessage(playerid, 0x00FF00AA, "[SUCESSO] Veiculo totalmente desmanchado! Pecas adicionadas ao estoque.");
                    PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
                    
                    ResetarDesmanchePlayer(playerid);
                    return 1;
                }
            }
        }

        g_PlayerDesmanche[playerid][pEtapaAtual]++;
        GerarCheckpointPeca(playerid);
    }
    return 1;
}

// --- Processador de Teclas Limpo ---
stock ProcessarCliquesDesmanche(playerid, newkeys) {
    if(newkeys & KEY_SECONDARY_ATTACK) { 
        if(g_PlayerDesmanche[playerid][pAguardandoTecla]) return 1; // Ignora cliques rapidos duplicados (Anti-Flood)

        new veh = GetPlayerVehicleID(playerid);

        // FLUXO 1: Iniciar o trabalho dentro do veiculo
        if(veh != 0 && !g_PlayerDesmanche[playerid][pDesmanchando]) {
            new idLoc = -1;
            for(new i = 0; i < MAX_DESMANCHES; i++) {
                if(g_Desmanches[i][desExiste] && IsPlayerInRangeOfPoint(playerid, RAIO_INTERACTION, g_Desmanches[i][desX], g_Desmanches[i][desY], g_Desmanches[i][desZ])) {
                    idLoc = i;
                    break;
                }
            }

            if(idLoc == -1) return 0; 
            
            if(!PodeDesmanchar(playerid)) {
                SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao tem ferramentas ou autorizacao mecanica aqui!");
                return 1;
            }

            g_PlayerDesmanche[playerid][pAguardandoTecla] = true; // Ativa trava
            g_PlayerDesmanche[playerid][pVeiculoAlvo] = veh;
            g_PlayerDesmanche[playerid][pDesmancheID] = idLoc;
            g_PlayerDesmanche[playerid][pDesmanchando] = true;
            g_PlayerDesmanche[playerid][pEtapaAtual] = 1;

            RemovePlayerFromVehicle(playerid);
            
            SetTimerEx("AguardarSaidaSegura", 1200, false, "d", playerid);
            return 1;
        }

        // FLUXO 2: Desmanchar a peca estando a pe no Checkpoint ativo
        if(veh == 0 && g_PlayerDesmanche[playerid][pDesmanchando]) {
            if(IsPlayerToCheckpoint(playerid)) {
                g_PlayerDesmanche[playerid][pAguardandoTecla] = true; // Ativa trava para nao pular a próxima etapa de uma vez
                
                DisablePlayerCheckpoint(playerid); 
                g_PlayerDesmanche[playerid][pContadorProgresso] = 0;

                CriarTextDrawsDesmanche(playerid);
                
                new textoEtapa[45];
                switch(g_PlayerDesmanche[playerid][pEtapaAtual]) {
                    case 1: {
                        textoEtapa = "DESMONTANDO EIXO E PNEUS...";
                        SetPlayerAttachedObject(playerid, 9, 18622, 5, 0.1, 0.0, 0.0, 0.0, 90.0, 0.0); 
                        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0); 
                    }
                    case 2: {
                        textoEtapa = "RETIRANDO BLOCO DO MOTOR...";
                        ApplyAnimation(playerid, "CAR", "Fixn_Car_Loop", 4.0, 1, 0, 0, 0, 0); 
                    }
                    case 3: {
                        textoEtapa = "EXTRAINDO PORTAS LATERAIS...";
                        SetPlayerAttachedObject(playerid, 9, 18634, 6, 0.1, 0.2, 0.0, 0.0, 0.0, 0.0); 
                        ApplyAnimation(playerid, "GRAFFITI", "GRAFFITI_縱l", 4.0, 1, 0, 0, 0, 0); 
                    }
                    case 4: {
                        textoEtapa = "REDUCÃO E CORTE DO CHASSI...";
                        SetPlayerAttachedObject(playerid, 9, 18634, 6, 0.1, 0.2, 0.0, 0.0, 0.0, 0.0);
                        ApplyAnimation(playerid, "GRAFFITI", "GRAFFITI_縱l", 4.0, 1, 0, 0, 0, 0);
                    }
                }

                TextDrawSetString(TD_DesTexto[playerid], textoEtapa);
                ExibirProgresso(playerid);

                TogglePlayerControllable(playerid, false); 
                g_PlayerDesmanche[playerid][pTimerProgresso] = SetTimerEx("OnUpdateDesmancheProgresso", 150, true, "d", playerid);
                return 1;
            }
        }
    }
    return 0;
}

forward AguardarSaidaSegura(playerid);
public AguardarSaidaSegura(playerid) {
    GerarCheckpointPeca(playerid);
    return 1;
}

// Limpeza de cache interna para evitar TextDraw estatica grudada
stock ResetarDesmanchePlayer(playerid) {
    KillTimer(g_PlayerDesmanche[playerid][pTimerProgresso]);
    DisablePlayerCheckpoint(playerid);
    OcultarProgresso(playerid);
    DestruirTextDrawsDesmanche(playerid);
    
    g_PlayerDesmanche[playerid][pDesmanchando] = false;
    g_PlayerDesmanche[playerid][pAguardandoTecla] = false;
    g_PlayerDesmanche[playerid][pVeiculoAlvo] = 0;
    g_PlayerDesmanche[playerid][pEtapaAtual] = 0;
    
    TogglePlayerControllable(playerid, true);
    RemovePlayerAttachedObject(playerid, 9);
    return 1;
}

static stock IsPlayerToCheckpoint(playerid) {
    if(IsPlayerInRangeOfPoint(playerid, 2.5, g_PlayerDesmanche[playerid][pCheckX], g_PlayerDesmanche[playerid][pCheckY], g_PlayerDesmanche[playerid][pCheckZ])) return 1;
    return 0;
}

// --- Comando Administrativo de Criacao ---
CMD:criardesmanche(playerid, params[]) 
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    if(strcmp(name, "Lipee_fxp1", true) != 0)
        return SendClientMessage(playerid, 0xFF0000FF, "Apenas Lipee_fxp1!");

    new slot = -1;
    for(new i = 0; i < MAX_DESMANCHES; i++) {
        if(!g_Desmanches[i][desExiste]) { slot = i; break; }
    }
    if(slot == -1) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Banco de dados de vagas de desmanche cheio.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    g_Desmanches[slot][desX] = x; g_Desmanches[slot][desY] = y; g_Desmanches[slot][desZ] = z;
    g_Desmanches[slot][desExiste] = true;
    CriarElementosDesmanche(slot); 

    new query[150];
    format(query, sizeof(query), "INSERT INTO locais (ID, X, Y, Z) VALUES (%d, %f, %f, %f)", slot, x, y, z);
    db_query(g_DB_Desmanche, query);

    new msg[128];
    format(msg, sizeof(msg), "[SISTEMA] Vaga de Desmanche por Checkpoints criada com sucesso! ID: %d", slot);
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}
// --- Comando Administrativo para Deletar Desmanche ---
CMD:deletardesmanche(playerid, params[]) 
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));

    if(strcmp(name, "Lipee_fxp1", true) != 0)
        return SendClientMessage(playerid, 0xFF0000FF, "Apenas Lipee_fxp1!");

    new idLoc = -1;
    
    // Procura se o administrador está perto de alguma vaga ativa
    for(new i = 0; i < MAX_DESMANCHES; i++) {
        if(g_Desmanches[i][desExiste] && IsPlayerInRangeOfPoint(playerid, RAIO_INTERACTION, g_Desmanches[i][desX], g_Desmanches[i][desY], g_Desmanches[i][desZ])) {
            idLoc = i;
            break;
        }
    }

    if(idLoc == -1) {
        return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao esta em cima de nenhuma vaga de desmanche ativa.");
    }

    // 1. Destrói os elementos visuais criados pelo Streamer
    if(IsValidDynamic3DTextLabel(g_Desmanches[idLoc][desText3D])) {
        DestroyDynamic3DTextLabel(g_Desmanches[idLoc][desText3D]);
        g_Desmanches[idLoc][desText3D] = Text3D:INVALID_3DTEXT_ID;
    }
    if(IsValidDynamicArea(g_Desmanches[idLoc][desArea])) {
        DestroyDynamicArea(g_Desmanches[idLoc][desArea]);
        g_Desmanches[idLoc][desArea] = -1;
    }

    // 2. Remove o registro permanentemente do Banco de Dados SQLite
    new query[128];
    format(query, sizeof(query), "DELETE FROM locais WHERE ID = %d", idLoc);
    db_query(g_DB_Desmanche, query);

    // 3. Limpa os dados estruturais da array
    g_Desmanches[idLoc][desX] = 0.0;
    g_Desmanches[idLoc][desY] = 0.0;
    g_Desmanches[idLoc][desZ] = 0.0;
    g_Desmanches[idLoc][desExiste] = false;

    // 4. Mensagem de feedback
    new msg[128];
    format(msg, sizeof(msg), "[SISTEMA] Vaga de Desmanche ID: %d foi deletada e removida do banco de dados com sucesso.", idLoc);
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}
