#!/usr/bin/env python3
"""Preflight checks for the BCG Android source tree."""

from __future__ import annotations

import hashlib
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "app"
ERRORS: list[str] = []


def fail(message: str) -> None:
    ERRORS.append(message)


def read(relative: str) -> str:
    path = ROOT / relative
    if not path.is_file():
        fail(f"arquivo obrigatório ausente: {relative}")
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


gradle = read("app/build.gradle.kts")
manifest = read("app/src/main/AndroidManifest.xml")
cmake = read("app/src/main/cpp/samp/CMakeLists.txt")

if 'applicationId = "com.cidadegranderp"' not in gradle:
    fail("applicationId deve ser com.cidadegranderp")
if 'namespace = "com.gta.game"' not in gradle:
    fail("namespace JNI compatível com.gta.game ausente")
if "arm64-v8a" not in gradle:
    fail("filtro arm64-v8a ausente")
if "bass_fx" not in cmake or "bass_ssl" not in cmake:
    fail("BASS FX/SSL não estão ligados pelo CMake")

try:
    ET.fromstring(manifest)
except ET.ParseError as exc:
    fail(f"AndroidManifest.xml inválido: {exc}")

for forbidden in (
    "firebase",
    "crashlytics",
    "google-services",
    "/storage/emulated/0/GTA",
    "/storage/emulated/0/VICE",
    "com.samp.mobile",
):
    for path in APP.rglob("*"):
        if any(part in {"build", ".cxx", ".gradle"} for part in path.parts):
            continue
        if not path.is_file() or path.suffix.lower() in {".so", ".a", ".png", ".jpg", ".webp", ".ttf", ".otf"}:
            continue
        if forbidden.lower() in path.read_text(encoding="utf-8", errors="ignore").lower():
            fail(f"referência proibida '{forbidden}' em {path.relative_to(ROOT)}")

if (APP / "google-services.json").exists():
    fail("google-services.json incompatível ainda está no projeto")

if '#include "RGBA.h"' in read("app/src/main/cpp/samp/game/rgba.cpp"):
    fail("include RGBA.h quebra o build em Linux; use rgba.h")

for archive in (APP / "src").rglob("*.zip"):
    fail(f"arquivo ZIP duplicado dentro da source: {archive.relative_to(ROOT)}")

so_files = sorted((APP / "src" / "main").rglob("*.so"))
expected = {
    "libGame.so",
    "libVendor_mpg123.so",
    "libbass.so",
    "libbass_fx.so",
    "libbass_ssl.so",
    "libopenal.so",
    "libz.so",
}
names = {path.name for path in so_files}
if names != expected:
    fail(f"conjunto de .so inesperado: {sorted(names)}")

hashes: dict[str, Path] = {}
sonames: dict[str, Path] = {}
for path in so_files:
    if "arm64-v8a" not in path.parts:
        fail(f"ABI não suportado na source: {path.relative_to(ROOT)}")

    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if digest in hashes:
        fail(f".so duplicada: {path.relative_to(ROOT)} e {hashes[digest].relative_to(ROOT)}")
    hashes[digest] = path

    header = subprocess.run(
        ["readelf", "-h", str(path)], capture_output=True, text=True, check=False
    ).stdout
    if "AArch64" not in header:
        fail(f"biblioteca não é ARM64: {path.relative_to(ROOT)}")

    program_headers = subprocess.run(
        ["readelf", "-lW", str(path)], capture_output=True, text=True, check=False
    ).stdout
    alignments = [int(value, 16) for value in re.findall(r"^\s*LOAD\s+.*\s(0x[0-9a-fA-F]+)\s*$", program_headers, re.M)]
    if not alignments or min(alignments) < 0x4000:
        fail(f"biblioteca sem alinhamento de página 16 KB: {path.relative_to(ROOT)}")

    dynamic = subprocess.run(
        ["readelf", "-d", str(path)], capture_output=True, text=True, check=False
    ).stdout
    match = re.search(r"\(SONAME\).*\[([^]]+)]", dynamic)
    if not match:
        fail(f"SONAME ausente: {path.relative_to(ROOT)}")
    elif match.group(1) in sonames:
        fail(f"SONAME duplicado: {match.group(1)}")
    else:
        sonames[match.group(1)] = path

if ERRORS:
    print("BCG preflight: FALHOU")
    for error in ERRORS:
        print(f" - {error}")
    sys.exit(1)

print(f"BCG preflight: OK ({len(so_files)} bibliotecas ARM64, pacote com.cidadegranderp)")
