// BCG V043: inventory operates on existing account fields, never on UI supplied quantities.
new bool:BCG43InvOpen[MAX_PLAYERS];
new BCG43InvTick[MAX_PLAYERS];
new bool:BCG43DropActive[64], BCG43DropPickup[64], BCG43DropItem[64], BCG43DropQuantity[64], BCG43DropAt[64];
new Float:BCG43DropPos[64][3];
new BCG43DropWorld[64], BCG43DropInterior[64];
new const BCG43InvNames[10][] = {"Kit medico","Colete","Galao de gasolina","Kit de reparo","Adrenalina","Licencas","Caixa de som","Titulo","Celular","Portao"};
new const BCG43InvModels[10] = {1240,1242,1650,19921,1575,1581,2226,1581,18865,19912};
stock BCG43Quantity(playerid, slot)
{
    switch(slot)
    {
        case 0: return Pdados[playerid][pItem_Medikit];
        case 1: return Pdados[playerid][pItem_Colete];
        case 2: return Pdados[playerid][pItem_Galao];
        case 3: return Pdados[playerid][pItem_KitReparo];
        case 4: return Pdados[playerid][Adrenalina];
        case 5: return Pdados[playerid][pItem_Licencias];
        case 6: return Pdados[playerid][pItem_JBL];
        case 7: return Pdados[playerid][pItem_Titulo];
        case 8: return Pdados[playerid][Celular];
        case 9: return Pdados[playerid][pItem_Portao];
    }
    return 0;
}
stock BCG43Change(playerid, slot, amount)
{
    switch(slot)
    {
        case 0: Pdados[playerid][pItem_Medikit] += amount;
        case 1: Pdados[playerid][pItem_Colete] += amount;
        case 2: Pdados[playerid][pItem_Galao] += amount;
        case 3: Pdados[playerid][pItem_KitReparo] += amount;
        case 4: Pdados[playerid][Adrenalina] += amount;
        case 5: Pdados[playerid][pItem_Licencias] += amount;
        case 6: Pdados[playerid][pItem_JBL] += amount;
        case 7: Pdados[playerid][pItem_Titulo] += amount;
        default: return 0;
    }
    return 1;
}
stock BCG43Inventory(playerid, bool:open = true)
{
    if(!Pdados[playerid][Logado] || !BCG36Client[playerid]) return 1;
    if(open)BCG43InvOpen[playerid] = true;
    new packet[144], path[64], key[20];
    format(packet,sizeof(packet),"[BCG:UI]INV43|start|%s|%d|%d",Nome(playerid),playerid,open);
    SendClientMessage(playerid,-1,packet);
    for(new i=0;i<10;i++) {
        format(packet,sizeof(packet),"[BCG:UI]INV43|item|%d|%d|%d|%s",i,BCG43Quantity(playerid,i),BCG43InvModels[i],BCG43InvNames[i]);
        SendClientMessage(playerid,-1,packet);
    }
    format(path,sizeof(path),"Contas/%s.txt",Nome(playerid));
    for(new i=0;i<5;i++) {
        format(key,sizeof(key),"Quick43_%d",i);
        new slot=DOF2_GetInt(path,key)-1;
        if(g_DadosMorte[playerid][pEmComa])return SendClientMessage(playerid,-1,"[ERRO] Aguarde atendimento antes de usar ou entregar itens.");
    if(slot<0 || slot>=10)slot=-1;
        format(packet,sizeof(packet),"[BCG:UI]INV43|quick|%d|%d",i,slot);
        SendClientMessage(playerid,-1,packet);
    }
    SendClientMessage(playerid,-1,"[BCG:UI]INV43|ready");
    return 1;
}
stock BCG43InvClose(playerid)
{
    BCG43InvOpen[playerid]=false;
    SendClientMessage(playerid,-1,"[BCG:UI]INV43|close");
    return 1;
}
stock BCG43InvAction(playerid, params[])
{
    if(!Pdados[playerid][Logado] || !BCG36Client[playerid])return 1;
    if(!strcmp(params,"inv close",false))return BCG43InvClose(playerid);
    new verb[10],slot,qty,target,quick;
    if(sscanf(params,"s[10]iiii",verb,slot,qty,target,quick))return 1;
    if(slot<0 || slot>=10 || qty<1 || qty>50)return 1;
    if(GetTickCount()-BCG43InvTick[playerid]<350)return 1;
    BCG43InvTick[playerid]=GetTickCount();
    if(!BCG43InvOpen[playerid] && strcmp(verb,"quick",false))return 1;
    if(!strcmp(verb,"assign",false)) {
        if(quick<0 || quick>=5)return 1;
        new path[64],key[20];format(path,sizeof(path),"Contas/%s.txt",Nome(playerid));format(key,sizeof(key),"Quick43_%d",quick);
        DOF2_SetInt(path,key,slot+1);DOF2_WriteFile();return BCG43Inventory(playerid);
    }
    if(!strcmp(verb,"quick",false)) {
        if(quick<0 || quick>=5)return 1;
        new path[64],key[20];format(path,sizeof(path),"Contas/%s.txt",Nome(playerid));format(key,sizeof(key),"Quick43_%d",quick);
        if(DOF2_GetInt(path,key)!=slot+1)return 1;
    }
    if(BCG43Quantity(playerid,slot)<qty)return SendClientMessage(playerid,-1,"[ERRO] Quantidade indisponivel.");
    if(!strcmp(verb,"use",false) || !strcmp(verb,"quick",false)) {
        BCG43InvClose(playerid);
        if(slot==8)return BCG36Phone(playerid);
        if(slot==9){OnDialogResponse(playerid,DIALOG_MENU_MOCHILA,1,8,"");return 1;}
        if(slot==4)return cmd_usaradrenalina(playerid,"");
        if(slot==2) {
            if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER)return SendClientMessage(playerid,-1,"[ERRO] Entre como motorista para abastecer.");
            new vehicle=GetPlayerVehicleID(playerid);if(GasolinaVeiculo[vehicle]>=100)return SendClientMessage(playerid,-1,"[ERRO] O tanque esta cheio.");
            GasolinaVeiculo[vehicle]+=25;if(GasolinaVeiculo[vehicle]>100)GasolinaVeiculo[vehicle]=100;
            BCG43Change(playerid,slot,-1);SalvarDados(playerid);return SendClientMessage(playerid,-1,"[SUCESSO] Veiculo abastecido com o galao.");
        }
        new mapped=slot;
        if(slot==5)mapped=5;else if(slot==6)mapped=7;else if(slot==7)mapped=6;
        OnDialogResponse(playerid,DIALOG_MENU_MOCHILA,1,mapped,"");
        BCG43Inventory(playerid,false);
        return 1;
    }
    if(slot>=8)return SendClientMessage(playerid,-1,"[ERRO] Aparelhos vinculados a conta nao podem ser transferidos.");
    if(!strcmp(verb,"send",false)) {
        if(target<0 || target>=MAX_PLAYERS || target==playerid || !IsPlayerConnected(target) || !Pdados[target][Logado])return SendClientMessage(playerid,-1,"[ERRO] Jogador indisponivel.");
        new Float:x,Float:y,Float:z;GetPlayerPos(target,x,y,z);
        if(GetPlayerVirtualWorld(playerid)!=GetPlayerVirtualWorld(target) || GetPlayerInterior(playerid)!=GetPlayerInterior(target) || !IsPlayerInRangeOfPoint(playerid,3.0,x,y,z))return SendClientMessage(playerid,-1,"[ERRO] Aproxime-se do jogador para entregar.");
        if(BCG43Quantity(target,slot)+qty>50)return SendClientMessage(playerid,-1,"[ERRO] O destinatario atingiu o limite do item.");
        BCG43Change(playerid,slot,-qty);BCG43Change(target,slot,qty);SalvarDados(playerid);SalvarDados(target);
        SendClientMessage(target,-1,"[SUCESSO] Voce recebeu itens no inventario.");BCG43Inventory(playerid);return 1;
    }
    if(!strcmp(verb,"drop",false)) {
        new free=-1;
        for(new i=0;i<64;i++) {
            if(BCG43DropActive[i] && gettime()-BCG43DropAt[i]>900) {DestroyDynamicPickup(BCG43DropPickup[i]);BCG43DropActive[i]=false;}
            if(!BCG43DropActive[i] && free==-1)free=i;
        }
        if(free==-1)return SendClientMessage(playerid,-1,"[ERRO] Muitos itens no chao. Tente novamente depois.");
        new Float:x,Float:y,Float:z;GetPlayerPos(playerid,x,y,z);
        new pick=CreateDynamicPickup(BCG43InvModels[slot],1,x+2.5,y,z-0.6,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
        if(!IsValidDynamicPickup(pick))return SendClientMessage(playerid,-1,"[ERRO] Nao foi possivel deixar o item.");
        BCG43DropPos[free][0]=x+2.5;BCG43DropPos[free][1]=y;BCG43DropPos[free][2]=z;BCG43DropWorld[free]=GetPlayerVirtualWorld(playerid);BCG43DropInterior[free]=GetPlayerInterior(playerid);
        BCG43DropPickup[free]=pick;BCG43DropItem[free]=slot;BCG43DropQuantity[free]=qty;BCG43DropAt[free]=gettime();BCG43DropActive[free]=true;
        BCG43Change(playerid,slot,-qty);SalvarDados(playerid);BCG43Inventory(playerid);return 1;
    }
    return 1;
}
public OnPlayerPickUpDynamicPickup(playerid,pickupid)
{
    if(!Pdados[playerid][Logado])return 1;
    for(new i=0;i<64;i++)if(BCG43DropActive[i] && BCG43DropPickup[i]==pickupid) {
        if(GetPlayerVirtualWorld(playerid)!=BCG43DropWorld[i] || GetPlayerInterior(playerid)!=BCG43DropInterior[i] || !IsPlayerInRangeOfPoint(playerid,3.0,BCG43DropPos[i][0],BCG43DropPos[i][1],BCG43DropPos[i][2]) || gettime()-BCG43DropAt[i]<2)return 1;
        if(BCG43Quantity(playerid,BCG43DropItem[i])+BCG43DropQuantity[i]>50)return SendClientMessage(playerid,-1,"[ERRO] Sem espaco para mais unidades deste item.");
        BCG43DropActive[i]=false;DestroyDynamicPickup(pickupid);
        BCG43Change(playerid,BCG43DropItem[i],BCG43DropQuantity[i]);SalvarDados(playerid);
        SendClientMessage(playerid,-1,"[SUCESSO] Item recolhido do chao.");if(BCG43InvOpen[playerid])BCG43Inventory(playerid);return 1;
    }
    return 1;
}
