#if defined _bcg_wardrobe47_included
    #endinput
#endif
#define _bcg_wardrobe47_included
new bool:BCG47Enabled[MAX_PLAYERS], BCG47Fit[MAX_PLAYERS][4], BCG47Tick[MAX_PLAYERS];

stock BCG47Packet(playerid, receiver)
{
    new bcg47Packet[96];
    if(BCG47Enabled[playerid]) format(bcg47Packet,sizeof(bcg47Packet),"[BCG:LOOK47]%d|%d|%d|%d|%d",playerid,BCG47Fit[playerid][0],BCG47Fit[playerid][1],BCG47Fit[playerid][2],BCG47Fit[playerid][3]);
    else format(bcg47Packet,sizeof(bcg47Packet),"[BCG:LOOK47]%d|-1|-1|-1|-1",playerid);
    if(receiver==INVALID_PLAYER_ID)
    {
        for(new bcg47Viewer=0;bcg47Viewer<MAX_PLAYERS;bcg47Viewer++) if(IsPlayerConnected(bcg47Viewer)&&BCG36Client[bcg47Viewer]) SendClientMessage(bcg47Viewer,-1,bcg47Packet);
    }
    else if(IsPlayerConnected(receiver)&&BCG36Client[receiver]) SendClientMessage(receiver,-1,bcg47Packet);
    return 1;
}
stock BCG47Reset(playerid)
{
    BCG47Enabled[playerid]=false;BCG47Tick[playerid]=0;
    for(new bcg47I=0;bcg47I<4;bcg47I++) BCG47Fit[playerid][bcg47I]=0;
    return BCG47Packet(playerid,INVALID_PLAYER_ID);
}
stock BCG47Load(playerid)
{
    new bcg47Path[64];format(bcg47Path,sizeof(bcg47Path),"Contas/%s.txt",Nome(playerid));
    if(!DOF2_FileExists(bcg47Path)) return 0;
    BCG47Enabled[playerid]=DOF2_GetInt(bcg47Path,"BCG47Enabled")!=0;
    BCG47Fit[playerid][0]=DOF2_GetInt(bcg47Path,"BCG47Top");
    BCG47Fit[playerid][1]=DOF2_GetInt(bcg47Path,"BCG47Bottom");
    BCG47Fit[playerid][2]=DOF2_GetInt(bcg47Path,"BCG47Shoes");
    BCG47Fit[playerid][3]=DOF2_GetInt(bcg47Path,"BCG47Hair");
    new bcg47Limits[4]={5,5,4,6};
    for(new bcg47I=0;bcg47I<4;bcg47I++) if(BCG47Fit[playerid][bcg47I]<0||BCG47Fit[playerid][bcg47I]>=bcg47Limits[bcg47I]) BCG47Fit[playerid][bcg47I]=0;
    return BCG47Packet(playerid,INVALID_PLAYER_ID);
}
stock BCG47Save(playerid)
{
    new bcg47Path[64];format(bcg47Path,sizeof(bcg47Path),"Contas/%s.txt",Nome(playerid));
    if(!DOF2_FileExists(bcg47Path)) return 0;
    DOF2_SetInt(bcg47Path,"BCG47Enabled",BCG47Enabled[playerid]);
    DOF2_SetInt(bcg47Path,"BCG47Top",BCG47Fit[playerid][0]);
    DOF2_SetInt(bcg47Path,"BCG47Bottom",BCG47Fit[playerid][1]);
    DOF2_SetInt(bcg47Path,"BCG47Shoes",BCG47Fit[playerid][2]);
    DOF2_SetInt(bcg47Path,"BCG47Hair",BCG47Fit[playerid][3]);
    if(BCG47Enabled[playerid]) {Pdados[playerid][Skin]=0;DOF2_SetInt(bcg47Path,"Skin",0);SetPlayerSkin(playerid,0);}
    DOF2_WriteFile();return BCG47Packet(playerid,INVALID_PLAYER_ID);
}
stock BCG47Select(playerid,skin)
{
    BCG47Enabled[playerid]=skin==0;
    if(skin==0) for(new bcg47I=0;bcg47I<4;bcg47I++) BCG47Fit[playerid][bcg47I]=0;
    return BCG47Save(playerid);
}
CMD:bcglook47(playerid,params[])
{
    if(!BCG36Client[playerid]||(!Pdados[playerid][Logado]&&!BCG36Authenticated[playerid])||GetPVarInt(playerid,"BCG_NOVA_CONTA")) return 1;
    if(GetTickCount()-BCG47Tick[playerid]<500) return 1;
    BCG47Tick[playerid]=GetTickCount();
    if(Pdados[playerid][Genero]!=1) return SendClientMessage(playerid,-1,"[ERRO] As roupas modulares desta base sao masculinas. Use Personalizar para escolher o personagem feminino.");
    if(!strcmp(params,"open",false))
    {
        BCG47Load(playerid);
        new bcg47Packet[96];format(bcg47Packet,sizeof(bcg47Packet),"[BCG:UI]LOOK47|%d|%d|%d|%d",BCG47Fit[playerid][0],BCG47Fit[playerid][1],BCG47Fit[playerid][2],BCG47Fit[playerid][3]);
        return SendClientMessage(playerid,-1,bcg47Packet);
    }
    new bcg47Verb[12],bcg47Top,bcg47Bottom,bcg47Shoes,bcg47Hair;
    if(sscanf(params,"s[12]iiii",bcg47Verb,bcg47Top,bcg47Bottom,bcg47Shoes,bcg47Hair)||strcmp(bcg47Verb,"save",false)) return 1;
    if(bcg47Top<0||bcg47Top>=5||bcg47Bottom<0||bcg47Bottom>=5||bcg47Shoes<0||bcg47Shoes>=4||bcg47Hair<0||bcg47Hair>=6) return SendClientMessage(playerid,-1,"[ERRO] Escolha uma aparencia valida.");
    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,-1,"[ERRO] Saia do veiculo para trocar de roupa.");
    BCG47Enabled[playerid]=true;BCG47Fit[playerid][0]=bcg47Top;BCG47Fit[playerid][1]=bcg47Bottom;BCG47Fit[playerid][2]=bcg47Shoes;BCG47Fit[playerid][3]=bcg47Hair;
    if(!BCG47Save(playerid)) return SendClientMessage(playerid,-1,"[ERRO] A conta nao foi encontrada para salvar.");
    SendClientMessage(playerid,-1,"[BCG:UI]LOOK47SAVED");
    return SendClientMessage(playerid,-1,"[SUCESSO] Aparencia salva na sua conta.");
}
