#if defined _rotas_gangsters_included
    #endinput
#endif
#define _rotas_gangsters_included

#include <a_samp>
#include <a_sampdb>
#include <streamer>

// --- Configurações Avançadas ---
#define MAX_PONTOS_DINAMICOS  10000 // Maximo de pontos por cidade
#define TEMPO_COLETA_MS       6000 
#define RAIO_CHECKPOINT       4.0

enum {
    CIDADE_LS = 0,
    CIDADE_SF,
    CIDADE_LV
}

enum E_PONTOS_DINAMICOS {
    bool:ptExiste,
    Float:ptX,
    Float:ptY,
    Float:ptZ
}

enum E_PLAYER_ROTA_ADV {
    bool:pEmRota,
    pCidadeAtual,
    pCheckPointAtual,
    pMateriaisColetados,
    pObjetoMarcador,
    Text3D:pText3D,
    pTimerDistancia,
    pTimerProgresso,
    pContadorProgresso
}

// Armazenamento das rotas criadas por cidade
new g_RotasDinamicas[3][MAX_PONTOS_DINAMICOS][E_PONTOS_DINAMICOS];
new g_TotalPontosCidade[3] = {0, 0, 0};

// Variaveis Globais de Controle do Jogador
new g_PlayerRota[MAX_PLAYERS][E_PLAYER_ROTA_ADV];
static DB:g_DB_Rotas;

// --- Coloque estas definições no topo do arquivo (substituindo as antigas) ---
new Text:TD_ProgressoFundo[MAX_PLAYERS];
new Text:TD_ProgressoBarra[MAX_PLAYERS];
new Text:TD_ProgressoTexto[MAX_PLAYERS]; // Apenas uma TextDraw de texto agora

// --- Verificaçao das Organizações ---
stock IsPlayerGangster(orgid) {
    switch(orgid) {
        case 24, 25, 26, 27, 29, 31: return 1; 
    }
    return 0;
}

// --- Detecçao Automatica de Cidade ---
stock GetPlayerCurrentCity(playerid) {
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(x > -920.0 && y < -1000.0) return CIDADE_LS;
    if(x < -920.0 && y < 1000.0)  return CIDADE_SF;
    return CIDADE_LV;
}

stock GetNomeCidade(cidadeid) {
    new cName[16];
    switch(cidadeid) {
        case CIDADE_LS: cName = "Los Santos";
        case CIDADE_SF: cName = "San Fierro";
        case CIDADE_LV: cName = "Las Venturas";
    }
    return cName;
}

// --- BANCO DE DADOS SCRIPT (Criaçao e Carregamento Permanente) ---
stock InitRotaGangstersDB() {
    g_DB_Rotas = db_open("rotas_gangsters_v3.db");
    
    // Tabela 1: Salva o progresso dos jogadores ativos
    db_query(g_DB_Rotas, "CREATE TABLE IF NOT EXISTS progresso (Nome TEXT UNIQUE, Cidade INTEGER, Ponto INTEGER, Materiais INTEGER)");
    
    // Tabela 2: Salva as coordenadas criadas pelo /criarrota permanentemente
    db_query(g_DB_Rotas, "CREATE TABLE IF NOT EXISTS coordenadas_rotas (Cidade INTEGER, Slot INTEGER, X REAL, Y REAL, Z REAL, PRIMARY KEY (Cidade, Slot))");
    
    // Carrega as coordenadas salvas do banco de dados para a memória ao ligar o servidor
    CarregarTodasCoordenadasBanco();
    return 1;
}

stock ExitRotaGangstersDB() {
    db_close(g_DB_Rotas);
    return 1;
}

// Salva a nova coordenada no banco SQLite assim que usa o comando
stock SalvarCoordenadaNoBanco(cidade, slot, Float:x, Float:y, Float:z) {
    new query[200];
    format(query, sizeof(query), "INSERT OR REPLACE INTO coordenadas_rotas (Cidade, Slot, X, Y, Z) VALUES (%d, %d, %f, %f, %f)", 
        cidade, slot, x, y, z);
    db_query(g_DB_Rotas, query);
}

