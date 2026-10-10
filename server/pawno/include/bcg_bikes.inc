/**
 * ----------------------------------------------------------------------------
 * Nome da Include: bcg_bikes.inc
 * Descrição: Sistema de Spawn de Bicicletas (Versão Corrigida)
 * ----------------------------------------------------------------------------
 */

#if defined _bcg_bikes_included
    #endinput
#endif
#define _bcg_bikes_included

#define MAX_SPAWN_BIKES 50

enum e_SpawnBikeData
{
    bool:spAtivo,
    Float:spX,
    Float:spY,
    Float:spZ,
    Text3D:spTextID,
    spPickupID
};

new SpawnBikeInfo[MAX_SPAWN_BIKES][e_SpawnBikeData];
new VeiculoPlayer[MAX_PLAYERS];

stock bool:IsVeicValido(vehicleid)
{
    if(vehicleid == INVALID_VEHICLE_ID) return false;
    new Float:pos[3];
    return GetVehiclePos(vehicleid, pos[0], pos[1], pos[2]) != 0;
}

stock CarregarSpawnsBikes()
{
    new string[64];
    for(new i = 0; i < MAX_SPAWN_BIKES; i++)
    {
        format(string, sizeof(string), "SpawnsBikes/Spawn_%d.ini", i);
        if(DOF2_FileExists(string))
        {
            SpawnBikeInfo[i][spAtivo] = true;
            SpawnBikeInfo[i][spX] = DOF2_GetFloat(string, "X");
            SpawnBikeInfo[i][spY] = DOF2_GetFloat(string, "Y");
            SpawnBikeInfo[i][spZ] = DOF2_GetFloat(string, "Z");
            SpawnBikeInfo[i][spTextID] = CreateDynamic3DTextLabel("{00BFFF}Spawn Civil!{FFFFFF}\n'F' ou /pegarbike", -1, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ], 15.0);
            SpawnBikeInfo[i][spPickupID] = CreateDynamicPickup(1239, 1, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ]);
        }
    }
}

// Comandos
CMD:criarspa(playerid, params)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    for(new i = 0; i < MAX_SPAWN_BIKES; i++)
    {
        if(!SpawnBikeInfo[i][spAtivo])
        {
            SpawnBikeInfo[i][spAtivo] = true;
            SpawnBikeInfo[i][spX] = x; SpawnBikeInfo[i][spY] = y; SpawnBikeInfo[i][spZ] = z;
            SpawnBikeInfo[i][spTextID] = CreateDynamic3DTextLabel("Spawn Civil", -1, x, y, z, 15.0);
            SpawnBikeInfo[i][spPickupID] = CreateDynamicPickup(1239, 1, x, y, z);
            return SendClientMessage(playerid, -1, "Spawn criado!");
        }
    }
    return 1;
}

CMD:pegarbike(playerid, params)
{
    new Float:pos[4];
    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
    GetPlayerFacingAngle(playerid, pos[3]);
    new bike = CreateVehicle(509, pos[0], pos[1], pos[2]+1, pos[3], 3, 3, 60);
    PutPlayerInVehicle(playerid, bike, 0);
    VeiculoPlayer[playerid] = bike;
    return 1;
}

// Hooks simplificados (sem nomes longos)
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_SECONDARY_ATTACK)
    {
        for(new i = 0; i < MAX_SPAWN_BIKES; i++)
        {
            if(SpawnBikeInfo[i][spAtivo] && IsPlayerInRangeOfPoint(playerid, 2.0, SpawnBikeInfo[i][spX], SpawnBikeInfo[i][spY], SpawnBikeInfo[i][spZ]))
            {
                cmd_pegarbike(playerid, "");
                break;
            }
        }
    }
    #if defined bcg_OnPlayerKeyState
        return bcg_OnPlayerKeyState(playerid, newkeys, oldkeys);
    #else
        return 1;
    #endif
}
#define OnPlayerKeyStateChange bcg_OnPlayerKeyState
forward bcg_OnPlayerKeyState(playerid, newkeys, oldkeys);
