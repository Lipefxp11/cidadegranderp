# Brasil Cidade Grande RP — Android V019

Cliente SA-MP ARM64 com launcher nativo próprio do Brasil Cidade Grande RP.

## Estado desta entrega

- Pacote: `com.cidadegranderp`
- Versão: `0.0.19` (`versionCode 19`)
- Servidor configurado em `190.102.40.7:7825`
- Launcher nativo redesenhado, sem HTML/WebView
- Consulta de jogadores/status via UDP e botão **JOGAR**
- Configurações de nick, FPS, teclado, voz, tela ligada e linhas do chat
- Tela BCG cobre a inicialização do GTA e só fecha após o evento SA-MP `InitGame`
- Exportação de diagnóstico, `logcat.txt`, `voice.log` e `settings.ini`
- Android mínimo 8.0/API 28; alvo API 36; somente `arm64-v8a`
- Firebase e Crashlytics não fazem parte do APK

A DATA é instalada no diretório retornado por `getExternalFilesDir(null)` a partir do `files.json` do release configurado.

## CEF

Esta versão entrega a base de integração e o cliente sem o overlay WebView antigo. O renderer Chromium/CEF e o protocolo definitivo de páginas/eventos devem ser ligados à GameMode quando ela for fornecida. Não há tela HTML falsa bloqueando o login nativo.

## Compilar e validar

Requisitos: JDK 17, Android SDK 36, Build Tools 36.0.0, NDK 28.2.13676358 e CMake 3.22.1.

```bash
python3 scripts/verify_project.py
./gradlew --no-daemon clean assembleDebug lintDebug
```

APK: `app/build/outputs/apk/debug/Cidade-Grande-RP-V019-LAUNCHER-CEF-BASE-debug.apk`

## Teste no aparelho

1. Desinstale a versão anterior e instale a V019 em aparelho ARM64.
2. Aguarde a DATA chegar a 100%.
3. Abra as configurações, informe `Nome_Sobrenome` e salve.
4. Toque em **JOGAR** e confirme a conexão com `190.102.40.7:7825`.
5. Em caso de falha, volte ao launcher e use **Exportar logs**.

O APK de teste usa assinatura debug. Uma publicação oficial deve usar a chave privada definitiva do BCG.
