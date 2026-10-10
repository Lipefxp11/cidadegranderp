package com.gta.launcher.activity;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.CancellationSignal;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.view.View;
import android.widget.*;
import androidx.credentials.*;
import androidx.credentials.exceptions.GetCredentialException;
import com.google.android.libraries.identity.googleid.*;
import com.gta.game.R;
import org.json.JSONObject;
import java.net.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.*;

/** Google account chooser + server validation. Never authenticates a GM account by nickname. */
public final class GoogleLogin50 extends Activity {
 private static final String WEB="872777251959-f549vaiqp4uefnih6ld5a0hpsnu7obrp.apps.googleusercontent.com";
 private final ExecutorService worker=Executors.newSingleThreadExecutor();
 private CancellationSignal cancellation;
 private TextView status;private Button button;private boolean busy;
 private GoogleSession52 vault(){return new GoogleSession52(this);}
 private int dp(float value){return Math.round(value*getResources().getDisplayMetrics().density);}
 @Override public void onCreate(Bundle state){super.onCreate(state);getWindow().getDecorView().setSystemUiVisibility(5894);
  try{ClientIdentity53.verify(this);}catch(Exception e){drawLoading();status.setText("Instale o APK oficial Cidade Grande SA-MP.");return;}
  if(vault().load().isEmpty())draw();else {drawLoading();checkSavedSession();}
 }
 private void drawLoading(){
  FrameLayout root=new FrameLayout(this);root.setBackgroundColor(0xff031020);
  ImageView art=new ImageView(this);art.setImageResource(R.drawable.login_background50);art.setScaleType(ImageView.ScaleType.CENTER_CROP);root.addView(art,new FrameLayout.LayoutParams(-1,-1));
  View shade=new View(this);shade.setBackgroundColor(0xb5031020);root.addView(shade,new FrameLayout.LayoutParams(-1,-1));
  LinearLayout content=new LinearLayout(this);content.setOrientation(1);content.setGravity(android.view.Gravity.CENTER);content.setPadding(dp(24),dp(20),dp(24),dp(20));root.addView(content,new FrameLayout.LayoutParams(-1,-1));
  TextView title=label("CIDADE GRANDE SA-MP",24,Color.WHITE);title.setTypeface(null,Typeface.BOLD);content.addView(title);
  ProgressBar progress=new ProgressBar(this);LinearLayout.LayoutParams pm=new LinearLayout.LayoutParams(dp(32),dp(32));pm.topMargin=dp(20);content.addView(progress,pm);
  status=label("Carregando sua conta…",13,0xffc6d3e2);status.setPadding(0,dp(14),0,dp(10));content.addView(status);
  button=new Button(this);button.setAllCaps(false);button.setText("Tentar novamente");button.setVisibility(View.GONE);content.addView(button);button.setOnClickListener(v->checkSavedSession());setContentView(root);
 }
 private void checkSavedSession(){if(busy)return;setBusy(true,"Carregando sua conta…");worker.execute(()->{
  try{request("GET","/session",null,vault().load());runOnUiThread(this::open);}
  catch(AuthStatus53 e){runOnUiThread(()->{if(e.code==401){setBusy(false,"Renove a sessão da conta salva.");button.setText("Continuar com Google");button.setVisibility(View.VISIBLE);button.setOnClickListener(v->signIn());}else {setBusy(false,"Serviço temporariamente indisponível. Sua conta continua salva.");button.setVisibility(View.VISIBLE);}});}
  catch(Exception e){runOnUiThread(()->{setBusy(false,"Sem conexão com o serviço. Sua conta continua salva.");button.setVisibility(View.VISIBLE);});}
 });}
 private static final class AuthStatus53 extends IOException{final int code;AuthStatus53(int c){super("Serviço de login indisponível ("+c+").");code=c;}}
 private void draw(){
  FrameLayout root=new FrameLayout(this);root.setBackgroundColor(Color.rgb(3,12,24));
  ImageView art=new ImageView(this);art.setImageResource(R.drawable.login_background50);art.setScaleType(ImageView.ScaleType.CENTER_CROP);root.addView(art,new FrameLayout.LayoutParams(-1,-1));
  View shade=new View(this);shade.setBackground(new GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT,new int[]{0xc0031020,0x60031020,0x00031020}));root.addView(shade,new FrameLayout.LayoutParams(-1,-1));
  int height=getResources().getConfiguration().screenHeightDp;boolean compact=height<390;
  LinearLayout panel=new LinearLayout(this);panel.setOrientation(1);panel.setPadding(dp(30),dp(12),dp(24),dp(12));panel.setGravity(android.view.Gravity.CENTER_VERTICAL);
  FrameLayout.LayoutParams box=new FrameLayout.LayoutParams(getResources().getDisplayMetrics().widthPixels*46/100,-1);box.bottomMargin=dp(50);root.addView(panel,box);
  TextView title=label("CIDADE GRANDE SA-MP",compact?21:25,Color.WHITE);title.setTypeface(null,Typeface.BOLD);panel.addView(title);
  TextView description=label("Entre com sua conta Google.\nAcesse o launcher do servidor.\nEscolha onde quer jogar.\nAjuste suas preferências.\nComece sua história na cidade.",compact?11:12,0xffb6c8dd);LinearLayout.LayoutParams dm=new LinearLayout.LayoutParams(-1,-2);dm.topMargin=dp(12);panel.addView(description,dm);
  button=new Button(this);button.setText("Entrar com Google  →");button.setAllCaps(false);button.setTextSize(14);button.setTextColor(Color.WHITE);
  GradientDrawable bg=new GradientDrawable();bg.setColor(0xff1351a0);bg.setCornerRadius(dp(9));bg.setStroke(dp(1),0xff83b7ff);button.setBackground(bg);
  LinearLayout.LayoutParams bm=new LinearLayout.LayoutParams(-1,dp(48));bm.topMargin=dp(16);panel.addView(button,bm);button.setOnClickListener(v->signIn());
  status=label("",11,0xffb6c8dd);status.setPadding(0,dp(6),0,0);status.setVisibility(View.GONE);panel.addView(status);
  LinearLayout footer=new LinearLayout(this);footer.setOrientation(1);footer.setPadding(dp(30),0,dp(20),dp(8));
  footer.addView(label("© 2026 Interface Cidade Grande SA-MP",9,0xffadbaca));
  TextView terms=label("Termos Cidade Grande SA-MP",10,0xffcad8ed);terms.setPadding(0,dp(6),0,dp(4));terms.setOnClickListener(v->showTerms(this));footer.addView(terms);
  root.addView(footer,new FrameLayout.LayoutParams(-1,-2,android.view.Gravity.BOTTOM));setContentView(root);
 }
 public static void showTerms(Activity activity){
  android.app.AlertDialog dialog=new android.app.AlertDialog.Builder(activity).setTitle("Termos Cidade Grande SA-MP").setMessage("O login Google identifica sua conta no launcher. O serviço valida essa identificação e mantém um identificador de conta.\n\nA vinculação ao personagem da gamemode ainda é uma etapa separada. Não compartilhe sua conta.\n\nGoogle é uma marca da Google LLC. SA-MP e GTA pertencem aos respectivos titulares. A arte de fundo foi reconstruída a partir da referência fornecida. O copyright indicado refere-se à interface Cidade Grande.\n\nDúvidas e informações sobre o servidor: cidadegranderp.discloud.dev").setPositiveButton("Fechar",null).create();dialog.show();
 }
 private TextView label(String text,int size,int color){TextView t=new TextView(this);t.setText(text);t.setTextSize(size);t.setTextColor(color);return t;}
 private void setBusy(boolean value,String text){if(isFinishing()||isDestroyed())return;busy=value;button.setEnabled(!value);status.setText(text);status.setVisibility(text.isEmpty()?View.GONE:View.VISIBLE);}
 private String endpoint()throws IOException{String url=getString(R.string.google_auth50_url).trim();if(!url.startsWith("https://")||url.endsWith("example.com"))throw new IOException("O serviço de login ainda precisa ser configurado.");return url.replaceAll("/+$","");}
 private void signIn(){if(busy)return;setBusy(true,"Preparando login seguro…");worker.execute(()->{try{JSONObject c=request("POST","/challenge",new JSONObject(),null);String id=c.getString("challengeId"),nonce=c.getString("nonce");runOnUiThread(()->choose(id,nonce));}catch(Exception e){runOnUiThread(()->setBusy(false,e.getMessage()==null?"Não foi possível conectar ao serviço de login.":e.getMessage()));}});}
 private void choose(String challenge,String nonce){if(isFinishing()||isDestroyed())return;
  GetSignInWithGoogleOption option=new GetSignInWithGoogleOption.Builder(WEB).setNonce(nonce).build();GetCredentialRequest req=new GetCredentialRequest.Builder().addCredentialOption(option).build();cancellation=new CancellationSignal();
  CredentialManager.create(this).getCredentialAsync(this,req,cancellation,getMainExecutor(),new CredentialManagerCallback<GetCredentialResponse,GetCredentialException>(){
   @Override public void onResult(GetCredentialResponse result){try{Credential credential=result.getCredential();if(!(credential instanceof CustomCredential))throw new IOException("Resposta Google incompatível.");GoogleIdTokenCredential google=GoogleIdTokenCredential.createFrom(((CustomCredential)credential).getData());exchange(google.getIdToken(),challenge);}catch(Exception e){setBusy(false,"Não foi possível obter a identificação Google. Tente novamente.");}}
   @Override public void onError(GetCredentialException e){setBusy(false,"Login não concluído. Toque no botão para tentar novamente.");}
  });
 }
 private void exchange(String idToken,String challenge){if(isFinishing()||isDestroyed())return;setBusy(true,"Validando sua conta…");worker.execute(()->{try{JSONObject body=new JSONObject().put("idToken",idToken).put("challengeId",challenge);JSONObject answer=request("POST","/google",body,null);String session=answer.getString("session");if(session.length()<32)throw new IOException("Resposta inválida do servidor.");vault().save(session);runOnUiThread(this::open);}catch(Exception e){runOnUiThread(()->setBusy(false,"Não foi possível validar sua conta no servidor. Tente novamente."));}});}
 private void open(){if(isFinishing()||isDestroyed())return;startActivity(new Intent(this,MainActivity.class));finish();}
 private JSONObject request(String method,String path,JSONObject body,String token)throws Exception{
  URL url=new URL(endpoint()+path);HttpURLConnection c=(HttpURLConnection)url.openConnection();c.setConnectTimeout(10000);c.setReadTimeout(15000);c.setInstanceFollowRedirects(false);c.setRequestMethod(method);c.setRequestProperty("Accept","application/json");if(token!=null)c.setRequestProperty("Authorization","Bearer "+token);
  try{if(body!=null){c.setDoOutput(true);c.setRequestProperty("Content-Type","application/json");try(OutputStream out=c.getOutputStream()){out.write(body.toString().getBytes(StandardCharsets.UTF_8));}}int code=c.getResponseCode();if(code!=200)throw new AuthStatus53(code);try(InputStream in=c.getInputStream()){ByteArrayOutputStream out=new ByteArrayOutputStream();byte[] b=new byte[4096];int n;while((n=in.read(b))!=-1){if(out.size()+n>65536)throw new IOException("Resposta excessiva.");out.write(b,0,n);}return new JSONObject(out.toString("UTF-8"));}}finally{c.disconnect();}
 }
 @Override protected void onDestroy(){if(cancellation!=null)cancellation.cancel();worker.shutdownNow();super.onDestroy();}
}
