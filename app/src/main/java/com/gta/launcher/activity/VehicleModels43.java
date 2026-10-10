package com.gta.launcher.activity;

import android.content.res.AssetManager;
import org.json.*;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

/** Installs the three supplied DFFs into IMG v2 without changing engine binaries. */
final class VehicleModels43 {
    private static final String IMG="texdb/gta3.img", BACKUP=".bcg43-original-gta3.img";
    static File validationFile(File root,String relative)throws IOException {
        if(relative.replace('\\','/').equalsIgnoreCase(IMG)) {
            File backup=new File(root,BACKUP);if(backup.isFile())return backup;
        }
        return Character49.validationFile(root,relative);
    }
    static void ensure(File root,AssetManager assets)throws Exception {
        File image=new File(root,IMG);if(!image.isFile())image=new File(root,"texdb/GTA3.IMG");
        if(!image.isFile())throw new IOException("Arquivo GTA3.IMG não encontrado na DATA");
        File backup=new File(root,BACKUP),receipt=new File(root,".bcg43-models.json");
        JSONArray list=new JSONObject(read(assets.open("bcg_vehicles43/manifest.json"))).getJSONArray("vehicles");
        String manifest=FileIntegrity.sha256(writeManifestTemp(root,assets));
        if(backup.isFile()&&receipt.isFile()) {
            JSONObject saved=new JSONObject(read(new FileInputStream(receipt)));
            if(manifest.equals(saved.optString("manifest"))) {
                if(saved.optLong("size",-1)==image.length()&&saved.optLong("modified",-1)==image.lastModified())return;
                if(saved.optString("image").equals(FileIntegrity.sha256(image))) {
                    saved.put("size",image.length()).put("modified",image.lastModified());
                    try(FileOutputStream out=new FileOutputStream(receipt)){out.write(saved.toString().getBytes(StandardCharsets.UTF_8));out.getFD().sync();}
                    return;
                }
            }
        }
        if(!backup.isFile()) {
            File tmp=new File(root,BACKUP+".tmp");Files.copy(image.toPath(),tmp.toPath(),StandardCopyOption.REPLACE_EXISTING);Files.move(tmp.toPath(),backup.toPath(),StandardCopyOption.REPLACE_EXISTING);
        }
        File tmp=File.createTempFile("bcg43_img_",".tmp",image.getParentFile());
        try {
            Map<String,byte[]> models=new LinkedHashMap<>();
            for(int i=0;i<list.length();i++) {
                JSONObject model=list.getJSONObject(i);String name=model.getString("file");byte[] data;
                try(InputStream in=assets.open("bcg_vehicles43/"+name)){data=bytes(in);}
                if(data.length!=model.getLong("size")||!sha(data).equals(model.getString("sha256")))throw new IOException("Modelo inválido: "+name);
                models.put(name,data);
            }
            ImgArchive43.replace(backup,tmp,models);
            String hash=FileIntegrity.sha256(tmp);Files.move(tmp.toPath(),image.toPath(),StandardCopyOption.REPLACE_EXISTING);
            JSONObject info=new JSONObject().put("manifest",manifest).put("image",hash).put("size",image.length()).put("modified",image.lastModified());
            try(FileOutputStream o=new FileOutputStream(receipt)){o.write(info.toString().getBytes(StandardCharsets.UTF_8));o.getFD().sync();}
        } finally {Files.deleteIfExists(tmp.toPath());}
    }
    private static File writeManifestTemp(File root,AssetManager assets)throws IOException {File f=new File(root,".bcg43-manifest.json");try(InputStream in=assets.open("bcg_vehicles43/manifest.json");FileOutputStream out=new FileOutputStream(f)){out.write(bytes(in));}return f;}
    private static String sha(byte[] data)throws Exception {byte[] digest=java.security.MessageDigest.getInstance("SHA-256").digest(data);StringBuilder s=new StringBuilder();for(byte b:digest)s.append(String.format(Locale.ROOT,"%02x",b&255));return s.toString();}
    private static byte[] bytes(InputStream in)throws IOException {ByteArrayOutputStream out=new ByteArrayOutputStream();byte[] b=new byte[65536];int n;while((n=in.read(b))!=-1){if(out.size()+n>32*1024*1024)throw new IOException("Arquivo muito grande");out.write(b,0,n);}return out.toByteArray();}
    private static String read(InputStream in)throws IOException {try(InputStream input=in){return new String(bytes(input),StandardCharsets.UTF_8);}}
    private static int readLE(RandomAccessFile r)throws IOException {return Integer.reverseBytes(r.readInt());}
    private static void writeLE(RandomAccessFile r,int value)throws IOException {r.writeInt(Integer.reverseBytes(value));}
}
