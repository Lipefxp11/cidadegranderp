package com.gta.launcher.activity;

import android.app.AlertDialog;
import android.content.ContentValues;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.CheckBox;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;
import android.text.InputType;

import androidx.appcompat.app.AppCompatActivity;

import com.gta.game.R;
import com.gta.game.SAMP;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.json.JSONArray;
import org.json.JSONObject;

/** BCG native launcher: installs the DATA, persists client settings and starts SA-MP. */
public class MainActivity extends AppCompatActivity {
    private static final String TAG = "BCGLauncher";
    private static final String FILES_URL = "https://github.com/Lipefxp11/cidadegranderp/releases/download/data-v1/files.json";
    private static final String CLIENT_URL = "https://github.com/Lipefxp11/cidadegranderp/releases/download/data-v1/client.json";
    private static final String DATA_URL = "https://github.com/Lipefxp11/cidadegranderp/releases/download/data-v1/data.zip";
    // Zero evita rejeitar uma DATA nova quando o manifesto estiver temporariamente indisponível.
    private static final long DATA_SIZE = 463358120L;
    private static final String OWNER = "Ricardo Santos";
    private static final String INSTALL_MARKER = ".bcg_data_v022_ok";
    private static final String SERVER_HOST = "190.102.40.7";
    private static final int SERVER_PORT = 7825;
    private static final String PREFS = "bcg_client";
    private static final String PREF_NICK = "nickname";
    private static final String PREF_FPS = "fps";
    private static final String PREF_CHAT_LINES = "chat_lines";
    private static final String PREF_VOICE = "voice";
    private static final String PREF_ANDROID_KEYBOARD = "android_keyboard";
    private static final String PREF_KEEP_SCREEN = "keep_screen";

    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private Button startButton, settingsButton, logsButton, retryButton;
    private TextView statusText, progressText, pathText, serverStatusText;
    private ProgressBar progressBar;
    private volatile boolean busy = false;
    private volatile long expectedDataSize = DATA_SIZE;
    private volatile String resolvedDataUrl = DATA_URL;
    private File gameDir, cacheZip, logFile;

    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        setFullScreenMode();
        setContentView(R.layout.main_activity);
        gameDir = getExternalFilesDir(null);
        cacheZip = new File(getCacheDir(), "data.zip.part");
        logFile = new File(getFilesDir(), "bcg_launcher.log");
        bindViews();
        log("Launcher iniciado. package=" + getPackageName() + " data=" + gameDir);
        refreshState(true);
    }

    private void bindViews() {
        startButton = findViewById(R.id.startButton);
        settingsButton = findViewById(R.id.settingsButton);
        logsButton = findViewById(R.id.logsButton);
        retryButton = findViewById(R.id.retryButton);
        statusText = findViewById(R.id.statusText);
        progressText = findViewById(R.id.progressText);
        pathText = findViewById(R.id.pathText);
        progressBar = findViewById(R.id.downloadProgress);
        serverStatusText = findViewById(R.id.serverStatusText);
        startButton.setOnClickListener(v -> onStartPressed());
        retryButton.setOnClickListener(v -> beginInstall());
        settingsButton.setOnClickListener(v -> showSettings());
        logsButton.setOnClickListener(v -> exportLogs());
        findViewById(R.id.siteButton).setOnClickListener(v -> {
            try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://cidadegranderp.discloud.dev"))); }
            catch (Throwable t) { Toast.makeText(this, "Site indisponível", Toast.LENGTH_SHORT).show(); }
        });
        queryServerStatus();
    }

    private boolean dataInstalled() {
        if (gameDir == null) return false;
        File marker = new File(gameDir, INSTALL_MARKER);
        File anim = new File(gameDir, "anim");
        File audio = new File(gameDir, "audio");
        File models = new File(gameDir, "models");
        File texdb = new File(gameDir, "texdb");
        // O pacote oficial pode variar; marcador + uma árvore central confirma instalação concluída.
        File mobileTmb = new File(gameDir, "texdb/mobile/mobile.etc.tmb");
        File sampTmb = new File(gameDir, "texdb/samp/samp.dxt.tmb");
        // GTA 2.11: player parcialmente presente (somente PVR, sem DXT) pode derrubar SortEntries.
        // V022 saneia esse caso antes do jogo; a validação exige apenas bancos centrais completos.
        return marker.isFile() && anim.isDirectory() && audio.isDirectory() && models.isDirectory()
                && texdb.isDirectory() && mobileTmb.isFile() && mobileTmb.length() > 0
                && sampTmb.isFile() && sampTmb.length() > 0;
    }

    private void refreshState(boolean autoDownload) {
        if (gameDir == null) {
            setStatus("Falha ao acessar a pasta do jogo.", 0, false);
            return;
        }
        pathText.setText("DATA: " + gameDir.getAbsolutePath());
        if (dataInstalled()) {
            progressBar.setProgress(100);
            progressText.setText("100% • DATA instalada");
            statusText.setText("Cliente pronto para iniciar");
            startButton.setEnabled(true);
            startButton.setText("JOGAR");
            retryButton.setVisibility(View.GONE);
            log("DATA validada.");
        } else {
            startButton.setEnabled(false);
            startButton.setText("AGUARDANDO DATA");
            statusText.setText("DATA não instalada");
            progressText.setText("Preparando download…");
            if (autoDownload) beginInstall(); else retryButton.setVisibility(View.VISIBLE);
        }
    }

    private void onStartPressed() {
        if (busy) return;
        if (!dataInstalled()) { beginInstall(); return; }
        String nickname = getPreferencesStore().getString(PREF_NICK, "");
        if (!isValidNickname(nickname)) {
            showNicknameDialog(true);
            return;
        }
        try {
            sanitizePlayerTexdb();
            writeNativeSettings(nickname);
            statusText.setText("Carregando cliente…");
            log("Abrindo SAMP. servidor=" + SERVER_HOST + ":" + SERVER_PORT + " nick=" + nickname);
            startActivity(new Intent(this, SAMP.class));
        } catch (Throwable t) {
            fail("Não foi possível abrir o cliente", t);
        }
    }

    private SharedPreferences getPreferencesStore() {
        return getSharedPreferences(PREFS, MODE_PRIVATE);
    }

    private boolean isValidNickname(String nickname) {
        return nickname != null && nickname.matches("[A-Za-z0-9]{2,16}_[A-Za-z0-9]{2,16}") && nickname.length() <= 24;
    }

    private void showNicknameDialog(boolean startAfterSave) {
        EditText input = new EditText(this);
        input.setSingleLine(true);
        input.setHint("Nome_Sobrenome");
        input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        input.setText(getPreferencesStore().getString(PREF_NICK, ""));
        input.setSelection(input.length());

        AlertDialog dialog = new AlertDialog.Builder(this)
                .setTitle("Nome do jogador")
                .setMessage("Digite o mesmo Nome_Sobrenome usado no servidor.")
                .setView(input)
                .setNegativeButton("CANCELAR", null)
                .setPositiveButton("SALVAR", null)
                .create();
        dialog.setOnShowListener(ignored -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String nickname = input.getText().toString().trim();
            if (!isValidNickname(nickname)) {
                input.setError("Use Nome_Sobrenome, sem espaços, até 24 caracteres.");
                return;
            }
            try {
                getPreferencesStore().edit().putString(PREF_NICK, nickname).apply();
                writeNativeSettings(nickname);
                log("Configuração nativa salva. servidor=" + SERVER_HOST + ":" + SERVER_PORT + " nick=" + nickname);
                dialog.dismiss();
                Toast.makeText(this, "Nome salvo: " + nickname, Toast.LENGTH_SHORT).show();
                if (startAfterSave) onStartPressed();
            } catch (IOException e) {
                input.setError("Não foi possível salvar a configuração.");
                log("Falha ao salvar settings.ini: " + e);
            }
        }));
        dialog.show();
    }

    private void writeNativeSettings(String nickname) throws IOException {
        if (gameDir == null) throw new IOException("Pasta do jogo indisponível");
        File sampDir = new File(gameDir, "SAMP");
        if (!sampDir.isDirectory() && !sampDir.mkdirs()) throw new IOException("Falha ao criar " + sampDir);
        File settings = new File(sampDir, "settings.ini");
        try (FileWriter writer = new FileWriter(settings, false)) {
            writer.write("[client]\n");
            writer.write("name=" + nickname + "\n");
            writer.write("host=" + SERVER_HOST + "\n");
            writer.write("port=" + SERVER_PORT + "\n");
            writer.write("password=\n");
            writer.write("version=0.3.7\n\n");
            writer.write("[debug]\n");
            writer.write("debug=false\n");
            writer.write("online=true\n");
            writer.write("\n[gui]\n");
            writer.write("FPSLimit=" + getPreferencesStore().getInt(PREF_FPS, 60) + "\n");
            writer.write("ChatMaxMessages=" + getPreferencesStore().getInt(PREF_CHAT_LINES, 6) + "\n");
            writer.write("VoiceChatEnable=" + getPreferencesStore().getBoolean(PREF_VOICE, true) + "\n");
            writer.write("androidkeyboard=" + getPreferencesStore().getBoolean(PREF_ANDROID_KEYBOARD, false) + "\n");
        }
        if (getPreferencesStore().getBoolean(PREF_KEEP_SCREEN, false)) getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        else getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }

    private void queryServerStatus() {
        worker.execute(() -> {
            String result = "OFFLINE";
            try (DatagramSocket socket = new DatagramSocket()) {
                socket.setSoTimeout(2500);
                String[] parts = SERVER_HOST.split("\\.");
                byte[] query = new byte[11];
                query[0]='S'; query[1]='A'; query[2]='M'; query[3]='P';
                for (int i=0;i<4;i++) query[4+i]=(byte)Integer.parseInt(parts[i]);
                query[8]=(byte)(SERVER_PORT & 0xff); query[9]=(byte)((SERVER_PORT >> 8) & 0xff); query[10]='i';
                socket.send(new DatagramPacket(query, query.length, InetAddress.getByName(SERVER_HOST), SERVER_PORT));
                byte[] data = new byte[2048]; DatagramPacket reply = new DatagramPacket(data, data.length); socket.receive(reply);
                if (reply.getLength() >= 17) {
                    int players = (data[12] & 0xff) | ((data[13] & 0xff) << 8);
                    int max = (data[14] & 0xff) | ((data[15] & 0xff) << 8);
                    result = players + "/" + max;
                } else result = "ONLINE";
            } catch (Throwable t) { log("Status UDP indisponível: " + t.getClass().getSimpleName()); }
            final String value = result;
            runOnUiThread(() -> serverStatusText.setText(value));
        });
    }

    private void beginInstall() {
        if (busy || dataInstalled()) { refreshState(false); return; }
        busy = true;
        startButton.setEnabled(false);
        retryButton.setVisibility(View.GONE);
        worker.execute(() -> {
            try {
                loadRemoteManifest();
                downloadWithResume();
                unzipData();
                sanitizePlayerTexdb();
                writeMarker();
                if (!dataInstalled()) throw new IOException("DATA incompatível/incompleta: faltam bancos centrais mobile/samp ou outra pasta obrigatória. Atualize o data.zip antes de jogar.");
                runOnUiThread(() -> { busy = false; refreshState(false); });
            } catch (Throwable t) {
                runOnUiThread(() -> { busy = false; fail("Falha ao instalar a DATA", t); });
            }
        });
    }

    private void loadRemoteManifest() {
        try {
            String json = readUrl(FILES_URL);
            JSONObject root = new JSONObject(json);
            JSONArray files = root.optJSONArray("files");
            if (files == null) throw new IOException("files.json sem array files");
            boolean found = false;
            for (int i = 0; i < files.length(); i++) {
                JSONObject f = files.getJSONObject(i);
                if ("data.zip".equalsIgnoreCase(f.optString("name"))) {
                    long size = f.optLong("size", DATA_SIZE);
                    String url = f.optString("url", DATA_URL);
                    if (size > 0) expectedDataSize = size;
                    if (url.startsWith("https://")) resolvedDataUrl = url;
                    found = true;
                    break;
                }
            }
            if (!found) throw new IOException("data.zip não encontrado no files.json");
            log("Manifesto DATA OK. size=" + expectedDataSize + " url=" + resolvedDataUrl);
        } catch (Throwable t) {
            expectedDataSize = DATA_SIZE;
            resolvedDataUrl = DATA_URL;
            log("Aviso: files.json indisponível; usando fallback oficial. " + t);
        }
        // client.json é consultado para diagnóstico/compatibilidade, mas não bloqueia o jogo
        // porque versões antigas do manifesto usam esquemas diferentes.
        try {
            String client = readUrl(CLIENT_URL);
            log("client.json acessível bytes=" + client.length());
        } catch (Throwable t) {
            log("Aviso: client.json indisponível: " + t);
        }
    }

    private String readUrl(String url) throws IOException {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(15000);
        c.setReadTimeout(15000);
        c.setInstanceFollowRedirects(true);
        c.setRequestProperty("User-Agent", "BCG-Launcher/0.0.20 Ricardo-Santos");
        int code = c.getResponseCode();
        if (code != HttpURLConnection.HTTP_OK) throw new IOException("HTTP " + code + " em " + url);
        try (InputStream in = new BufferedInputStream(c.getInputStream());
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            byte[] b = new byte[8192]; int n;
            while ((n = in.read(b)) != -1) out.write(b, 0, n);
            return out.toString("UTF-8");
        } finally { c.disconnect(); }
    }

    private void downloadWithResume() throws IOException {
        long existing = cacheZip.exists() ? cacheZip.length() : 0L;
        if (expectedDataSize > 0 && existing > expectedDataSize) { cacheZip.delete(); existing = 0; }
        log("Download DATA. parcial=" + existing + " esperado=" + expectedDataSize + " url=" + resolvedDataUrl);
        HttpURLConnection c = (HttpURLConnection) new URL(resolvedDataUrl).openConnection();
        c.setConnectTimeout(20000); c.setReadTimeout(30000); c.setInstanceFollowRedirects(true);
        c.setRequestProperty("User-Agent", "BCG-Launcher/0.0.20 Android");
        if (existing > 0) c.setRequestProperty("Range", "bytes=" + existing + "-");
        int code = c.getResponseCode();
        boolean append = existing > 0 && code == HttpURLConnection.HTTP_PARTIAL;
        if (code != HttpURLConnection.HTTP_OK && code != HttpURLConnection.HTTP_PARTIAL)
            throw new IOException("HTTP " + code + " ao baixar DATA");
        if (!append) existing = 0;
        long total = c.getContentLengthLong();
        if (total > 0) total += existing; else total = expectedDataSize;
        if (expectedDataSize <= 0 && total > 0) expectedDataSize = total;
        final long finalTotal = total;
        try (InputStream in = new BufferedInputStream(c.getInputStream(), 256 * 1024);
             RandomAccessFile out = new RandomAccessFile(cacheZip, "rw")) {
            if (append) out.seek(existing); else out.setLength(0);
            byte[] buf = new byte[256 * 1024]; int n; long done = existing; long lastUi = 0;
            while ((n = in.read(buf)) != -1) {
                out.write(buf, 0, n); done += n;
                long now = System.currentTimeMillis();
                if (now - lastUi > 250) { lastUi = now; updateProgress("Baixando DATA", done, finalTotal); }
            }
        } finally { c.disconnect(); }
        if (cacheZip.length() < 1024 * 1024) throw new IOException("Arquivo baixado é inválido: " + cacheZip.length() + " bytes");
        if (expectedDataSize > 0 && cacheZip.length() != expectedDataSize) {
            long got = cacheZip.length();
            cacheZip.delete();
            throw new IOException("DATA incompleta: " + got + " / " + expectedDataSize + " bytes. O parcial foi removido.");
        }
        updateProgress("Download concluído", cacheZip.length(), cacheZip.length());
        log("Download concluído bytes=" + cacheZip.length());
    }

    private void unzipData() throws IOException {
        runOnUiThread(() -> { statusText.setText("Instalando arquivos…"); progressText.setText("Extraindo DATA…"); progressBar.setIndeterminate(true); });
        String root = gameDir.getCanonicalPath() + File.separator;
        int count = 0;
        try (ZipInputStream zis = new ZipInputStream(new BufferedInputStream(new FileInputStream(cacheZip), 256 * 1024))) {
            ZipEntry e;
            while ((e = zis.getNextEntry()) != null) {
                String name = normalizeEntry(e.getName());
                if (name.isEmpty()) continue;
                File out = new File(gameDir, name);
                String canonical = out.getCanonicalPath();
                if (!canonical.startsWith(root)) throw new IOException("ZIP inseguro: " + name);
                if (e.isDirectory()) { if (!out.exists() && !out.mkdirs()) throw new IOException("Falha criando " + out); }
                else {
                    File parent = out.getParentFile(); if (parent != null && !parent.exists()) parent.mkdirs();
                    try (OutputStream os = new BufferedOutputStream(new FileOutputStream(out), 128 * 1024)) {
                        byte[] b = new byte[128 * 1024]; int n; while ((n = zis.read(b)) > 0) os.write(b, 0, n);
                    }
                    count++;
                    if ((count % 50) == 0) { final int f = count; runOnUiThread(() -> progressText.setText("Extraindo… " + f + " arquivos")); }
                }
                zis.closeEntry();
            }
        }
        log("Extração concluída arquivos=" + count);
        if (count == 0) throw new IOException("ZIP não contém arquivos");
        if (!cacheZip.delete()) log("Aviso: não foi possível apagar cache da DATA");
        runOnUiThread(() -> progressBar.setIndeterminate(false));
    }

    private String normalizeEntry(String n) {
        n = n.replace('\\','/');
        while (n.startsWith("/")) n = n.substring(1);
        // Remove only installation-path wrappers. The real data/ directory must be preserved.
        String[] prefixes = {
                "storage/emulated/0/Android/data/com.cidadegranderp/files/",
                "Android/data/com.cidadegranderp/files/",
                "com.cidadegranderp/files/",
                "files/"
        };
        for (String p : prefixes) {
            if (p.startsWith(n)) return ""; // directory parents of a wrapped archive
            if (n.startsWith(p)) { n = n.substring(p.length()); break; }
        }
        return n;
    }

    private void sanitizePlayerTexdb() {
        if (gameDir == null) return;
        File player = new File(gameDir, "texdb/player");
        if (!player.isDirectory()) return;
        File dxt = new File(player, "player.dxt.tmb");
        File pvr = new File(player, "player.pvr.tmb");
        if (!dxt.isFile() && pvr.isFile()) {
            log("GTA 2.11: texdb/player somente PVR detectado; removendo banco parcial para evitar TextureDatabaseRuntime::SortEntries crash.");
            deleteTree(player);
        }
    }

    private void deleteTree(File f) {
        if (f == null || !f.exists()) return;
        if (f.isDirectory()) {
            File[] children = f.listFiles();
            if (children != null) for (File c : children) deleteTree(c);
        }
        if (!f.delete()) log("Aviso: não foi possível remover " + f.getAbsolutePath());
    }

    private void writeMarker() throws IOException {
        try (FileWriter w = new FileWriter(new File(gameDir, INSTALL_MARKER), false)) {
            w.write("BCG V022\nowner=" + OWNER + "\nurl=" + resolvedDataUrl + "\nsize=" + expectedDataSize + "\ninstalled=" + System.currentTimeMillis());
        }
    }

    private void updateProgress(String label, long done, long total) {
        int pct = total > 0 ? (int)Math.min(100, (done * 100L) / total) : 0;
        final String s = String.format(Locale.US, "%d%% • %.1f MB / %.1f MB", pct, done/1048576.0, total/1048576.0);
        runOnUiThread(() -> { progressBar.setIndeterminate(false); progressBar.setProgress(pct); statusText.setText(label); progressText.setText(s); });
    }

    private void showSettings() {
        View panel = getLayoutInflater().inflate(R.layout.launcher_settings, null);
        EditText nick = panel.findViewById(R.id.settingsNickname);
        SeekBar fps = panel.findViewById(R.id.fpsSeek), chat = panel.findViewById(R.id.chatLinesSeek);
        TextView fpsLabel = panel.findViewById(R.id.fpsLabel), chatLabel = panel.findViewById(R.id.chatLinesLabel);
        CheckBox voice = panel.findViewById(R.id.voiceCheck), wake = panel.findViewById(R.id.wakeCheck);
        RadioButton gameKeyboard = panel.findViewById(R.id.gameKeyboard), androidKeyboard = panel.findViewById(R.id.androidKeyboard);
        SharedPreferences prefs = getPreferencesStore();
        nick.setText(prefs.getString(PREF_NICK, ""));
        int fpsValue = prefs.getInt(PREF_FPS, 60); fps.setProgress(Math.max(0, fpsValue - 30)); fpsLabel.setText("Limite de FPS: " + fpsValue);
        int lines = prefs.getInt(PREF_CHAT_LINES, 6); chat.setProgress(Math.max(0, lines - 3)); chatLabel.setText("Linhas do chat: " + lines);
        voice.setChecked(prefs.getBoolean(PREF_VOICE, true)); wake.setChecked(prefs.getBoolean(PREF_KEEP_SCREEN, false));
        androidKeyboard.setChecked(prefs.getBoolean(PREF_ANDROID_KEYBOARD, false)); gameKeyboard.setChecked(!androidKeyboard.isChecked());
        fps.setOnSeekBarChangeListener(simpleSeek(value -> fpsLabel.setText("Limite de FPS: " + (value + 30))));
        chat.setOnSeekBarChangeListener(simpleSeek(value -> chatLabel.setText("Linhas do chat: " + (value + 3))));
        AlertDialog dialog = new AlertDialog.Builder(this).setView(panel).setNegativeButton("CANCELAR", null).setPositiveButton("SALVAR", null).create();
        dialog.setOnShowListener(x -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String value = nick.getText().toString().trim();
            if (!isValidNickname(value)) { nick.setError("Use Nome_Sobrenome"); return; }
            prefs.edit().putString(PREF_NICK, value).putInt(PREF_FPS, fps.getProgress()+30).putInt(PREF_CHAT_LINES, chat.getProgress()+3)
                    .putBoolean(PREF_VOICE, voice.isChecked()).putBoolean(PREF_KEEP_SCREEN, wake.isChecked()).putBoolean(PREF_ANDROID_KEYBOARD, androidKeyboard.isChecked()).apply();
            try { writeNativeSettings(value); dialog.dismiss(); Toast.makeText(this, "Configurações salvas", Toast.LENGTH_SHORT).show(); }
            catch (IOException e) { nick.setError("Falha ao salvar"); }
        }));
        dialog.show();
    }

    private SeekBar.OnSeekBarChangeListener simpleSeek(java.util.function.IntConsumer changed) {
        return new SeekBar.OnSeekBarChangeListener() {
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) { changed.accept(progress); }
            public void onStartTrackingTouch(SeekBar seekBar) { }
            public void onStopTrackingTouch(SeekBar seekBar) { }
        };
    }

    private void resetDataMarker() {
        if (busy || gameDir == null) return;
        new File(gameDir, INSTALL_MARKER).delete();
        log("Marcador removido para reinstalação.");
        refreshState(true);
    }

    private void exportLogs() {
        worker.execute(() -> {
            try {
                log("Exportando diagnóstico.");
                StringBuilder sb = new StringBuilder();
                sb.append("BCG V019 DIAGNOSTICO COMPLETO\n");
                sb.append("Proprietario: ").append(OWNER).append('\n');
                sb.append("FilesManifest: ").append(FILES_URL).append('\n');
                sb.append("ClientManifest: ").append(CLIENT_URL).append('\n');
                sb.append("DataUrl: ").append(resolvedDataUrl).append('\n');
                sb.append("ExpectedDataSize: ").append(expectedDataSize).append(" bytes\n");
                sb.append("Data: ").append(new Date()).append('\n');
                sb.append("Package: ").append(getPackageName()).append('\n');
                sb.append("Server: ").append(SERVER_HOST).append(':').append(SERVER_PORT).append('\n');
                sb.append("Nickname: ").append(getPreferencesStore().getString(PREF_NICK, "nao configurado")).append('\n');
                sb.append("Android: ").append(Build.VERSION.RELEASE).append(" SDK ").append(Build.VERSION.SDK_INT).append('\n');
                sb.append("ABI: ").append(Build.SUPPORTED_ABIS.length > 0 ? Build.SUPPORTED_ABIS[0] : "?").append('\n');
                sb.append("GameDir: ").append(gameDir).append('\n');
                sb.append("DataInstalled: ").append(dataInstalled()).append('\n');
                sb.append("PartialZip: ").append(cacheZip.exists() ? cacheZip.length() : 0).append(" bytes\n\n--- launcher.log ---\n");
                if (logFile.exists()) try (BufferedReader r = new BufferedReader(new FileReader(logFile))) { String line; while ((line=r.readLine())!=null) sb.append(line).append('\n'); }
                appendDiagnosticFile(sb, new File(gameDir, "logcat.txt"), "cliente nativo / logcat.txt");
                appendDiagnosticFile(sb, new File(gameDir, "SAMP/voice.log"), "SAMP/voice.log");
                appendDiagnosticFile(sb, new File(gameDir, "SAMP/settings.ini"), "SAMP/settings.ini");
                String name = "BCG_LOG_" + new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date()) + ".txt";
                final String savedAt;
                if (Build.VERSION.SDK_INT >= 29) {
                    ContentValues cv = new ContentValues(); cv.put(MediaStore.Downloads.DISPLAY_NAME, name); cv.put(MediaStore.Downloads.MIME_TYPE, "text/plain"); cv.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
                    Uri u = getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, cv); if (u == null) throw new IOException("MediaStore retornou null");
                    try (OutputStream os = getContentResolver().openOutputStream(u)) { if (os == null) throw new IOException("OutputStream null"); os.write(sb.toString().getBytes("UTF-8")); }
                    savedAt = "Downloads/" + name;
                } else {
                    File diagnosticsDir = getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS);
                    if (diagnosticsDir == null) throw new IOException("Pasta de diagnóstico indisponível");
                    File out = new File(diagnosticsDir, name);
                    try (FileOutputStream os = new FileOutputStream(out)) { os.write(sb.toString().getBytes("UTF-8")); }
                    savedAt = out.getAbsolutePath();
                }
                runOnUiThread(() -> Toast.makeText(this, "Log salvo em " + savedAt, Toast.LENGTH_LONG).show());
            } catch (Throwable t) { runOnUiThread(() -> fail("Falha ao exportar log", t)); }
        });
    }

    private void appendDiagnosticFile(StringBuilder sb, File file, String title) throws IOException {
        sb.append("\n--- ").append(title).append(" ---\n");
        if (!file.isFile()) { sb.append("arquivo ausente\n"); return; }
        try (BufferedReader reader = new BufferedReader(new FileReader(file))) { String line; while ((line = reader.readLine()) != null) sb.append(line).append('\n'); }
    }

    private synchronized void log(String s) {
        Log.i(TAG, s);
        try (FileWriter w = new FileWriter(logFile, true)) { w.write(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US).format(new Date()) + " " + s + "\n"); } catch (Exception ignored) {}
    }

    private void setStatus(String text, int progress, boolean ready) { statusText.setText(text); progressBar.setProgress(progress); startButton.setEnabled(ready); }
    private void fail(String msg, Throwable t) { log(msg + ": " + t); progressBar.setIndeterminate(false); statusText.setText(msg); progressText.setText(t.getMessage() == null ? t.getClass().getSimpleName() : t.getMessage()); startButton.setEnabled(false); retryButton.setVisibility(View.VISIBLE); Toast.makeText(this, msg, Toast.LENGTH_LONG).show(); }

    private void setFullScreenMode() {
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
    }
    @Override public void onWindowFocusChanged(boolean f) { super.onWindowFocusChanged(f); if (f) setFullScreenMode(); }
    @Override protected void onDestroy() { super.onDestroy(); worker.shutdownNow(); }
}