// Busca do banco todas as coordenadas ao iniciar o servidor
static stock CarregarTodasCoordenadasBanco() {
    new DBResult:res = db_query(g_DB_Rotas, "SELECT Cidade, Slot, X, Y, Z FROM coordenadas_rotas");
    new rows = db_num_rows(res);
    
    for(new i = 0; i < rows; i++) {
        new cid = db_get_field_assoc_int(res, "Cidade");
        new slot = db_get_field_assoc_int(res, "Slot");
        
        g_RotasDinamicas[cid][slot][ptX] = db_get_field_assoc_float(res, "X");
        g_RotasDinamicas[cid][slot][ptY] = db_get_field_assoc_float(res, "Y");
        g_RotasDinamicas[cid][slot][ptZ] = db_get_field_assoc_float(res, "Z");
        g_RotasDinamicas[cid][slot][ptExiste] = true;
        
        // Atualiza o contador da cidade para saber quantos pontos ela tem guardada
        if(slot >= g_TotalPontosCidade[cid]) {
            g_TotalPontosCidade[cid] = slot + 1;
        }
        db_next_row(res);
    }
    db_free_result(res);
    printf("[ROTA METAL] Carregadas %d coordenadas salvas do Banco de Dados.", rows);
}

stock SalvarDadosRotaGangster(playerid) {
    if(!g_PlayerRota[playerid][pEmRota]) return 0;

    new name[MAX_PLAYER_NAME], query[200];
    GetPlayerName(playerid, name, sizeof(name));

    format(query, sizeof(query), "INSERT OR REPLACE INTO progresso (Nome, Cidade, Ponto, Materiais) VALUES ('%s', %d, %d, %d)", 
        name, g_PlayerRota[playerid][pCidadeAtual], g_PlayerRota[playerid][pCheckPointAtual], g_PlayerRota[playerid][pMateriaisColetados]);
    
    db_query(g_DB_Rotas, query);
    return 1;
}

stock CarregarDadosRotaGangster(playerid, orgid) {
    if(!IsPlayerGangster(orgid)) return 0;

    new name[MAX_PLAYER_NAME], query[150], DBResult:res;
    GetPlayerName(playerid, name, sizeof(name));

    format(query, sizeof(query), "SELECT Cidade, Ponto, Materiais FROM progresso WHERE Nome = '%s'", name);
    res = db_query(g_DB_Rotas, query);

    if(db_num_rows(res) > 0) {
        new cid = db_get_field_assoc_int(res, "Cidade");
        
        if(g_TotalPontosCidade[cid] == 0) {
            db_free_result(res);
            return 0; 
        }

        g_PlayerRota[playerid][pEmRota] = true;
        g_PlayerRota[playerid][pCidadeAtual] = cid;
        g_PlayerRota[playerid][pCheckPointAtual] = db_get_field_assoc_int(res, "Ponto");
        g_PlayerRota[playerid][pMateriaisColetados] = db_get_field_assoc_int(res, "Materiais");
        
        CriarTextDrawsProgresso(playerid);
        CriarElementosPonto(playerid);
        
        SendClientMessage(playerid, 0x33AA33AA, "______________________________________________________");
        SendClientMessage(playerid, 0xFFFF00AA, "[ROTA] Voce deslogou em rota! Progresso recuperado nesta cidade.");
        SendClientMessage(playerid, 0x33AA33AA, "______________________________________________________");
    }
    db_free_result(res);
    return 1;
}

