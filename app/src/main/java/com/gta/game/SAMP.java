package com.gta.game;

import android.os.Bundle;
import android.util.Log;
import java.nio.charset.StandardCharsets;
import com.gta.game.ui.ConnectionState;

import com.gta.game.ui.AttachEdit;
import com.gta.game.ui.LoadingScreen;
import com.gta.game.ui.dialog.DialogManager;

public class SAMP extends GTASA implements HeightProvider.HeightListener {

    @Override public void onActivityResult(int requestCode,int resultCode,android.content.Intent data){
        if(mChromium!=null&&mChromium.imageResult(requestCode,resultCode,data))return;
        super.onActivityResult(requestCode,resultCode,data);
    }
    private static final String TAG = "SAMP";
    private static SAMP instance;

    private DialogManager mDialog;
    private com.gta.game.ui.ChromiumUI mChromium;
    private int lastUiPhase=0, uiRecoveries=0;
    private String lastUiMessage="";
    private org.json.JSONObject recoverDialog;
    private boolean gameDestroyed=false;
    private void startChromium(){
        if(gameDestroyed || mChromium!=null)return;
        try {
            mChromium=new com.gta.game.ui.ChromiumUI(this);
            mChromium.connection(lastUiPhase,lastUiMessage);
            if(recoverDialog!=null){
                org.json.JSONObject d=recoverDialog;recoverDialog=null;
                mChromium.dialog(d.optInt("id"),d.optInt("style"),d.optString("title"),d.optString("text"),d.optString("left"),d.optString("right"));
            }
        } catch(RuntimeException unavailable){
            mChromium=null;
            Log.e("BCG_UI","Falha ao criar o WebView",unavailable);
            com.gta.game.ui.UiDiagnostics.write(this,"WebView creation failed: "+android.util.Log.getStackTraceString(unavailable));
            android.widget.Toast.makeText(this,"Interface indisponivel. Confira o Android System WebView.",android.widget.Toast.LENGTH_LONG).show();
            onChromiumUnavailable(recoverDialog);
        }
    }
    public void onChromiumUnavailable(org.json.JSONObject dialog){
        recoverDialog=dialog;
        mChromium=null;
        if(!gameDestroyed && uiRecoveries++<2)
            new android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(this::startChromium,1500);
    }
    public void showNativeDialog(int id,int style,String title,String body,String left,String right){if(mDialog!=null)mDialog.show(id,style,title,body,left,right);}
    public void onChromiumReady(){if(mDialog!=null)mDialog.dismiss();}
    private void onUiEvent(byte[] payload){if(mChromium!=null){String event=new String(payload,StandardCharsets.UTF_8);if(event.contains("\"type\":\"nativeKeyboard\""))mChromium.nativeKeyboard(event.contains("true"));else mChromium.event(event);}}
    private HeightProvider mHeightProvider;
    private Object mBackCallback;

    private AttachEdit mAttachEdit;
    private LoadingScreen mLoadingScreen;

    public static SAMP getInstance() {
        return instance;
    }


    private void showLoadingScreen() {
        runOnUiThread(() -> {if(mLoadingScreen!=null)mLoadingScreen.show();});
    }

