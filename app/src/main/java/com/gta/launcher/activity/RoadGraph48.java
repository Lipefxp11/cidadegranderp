package com.gta.launcher.activity;
import android.content.res.AssetManager;
import java.io.*;
import java.nio.file.*;
/** Small read-only road graph, prepared off the UI thread before launching. */
final class RoadGraph48 {
 static void ensure(File root,AssetManager assets)throws IOException{
  File temporary=new File(root,"bcg_roads48.bin.tmp"),target=new File(root,"bcg_roads48.bin");
  try(InputStream in=assets.open("bcg_roads48.bin");OutputStream out=new FileOutputStream(temporary)){
   byte[] buffer=new byte[16384];int count;while((count=in.read(buffer))!=-1)out.write(buffer,0,count);
  }
  Files.move(temporary.toPath(),target.toPath(),StandardCopyOption.REPLACE_EXISTING);
 }
}
