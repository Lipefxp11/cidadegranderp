#if defined _celular_included
    #endinput
#endif
#define _celular_included

// --- DEFINIÇÕES DE TELAS ---
#define TELA_INICIAL    0
#define TELA_BANCO      1
#define TELA_CALC       2
#define TELA_WHATS      3
#define TELA_CONFIG     4

// --- VARIÁVEIS DOS TEXTDRAWS DO CELULAR ---
static PlayerText:CelularBorda[MAX_PLAYERS];
static PlayerText:CelularFundo[MAX_PLAYERS];
static PlayerText:CelularBarraTopo[MAX_PLAYERS];
static PlayerText:CelularTextoTopo[MAX_PLAYERS];
static PlayerText:CelularHomeBar[MAX_PLAYERS];
static PlayerText:CelularTitulo[MAX_PLAYERS];

// Ícones da Home (Menu Principal)
static PlayerText:AppBancoFundo[MAX_PLAYERS];
static PlayerText:AppBancoTexto[MAX_PLAYERS];
static PlayerText:AppWhatsFundo[MAX_PLAYERS];
static PlayerText:AppWhatsTexto[MAX_PLAYERS];
static PlayerText:AppCalcFundo[MAX_PLAYERS];
static PlayerText:AppCalcTexto[MAX_PLAYERS];
static PlayerText:AppConfigFundo[MAX_PLAYERS];
static PlayerText:AppConfigTexto[MAX_PLAYERS];

// App: Banco
static PlayerText:BancoFundoTela[MAX_PLAYERS];
static PlayerText:BancoTextoSaldo[MAX_PLAYERS];
static PlayerText:BancoBotaoEmprestimo[MAX_PLAYERS];

// App: Calculadora
static PlayerText:CalcFundoTela[MAX_PLAYERS];
static PlayerText:CalcDisplay[MAX_PLAYERS];

// App: WhatsApp
static PlayerText:WhatsFundoTela[MAX_PLAYERS];
static PlayerText:WhatsTextoHeader[MAX_PLAYERS];
static PlayerText:WhatsConversa1[MAX_PLAYERS];

// App: Configurações
static PlayerText:ConfigFundoTela[MAX_PLAYERS];
static PlayerText:ConfigTextoInfo[MAX_PLAYERS];

// Estados do Jogador
static bool:CelularAberto[MAX_PLAYERS];
static CelularTelaAtual[MAX_PLAYERS];

