#if defined _caixas_banco_included
    #endinput
#endif
#define _caixas_banco_included

#include <a_samp>
#include <a_sampdb>
#include <streamer>

#define MAX_CAIXAS          50
#define VAGA_ANEXO_BOLSA    3       // Slot de anexo para a bolsa nas costas

// Cores do sistema
#define COR_VERMELHA_BCG    0xFF0000AA
#define COR_VERDE_BCG       0x00FF00AA
#define COR_AVISO_BCG       0xFFFF00AA

// Enum para controle do menu em TextDraw
enum {
    MENU_ESTADO_FECHADO = 0,
    MENU_ESTADO_PRINCIPAL,
    MENU_ESTADO_SACAR,
    MENU_ESTADO_DEPOSITAR
}

enum E_DADOS_CAIXA {
    bool:cxExiste,
    Float:cxX,
    Float:cxY,
    Float:cxZ,
    Float:cxA,
    cxObjeto,
    Text3D:cxText,
    bool:cxSendoRoubado,
    cxTempoReset
}

new g_CaixasDados[MAX_CAIXAS][E_DADOS_CAIXA];
static DB:g_DB_Caixas;

// Variaveis de controle por jogador
new g_EstadoMenuBanco[MAX_PLAYERS];
new g_CaixaMenuID[MAX_PLAYERS];
new g_TempoRouboCaixa[MAX_PLAYERS];
new g_IDCaixaSendoRoubado[MAX_PLAYERS];

// TextDraws do Banco
new Text:TD_BancoFundo;
new Text:TD_BancoTitulo;
new Text:TD_BancoBotaoSacar;
new Text:TD_BancoBotaoDepositar;
new Text:TD_BancoBotaoSaldo;
new Text:TD_BancoBotaoFechar;

// --- Inicializacao do Banco de Dados e TextDraws ---
stock InitCaixasBancoDB() {
    g_DB_Caixas = db_open("caixas_eletronicos.db");
    db_query(g_DB_Caixas, "CREATE TABLE IF NOT EXISTS caixas (ID INTEGER PRIMARY KEY, X REAL, Y REAL, Z REAL, A REAL)");
    
    // Interface Visual (TextDraws) estilo Vida Real
    TD_BancoFundo = TextDrawCreate(200.0, 120.0, "ld_spac:white");
    TextDrawFont(TD_BancoFundo, 4);
    TextDrawColor(TD_BancoFundo, 0x1A1A1ACC); 
    TextDrawTextSize(TD_BancoFundo, 240.0, 220.0);

    TD_BancoTitulo = TextDrawCreate(320.0, 130.0, "BANCO LOCAL");
    TextDrawFont(TD_BancoTitulo, 1);
    TextDrawLetterSize(TD_BancoTitulo, 0.4, 1.6);
    TextDrawColor(TD_BancoTitulo, 0x00FF00FF); 
    TextDrawAlignment(TD_BancoTitulo, 2);
    TextDrawSetOutline(TD_BancoTitulo, 1);

    TD_BancoBotaoSacar = TextDrawCreate(220.0, 180.0, "SACAR DINHEIRO");
    TextDrawFont(TD_BancoBotaoSacar, 1);
    TextDrawLetterSize(TD_BancoBotaoSacar, 0.27, 1.2);
    TextDrawColor(TD_BancoBotaoSacar, 0xFFFFFFFF);
    TextDrawTextSize(TD_BancoBotaoSacar, 420.0, 15.0);
    TextDrawSetSelectable(TD_BancoBotaoSacar, true);

    TD_BancoBotaoDepositar = TextDrawCreate(220.0, 215.0, "DEPOSITAR DINHEIRO");
    TextDrawFont(TD_BancoBotaoDepositar, 1);
    TextDrawLetterSize(TD_BancoBotaoDepositar, 0.27, 1.2);
    TextDrawColor(TD_BancoBotaoDepositar, 0xFFFFFFFF);
    TextDrawTextSize(TD_BancoBotaoDepositar, 420.0, 15.0);
    TextDrawSetSelectable(TD_BancoBotaoDepositar, true);

    TD_BancoBotaoSaldo = TextDrawCreate(220.0, 250.0, "VER SALDO BANCARIO");
    TextDrawFont(TD_BancoBotaoSaldo, 1);
    TextDrawLetterSize(TD_BancoBotaoSaldo, 0.27, 1.2);
    TextDrawColor(TD_BancoBotaoSaldo, 0xFFFFFFFF);
    TextDrawTextSize(TD_BancoBotaoSaldo, 420.0, 15.0);
    TextDrawSetSelectable(TD_BancoBotaoSaldo, true);

    TD_BancoBotaoFechar = TextDrawCreate(320.0, 305.0, "~r~SAIR DA CONTA");
    TextDrawFont(TD_BancoBotaoFechar, 1);
    TextDrawLetterSize(TD_BancoBotaoFechar, 0.3, 1.2);
    TextDrawColor(TD_BancoBotaoFechar, 0xFFFFFFFF);
    TextDrawAlignment(TD_BancoBotaoFechar, 2);
    TextDrawTextSize(TD_BancoBotaoFechar, 80.0, 15.0);
    TextDrawSetSelectable(TD_BancoBotaoFechar, true);

    CarregarCaixasDoBanco();
    return 1;
}

