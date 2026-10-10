/*
    Módulo de GangZones - BrasilRP
*/

#if defined _gangzones_included
    #endinput
#endif
#define _gangzones_included

#define TOTAL_ZONAS 4

enum E_GANG_ZONES {
    Float:gzMinX,
    Float:gzMinY,
    Float:gzMaxX,
    Float:gzMaxY,
    gzCor
}

// Dados exatos obtidos da imagem 1000358803.png
static const GangZonesData[TOTAL_ZONAS][E_GANG_ZONES] = {
    {-1550.0,  350.0, -1250.0,  650.0, 0xA8B4B4AA}, // Zona ID 29 (Topo Esquerdo)
    { 1250.0,  100.0,  1600.0,  450.0, 0xFF0000AA}, // Zona ID 17 (Centro - Vermelha)
    {-1150.0, -2450.0, -850.0, -2150.0, 0x8B4513AA}, // Zona ID 8 (Inferior Esquerdo)
    { 1600.0, -2700.0,  2100.0, -2200.0, 0x708090AA}  // Zona ID 30/33 (Inferior Direito)
};

static StatusGangZones[TOTAL_ZONAS];

// Função que será chamada no OnGameModeInit
stock CarregarGangZonesModulares()
{
    for(new i = 0; i < TOTAL_ZONAS; i++)
    {
        StatusGangZones[i] = GangZoneCreate(
            GangZonesData[i][gzMinX], 
            GangZonesData[i][gzMinY], 
            GangZonesData[i][gzMaxX], 
            GangZonesData[i][gzMaxY]
        );
    }
    printf("[MODULO] %d GangZones carregadas com sucesso.", TOTAL_ZONAS);
    return 1;
}

// Função que será chamada no OnPlayerSpawn
stock MostrarGangZonesModulares(playerid)
{
    for(new i = 0; i < TOTAL_ZONAS; i++)
    {
        GangZoneShowForPlayer(playerid, StatusGangZones[i], GangZonesData[i][gzCor]);
    }
    return 1;
}