// ==========================================
// FUNÇÃO DE CRIAÇÃO DAS TEXTDRAWS
// ==========================================
stock Celular_CriarTextDraws(playerid) {
    // 1. Moldura Externa (Carcaça do Celular)
    CelularBorda[playerid] = CreatePlayerTextDraw(playerid, 475.0, 60.0, "_");
    PlayerTextDrawUseBox(playerid, CelularBorda[playerid], 1);
    PlayerTextDrawBoxColor(playerid, CelularBorda[playerid], 0x111111FF);
    PlayerTextDrawTextSize(playerid, CelularBorda[playerid], 585.0, 480.0);
    PlayerTextDrawLetterSize(playerid, CelularBorda[playerid], 0.0, 39.5);

    // 2. Tela Interna (Fundo Preto Principal)
    CelularFundo[playerid] = CreatePlayerTextDraw(playerid, 478.0, 64.0, "_");
    PlayerTextDrawUseBox(playerid, CelularFundo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, CelularFundo[playerid], 0x0A0A0AFF);
    PlayerTextDrawTextSize(playerid, CelularFundo[playerid], 582.0, 460.0);
    PlayerTextDrawLetterSize(playerid, CelularFundo[playerid], 0.0, 37.5);

    // 3. Barra Superior (Status bar)
    CelularBarraTopo[playerid] = CreatePlayerTextDraw(playerid, 478.0, 64.0, "_");
    PlayerTextDrawUseBox(playerid, CelularBarraTopo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, CelularBarraTopo[playerid], 0x1A1A1AFF);
    PlayerTextDrawTextSize(playerid, CelularBarraTopo[playerid], 582.0, 82.0);
    PlayerTextDrawLetterSize(playerid, CelularBarraTopo[playerid], 0.0, 1.1);

    CelularTextoTopo[playerid] = CreatePlayerTextDraw(playerid, 484.0, 67.0, "00:24   3G   [100%]");
    PlayerTextDrawFont(playerid, CelularTextoTopo[playerid], 1);
    PlayerTextDrawLetterSize(playerid, CelularTextoTopo[playerid], 0.16, 0.85);
    PlayerTextDrawColor(playerid, CelularTextoTopo[playerid], -1);
    PlayerTextDrawSetProportional(playerid, CelularTextoTopo[playerid], 1);

    CelularTitulo[playerid] = CreatePlayerTextDraw(playerid, 530.0, 250.0, "CIDADE GRANDE~n~ROLEPLAY");
    PlayerTextDrawFont(playerid, CelularTitulo[playerid], 2);
    PlayerTextDrawLetterSize(playerid, CelularTitulo[playerid], 0.18, 0.85);
    PlayerTextDrawColor(playerid, CelularTitulo[playerid], 0xFFFFFF22);
    PlayerTextDrawAlignment(playerid, CelularTitulo[playerid], 2);
    PlayerTextDrawSetProportional(playerid, CelularTitulo[playerid], 1);

    // 4. Ícones dos Aplicativos na Home
    // Banco (N)
    AppBancoFundo[playerid] = CreatePlayerTextDraw(playerid, 490.0, 95.0, "_");
    PlayerTextDrawUseBox(playerid, AppBancoFundo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, AppBancoFundo[playerid], 0x6A0DADFF);
    PlayerTextDrawTextSize(playerid, AppBancoFundo[playerid], 512.0, 117.0);
    PlayerTextDrawLetterSize(playerid, AppBancoFundo[playerid], 0.0, 1.8);
    PlayerTextDrawSetSelectable(playerid, AppBancoFundo[playerid], 1);
    
    AppBancoTexto[playerid] = CreatePlayerTextDraw(playerid, 501.0, 98.0, "N");
    PlayerTextDrawFont(playerid, AppBancoTexto[playerid], 2);
    PlayerTextDrawLetterSize(playerid, AppBancoTexto[playerid], 0.2, 1.2);
    PlayerTextDrawColor(playerid, AppBancoTexto[playerid], -1);
    PlayerTextDrawSetSelectable(playerid, AppBancoTexto[playerid], 1);

    // WhatsApp (W)
    AppWhatsFundo[playerid] = CreatePlayerTextDraw(playerid, 517.0, 95.0, "_");
    PlayerTextDrawUseBox(playerid, AppWhatsFundo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, AppWhatsFundo[playerid], 0x25D366FF);
    PlayerTextDrawTextSize(playerid, AppWhatsFundo[playerid], 539.0, 117.0);
    PlayerTextDrawLetterSize(playerid, AppWhatsFundo[playerid], 0.0, 1.8);
    PlayerTextDrawSetSelectable(playerid, AppWhatsFundo[playerid], 1);

    AppWhatsTexto[playerid] = CreatePlayerTextDraw(playerid, 526.0, 98.0, "W");
    PlayerTextDrawFont(playerid, AppWhatsTexto[playerid], 2);
    PlayerTextDrawLetterSize(playerid, AppWhatsTexto[playerid], 0.2, 1.2);
    PlayerTextDrawColor(playerid, AppWhatsTexto[playerid], -1);
    PlayerTextDrawSetSelectable(playerid, AppWhatsTexto[playerid], 1);

    // Calculadora (C)
    AppCalcFundo[playerid] = CreatePlayerTextDraw(playerid, 544.0, 95.0, "_");
    PlayerTextDrawUseBox(playerid, AppCalcFundo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, AppCalcFundo[playerid], 0x007ACCFF);
    PlayerTextDrawTextSize(playerid, AppCalcFundo[playerid], 566.0, 117.0);
    PlayerTextDrawLetterSize(playerid, AppCalcFundo[playerid], 0.0, 1.8);
    PlayerTextDrawSetSelectable(playerid, AppCalcFundo[playerid], 1);

    AppCalcTexto[playerid] = CreatePlayerTextDraw(playerid, 552.0, 98.0, "C");
    PlayerTextDrawFont(playerid, AppCalcTexto[playerid], 2);
    PlayerTextDrawLetterSize(playerid, AppCalcTexto[playerid], 0.2, 1.2);
    PlayerTextDrawColor(playerid, AppCalcTexto[playerid], -1);
    PlayerTextDrawSetSelectable(playerid, AppCalcTexto[playerid], 1);

    // Configurações (Settings)
    AppConfigFundo[playerid] = CreatePlayerTextDraw(playerid, 490.0, 125.0, "_");
    PlayerTextDrawUseBox(playerid, AppConfigFundo[playerid], 1);
    PlayerTextDrawBoxColor(playerid, AppConfigFundo[playerid], 0x555555FF);
    PlayerTextDrawTextSize(playerid, AppConfigFundo[playerid], 512.0, 147.0);
    PlayerTextDrawLetterSize(playerid, AppConfigFundo[playerid], 0.0, 1.8);
    PlayerTextDrawSetSelectable(playerid, AppConfigFundo[playerid], 1);

    AppConfigTexto[playerid] = CreatePlayerTextDraw(playerid, 499.0, 128.0, "S");
    PlayerTextDrawFont(playerid, AppConfigTexto[playerid], 2);
    PlayerTextDrawLetterSize(playerid, AppConfigTexto[playerid], 0.2, 1.2);
    PlayerTextDrawColor(playerid, AppConfigTexto[playerid], -1);
    PlayerTextDrawSetSelectable(playerid, AppConfigTexto[playerid], 1);

    // 5. TELAS INTERNAS DOS APLICATIVOS
    // --- BANCO ---
    BancoFundoTela[playerid] = CreatePlayerTextDraw(playerid, 478.0, 82.0, "_");
    PlayerTextDrawUseBox(playerid, BancoFundoTela[playerid], 1);
    PlayerTextDrawBoxColor(playerid, BancoFundoTela[playerid], 0x14141AFF);
    PlayerTextDrawTextSize(playerid, BancoFundoTela[playerid], 582.0, 422.0);
    PlayerTextDrawLetterSize(playerid, BancoFundoTela[playerid], 0.0, 34.0);

    BancoTextoSaldo[playerid] = CreatePlayerTextDraw(playerid, 485.0, 95.0, "Banco Central~n~Saldo: R$ 5.000,00");
    PlayerTextDrawFont(playerid, BancoTextoSaldo[playerid], 1);
    PlayerTextDrawLetterSize(playerid, BancoTextoSaldo[playerid], 0.18, 0.9);
    PlayerTextDrawColor(playerid, BancoTextoSaldo[playerid], -1);
    PlayerTextDrawSetProportional(playerid, BancoTextoSaldo[playerid], 1);

    BancoBotaoEmprestimo[playerid] = CreatePlayerTextDraw(playerid, 485.0, 145.0, "[ SOLICITAR EMPRESTIMO ]");
    PlayerTextDrawFont(playerid, BancoBotaoEmprestimo[playerid], 1);
    PlayerTextDrawLetterSize(playerid, BancoBotaoEmprestimo[playerid], 0.16, 0.8);
    PlayerTextDrawColor(playerid, BancoBotaoEmprestimo[playerid], 0x00FF00FF);
    PlayerTextDrawSetSelectable(playerid, BancoBotaoEmprestimo[playerid], 1);

    // --- CALCULADORA ---
    CalcFundoTela[playerid] = CreatePlayerTextDraw(playerid, 478.0, 82.0, "_");
    PlayerTextDrawUseBox(playerid, CalcFundoTela[playerid], 1);
    PlayerTextDrawBoxColor(playerid, CalcFundoTela[playerid], 0x1E1E1EFF);
    PlayerTextDrawTextSize(playerid, CalcFundoTela[playerid], 582.0, 422.0);
    PlayerTextDrawLetterSize(playerid, CalcFundoTela[playerid], 0.0, 34.0);

    CalcDisplay[playerid] = CreatePlayerTextDraw(playerid, 575.0, 95.0, "100 + 200 = 300");
    PlayerTextDrawFont(playerid, CalcDisplay[playerid], 1);
    PlayerTextDrawLetterSize(playerid, CalcDisplay[playerid], 0.22, 1.0);
    PlayerTextDrawColor(playerid, CalcDisplay[playerid], -1);
    PlayerTextDrawAlignment(playerid, CalcDisplay[playerid], 3);
    PlayerTextDrawSetProportional(playerid, CalcDisplay[playerid], 1);

    // --- WHATSAPP ---
    WhatsFundoTela[playerid] = CreatePlayerTextDraw(playerid, 478.0, 82.0, "_");
    PlayerTextDrawUseBox(playerid, WhatsFundoTela[playerid], 1);
    PlayerTextDrawBoxColor(playerid, WhatsFundoTela[playerid], 0x075E54FF);
    PlayerTextDrawTextSize(playerid, WhatsFundoTela[playerid], 582.0, 422.0);
    PlayerTextDrawLetterSize(playerid, WhatsFundoTela[playerid], 0.0, 34.0);

    WhatsTextoHeader[playerid] = CreatePlayerTextDraw(playerid, 485.0, 90.0, "WhatsApp - Conversas");
    PlayerTextDrawFont(playerid, WhatsTextoHeader[playerid], 1);
    PlayerTextDrawLetterSize(playerid, WhatsTextoHeader[playerid], 0.2, 0.9);
    PlayerTextDrawColor(playerid, WhatsTextoHeader[playerid], -1);
    PlayerTextDrawSetProportional(playerid, WhatsTextoHeader[playerid], 1);

    WhatsConversa1[playerid] = CreatePlayerTextDraw(playerid, 485.0, 120.0, "> Contato: Delegacia de Policia~n> Ultima msg: Preciso de ajuda!");
    PlayerTextDrawFont(playerid, WhatsConversa1[playerid], 1);
    PlayerTextDrawLetterSize(playerid, WhatsConversa1[playerid], 0.16, 0.8);
    PlayerTextDrawColor(playerid, WhatsConversa1[playerid], 0xCCCCCCFF);
    PlayerTextDrawSetSelectable(playerid, WhatsConversa1[playerid], 1);

    // --- CONFIGURAÇÕES ---
    ConfigFundoTela[playerid] = CreatePlayerTextDraw(playerid, 478.0, 82.0, "_");
    PlayerTextDrawUseBox(playerid, ConfigFundoTela[playerid], 1);
    PlayerTextDrawBoxColor(playerid, ConfigFundoTela[playerid], 0x222222FF);
    PlayerTextDrawTextSize(playerid, ConfigFundoTela[playerid], 582.0, 422.0);
    PlayerTextDrawLetterSize(playerid, ConfigFundoTela[playerid], 0.0, 34.0);

    ConfigTextoInfo[playerid] = CreatePlayerTextDraw(playerid, 485.0, 95.0, "Configuracoes do Aparelho~n~Rede: Conectado (CIDADE GRANDE)~n~Bateria: 100%");
    PlayerTextDrawFont(playerid, ConfigTextoInfo[playerid], 1);
    PlayerTextDrawLetterSize(playerid, ConfigTextoInfo[playerid], 0.17, 0.85);
    PlayerTextDrawColor(playerid, ConfigTextoInfo[playerid], -1);
    PlayerTextDrawSetProportional(playerid, ConfigTextoInfo[playerid], 1);

    // 6. Barra Inferior (Home Bar - Posicionada estritamente dentro da carcaça do celular)
    CelularHomeBar[playerid] = CreatePlayerTextDraw(playerid, 510.0, 425.0, "_");
    PlayerTextDrawUseBox(playerid, CelularHomeBar[playerid], 1);
    PlayerTextDrawBoxColor(playerid, CelularHomeBar[playerid], 0xFFFFFFFF);
    PlayerTextDrawTextSize(playerid, CelularHomeBar[playerid], 550.0, 427.0);
    PlayerTextDrawLetterSize(playerid, CelularHomeBar[playerid], 0.0, 0.12);
    PlayerTextDrawSetSelectable(playerid, CelularHomeBar[playerid], 1);
}

