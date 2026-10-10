#!/usr/bin/env python3
"""Create an independent BCG DATA copy from the user's own supplied archive.

Retains the coherent DXT banks, verifies indices and rebuilds incomplete SAMP
mip chains without changing their top-level texture. Requires Pillow and
texture2ddecoder only when preparing a new DATA, never when running the APK.
"""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import argparse
import hashlib
import io
import json
import re
import shutil
import struct

from verify_data import audit_bank, total_size, mip_size

BANKS = ['mobile', 'txd', 'gta3', 'gta_int', 'cutscene', 'menu', 'player', 'playerhi', 'samp']
ENGINE_HASH = '4c6a7445e30b27afdda781302e4db9bac89c28fc1181b68b1eef16f84d6a282e'
PROFILE_HASH = '4fd2f5a384e217c3c198ba23cb095fac457f80581e3dbf14be0a79bff8b8a684'
STREAM_HASH = 'e5b4ac3e7797a271660a091bdc0e4663beedcab43acaee2473086ca8f925a148'
SESSION_FILES = {'samp/settings.ini', 'samp/settings.json', 'logcat.txt', 'cinfo.bin', 'gta_sa.set'}


def sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1048576), b''):
            result.update(chunk)
    return result.hexdigest()


def expand(payload: bytes, marker: int) -> bytes:
    if not marker:
        return payload
    result = bytearray()
    cursor = 0
    while cursor < len(payload):
        repeats = 1
        if payload[cursor] == marker:
            if cursor + 2 > len(payload):
                raise ValueError('truncated RLE marker')
            repeats = payload[cursor + 1]
            cursor += 2
        if not repeats or cursor + 16 > len(payload):
            raise ValueError('invalid SAMP DXT5 RLE')
        result.extend(payload[cursor:cursor+16] * repeats)
        cursor += 16
        if len(result) > 64 * 1024 * 1024:
            raise ValueError('RLE allocation limit')
    return bytes(result)


