package com.gta.launcher.activity;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

/** Engine startup files are validated independently of the texture/DATA profile. */
final class BootConfig {
    static final String ASSET_PATH = "bcg_boot/stream.ini";
    static final String FILE_NAME = "stream.ini";
    static final long FILE_SIZE = 197L;
    static final String FILE_HASH = "40729773c7146020cad18415f604e66d5f50ba6f6ee2fc604acf33eeecb24fcf";
    static final String SCRIPT_ASSET_PATH = "bcg_boot/main.scv";
    static final String SCRIPT_FILE_NAME = "SAMP/main.scv";
    static final long SCRIPT_FILE_SIZE = 16L;
    static final String SCRIPT_FILE_HASH = "374708fff7719dd5979ec875d56cd2286f6d3cf7ec317a3b25632aab28ec37bb";

    private static final class AssetSpec {
        final String asset, file, hash;
        final long size;
        AssetSpec(String asset, String file, long size, String hash) {
            this.asset = asset; this.file = file; this.size = size; this.hash = hash;
        }
    }
    private static final AssetSpec[] STARTUP_FILES = {
        new AssetSpec(ASSET_PATH, FILE_NAME, FILE_SIZE, FILE_HASH),
        new AssetSpec(SCRIPT_ASSET_PATH, SCRIPT_FILE_NAME, SCRIPT_FILE_SIZE, SCRIPT_FILE_HASH),
        new AssetSpec("bcg_avatar/bcgskin.dxt.dat", "texdb/bcgskin/bcgskin.dxt.dat", 699120L, "a93934403281b92ec3218ab3592822e8c150c2722e93ebeed928c971e9c3518b"),
        new AssetSpec("bcg_avatar/bcgskin.dxt.tmb", "texdb/bcgskin/bcgskin.dxt.tmb", 96L, "aeb65c327ad781780bb6fb8c772474da7c0b1762c1caaa0743433f2660f572b7"),
        new AssetSpec("bcg_avatar/bcgskin.dxt.toc", "texdb/bcgskin/bcgskin.dxt.toc", 12L, "c02097b5252be07ac779a023d986ef26759b861338c1e4a23e1dd138d2fbab0c"),
        new AssetSpec("bcg_avatar/bcgskin.txt", "texdb/bcgskin/bcgskin.txt", 208L, "3f2a173a27f584280dfcf701325e4f316820538077f090c54950370bc28d9daf")
    };

    interface AssetSource { InputStream open(String name) throws IOException; }

    private BootConfig() { }

    static void verify(File root) throws IOException {
        if (root == null) throw new IOException("Pasta do jogo indisponível");
        for (AssetSpec spec : STARTUP_FILES) verifyFile(root, spec);
    }

    private static void verifyFile(File root, AssetSpec spec) throws IOException {
        File target = new File(root, spec.file);
        if (!target.isFile() || target.length() != spec.size || !spec.hash.equals(FileIntegrity.sha256(target)))
            throw new IOException("Arquivo de inicialização ausente ou incompatível: " + spec.file);
    }

    /** Restore only startup files, leaving the installed DATA intact. */
    static boolean ensure(File root, AssetSource assets) throws IOException {
        if (root == null) throw new IOException("Pasta do jogo indisponível");
        if (!root.isDirectory() && !root.mkdirs()) throw new IOException("Falha criando a pasta do jogo");
        boolean restored = false;
        for (AssetSpec spec : STARTUP_FILES) {
            if (ensureFile(root, assets, spec)) restored = true;
        }
        verify(root);
        return restored;
    }

    private static boolean ensureFile(File root, AssetSource assets, AssetSpec spec) throws IOException {
        try { verifyFile(root, spec); return false; }
        catch (IOException missingOrDamaged) { /* Restore from the APK, then verify again. */ }

        File target = new File(root, spec.file);
        if (!target.getCanonicalPath().equals(new File(root.getCanonicalFile(), spec.file).getAbsolutePath()))
            throw new IOException("Caminho de inicialização inválido: " + spec.file);
        File parent = target.getParentFile();
        if (parent == null || (!parent.isDirectory() && !parent.mkdirs()))
            throw new IOException("Falha criando a pasta de " + spec.file);
        File temporary = File.createTempFile("bcg_boot_", ".tmp", parent);
        try {
            try (InputStream input = assets.open(spec.asset); FileOutputStream output = new FileOutputStream(temporary)) {
                if (input == null) throw new IOException("Arquivo de inicialização ausente no APK: " + spec.file);
                byte[] buffer = new byte[1024];
                int count;
                long total = 0;
                while ((count = input.read(buffer)) != -1) {
                    total += count;
                    if (total > spec.size) throw new IOException("Arquivo de inicialização do APK inválido: " + spec.file);
                    output.write(buffer, 0, count);
                }
                output.getFD().sync();
            }
            if (temporary.length() != spec.size || !spec.hash.equals(FileIntegrity.sha256(temporary)))
                throw new IOException("Arquivo de inicialização do APK não corresponde ao arquivo auditado: " + spec.file);
            try {
                Files.move(temporary.toPath(), target.toPath(), StandardCopyOption.REPLACE_EXISTING, StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException unsupported) {
                Files.move(temporary.toPath(), target.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }
            verifyFile(root, spec);
            return true;
        } finally {
            Files.deleteIfExists(temporary.toPath());
        }
    }
}