// ==========================================
// DESTRUIDOR DE TEXTDRAWS
// ==========================================
stock Celular_DestruirTextDraws(playerid) {
    PlayerTextDrawDestroy(playerid, CelularBorda[playerid]);
    PlayerTextDrawDestroy(playerid, CelularFundo[playerid]);
    PlayerTextDrawDestroy(playerid, CelularBarraTopo[playerid]);
    PlayerTextDrawDestroy(playerid, CelularTextoTopo[playerid]);
    PlayerTextDrawDestroy(playerid, CelularTitulo[playerid]);
    PlayerTextDrawDestroy(playerid, CelularHomeBar[playerid]);

    PlayerTextDrawDestroy(playerid, AppBancoFundo[playerid]);
    PlayerTextDrawDestroy(playerid, AppBancoTexto[playerid]);
    PlayerTextDrawDestroy(playerid, AppWhatsFundo[playerid]);
    PlayerTextDrawDestroy(playerid, AppWhatsTexto[playerid]);
    PlayerTextDrawDestroy(playerid, AppCalcFundo[playerid]);
    PlayerTextDrawDestroy(playerid, AppCalcTexto[playerid]);
    PlayerTextDrawDestroy(playerid, AppConfigFundo[playerid]);
    PlayerTextDrawDestroy(playerid, AppConfigTexto[playerid]);

    PlayerTextDrawDestroy(playerid, BancoFundoTela[playerid]);
    PlayerTextDrawDestroy(playerid, BancoTextoSaldo[playerid]);
    PlayerTextDrawDestroy(playerid, BancoBotaoEmprestimo[playerid]);

    PlayerTextDrawDestroy(playerid, CalcFundoTela[playerid]);
    PlayerTextDrawDestroy(playerid, CalcDisplay[playerid]);

    PlayerTextDrawDestroy(playerid, WhatsFundoTela[playerid]);
    PlayerTextDrawDestroy(playerid, WhatsTextoHeader[playerid]);
    PlayerTextDrawDestroy(playerid, WhatsConversa1[playerid]);

    PlayerTextDrawDestroy(playerid, ConfigFundoTela[playerid]);
    PlayerTextDrawDestroy(playerid, ConfigTextoInfo[playerid]);
}