def repair_samp(root: Path) -> int:
    import texture2ddecoder
    from PIL import Image
    dat = root/'texdb/samp/samp.dxt.dat'
    toc = dat.with_suffix('.toc')
    index = toc.read_bytes()
    offsets = list(struct.unpack(f'<{len(index)//4 - 1}i', index[4:]))
    original = dat.read_bytes()
    limits = sorted(set(x for x in offsets if x >= 0) | {len(original)})
    ends = dict(zip(limits, limits[1:]))
    adjusted = {}
    output = bytearray()
    repaired = 0
    for offset in limits[:-1]:
        block = original[offset:ends[offset]]
        hashed, fmt, width, hflags, stored, marker = struct.unpack_from('<HHHHII', block)
        raw = expand(block[16:], marker) if fmt == 0x83f3 else block[16:]
        expected = total_size(fmt, width, hflags)
        if len(raw) < expected:
            if fmt != 0x83f3 or len(raw) < mip_size(fmt, width, hflags & 0x7fff):
                raise ValueError('Cannot repair a missing top-level texture')
            height = hflags & 0x7fff
            top_size = mip_size(fmt, width, height)
            pixels = texture2ddecoder.decode_bc3(raw[:top_size], width, height)
            image = Image.frombytes('RGBA', (width, height), pixels, 'raw', 'BGRA')
            # Preserve the full-size DXT bytes exactly; generate only lower mips.
            mips = bytearray(raw[:top_size])
            w, h = width, height
            while w + h > 2:
                w, h = max(1, w >> 1), max(1, h >> 1)
                thumb = image.resize((w, h), Image.Resampling.BOX)
                stream = io.BytesIO()
                thumb.save(stream, format='DDS', pixel_format='DXT5')
                encoded = stream.getvalue()
                if encoded[:4] != b'DDS ' or len(encoded)-128 != mip_size(fmt, w, h):
                    raise ValueError('Unexpected DDS mip length')
                mips.extend(encoded[128:])
            if len(mips) != expected:
                raise ValueError('Regenerated mip chain length differs from engine')
            block = struct.pack('<HHHHII', hashed, fmt, width, hflags, len(mips)+4, 0)+mips
            repaired += 1
        adjusted[offset] = len(output)
        output.extend(block)
    dat.write_bytes(output)
    toc.write_bytes(struct.pack('<I',len(output))+struct.pack(f'<{len(offsets)}i',*(adjusted[x] if x >= 0 else x for x in offsets)))
    return repaired


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('archive',type=Path)
    parser.add_argument('directory',type=Path)
    parser.add_argument('output_zip',type=Path)
    args = parser.parse_args()
    args.directory.mkdir(parents=True,exist_ok=False)
    with ZipFile(args.archive) as source:
        for info in source.infolist():
            name = info.filename.replace('\\','/')
            if info.is_dir() or name.startswith(('storage/', 'Android/')):
                continue
            if Path(name).is_absolute() or '..' in Path(name).parts:
                raise ValueError('Unsafe archive path')
            # Engine INI/JSON files are assets, not automatically session state.
            # The original stream.ini is required by CStreaming::ReadIniFile.
            if (name.casefold().endswith('.log') or name.casefold() in SESSION_FILES
                    or any(part.startswith('.') for part in Path(name).parts)):
                continue
            texture = re.fullmatch(r'texdb/([^/]+)/\1\.(dxt|etc|pvr|unc|360)\.(dat|toc|tmb)',name)
            if texture:
                bank,fmt,ext = texture.groups()
                selected = 'pvr' if bank in ('player','playerhi') else 'dxt'
                if bank not in BANKS or fmt != selected:
                    continue
                name = f'texdb/{bank}/{bank}.dxt.{ext}'
            destination = args.directory/name
            destination.parent.mkdir(parents=True,exist_ok=True)
            with source.open(info) as src, destination.open('xb') as dst:
                shutil.copyfileobj(src,dst)
    repaired = repair_samp(args.directory)
    for bank in BANKS:
        result = audit_bank(args.directory/f'texdb/{bank}/{bank}.dxt.toc')
        if result['errors']:
            raise ValueError(result)
        print(bank,result['textures'],'validated',flush=True)
    # stream.ini is separately supplied/validated by BootConfig in the APK.
    # Keep it in the archive without changing the existing texture/DATA profile.
    stream = args.directory/'stream.ini'
    if not stream.is_file() or stream.stat().st_size != 197 or sha256(stream) != STREAM_HASH:
        raise ValueError('Missing/incompatible engine stream.ini')
    # ARM64 CTheScripts::Init reads two uint64 fields before any records.
    # The legacy custom SA-MP SCM has no named-variable migration dictionary.
    # Its SCV therefore contains count=0 and seed_length=0, not an empty file.
    metadata = args.directory/'SAMP/main.scv'
    metadata.write_bytes(struct.pack('<QQ', 0, 0))
    files = [{'path':str(path.relative_to(args.directory)), 'size':path.stat().st_size,'sha256':sha256(path)} for path in sorted(args.directory.rglob('*')) if path.is_file() and path not in (stream, metadata)]
    profile = {'schema':1,'id':'bcg-v023-dxt','texture_format':'dxt','engine_sha256':ENGINE_HASH,'repaired_samp_textures':repaired,'files':files}
    (args.directory/'bcg_data_profile.json').write_text(json.dumps(profile,indent=2)+'\n')
    if sha256(args.directory/'bcg_data_profile.json') != PROFILE_HASH:
        raise ValueError('Prepared DATA differs from the audited 319-file profile')
    args.output_zip.parent.mkdir(parents=True,exist_ok=True)
    with ZipFile(args.output_zip,'w',compression=ZIP_DEFLATED,compresslevel=6) as out:
        for path in sorted(args.directory.rglob('*')):
            if path.is_file():out.write(path,path.relative_to(args.directory))
    print('SAMP mip chains repaired:',repaired,flush=True)
    print('DATA bytes:',args.output_zip.stat().st_size,'sha256:',sha256(args.output_zip),flush=True)


if __name__ == '__main__':
    main()
