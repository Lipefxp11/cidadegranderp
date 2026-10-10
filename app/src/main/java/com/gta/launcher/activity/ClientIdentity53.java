package com.gta.launcher.activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import java.security.MessageDigest;
import java.io.IOException;
/** Detects incorrectly signed/repackaged local installs; this is not remote attestation. */
public final class ClientIdentity53 {
 public static void verify(Context context)throws Exception {
  if(!"com.cidadegranderp".equals(context.getPackageName()))throw new IOException("Pacote do cliente inválido");
  PackageInfo info=context.getPackageManager().getPackageInfo(context.getPackageName(),PackageManager.GET_SIGNING_CERTIFICATES);
  if(info.signingInfo==null||info.signingInfo.hasMultipleSigners())throw new IOException("Assinatura do cliente inválida");
  android.content.pm.Signature[] signatures=info.signingInfo.getApkContentsSigners();
  if(signatures.length!=1)throw new IOException("Assinatura do cliente inválida");
  byte[] digest=MessageDigest.getInstance("SHA-256").digest(signatures[0].toByteArray());StringBuilder hash=new StringBuilder();for(byte b:digest)hash.append(String.format(java.util.Locale.ROOT,"%02x",b&255));
  if(!"d770eeaf7cb99349a52f107704c77c509ceabf149546ba9484722e79916d3cbf".equals(hash.toString()))throw new IOException("Instale o APK assinado Cidade Grande SA-MP");
 }
}
