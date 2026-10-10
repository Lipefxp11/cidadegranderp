package com.gta.game.ui;
import android.app.Activity;import com.gta.launcher.activity.GoogleSession52;import org.json.JSONObject;import java.util.concurrent.*;import java.util.function.Consumer;
final class Access52 {
 private final Activity activity;private final Consumer<String> send;private final ExecutorService worker=Executors.newSingleThreadExecutor();private String nonce="";private boolean closed;
 Access52(Activity a,Consumer<String>s){activity=a;send=s;}
 void grant(String challenge,String nickname){if(closed||challenge.equals(nonce)||!challenge.matches("[a-fA-F0-9]{32}")||!nickname.matches("[A-Za-z0-9_]{3,24}"))return;String own=activity.getSharedPreferences("bcg_client",0).getString("nickname","");if(!own.equals(nickname))return;nonce=challenge;
 worker.execute(()->{try{com.gta.launcher.activity.ClientIdentity53.verify(activity);JSONObject v=new GoogleSession52(activity).request("/grant52",new JSONObject().put("challenge",challenge).put("nickname",nickname).put("version",53).put("packageName",activity.getPackageName()));String ticket=v.getString("ticket");if(!ticket.matches("[a-f0-9]{64}"))throw new Exception();activity.runOnUiThread(()->{if(!closed&&nonce.equals(challenge))send.accept("/bcgaccess52 "+ticket);});}catch(Exception error){activity.runOnUiThread(()->{if(!closed&&!activity.isFinishing())android.widget.Toast.makeText(activity,"Não foi possível autorizar a entrada. Confira o serviço de login.",android.widget.Toast.LENGTH_LONG).show();});}});
 }
 void reset(){nonce="";}void close(){closed=true;worker.shutdownNow();}
}