stock ResetarDadosJogadorRota(playerid, deletarBanco = 0) {
    if(IsValidDynamicPickup(g_PlayerRota[playerid][pObjetoMarcador])) DestroyDynamicPickup(g_PlayerRota[playerid][pObjetoMarcador]);
    if(IsValidDynamic3DTextLabel(g_PlayerRota[playerid][pText3D])) DestroyDynamic3DTextLabel(g_PlayerRota[playerid][pText3D]);
    
    if(g_PlayerRota[playerid][pTimerDistancia] != 0) {
        KillTimer(g_PlayerRota[playerid][pTimerDistancia]);
        g_PlayerRota[playerid][pTimerDistancia] = 0;
    }
    
    if(g_PlayerRota[playerid][pTimerProgresso] != 0) {
        KillTimer(g_PlayerRota[playerid][pTimerProgresso]);
        g_PlayerRota[playerid][pTimerProgresso] = 0;
    }

    OcultarBarraProgresso(playerid);

    if(deletarBanco) {
        new name[MAX_PLAYER_NAME], query[100];
        GetPlayerName(playerid, name, sizeof(name));
        format(query, sizeof(query), "DELETE FROM progresso WHERE Nome = '%s'", name);
        db_query(g_DB_Rotas, query);
    }

    g_PlayerRota[playerid][pEmRota] = false;
    g_PlayerRota[playerid][pCidadeAtual] = 0;
    g_PlayerRota[playerid][pCheckPointAtual] = 0;
    g_PlayerRota[playerid][pMateriaisColetados] = 0;
    g_PlayerRota[playerid][pObjetoMarcador] = -1;
    DisablePlayerCheckpoint(playerid);
}

// --- Atualizador Dinamico de Texto ---
forward OnUpdateTextDistancia(playerid);
public OnUpdateTextDistancia(playerid) {
    if(!g_PlayerRota[playerid][pEmRota]) return 0;

    new cid = g_PlayerRota[playerid][pCidadeAtual];
    new idx = g_PlayerRota[playerid][pCheckPointAtual];
    
    if(idx >= g_TotalPontosCidade[cid]) return 0;

    new Float:distancia = GetPlayerDistanceFromPoint(playerid, g_RotasDinamicas[cid][idx][ptX], g_RotasDinamicas[cid][idx][ptY], g_RotasDinamicas[cid][idx][ptZ]);

    new string[200];
    format(string, sizeof(string), "{FF9900}[ROTA METAL %d]\n{FFFFFF}Cidade: %s\n{00FF00}Aperte 'F' / 'ENTER' a pe\n{FFFFFF}Distancia: {FFFF00}%.1fm", 
        (idx + 1), GetNomeCidade(cid), distancia);

    UpdateDynamic3DTextLabelText(g_PlayerRota[playerid][pText3D], 0xFFFFFFFF, string);
    return 1;
}

stock CriarElementosPonto(playerid) {
    new cid = g_PlayerRota[playerid][pCidadeAtual];
    new idx = g_PlayerRota[playerid][pCheckPointAtual];
    
    if(idx >= g_TotalPontosCidade[cid]) return 0;

    if(IsValidDynamicPickup(g_PlayerRota[playerid][pObjetoMarcador])) DestroyDynamicPickup(g_PlayerRota[playerid][pObjetoMarcador]);
    if(IsValidDynamic3DTextLabel(g_PlayerRota[playerid][pText3D])) DestroyDynamic3DTextLabel(g_PlayerRota[playerid][pText3D]);

    new Float:x = g_RotasDinamicas[cid][idx][ptX];
    new Float:y = g_RotasDinamicas[cid][idx][ptY];
    new Float:z = g_RotasDinamicas[cid][idx][ptZ];

    g_PlayerRota[playerid][pObjetoMarcador] = CreateDynamicPickup(1210, 1, x, y, z, -1, -1, playerid);
    g_PlayerRota[playerid][pText3D] = CreateDynamic3DTextLabel("Carregando...", 0xFFFFFFFF, x, y, z + 0.5, 50.0, .playerid = playerid);
    
    SetPlayerCheckpoint(playerid, x, y, z, RAIO_CHECKPOINT);
    
    if(g_PlayerRota[playerid][pTimerDistancia] != 0) KillTimer(g_PlayerRota[playerid][pTimerDistancia]);
    g_PlayerRota[playerid][pTimerDistancia] = SetTimerEx("OnUpdateTextDistancia", 400, true, "d", playerid); 
    
    OnUpdateTextDistancia(playerid);
    return 1;
}

