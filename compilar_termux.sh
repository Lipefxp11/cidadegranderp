#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v java >/dev/null; then echo 'Instale Java 17: pkg install openjdk-17'; exit 1; fi
chmod +x ./gradlew
./gradlew --no-daemon --stacktrace :app:assembleDebug
printf '\nAPK: %s\n' "$(pwd)/app/build/outputs/apk/debug/app-debug.apk"
