package com.gta.game.ui;
import android.app.Activity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.gta.game.R;
import com.gta.game.SAMP;

public class LoadingScreen {
    private final FrameLayout mainLayout;
    private final ProgressBar progressBar;
    private final TextView status, history;
    private final ConnectionState state=new ConnectionState();
    public LoadingScreen(Activity activity) {
        FrameLayout existing=activity.findViewById(R.id.bcgStartupShield);
        mainLayout=existing!=null ? existing : (FrameLayout)activity.getLayoutInflater().inflate(R.layout.loadingscreen,null);
        if(existing==null)activity.addContentView(mainLayout,new FrameLayout.LayoutParams(-1,-1));
        mainLayout.setZ(10);
        progressBar=mainLayout.findViewById(R.id.progressBar2);
        status=mainLayout.findViewById(R.id.bcgLoadingStatus);
        history=mainLayout.findViewById(R.id.bcgLoadingHistory);
        mainLayout.findViewById(R.id.bcgLoadingExit).setOnClickListener(v->((SAMP)activity).exitGame());
        progressBar.setIndeterminate(true);
    }
    public void update(int phase,String message) {
        if(!state.update(phase,message))return;
        if(message!=null && !message.isEmpty())status.setText(message);
        refresh();
        if(state.canShowGame())hide();else show();
    }
    public void notice(String message){state.addNotice(message);refresh();}
    private void refresh(){history.setText(String.join("\n",state.history()));}
    public void hide(){if(state.canShowGame())mainLayout.setVisibility(View.GONE);}
    public void show(){mainLayout.setVisibility(View.VISIBLE);progressBar.setIndeterminate(state.phase()!=ConnectionState.STOPPED);}
    public void destroy(){mainLayout.setVisibility(View.GONE);}
}
