/*
    ======================================================
    =          Sistema de WhiteList - Otimizado          =
    =                    by: dudu_xxx                    =
    =        GitHub: https://github.com/DuduXxx6         =
    =     YouTube: https://www.youtube.com/@duduxxx      =
    ======================================================
*/

#if defined _whitelist_included
    #endinput
#endif
#define _whitelist_included

#include <a_samp>

#define public:whitelist%0(%1)      forward %0(%1); public %0(%1)

// Constantes e Limites
#define MAX_WHITELIST_TEXTDRAWS 5
#define MAX_LOAD_TEXTDRAWS      2

enum enum_whitelist {
    whitelist_Valid,
    PlayerText: whitelist_textdraw[MAX_WHITELIST_TEXTDRAWS]
}

// Tornadas globais para poderem ser usadas no seu OnGameModeInit da GM
stock Text: Text_WhitelistCarregamento[MAX_LOAD_TEXTDRAWS];
static PlayerWhitelist[MAX_PLAYERS][enum_whitelist];

// Declaração antecipada da forward exigida pela GameMode
forward OnPlayerWhitelist(playerid);
forward OnPlayerValidWhitelist(playerid);

public OnPlayerConnect(playerid) {
    SetPlayerWhitelist(playerid, 0);

    PlayerWhitelist[playerid][whitelist_textdraw][0] = CreatePlayerTextDraw(playerid, 332.000, 188.000, "Seu acesso ao servidor nao esta liberado na nossa whitelist. Para resolver isso, siga os passos abaixo:");
    PlayerTextDrawLetterSize(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 0.180, 1.090);
    PlayerTextDrawAlignment(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 2);
    PlayerTextDrawColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], -1);
    PlayerTextDrawSetShadow(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 1);
    PlayerTextDrawSetOutline(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 0);
    PlayerTextDrawFont(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 1);
    PlayerTextDrawSetProportional(playerid, PlayerWhitelist[playerid][whitelist_textdraw][0], 1);

    new string[128];
    format(string, sizeof(string), "Atencao %s", Nome(playerid));
    PlayerWhitelist[playerid][whitelist_textdraw][1] = CreatePlayerTextDraw(playerid, 310.000, 175.000, string);
    PlayerTextDrawLetterSize(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 0.180, 1.090);
    PlayerTextDrawAlignment(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 2);
    PlayerTextDrawColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], -1);
    PlayerTextDrawSetShadow(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 1);
    PlayerTextDrawSetOutline(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 0);
    PlayerTextDrawFont(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 1);
    PlayerTextDrawSetProportional(playerid, PlayerWhitelist[playerid][whitelist_textdraw][1], 1);

    format(string, sizeof(string), "1- Entre no nosso Discord: %s~n~2- Va ate o canal %s e siga as instrucoes para liberar seu acesso.", link_discord, name_canal);
    PlayerWhitelist[playerid][whitelist_textdraw][2] = CreatePlayerTextDraw(playerid, 169.000, 200.000, string);
    PlayerTextDrawLetterSize(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 0.199, 1.199);
    PlayerTextDrawAlignment(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 1);
    PlayerTextDrawColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], -1);
    PlayerTextDrawSetShadow(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 1);
    PlayerTextDrawSetOutline(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 0);
    PlayerTextDrawFont(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 1);
    PlayerTextDrawSetProportional(playerid, PlayerWhitelist[playerid][whitelist_textdraw][2], 1);

    PlayerWhitelist[playerid][whitelist_textdraw][3] = CreatePlayerTextDraw(playerid, 341.000, 228.000, "Importante: Nao e necessario relogar o jogo. Assim que sua whitelist for liberada, voce podera voltar ao servidor normalmente!");
    PlayerTextDrawLetterSize(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 0.180, 1.090);
    PlayerTextDrawAlignment(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 2);
    PlayerTextDrawColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], -1);
    PlayerTextDrawSetShadow(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 1);
    PlayerTextDrawSetOutline(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 0);
    PlayerTextDrawFont(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 1);
    PlayerTextDrawSetProportional(playerid, PlayerWhitelist[playerid][whitelist_textdraw][3], 1);

    PlayerWhitelist[playerid][whitelist_textdraw][4] = CreatePlayerTextDraw(playerid, 312.000, 246.000, "Estamos esperando por voce!");
    PlayerTextDrawLetterSize(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 0.180, 1.090);
    PlayerTextDrawAlignment(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 2);
    PlayerTextDrawColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], -1);
    PlayerTextDrawSetShadow(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 1);
    PlayerTextDrawSetOutline(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 1);
    PlayerTextDrawBackgroundColor(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 0);
    PlayerTextDrawFont(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 1);
    PlayerTextDrawSetProportional(playerid, PlayerWhitelist[playerid][whitelist_textdraw][4], 1);

    return CallLocalFunction("WHIT_OPC", "d", playerid);
}

