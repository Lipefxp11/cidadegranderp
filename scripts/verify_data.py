#!/usr/bin/env python3
"""Check mobile texture indices, headers and every native RLE mip chain.

Uses only the Python standard library. No game assets are distributed here.
Pass an extracted DATA directory. The native format is derived from the
TextureListing/GetTotalSize and RLEDecompress functions of this client's engine.
"""
from __future__ import annotations
import argparse
import json
import re
import struct
from pathlib import Path


def name_hash(name: str) -> int:
    value = 0
    for byte in name.encode('ascii'):
        value = (value * 33 + byte) & 0xffffffff
    return ((value + (value >> 5)) & 0xffffffff) & 0xffff


def mip_size(fmt: int, width: int, height: int) -> int:
    if fmt in (0x83f0, 0x83f1, 0x8d64):
        return max(4, width) * max(4, height) // 2
    if fmt in (0x83f2, 0x83f3):
        return max(4, width) * max(4, height)
    if fmt in (0x8c00, 0x8c02):
        return max(8, width) * max(8, height) // 2
    if fmt in (0x8c01, 0x8c03):
        return max(16, width) * max(8, height) // 4
    if fmt in (0x8033, 0x8034, 0x8363, 0x190a):
        return width * height * 2
    if fmt == 0x1401:
        return width * height * 4
    if fmt == 0x1909:
        return width * height
    raise ValueError(f'unknown encoding 0x{fmt:x}')


def total_size(fmt: int, width: int, height_field: int) -> int:
    height = height_field & 0x7fff
    if not width or not height or width > 4096 or height > 4096:
        raise ValueError('invalid texture dimensions')
    result = mip_size(fmt, width, height)
    if height_field & 0x8000:
        while width + height > 2:
            width, height = max(1, width >> 1), max(1, height >> 1)
            result += mip_size(fmt, width, height)
    return result


def check_rle(payload: bytes, target: int, fmt: int, marker: int) -> None:
    segment = 8 if fmt in (0x83f0, 0x83f1, 0x8d64) else 16 if fmt in (0x83f2, 0x83f3, 0x8c00, 0x8c02) else 32 if fmt in (0x8c01, 0x8c03) else 4
    cursor = expanded = 0
    while expanded < target:
        if cursor >= len(payload):
            raise ValueError('RLE source exhausted before the final mip')
        repeat = 1
        if payload[cursor] == marker:
            if cursor + 2 > len(payload):
                raise ValueError('incomplete RLE marker')
            repeat = payload[cursor + 1]
            cursor += 2
            if repeat == 0:
                raise ValueError('zero RLE run')
        if cursor + segment > len(payload):
            raise ValueError('truncated RLE segment')
        expanded += repeat * segment
        cursor += segment
        if expanded > (target + segment - 1) // segment * segment:
            raise ValueError('RLE run writes beyond native allocation')


def audit_bank(toc: Path) -> dict:
    dat = toc.with_suffix('.dat')
    txt = toc.with_suffix('').with_suffix('.txt')
    result = {'bank': toc.name, 'textures': 0, 'errors': [], 'encodings': []}
    try:
        raw = toc.read_bytes()
        size = dat.stat().st_size
        if len(raw) < 8 or len(raw) % 4:
            raise ValueError('unaligned TOC')
        if struct.unpack_from('<I', raw)[0] != size:
            raise ValueError(f'TOC/DAT size mismatch: {struct.unpack_from("<I", raw)[0]} / {size}')
        offsets = list(struct.unpack(f'<{len(raw)//4 - 1}i', raw[4:]))
        lines = [line.strip() for line in txt.read_text().splitlines() if line.strip()]
        if not lines or not lines[0].startswith('cat=') or len(offsets) != len(lines)-1:
            raise ValueError(f'TXT/TOC count mismatch: {len(lines)-1} / {len(offsets)}')
        if any(x < -1 or x >= size for x in offsets):
            raise ValueError('TOC offset outside DAT')
        limits = sorted(set(x for x in offsets if x >= 0) | {size})
        ends = dict(zip(limits, limits[1:]))
        encodings = set()
        expected_hashes = set()
        with dat.open('rb') as stream:
            for line, offset in zip(lines[1:], offsets):
                if line.startswith('cat='):
                    continue
                match = re.fullmatch(r'"([^"]+)"(.*)', line)
                if not match:
                    raise ValueError('invalid TXT entry')
                name = match[1]
                expected_hashes.add(name_hash(name))
                result['textures'] += 1
                if offset < 0:
                    continue
                try:
                    length = ends[offset] - offset
                    if length < 16 or length > 64 * 1024 * 1024:
                        raise ValueError('invalid block length')
                    stream.seek(offset)
                    header = stream.read(16)
                    hashed, fmt, width, height, stored, marker = struct.unpack('<HHHHII', header)
                    encodings.add(fmt)
                    if hashed != name_hash(name):
                        raise ValueError('name hash differs from DAT header')
                    needed = total_size(fmt, width, height)
                    available = length - 16
                    if stored != available + 4:
                        raise ValueError(f'native stored length mismatch: {stored} / {available + 4}')
                    payload = stream.read(available)
                    if marker:
                        if marker > 255:
                            raise ValueError('invalid RLE marker')
                        check_rle(payload, needed, fmt, marker)
                    elif available < needed:
                        raise ValueError(f'uncompressed mip data truncated: {available} / {needed}')
                except (ValueError, struct.error) as error:
                    result['errors'].append(f'{name}: {error}')
        result['encodings'] = [f'0x{value:04x}' for value in sorted(encodings)]
        thumbnails = toc.with_suffix('.tmb').read_bytes()
        cursor = 0
        while cursor < len(thumbnails):
            if cursor + 16 > len(thumbnails):
                raise ValueError('TMB header truncated')
            hashed, fmt, width, height, stored, marker = struct.unpack_from('<HHHHII', thumbnails, cursor)
            length = stored - 4
            if length < 0 or cursor + 16 + length > len(thumbnails):
                raise ValueError('TMB record exceeds file')
            if hashed not in expected_hashes:
                raise ValueError('TMB hash has no matching TXT entry')
            target = total_size(fmt, width, height)
            payload = thumbnails[cursor+16:cursor+16+length]
            if marker:
                check_rle(payload, target, fmt, marker)
            elif length < target:
                raise ValueError('TMB texture truncated')
            cursor += 16 + length
    except (OSError, ValueError, struct.error) as error:
        result['errors'].append(str(error))
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path)
    parser.add_argument('--format', choices=['dxt', 'etc', 'pvr'])
    args = parser.parse_args()
    banks = sorted((args.directory/'texdb').glob('*/*.toc'))
    if args.format:
        banks = [x for x in banks if x.name.endswith('.'+args.format+'.toc')]
    valid = bool(banks)
    for toc in banks:
        result = audit_bank(toc)
        valid &= not result['errors']
        result['error_count'] = len(result['errors'])
        result['errors'] = result['errors'][:8]
        print(json.dumps(result, ensure_ascii=False), flush=True)
    return 0 if valid else 1


if __name__ == '__main__':
    raise SystemExit(main())
