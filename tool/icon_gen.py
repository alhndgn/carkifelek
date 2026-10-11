"""Çarkıfelek uygulama ikonu üretir (1024x1024 RGBA PNG, saf Python).

Tasarım: mor→mavi gradyan yuvarlatılmış kare zemin, 8 dilimli renkli çark,
beyaz halka ve beyaz göbek. 2x2 süper örnekleme ile kenar yumuşatma yapılır.
"""
import math
import struct
import zlib

SIZE = 1024
SS = 2  # süper örnekleme
CENTER = SIZE / 2
CORNER = 190.0
OUTER = 336.0
RING_INNER = 300.0
HUB = 78.0

PALETTE = [
    (0xE9, 0x4F, 0x6B),
    (0xF4, 0xB9, 0x42),
    (0x3F, 0xBF, 0x7F),
    (0x2F, 0xB7, 0xB0),
    (0x3E, 0x9B, 0xEF),
    (0x8B, 0x5C, 0xF6),
    (0xC2, 0x4F, 0xD1),
    (0xF2, 0x83, 0x3F),
]
GRAD_TOP = (0x8B, 0x5C, 0xF6)
GRAD_BOTTOM = (0x33, 0x27, 0x6B)
WHITE = (255, 255, 255)


def rounded_mask(x: float, y: float) -> bool:
    """Yuvarlatılmış kare maskesi."""
    inset = 0.0
    left, top = inset, inset
    right, bottom = SIZE - inset, SIZE - inset
    r = CORNER
    cx = min(max(x, left + r), right - r)
    cy = min(max(y, top + r), bottom - r)
    if left <= x <= right and top <= y <= bottom:
        d = math.hypot(x - cx, y - cy)
        return d <= r + 0.5
    return False


def sample(x: float, y: float):
    """Tek örnek için (r, g, b, a) döner."""
    if not rounded_mask(x, y):
        return (0, 0, 0, 0)

    t = y / SIZE
    bg = tuple(
        int(GRAD_TOP[i] + (GRAD_BOTTOM[i] - GRAD_TOP[i]) * t) for i in range(3)
    )

    dx = x - CENTER
    dy = y - CENTER
    r = math.hypot(dx, dy)

    if r > OUTER:
        return (bg[0], bg[1], bg[2], 255)

    if r > RING_INNER:  # beyaz halka
        return (WHITE[0], WHITE[1], WHITE[2], 255)

    if r <= HUB:  # göbek
        return (WHITE[0], WHITE[1], WHITE[2], 255)

    # dilim rengi: 0 radyan = üst, saat yönünde
    angle = math.atan2(dy, dx) + math.pi / 2
    angle = angle % (2 * math.pi)
    sector = (angle / (2 * math.pi)) * len(PALETTE)
    color = PALETTE[int(sector) % len(PALETTE)]

    # dilim sınırlarında ince beyaz ayırıcı
    frac = sector - int(sector)
    sweep_width = 0.055
    if frac < sweep_width or frac > 1 - sweep_width:
        return (WHITE[0], WHITE[1], WHITE[2], 255)

    # dıştan içe hafif koyulaşan gölge (derinlik hissi)
    depth = (r - HUB) / (RING_INNER - HUB)
    shade = 1.0 - 0.18 * depth
    return (
        int(color[0] * shade),
        int(color[1] * shade),
        int(color[2] * shade),
        255,
    )


def main() -> None:
    rows = []
    for py in range(SIZE):
        row = bytearray()
        row.append(0)  # filtre: none
        for px in range(SIZE):
            acc_r = acc_g = acc_b = acc_a = 0
            for sy in range(SS):
                for sx in range(SS):
                    x = px + (sx + 0.5) / SS
                    y = py + (sy + 0.5) / SS
                    r, g, b, a = sample(x, y)
                    acc_r += r * a
                    acc_g += g * a
                    acc_b += b * a
                    acc_a += a
            n = SS * SS
            if acc_a == 0:
                row += bytes((0, 0, 0, 0))
            else:
                row += bytes(
                    (
                        int(acc_r / acc_a),
                        int(acc_g / acc_a),
                        int(acc_b / acc_a),
                        int(acc_a / n),
                    )
                )
        rows.append(bytes(row))

    raw = b''.join(rows)

    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack('>I', len(data))
            + tag
            + data
            + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', SIZE, SIZE, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(raw, 9))
    png += chunk(b'IEND', b'')

    out = 'C:/dev/projeler/carkifelek/assets/icon/app_icon.png'
    import os

    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, 'wb') as f:
        f.write(png)
    print(f'ikon yazıldı: {out} ({len(png)} bayt)')


main()
