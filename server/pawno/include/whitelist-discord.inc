/*
    ==================================================
    SISTEMA DE WHITELIST DISCORD
    Cidade Grande RP
    ==================================================
*/

#if defined _whitelistdiscord_included
    #endinput
#endif
#define _whitelistdiscord_included

#include <a_samp>
#include <discord-connector>

// ==================================================
// CONFIGURAÇÕES
// ==================================================

#define ID_CANAL_WHITELIST "1542987874675335218"
#define ID_CARGO_DISCORD   "1542991563049934959"
#define PASTA_WHITELIST    "scriptfiles/whitelist"

// ==================================================
// VARIÁVEIS
// ==================================================

new DCC_Channel:CanalWhitelist;

// ==================================================
// FORWARD
// ==================================================

forward SendWhitelistEmbed(DCC_Channel:channel);

// ==================================================
// INICIALIZAÇÃO
// ==================================================

public OnGameModeInit()
{
    CanalWhitelist = DCC_FindChannelById(ID_CANAL_WHITELIST);

    if (_:CanalWhitelist != 0)
    {
        print("[WHITELIST] Canal encontrado.");
        SendWhitelistEmbed(CanalWhitelist);
    }
    else
    {
        print("[WHITELIST] ERRO: Canal nao encontrado.");
    }

    return 1;
}

// ==================================================
// MENSAGENS DO DISCORD
// ==================================================

public DCC_OnMessageCreate(DCC_Message:message)
{
    new DCC_Channel:channel;
    DCC_GetMessageChannel(message, channel);

    if (channel != CanalWhitelist)
        return 1;

    new DCC_User:author;
    DCC_GetMessageAuthor(message, author);

    new bool:isBot;
    DCC_IsUserBot(author, isBot);

    if (isBot)
        return 1;

    new content[256];
    DCC_GetMessageContent(message, content, sizeof(content));

    new command[32], params[128];
    new pos = strfind(content, " ");

    if (pos != -1)
    {
        strmid(command, content, 0, pos, sizeof(command));
        strmid(params, content, pos + 1, strlen(content), sizeof(params));
    }
    else
    {
        format(command, sizeof(command), "%s", content);
        params[0] = '\0';
    }

    if (command[0] != '!')
        return 1;

    // ==================================================
    // COMANDO !LIBERAR
    // ==================================================

    if (!strcmp(command, "!liberar", true))
    {
        new userId[DCC_ID_SIZE];
        DCC_GetUserId(author, userId, sizeof(userId));

        // Remove espaços e quebras de linha do final
        while (strlen(params) > 0)
        {
            new tamanho = strlen(params);

            if (params[tamanho - 1] == ' ' || params[tamanho - 1] == '\r' || params[tamanho - 1] == '\n')
            {
                params[tamanho - 1] = '\0';
            }
            else
            {
                break;
            }
        }

        // Nome não informado
        if (params[0] == '\0')
        {
            new mensagem[256];
            format(mensagem, sizeof(mensagem), "Uso correto: `!liberar Nome_Sobrenome`\n\nExemplo: `!liberar Lipee_fxp1`\n\n<@%s>", userId);
            DCC_SendChannelMessage(channel, mensagem);
            return 1;
        }

        // Caminho do arquivo
        new caminho[256];
        format(caminho, sizeof(caminho), "%s/%s.ini", PASTA_WHITELIST, params);

        // Verifica se já existe
        new File:arquivoCheck = fopen(caminho, io_read);
        if (arquivoCheck)
        {
            fclose(arquivoCheck);

            new mensagem[256];
            format(mensagem, sizeof(mensagem), "O jogador **%s** ja esta cadastrado na whitelist. <@%s>", params, userId);
            DCC_SendChannelMessage(channel, mensagem);
            return 1;
        }

        // Cria a whitelist
        new File:arquivo = fopen(caminho, io_write);
        if (!arquivo)
        {
            print("[WHITELIST] ERRO AO CRIAR ARQUIVO.");
            DCC_SendChannelMessage(channel, "Erro ao salvar a whitelist.");
            return 1;
        }

        new dados[256];
        format(dados, sizeof(dados), "discord=%s\r\nnome=%s\r\n", userId, params);
        fwrite(arquivo, dados);
        fclose(arquivo);

        // Pega guild e atribui cargo
        new DCC_Guild:guild;
        DCC_GetChannelGuild(channel, guild);

        if (_:guild != 0)
        {
            new DCC_Role:role = DCC_FindRoleById(ID_CARGO_DISCORD);

            if (_:role != 0)
            {
                DCC_AddGuildMemberRole(guild, author, role);
                print("[WHITELIST] Cargo atribuido com sucesso.");
            }
            else
            {
                print("[WHITELIST] ERRO: Cargo nao encontrado.");
            }
        }

        // Mensagem de sucesso
        new sucesso[256];
        format(sucesso, sizeof(sucesso), "Whitelist liberada com sucesso para **%s**! <@%s>", params, userId);
        DCC_SendChannelMessage(channel, sucesso);

        return 1;
    }

    return 1;
}

// ==================================================
// EMBED
// ==================================================

stock SendWhitelistEmbed(DCC_Channel:channel)
{
    if (_:channel == 0)
        return 0;

    new DCC_Embed:embed = DCC_CreateEmbed();

    DCC_SetEmbedTitle(embed, "Liberacao de WhiteList");
    DCC_SetEmbedColor(embed, 0x9F79D0);
    DCC_SetEmbedThumbnail(embed, "https://i.imgur.com/ry6TBxU.jpeg");
    DCC_SetEmbedDescription(embed, "Para liberar sua whitelist, utilize o comando abaixo.");
    
    DCC_AddEmbedField(embed, "Comando", "!liberar Nome_Sobrenome", false);
    DCC_AddEmbedField(embed, "Exemplo", "!liberar Lipee_fxp1", false);
    
    DCC_SetEmbedFooter(embed, "WhiteList System v1.0.0", "https://i.imgur.com/ry6TBxU.jpeg");

    DCC_SendChannelEmbedMessage(channel, embed, "");

    return 1;
}
