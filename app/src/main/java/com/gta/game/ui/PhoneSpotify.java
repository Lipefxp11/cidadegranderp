package com.gta.game.ui;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import org.json.JSONObject;
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.util.concurrent.*;
import java.util.function.Consumer;
import javax.crypto.*;
import javax.crypto.spec.GCMParameterSpec;

/** Official Spotify OAuth with PKCE. Credentials never enter JavaScript. */
public final class PhoneSpotify {
    private final Activity activity;
    private final Consumer<JSONObject> sink;
    private final ExecutorService worker=Executors.newSingleThreadExecutor();
    private final SharedPreferences vault;
    private final SpotifyEmbeddedPlayer embedded;
    private volatile String pendingTrack="";
    private volatile boolean embeddedReady=false, embeddedWanted=true;
    private final SecureRandom random=new SecureRandom();
    private volatile String owner="",access="",refresh="",device="";
    private volatile long expires=0,generation=0;
    private volatile ServerSocket callback;
    private String clientId="",redirect="";
    private static final String KEY_ALIAS="BCG38SpotifyVault";
    public PhoneSpotify(Activity a,Consumer<JSONObject> consumer){activity=a;sink=consumer;vault=a.getSharedPreferences("BCG38Spotify",0);embedded=new SpotifyEmbeddedPlayer(a,this::embeddedEvent);try(InputStream in=a.getAssets().open("bcg_spotify.json")){JSONObject config=new JSONObject(read(in,8192));clientId=config.getString("clientId");redirect=config.getString("redirectUri");}catch(Exception ignored){}}
    public synchronized void bind(String account){if(owner.equals(account))return;generation++;embedded.stop();embeddedReady=false;pendingTrack="";embeddedWanted=true;owner=account;access=refresh=device="";expires=0;closeCallback();if(!owner.isEmpty()){refresh=load(owner);emit(generation,"status",json("connected",!refresh.isEmpty()));}}
    public boolean isBoundTo(String account){return owner.equals(account);}
    public void reset(){bind("");}
    public void destroy(){reset();worker.shutdownNow();}
    private void closeCallback(){ServerSocket socket=callback;callback=null;if(socket!=null)try{socket.close();}catch(IOException ignored){}}
    private static String b64(byte[] value){return Base64.encodeToString(value,Base64.NO_WRAP|Base64.NO_PADDING|Base64.URL_SAFE);}
    private String randomText(){byte[] bytes=new byte[48];random.nextBytes(bytes);return b64(bytes);}
    private static String form(String s)throws Exception{return URLEncoder.encode(s,"UTF-8");}
    private static String read(InputStream input,int maximum)throws IOException{ByteArrayOutputStream out=new ByteArrayOutputStream();byte[] buffer=new byte[4096];int n;while((n=input.read(buffer))!=-1){if(out.size()+n>maximum)throw new IOException("Resposta grande demais");out.write(buffer,0,n);}return out.toString("UTF-8");}
    private static String readRequestLine(InputStream input)throws IOException{
        StringBuilder line=new StringBuilder();int value;
        while((value=input.read())!=-1){if(value=='\n')return line.toString().replace("\r","");if(line.length()>=8192)throw new IOException("Retorno grande demais");line.append((char)value);}
        return line.length()==0?null:line.toString();
    }
    private void emit(long g,String event,JSONObject data){activity.runOnUiThread(()->{if(g!=generation||owner.isEmpty())return;try{sink.accept(new JSONObject().put("type","spotify").put("event",event).put("data",data));}catch(Exception ignored){}});}
    private void fail(long g,Exception error){String message=error.getMessage();emit(g,"error",json("message",message==null?"Falha na conexão Spotify":message));}
    private static JSONObject json(String key,Object value){JSONObject object=new JSONObject();try{object.put(key,value);}catch(Exception ignored){}return object;}
    private JSONObject http(String method,String url,String body,String bearer)throws Exception{
        HttpURLConnection connection=(HttpURLConnection)new URL(url).openConnection();
        connection.setInstanceFollowRedirects(false);connection.setConnectTimeout(12000);connection.setReadTimeout(12000);connection.setRequestMethod(method);
        if(!bearer.isEmpty())connection.setRequestProperty("Authorization","Bearer "+bearer);
        if(body!=null){connection.setDoOutput(true);connection.setRequestProperty("Content-Type",url.contains("/api/token")?"application/x-www-form-urlencoded":"application/json");try(OutputStream out=connection.getOutputStream()){out.write(body.getBytes(StandardCharsets.UTF_8));}}
        try{int status=connection.getResponseCode();InputStream in=status>=400?connection.getErrorStream():connection.getInputStream();String text=in==null?"":read(in,1500000);
            if(status>=400){if(status==401)throw new IOException("Sessão Spotify expirou. Reconecte sua conta.");if(status==403)throw new IOException("Spotify recusou a operação. Confira Premium e usuários autorizados do aplicativo.");if(status==404)throw new IOException("Abra o Spotify em um dispositivo e inicie uma faixa.");if(status==429)throw new IOException("Limite do Spotify atingido. Aguarde antes de tentar novamente.");throw new IOException("Spotify respondeu com erro "+status);}
            return text.isEmpty()?new JSONObject():new JSONObject(text);
        }finally{connection.disconnect();}
    }
    private void keepToken(long g,String account,JSONObject token)throws Exception{
        synchronized(this){if(g!=generation||!owner.equals(account))return;access=token.getString("access_token");expires=System.currentTimeMillis()+token.optLong("expires_in",3600)*1000-30000;if(token.has("refresh_token")){refresh=token.getString("refresh_token");store(account,refresh);}}
    }
    private String token(long g)throws Exception{
        String account,renew; synchronized(this){if(g!=generation||owner.isEmpty())throw new IOException("Conta desconectada");if(!access.isEmpty()&&System.currentTimeMillis()<expires)return access;account=owner;renew=refresh;}
        if(renew.isEmpty())throw new IOException("Conecte sua conta Spotify primeiro.");
        JSONObject result=http("POST","https://accounts.spotify.com/api/token","grant_type=refresh_token&refresh_token="+form(renew)+"&client_id="+form(clientId),"");keepToken(g,account,result);
        synchronized(this){if(g!=generation||!owner.equals(account))throw new IOException("Conta mudou durante o pedido");return access;}
    }
    private void connect(long g)throws Exception{
        if(!clientId.matches("[a-fA-F0-9]{32}"))throw new IOException("Client ID Spotify não configurado.");
        Uri endpoint=Uri.parse(redirect);if(!"http".equals(endpoint.getScheme())||!"127.0.0.1".equals(endpoint.getHost())||!"/callback".equals(endpoint.getPath()))throw new IOException("Retorno Spotify inválido.");
        final String account=owner,state=randomText(),verifier=randomText();final int port=endpoint.getPort();
        ServerSocket server=new ServerSocket();server.bind(new InetSocketAddress(InetAddress.getByName("127.0.0.1"),port));server.setSoTimeout(300000);
        synchronized(this){if(g!=generation){server.close();return;}closeCallback();callback=server;}
        try{String challenge=b64(MessageDigest.getInstance("SHA-256").digest(verifier.getBytes(StandardCharsets.US_ASCII)));
            String url="https://accounts.spotify.com/authorize?response_type=code&client_id="+form(clientId)+"&redirect_uri="+form(redirect)+"&state="+form(state)+"&code_challenge_method=S256&code_challenge="+form(challenge)+"&scope="+form("streaming user-read-email user-read-private user-read-playback-state user-modify-playback-state user-read-currently-playing user-library-read");
            activity.runOnUiThread(()->{if(g==generation&&!owner.isEmpty())try{activity.startActivity(new Intent(Intent.ACTION_VIEW,Uri.parse(url)));}catch(Exception unavailable){closeCallback();fail(g,new IOException("Nenhum navegador disponível para o login Spotify."));}});
            long deadline=System.currentTimeMillis()+300000;
            while(g==generation&&System.currentTimeMillis()<deadline){try(Socket socket=server.accept()){socket.setSoTimeout(5000);String line=readRequestLine(socket.getInputStream());if(line==null||line.length()>8192)continue;String[] request=line.split(" ");if(request.length<2||!request[0].equals("GET"))continue;Uri result=Uri.parse("http://127.0.0.1"+request[1]);
                    boolean valid="/callback".equals(result.getPath())&&MessageDigest.isEqual(state.getBytes(StandardCharsets.US_ASCII),String.valueOf(result.getQueryParameter("state")).getBytes(StandardCharsets.US_ASCII));
                    String page=valid?"Retorno recebido. Volte ao Cidade Grande RP.":"Retorno inválido. Reabra o login pelo jogo.";byte[] pageBytes=page.getBytes(StandardCharsets.UTF_8);OutputStream output=socket.getOutputStream();output.write(("HTTP/1.1 "+(valid?"200 OK":"400 Bad Request")+"\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: "+pageBytes.length+"\r\nConnection: close\r\n\r\n").getBytes(StandardCharsets.US_ASCII));output.write(pageBytes);output.flush();
                    if(!valid)continue;if(result.getQueryParameter("error")!=null)throw new IOException("Login Spotify cancelado.");String code=result.getQueryParameter("code");if(code==null||code.length()>2048)throw new IOException("Retorno sem código.");
                    if(g!=generation||!owner.equals(account))return;JSONObject response=http("POST","https://accounts.spotify.com/api/token","grant_type=authorization_code&client_id="+form(clientId)+"&code="+form(code)+"&redirect_uri="+form(redirect)+"&code_verifier="+form(verifier),"");keepToken(g,account,response);emit(g,"status",json("connected",true));embedded.start();playback(g);return;
                }}
        }finally{synchronized(this){if(callback==server)callback=null;}server.close();}
    }
    private void playback(long g)throws Exception{JSONObject response=http("GET","https://api.spotify.com/v1/me/player",null,token(g));emit(g,"playback",response);}
    private void embeddedEvent(JSONObject event){
        final long g=generation;final String type=event.optString("event");if(owner.isEmpty())return;
        if(type.equals("error")){embedded.stop();pendingTrack="";embeddedReady=false;emit(g,"embedded",json("ready",false));emit(g,"error",json("message",event.optString("message")));return;}
        if(type.equals("offline")){embeddedReady=false;emit(g,"embedded",json("ready",false));return;}
        if(type.equals("volume")){emit(g,"volume",json("volume",event.optInt("volume",70)));return;}
        if(type.equals("playback")){JSONObject data=event.optJSONObject("data");if(data!=null)emit(g,"playback",data);return;}
        worker.execute(()->{try{
            if(g!=generation||owner.isEmpty())return;
            if(type.equals("tokenRequest")){String bearer=token(g);if(g==generation)embedded.token(bearer);return;}
            if(type.equals("ready")){
                String id=event.optString("device");if(!id.matches("[a-zA-Z0-9_-]{1,100}"))return;
                synchronized(this){if(g!=generation)return;if(embeddedWanted)device=id;embeddedReady=true;}
                emit(g,"embedded",json("ready",true));String uri=pendingTrack;pendingTrack="";
                if(!uri.isEmpty())playTrack(g,uri);
            }
        }catch(Exception error){pendingTrack="";fail(g,error);}});
    }
    private void playTrack(long g,String uri)throws Exception{
        String suffix=device.isEmpty()?"":"?device_id="+form(device);
        http("PUT","https://api.spotify.com/v1/me/player/play"+suffix,new JSONObject().put("uris",new org.json.JSONArray().put(uri)).toString(),token(g));playback(g);
    }
    public void request(JSONObject request){final long g=generation;if(owner.isEmpty())return;final String action=request.optString("action");worker.execute(()->{try{
        if(g!=generation||owner.isEmpty())return;
        if(action.equals("status")){emit(g,"status",json("connected",!refresh.isEmpty()));return;}
        if(action.equals("connect")){connect(g);return;}
        if(action.equals("disconnect")){synchronized(this){if(g==generation){vault.edit().remove(storageKey(owner)).apply();embedded.stop();embeddedReady=false;pendingTrack="";access=refresh="";expires=0;}}emit(g,"status",json("connected",false));return;}
        if(action.equals("embedded")){embeddedWanted=true;if(refresh.isEmpty())throw new IOException("Conecte o Spotify primeiro.");embedded.start();emit(g,"embedded",json("ready",embeddedReady));return;}
        if(action.equals("volume")){int volume=request.optInt("volume",-1);if(volume<0||volume>100)return;if(embeddedWanted){if(!embeddedReady)throw new IOException("Conecte o player do APK primeiro.");embedded.control("volume",volume);}else{http("PUT","https://api.spotify.com/v1/me/player/volume?volume_percent="+volume+(device.isEmpty()?"":"&device_id="+form(device)),null,token(g));emit(g,"volume",json("volume",volume));}return;}
        if(action.equals("search")){String q=request.optString("q").trim();if(q.length()<2||q.length()>100)return;emit(g,"search",http("GET","https://api.spotify.com/v1/search?type=track&limit=10&q="+form(q),null,token(g)));return;}
        if(action.equals("library")){emit(g,"library",http("GET","https://api.spotify.com/v1/me/tracks?limit=10",null,token(g)));return;}
        if(action.equals("devices")){emit(g,"devices",http("GET","https://api.spotify.com/v1/me/player/devices",null,token(g)));return;}
        if(action.equals("playback")){emit(g,"status",json("connected",true));embedded.start();playback(g);return;}
        if(action.equals("device")){String id=request.optString("id");if(!id.matches("[a-zA-Z0-9_-]{1,100}"))return;embeddedWanted=false;pendingTrack="";embedded.control("pause",0);device=id;http("PUT","https://api.spotify.com/v1/me/player",new JSONObject().put("device_ids",new org.json.JSONArray().put(id)).toString(),token(g));playback(g);return;}
        String suffix=device.isEmpty()?"":"?device_id="+form(device);
        if(action.equals("play")){String uri=request.optString("uri");if(!uri.matches("spotify:track:[A-Za-z0-9]{22}"))return;
            if(embeddedWanted&&!embeddedReady){pendingTrack=uri;embedded.start();emit(g,"embedded",json("ready",false));return;}
            playTrack(g,uri);return;}
        else if(embeddedWanted && (action.equals("resume")||action.equals("pause")||action.equals("next")||action.equals("prev")||action.equals("seek"))){
            if(!embeddedReady){embedded.start();throw new IOException("Aguarde a conexão do player do APK.");}
            int value=request.optInt("position",0);if(value<0||value>86400000)return;embedded.control(action,value);return;
        }
        else if(action.equals("resume")||action.equals("pause"))http("PUT","https://api.spotify.com/v1/me/player/"+(action.equals("resume")?"play":"pause")+suffix,null,token(g));
        else if(action.equals("next")||action.equals("prev"))http("POST","https://api.spotify.com/v1/me/player/"+(action.equals("prev")?"previous":"next")+suffix,null,token(g));
        else if(action.equals("seek")){long position=request.optLong("position",-1);if(position<0||position>86400000)return;http("PUT","https://api.spotify.com/v1/me/player/seek?position_ms="+position+(device.isEmpty()?"":"&device_id="+form(device)),null,token(g));}
        else return;playback(g);
    }catch(Exception error){fail(g,error);}});}
    private SecretKey key()throws Exception{KeyStore store=KeyStore.getInstance("AndroidKeyStore");store.load(null);if(!store.containsAlias(KEY_ALIAS)){KeyGenerator generator=KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES,"AndroidKeyStore");generator.init(new KeyGenParameterSpec.Builder(KEY_ALIAS,KeyProperties.PURPOSE_ENCRYPT|KeyProperties.PURPOSE_DECRYPT).setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build());generator.generateKey();}return (SecretKey)store.getKey(KEY_ALIAS,null);}
    private static String storageKey(String account)throws Exception{return b64(MessageDigest.getInstance("SHA-256").digest(account.getBytes(StandardCharsets.UTF_8)));}
    private void store(String account,String value)throws Exception{Cipher cipher=Cipher.getInstance("AES/GCM/NoPadding");cipher.init(Cipher.ENCRYPT_MODE,key());cipher.updateAAD(account.getBytes(StandardCharsets.UTF_8));vault.edit().putString(storageKey(account),b64(cipher.getIV())+"."+b64(cipher.doFinal(value.getBytes(StandardCharsets.UTF_8)))).apply();}
    private String load(String account){try{String stored=vault.getString(storageKey(account),"");String[] pieces=stored.split("\\.");if(pieces.length!=2)return "";Cipher cipher=Cipher.getInstance("AES/GCM/NoPadding");cipher.init(Cipher.DECRYPT_MODE,key(),new GCMParameterSpec(128,Base64.decode(pieces[0],Base64.URL_SAFE)));cipher.updateAAD(account.getBytes(StandardCharsets.UTF_8));return new String(cipher.doFinal(Base64.decode(pieces[1],Base64.URL_SAFE)),StandardCharsets.UTF_8);}catch(Exception ignored){return "";}}
}
