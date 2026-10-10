package com.gta.game.ui;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Color;
import android.graphics.RectF;
import android.net.Uri;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.content.Context;
import android.webkit.JavascriptInterface;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebView;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import org.json.JSONArray;
import org.json.JSONObject;
import java.nio.charset.StandardCharsets;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.io.ByteArrayInputStream;

/** Local Chromium interfaces. This is Android WebView, not a CEF runtime. */
public final class ChromiumUI {
    private final Activity activity;
    private final Surface web;
    private final PhoneSpotify spotify;
    private final LoginSessionVault loginVault;
    private final Access52 access52;
    private String loginAccount="";
    private boolean loginAttempted=false, loginPending=false;
    private int loginGeneration=0;
    private volatile String phoneAccount="",phoneNonce="";
    private volatile boolean phoneUnlocked=false;
    private final ArrayDeque<String> pending=new ArrayDeque<>();
    private volatile boolean ready=false;
    private boolean chatVisible=false;
    private boolean destroyed=false, paused=false, gotNativeHud=false, gotServerHud=false, gotAck=false;
    private long lastServerHudAt=0, lastHandshakeAt=0;
    private int connectionPhase=0;
    private final android.os.Handler recovery=new android.os.Handler(android.os.Looper.getMainLooper());
    private final Runnable heartbeat=new Runnable(){public void run(){
        if(destroyed)return;
        long now=android.os.SystemClock.elapsedRealtime();
        if(ready && !paused && connectionPhase>=3 && connectionPhase<=5 &&
           (lastServerHudAt==0 || now-lastServerHudAt>15000) && now-lastHandshakeAt>=5000){
            lastHandshakeAt=now;
            diagnostic("handshake retry; phase="+connectionPhase+" ready="+ready);
            diagnostic("handshake retry gerenciado pelo C++");
            Log.i("BCG_UI","Revalidando interface com a GameMode");
        }
        recovery.postDelayed(this,1000);
    }};
    private JSONObject currentDialog;
    private boolean nativeKeyboard=false;
    private android.webkit.ValueCallback<Uri[]> imageResult;
    private String imageOwner="",imageNonce="";
    private static final int PHONE_IMAGE=43822;
    private String latestHud, latestServerHud;
    private final ArrayList<RectF> regions=new ArrayList<>();
    private static native void nativeRequest(int op,int a,int b,int c,byte[] text);
    private void diagnostic(String message){UiDiagnostics.write(activity,message);}
    private boolean request(int op,int a,int b,int c,byte[] text){
        try {nativeRequest(op,a,b,c,text);return true;}
        catch(LinkageError unavailable){diagnostic("JNI unavailable: "+unavailable.getClass().getSimpleName()+" "+unavailable.getMessage());return false;}
    }
    private static byte[] bytes(String s){return s.getBytes(StandardCharsets.UTF_8);}

