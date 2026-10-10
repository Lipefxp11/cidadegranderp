import http from 'node:http';import {OAuth2Client} from 'google-auth-library';import {createAuth} from './auth.mjs';
const google=new OAuth2Client();const auth=createAuth(async(idToken,audience)=>{const ticket=await google.verifyIdToken({idToken,audience});return ticket.getPayload();});
const hits=new Map();
http.createServer(async(req,res)=>{
 res.setHeader('Content-Type','application/json');res.setHeader('Cache-Control','no-store');const send=(status,data)=>{res.writeHead(status);res.end(JSON.stringify(data));};
 const ip=req.socket.remoteAddress,t=Date.now();let h=hits.get(ip);if(!h||h.until<t)h={n:0,until:t+60000};hits.set(ip,h);if(++h.n>60)return send(429,{error:'rate_limited'});if(hits.size>10000)for(const [k,v]of hits)if(v.until<t)hits.delete(k);
 try{
  if(req.method==='GET'&&req.url==='/health')return send(200,{status:'ok',service:'BCG Google50'});
  if(req.method==='GET'&&req.url==='/session'){const token=(req.headers.authorization||'').replace(/^Bearer /,'');return send(200,auth.session(token));}
  if(req.method!=='POST'||!['/challenge','/google'].includes(req.url))return send(404,{error:'not_found'});
  let bytes=0,parts=[];for await(const part of req){bytes+=part.length;if(bytes>20000)return send(413,{error:'too_large'});parts.push(part);}const body=JSON.parse(Buffer.concat(parts).toString('utf8')||'{}');
  return send(200,req.url==='/challenge'?auth.challenge():await auth.login(body));
 }catch{return send(401,{error:'authentication_failed'});}
}).listen(Number(process.env.PORT||8080),'0.0.0.0');
