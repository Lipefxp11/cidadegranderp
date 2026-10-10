/*
    Sistema de Criação de Veículos por Organização (Include)
*/

#if defined _car_orgs_included
    #endinput
#endif
#define _car_orgs_included

// ---- DEFINIÇÕES DE DIALOGS ----
#define DIALOG_MENU_BASE_ORG  9848
#define DIALOG_LISTA_VEICULOS 9849

// ---- VARIÁVEIS DO SISTEMA ----
static TempCriarOrgID[MAX_PLAYERS];
static Float:TempLocalComando[MAX_PLAYERS][3];
static Float:TempLocalSpawn[MAX_PLAYERS][4];
static TempVeiculoSelecionado[MAX_PLAYERS];
static RegistrouLocalComando[MAX_PLAYERS];
static RegistrouLocalSpawn[MAX_PLAYERS];

// ---- DECLARAÇÃO DE FUNÇÕES INTERNAS (STOCKS) ----

stock MostrarMenuCriarOrg(playerid)
{
    new string_dialog[400];
    format(string_dialog, sizeof(string_dialog), 
        "1. Definir Local do Comando %s\n2. Definir Local do Spawn do Carro %s\n3. Escolher Modelo do Veiculo\n{00FF00}4. Confirmar e Salvar Tudo",
        (RegistrouLocalComando[playerid] == 1) ? ("{00FF00}[OK]") : ("{FF0000}[Pendente]"),
        (RegistrouLocalSpawn[playerid] == 1) ? ("{00FF00}[OK]") : ("{FF0000}[Pendente]")
    );

    new titulo[64];
    format(titulo, sizeof(titulo), "Configurando Org ID: %d", TempCriarOrgID[playerid]);
    ShowPlayerDialog(playerid, DIALOG_MENU_BASE_ORG, DIALOG_STYLE_LIST, titulo, string_dialog, "Selecionar", "Fechar");
    return 1;
}

stock CriarVeiculoComTexto3D(orgid, model, Float:x, Float:y, Float:z, Float:angle)
{
    new carid = CreateVehicle(model, x, y, z, angle, -1, -1, -1);
    
    // --- INTEGRAÇÃO COM O SISTEMA DE MOTOR MANUAL E GASOLINA ---
    GasolinaVeiculo[carid] = 100; // Define o tanque cheio para o veículo carregado
    MotorLigado[carid] = false;   // Garante que o motor comece desligado na nossa variável estável

    // Força o motor nativo do SA-MP a iniciar completamente desligado (0)
    new engine, lights, alarm, v_doors, v_bonnet, v_boot, objective;
    GetVehicleParamsEx(carid, engine, lights, alarm, v_doors, v_bonnet, v_boot, objective);
    SetVehicleParamsEx(carid, VEHICLE_PARAMS_OFF, lights, alarm, v_doors, v_bonnet, v_boot, objective);
    // -----------------------------------------------------------

    new label_text[128];
    format(label_text, sizeof(label_text), "Veiculo de Organizacao\n{00FFF0}%s", GetNomeOrg(orgid));
    
    new Text3D:carLabel = Create3DTextLabel(label_text, 0xFFFFFFFF, 0.0, 0.0, 0.0, 18.0, 0, 1);
    Attach3DTextLabelToVehicle(carLabel, carid, 0.0, 0.0, 0.85);
    return carid;
}

stock CarregarVeiculosOrgs_Include()
{
    new filename[64], line[250];
    new model;
    new Float:cx, Float:cy, Float:cz; 
    new Float:sx, Float:sy, Float:sz, Float:sa; 
    new File:file;

    for(new org = 1; org <= 32; org++)
    {
        format(filename, sizeof(filename), "CarOrgs/Org_%d.txt", org);
        
        if(fexist(filename))
        {
            file = fopen(filename, io_read);
            while(fread(file, line))
            {
                new len = strlen(line);
                if(line[len - 1] == '\r' || line[len - 1] == '\n') line[len - 1] = 0;
                if(line[len - 2] == '\r' || line[len - 2] == '\n') line[len - 2] = 0;

                if(sscanf(line, "p<|>fffffffff", model, cx, cy, cz, sx, sy, sz, sa)) continue;
                
                CriarVeiculoComTexto3D(org, model, sx, sy, sz, sa);
            }
            fclose(file);
        }
    }
    print(">> [SISTEMA INCLUDED] Veiculos das Organizacoes carregados com motores manuais.");
    return 1;
}

