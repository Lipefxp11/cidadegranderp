#include <a_samp>
#include <sscanf2>

#define MAX_MORROS 50
#define FILE_ZONAS "guerras_zonas.ini"

#define VERMELHO 0xFF2400FF
#define AMARELO  0xFFFF00FF
#define AZUL     0x0080FFFF
#define BRANCO   0xFFFFFFFF

enum e_MorroGuerra
{
    Float:m_MinX,
    Float:m_MinY,
    Float:m_MaxX,
    Float:m_MaxY,
    m_ZonaID,
    Text3D:m_TextInfoID,
    bool:m_GuerraAtiva,
    m_DonoOrgID,
    m_KillsAtacante,
    m_KillsDefensor,
    m_TextoCustom[128]
};

new MorroGuerra[MAX_MORROS][e_MorroGuerra];
new TotalMorrosCriados = 0;
new TimerGlobalGuerras;

// Variáveis para criação manual via passos
new GuerraPasso[MAX_PLAYERS];
new Float:GuerraPontos[MAX_PLAYERS][4][3];

// Exemplo de enums/variáveis externas do seu GM (ajuste conforme seu servidor)
enum pInfo { bool:Logado, Org };
new Pdados[MAX_PLAYERS][pInfo];

forward ChecarHorasGuerra();
forward FinalizarGuerraTerritorio(morroID);

// ==========================================
// SISTEMA DE CARREGAMENTO E SALVAMENTO
// ==========================================

stock CarregarZonasGuerra()
{
    if(!fexist(FILE_ZONAS)) return 0;
    
    new File:file = fopen(FILE_ZONAS, file_read);
    if(!file) return 0;

    new line[256];
    TotalMorrosCriados = 0;

    while(fread(file, line))
    {
        if(TotalMorrosCriados >= MAX_MORROS) break;
        
        Float:minx, Float:miny, Float:maxx, Float:maxy;
        if(sscanf(line, "ffff", minx, miny, maxx, maxy)) continue;

        MorroGuerra[TotalMorrosCriados][m_MinX] = minx;
        MorroGuerra[TotalMorrosCriados][m_MinY] = miny;
        MorroGuerra[TotalMorrosCriados][m_MaxX] = maxx;
        MorroGuerra[TotalMorrosCriados][m_MaxY] = maxy;
        MorroGuerra[TotalMorrosCriados][m_GuerraAtiva] = false;
        MorroGuerra[TotalMorrosCriados][m_DonoOrgID] = -1;
        MorroGuerra[TotalMorrosCriados][m_KillsAtacante] = 0;
        MorroGuerra[TotalMorrosCriados][m_KillsDefensor] = 0;

        MorroGuerra[TotalMorrosCriados][m_ZonaID] = GangZoneCreate(minx, miny, maxx, maxy);
        GangZoneShowForAll(MorroGuerra[TotalMorrosCriados][m_ZonaID], 0xFFFF0066);

        new Float:cx = (minx + maxx) / 2.0;
        new Float:cy = (miny + maxy) / 2.0;

        format(MorroGuerra[TotalMorrosCriados][m_TextoCustom], 128, "{FFFFFF}Territorio Neutro\n{FFFF00}Disponivel para Conquista");
        MorroGuerra[TotalMorrosCriados][m_TextInfoID] = Create3DTextLabel(MorroGuerra[TotalMorrosCriados][m_TextoCustom], AMARELO, cx, cy, 10.0, 50.0, 0, 0);

        TotalMorrosCriados++;
    }
    fclose(file);
    printf("[SISTEMA GUERRAS] Carregadas %d zonas de guerra com sucesso.", TotalMorrosCriados);
    return 1;
}

stock SalvarZonasGuerra()
{
    new File:file = fopen(FILE_ZONAS, file_write);
    if(!file) return 0;

    new line[128];
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        format(line, sizeof(line), "%f %f %f %f\r\n", 
            MorroGuerra[i][m_MinX], 
            MorroGuerra[i][m_MinY], 
            MorroGuerra[i][m_MaxX], 
            MorroGuerra[i][m_MaxY]
        );
        fwrite(file, line);
    }
    fclose(file);
    return 1;
}

// ==========================================
// FUNÇÕES PRINCIPAIS DO SISTEMA
// ==========================================

