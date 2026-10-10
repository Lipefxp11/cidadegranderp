#if defined _bcg_voice52
 #endinput
#endif
#define _bcg_voice52
#include <sampvoice>
new SV_SLSTREAM:CG52Voice[MAX_PLAYERS];
new bool:CG52Speaking[MAX_PLAYERS];
new CG52VoiceTimer;
forward CG52VoiceTick();
forward CG52CanVoice(playerid);
stock CG52VoiceReset(playerid)
{
 if(CG52Voice[playerid])SvDeleteStream(CG52Voice[playerid]);CG52Voice[playerid]=SV_SLSTREAM:SV_NULL;CG52Speaking[playerid]=false;SvRemoveAllKeys(playerid);return 1;
}
stock CG52VoiceListeners(playerid)
{
 new Float:x,Float:y,Float:z;GetPlayerPos(playerid,x,y,z);
 foreach(new other:Player){
  if(other==playerid)continue;
  if(CallLocalFunction("CG52CanVoice","i",other)&&GetPlayerVirtualWorld(other)==GetPlayerVirtualWorld(playerid)&&GetPlayerInterior(other)==GetPlayerInterior(playerid)&&IsPlayerInRangeOfPoint(other,25.0,x,y,z)){if(!SvHasListenerInStream(CG52Voice[playerid],other))SvAttachListenerToStream(CG52Voice[playerid],other);}
  else if(SvHasListenerInStream(CG52Voice[playerid],other))SvDetachListenerFromStream(CG52Voice[playerid],other);
 }
 return 1;
}
public CG52VoiceTick()
{
 foreach(new playerid:Player){
  if(!CallLocalFunction("CG52CanVoice","i",playerid)){if(CG52Voice[playerid])CG52VoiceReset(playerid);continue;}
  if(!CG52Voice[playerid]&&SvGetVersion(playerid)&&SvHasMicro(playerid)){CG52Voice[playerid]=SvCreateSLStreamAtPlayer(25.0,playerid,0x57C99AFF,"Local");SvAddKey(playerid,0x42);}
  if(CG52Speaking[playerid])CG52VoiceListeners(playerid);
 }
 return 1;
}
public SV_VOID:OnPlayerActivationKeyPress(SV_UINT:playerid,SV_UINT:keyid)
{
 if(keyid!=0x42||!CG52Voice[playerid]||!CallLocalFunction("CG52CanVoice","i",playerid))return;
 CG52Speaking[playerid]=true;CG52VoiceListeners(playerid);SvAttachSpeakerToStream(CG52Voice[playerid],playerid);
}
public SV_VOID:OnPlayerActivationKeyRelease(SV_UINT:playerid,SV_UINT:keyid)
{
 if(keyid==0x42&&CG52Voice[playerid]){SvDetachSpeakerFromStream(CG52Voice[playerid],playerid);CG52Speaking[playerid]=false;}
}
