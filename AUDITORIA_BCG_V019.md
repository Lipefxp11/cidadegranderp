# Auditoria técnica — BCG Android V019

Data da revisão: 5 de outubro de 2026.

## Alterações

- Launcher refeito em componentes Android nativos conforme a referência visual recebida.
- Status SA-MP consultado diretamente em `190.102.40.7:7825`.
- Botão **JOGAR** grava as opções em `SAMP/settings.ini` antes de iniciar o cliente.
- Tela de carregamento BCG permanece sobre o GTA até o RPC `InitGame` confirmar a entrada no servidor.
- Diagnóstico inclui os logs Java/nativo, voz e configuração, sem Firebase/Crashlytics.
- HTML/WebView antigo continua removido para não bloquear login ou conexão.
- Pacote `com.cidadegranderp`, ARM64, NDK 28.2 e alinhamento de página de 16 KB mantidos.

## Limite da integração CEF

O código está preparado como base para a futura integração com a GameMode. Um CEF/Chromium funcional exige o runtime binário compatível e a definição dos eventos/RPCs do servidor; esses itens não estão no material recebido. Por isso, esta revisão não anuncia páginas CEF como operacionais.

## Validação

- `assembleDebug`: aprovado.
- O teste final de DATA, renderização do GTA, login, voz e conexão exige aparelho ARM64 e servidor online.
- APK assinado com chave debug apenas para teste.