// ==========================================
// CONTROLE DE ABERTURA E TELAS
// ==========================================
stock Celular_Abrir(playerid) {
    if (CelularAberto[playerid]) return 0;

    PlayerTextDrawShow(playerid, CelularBorda[playerid]);
    PlayerTextDrawShow(playerid, CelularFundo[playerid]);
    PlayerTextDrawShow(playerid, CelularBarraTopo[playerid]);
    PlayerTextDrawShow(playerid, CelularTextoTopo[playerid]);
    PlayerTextDrawShow(playerid, CelularHomeBar[playerid]);

    Celular_MostrarHome(playerid);

    CelularAberto[playerid] = true;
    SelectTextDraw(playerid, 0x00FF00FF);
    return 1;
}

stock Celular_Fechar(playerid) {
    if (!CelularAberto[playerid]) return 0;

    PlayerTextDrawHide(playerid, CelularBorda[playerid]);
    PlayerTextDrawHide(playerid, CelularFundo[playerid]);
    PlayerTextDrawHide(playerid, CelularBarraTopo[playerid]);
    PlayerTextDrawHide(playerid, CelularTextoTopo[playerid]);
    PlayerTextDrawHide(playerid, CelularHomeBar[playerid]);

    Celular_OcultarTudoInterno(playerid);

    CelularAberto[playerid] = false;
    CancelSelectTextDraw(playerid);
    return 1;
}

