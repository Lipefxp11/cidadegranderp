package com.gta.game.ui;
import org.junit.Test;
import static org.junit.Assert.*;

public class ConnectionStateTest {
    @Test public void transportConnectionDoesNotExposeGame() {
        ConnectionState s=new ConnectionState();
        s.update(ConnectionState.CONNECTING,"IP");
        s.update(ConnectionState.JOINING,"Transport");
        assertFalse(s.canShowGame());
        s.update(ConnectionState.AUTH,"Login");
        s.update(ConnectionState.ENTERING,"Account");
        assertFalse(s.canShowGame());
        s.update(ConnectionState.READY,"Spawn");
        assertTrue(s.canShowGame());
    }
    @Test public void readyBeforeAuthenticationIsRejected() {
        ConnectionState s=new ConnectionState();
        assertFalse(s.update(ConnectionState.READY,"Unexpected"));
        assertFalse(s.update(ConnectionState.ENTERING,"Unexpected"));
        assertEquals(ConnectionState.BOOT,s.phase());
    }
    @Test public void connectionLossRequiresNewAuthentication() {
        ConnectionState s=new ConnectionState();
        s.update(ConnectionState.AUTH,"Login");s.update(ConnectionState.READY,"Spawn");
        s.update(ConnectionState.RETRY,"Lost");
        assertFalse(s.canShowGame());assertFalse(s.update(ConnectionState.READY,"Stale"));
        s.update(ConnectionState.CONNECTING,"IP");s.update(ConnectionState.AUTH,"Login");
        s.update(ConnectionState.READY,"New spawn");assertTrue(s.canShowGame());
        s.update(ConnectionState.JOINING,"Server restart");
        assertFalse(s.update(ConnectionState.READY,"Previous authentication"));
        s.update(ConnectionState.AUTH,"Login after restart");
        assertTrue(s.update(ConnectionState.READY,"Spawn after restart"));
        s.update(ConnectionState.STOPPED,"Closed");assertFalse(s.canShowGame());
    }
    @Test public void noticesAreBoundedAndConsecutiveDuplicatesRemoved() {
        ConnectionState s=new ConnectionState();
        s.addNotice("same");s.addNotice("same");assertEquals(1,s.history().size());
        for(int i=0;i<20;i++)s.addNotice("event"+i);
        assertEquals(6,s.history().size());assertEquals("event19",s.history().get(5));
    }
}