public OnPlayerDisconnect(playerid, reason) {
    for(new i = 0; i < MAX_WHITELIST_TEXTDRAWS; i++) {
        PlayerTextDrawDestroy(playerid, PlayerWhitelist[playerid][whitelist_textdraw][i]);
        PlayerWhitelist[playerid][whitelist_textdraw][i] = PlayerText:INVALID_TEXT_DRAW;
    }
    return CallLocalFunction("WHIT_OPD", "dd", playerid, reason);
}

public OnPlayerRequestClass(playerid, classid) {
    for(new i = 0; i < MAX_LOAD_TEXTDRAWS; i++) {
        TextDrawShowForPlayer(playerid, Text_WhitelistCarregamento[i]);
    }
    
    SetTimerEx("OnPlayerValidWhitelist", 2000, false, "i", playerid);
    return CallLocalFunction("WHIT_OPRC", "dd", playerid, classid);
}

public OnPlayerSpawn(playerid) {
    if(GetPlayerWhitelist(playerid) != 1) {
        Kick(playerid);
        return 0;
    }
    return CallLocalFunction("WHIT_OPS", "d", playerid);
}

public:whitelist OnPlayerValidWhitelist(playerid) {
    new file_path[64];
    format(file_path, sizeof(file_path), "%s/%s.ini", pasta_whitelist, Nome(playerid));

    if(DOF2_FileExists(file_path)) {
        for(new i = 0; i < MAX_LOAD_TEXTDRAWS; i++) {
            TextDrawHideForPlayer(playerid, Text_WhitelistCarregamento[i]);
        }
        for(new i = 0; i < MAX_WHITELIST_TEXTDRAWS; i++) {
            PlayerTextDrawHide(playerid, PlayerWhitelist[playerid][whitelist_textdraw][i]);
        }

        SetPlayerWhitelist(playerid, 1);
        SetTimerEx("OnPlayerWhitelist", 1000, false, "i", playerid);
    } 
    else {
        TextDrawHideForPlayer(playerid, Text_WhitelistCarregamento[1]);
        for(new i = 0; i < MAX_WHITELIST_TEXTDRAWS; i++) {
            PlayerTextDrawShow(playerid, PlayerWhitelist[playerid][whitelist_textdraw][i]);
        }
        
        SetTimerEx("OnPlayerValidWhitelist", 2000, false, "i", playerid);
    }
    return true;
}

stock SetPlayerWhitelist(playerid, whitelist = 0) {
    PlayerWhitelist[playerid][whitelist_Valid] = whitelist;
    return PlayerWhitelist[playerid][whitelist_Valid];
}

stock GetPlayerWhitelist(playerid) {
    return PlayerWhitelist[playerid][whitelist_Valid];
}

// Mantidos apenas os ganchos necessários para as outras callbacks (sem mexer no OnGameModeInit)
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn WHIT_OPS
forward WHIT_OPS(playerid);

#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect WHIT_OPC
forward WHIT_OPC(playerid);

#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect WHIT_OPD
forward WHIT_OPD(playerid, reason);

#if defined _ALS_OnPlayerRequestClass
    #undef OnPlayerRequestClass
#else
    #define _ALS_OnPlayerRequestClass
#endif
#define OnPlayerRequestClass WHIT_OPRC
forward WHIT_OPRC(playerid, classid);
