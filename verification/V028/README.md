# Verificações V028

Os relatórios neste diretório pertencem à compilação V028. Os relatórios da base recuperada ficam no diretório histórico.

Para repetir o harness nativo: `python3 verification/V028/native_v028_tests.py` (g++ C++17 necessário).

Para repetir a verificação de interface: instale Playwright para Node e execute `node verification/V028/ui_v028_check.cjs`. Defina `BCG_CHROMIUM_PATH` se usar um Chromium externo; `BCG_PLAYWRIGHT_PATH` aceita uma instalação externa de Playwright. A ponte Android é simulada.

JUnit e Lint: `./gradlew testDebugUnitTest lintDebug`. Confira os requisitos de SDK/NDK no README principal.
