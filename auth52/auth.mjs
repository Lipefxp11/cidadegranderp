import {randomBytes,randomUUID,timingSafeEqual,createHash} from 'node:crypto';
import {existsSync,readFileSync,writeFileSync,renameSync,mkdirSync} from 'node:fs';
import {dirname} from 'node:path';
export const audience='872777251959-f549vaiqp4uefnih6ld5a0hpsnu7obrp.apps.googleusercontent.com';
export function createAuth(verify,{file='data/accounts.json',now=Date.now}={}){
 const challenges=new Map(),sessions=new Map();const sessionFile=file+'.sessions.json';
 const tokenKey=token=>createHash('sha256').update(String(token)).digest('hex');
 const saveSessions=()=>{mkdirSync(dirname(sessionFile),{recursive:true});writeFileSync(sessionFile+'.tmp',JSON.stringify(Object.fromEntries(sessions)),{mode:0o600});renameSync(sessionFile+'.tmp',sessionFile);};
 if(existsSync(sessionFile)){const stored=JSON.parse(readFileSync(sessionFile,'utf8'));for(const [key,value]of Object.entries(stored))if(/^[a-f0-9]{64}$/.test(key)&&typeof value.accountId==='string'&&Number.isFinite(value.expires)&&value.expires>now())sessions.set(key,value);}
 let accounts=existsSync(file)?JSON.parse(readFileSync(file,'utf8')):{};
 const random=()=>randomBytes(32).toString('base64url');
 function sweep(){let t=now();for(const [k,v]of challenges)if(v.expires<=t)challenges.delete(k);for(const [k,v]of sessions)if(v.expires<=t)sessions.delete(k);}
 return {
 challenge(){sweep();if(challenges.size>=10000)throw Error('busy');let challengeId=random(),nonce=random();challenges.set(challengeId,{nonce,expires:now()+180000});return {challengeId,nonce};},
 async login({challengeId,idToken}){sweep();let c=challenges.get(challengeId);challenges.delete(challengeId);if(!c||typeof idToken!=='string'||idToken.length>16000)throw Error('invalid');let p=await verify(idToken,audience);
  if(!p||typeof p.sub!=='string'||!p.sub||p.aud!==audience||!['https://accounts.google.com','accounts.google.com'].includes(p.iss)||!Number.isFinite(p.exp)||p.exp*1000<=now()||typeof p.nonce!=='string')throw Error('invalid');
  const a=Buffer.from(c.nonce),b=Buffer.from(p.nonce);if(a.length!==b.length||!timingSafeEqual(a,b))throw Error('invalid');
  let account=accounts[p.sub];if(!account){account={id:randomUUID(),created:new Date(now()).toISOString()};accounts[p.sub]=account;mkdirSync(dirname(file),{recursive:true});writeFileSync(file+'.tmp',JSON.stringify(accounts),{mode:0o600});renameSync(file+'.tmp',file);}
  let session=random();sessions.set(tokenKey(session),{accountId:account.id,expires:now()+30*86400000});saveSessions();return {session,accountId:account.id};
 },
 session(token){sweep();let s=sessions.get(tokenKey(token));if(!s)throw Error('invalid');if(s.expires-now()<29*86400000){s.expires=now()+30*86400000;saveSessions();}return {accountId:s.accountId};}
 };
}
