"""Paint rectangles over regions of an 8-bit RGB/RGBA PNG (no external libraries).

Usage: python3 -I redact.py in.png out.png x0,y0,x1,y1 [x0,y0,x1,y1 ...]
Each rectangle is filled with the color of the pixel just left of it.
"""
import struct
import sys
import zlib


def read_png(path):
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, chunks = 8, b"", []
    while pos < len(data):
        n = struct.unpack(">I", data[pos:pos + 4])[0]
        typ = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + n]
        pos += 12 + n
        if typ == b"IHDR":
            w, h, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", body)
        elif typ == b"IDAT":
            idat += body
        chunks.append((typ, body))
    assert depth == 8 and ctype in (2, 6) and interlace == 0, (depth, ctype, interlace)
    bpp = 3 if ctype == 2 else 4
    raw = zlib.decompress(idat)
    stride = w * bpp
    rows, prev, i = [], bytearray(stride), 0
    for _ in range(h):
        f = raw[i]
        line = bytearray(raw[i + 1:i + 1 + stride])
        i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        rows.append(line)
        prev = line
    return w, h, ctype, bpp, rows, chunks


def write_png(path, w, h, ctype, rows, chunks):
    def chunk(typ, body):
        return struct.pack(">I", len(body)) + typ + body + struct.pack(">I", zlib.crc32(typ + body) & 0xFFFFFFFF)

    raw = b"".join(b"\x00" + bytes(r) for r in rows)
    out = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, ctype, 0, 0, 0))
    # keep only color-related ancillary chunks; drop text/metadata chunks
    for typ, body in chunks:
        if typ in (b"sRGB", b"gAMA", b"cHRM", b"pHYs", b"iCCP"):
            out += chunk(typ, body)
    out += chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    open(path, "wb").write(out)


src, dst, rects = sys.argv[1], sys.argv[2], sys.argv[3:]
w, h, ctype, bpp, rows, chunks = read_png(src)
for r in rects:
    x0, y0, x1, y1 = map(int, r.split(","))
    for y in range(y0, y1):
        fill = rows[y][(x0 - 3) * bpp:(x0 - 2) * bpp]
        for x in range(x0, x1):
            rows[y][x * bpp:(x + 1) * bpp] = fill
write_png(dst, w, h, ctype, rows, chunks)
print("wrote", dst, w, h)