stock ExitCaixasBancoDB() {
    db_close(g_DB_Caixas);
    return 1;
}

forward CriarElementosCaixa(id);
public CriarElementosCaixa(id) {
    if(IsValidDynamicObject(g_CaixasDados[id][cxObjeto])) DestroyDynamicObject(g_CaixasDados[id][cxObjeto]);
    if(IsValidDynamic3DTextLabel(g_CaixasDados[id][cxText])) DestroyDynamic3DTextLabel(g_CaixasDados[id][cxText]);

    g_CaixasDados[id][cxObjeto] = CreateDynamicObject(19324, g_CaixasDados[id][cxX], g_CaixasDados[id][cxY], g_CaixasDados[id][cxZ] - 0.3, 0.0, 0.0, g_CaixasDados[id][cxA]);
    
    new str[150];
    if(g_CaixasDados[id][cxSendoRoubado]) {
        format(str, sizeof(str), "{FF0000}[ CAIXA DANIFICADO ]\n{FFFFFF}ID: %d\nEste caixa foi explodido recentemente!", id);
    } else {
        format(str, sizeof(str), "{00FF00}[ CAIXA ELETRONICO ]\n{FFFFFF}ID: %d\nAperte {FFFF00}[ F ]{FFFFFF} para usar\nOu {FF0000}/roubarcaixa", id);
    }
    g_CaixasDados[id][cxText] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, g_CaixasDados[id][cxX], g_CaixasDados[id][cxY], g_CaixasDados[id][cxZ] + 0.8, 8.0);
    return 1;
}

static stock CarregarCaixasDoBanco() {
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
            g_CaixasDados[id][cxSendoRoubado] = false;
            g_CaixasDados[id][cxTempoReset] = 0;
            
            CriarElementosCaixa(id);
        }
        db_next_row(res);
    }
    db_free_result(res);
}

// --- Funcões de Controle da Interface ---
stock AbrirBancoTextDraw(playerid) {
    TextDrawShowForPlayer(playerid, TD_BancoFundo);
    TextDrawShowForPlayer(playerid, TD_BancoTitulo);
    TextDrawShowForPlayer(playerid, TD_BancoBotaoSacar);
    TextDrawShowForPlayer(playerid, TD_BancoBotaoDepositar);
    TextDrawShowForPlayer(playerid, TD_BancoBotaoSaldo);
    TextDrawShowForPlayer(playerid, TD_BancoBotaoFechar);
    
    g_EstadoMenuBanco[playerid] = MENU_ESTADO_PRINCIPAL;
    SelectTextDraw(playerid, 0x00FF00FF); 
    return 1;
}

stock FecharBancoTextDraw(playerid) {
    TextDrawHideForPlayer(playerid, TD_BancoFundo);
    TextDrawHideForPlayer(playerid, TD_BancoTitulo);
    TextDrawHideForPlayer(playerid, TD_BancoBotaoSacar);
    TextDrawHideForPlayer(playerid, TD_BancoBotaoDepositar);
    TextDrawHideForPlayer(playerid, TD_BancoBotaoSaldo);
    TextDrawHideForPlayer(playerid, TD_BancoBotaoFechar);
    
    g_EstadoMenuBanco[playerid] = MENU_ESTADO_FECHADO;
    CancelSelectTextDraw(playerid);
    return 1;
}