Stock IniciarSistemaGuerra()
{
    CarregarZonasGuerra();
    TimerGlobalGuerras = SetTimer("ChecarHorasGuerra", 60000, true);
    print("[SISTEMA GUERRAS] Sistema completo integrado com sucesso!");
    return 1;
}

Stock FecharSistemaGuerra()
{
    KillTimer(TimerGlobalGuerras);
    SalvarZonasGuerra();
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        GangZoneDestroy(MorroGuerra[i][m_ZonaID]);
        Delete3DTextLabel(MorroGuerra[i][m_TextInfoID]);
    }
    return 1;
}

public ChecarHorasGuerra()
{
    new hora, minuto, segundo;
    gettime(hora, minuto, segundo);

    if(minuto == 0)
    {
        if(hora == 12 || hora == 14 || hora == 17 || hora == 19 || hora == 21 || hora == 23 || hora == 0)
        {
            for(new i = 0; i < TotalMorrosCriados; i++)
            {
                DispararGuerraTerritorio(i);
            }
        }
    }
    return 1;
}

stock DispararGuerraTerritorio(morroID)
{
    if(MorroGuerra[morroID][m_GuerraAtiva]) return 0;

    MorroGuerra[morroID][m_GuerraAtiva] = true;
    MorroGuerra[morroID][m_KillsAtacante] = 0;
    MorroGuerra[morroID][m_KillsDefensor] = 0;

    GangZoneFlashForAll(MorroGuerra[morroID][m_ZonaID], VERMELHO);
    SendClientMessageToAll(VERMELHO, "[DOMINACAO] Guerra Iniciada em um territorio! Confronte pelo perimetro!");

    SetTimerEx("FinalizarGuerraTerritorio", 900000, false, "i", morroID);
    return 1;
}

public FinalizarGuerraTerritorio(morroID)
{
    if(!MorroGuerra[morroID][m_GuerraAtiva]) return 0;

    MorroGuerra[morroID][m_GuerraAtiva] = false;
    GangZoneStopFlashForAll(MorroGuerra[morroID][m_ZonaID]);

    SendClientMessageToAll(AMARELO, "[DOMINACAO] A guerra de territorio terminou!");
    
    new str3d[128];
    if(MorroGuerra[morroID][m_KillsAtacante] > MorroGuerra[morroID][m_KillsDefensor])
    {
        SendClientMessageToAll(AZUL, "[DOMINACAO] Os Atacantes conquistaram o territorio!");
        format(str3d, sizeof(str3d), "{FFFFFF}Territorio Dominado\n{FF0000}Atacantes (Kills: %d)", MorroGuerra[morroID][m_KillsAtacante]);
    }
    else
    {
        SendClientMessageToAll(AZUL, "[DOMINACAO] Os Defensores mantiveram o territorio!");
        format(str3d, sizeof(str3d), "{FFFFFF}Territorio Protegido\n{0000FF}Defensores (Kills: %d)", MorroGuerra[morroID][m_KillsDefensor]);
    }
    format(MorroGuerra[morroID][m_TextoCustom], 128, "%s", str3d);
    Update3DTextLabelText(MorroGuerra[morroID][m_TextInfoID], BRANCO, str3d);
    return 1;
}

stock OnPlayerDeathGuerra(killerid, playerid, reason)
{
    #pragma unused reason
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        if(MorroGuerra[i][m_GuerraAtiva])
        {
            new Float:px, Float:py, Float:pz;
            GetPlayerPos(playerid, px, py, pz);

            if(px >= MorroGuerra[i][m_MinX] && px <= MorroGuerra[i][m_MaxX] && py >= MorroGuerra[i][m_MinY] && py <= MorroGuerra[i][m_MaxY])
            {
                MorroGuerra[i][m_KillsAtacante]++;
                
                if(IsPlayerConnected(killerid)) {
                    SendClientMessage(killerid, AMARELO, "[GUERRA] Inimigo abatido na zona de confronto!");
                }
            }
        }
    }
    return 1;
}

// ==========================================
// COMANDOS DE CRIAÇÃO E ADMINISTRAÇÃO
// ==========================================

