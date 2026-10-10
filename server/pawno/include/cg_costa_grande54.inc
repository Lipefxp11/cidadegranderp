// Cidade Grande SA-MP: Costa Grande V054. Native-model test district.
#if defined _cg54_map_included
    #endinput
#endif
#define _cg54_map_included
#define CG54_WORLD (5400)
new bool:CG54Ready;
new bool:CG54Inside[MAX_PLAYERS];
new CG54Timer[MAX_PLAYERS], CG54Stamp[MAX_PLAYERS];
new CG54World[MAX_PLAYERS], CG54Interior[MAX_PLAYERS];
new Float:CG54Return[MAX_PLAYERS][4];
new STREAMER_TAG_OBJECT:CG54Objects[69];
new const Float:CG54Layout[][7] = {
    {12814.0, 2309.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2309.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2309.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2309.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2309.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2339.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2339.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2339.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2339.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2339.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2369.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2369.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2369.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2369.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2369.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2399.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2399.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2399.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2399.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2399.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2429.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2429.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2429.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2429.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2429.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2459.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2459.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2459.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2459.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2459.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2489.99695, -2900.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2489.99695, -2850.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2489.99695, -2800.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2489.99695, -2750.00580, 59.99170, 0.0, 240.0, 240.0},
    {12814.0, 2489.99695, -2700.00580, 59.99170, 0.0, 240.0, 240.0},
    {8357.0, 2400.00000, -2800.00000, 60.01374, 0.0, 240.0, 240.0},
    {3653.0, 2335.00000, -2885.00000, 68.16751, 0.0, 240.0, 240.0},
    {3653.0, 2335.00000, -2860.00000, 68.16751, 0.0, 240.0, 240.0},
    {3555.0, 2335.00000, -2740.00000, 62.72795, 0.0, 240.0, 240.0},
    {3556.0, 2335.00000, -2715.00000, 62.62640, 0.0, 240.0, 240.0},
    {3653.0, 2465.00000, -2885.00000, 68.16751, 0.0, 240.0, 240.0},
    {3653.0, 2465.00000, -2860.00000, 68.16751, 0.0, 240.0, 240.0},
    {3555.0, 2465.00000, -2740.00000, 62.72795, 0.0, 240.0, 240.0},
    {3556.0, 2465.00000, -2715.00000, 62.62640, 0.0, 240.0, 240.0},
    {3557.0, 2317.00000, -2775.00000, 62.79292, 0.0, 240.0, 240.0},
    {3557.0, 2352.00000, -2775.00000, 62.79292, 0.0, 240.0, 240.0},
    {3557.0, 2448.00000, -2775.00000, 62.79292, 0.0, 240.0, 240.0},
    {3557.0, 2483.00000, -2775.00000, 62.79292, 0.0, 240.0, 240.0},
    {620.0, 2371.00000, -2895.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2371.00000, -2850.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2371.00000, -2800.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2371.00000, -2750.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2371.00000, -2705.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2429.00000, -2895.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2429.00000, -2850.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2429.00000, -2800.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2429.00000, -2750.00000, 60.06716, 0.0, 110.0, 110.0},
    {620.0, 2429.00000, -2705.00000, 60.06716, 0.0, 110.0, 110.0},
    {1231.0, 2377.00000, -2875.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2377.00000, -2825.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2377.00000, -2775.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2377.00000, -2725.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2423.00000, -2875.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2423.00000, -2825.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2423.00000, -2775.00000, 62.73039, 0.0, 110.0, 110.0},
    {1231.0, 2423.00000, -2725.00000, 62.73039, 0.0, 110.0, 110.0},
    {1256.0, 2320.00000, -2815.00000, 60.65946, 90.0, 110.0, 110.0},
    {1256.0, 2340.00000, -2815.00000, 60.65946, 90.0, 110.0, 110.0},
    {1256.0, 2360.00000, -2815.00000, 60.65946, 90.0, 110.0, 110.0}
};
stock CG54Unload()
{
    for(new i=0;i<sizeof(CG54Objects);i++) {
        if(CG54Objects[i]) DestroyDynamicObject(CG54Objects[i]);
        CG54Objects[i]=STREAMER_TAG_OBJECT:0;
    }
    CG54Ready=false;
    return 1;
}
stock CG54Load()
{
    if(CG54Ready) return 1;
    for(new i=0;i<sizeof(CG54Layout);i++) {
        CG54Objects[i]=CreateDynamicObject(floatround(CG54Layout[i][0]),CG54Layout[i][1],CG54Layout[i][2],CG54Layout[i][3],0.0,0.0,CG54Layout[i][4],CG54_WORLD,0,-1,CG54Layout[i][5],CG54Layout[i][6]);
        if(!CG54Objects[i]) { CG54Unload(); print("[Costa Grande] Falha ao criar o mapa."); return 0; }
    }
    CG54Ready=true;
    print("[Costa Grande] V054 carregada no mundo de teste 5400.");
    return 1;
}
stock CG54Reset(playerid)
{
    if(CG54Timer[playerid]) KillTimer(CG54Timer[playerid]);
    CG54Timer[playerid]=0;
    CG54Stamp[playerid]++;
    CG54Inside[playerid]=false;
    return 1;
}
forward CG54Release(playerid,stamp);
public CG54Release(playerid,stamp)
{
    if(!IsPlayerConnected(playerid)||CG54Stamp[playerid]!=stamp) return 0;
    CG54Timer[playerid]=0;
    TogglePlayerControllable(playerid,true);
    return 1;
}
stock CG54Stream(playerid)
{
    if(CG54Timer[playerid]) KillTimer(CG54Timer[playerid]);
    CG54Stamp[playerid]++;
    TogglePlayerControllable(playerid,false);
    Streamer_Update(playerid);
    new cg54Format[]="ii", cg54Callback[]="CG54Release";
    CG54Timer[playerid]=SetTimerEx(cg54Callback,2000,false,cg54Format,playerid,CG54Stamp[playerid]);
    if(!CG54Timer[playerid]) TogglePlayerControllable(playerid,true);
    return 1;
}
CMD:testarmapa(playerid,params[])
{
    #pragma unused params
    if(!CG52Approved[playerid] || !Pdados[playerid][pLogged]) return 1;
    if(g_DadosMorte[playerid][pEmComa]) return SendClientMessage(playerid,-1,"ERRO: Aguarde sair do estado de coma.");
    if(!ADM(playerid,1)) return SendClientMessage(playerid,-1,"ERRO: Apenas administradores podem testar o mapa.");
    if(!CG54Ready) return SendClientMessage(playerid,-1,"ERRO: Costa Grande indisponivel.");
    if(CG54Inside[playerid]) return SendClientMessage(playerid,-1,"Use /voltarmapa para sair de Costa Grande.");
    if(GetPlayerState(playerid)!=PLAYER_STATE_ONFOOT) return SendClientMessage(playerid,-1,"ERRO: Saia do veiculo para testar o mapa.");
    CG54World[playerid]=GetPlayerVirtualWorld(playerid);
    CG54Interior[playerid]=GetPlayerInterior(playerid);
    GetPlayerPos(playerid,CG54Return[playerid][0],CG54Return[playerid][1],CG54Return[playerid][2]);
    GetPlayerFacingAngle(playerid,CG54Return[playerid][3]);
    CG54Inside[playerid]=true;
    SetPlayerInterior(playerid,0);
    SetPlayerVirtualWorld(playerid,CG54_WORLD);
    SetPlayerPos(playerid,2400.0,-2890.0,61.5);
    SetPlayerFacingAngle(playerid,0.0);
    SetCameraBehindPlayer(playerid);
    CG54Stream(playerid);
    return SendClientMessage(playerid,-1,"Costa Grande: regiao de teste. Para retornar, use /voltarmapa.");
}
CMD:voltarmapa(playerid,params[])
{
    #pragma unused params
    if(!CG54Inside[playerid]) return SendClientMessage(playerid,-1,"ERRO: Voce nao esta testando Costa Grande.");
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    SetPlayerVirtualWorld(playerid,CG54World[playerid]);
    SetPlayerInterior(playerid,CG54Interior[playerid]);
    SetPlayerPos(playerid,CG54Return[playerid][0],CG54Return[playerid][1],CG54Return[playerid][2]);
    SetPlayerFacingAngle(playerid,CG54Return[playerid][3]);
    CG54Inside[playerid]=false;
    CG54Stream(playerid);
    return SendClientMessage(playerid,-1,"Voce voltou ao local anterior.");
}