stock VerificarEInteragirCaixa(playerid) {
    new idProximo = -1;
    for(new i = 0; i < MAX_CAIXAS; i++) {
        if(g_CaixasDados[i][cxExiste] && IsPlayerInRangeOfPoint(playerid, 2.2, g_CaixasDados[i][cxX], g_CaixasDados[i][cxY], g_CaixasDados[i][cxZ])) {
            idProximo = i;
            break;
        }
    }

    if(idProximo != -1) {
        g_CaixaMenuID[playerid] = idProximo;
        
        // Abre o Menu Principal do Caixa Eletrônico em DIALOG_STYLE_LIST
        ShowPlayerDialog(playerid, 9920, DIALOG_STYLE_LIST, "{00FF00}CAIXA ELETRÔNICO", 
            "1. Acessar Banco\n2. Roubar Caixinha\n3. Reparar Caixa (Polícia/CORPS)\n4. Abastecer Caixa (Dono)", 
            "Selecionar", "Fechar");
        return 1;
    }
    return 0;
}



stock InterceptarTeclaCaixa(playerid, newkeys, oldkeys) {
    if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK)) {
        if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) { 
            if(g_EstadoMenuBanco[playerid] == MENU_ESTADO_FECHADO) {
                if(VerificarEInteragirCaixa(playerid)) return 1;
            }
        }
    }
    return 0;
}

CMD:caixa(playerid) {
    if(!VerificarEInteragirCaixa(playerid)) {
        SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Voce nao esta proximo a um Caixa Eletronico.");
    }
    return 1;
}

// --- Sistema de Roubo Atualizado ---
CMD:roubarcaixa(playerid) {
    new idProximo = -1;
    for(new i = 0; i < MAX_CAIXAS; i++) {
        if(g_CaixasDados[i][cxExiste] && IsPlayerInRangeOfPoint(playerid, 2.0, g_CaixasDados[i][cxX], g_CaixasDados[i][cxY], g_CaixasDados[i][cxZ])) {
            idProximo = i;
            break;
        }
    }

    if(idProximo == -1) return SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Voce nao esta perto de um Caixa Eletronico.");
    if(g_CaixasDados[idProximo][cxSendoRoubado]) return SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Este caixa ja foi roubado ou esta destruido.");
    
    // Filtro de Orgs criminosas (Exemplo: 13 a 20) -> Mude de acordo com os IDs da sua GM
    new org = Pdados[playerid][Org];
    if(!(org >= 27 && org <= 32))
    {
        return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce nao participa de uma organizacao Gangstar/Criminosa!");
    }

    // Avisa a policia fardada (Orgs 1 a 12)
    new msg[145];
    format(msg, sizeof(msg), "{FF0000}[ALERTA DE ASSALTO] {FFFFFF}Um Caixa Eletronico (ID: %d) esta sendo violado! Verifique o mapa.", idProximo);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && Pdados[i][Org] >= 1 && Pdados[i][Org] <= 12 && Pdados[i][Farda] == true) {
            SendClientMessage(i, -1, msg);
            SetPlayerCheckpoint(i, g_CaixasDados[idProximo][cxX], g_CaixasDados[idProximo][cxY], g_CaixasDados[idProximo][cxZ], 6.0);
        }
    }

    g_CaixasDados[idProximo][cxSendoRoubado] = true;
    g_IDCaixaSendoRoubado[playerid] = idProximo;
    g_TempoRouboCaixa[playerid] = 30; // Tempo em segundos para a bomba detonar

    // Aplica animacao de mexer no caixa (BOMB)
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0, 1);
    
    // Inicia o Timer progressivo
    SetTimerEx("TimerProgressoRoubo", 1000, false, "ii", playerid, idProximo);
    return 1;
}