CMD:criarguerra(playerid, params)
{
    #pragma unused params
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    if(strcmp(nome, "Lipee_fxp1", true) != 0) return SendClientMessage(playerid, VERMELHO, "[ERRO] Acesso negado.");

    GuerraPasso[playerid] = 1;
    GetPlayerPos(playerid, GuerraPontos[playerid][0][0], GuerraPontos[playerid][0][1], GuerraPontos[playerid][0][2]);
    
    SendClientMessage(playerid, -1, "{28FC14}[GUERRA] Ponto 1 salvo na sua posicao atual!");
    SendClientMessage(playerid, -1, "{AFAFAF}Va para a segunda ponta e digite /marcarponto.");
    return 1;
}

CMD:marcarponto(playerid, params)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    if(strcmp(nome, "Lipee_fxp1", true) != 0) return SendClientMessage(playerid, VERMELHO, "[ERRO] Acesso negado.");

    if(GuerraPasso[playerid] == 0)
        return SendClientMessage(playerid, VERMELHO, "[ERRO] Digite /criarguerra primeiro para iniciar o processo!");

    if(GuerraPasso[playerid] == 1)
    {
        GetPlayerPos(playerid, GuerraPontos[playerid][1][0], GuerraPontos[playerid][1][1], GuerraPontos[playerid][1][2]);
        GuerraPasso[playerid] = 2;
        SendClientMessage(playerid, -1, "{28FC14}[GUERRA] Ponto 2 salvo! Va para o terceiro ponto e digite /marcarponto.");
    }
    else if(GuerraPasso[playerid] == 2)
    {
        GetPlayerPos(playerid, GuerraPontos[playerid][2][0], GuerraPontos[playerid][2][1], GuerraPontos[playerid][2][2]);
        GuerraPasso[playerid] = 3;
        SendClientMessage(playerid, -1, "{28FC14}[GUERRA] Ponto 3 salvo! Va para o quarto e ultimo ponto e digite /marcarponto.");
    }
    else if(GuerraPasso[playerid] == 3)
    {
        GetPlayerPos(playerid, GuerraPontos[playerid][3][0], GuerraPontos[playerid][3][1], GuerraPontos[playerid][3][2]);
        
        new Float:minX = GuerraPontos[playerid][0][0];
        new Float:maxX = GuerraPontos[playerid][0][0];
        new Float:minY = GuerraPontos[playerid][0][1];
        new Float:maxY = GuerraPontos[playerid][0][1];

        for(new i = 1; i < 4; i++)
        {
            if(GuerraPontos[playerid][i][0] < minX) minX = GuerraPontos[playerid][i][0];
            if(GuerraPontos[playerid][i][0] > maxX) maxX = GuerraPontos[playerid][i][0];
            if(GuerraPontos[playerid][i][1] < minY) minY = GuerraPontos[playerid][i][1];
            if(GuerraPontos[playerid][i][1] > maxY) maxY = GuerraPontos[playerid][i][1];
        }

        if(TotalMorrosCriados >= MAX_MORROS)
            return SendClientMessage(playerid, VERMELHO, "[ERRO] Limite maximo de zonas atingido!");

        new id = TotalMorrosCriados;
        MorroGuerra[id][m_MinX] = minX;
        MorroGuerra[id][m_MinY] = minY;
        MorroGuerra[id][m_MaxX] = maxX;
        MorroGuerra[id][m_MaxY] = maxY;
        MorroGuerra[id][m_GuerraAtiva] = false;
        MorroGuerra[id][m_DonoOrgID] = -1;

        MorroGuerra[id][m_ZonaID] = GangZoneCreate(minX, minY, maxX, maxY);
        GangZoneShowForAll(MorroGuerra[id][m_ZonaID], 0xFFFF0066);

        new Float:cx = (minX + maxX) / 2.0;
        new Float:cy = (minY + maxY) / 2.0;
        
        format(MorroGuerra[id][m_TextoCustom], 128, "{FFFFFF}Territorio Neutro\n{FFFF00}Disponivel para Conquista");
        MorroGuerra[id][m_TextInfoID] = Create3DTextLabel(MorroGuerra[id][m_TextoCustom], AMARELO, cx, cy, 10.0, 50.0, 0, 0);

        TotalMorrosCriados++;
        SalvarZonasGuerra(); // Salva automaticamente ao criar
        
        SendClientMessage(playerid, -1, "{28FC14}[GUERRA] Zona criada, ativada e salva com sucesso!");
        GuerraPasso[playerid] = 0; 
    }
    return 1;
}

