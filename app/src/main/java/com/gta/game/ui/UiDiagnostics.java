package com.gta.game.ui;

import android.content.Context;
import android.os.SystemClock;
import java.io.File;
import java.io.FileWriter;

/** Local UI diagnostics; never writes account data, commands, tokens or passwords. */
public final class UiDiagnostics {
    private UiDiagnostics(){}
    public static synchronized void write(Context context,String message){
        android.util.Log.i("BCG_UI_DIAG",message);
        try {
            File file=new File(context.getFilesDir(),"bcg-interface.log");
            if(file.length()>524288){File previous=new File(context.getFilesDir(),"bcg-interface.previous.log");previous.delete();file.renameTo(previous);}
            try(FileWriter out=new FileWriter(file,true)){out.write(SystemClock.elapsedRealtime()+" "+message.replace('\n',' ').replace('\r',' ')+"\n");}
        }catch(Exception ignored){}
    }
}