forward TimerProgressoRoubo(playerid, caixaid);
public TimerProgressoRoubo(playerid, caixaid) {
    if(!IsPlayerConnected(playerid) || !g_CaixasDados[caixaid][cxSendoRoubado]) return 1;

    if(!IsPlayerInRangeOfPoint(playerid, 4.0, g_CaixasDados[caixaid][cxX], g_CaixasDados[caixaid][cxY], g_CaixasDados[caixaid][cxZ])) {
        SendClientMessage(playerid, COR_VERMELHA_BCG, "[ROUBO] Voce se afastou demais e o mecanismo falhou!");
        g_CaixasDados[caixaid][cxSendoRoubado] = false;
        CriarElementosCaixa(caixaid);
        ClearAnimations(playerid);
        return 1;
    }

    g_TempoRouboCaixa[playerid]--;

    new txtDraw[24];
    format(txtDraw, sizeof(txtDraw), "~r~BOMBA: ~w~%ds", g_TempoRouboCaixa[playerid]);
    GameTextForPlayer(playerid, txtDraw, 1000, 3);

    if(g_TempoRouboCaixa[playerid] > 0) {
        // Mantem a animacao ativa enquanto planta
        ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0, 1);
        SetTimerEx("TimerProgressoRoubo", 1000, false, "ii", playerid, caixaid);
    } else {
        // Detonacao
        ClearAnimations(playerid);
        CreateExplosion(g_CaixasDados[caixaid][cxX], g_CaixasDados[caixaid][cxY], g_CaixasDados[caixaid][cxZ], 12, 5.0);
        
        // Sorteia valor do premio
        new recompensa = 5000 + random(8000); 
        Pdados[playerid][DinheiroSujo] += recompensa;
        
        // Atribui a Bolsa de Dinheiro nas Costas do Jogador
        SetPlayerAttachedObject(playerid, VAGA_ANEXO_BOLSA, 1550, 1, -0.1, -0.18, 0.0, 0.0, 90.0, 90.0, 1.0, 1.0, 1.0);
        
        new str[128];
        format(str, sizeof(str), "~g~Cofre Violado!~n~+R$ %d em Dinheiro Sujo", recompensa);
        GameTextForPlayer(playerid, str, 4000, 1);
        SendClientMessage(playerid, COR_VERDE_BCG, "[SISTEMA] Voce recolheu o dinheiro e colocou na bolsa. Lave-o para poder usar.");
        
        g_CaixasDados[caixaid][cxTempoReset] = 600; // 10 minutos para poder roubar de novo
        CriarElementosCaixa(caixaid);
        SetTimerEx("ResetarCaixaStatus", 1000, false, "i", caixaid);
        
        // Forca o salvamento instantaneo do dinheiro sujo adquirido
        DOF2_SaveFile(); 
    }
    return 1;
}

forward ResetarCaixaStatus(caixaid);
public ResetarCaixaStatus(caixaid) {
    if(g_CaixasDados[caixaid][cxTempoReset] > 0) {
        g_CaixasDados[caixaid][cxTempoReset]--;
        SetTimerEx("ResetarCaixaStatus", 1000, false, "i", caixaid);
    } else {
        g_CaixasDados[caixaid][cxSendoRoubado] = false;
        CriarElementosCaixa(caixaid);
    }
    return 1;
}

