package com.gta.game.ui;

import android.content.Context;
import android.content.SharedPreferences;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;
import java.nio.charset.StandardCharsets;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.SecureRandom;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

/** Device-only remembered login. Never stores the account password. */
final class LoginSessionVault {
    private static final String ALIAS="BCG42LoginSessions";
    private final SharedPreferences prefs;
    LoginSessionVault(Context context){prefs=context.getSharedPreferences("BCG42LoginSessions",0);}
    private static String b64(byte[] data){return Base64.encodeToString(data,Base64.NO_WRAP|Base64.URL_SAFE);}
    private static String id(String account)throws Exception{return b64(MessageDigest.getInstance("SHA-256").digest(account.getBytes(StandardCharsets.UTF_8)));}
    private static SecretKey key()throws Exception{
        KeyStore store=KeyStore.getInstance("AndroidKeyStore");store.load(null);
        if(!store.containsAlias(ALIAS)){KeyGenerator generator=KeyGenerator.getInstance("AES","AndroidKeyStore");generator.init(new KeyGenParameterSpec.Builder(ALIAS,KeyProperties.PURPOSE_ENCRYPT|KeyProperties.PURPOSE_DECRYPT).setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build());generator.generateKey();}
        return (SecretKey)store.getKey(ALIAS,null);
    }
    String load(String account){try{
        String[] data=prefs.getString(id(account),"").split("\\.");if(data.length!=2)return "";
        Cipher cipher=Cipher.getInstance("AES/GCM/NoPadding");cipher.init(Cipher.DECRYPT_MODE,key(),new GCMParameterSpec(128,Base64.decode(data[0],Base64.URL_SAFE)));cipher.updateAAD(account.getBytes(StandardCharsets.UTF_8));
        String token=new String(cipher.doFinal(Base64.decode(data[1],Base64.URL_SAFE)),StandardCharsets.UTF_8);return token.matches("[0-9a-f]{64}")?token:"";
    }catch(Exception ignored){return "";}}
    void remove(String account){try{prefs.edit().remove(id(account)).apply();}catch(Exception ignored){}}
    String remember(String account){String token=load(account);if(!token.isEmpty())return token;try{
        byte[] bytes=new byte[32];new SecureRandom().nextBytes(bytes);StringBuilder text=new StringBuilder(64);for(byte value:bytes)text.append(String.format(java.util.Locale.ROOT,"%02x",value&255));token=text.toString();
        Cipher cipher=Cipher.getInstance("AES/GCM/NoPadding");cipher.init(Cipher.ENCRYPT_MODE,key());cipher.updateAAD(account.getBytes(StandardCharsets.UTF_8));prefs.edit().putString(id(account),b64(cipher.getIV())+"."+b64(cipher.doFinal(token.getBytes(StandardCharsets.UTF_8)))).apply();return token;
    }catch(Exception ignored){return "";}}
}
