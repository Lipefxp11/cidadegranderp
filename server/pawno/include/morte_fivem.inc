#if defined _morte_fivem_included
    #endinput
#endif
#define _morte_fivem_included

#include <a_samp>
#include <a_sampdb>
#include <streamer>

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

// TextDraws Globais Nativizadas por ID para o seu Pawno
new Text:TD_MorteFundo[MAX_PLAYERS];
new Text:TD_MorteIcone[MAX_PLAYERS];
new Text:TD_MorteTitulo[MAX_PLAYERS];
new Text:TD_MorteTexto[MAX_PLAYERS];

stock InitMorteFiveM() {
    g_DB_Morte = db_open("coma_persistente.db");
    db_query(g_DB_Morte, "CREATE TABLE IF NOT EXISTS comas (Nome TEXT UNIQUE, EmComa INTEGER, X REAL, Y REAL, Z REAL, A REAL, VW INTEGER, INT INTEGER)");
    
    for(new i = 0; i < MAX_PLAYERS; i++) {
        TD_MorteFundo[i]  = Text:INVALID_TEXT_DRAW;
        TD_MorteIcone[i]  = Text:INVALID_TEXT_DRAW;
        TD_MorteTitulo[i] = Text:INVALID_TEXT_DRAW;
        TD_MorteTexto[i]  = Text:INVALID_TEXT_DRAW;
    }
    return 1;
}

stock ExitMorteFiveM() {
    db_close(g_DB_Morte);
    return 1;
}

stock CriarTextDrawsMortePlayer(playerid) {
    DestruirTextDrawsMortePlayer(playerid);

    // 1. Fundo Escuro de Tela Cheia
    TD_MorteFundo[playerid] = TextDrawCreate(0.0, 0.0, "ld_spac:white");
    TextDrawFont(TD_MorteFundo[playerid], 4);
    TextDrawColor(TD_MorteFundo[playerid], 0x000000E6); 
    TextDrawTextSize(TD_MorteFundo[playerid], 640.0, 480.0);

    // 2. Ícone Centralizado (Substituindo o caractere feio por uma textura/símbolo adequado)
    TD_MorteIcone[playerid] = TextDrawCreate(320.0, 205.0, "hud:radar_eye"); // Ícone nativo de olho do GTA SA
    TextDrawFont(TD_MorteIcone[playerid], 4);
    TextDrawColor(TD_MorteIcone[playerid], 0x0099FFFF);
    TextDrawTextSize(TD_MorteIcone[playerid], 45.0, 45.0);
    TextDrawAlignment(TD_MorteIcone[playerid], 2);

    // 3. Título "DESACORDADO" em maiúsculo, limpo e centralizado
    TD_MorteTitulo[playerid] = TextDrawCreate(320.0, 260.0, "DESACORDADO");
    TextDrawFont(TD_MorteTitulo[playerid], 2); // Fonte limpa (Font 2)
    TextDrawLetterSize(TD_MorteTitulo[playerid], 0.48, 2.0);
    TextDrawColor(TD_MorteTitulo[playerid], 0xFFFFFFFF);
    TextDrawAlignment(TD_MorteTitulo[playerid], 2);
    TextDrawSetOutline(TD_MorteTitulo[playerid], 2);

    // 4. Texto inferior de instrução
    TD_MorteTexto[playerid] = TextDrawCreate(320.0, 310.0, "_");
    TextDrawFont(TD_MorteTexto[playerid], 1);
    TextDrawLetterSize(TD_MorteTexto[playerid], 0.22, 1.0);
    TextDrawColor(TD_MorteTexto[playerid], 0xCCCCCCFF);
    TextDrawAlignment(TD_MorteTexto[playerid], 2);
    TextDrawSetOutline(TD_MorteTexto[playerid], 1);
}


stock DestruirTextDrawsMortePlayer(playerid) {
    if(TD_MorteFundo[playerid] != Text:INVALID_TEXT_DRAW)  { TextDrawDestroy(TD_MorteFundo[playerid]); TD_MorteFundo[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteIcone[playerid] != Text:INVALID_TEXT_DRAW)  { TextDrawDestroy(TD_MorteIcone[playerid]); TD_MorteIcone[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteTitulo[playerid] != Text:INVALID_TEXT_DRAW) { TextDrawDestroy(TD_MorteTitulo[playerid]); TD_MorteTitulo[playerid] = Text:INVALID_TEXT_DRAW; }
    if(TD_MorteTexto[playerid] != Text:INVALID_TEXT_DRAW)  { TextDrawDestroy(TD_MorteTexto[playerid]); TD_MorteTexto[playerid] = Text:INVALID_TEXT_DRAW; }
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
    TextDrawShowForPlayer(playerid, TD_MorteIcone[playerid]);
    TextDrawShowForPlayer(playerid, TD_MorteTitulo[playerid]);
    
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

    new str[256];
    if(!g_DadosMorte[playerid][pPodeDesistir]) {
        format(str, sizeof(str), "AGUARDE ~y~%d SEGUNDOS~w~ PARA RENASCER OU PRESSIONE ~g~G~w~ PARA CHAMAR AJUDA", g_DadosMorte[playerid][pTempoRestanteDesistir]);
    } else {
        new minutosComa = g_DadosMorte[playerid][pTempoRestanteComa] / 60;
        new seg = g_DadosMorte[playerid][pTempoRestanteComa] % 60;
        format(str, sizeof(str), "TEMPO RESTANTE: ~y~%02d:%02d~w~ | USE ~g~/DESISTIR~w~ OU PRESSIONE ~g~G~w~ PARA AJUDA", minutosComa, seg);
    }
    
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

// Hook de Tecla para simular a chamada de ajuda (Tecla G / KEY_WALK)
stock OnMortePlayerKeyStateChange(playerid, newkeys, oldkeys) {
    if(g_DadosMorte[playerid][pEmComa]) {
        if(PRESSED(KEY_WALK)) { // Equivalente à tecla G no SA:MP
            SendClientMessage(playerid, 0x33CCFFAA, "[EMERGENCIA] Voce enviou um sinal via radio de proximaidade chamando atendimento medico!");
            
            // Notificar paramédicos online (Exemplo prático de verificação)
            new string[128], pName[MAX_PLAYER_NAME];
            GetPlayerName(playerid, pName, sizeof(pName));
            format(string, sizeof(string), "[RADIO] Vitima %s esta desacordada! Verifique o mapa.", pName);
            
            foreach(new i : Player) {
                // Insira aqui sua verificação de profissão médica se necessário (ex: IsPlayerMedic(i))
                SendClientMessage(i, 0xFFFF00AA, string);
            }
        }
    }
    return 1;
}
#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

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
