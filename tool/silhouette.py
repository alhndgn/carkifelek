"""Her gorunumun siluetini olcer: aciya gore dis yaricap ve cikinti sayisi."""
import math
import os

from PIL import Image

SRC = r"C:\dev\projeler\carkifelek\store\styles"
dosyalar = sorted(
    [f for f in os.listdir(SRC) if f.endswith(".png")],
    key=lambda f: int(f.split("-")[0]),
)


def renkli(px, x, y):
    r, g, b = px[x, y]
    return (max(r, g, b) - min(r, g, b)) > 42 and max(r, g, b) > 70


for ad in dosyalar:
    im = Image.open(os.path.join(SRC, ad)).convert("RGB")
    W, H = im.size
    px = im.load()
    # cark merkezi: goruntunun yatay ortasi, carkin dikey merkezi ~ %40
    cx, cy = W // 2, int(H * 0.40)
    rmax = int(W * 0.48)

    profil = []
    for step in range(0, 360, 5):
        a = math.radians(step - 90)
        son = 0
        for rr in range(10, rmax, 2):
            x = int(cx + math.cos(a) * rr)
            y = int(cy + math.sin(a) * rr)
            if 0 <= x < W and 0 <= y < H and renkli(px, x, y):
                son = rr
        profil.append(son / rmax)

    if not profil:
        continue
    mn, mx = min(profil), max(profil)
    # yerel tepe sayisi (cikintilar)
    tepeler = 0
    for i in range(len(profil)):
        if profil[i] > profil[i - 1] and profil[i] >= profil[(i + 1) % len(profil)]:
            tepeler += 1
    ort = sum(profil) / len(profil)
    print("%-22s  min/ort/max = %.3f / %.3f / %.3f   salinim=%.3f   tepe=%d"
          % (ad, mn, ort, mx, mx - mn, tepeler))