CMD:apagargz(playerid, params)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));
    if(strcmp(nome, "Lipee_fxp1", true) != 0) return SendClientMessage(playerid, VERMELHO, "[ERRO] Acesso negado.");

    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        if(x >= MorroGuerra[i][m_MinX] && x <= MorroGuerra[i][m_MaxX] && y >= MorroGuerra[i][m_MinY] && y <= MorroGuerra[i][m_MaxY])
        {
            GangZoneDestroy(MorroGuerra[i][m_ZonaID]);
            Delete3DTextLabel(MorroGuerra[i][m_TextInfoID]);
            
            // Remove deslocando os elementos do array
            for(new j = i; j < TotalMorrosCriados - 1; j++)
            {
                MorroGuerra[j] = MorroGuerra[j + 1];
            }
            TotalMorrosCriados--;
            SalvarZonasGuerra();
            
            SendClientMessage(playerid, -1, "{FF2400}[GUERRA] Voce apagou e removeu permanentemente a GangZone em que estava!");
            return 1;
        }
    }

    SendClientMessage(playerid, VERMELHO, "[ERRO] Voce nao esta dentro de nenhuma GangZone!");
    return 1;
}

CMD:forcarinicio(playerid, params)
{
    #pragma unused params
    new nome[MAX_PLAYER_NAME]; GetPlayerName(playerid, nome, sizeof(nome));
    if(strcmp(nome, "Lipee_fxp1", true) != 0) return SendClientMessage(playerid, VERMELHO, "[ERRO] Acesso negado.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        if(x >= MorroGuerra[i][m_MinX] && x <= MorroGuerra[i][m_MaxX] && y >= MorroGuerra[i][m_MinY] && y <= MorroGuerra[i][m_MaxY])
        {
            DispararGuerraTerritorio(i);
            SendClientMessage(playerid, AMARELO, "[STAFF] Guerra forcada com sucesso nesta zona.");
            return 1;
        }
    }
    SendClientMessage(playerid, VERMELHO, "[ERRO] Voce precisa estar dentro de uma GangZone para forcar o inicio!");
    return 1;
}

CMD:forcarfim(playerid, params)
{
    #pragma unused params
    new nome[MAX_PLAYER_NAME]; GetPlayerName(playerid, nome, sizeof(nome));
    if(strcmp(nome, "Lipee_fxp1", true) != 0) return SendClientMessage(playerid, VERMELHO, "[ERRO] Acesso negado.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        if(x >= MorroGuerra[i][m_MinX] && x <= MorroGuerra[i][m_MaxX] && y >= MorroGuerra[i][m_MinY] && y <= MorroGuerra[i][m_MaxY])
        {
            FinalizarGuerraTerritorio(i);
            SendClientMessage(playerid, AMARELO, "[STAFF] Guerra encerrada manualmente nesta zona.");
            return 1;
        }
    }
    SendClientMessage(playerid, VERMELHO, "[ERRO] Voce precisa estar dentro de uma GangZone para encerrar a guerra!");
    return 1;
}

CMD:resetarkills(playerid, params)
{
    #pragma unused params
    new nome[MAX_PLAYER_NAME]; GetPlayerName(playerid, nome, sizeof(nome));
    if(strcmp(nome, "Lipee_fxp1", true) != 0) return SendClientMessage(playerid, VERMELHO, "[ERRO] Acesso negado.");
    
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        if(x >= MorroGuerra[i][m_MinX] && x <= MorroGuerra[i][m_MaxX] && y >= MorroGuerra[i][m_MinY] && y <= MorroGuerra[i][m_MaxY])
        {
            MorroGuerra[i][m_KillsAtacante] = 0;
            MorroGuerra[i][m_KillsDefensor] = 0;
            SendClientMessage(playerid, AMARELO, "[STAFF] Kills resetadas nesta zona.");
            return 1;
        }
    }
    SendClientMessage(playerid, VERMELHO, "[ERRO] Voce precisa estar dentro de uma GangZone para resetar as kills!");
    return 1;
}