// --- Teclas ---
stock ProcessarTeclaRotaGangster(playerid, newkeys) {
    if(!g_PlayerRota[playerid][pEmRota]) return 0;
    
    if(newkeys & KEY_SECONDARY_ATTACK) { 
        new cid = g_PlayerRota[playerid][pCidadeAtual];
        new idx = g_PlayerRota[playerid][pCheckPointAtual];
        
        if(IsPlayerInRangeOfPoint(playerid, RAIO_CHECKPOINT, g_RotasDinamicas[cid][idx][ptX], g_RotasDinamicas[cid][idx][ptY], g_RotasDinamicas[cid][idx][ptZ])) {
            
            if(IsPlayerInAnyVehicle(playerid)) {
                SendClientMessage(playerid, 0xFF0000AA, "[ROTA] Saia do veiculo para coletar os metais!");
                return 1;
            }

            ExecutarAcaoColeta(playerid);
            return 1;
        }
    }
    return 0;
}

static stock ExecutarAcaoColeta(playerid) {
    if(g_PlayerRota[playerid][pTimerProgresso] != 0) return; 

    TogglePlayerControllable(playerid, false); 
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 1, 0, 0, 0, TEMPO_COLETA_MS);
    
    g_PlayerRota[playerid][pContadorProgresso] = 0;
    ExibirBarraProgresso(playerid);
    
    g_PlayerRota[playerid][pTimerProgresso] = SetTimerEx("OnUpdateBarraProgresso", 60, true, "d", playerid);
}

// --- Timer Progresso ---
// --- Procura pela public OnUpdateTextDistancia ou o bloco do timer no seu código e atualize a verificaçao de conclusao: ---

forward OnUpdateBarraProgresso(playerid);
public OnUpdateBarraProgresso(playerid) {
    if(!g_PlayerRota[playerid][pEmRota]) {
        OcultarBarraProgresso(playerid);
        return 0;
    }

    g_PlayerRota[playerid][pContadorProgresso]++;
    new pct = g_PlayerRota[playerid][pContadorProgresso];

    if(pct <= 100) {
        new Float:novoTamanho = (Float:pct / 100.0) * 160.0;
        TextDrawTextSize(TD_ProgressoBarra[playerid], novoTamanho, 10.0);
        TextDrawShowForPlayer(playerid, TD_ProgressoBarra[playerid]);

        new str[24];
        format(str, sizeof(str), "COLETANDO: %d%%", pct);
        TextDrawSetString(TD_ProgressoTexto[playerid], str);
        TextDrawShowForPlayer(playerid, TD_ProgressoTexto[playerid]);
    } else {
        KillTimer(g_PlayerRota[playerid][pTimerProgresso]);
        g_PlayerRota[playerid][pTimerProgresso] = 0;
        OcultarBarraProgresso(playerid);
        
        TogglePlayerControllable(playerid, true);
        ClearAnimations(playerid);

        g_PlayerRota[playerid][pMateriaisColetados] += 50; 
        g_PlayerRota[playerid][pCheckPointAtual]++;

        new cid = g_PlayerRota[playerid][pCidadeAtual];

        // [MODO LOOP] Se chegou ao fim dos pontos criados da cidade
        if(g_PlayerRota[playerid][pCheckPointAtual] >= g_TotalPontosCidade[cid]) {
            new msg[128];
            format(msg, sizeof(msg), "{00FF00}[LOOP] Rota de %s Concluida! Reiniciando ciclo automaticamente. Total acumulado: %d metais.", GetNomeCidade(cid), g_PlayerRota[playerid][pMateriaisColetados]);
            SendClientMessage(playerid, -1, msg);
            
            // Reseta o index para o primeiro ponto, mas NaO limpa os materiais coletados
            g_PlayerRota[playerid][pCheckPointAtual] = 0; 
            
            // Recria o ponto inicial no mapa para continuar coletando
            CriarElementosPonto(playerid);
            SalvarDadosRotaGangster(playerid);
        } else {
            SendClientMessage(playerid, 0x00FF00AA, "[ROTA] Metal coletado! Siga para o próximo ponto.");
            CriarElementosPonto(playerid);
            SalvarDadosRotaGangster(playerid); 
        }
    }
    return 1;
}