// ---- INTERCEPTADOR DE RESPOTA DE DIALOGS ----
stock CO_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_MENU_BASE_ORG:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0: 
                {
                    GetPlayerPos(playerid, TempLocalComando[playerid][0], TempLocalComando[playerid][1], TempLocalComando[playerid][2]);
                    RegistrouLocalComando[playerid] = 1;
                    SendClientMessage(playerid, CINZA, "Sucesso: Local do comando definido onde voce esta pisando!");
                    MostrarMenuCriarOrg(playerid);
                }
                case 1: 
                {
                    GetPlayerPos(playerid, TempLocalSpawn[playerid][0], TempLocalSpawn[playerid][1], TempLocalSpawn[playerid][2]);
                    GetPlayerFacingAngle(playerid, TempLocalSpawn[playerid][3]);
                    RegistrouLocalSpawn[playerid] = 1;
                    SendClientMessage(playerid, CINZA, "Sucesso: Local de Spawn do veiculo definido aqui!");
                    MostrarMenuCriarOrg(playerid);
                }
                case 2: 
                {
                    ShowPlayerDialog(playerid, DIALOG_LISTA_VEICULOS, DIALOG_STYLE_LIST, "Selecione o Veiculo", "Burrito (Van)\nSavana (Lowrider)\nPicador (Fezes/Pick-up)\nMaverick (Helicoptero)", "Escolher", "Voltar");
                }
                case 3: 
                {
                    if(RegistrouLocalComando[playerid] == 0 || RegistrouLocalSpawn[playerid] == 0)
                    {
                        return SendClientMessage(playerid, CINZA, "Erro: Voce precisa definir o local do comando E o local do spawn antes de salvar.");
                    }

                    new org = TempCriarOrgID[playerid];
                    new filename[64], line[250];
                    format(filename, sizeof(filename), "CarOrgs/Org_%d.txt", org);

                    new File:file = fopen(filename, io_append);
                    if(file)
                    {
                        format(line, sizeof(line), "%d|%f|%f|%f|%f|%f|%f|%f\r\n", 
                            TempVeiculoSelecionado[playerid],
                            TempLocalComando[playerid][0], TempLocalComando[playerid][1], TempLocalComando[playerid][2],
                            TempLocalSpawn[playerid][0], TempLocalSpawn[playerid][1], TempLocalSpawn[playerid][2], TempLocalSpawn[playerid][3]
                        );
                        
                        fwrite(file, line);
                        fclose(file);

                        // Cria o veículo através do stock que agora desliga os motores automaticamente
                        CriarVeiculoComTexto3D(org, TempVeiculoSelecionado[playerid], TempLocalSpawn[playerid][0], TempLocalSpawn[playerid][1], TempLocalSpawn[playerid][2], TempLocalSpawn[playerid][3]);
                        SendClientMessage(playerid, CINZA, "Tudo pronto! Local de comando, spawn e veiculo salvos perfeitamente.");
                    }
                    else
                    {
                        SendClientMessage(playerid, CINZA, "Erro catastrófico: Verifique se a pasta 'CarOrgs' existe in scriptfiles.");
                    }
                }
            }
            return 1;
        }

        case DIALOG_LISTA_VEICULOS:
        {
            if(!response) return MostrarMenuCriarOrg(playerid);

            switch(listitem)
            {
                case 0: TempVeiculoSelecionado[playerid] = 482; 
                case 1: TempVeiculoSelecionado[playerid] = 567; 
                case 2: TempVeiculoSelecionado[playerid] = 600; 
                case 3: TempVeiculoSelecionado[playerid] = 487; 
            }

            SendClientMessage(playerid, CINZA, "Modelo de veiculo selecionado!");
            MostrarMenuCriarOrg(playerid); 
            return 1;
        }
    }
    return 0;
}

// ---- O COMANDO DENTRO DA INCLUDE ----
CMD:criarsporg(playerid, params[])
{
    if(!(ADM(playerid, 3))) return 1;

    new id_org;
    if(sscanf(params, "i", id_org)) return SendClientMessage(playerid, CINZA, "Use /criarsporg [ID DA ORG]");
    if(id_org < 1 || id_org > 32) return SendClientMessage(playerid, CINZA, "ID de organizacao invalido (1 a 32).");

    TempCriarOrgID[playerid] = id_org;
    RegistrouLocalComando[playerid] = 0;
    RegistrouLocalSpawn[playerid] = 0;

    MostrarMenuCriarOrg(playerid);
    return 1;
}
