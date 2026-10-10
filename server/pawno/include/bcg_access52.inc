#if defined _bcg_access52
 #endinput
#endif
#define _bcg_access52
#include <a_http>
new bool:CG52Approved[MAX_PLAYERS], bool:CG52Pending[MAX_PLAYERS];
new CG52Nonce[MAX_PLAYERS][33], CG52Account[MAX_PLAYERS][37], CG52Request[MAX_PLAYERS], CG52Serial;
forward CG52Timeout(playerid, const nonce[]);
forward CG52Result(index, response_code, data[]);
stock CG52Begin(playerid)
{
 CG52Approved[playerid]=false; CG52Pending[playerid]=false; CG52Request[playerid]=-1;CG52Account[playerid][0]=EOS;
 new seed[100], digest[65];format(seed,sizeof seed,"%d:%d:%d:%d:%d",gettime(),playerid,random(2147483647),random(2147483647),++CG52Serial);SHA256_PassHash(seed,"CidadeGrande52",digest,sizeof digest);strmid(CG52Nonce[playerid],digest,0,32,33);
 TogglePlayerControllable(playerid,false);SetTimerEx("CG52Timeout",60000,false,"is",playerid,CG52Nonce[playerid]);return 1;
}
stock CG52Challenge(playerid)
{
 if(CG52Approved[playerid]||CG52Pending[playerid])return 1;
 new name[MAX_PLAYER_NAME+1], packet[100];GetPlayerName(playerid,name,sizeof name);format(packet,sizeof packet,"[BCG:UI]GATE52|%s|%s",CG52Nonce[playerid],name);SendClientMessage(playerid,-1,packet);return 1;
}
stock CG52Verify(playerid,const ticket[])
{
 if(CG52Approved[playerid]||CG52Pending[playerid])return 1;
 if(strlen(ticket)!=64)return 1;
 for(new i=0;i<64;i++)if(!((ticket[i]>='0'&&ticket[i]<='9')||(ticket[i]>='a'&&ticket[i]<='f')))return 1;
 new name[MAX_PLAYER_NAME+1],body[180];GetPlayerName(playerid,name,sizeof name);format(body,sizeof body,"ticket=%s&nickname=%s&challenge=%s",ticket,name,CG52Nonce[playerid]);CG52Pending[playerid]=true;CG52Request[playerid]=++CG52Serial;
 HTTP(CG52Request[playerid],HTTP_POST,"127.0.0.1:18552/verify",body,"CG52Result");return 1;
}
public CG52Result(index,response_code,data[])
{
 new playerid=INVALID_PLAYER_ID;
 for(new i=0;i<MAX_PLAYERS;i++)if(IsPlayerConnected(i)&&CG52Pending[i]&&CG52Request[i]==index){playerid=i;break;}
 if(playerid==INVALID_PLAYER_ID)return 1;
 CG52Pending[playerid]=false;
 new gateState[4],nonce[33],name[25],account[37],own[25];GetPlayerName(playerid,own,sizeof own);
 if(response_code!=200||sscanf(data,"p<|>s[4]s[33]s[25]s[37]",gateState,nonce,name,account)||strcmp(gateState,"OK")||strcmp(nonce,CG52Nonce[playerid])||strcmp(name,own)||strlen(account)!=36)
 {SendClientMessage(playerid,-1,"[ERRO] Entrada nao autorizada. Abra Cidade Grande SA-MP e entre com Google.");Kick(playerid);return 1;}
 CG52Approved[playerid]=true;format(CG52Account[playerid],37,"%s",account);CallLocalFunction("cmd_bcgui31","is",playerid,"");return 1;
}
public CG52Timeout(playerid,const nonce[])
{
 if(IsPlayerConnected(playerid)&&!CG52Approved[playerid]&&!strcmp(nonce,CG52Nonce[playerid])){SendClientMessage(playerid,-1,"Use o APK Cidade Grande SA-MP atualizado para entrar.");Kick(playerid);}return 1;
}
stock CG52Reset(playerid){CG52Approved[playerid]=false;CG52Pending[playerid]=false;CG52Request[playerid]=-1;CG52Nonce[playerid][0]=EOS;CG52Account[playerid][0]=EOS;return 1;}
