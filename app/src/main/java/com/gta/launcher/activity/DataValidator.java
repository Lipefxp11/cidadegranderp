package com.gta.launcher.activity;

import org.json.JSONArray;
import org.json.JSONObject;
import java.io.*;
import java.nio.charset.StandardCharsets;

/** Contract for the exact DATA audited against this client's ARM64 engine. */
final class DataValidator {
    static final String PROFILE_HASH = "4fd2f5a384e217c3c198ba23cb095fac457f80581e3dbf14be0a79bff8b8a684";
    private static final String ENGINE_HASH = "4c6a7445e30b27afdda781302e4db9bac89c28fc1181b68b1eef16f84d6a282e";

    static int verify(File root, boolean full) throws IOException {
        if (root == null) throw new IOException("Pasta do jogo indisponível");
        BootConfig.verify(root);
        File profile = new File(root, "bcg_data_profile.json");
        if (!profile.isFile() || profile.length() > 1048576 || !PROFILE_HASH.equals(sha256(profile)))
            throw new IOException("DATA incompatível. Use IMPORTAR DATA e selecione o ZIP V024 ou V023 entregue.");
        try {
            JSONObject json = new JSONObject(new String(read(profile), StandardCharsets.UTF_8));
            if (json.getInt("schema") != 1 || !"bcg-v023-dxt".equals(json.getString("id")) || !ENGINE_HASH.equals(json.getString("engine_sha256")))
                throw new IOException("Perfil da DATA não corresponde ao motor desta versão");
            String prefix = root.getCanonicalPath() + File.separator;
            JSONArray files = json.getJSONArray("files");
            for (int i = 0; i < files.length(); i++) {
                JSONObject info = files.getJSONObject(i);
                File file = VehicleModels43.validationFile(root, info.getString("path"));
                if (!file.getCanonicalPath().startsWith(prefix) || !file.isFile() || file.length() != info.getLong("size"))
                    throw new IOException("DATA incompleta: " + info.getString("path"));
                if (full && !info.getString("sha256").equals(sha256(file)))
                    throw new IOException("Arquivo da DATA alterado/incompleto: " + info.getString("path"));
            }
            return files.length();
        } catch (IOException error) { throw error; }
        catch (Exception error) { throw new IOException("Perfil DATA inválido", error); }
    }

    /** Full verification on first launch or changed files; metadata checks on unchanged DATA. */
    static int verifyForLaunch(File root) throws IOException {
        verify(root, false);
        String fingerprint;
        try {
            JSONObject profile = new JSONObject(new String(read(new File(root,"bcg_data_profile.json")),StandardCharsets.UTF_8));
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            JSONArray files = profile.getJSONArray("files");
            for(int i=0;i<files.length();i++) {
                String path=files.getJSONObject(i).getString("path");
                File file=VehicleModels43.validationFile(root,path);
                digest.update((path+"|"+file.length()+"|"+file.lastModified()+"\n").getBytes(StandardCharsets.UTF_8));
            }
            StringBuilder value=new StringBuilder();for(byte b:digest.digest())value.append(String.format(java.util.Locale.ROOT,"%02x",b&255));fingerprint=value.toString();
        } catch(Exception error) {throw new IOException("Falha verificando a DATA",error);}
        File receipt=new File(root,".bcg44-data-verified");
        if(receipt.isFile()&&receipt.length()==64&&fingerprint.equals(new String(read(receipt),StandardCharsets.UTF_8)))return verify(root,false);
        int count=verify(root,true);
        try(FileOutputStream output=new FileOutputStream(receipt)){output.write(fingerprint.getBytes(StandardCharsets.UTF_8));output.getFD().sync();}
        return count;
    }

    static String sha256(File file) throws IOException {
        return FileIntegrity.sha256(file);
    }

    private static byte[] read(File file) throws IOException {
        try (InputStream in = new FileInputStream(file); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[8192]; int n;
            while ((n = in.read(buffer)) != -1) out.write(buffer, 0, n);
            return out.toByteArray();
        }
    }
}
