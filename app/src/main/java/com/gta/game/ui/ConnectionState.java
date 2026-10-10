package com.gta.game.ui;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;

/** Transport connection alone never uncovers the game. The GM confirms auth and spawn. */
public final class ConnectionState {
    public static final int BOOT=0, CONNECTING=1, JOINING=2, AUTH=3, ENTERING=4, READY=5, RETRY=6, STOPPED=7;
    private int phase=BOOT;
    private boolean authFlow;
    private final ArrayDeque<String> messages=new ArrayDeque<>();
    public boolean update(int next, String message) {
        if(next < BOOT || next > STOPPED || (next == READY && !authFlow)) return false;
        if(next == CONNECTING || next == JOINING || next == RETRY || next == STOPPED) authFlow=false;
        if(next == AUTH) authFlow=true;
        if(next == ENTERING && !authFlow) return false;
        phase=next;
        addNotice(message);
        return true;
    }
    public void addNotice(String message) {
        if(message==null || message.trim().isEmpty()) return;
        String value=message.trim();
        if(value.equals(messages.peekLast())) return;
        messages.addLast(value);
        while(messages.size()>6) messages.removeFirst();
    }
    public int phase() {return phase;}
    public boolean canShowGame() {return phase==READY;}
    public List<String> history() {return new ArrayList<>(messages);}
}
