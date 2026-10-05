package com.gta.game.ui;

import android.app.Activity;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.FrameLayout;

import com.gta.game.R;

public class LoadingScreen {

    private Activity activity;
    private FrameLayout mainLayout;
    private ProgressBar progressBar;


    public LoadingScreen(Activity activity) {
        this.activity = activity;

        mainLayout = (FrameLayout) activity.getLayoutInflater()
                .inflate(R.layout.loadingscreen, null);
        activity.addContentView(mainLayout,
                new FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT));

        initializeViews();
    }

    private void initializeViews() {
        progressBar = mainLayout.findViewById(R.id.progressBar2);
        progressBar.setIndeterminate(true);
    }

    public void hide() {
        if (mainLayout != null) {
            mainLayout.setVisibility(View.GONE);
        }
    }

    public void show() {
        if (mainLayout != null) {
            mainLayout.setVisibility(View.VISIBLE);
            progressBar.setIndeterminate(true);
        }
    }

    public void destroy() {
        hide();
    }
}
