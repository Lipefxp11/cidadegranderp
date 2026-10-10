package com.gta.launcher.activity;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
/** IMG v2 replacements append aligned payloads and change only their directory records. */
final class ImgArchive43 {
 static void replace(File original,File destination,Map<String,byte[]> models)throws IOException {
  Files.copy(original.toPath(),destination.toPath(),StandardCopyOption.REPLACE_EXISTING);
  try(RandomAccessFile r=new RandomAccessFile(destination,"rw")) {
   if(r.length()<8||r.readInt()!=0x56455232)throw new IOException("IMG precisa ser VER2");
   int count=Integer.reverseBytes(r.readInt());long directory=8L+count*32L;
   if(count<1||count>200000||directory>r.length())throw new IOException("Diretório IMG inválido");
   Map<String,Long> entries=new HashMap<>();
   for(int i=0;i<count;i++){long pos=8L+i*32;r.seek(pos);long offset=Integer.toUnsignedLong(Integer.reverseBytes(r.readInt()));int sectors=r.readUnsignedByte()|(r.readUnsignedByte()<<8);r.skipBytes(2);byte[] name=new byte[24];r.readFully(name);int end=0;while(end<name.length&&name[end]!=0)end++;String key=new String(name,0,end,StandardCharsets.US_ASCII).toLowerCase(Locale.ROOT);
    if(entries.put(key,pos)!=null)throw new IOException("Nome duplicado no IMG: "+key);
    if(sectors>0&&(offset*2048<directory||(offset+sectors)*2048>r.length()))throw new IOException("Entrada IMG fora dos limites: "+key);
   }
   for(Map.Entry<String,byte[]> model:models.entrySet()) {
    Long entry=entries.get(model.getKey().toLowerCase(Locale.ROOT));if(entry==null)throw new IOException("Modelo base ausente: "+model.getKey());
    byte[] data=model.getValue();long sector=(r.length()+2047)/2048;int sectors=(data.length+2047)/2048;
    if(data.length<12||sectors>65535||sector>Integer.MAX_VALUE)throw new IOException("Modelo fora dos limites IMG");
    r.seek(sector*2048);r.write(data);r.setLength((sector+sectors)*2048);r.seek(entry);r.writeInt(Integer.reverseBytes((int)sector));r.writeByte(sectors&255);r.writeByte((sectors>>8)&255);r.writeShort(0);
   }
   r.getFD().sync();
  }
 }
}