stock CriarTextDrawsProgresso(playerid) {
    // Fundo da barra (Preto transparente) - Centralizado um pouco abaixo do meio
    TD_ProgressoFundo[playerid] = TextDrawCreate(238.0, 340.0, "ld_spac:white");
    TextDrawFont(TD_ProgressoFundo[playerid], 4);
    TextDrawColor(TD_ProgressoFundo[playerid], 0x000000AA);
    TextDrawTextSize(TD_ProgressoFundo[playerid], 164.0, 14.0);

    // Barra de progresso interna (Laranja)
    TD_ProgressoBarra[playerid] = TextDrawCreate(240.0, 342.0, "ld_spac:white");
    TextDrawFont(TD_ProgressoBarra[playerid], 4);
    TextDrawColor(TD_ProgressoBarra[playerid], 0xFF9900FF); 
    TextDrawTextSize(TD_ProgressoBarra[playerid], 0.0, 10.0); // Começa zerada

    // TEXTO ÚNICO (Branco com contorno padrao do jogo)
    TD_ProgressoTexto[playerid] = TextDrawCreate(320.0, 341.0, "COLETANDO: 0%");
    TextDrawFont(TD_ProgressoTexto[playerid], 1);
    TextDrawLetterSize(TD_ProgressoTexto[playerid], 0.23, 1.1);
    TextDrawColor(TD_ProgressoTexto[playerid], 0xFFFFFFFF); // Cor Branca pura
    TextDrawAlignment(TD_ProgressoTexto[playerid], 2); // Centralizado no próprio eixo
}

stock ExibirBarraProgresso(playerid) {
    TextDrawShowForPlayer(playerid, TD_ProgressoFundo[playerid]);
    TextDrawShowForPlayer(playerid, TD_ProgressoBarra[playerid]);
    TextDrawShowForPlayer(playerid, TD_ProgressoTexto[playerid]);
}

stock OcultarBarraProgresso(playerid) {
    TextDrawHideForPlayer(playerid, TD_ProgressoFundo[playerid]);
    TextDrawHideForPlayer(playerid, TD_ProgressoBarra[playerid]);
    TextDrawHideForPlayer(playerid, TD_ProgressoTexto[playerid]);
}

stock DestruirTextDrawsJogador(playerid) {
    TextDrawDestroy(TD_ProgressoFundo[playerid]);
    TextDrawDestroy(TD_ProgressoBarra[playerid]);
    TextDrawDestroy(TD_ProgressoTexto[playerid]);
}


// --- COMANDOS SALVANDO EM BANCO DE DADOS ---

CMD:criarrota(playerid, params[])
{
    new cid = GetPlayerCurrentCity(playerid); 
    new slot = g_TotalPontosCidade[cid];

    if(slot >= MAX_PONTOS_DINAMICOS) {
        new msg[128];
        format(msg, sizeof(msg), "[ERRO] Limite maximo de rotas atingido para %s!", GetNomeCidade(cid));
        SendClientMessage(playerid, 0xFF0000AA, msg);
        return 1;
    }

    // Pega as coordenadas locais
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    // Grava na memória RAM temporaria
    g_RotasDinamicas[cid][slot][ptX] = x;
    g_RotasDinamicas[cid][slot][ptY] = y;
    g_RotasDinamicas[cid][slot][ptZ] = z;
    g_RotasDinamicas[cid][slot][ptExiste] = true;
    g_TotalPontosCidade[cid]++; 

    // SALVA PERMANENTEMENTE NO BANCO DE DADOS (Substitui ou adiciona)
    SalvarCoordenadaNoBanco(cid, slot, x, y, z);

    new msg[128];
    format(msg, sizeof(msg), "[SUCESSO] ROTA METAL %d salva de forma PERMANENTE em %s!", (slot + 1), GetNomeCidade(cid));
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}