// --- Sistema de Cliques do Menu TextDraw ---
public OnPlayerClickTextDraw(playerid, Text:clickedid) {
    if(g_EstadoMenuBanco[playerid] == MENU_ESTADO_FECHADO) return 0;

    if(clickedid == INVALID_TEXT_DRAW || clickedid == TD_BancoBotaoFechar) {
        FecharBancoTextDraw(playerid);
        return 1;
    }

    if(clickedid == TD_BancoBotaoSacar) {
        g_EstadoMenuBanco[playerid] = MENU_ESTADO_SACAR;
        new string[120];
        format(string, sizeof(string), "Escolha o valor da quantia a ser sacada.\nSeu saldo e R$: %d", Pdados[playerid][Banco]);
        ShowPlayerDialog(playerid, 9921, DIALOG_STYLE_INPUT, "Banco BCG - Sacar", string, "Confirmar", "Cancelar");
        return 1;
    }

    if(clickedid == TD_BancoBotaoDepositar) {
        g_EstadoMenuBanco[playerid] = MENU_ESTADO_DEPOSITAR;
        new string[120];
        format(string, sizeof(string), "Escolha o valor da quantia a ser depositada.\nSeu saldo e R$: %d", Pdados[playerid][Banco]);
        ShowPlayerDialog(playerid, 9922, DIALOG_STYLE_INPUT, "Banco BCG - Depositar", string, "Confirmar", "Cancelar");
        return 1;
    }

    if(clickedid == TD_BancoBotaoSaldo) {
        new string[120];
        format(string, sizeof(string), "[BANCO BCG] Seu saldo atual e R$: %d", Pdados[playerid][Banco]);
        SendClientMessage(playerid, 0x00FFFFAA, string);
        PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
        // DIALOG PRINCIPAL DO CAIXA ELETRONICO
    if(dialogid == 9920) 
    {
        if(!response) return 1;
        new caixaid = g_CaixaMenuID[playerid];
        new playerNome[MAX_PLAYER_NAME];
        GetPlayerName(playerid, playerNome, sizeof(playerNome));

        switch(listitem) {
            case 0: // Acessar Banco
            {
                if(g_CaixasDados[caixaid][cxSendoRoubado]) {
                    return SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Este caixa esta quebrado e sem sistema!");
                }
                AbrirBancoTextDraw(playerid);
            }
            case 1: // Roubar Caixinha
            {
                if(g_CaixasDados[caixaid][cxSendoRoubado]) {
                    return SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Este caixa ja esta danificado ou sendo roubado!");
                }

                // Inicia o roubo
                g_CaixasDados[caixaid][cxSendoRoubado] = true;
                g_TempoRouboCaixa[playerid] = 30;

                // Avisa as Corporações (Orgs 1 a 12 fardadas)
                new msg[145];
                format(msg, sizeof(msg), "{FF0000}[ALERTA] {FFFFFF}Caixa Eletronico (ID: %d) sendo violado! Verifique o local.", caixaid);
                for(new i = 0; i < MAX_PLAYERS; i++) {
                    if(IsPlayerConnected(i) && Pdados[i][Org] >= 1 && Pdados[i][Org] <= 12 && Pdados[i][Farda]) {
                        SendClientMessage(i, -1, msg);
                        SetPlayerCheckpoint(i, g_CaixasDados[caixaid][cxX], g_CaixasDados[caixaid][cxY], g_CaixasDados[caixaid][cxZ], 6.0);
                    }
                }

                ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, 0, 1);
                SetTimerEx("TimerProgressoRoubo", 1000, false, "ii", playerid, caixaid);
                SendClientMessage(playerid, COR_AVISO_BCG, "[ATENÇaO] Mantenha-se perto enquanto instala a TNT!");
            }
            case 2: // Reparar Caixa (CORPS)
            {
                // Apenas policiais fardados (Orgs 1 a 12)
                if(Pdados[playerid][Org] < 1 || Pdados[playerid][Org] > 12 || !Pdados[playerid][Farda]) {
                    return SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Apenas Policiais fardados podem reparar o caixa.");
                }
                if(!g_CaixasDados[caixaid][cxSendoRoubado]) {
                    return SendClientMessage(playerid, COR_AVISO_BCG, "[INFO] Este caixa nao precisa de reparos.");
                }

                g_CaixasDados[caixaid][cxSendoRoubado] = false;
                g_CaixasDados[caixaid][cxTempoReset] = 0;
                CriarElementosCaixa(caixaid);

                SendClientMessage(playerid, COR_VERDE_BCG, "[SUCESSO] Voce reparou o caixa eletronico com o kit policial!");
            }
            case 3: // Abastecer Caixa (Lipee_fxp1)
            {
                // Apenas voce (Lipee_fxp1)
                if(strcmp(playerNome, "Lipee_fxp1", true) != 0) {
                    return SendClientMessage(playerid, COR_VERMELHA_BCG, "[ERRO] Apenas o dono (Lipee_fxp1) pode abastecer este caixa!");
                }

                g_CaixasDados[caixaid][cxSendoRoubado] = false;
                g_CaixasDados[caixaid][cxTempoReset] = 0;
                CriarElementosCaixa(caixaid);

                SendClientMessage(playerid, COR_VERDE_BCG, "[DONO] Caixa abastecido e redefinido com sucesso!");
            }
        }
        return 1;
    }

    return 0;
}