CMD:infoguerra(playerid, params)
{
    #pragma unused params
    new dlg[600];
    format(dlg, sizeof(dlg), 
        "{FFFFFF}=== INFORMACOES DE GUERRAS ===\n\n\
        {FF8000}Horarios de Disparo Automatico:\n\
        12:00 | 14:00 | 17:00 | 19:00 | 21:00 | 23:00 | 00:00\n\n\
        {FFFF00}Total de Zonas Registradas: %d\n\
        {00FF00}Fique dentro do perimetro da zona e use /guerra para verificar.",
        TotalMorrosCriados
    );
    ShowPlayerDialog(playerid, 9970, DIALOG_STYLE_MSGBOX, "Guerras", dlg, "Fechar", "");
    return 1;
}

CMD:rankingguerra(playerid, params)
{
    #pragma unused params
    new dlg[800], titulo[64];
    format(titulo, sizeof(titulo), "Ranking de Zonas de Guerra (%d Zonas)", TotalMorrosCriados);
    
    format(dlg, sizeof(dlg), "{FFFFFF}ID\tStatus\tAtacantes (Kills)\tDefensores (Kills)\n");
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        new status[32];
        if(MorroGuerra[i][m_GuerraAtiva]) format(status, sizeof(status), "{FF0000}Em Guerra");
        else format(status, sizeof(status), "{00FF00}Paz");
        
        new linha[128];
        format(linha, sizeof(linha), "%d\t%s\t%d Kills\t%d Kills\n", i, status, MorroGuerra[i][m_KillsAtacante], MorroGuerra[i][m_KillsDefensor]);
        strcat(dlg, linha);
    }
    ShowPlayerDialog(playerid, 9972, DIALOG_STYLE_TABLIST_HEADERS, titulo, dlg, "Fechar", "");
    return 1;
}

CMD:guerra(playerid, params)
{
    #pragma unused params
    if(!Pdados[playerid][Logado]) 
        return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce precisa estar logado!");

    new org = Pdados[playerid][Org];
    if(!(org >= 16 && org <= 32))
    {
        return SendClientMessage(playerid, 0xE74C3CFF, "[ERRO] Voce nao participa de uma organizacao Gangstar/Criminosa!");
    }

    new dentroDeAlguma = 0;
    for(new i = 0; i < TotalMorrosCriados; i++)
    {
        new Float:px, Float:py, Float:pz;
        GetPlayerPos(playerid, px, py, pz);

        if(px >= MorroGuerra[i][m_MinX] && px <= MorroGuerra[i][m_MaxX] && py >= MorroGuerra[i][m_MinY] && py <= MorroGuerra[i][m_MaxY])
        {
            dentroDeAlguma = 1;
            if(!MorroGuerra[i][m_GuerraAtiva])
            {
                SendClientMessage(playerid, VERMELHO, "[ERRO] Esta zona nao esta em guerra no momento.");
            }
            else
            {
                new string[128];
                format(string, sizeof(string), "[GUERRA] Voce esta combatendo na zona ativa! Kills do time: %d", MorroGuerra[i][m_KillsAtacante]);
                SendClientMessage(playerid, AMARELO, string);
            }
            break;
        }
    }

    if(!dentroDeAlguma)
    {
        SendClientMessage(playerid, VERMELHO, "[ERRO] Voce nao esta dentro de nenhum perimetro de zona de guerra.");
    }
    return 1;
}

CMD:cmdsguerra(playerid, params)
{
    #pragma unused params
    new lista[512];
    format(lista, sizeof(lista),
        "{FFFFFF}/infoguerra - Mostra informacoes e horarios\n\
        /rankingguerra - Exibe o ranking e placar das zonas\n\
        /guerra - Participa/Verifica status no perimetro\n\
        /cmdsguerra - Lista de comandos\n");

    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    if(!strcmp(nome, "Lipee_fxp1", true))
    {
        strcat(lista, "\n{FF0000}[STAFF]\n");
        strcat(lista, "/criarguerra /marcarponto - Cria e salva nova zona por etapas\n/apagargz - Apaga a zona onde esta\n/forcarinicio /forcarfim - Controla guerras\n/resetarkills - Reseta placar\n");
    }

    ShowPlayerDialog(playerid, 9971, DIALOG_STYLE_MSGBOX, "Comandos de Guerra", lista, "Fechar", "");
    return 1;
}