stock Celular_MostrarHome(playerid) {
    CelularTelaAtual[playerid] = TELA_INICIAL;
    Celular_OcultarTudoInterno(playerid);

    PlayerTextDrawShow(playerid, CelularTitulo[playerid]);
    PlayerTextDrawShow(playerid, AppBancoFundo[playerid]);
    PlayerTextDrawShow(playerid, AppBancoTexto[playerid]);
    PlayerTextDrawShow(playerid, AppWhatsFundo[playerid]);
    PlayerTextDrawShow(playerid, AppWhatsTexto[playerid]);
    PlayerTextDrawShow(playerid, AppCalcFundo[playerid]);
    PlayerTextDrawShow(playerid, AppCalcTexto[playerid]);
    PlayerTextDrawShow(playerid, AppConfigFundo[playerid]);
    PlayerTextDrawShow(playerid, AppConfigTexto[playerid]);
}

stock Celular_OcultarTudoInterno(playerid) {
    PlayerTextDrawHide(playerid, CelularTitulo[playerid]);
    PlayerTextDrawHide(playerid, AppBancoFundo[playerid]);
    PlayerTextDrawHide(playerid, AppBancoTexto[playerid]);
    PlayerTextDrawHide(playerid, AppWhatsFundo[playerid]);
    PlayerTextDrawHide(playerid, AppWhatsTexto[playerid]);
    PlayerTextDrawHide(playerid, AppCalcFundo[playerid]);
    PlayerTextDrawHide(playerid, AppCalcTexto[playerid]);
    PlayerTextDrawHide(playerid, AppConfigFundo[playerid]);
    PlayerTextDrawHide(playerid, AppConfigTexto[playerid]);

    PlayerTextDrawHide(playerid, BancoFundoTela[playerid]);
    PlayerTextDrawHide(playerid, BancoTextoSaldo[playerid]);
    PlayerTextDrawHide(playerid, BancoBotaoEmprestimo[playerid]);

    PlayerTextDrawHide(playerid, CalcFundoTela[playerid]);
    PlayerTextDrawHide(playerid, CalcDisplay[playerid]);

    PlayerTextDrawHide(playerid, WhatsFundoTela[playerid]);
    PlayerTextDrawHide(playerid, WhatsTextoHeader[playerid]);
    PlayerTextDrawHide(playerid, WhatsConversa1[playerid]);

    PlayerTextDrawHide(playerid, ConfigFundoTela[playerid]);
    PlayerTextDrawHide(playerid, ConfigTextoInfo[playerid]);
}