    @SuppressLint({"SetJavaScriptEnabled","AddJavascriptInterface"})
    public ChromiumUI(Activity activity){
        this.activity=activity;
        access52=new Access52(activity,command->request(2,0,0,0,bytes(command)));
        diagnostic("Chromium constructor V045");
        android.content.pm.PackageInfo provider=WebView.getCurrentWebViewPackage();
        diagnostic("WebView provider="+(provider==null?"unavailable":provider.packageName+" "+provider.versionName));
        loginVault=new LoginSessionVault(activity);
        spotify=new PhoneSpotify(activity,this::event);
        web=new Surface(activity);
        web.setBackgroundColor(Color.TRANSPARENT);
        web.setFocusable(true);
        web.setFocusableInTouchMode(true);
        web.setLayerType(View.LAYER_TYPE_HARDWARE,null);
        web.getSettings().setJavaScriptEnabled(true);
        web.getSettings().setDomStorageEnabled(false);
        web.getSettings().setAllowFileAccess(false);
        web.getSettings().setAllowContentAccess(true);
        web.getSettings().setAllowFileAccessFromFileURLs(false);
        web.getSettings().setAllowUniversalAccessFromFileURLs(false);
        web.getSettings().setSupportZoom(false);
        web.getSettings().setTextZoom(100);
        web.getSettings().setUseWideViewPort(true);
        web.getSettings().setMediaPlaybackRequiresUserGesture(true);
        web.addJavascriptInterface(new Bridge(),"BCG");
        web.setWebViewClient(new WebViewClient(){
            @Override public boolean onRenderProcessGone(WebView v,RenderProcessGoneDetail detail){
                diagnostic("renderer exited crash="+detail.didCrash());access52.close();destroyed=true;recovery.removeCallbacks(heartbeat);ready=false;pending.clear();phoneAccount=phoneNonce="";phoneUnlocked=false;spotify.destroy();request(0,0,0,0,bytes(""));request(6,0,0,0,bytes(""));
                request(2,0,0,0,bytes("/bcgui31 off"));
                web.setVisibility(View.GONE);
                if(activity instanceof com.gta.game.SAMP){com.gta.game.SAMP game=(com.gta.game.SAMP)activity;game.onChromiumUnavailable(currentDialog);if(currentDialog!=null)game.showNativeDialog(currentDialog.optInt("id"),currentDialog.optInt("style"),currentDialog.optString("title"),currentDialog.optString("text"),currentDialog.optString("left"),currentDialog.optString("right"));}
                if(web.getParent() instanceof android.view.ViewGroup)((android.view.ViewGroup)web.getParent()).removeView(web);
                web.destroy();return true;
            }
            @Override public void onPageFinished(WebView view,String url){
                diagnostic("page finished local="+local(Uri.parse(url)));
                if(!local(Uri.parse(url)))return;
                view.evaluateJavascript("Boolean(window.BCGUI && window.BCGUI.receive)", result->{
                    if("true".equals(result)) {
                        if(!ready)new Bridge().send("{\"op\":\"ready\"}");
                    } else {
                        diagnostic("page loaded but BCGUI missing; ui.js did not initialize");
                        Log.e("BCG_UI","Pagina carregou sem inicializar ui.js");
                        android.widget.Toast.makeText(activity,"A interface nao iniciou. Atualize o Android System WebView.",android.widget.Toast.LENGTH_LONG).show();
                    }
                });
            }
            @Override public void onReceivedError(WebView view,WebResourceRequest req,android.webkit.WebResourceError error){
                if(local(req.getUrl()))diagnostic("asset failed: "+req.getUrl().getPath()+" code="+error.getErrorCode()+" "+error.getDescription());
            }
            @Override public boolean shouldOverrideUrlLoading(WebView v,WebResourceRequest r){return !local(r.getUrl());}
            @Override public WebResourceResponse shouldInterceptRequest(WebView v,WebResourceRequest r){
                Uri uri=r.getUrl();
                if(local(uri))try{
                    String path=uri.getPath().substring("/assets/".length());
                    String mime=path.endsWith(".js")?"application/javascript":path.endsWith(".css")?"text/css":path.endsWith(".svg")?"image/svg+xml":"text/html";
                    return new WebResourceResponse(mime,"UTF-8",activity.getAssets().open(path));
                }catch(Exception missing){diagnostic("asset missing: "+uri.getPath()+" "+missing.getClass().getSimpleName());return new WebResourceResponse("text/plain","UTF-8",new ByteArrayInputStream(new byte[0]));}
                if("https".equals(uri.getScheme())&&"i.scdn.co".equals(uri.getHost()))return null;
                return new WebResourceResponse("text/plain","UTF-8",new ByteArrayInputStream(new byte[0]));
            }
        });
        web.setWebChromeClient(new android.webkit.WebChromeClient(){
            @Override public boolean onConsoleMessage(android.webkit.ConsoleMessage message){
                diagnostic("JS "+message.message()+" line="+message.lineNumber());
                Log.e("BCG_UI_JS",message.message()+" @"+message.sourceId()+":"+message.lineNumber());return true;
            }
            @Override public boolean onShowFileChooser(WebView view,android.webkit.ValueCallback<Uri[]> result,FileChooserParams params){
                if(!phoneUnlocked||phoneAccount.isEmpty())return false;
                if(imageResult!=null)imageResult.onReceiveValue(null);imageResult=result;imageOwner=phoneAccount;imageNonce=phoneNonce;
                IntentChooser();return true;
            }
        });
        activity.addContentView(web,new FrameLayout.LayoutParams(-1,-1));
        web.setZ(30);
        try(java.io.InputStream in=activity.getAssets().open("bcg_ui/index.html")){
            java.io.ByteArrayOutputStream html=new java.io.ByteArrayOutputStream();byte[] buffer=new byte[4096];int n;
            while((n=in.read(buffer))!=-1)html.write(buffer,0,n);
            web.loadDataWithBaseURL("https://appassets.androidplatform.net/assets/bcg_ui/",html.toString("UTF-8"),"text/html","UTF-8",null);
            diagnostic("bundled HTML loaded directly; no main-document network navigation");
        }catch(java.io.IOException missing){diagnostic("entry HTML failed: "+missing.getMessage());throw new IllegalStateException("Missing BCG interface",missing);}
        recovery.postDelayed(heartbeat,1000);
    }
    private void IntentChooser(){
        android.content.Intent intent=new android.content.Intent(android.content.Intent.ACTION_GET_CONTENT).setType("image/*").addCategory(android.content.Intent.CATEGORY_OPENABLE);
        try{activity.startActivityForResult(intent,PHONE_IMAGE);}catch(Exception unavailable){if(imageResult!=null)imageResult.onReceiveValue(null);imageResult=null;}
    }
    public boolean imageResult(int requestCode,int resultCode,android.content.Intent data){
        if(requestCode!=PHONE_IMAGE)return false;
        android.webkit.ValueCallback<Uri[]> callback=imageResult;imageResult=null;
        if(callback!=null)callback.onReceiveValue(resultCode==Activity.RESULT_OK&&data!=null&&data.getData()!=null&&phoneUnlocked&&imageOwner.equals(phoneAccount)&&imageNonce.equals(phoneNonce)?new Uri[]{data.getData()}:null);
        imageOwner=imageNonce="";return true;
    }
    private boolean local(Uri uri){return "https".equals(uri.getScheme())&&"appassets.androidplatform.net".equals(uri.getHost())&&uri.getPath()!=null&&uri.getPath().startsWith("/assets/bcg_ui/")&&!uri.getPath().contains("..");}
    public boolean isReady(){return ready;}
    public void event(JSONObject value){event(value.toString());}
    public void event(String json){
        activity.runOnUiThread(()->{
            try{
                JSONObject incoming=new JSONObject(json);
                if(incoming.optString("type").equals("nativeHud")&&!gotNativeHud){gotNativeHud=true;diagnostic("native HUD callback received");}
                if(incoming.optString("type").equals("serverHud")){lastServerHudAt=android.os.SystemClock.elapsedRealtime();if(!gotServerHud){gotServerHud=true;diagnostic("GameMode HUD received");}}
                if(incoming.optString("type").equals("nativeHud"))latestHud=json;
                if(incoming.optString("type").equals("serverHud"))latestServerHud=json;
                if(incoming.optString("type").equals("sessionReset")){access52.reset();latestHud=null;gotNativeHud=gotServerHud=gotAck=false;diagnostic("session reset");loginAccount="";loginAttempted=loginPending=false;loginGeneration++;lastServerHudAt=lastHandshakeAt=0; latestServerHud=null;phoneAccount=phoneNonce="";phoneUnlocked=false;spotify.reset();}
                if(incoming.optString("type").equals("serverUi")){
                    String[] packet=incoming.optString("text").split("\\|",-1);
                    if(packet.length==3&&packet[0].equals("GATE52")){access52.grant(packet[1],packet[2]);return;}
                    if(packet.length>=2 && packet[0].equals("AUTH")){
                        if(packet[1].equals("REQUEST") && packet.length>=4){
                            loginAccount=packet[3]+"/"+packet[2];
                            if(!loginAttempted){loginAttempted=true;String token=loginVault.load(loginAccount);
                                if(!token.isEmpty()){loginPending=true;final int current=++loginGeneration;request(2,0,0,0,bytes("/bcgauth42 resume "+token));
                                    recovery.postDelayed(()->{if(loginPending&&current==loginGeneration){loginPending=false;if(currentDialog!=null)event(currentDialog);}},8000);}
                            }
                        }else if(packet[1].equals("OK")){
                            loginPending=false;loginGeneration++;String token=loginVault.remember(loginAccount);
                            if(!loginAccount.isEmpty()&&!token.isEmpty())request(2,0,0,0,bytes("/bcgauth42 remember "+token));
                        }else if(packet[1].equals("FAIL")){
                            loginPending=false;loginGeneration++;loginVault.remove(loginAccount);if(currentDialog!=null)event(currentDialog);
                        }
                    }
                    if(incoming.optString("type").equals("serverUi") && packet.length>=2 && packet[0].equals("ACK")&&!gotAck){gotAck=true;diagnostic("GameMode ACK received");}
                    if(packet.length>=7 && packet[0].equals("P38") && packet[1].equals("hello")){phoneNonce=packet[2];phoneAccount=packet[6]+"/"+packet[3];phoneUnlocked=false;if(!spotify.isBoundTo(phoneAccount))spotify.reset();}
                    if(packet.length>=6 && packet[0].equals("P38") && packet[1].equals("end") && packet[2].equals(phoneNonce)){
                        if(packet[3].equals("ready")&&!phoneAccount.isEmpty()){phoneUnlocked=true;spotify.bind(phoneAccount);}
                        if(packet[3].equals("locked")){phoneUnlocked=false;spotify.reset();}
                    }
                }
            }catch(Exception ignored){}
            try{JSONObject d=new JSONObject(json);if(d.optString("type").equals("dialog")&&d.optInt("id")==2&&loginPending)return;}catch(Exception ignored){}
            if(!ready){
                if(json.contains("\"type\":\"nativeHud\"")){latestHud=json;return;}
                if(json.contains("\"type\":\"serverHud\"")){latestServerHud=json;return;}
                if(pending.size()>=32)pending.removeFirst();pending.addLast(json);return;
            }
            if(json.contains("\"type\":\"chatInput\"") && json.contains("\"open\":true")) { chatVisible=true; web.requestFocus(); }
            if(json.contains("\"type\":\"chatInput\"") && json.contains("\"open\":false")) {
                chatVisible=false;
                InputMethodManager ime=(InputMethodManager)activity.getSystemService(Context.INPUT_METHOD_SERVICE);
                if(ime!=null) ime.hideSoftInputFromWindow(web.getWindowToken(),0);
                web.clearFocus();
            }
            web.evaluateJavascript("window.BCGUI.receive("+json+");",null);
        });
    }
    public void dialog(int id,int style,String title,String text,String left,String right){
        try{
            JSONObject value=new JSONObject().put("type","dialog").put("id",id==65535?-1:id).put("style",style).put("title",title).put("text",text).put("left",left).put("right",right);
            currentDialog=id<0||id==65535?null:value;event(value);
        }catch(Exception e){Log.e("BCG_UI","Falha ao preparar dialogo",e);}
    }
    private void startHandshake(){
        if(ready&&!paused&&connectionPhase>=3&&connectionPhase<=5){diagnostic("handshake gerenciado pelo C++");}
    }
    public void connection(int phase,String message){connectionPhase=phase;if(phase==3||phase==5)startHandshake();diagnostic("connection phase="+phase);try{event(new JSONObject().put("type","connection").put("phase",phase).put("text",message));}catch(Exception e){Log.e("BCG_UI","Falha no estado da conexao",e);}}
    public void pause(boolean value){paused=value;if(value){request(5,0,0,0,bytes(""));request(5,1,0,0,bytes(""));chatVisible=false;request(2,0,0,0,bytes(""));request(3,66,0,0,bytes(""));}web.setVisibility(value?View.GONE:View.VISIBLE);if(value)web.onPause();else {web.onResume();if(ready){if(latestHud!=null)event(latestHud);if(latestServerHud!=null)event(latestServerHud);event("{\"type\":\"restoreHud\"}");startHandshake();}}}
    public void nativeKeyboard(boolean shown){activity.runOnUiThread(()->{nativeKeyboard=shown;web.setVisibility(shown?View.INVISIBLE:View.VISIBLE);});}
    public void back(){event("{\"type\":\"back\"}");}
    public void destroy(){access52.close();destroyed=true;recovery.removeCallbacks(heartbeat);spotify.destroy();request(0,0,0,0,bytes(""));request(3,66,0,0,bytes(""));web.removeJavascriptInterface("BCG");web.destroy();}