    private void hideLoadingScreen() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(mLoadingScreen!=null)mLoadingScreen.hide();
            }
        });
    }

    private void onConnectionStatus(int phase, String message) {
        Log.i("BCG_CONNECTION", "phase="+phase+" "+message);
        lastUiPhase=phase;lastUiMessage=message;
        runOnUiThread(()->{
            if(phase==ConnectionState.CONNECTING || phase==ConnectionState.RETRY || phase==ConnectionState.STOPPED)
                if(mDialog!=null)mDialog.dismiss();
            if(mLoadingScreen!=null)mLoadingScreen.update(phase,message);
            if(mChromium!=null)mChromium.connection(phase,message);
        });
    }
    private void onConnectionNotice(String message) {
        final String clean=message.replaceAll("\\{[0-9A-Fa-f]{6}\\}", "");
        runOnUiThread(()->{if(mLoadingScreen!=null)mLoadingScreen.notice(clean);});
    }
    public void setPauseState(boolean pause) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (pause) {
                    mDialog.hideWithoutReset();
                    mAttachEdit.hideWithoutReset();
                } else {
                    if (mDialog.isShow)
                        mDialog.showWithOldContent();
                    if (mAttachEdit.isShow)
                        mAttachEdit.showWithoutReset();
                }
            }
        });
    }

    public void exitGame() {
        finishAndRemoveTask();
        System.exit(0);
    }

    public void showDialog(int dialogId, int dialogTypeId, byte[] bArr, byte[] bArr2, byte[] bArr3, byte[] bArr4) {
        final String caption = new String(bArr, StandardCharsets.UTF_8);
        final String content = new String(bArr2, StandardCharsets.UTF_8);
        final String leftBtnText = new String(bArr3, StandardCharsets.UTF_8);
        final String rightBtnText = new String(bArr4, StandardCharsets.UTF_8);
        runOnUiThread(() -> { if(mChromium!=null){mChromium.dialog(dialogId,dialogTypeId,caption,content,leftBtnText,rightBtnText);if(mChromium.isReady()){mDialog.dismiss();return;}}if(dialogId < 0)this.mDialog.dismiss();else this.mDialog.show(dialogId, dialogTypeId, caption, content, leftBtnText, rightBtnText); });
    }
    private void showEditObject() {
        runOnUiThread(() -> mAttachEdit.show());
    }

    private void hideEditObject() {
        runOnUiThread(() -> mAttachEdit.hide());
    }


    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "**** onCreate");
        com.gta.game.ui.UiDiagnostics.write(this,"SAMP session V043 start");
        super.onCreate(savedInstanceState);

        mDialog     = new DialogManager(this);
        mAttachEdit = new AttachEdit(this);
        mLoadingScreen = new LoadingScreen(this);
        // Native build: original dialogs, textdraws and chat keyboard.
        startChromium();
        instance = this;
        if (android.os.Build.VERSION.SDK_INT >= 33) mBackCallback = BackApi33.register(this, this::handleBack);
        try {
            initializeSAMP();
        } catch (UnsatisfiedLinkError e5) {
            Log.e(TAG, e5.getMessage());
        }
    }
    private native void initializeSAMP();

    @Override
    public void onStart() {
        Log.i(TAG, "**** onStart");
        super.onStart();
    }

    @Override
    public void onRestart() {
        Log.i(TAG, "**** onRestart");
        super.onRestart();
    }

    @Override
    public void onResume() {
        Log.i(TAG, "**** onResume");
        super.onResume();
        com.gta.game.ui.DisplayRate45.apply(this);
        if(mChromium!=null)mChromium.pause(false);
    }

    @Override
    public void onPause() {
        Log.i(TAG, "**** onPause");
        super.onPause();
        if(mChromium!=null)mChromium.pause(true);
    }

    @Override
    public void onStop() {
        Log.i(TAG, "**** onStop");
        super.onStop();
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "**** onDestroy");
        if (android.os.Build.VERSION.SDK_INT >= 33 && mBackCallback != null) {
            BackApi33.unregister(this, mBackCallback);
            mBackCallback = null;
        }
        gameDestroyed=true;
        if(mChromium!=null)mChromium.destroy();
        super.onDestroy();
    }

    private void handleBack() {
        if (mChromium != null && mChromium.isReady()) mChromium.back();
        else finish();
    }

    // Android 9–12 use the legacy callback. API 33+ registers the platform callback above.
    @android.annotation.SuppressLint("GestureBackNavigation")
    @Override public void onBackPressed() { handleBack(); }

    @androidx.annotation.RequiresApi(33)
    private static final class BackApi33 {
        static Object register(SAMP activity, Runnable action) {
            android.window.OnBackInvokedCallback callback = action::run;
            activity.getOnBackInvokedDispatcher().registerOnBackInvokedCallback(
                    android.window.OnBackInvokedDispatcher.PRIORITY_DEFAULT, callback);
            return callback;
        }
        static void unregister(SAMP activity, Object callback) {
            activity.getOnBackInvokedDispatcher().unregisterOnBackInvokedCallback(
                    (android.window.OnBackInvokedCallback) callback);
        }
    }

    @Override
    public void onHeightChanged(int orientation, int height) { }
}
