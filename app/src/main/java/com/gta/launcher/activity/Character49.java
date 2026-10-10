package com.gta.launcher.activity;

import android.content.res.AssetManager;
import org.json.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

/** Installs the compatible CJ derivative before the engine opens its archives. */
final class Character49 {
    private static final String[] PATHS={"texdb/player.img","texdb/player/player.dxt.dat","texdb/player/player.dxt.toc"};
    static File validationFile(File root,String path) {
        for(int i=0;i<PATHS.length;i++)if(PATHS[i].equalsIgnoreCase(path.replace('\\','/'))) {
            File backup=backup(root,i);if(backup.isFile())return backup;
        }
        return new File(root,path);
    }
    private static File backup(File root,int i){return new File(root,".bcg49-original-"+i);}
    private static File actual(File root,String path)throws IOException {
        File current=root;
        for(String part:path.split("/")) {
            File next=new File(current,part);
            if(!next.exists()) {
                File[] children=current.listFiles();if(children!=null)for(File child:children)if(child.getName().equalsIgnoreCase(part)){next=child;break;}
            }
            current=next;
        }
        if(!current.isFile())throw new IOException("Arquivo do personagem ausente: "+path);
        return current;
    }
    static void ensure(File root,AssetManager assets)throws Exception {
        JSONObject manifest=new JSONObject(read(assets.open("bcg_character49/manifest.json")));
        JSONObject face=manifest.getJSONObject("face");String fingerprint=manifest.toString()+"|clumps55";
        File receipt=new File(root,".bcg49-character.json");File[] files=new File[3];
        for(int i=0;i<3;i++)files[i]=actual(root,PATHS[i]);
        if(receipt.isFile()) {
            JSONObject saved=new JSONObject(read(new FileInputStream(receipt)));boolean valid=fingerprint.equals(saved.optString("manifest"));
            JSONArray states=saved.optJSONArray("files");valid&=states!=null&&states.length()==3;
            if(valid)for(int i=0;i<3;i++) {JSONObject s=states.getJSONObject(i);valid&=backup(root,i).isFile()&&s.getLong("size")==files[i].length()&&s.getLong("modified")==files[i].lastModified();}
            if(valid)return;
        }
        String[] hashes={manifest.getString("baseImg"),face.getString("baseDat"),face.getString("baseToc")};
        for(int i=0;i<3;i++) {
            File base=backup(root,i);
            if(!base.exists()) {
                if(!hashes[i].equals(FileIntegrity.sha256(files[i])))throw new IOException("DATA do personagem incompatível. Restaure a PLAYER original antes de instalar a variante BCG.");
                File temp=new File(root,base.getName()+".tmp");Files.copy(files[i].toPath(),temp.toPath(),StandardCopyOption.REPLACE_EXISTING);move(temp,base);
            }
            if(!hashes[i].equals(FileIntegrity.sha256(base)))throw new IOException("Backup do personagem inválido");
        }
        File[] temp=new File[3];
        try {
            for(int i=0;i<3;i++)temp[i]=File.createTempFile("bcg49_",".tmp",files[i].getParentFile());
            Map<String,byte[]> models=new LinkedHashMap<>();JSONArray list=manifest.getJSONArray("models");
            for(int i=0;i<list.length();i++){JSONObject item=list.getJSONObject(i);byte[] model=asset(assets,item);validateModel(model);models.put(item.getString("file"),model);}
            ImgArchive43.replace(backup(root,0),temp[0],models);
            byte[] replacement=asset(assets,face);long offset=face.getLong("offset"),oldSize=face.getLong("oldSize");
            replaceTexture(backup(root,1),backup(root,2),temp[1],temp[2],offset,oldSize,replacement);
            JSONArray states=new JSONArray();
            for(int i=0;i<3;i++){move(temp[i],files[i]);states.put(new JSONObject().put("size",files[i].length()).put("modified",files[i].lastModified()));}
            File pending=new File(root,".bcg49-character.json.tmp");
            try(FileOutputStream out=new FileOutputStream(pending)){out.write(new JSONObject().put("manifest",fingerprint).put("files",states).toString().getBytes(StandardCharsets.UTF_8));out.getFD().sync();}
            move(pending,receipt);
        } finally {for(File file:temp)if(file!=null)Files.deleteIfExists(file.toPath());}
    }
    /** Each PLAYER DFF must retain the normal, fat and ripped clump streams. */
    static void validateModel(byte[] model)throws IOException {
        int cursor=0,clumps=0;
        while(cursor<model.length) {
            if(model.length-cursor<12)throw new IOException("Cabecalho do modelo truncado");
            long kind=unsignedInt(model,cursor),length=unsignedInt(model,cursor+4);
            if(kind!=16||length<12||length>model.length-cursor-12)throw new IOException("Bloco do personagem invalido");
            cursor+=12+(int)length;
            clumps++;
        }
        if(clumps!=3)throw new IOException("Modelo do personagem sem as tres variantes corporais");
    }
    private static long unsignedInt(byte[] data,int offset) {
        return ((long)data[offset]&255)|(((long)data[offset+1]&255)<<8)|(((long)data[offset+2]&255)<<16)|(((long)data[offset+3]&255)<<24);
    }
    static void replaceTexture(File dat,File toc,File outputDat,File outputToc,long offset,long oldSize,byte[] replacement)throws IOException {
        if(offset<0||oldSize<16||offset>dat.length()||oldSize>dat.length()-offset||toc.length()<8||toc.length()%4!=0||replacement.length<16)throw new IOException("Banco de textura inválido");
        byte[] bytes=Files.readAllBytes(toc.toPath());long delta=replacement.length-oldSize;
        boolean found=false;
        for(int i=0;i<bytes.length;i+=4) {
            long value=((long)bytes[i]&255)|(((long)bytes[i+1]&255)<<8)|(((long)bytes[i+2]&255)<<16)|(((long)bytes[i+3]&255)<<24);
            if(i==0) {
                if(value!=dat.length())throw new IOException("Tamanho da tabela de textura não corresponde à DATA");
                value+=delta;
            } else {
                // TOC entries are signed: negative values denote absent textures, not offsets.
                if(value>=0x80000000L)continue;
                if(value>=dat.length())throw new IOException("Entrada de textura fora da DATA");
                if(value==offset)found=true;
                if(value>offset&&value<offset+oldSize)throw new IOException("Texturas sobrepostas na DATA");
                if(value>=offset+oldSize)value+=delta;
            }
            if(value<0||value>0xffffffffL)throw new IOException("Offset da textura inválido");
            for(int j=0;j<4;j++)bytes[i+j]=(byte)(value>>(8*j));
        }
        if(!found)throw new IOException("Textura do personagem não consta na tabela da DATA");
        // Validate the complete index before creating any output.
        try(InputStream in=new FileInputStream(dat);FileOutputStream out=new FileOutputStream(outputDat)) {
            copy(in,out,offset);long remaining=oldSize;
            while(remaining>0){long n=in.skip(remaining);if(n==0){if(in.read()<0)throw new EOFException();n=1;}remaining-=n;}
            out.write(replacement);copy(in,out,dat.length()-offset-oldSize);out.getFD().sync();
        }
        try(FileOutputStream out=new FileOutputStream(outputToc)){out.write(bytes);out.getFD().sync();}
    }
    private static void copy(InputStream in,OutputStream out,long count)throws IOException {byte[] b=new byte[65536];while(count>0){int n=in.read(b,0,(int)Math.min(count,b.length));if(n<0)throw new EOFException();out.write(b,0,n);count-=n;}}
    private static byte[] asset(AssetManager assets,JSONObject item)throws Exception {
        byte[] bytes;try(InputStream in=assets.open("bcg_character49/"+item.getString("file"))){bytes=bytes(in);}
        StringBuilder hash=new StringBuilder();for(byte b:java.security.MessageDigest.getInstance("SHA-256").digest(bytes))hash.append(String.format(Locale.ROOT,"%02x",b&255));
        if(bytes.length!=item.getLong("size")||!hash.toString().equals(item.getString("sha256")))throw new IOException("Modelo do personagem inválido");return bytes;
    }
    private static byte[] bytes(InputStream in)throws IOException {ByteArrayOutputStream out=new ByteArrayOutputStream();byte[] b=new byte[65536];int n;while((n=in.read(b))!=-1){if(out.size()+n>32*1024*1024)throw new IOException("Arquivo do personagem muito grande");out.write(b,0,n);}return out.toByteArray();}
    private static String read(InputStream in)throws IOException {try(InputStream input=in){return new String(bytes(input),StandardCharsets.UTF_8);}}
    private static void move(File from,File to)throws IOException {Files.move(from.toPath(),to.toPath(),StandardCopyOption.REPLACE_EXISTING);}
}
