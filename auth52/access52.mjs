import {randomBytes,timingSafeEqual} from 'node:crypto';
export function access52({session,secret,now=Date.now}){
 if(!/^[0-9a-f]{64}$/.test(secret||''))throw Error('BCG52_SERVER_SECRET deve conter 64 caracteres hexadecimais');
 const tickets=new Map();const sweep=()=>{for(const[k,v]of tickets)if(v.expires<=now())tickets.delete(k);};
 return {
 issue(token,{nickname,challenge,version,packageName}){sweep();if(version!==53||packageName!=='com.cidadegranderp')throw Error('unsupported_client');const account=session(token);if(!/^[A-Za-z0-9_]{3,24}$/.test(nickname||'')||!/^[0-9A-Fa-f]{32}$/.test(challenge||''))throw Error('invalid');if([...tickets.values()].filter(v=>v.accountId===account.accountId).length>=6)throw Error('busy');if(tickets.size>=10000)throw Error('busy');let ticket=randomBytes(32).toString('hex');tickets.set(ticket,{accountId:account.accountId,nickname,challenge,expires:now()+30000});return {ticket,expiresIn:30};},
 consume(key,{ticket,nickname,challenge}){if(typeof key!=='string'||key.length!==secret.length||!timingSafeEqual(Buffer.from(key),Buffer.from(secret)))throw Error('unauthorized');sweep();let v=tickets.get(ticket);if(!v||v.nickname!==nickname||v.challenge!==challenge)throw Error('invalid');tickets.delete(ticket);return {nickname,challenge,accountId:v.accountId};}
 };
}
