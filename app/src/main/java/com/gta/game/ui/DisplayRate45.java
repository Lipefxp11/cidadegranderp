package com.gta.game.ui;
import android.app.Activity;
import android.os.Build;
import android.view.Display;
import android.view.WindowManager;
/** Request a supported display mode; this does not guarantee rendering FPS. */
public final class DisplayRate45 {
    private DisplayRate45() {}
    public static void apply(Activity activity) {
        if(Build.VERSION.SDK_INT<23)return;
        int cap=Math.max(30,Math.min(120,activity.getSharedPreferences("bcg_client",0).getInt("fps",60)));
        Display display=activity.getWindowManager().getDefaultDisplay();
        Display.Mode current=display.getMode(),best=null;
        for(Display.Mode mode:display.getSupportedModes()) {
            if(mode.getPhysicalWidth()!=current.getPhysicalWidth()||mode.getPhysicalHeight()!=current.getPhysicalHeight())continue;
            if(mode.getRefreshRate()<=cap+1&&(best==null||mode.getRefreshRate()>best.getRefreshRate()))best=mode;
        }
        if(best!=null){WindowManager.LayoutParams params=activity.getWindow().getAttributes();params.preferredDisplayModeId=best.getModeId();params.preferredRefreshRate=best.getRefreshRate();activity.getWindow().setAttributes(params);}
    }
}