// Abertura de APPs individuais
stock Celular_AbrirBanco(playerid) {
    CelularTelaAtual[playerid] = TELA_BANCO;
    Celular_OcultarTudoInterno(playerid);
    PlayerTextDrawShow(playerid, BancoFundoTela[playerid]);
    PlayerTextDrawShow(playerid, BancoTextoSaldo[playerid]);
    PlayerTextDrawShow(playerid, BancoBotaoEmprestimo[playerid]);
}

stock Celular_AbrirCalc(playerid) {
    CelularTelaAtual[playerid] = TELA_CALC;
    Celular_OcultarTudoInterno(playerid);
    PlayerTextDrawShow(playerid, CalcFundoTela[playerid]);
    PlayerTextDrawShow(playerid, CalcDisplay[playerid]);
}

stock Celular_AbrirWhats(playerid) {
    CelularTelaAtual[playerid] = TELA_WHATS;
    Celular_OcultarTudoInterno(playerid);
    PlayerTextDrawShow(playerid, WhatsFundoTela[playerid]);
    PlayerTextDrawShow(playerid, WhatsTextoHeader[playerid]);
    PlayerTextDrawShow(playerid, WhatsConversa1[playerid]);
}

stock Celular_AbrirConfig(playerid) {
    CelularTelaAtual[playerid] = TELA_CONFIG;
    Celular_OcultarTudoInterno(playerid);
    PlayerTextDrawShow(playerid, ConfigFundoTela[playerid]);
    PlayerTextDrawShow(playerid, ConfigTextoInfo[playerid]);
}

// ==========================================
// PROCESSAMENTO DE CLIQUES (EXCLUSIVO)
// ==========================================
stock Celular_ProcessarClique(playerid, PlayerText:textdraw) {
    if (!CelularAberto[playerid]) return 0;

    // Se clicar na barra de navegação inferior (Home Bar)
    if (textdraw == CelularHomeBar[playerid]) {
        if (CelularTelaAtual[playerid] == TELA_INICIAL) {
            Celular_Fechar(playerid);
        } else {
            Celular_MostrarHome(playerid); // Volta pro menu principal dos apps
        }
        return 1;
    }

    // Se estiver na Tela Inicial (Home)
    if (CelularTelaAtual[playerid] == TELA_INICIAL) {
        if (textdraw == AppBancoFundo[playerid] || textdraw == AppBancoTexto[playerid]) {
            Celular_AbrirBanco(playerid);
            return 1;
        }
        else if (textdraw == AppWhatsFundo[playerid] || textdraw == AppWhatsTexto[playerid]) {
            Celular_AbrirWhats(playerid);
            return 1;
        }
        else if (textdraw == AppCalcFundo[playerid] || textdraw == AppCalcTexto[playerid]) {
            Celular_AbrirCalc(playerid);
            return 1;
        }
        else if (textdraw == AppConfigFundo[playerid] || textdraw == AppConfigTexto[playerid]) {
            Celular_AbrirConfig(playerid);
            return 1;
        }
    }
    // Se estiver dentro do Banco
    else if (CelularTelaAtual[playerid] == TELA_BANCO) {
        if (textdraw == BancoBotaoEmprestimo[playerid]) {
            SendClientMessage(playerid, 0x00FF00FF, "[BANCO]: Emprestimo aprovado com sucesso! Dinheiro depositado.");
            return 1;
        }
    }
    // Se estiver no WhatsApp
    else if (CelularTelaAtual[playerid] == TELA_WHATS) {
        if (textdraw == WhatsConversa1[playerid]) {
            SendClientMessage(playerid, 0x25D366FF, "[WHATSAPP]: Voce abriu a conversa com a Policia.");
            return 1;
        }
    }

    return 0;
}