CMD:iniciarrota(playerid, params[])
{
    new org = CallLocalFunction("GetPlayerOrgID", "d", playerid); 
    
    if(!IsPlayerGangster(org)) {
        SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Comando restrito para membros de Faccoes/Gangsters!");
        return 1;
    }
    
    if(g_PlayerRota[playerid][pEmRota]) {
        SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce ja esta executando uma rota atualmente.");
        return 1;
    }

    new cid = GetPlayerCurrentCity(playerid); 

    if(g_TotalPontosCidade[cid] == 0) {
        new msg[128];
        format(msg, sizeof(msg), "[ERRO] Nenhuma Rota Metal foi configurada em %s ainda.", GetNomeCidade(cid));
        SendClientMessage(playerid, 0xFF0000AA, msg);
        return 1;
    }

    g_PlayerRota[playerid][pEmRota] = true;
    g_PlayerRota[playerid][pCidadeAtual] = cid;
    g_PlayerRota[playerid][pCheckPointAtual] = 0;
    g_PlayerRota[playerid][pMateriaisColetados] = 0;

    CriarTextDrawsProgresso(playerid);
    CriarElementosPonto(playerid);
    
    new msg[128];
    format(msg, sizeof(msg), "[ROTA] Voce iniciou as rotas de %s. Va para a ROTA METAL 1 marcada no seu mapa!", GetNomeCidade(cid));
    SendClientMessage(playerid, 0x00FF00AA, msg);
    return 1;
}

CMD:sairrota(playerid, params[])
{
    if(!g_PlayerRota[playerid][pEmRota]) {
        SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce nao esta em nenhuma rota.");
        return 1;
    }

    ResetarDadosJogadorRota(playerid, 1); 
    SendClientMessage(playerid, 0xFF0000AA, "[ROTA] Rota cancelada e progresso zerado.");
    return 1;
}
// --- COMANDO ADICIONADO PARA RETORNAR a ROTA QUE PAROU ---

CMD:voltarrota(playerid, params[])
{
    new org = CallLocalFunction("GetPlayerOrgID", "d", playerid); 
    
    if(!IsPlayerGangster(org)) {
        SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Comando restrito para membros de Facções/Gangsters!");
        return 1;
    }
    
    if(g_PlayerRota[playerid][pEmRota]) {
        SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Voce ja esta em uma rota ativa atualmente.");
        return 1;
    }

    new name[MAX_PLAYER_NAME], query[150], DBResult:res;
    GetPlayerName(playerid, name, sizeof(name));

    // Busca se existe algum progresso salvo desse jogador na tabela do banco SQLite
    format(query, sizeof(query), "SELECT Cidade, Ponto, Materiais FROM progresso WHERE Nome = '%s'", name);
    res = db_query(g_DB_Rotas, query);

    if(db_num_rows(res) > 0) {
        new cid = db_get_field_assoc_int(res, "Cidade");
        
        if(g_TotalPontosCidade[cid] == 0) {
            SendClientMessage(playerid, 0xFF0000AA, "[ERRO] A cidade do seu save nao possui mais rotas configuradas.");
            db_free_result(res);
            return 1; 
        }

        // Carrega as informações guardadas de onde ele parou
        g_PlayerRota[playerid][pEmRota] = true;
        g_PlayerRota[playerid][pCidadeAtual] = cid;
        g_PlayerRota[playerid][pCheckPointAtual] = db_get_field_assoc_int(res, "Ponto");
        g_PlayerRota[playerid][pMateriaisColetados] = db_get_field_assoc_int(res, "Materiais");
        
        // Ativa os elementos de interface e o marcador no mapa
        CriarTextDrawsProgresso(playerid);
        CriarElementosPonto(playerid);
        
        new msg[150];
        format(msg, sizeof(msg), "[ROTA] Progresso recuperado! Voce voltou para a rota de %s no Ponto %d. Metais anteriores: %d", 
            GetNomeCidade(cid), (g_PlayerRota[playerid][pCheckPointAtual] + 1), g_PlayerRota[playerid][pMateriaisColetados]);
        SendClientMessage(playerid, 0x00FF00AA, msg);
    } else {
        SendClientMessage(playerid, 0xFF0000AA, "[ERRO] Nenhum registro de rota anterior foi encontrado para voce no banco de dados.");
    }
    
    db_free_result(res);
    return 1;
}