    private final class Surface extends WebView {
        private boolean gesture=false;
        Surface(Activity a){super(a);}
        @Override public boolean onTouchEvent(MotionEvent event){
            if(event.getActionMasked()==MotionEvent.ACTION_DOWN){
                gesture=!nativeKeyboard && (chatVisible || currentDialog!=null);float x=event.getX()/getWidth(),y=event.getY()/getHeight();
                for(RectF region:regions)if(!nativeKeyboard && region.contains(x,y)){gesture=true;break;}
            }
            if(!gesture)return false;
            boolean handled=super.onTouchEvent(event);
            if(event.getActionMasked()==MotionEvent.ACTION_UP||event.getActionMasked()==MotionEvent.ACTION_CANCEL)gesture=false;
            return handled;
        }
    }
    private final class Bridge {
        @JavascriptInterface public void send(String raw){
            if(raw==null||raw.length()>8192)return;
            try{
                JSONObject obj=new JSONObject(raw);String op=obj.optString("op");
                if(op.equals("ready")){activity.runOnUiThread(()->{diagnostic("JS ready bridge received");if(!request(0,1,0,0,bytes(""))){ready=false;return;}ready=true;if(activity instanceof com.gta.game.SAMP)((com.gta.game.SAMP)activity).onChromiumReady();diagnostic("native ready queued");startHandshake();while(!pending.isEmpty())event(pending.removeFirst());if(latestHud!=null)event(latestHud);if(latestServerHud!=null)event(latestServerHud);if(currentDialog!=null)event(currentDialog);});return;}
                if(op.equals("regions")){JSONArray list=obj.getJSONArray("list");activity.runOnUiThread(()->{regions.clear();for(int i=0;i<list.length()&&i<200;i++){JSONArray r=list.optJSONArray(i);if(r!=null&&r.length()==4)regions.add(new RectF((float)r.optDouble(0),(float)r.optDouble(1),(float)r.optDouble(2),(float)r.optDouble(3)));}});return;}
                if(!ready)return;
                if(op.equals("phoneRequest")){String text=obj.optString("text");if(!phoneAccount.isEmpty()&&text.startsWith("/bcgphone38 "+phoneNonce+"|")&&text.length()<=144&&text.matches("/bcgphone38 [0-9]+\\|[0-9]+\\|[a-z]+\\|[0-9a-f]+\\|[0-9a-f]+"))request(2,0,0,0,bytes(text));}
                else if(op.equals("phoneClose")){phoneUnlocked=false;phoneAccount=phoneNonce="";}
                else if(op.equals("spotify")){if(phoneUnlocked&&!phoneAccount.isEmpty())spotify.request(obj);}
                else if(op.equals("command")){String text=obj.optString("text");if(text.matches("/bcgui36 (weapon|phone|motor|lights|trancar|gps|mochila|inventory|inv close|(use|send|drop|assign|quick) [0-9]{1,2} [0-9]{1,2} -?[0-9]{1,3} -?[0-9]|look|turn [0-7]|preview [0-4]|sound [01])"))request(2,0,0,0,bytes(text));}
                else if(op.equals("dialog")){int id=obj.optInt("id",-1),button=obj.optInt("button",0),item=obj.optInt("item",-1);String text=obj.optString("text");if(id>=0&&id<=32767&&(button==0||button==1)&&text.length()<=255){currentDialog=null;request(1,id,button,item,bytes(text));}}
                else if(op.equals("control")){int key=obj.optInt("key",-1);if(key>=0&&key<2)request(5,key,obj.optBoolean("down")?1:0,0,bytes(""));}
                else if(op.equals("modal")){request(6,obj.optBoolean("open")?1:0,0,0,bytes(""));}
                else if(op.equals("ptt")){int key=obj.optInt("key",66);if(key==66)request(3,key,obj.optBoolean("down")?1:0,0,bytes(""));}
                else if(op.equals("textdraw")){request(4,obj.optInt("id",65535),0,0,bytes(""));}
            }catch(Exception e){Log.w("BCG_UI","Evento de interface rejeitado");}
        }
    }
}