// --- COMANDOS ADMINISTRATIVOS ---
CMD:criarcaixa(playerid, params[]) {
    new slot = -1;
    for(new i = 0; i < MAX_CAIXAS; i++) {
        if(!g_CaixasDados[i][cxExiste]) { slot = i; break; }
    }
    if(slot == -1) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Limite maximo de caixas atingido.");

    new Float:x, Float:y, Float:z, Float:a;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);

    g_CaixasDados[slot][cxX] = x;
    g_CaixasDados[slot][cxY] = y;
    g_CaixasDados[slot][cxZ] = z;
    g_CaixasDados[slot][cxA] = a; 
    g_CaixasDados[slot][cxExiste] = true;

    CriarElementosCaixa(slot);

    new query[180];
    format(query, sizeof(query), "INSERT INTO caixas (ID, X, Y, Z, A) VALUES (%d, %f, %f, %f, %f)", slot, x, y, z, a);
    db_query(g_DB_Caixas, query);

    new msg[128];
    format(msg, sizeof(msg), "[SUCESSO] Caixa Eletronico ID: %d criado EXATAMENTE na sua posicao atual!", slot);
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}

CMD:deletarcaixa(playerid, params[]) {
    new idProximo = -1;
    for(new i = 0; i < MAX_CAIXAS; i++) {
        if(g_CaixasDados[i][cxExiste] && IsPlayerInRangeOfPoint(playerid, 3.0, g_CaixasDados[i][cxX], g_CaixasDados[i][cxY], g_CaixasDados[i][cxZ])) {
            idProximo = i;
            break;
        }
    }

    if(idProximo == -1) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao esta perto de nenhum caixa criado.");

    if(IsValidDynamicObject(g_CaixasDados[idProximo][cxObjeto])) DestroyDynamicObject(g_CaixasDados[idProximo][cxObjeto]);
    if(IsValidDynamic3DTextLabel(g_CaixasDados[idProximo][cxText])) DestroyDynamic3DTextLabel(g_CaixasDados[idProximo][cxText]);

    new query[100];
    format(query, sizeof(query), "DELETE FROM caixas WHERE ID = %d", idProximo);
    db_query(g_DB_Caixas, query);

    g_CaixasDados[idProximo][cxExiste] = false;
    
    new msg[128];
    format(msg, sizeof(msg), "[SISTEMA] Caixa Eletronico ID: %d deletado.", idProximo);
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}

CMD:editarcaixa(playerid, params[]) {
    new id;
    if(sscanf(params, "d", id)) return SendClientMessage(playerid, 0xFFFF00AA, "[USO] /editarcaixa [ID]");
    if(id < 0 || id >= MAX_CAIXAS || !g_CaixasDados[id][cxExiste]) return SendClientMessage(playerid, 0xFF0000AA, "[ERRO] ID invalido.");

    Streamer_SetIntData(STREAMER_TYPE_OBJECT, g_CaixasDados[id][cxObjeto], E_STREAMER_EXTRA_ID, id);
    EditDynamicObject(playerid, g_CaixasDados[id][cxObjeto]);
    return 1;
}

forward OnClientCheckResponse(playerid, action, objectid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
public OnClientCheckResponse(playerid, action, objectid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
    if(action == EDIT_RESPONSE_FINAL) {
        new id = Streamer_GetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_EXTRA_ID);
        if(id >= 0 && id < MAX_CAIXAS && g_CaixasDados[id][cxExiste]) {
            g_CaixasDados[id][cxX] = x;
            g_CaixasDados[id][cxY] = y;
            g_CaixasDados[id][cxZ] = z;
            g_CaixasDados[id][cxA] = rz;

            new query[200];
            format(query, sizeof(query), "UPDATE caixas SET X = %f, Y = %f, Z = %f, A = %f WHERE ID = %d", x, y, z, rz, id);
            db_query(g_DB_Caixas, query);

            CriarElementosCaixa(id);
            SendClientMessage(playerid, 0x00FF00AA, "[SISTEMA] Posicao updated!");
        }
    }
    return 1;
}
