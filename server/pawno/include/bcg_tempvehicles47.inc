#if defined _bcg_tempvehicles47_included
    #endinput
#endif
#define _bcg_tempvehicles47_included
new BCG47TempVehicle[MAX_PLAYERS], BCG47TempOwner[MAX_VEHICLES];
new bool:BCG47TempActive[MAX_VEHICLES];
stock BCG47ForgetVehicle(vehicleid)
{
    if(vehicleid<=0||vehicleid>=MAX_VEHICLES||!BCG47TempActive[vehicleid]) return 1;
    new bcg47Owner=BCG47TempOwner[vehicleid];
    if(bcg47Owner>=0&&bcg47Owner<MAX_PLAYERS&&BCG47TempVehicle[bcg47Owner]==vehicleid) BCG47TempVehicle[bcg47Owner]=0;
    BCG47TempActive[vehicleid]=false;return 1;
}
stock BCG47DestroyVehicle(vehicleid)
{
    BCG47ForgetVehicle(vehicleid);
    return DestroyVehicle(vehicleid);
}
stock BCG47CreateVehicle(modelid,Float:x,Float:y,Float:z,Float:angle,color1,color2,respawn_delay,addsiren=0)
{
    new bcg47Vehicle=CreateVehicle(modelid,x,y,z,angle,color1,color2,respawn_delay,addsiren);
    BCG47ForgetVehicle(bcg47Vehicle);
    return bcg47Vehicle;
}
stock BCG47ReleaseVehicle(playerid)
{
    new bcg47Vehicle=BCG47TempVehicle[playerid];
    if(bcg47Vehicle>0&&bcg47Vehicle<MAX_VEHICLES&&BCG47TempActive[bcg47Vehicle]&&BCG47TempOwner[bcg47Vehicle]==playerid) BCG47DestroyVehicle(bcg47Vehicle);
    BCG47TempVehicle[playerid]=0;return 1;
}
#define DestroyVehicle BCG47DestroyVehicle
#define CreateVehicle BCG47CreateVehicle
