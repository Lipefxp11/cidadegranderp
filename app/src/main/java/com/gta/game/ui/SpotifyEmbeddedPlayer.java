package com.gta.game.ui;

import android.app.Activity;
import android.graphics.Color;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.ConsoleMessage;
import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import org.json.JSONObject;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.function.Consumer;

/** Dedicated official Spotify SDK surface. No game bridge or access to player records. */
final class SpotifyEmbeddedPlayer {
    private static final String ENTRY="https://appassets.androidplatform.net/assets/bcg_spotify/player.html";
    private final Activity activity;
    private final Consumer<JSONObject> sink;
    private WebView web;
    private int generation;
    private boolean playerReady;
    SpotifyEmbeddedPlayer(Activity activity,Consumer<JSONObject> sink){this.activity=activity;this.sink=sink;}
    boolean started(){return web!=null;}
    static boolean allowed(Uri uri){
        if(!"https".equals(uri.getScheme())||uri.getUserInfo()!=null)return false;
        String host=uri.getHost();if(host==null)return false;
        return host.equals("sdk.scdn.co")||host.endsWith(".scdn.co")||host.equals("scdn.co")||host.equals("spotify.com")||host.endsWith(".spotify.com")||host.equals("spotifycdn.com")||host.endsWith(".spotifycdn.com")||host.equals("appassets.androidplatform.net")&&ENTRY.equals(uri.toString());
    }
    void start(){activity.runOnUiThread(()->{
        if(web!=null)return;playerReady=false;final int current=++generation;
        WebView player=new WebView(activity);web=player;player.setBackgroundColor(Color.TRANSPARENT);player.setAlpha(.01f);player.setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS);player.setFocusable(false);
        player.getSettings().setJavaScriptEnabled(true);player.getSettings().setDomStorageEnabled(true);player.getSettings().setAllowFileAccess(false);player.getSettings().setAllowContentAccess(false);player.getSettings().setMediaPlaybackRequiresUserGesture(false);
        player.setWebChromeClient(new WebChromeClient(){
            @Override public boolean onConsoleMessage(ConsoleMessage message){
                if(current!=generation||!ENTRY.equals(message.sourceId())||!message.message().startsWith("BCGSP42:"))return true;
                try{JSONObject event=new JSONObject(message.message().substring(8));if(event.optString("event").equals("ready"))playerReady=true;if(event.toString().length()<=8192)sink.accept(event);}catch(Exception ignored){}
                return true; // Never log access tokens or third-party console output.
            }
            @Override public void onPermissionRequest(PermissionRequest request){
                activity.runOnUiThread(()->{if(current!=generation){request.deny();return;}Uri origin=request.getOrigin();
                    if(!"https".equals(origin.getScheme())||!("sdk.scdn.co".equals(origin.getHost())||"appassets.androidplatform.net".equals(origin.getHost())&&web==player&&ENTRY.equals(player.getUrl()))){request.deny();return;}
                    for(String resource:request.getResources())if(!PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID.equals(resource)){request.deny();return;}
                    request.grant(new String[]{PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID});
                });
            }
        });
        player.setWebViewClient(new WebViewClient(){
            @Override public boolean shouldOverrideUrlLoading(WebView view,WebResourceRequest request){return request.isForMainFrame() || !allowed(request.getUrl());}
            @Override public WebResourceResponse shouldInterceptRequest(WebView view,WebResourceRequest request){
                if(allowed(request.getUrl()))return null;return new WebResourceResponse("text/plain","UTF-8",403,"Blocked",java.util.Collections.emptyMap(),new ByteArrayInputStream(new byte[0]));
            }
            @Override public void onReceivedError(WebView view,WebResourceRequest request,android.webkit.WebResourceError error){
                if(current==generation&&request.isForMainFrame())sendError("Não foi possível carregar o player Spotify.");
            }
            @Override public boolean onRenderProcessGone(WebView view,android.webkit.RenderProcessGoneDetail detail){stop();sendError("O player Spotify foi interrompido. Abra Onda novamente.");return true;}
        });
        ViewGroup content=activity.findViewById(android.R.id.content);if(content!=null)content.addView(player,new FrameLayout.LayoutParams(1,1));
        try(InputStream input=activity.getAssets().open("bcg_spotify/player.html")){
            byte[] bytes=new byte[32768];int n=input.read(bytes);if(n<=0)throw new java.io.IOException();player.loadDataWithBaseURL(ENTRY,new String(bytes,0,n,StandardCharsets.UTF_8),"text/html","UTF-8",ENTRY);
        }catch(Exception error){stop();sendError("Player Spotify ausente no APK.");}
        new android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(()->{if(current==generation&&web==player&&!playerReady){stop();sendError("O player Spotify não respondeu. Confira a conexão e reautorize sua conta.");}},30000);
    });}
    private void sendError(String message){try{sink.accept(new JSONObject().put("event","error").put("message",message));}catch(Exception ignored){}}
    void token(String value){evaluate("window.BCGSpotifyPlayer&&window.BCGSpotifyPlayer.token("+JSONObject.quote(value)+");");}
    void control(String action,int value){evaluate("window.BCGSpotifyPlayer&&window.BCGSpotifyPlayer.control("+JSONObject.quote(action)+","+value+");");}
    private void evaluate(String script){activity.runOnUiThread(()->{if(web!=null&&ENTRY.equals(web.getUrl()))web.evaluateJavascript(script,null);});}
    void stop(){activity.runOnUiThread(()->{generation++;WebView old=web;web=null;if(old==null)return;old.stopLoading();if(old.getParent() instanceof ViewGroup)((ViewGroup)old.getParent()).removeView(old);old.destroy();});}
}
