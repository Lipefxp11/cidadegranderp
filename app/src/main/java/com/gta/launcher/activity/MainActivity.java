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
    private boolean bcgMicRequested=false;
    private static final String TAG = "BCGLauncher";
    private static final String FILES_URL = "https://github.com/Lipefxp11/cidadegranderp/releases/download/data-v1/files.json";
    private static final String CLIENT_URL = "https://github.com/Lipefxp11/cidadegranderp/releases/download/data-v1/client.json";
    private static final String DATA_URL = "https://github.com/Lipefxp11/cidadegranderp/releases/download/data-v1/data.zip";
    // Zero evita rejeitar uma DATA nova quando o manifesto estiver temporariamente indisponível.
    private static final long DATA_SIZE = 0L;
    private static final String OWNER = "Ricardo Santos";
    private static final String INSTALL_MARKER = ".bcg_data_v023_ok";
    private static final int IMPORT_DATA_REQUEST = 2301;
    private static final String SERVER_HOST = "190.102.40.7";
    private static final int SERVER_PORT = 7825;
    private static final String PREFS = "bcg_client";
    private static final String PREF_NICK = "nickname";
    private static final String PREF_FPS = "fps";
    private static final String PREF_CHAT_LINES = "chat_lines";
    private static final String PREF_VOICE = "voice";
    private static final String PREF_ANDROID_KEYBOARD = "android_keyboard";
    private static final String PREF_KEEP_SCREEN = "keep_screen";

    private static final class CityServer {
        final String name, host; final int port;
        String status="VERIFICANDO"; int players=0,capacity=0;
        CityServer(String name,String host,int port){this.name=name;this.host=host;this.port=port;}
    }
    private final java.util.ArrayList<CityServer> cities=new java.util.ArrayList<>();
    private int selectedCity=0;
    private CityServer city(){return cities.get(selectedCity);}
    private final ExecutorService worker = Executors.newSingleThreadExecutor();
    private final ExecutorService statusWorker44 = Executors.newSingleThreadExecutor();
    private Button startButton, logsButton, retryButton;
    private View settingsButton;
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
        if (gameDir != null) {
            try (FileReader input = new FileReader(new File(gameDir, INSTALL_MARKER))) {
                java.util.Properties installed = new java.util.Properties();
                installed.load(input);
                expectedDataSize = Long.parseLong(installed.getProperty("size", "0"));
                resolvedDataUrl = installed.getProperty("url", DATA_URL);
            } catch (IOException | NumberFormatException ignored) { }
        }
        loadCities();
        bindViews();
        log("Launcher iniciado. package=" + getPackageName() + " data=" + gameDir);
        busy=true;startButton.setEnabled(false);
        worker.execute(() -> {
            try { ensureBootConfig();runOnUiThread(() -> {if(isFinishing()||isDestroyed())return;busy=false;findViewById(R.id.bootLoading45).setVisibility(android.view.View.GONE);refreshState(true);}); }
            catch(IOException error){runOnUiThread(() -> {if(isFinishing()||isDestroyed())return;busy=false;findViewById(R.id.bootLoading45).setVisibility(android.view.View.GONE);fail("Falha ao preparar a configuração do cliente",error);});}
        });
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
        settingsButton.setOnClickListener(v -> showMenu51());
        findViewById(R.id.switchAccount51).setOnClickListener(v -> switchAccount51());
        findViewById(R.id.termsButton51).setOnClickListener(v -> showTerms51());
        View playPanel=findViewById(R.id.playPanel51); android.view.ViewGroup.LayoutParams pp=playPanel.getLayoutParams(); pp.width=Math.min(dp43(300),getResources().getDisplayMetrics().widthPixels*35/100); playPanel.setLayoutParams(pp);
        logsButton.setOnClickListener(v -> exportLogs());
        findViewById(R.id.siteButton).setOnClickListener(v -> {
            try { startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://cidadegranderp.discloud.dev"))); }
            catch (Throwable t) { Toast.makeText(this, "Site indisponível", Toast.LENGTH_SHORT).show(); }
        });
        findViewById(R.id.importDataButton).setOnClickListener(v -> selectLocalData());
        findViewById(R.id.serverCard).setOnClickListener(v -> showCities());
        findViewById(R.id.toolsButton).setOnClickListener(v -> showTools());
        ((TextView)findViewById(R.id.serverName)).setText(city().name);
        queryServerStatus();
    }

    private boolean dataInstalled() {
        if (gameDir == null) return false;
        File marker = new File(gameDir, INSTALL_MARKER);
        if (!marker.isFile()) return false;
        try { DataValidator.verify(gameDir, false); return true; }
        catch (IOException error) { return false; }
    }

    private void ensureBootConfig() throws IOException {
        if (BootConfig.ensure(gameDir, getAssets()::open))
            log("BCG V026: arquivos de inicialização e personagem BCG restaurados do APK");
        BootConfig.verify(gameDir);
        log("BCG V026: inicialização aprovada. stream_sha256=" + BootConfig.FILE_HASH + " scv_sha256=" + BootConfig.SCRIPT_FILE_HASH);
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
            progressBar.setVisibility(View.GONE);progressText.setVisibility(View.GONE);
            statusText.setText("Cliente pronto para iniciar");
            startButton.setEnabled(true);
            startButton.setText("JOGAR AGORA");startButton.setOnClickListener(v -> onStartPressed());
            retryButton.setVisibility(View.GONE);
            log("DATA validada.");
        } else {
            startButton.setEnabled(false);
            startButton.setText("IMPORTAR DATA");
            startButton.setEnabled(true);startButton.setOnClickListener(v->{if(dataInstalled())onStartPressed();else selectLocalData();});
            statusText.setText("Importe a DATA compatível entregue com o APK");
            progressText.setText("Toque em IMPORTAR DATA e selecione o ZIP entregue");
            // A DATA remota antiga não deve ser baixada repetidamente nem marcada como válida.
            retryButton.setVisibility(View.GONE);
            statusText.setText("Importe a DATA pela engrenagem");
        }
    }

    private void onStartPressed() {
        if (busy) return;
        if(!bcgMicRequested && android.os.Build.VERSION.SDK_INT>=23 && checkSelfPermission(android.Manifest.permission.RECORD_AUDIO)!=android.content.pm.PackageManager.PERMISSION_GRANTED){bcgMicRequested=true;requestPermissions(new String[]{android.Manifest.permission.RECORD_AUDIO},271);return;}
        try { ensureBootConfig(); }
        catch (IOException error) { fail("Falha ao preparar a configuração do cliente", error); return; }
        if (!dataInstalled()) { beginInstall(); return; }
        String nickname = getPreferencesStore().getString(PREF_NICK, "");
        if (!isValidNickname(nickname)) {
            showNicknameDialog(true);
            return;
        }
        busy = true;
        startButton.setEnabled(false);
        statusText.setText("Validando arquivos do cliente…");
        worker.execute(() -> {
            try {
                ensureBootConfig();
                int count = DataValidator.verifyForLaunch(gameDir);
                log("DATA validada antes de JOGAR. arquivos=" + count);
                log("BCG V026: stream.ini e SAMP/main.scv aprovados antes de JOGAR. scv_sha256=" + BootConfig.SCRIPT_FILE_HASH);
                VehicleModels43.ensure(gameDir, getAssets());
                Character49.ensure(gameDir, getAssets());
                RoadGraph48.ensure(gameDir, getAssets());
                writeNativeSettings(nickname);
                File previous = new File(gameDir, "logcat.txt");
                if (previous.isFile() && !previous.renameTo(new File(gameDir, "logcat.previous." + System.currentTimeMillis() + ".txt")))
                    throw new IOException("Falha ao preservar o diagnóstico nativo anterior");
                log("Abrindo SAMP V026. servidor=" + SERVER_HOST + ":" + SERVER_PORT + " nick=" + nickname);
                runOnUiThread(() -> { busy = false; startButton.setEnabled(true);
                    startActivity(new Intent(this, SAMP.class)); });
            } catch (Throwable t) { runOnUiThread(() -> { busy = false; fail("Não foi possível abrir o cliente", t); }); }
        });
    }

    @Override public void onRequestPermissionsResult(int requestCode,String[] permissions,int[] results){
        super.onRequestPermissionsResult(requestCode,permissions,results);
        if(requestCode==271)onStartPressed();
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
            writer.write("host=" + city().host + "\n");
            writer.write("port=" + city().port + "\n");
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
            writer.write("\n[graphics]\nLightBoost="+(getPreferencesStore().getInt("light52",6)/100.0f)+"\n");
        }
        runOnUiThread(() -> {
            if (getPreferencesStore().getBoolean(PREF_KEEP_SCREEN, false)) getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            else getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        });
    }

    private void loadCities() {
        cities.add(new CityServer("Cidade Grande",SERVER_HOST,SERVER_PORT));
        try(InputStream input=getAssets().open("bcg_servers.json")){
            ByteArrayOutputStream buffer=new ByteArrayOutputStream();byte[] block=new byte[4096];int read;
            while((read=input.read(block))!=-1){if(buffer.size()+read>65536)throw new IOException("Lista muito grande");buffer.write(block,0,read);}
            JSONArray list=new JSONObject(buffer.toString("UTF-8")).getJSONArray("servers");
            java.util.ArrayList<CityServer> configured=new java.util.ArrayList<>();
            for(int i=0;i<list.length()&&i<20;i++){
                JSONObject item=list.getJSONObject(i);String name=item.getString("name"),host=item.getString("host");int port=item.getInt("port");
                if(name.length()>0&&name.length()<=40&&host.matches("[A-Za-z0-9.-]{1,253}")&&port>0&&port<=65535)configured.add(new CityServer(name,host,port));
            }
            if(!configured.isEmpty()){cities.clear();cities.addAll(configured);}
        }catch(Exception ignored){}
        selectedCity=Math.min(cities.size()-1,Math.max(0,getPreferencesStore().getInt("city",0)));
    }
    private final java.util.Map<CityServer,TextView> serverStates45=new java.util.HashMap<>();
    private final java.util.Map<CityServer,android.widget.ProgressBar> serverBars45=new java.util.HashMap<>();
    private void updateServer45(CityServer target){
        TextView label=serverStates45.get(target);if(label!=null){label.setText(target.status);label.setTextColor(target.status.startsWith("ON")?0xFF69DD96:0xFFABB2BF);}
        android.widget.ProgressBar bar=serverBars45.get(target);if(bar!=null)bar.setProgress(target.capacity>0?(int)(100L*target.players/target.capacity):0);
        if(city()==target){serverStatusText.setText(target.status);((TextView)findViewById(R.id.onlineBadge45)).setText(target.status);((android.widget.ProgressBar)findViewById(R.id.serverOccupancy45)).setProgress(target.capacity>0?(int)(100L*target.players/target.capacity):0);}
    }
    private android.widget.FrameLayout serversPane43;
    private void showCities(){
        if(busy||serversPane43!=null)return;
        android.widget.FrameLayout root=findViewById(R.id.launcherRoot43);
        serversPane43=new android.widget.FrameLayout(this);serversPane43.setBackgroundColor(0xFF071323);
        android.widget.ImageView backdrop51=new android.widget.ImageView(this);backdrop51.setImageResource(R.drawable.login_background50);backdrop51.setScaleType(android.widget.ImageView.ScaleType.CENTER_CROP);serversPane43.addView(backdrop51,new android.widget.FrameLayout.LayoutParams(-1,-1));View shade51=new View(this);shade51.setBackgroundColor(0xDC071323);serversPane43.addView(shade51,new android.widget.FrameLayout.LayoutParams(-1,-1));
        root.addView(serversPane43,new android.widget.FrameLayout.LayoutParams(-1,-1));
        android.widget.LinearLayout column=new android.widget.LinearLayout(this);column.setOrientation(1);column.setPadding(dp43(28),dp43(20),dp43(28),dp43(20));
        serversPane43.addView(column,new android.widget.FrameLayout.LayoutParams(-1,-1));
        android.widget.LinearLayout header45=new android.widget.LinearLayout(this);header45.setGravity(android.view.Gravity.CENTER_VERTICAL);column.addView(header45,new android.widget.LinearLayout.LayoutParams(-1,dp43(64)));
        Button back=new Button(this);back.setText("VOLTAR");back.setTextColor(0xFFFFFFFF);back.setBackgroundResource(R.drawable.launcher_outline_button);header45.addView(back,new android.widget.LinearLayout.LayoutParams(dp43(130),dp43(42)));back.setOnClickListener(v->closeServers43());
        TextView title=new TextView(this);title.setText("Escolha onde quer jogar\nSelecionar servidor");title.setTextColor(0xFFFFFFFF);title.setTextSize(22);title.setGravity(android.view.Gravity.CENTER);header45.addView(title,new android.widget.LinearLayout.LayoutParams(0,dp43(64),1));
        android.widget.ScrollView scroll=new android.widget.ScrollView(this);column.addView(scroll,new android.widget.LinearLayout.LayoutParams(-1,0,1));
        android.widget.GridLayout grid=new android.widget.GridLayout(this);int columns=getResources().getConfiguration().screenWidthDp<650?2:3;grid.setColumnCount(columns);scroll.addView(grid);
        int width=Math.max(dp43(180),(getResources().getDisplayMetrics().widthPixels-dp43(56+8*columns))/columns);
        for(int i=0;i<cities.size();i++){final int index=i;CityServer target=cities.get(i);android.widget.LinearLayout card=new android.widget.LinearLayout(this);card.setOrientation(1);card.setPadding(dp43(16),dp43(16),dp43(16),dp43(16));card.setBackgroundResource(R.drawable.launcher_server_card);
            android.widget.GridLayout.LayoutParams params=new android.widget.GridLayout.LayoutParams();params.width=width;params.height=dp43(125);params.setMargins(dp43(4),dp43(4),dp43(4),dp43(4));grid.addView(card,params);
            TextView name=new TextView(this);name.setText(target.name);name.setTextColor(0xFFFFFFFF);name.setTextSize(15);name.setTypeface(null,android.graphics.Typeface.BOLD);card.addView(name);
            TextView state=new TextView(this);state.setText(target.status);state.setTextColor(target.status.startsWith("ON")?0xFF69DD96:0xFFABB2BF);state.setPadding(0,dp43(10),0,dp43(10));card.addView(state);
            android.widget.ProgressBar occupancy=new android.widget.ProgressBar(this,null,android.R.attr.progressBarStyleHorizontal);occupancy.setMax(100);occupancy.setProgress(target.capacity>0?(int)(100L*target.players/target.capacity):0);occupancy.setProgressTintList(android.content.res.ColorStateList.valueOf(0xFFEB3D48));card.addView(occupancy,new android.widget.LinearLayout.LayoutParams(-1,dp43(5)));
            serverStates45.put(target,state);serverBars45.put(target,occupancy);card.setContentDescription("Selecionar "+target.name);card.setOnClickListener(v->{selectedCity=index;getPreferencesStore().edit().putInt("city",index).apply();((TextView)findViewById(R.id.serverName)).setText(city().name);updateServer45(city());closeServers43();});
        }
    }
    private int dp43(int v){return Math.round(v*getResources().getDisplayMetrics().density);}
    private void closeServers43(){if(serversPane43!=null){((android.view.ViewGroup)serversPane43.getParent()).removeView(serversPane43);serversPane43=null;serverStates45.clear();serverBars45.clear();}}
    @Override public void onBackPressed(){if(serversPane43!=null)closeServers43();else super.onBackPressed();}
    private void showTools(){
        if(busy)return;
        new AlertDialog.Builder(this).setTitle("Arquivos e suporte").setItems(new String[]{"Importar DATA","Verificar instalacao","Exportar diagnostico","Abrir site"},(d,index)->{
            switch(index){case 0:selectLocalData();break;case 1:refreshState(false);break;case 2:exportLogs();break;case 3:findViewById(R.id.siteButton).performClick();break;}
        }).setNegativeButton("FECHAR",null).show();
    }
    private final java.util.concurrent.atomic.AtomicBoolean querying51=new java.util.concurrent.atomic.AtomicBoolean();
    private void queryServerStatus() {
        if(!querying51.compareAndSet(false,true))return;
        java.util.Set<String> queried45=new java.util.HashSet<>();
        for(final CityServer target:cities){
        if(!queried45.add(target.host+":"+target.port))continue;
        statusWorker44.execute(() -> {
            String result="SEM RESPOSTA";
            try(DatagramSocket socket=new DatagramSocket()){
                socket.setSoTimeout(2500);
                InetAddress address=InetAddress.getByName(target.host);byte[] addressBytes=address.getAddress();
                if(addressBytes.length!=4)throw new IOException("IPv4 necessario");
                byte[] query=new byte[11];query[0]='S';query[1]='A';query[2]='M';query[3]='P';
                System.arraycopy(addressBytes,0,query,4,4);query[8]=(byte)target.port;query[9]=(byte)(target.port>>8);query[10]='i';
                socket.send(new DatagramPacket(query,query.length,address,target.port));
                byte[] data=new byte[2048];DatagramPacket reply=new DatagramPacket(data,data.length);socket.receive(reply);
                if(!reply.getAddress().equals(address)||reply.getPort()!=target.port||reply.getLength()<16||!java.util.Arrays.equals(query,java.util.Arrays.copyOf(data,query.length)))throw new IOException("Resposta invalida");
                int players=(data[12]&255)|((data[13]&255)<<8),max=(data[14]&255)|((data[15]&255)<<8);
                target.players=players;target.capacity=max;result="ON · "+players+"/"+max;
            }catch(Exception ignored){}
            final String status=result;runOnUiThread(()->{if(isFinishing()||isDestroyed())return;for(CityServer alias:cities){if(alias.host.equals(target.host)&&alias.port==target.port){alias.players=target.players;alias.capacity=target.capacity;alias.status=status;updateServer45(alias);}}});
        });}
        statusWorker44.execute(()->querying51.set(false));
    }

    private void beginInstall() {
        if (busy) return;
        try { ensureBootConfig(); }
        catch (IOException error) { fail("Falha ao preparar a configuração do cliente", error); return; }
        if (dataInstalled()) { refreshState(false); return; }
        busy = true;
        startButton.setEnabled(false);
        retryButton.setVisibility(View.GONE);
        worker.execute(() -> {
            try {
                loadRemoteManifest();
                downloadWithResume();
                try (java.util.zip.ZipFile zip = new java.util.zip.ZipFile(cacheZip)) {
                    if (zip.getEntry("bcg_data_profile.json") == null) throw new IOException("O data.zip publicado ainda é antigo. Use IMPORTAR DATA com o ZIP V024 ou V023 entregue.");
                }
                unzipData();
                log("Verificação DATA: " + DataValidator.verify(gameDir, true) + " arquivos SHA-256 aprovados");
                writeMarker();
                if (!dataInstalled()) throw new IOException("DATA incompatível. Importe a DATA V024 ou V023 entregue.");
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
        c.setRequestProperty("User-Agent", "BCG-Launcher/0.0.25 Ricardo-Santos");
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
        c.setRequestProperty("User-Agent", "BCG-Launcher/0.0.25 Android");
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
        runOnUiThread(() -> { statusText.setText("Instalando arquivos…"); progressText.setText("Extraindo DATA…"); progressBar.setVisibility(View.VISIBLE); progressText.setVisibility(View.VISIBLE); progressBar.setIndeterminate(true); });
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
        ensureBootConfig();
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

    private void selectLocalData() {
        if (busy) return;
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("*/*");
        startActivityForResult(intent, IMPORT_DATA_REQUEST);
    }

    @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode != IMPORT_DATA_REQUEST || resultCode != RESULT_OK || data == null || data.getData() == null || busy) return;
        final Uri uri = data.getData();
        busy = true;
        startButton.setEnabled(false);
        statusText.setText("Importando DATA…");
        worker.execute(() -> {
            try {
                try (InputStream in = getContentResolver().openInputStream(uri); OutputStream out = new BufferedOutputStream(new FileOutputStream(cacheZip))) {
                    if (in == null) throw new IOException("Não foi possível ler o ZIP escolhido");
                    byte[] buffer = new byte[262144]; int n;
                    while ((n = in.read(buffer)) != -1) out.write(buffer, 0, n);
                }
                try (java.util.zip.ZipFile zip = new java.util.zip.ZipFile(cacheZip)) {
                    if (zip.getEntry("bcg_data_profile.json") == null) throw new IOException("Selecione o ZIP de DATA V024 ou V023 entregue, sem extrair");
                }
                expectedDataSize = cacheZip.length();
                resolvedDataUrl = "Arquivo local compatível";
                new File(gameDir, INSTALL_MARKER).delete();
                unzipData();
                log("DATA importada e validada. arquivos=" + DataValidator.verify(gameDir, true));
                writeMarker();
                runOnUiThread(() -> { busy = false; refreshState(false); });
            } catch (Throwable t) { runOnUiThread(() -> { busy = false; fail("Falha ao importar DATA", t); }); }
        });
    }

    private void writeMarker() throws IOException {
        try (FileWriter w = new FileWriter(new File(gameDir, INSTALL_MARKER), false)) {
            w.write("BCG V026\nprofile_sha256=" + DataValidator.PROFILE_HASH + "\nboot_sha256=" + BootConfig.FILE_HASH + "\nscv_sha256=" + BootConfig.SCRIPT_FILE_HASH + "\nowner=" + OWNER + "\nurl=" + resolvedDataUrl + "\nsize=" + expectedDataSize + "\ninstalled=" + System.currentTimeMillis());
        }
    }

    private void updateProgress(String label, long done, long total) {
        int pct = total > 0 ? (int)Math.min(100, (done * 100L) / total) : 0;
        final String s = String.format(Locale.US, "%d%% • %.1f MB / %.1f MB", pct, done/1048576.0, total/1048576.0);
        runOnUiThread(() -> { progressBar.setVisibility(View.VISIBLE);progressText.setVisibility(View.VISIBLE);progressBar.setIndeterminate(false); progressBar.setProgress(pct); statusText.setText(label); progressText.setText(s); });
    }

    private void showMenu51() {
        if(busy)return;
        new AlertDialog.Builder(this).setTitle("Cidade Grande SA-MP").setItems(new String[]{"Perfil e desempenho","Importar DATA","Verificar instalação","Baixar / reparar DATA","Exportar diagnóstico","Abrir site","Atualizar status dos servidores","Termos"},(d,i)->{switch(i){case 0:showSettings();break;case 1:selectLocalData();break;case 2:refreshState(false);break;case 3:beginInstall();break;case 4:exportLogs();break;case 5:findViewById(R.id.siteButton).performClick();break;case 6:queryServerStatus();break;case 7:showTerms51();break;}}).setNegativeButton("Fechar",null).show();
    }
    private void switchAccount51(){
        if(busy)return;
        new AlertDialog.Builder(this).setTitle("Trocar conta Google?").setMessage("Você voltará à tela de entrada. Os arquivos do jogo serão mantidos.").setNegativeButton("Cancelar",null).setPositiveButton("Trocar conta",(d,w)->{
            new GoogleSession52(this).clear();
            getPreferencesStore().edit().remove(PREF_NICK).apply();
            androidx.credentials.CredentialManager.create(this).clearCredentialStateAsync(new androidx.credentials.ClearCredentialStateRequest(),null,getMainExecutor(),new androidx.credentials.CredentialManagerCallback<Void,androidx.credentials.exceptions.ClearCredentialException>(){
                public void onResult(Void value){backToLogin51();}
                public void onError(androidx.credentials.exceptions.ClearCredentialException error){backToLogin51();}
            });
        }).show();
    }
    private void backToLogin51(){if(isFinishing()||isDestroyed())return;startActivity(new Intent(this,GoogleLogin50.class).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TASK));finish();}
    private void showTerms51(){GoogleLogin50.showTerms(this);}
    private void showSettings() {
        View panel = getLayoutInflater().inflate(R.layout.launcher_settings, null);
        EditText nick = panel.findViewById(R.id.settingsNickname);
        SeekBar fps = panel.findViewById(R.id.fpsSeek), chat = panel.findViewById(R.id.chatLinesSeek);
        TextView fpsLabel = panel.findViewById(R.id.fpsLabel), chatLabel = panel.findViewById(R.id.chatLinesLabel);
        CheckBox voice = panel.findViewById(R.id.voiceCheck), wake = panel.findViewById(R.id.wakeCheck);
        RadioButton gameKeyboard = panel.findViewById(R.id.gameKeyboard), androidKeyboard = panel.findViewById(R.id.androidKeyboard);
        SeekBar light=panel.findViewById(R.id.lightSeek52); TextView lightLabel=panel.findViewById(R.id.lightLabel52);
        light.setProgress(getPreferencesStore().getInt("light52",6));lightLabel.setText("Iluminação suave: "+light.getProgress()+"%");light.setOnSeekBarChangeListener(simpleSeek(value->lightLabel.setText("Iluminação suave: "+value+"%")));
        SharedPreferences prefs = getPreferencesStore();
        nick.setText(prefs.getString(PREF_NICK, ""));
        int fpsValue = prefs.getInt(PREF_FPS, 60); fps.setProgress(Math.max(0, fpsValue - 30)); fpsLabel.setText("Limite de FPS: " + fpsValue);
        int lines = prefs.getInt(PREF_CHAT_LINES, 6); chat.setProgress(Math.max(0, lines - 3)); chatLabel.setText("Linhas do chat: " + lines);
        voice.setChecked(prefs.getBoolean(PREF_VOICE, true)); wake.setChecked(prefs.getBoolean(PREF_KEEP_SCREEN, false));
        androidKeyboard.setChecked(prefs.getBoolean(PREF_ANDROID_KEYBOARD, false)); gameKeyboard.setChecked(!androidKeyboard.isChecked());
        fps.setOnSeekBarChangeListener(simpleSeek(value -> fpsLabel.setText("Limite de FPS: " + (value + 30))));
        chat.setOnSeekBarChangeListener(simpleSeek(value -> chatLabel.setText("Linhas do chat: " + (value + 3))));
        AlertDialog dialog = new AlertDialog.Builder(this).setTitle("Configuracoes").setView(panel).setNegativeButton("CANCELAR", null).setPositiveButton("SALVAR", null).create();
        dialog.setOnShowListener(x -> dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            String value = nick.getText().toString().trim();
            if (!isValidNickname(value)) { nick.setError("Use Nome_Sobrenome"); return; }
            prefs.edit().putInt("light52",light.getProgress()).putString(PREF_NICK, value).putInt(PREF_FPS, fps.getProgress()+30).putInt(PREF_CHAT_LINES, chat.getProgress()+3)
                    .putBoolean(PREF_VOICE, voice.isChecked()).putBoolean(PREF_KEEP_SCREEN, wake.isChecked()).putBoolean(PREF_ANDROID_KEYBOARD, androidKeyboard.isChecked()).apply();
            try { writeNativeSettings(value); dialog.dismiss(); Toast.makeText(this, "Configurações salvas", Toast.LENGTH_SHORT).show(); }
            catch (IOException e) { nick.setError("Falha ao salvar"); }
        }));
        dialog.show();
        if(dialog.getWindow()!=null)dialog.getWindow().setLayout(Math.min(dp43(540),getResources().getDisplayMetrics().widthPixels-dp43(48)),getResources().getDisplayMetrics().heightPixels*85/100);
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
                sb.append("BCG V042 DIAGNOSTICO COMPLETO\n");
                sb.append("TextureProfile: bcg-v023-dxt\n");
                sb.append("BootConfig: stream.ini\n");
                sb.append("BootConfigSHA256: ").append(BootConfig.FILE_HASH).append('\n');
                sb.append("ScriptMetadata: ").append(BootConfig.SCRIPT_FILE_NAME).append('\n');
                sb.append("ScriptMetadataSHA256: ").append(BootConfig.SCRIPT_FILE_HASH).append('\n');
                sb.append("ProfileSHA256: ").append(DataValidator.PROFILE_HASH).append('\n');
                android.content.pm.PackageInfo webview=android.webkit.WebView.getCurrentWebViewPackage();
                sb.append("WebView: ").append(webview==null?"indisponivel":webview.packageName+" "+webview.versionName).append('\n');
                sb.append("InstalledVersion: ").append(getPackageManager().getPackageInfo(getPackageName(), 0).versionName).append('\n');
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
                appendDiagnosticFile(sb,new File(getFilesDir(),"bcg-interface.log"),"Interface Chromium / Java / JavaScript");
                appendDiagnosticFile(sb, new File(gameDir, "logcat.txt"), "cliente nativo / logcat.txt");
                appendDiagnosticFile(sb, new File(gameDir, "SAMP/voice.log"), "SAMP/voice.log");
                appendDiagnosticFile(sb, new File(gameDir, "SAMP/settings.ini"), "SAMP/settings.ini");
                appendDiagnosticFile(sb, new File(gameDir, INSTALL_MARKER), "DATA verificada");
                appendDiagnosticFile(sb, new File(gameDir, BootConfig.FILE_NAME), "stream.ini / inicialização do motor");
                File scv = new File(gameDir, BootConfig.SCRIPT_FILE_NAME);
                sb.append("\n--- SAMP/main.scv / metadados do script ---\n");
                sb.append("Exists: ").append(scv.isFile()).append(" bytes: ").append(scv.length()).append('\n');
                if (scv.isFile()) sb.append("SHA256: ").append(DataValidator.sha256(scv)).append('\n');
                sb.append("\n--- BCG Avatares V027 R2 ---\n");
                for(String fileName : new String[]{"bcgskin.txt", "bcgskin.dxt.dat", "bcgskin.dxt.toc", "bcgskin.dxt.tmb"}) {
                    File avatarFile=new File(gameDir, "texdb/bcgskin/"+fileName);
                    sb.append(fileName).append(" exists=").append(avatarFile.isFile()).append(" bytes=").append(avatarFile.length());
                    if(avatarFile.isFile())sb.append(" sha256=").append(DataValidator.sha256(avatarFile));
                    sb.append('\n');
                }
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
    private void fail(String msg, Throwable t) { log(msg + ": " + t); progressBar.setIndeterminate(false); statusText.setText(msg); progressText.setText(t.getMessage() == null ? t.getClass().getSimpleName() : t.getMessage()); startButton.setEnabled(false); retryButton.setVisibility(View.GONE);
            progressText.setVisibility(View.VISIBLE); startButton.setEnabled(true); Toast.makeText(this, msg, Toast.LENGTH_LONG).show(); }

    private void setFullScreenMode() {
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
    }
    @Override public void onWindowFocusChanged(boolean f) { super.onWindowFocusChanged(f); if (f) setFullScreenMode(); }
    @Override protected void onDestroy() { super.onDestroy(); worker.shutdownNow(); statusWorker44.shutdownNow(); }
}
