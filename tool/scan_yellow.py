"""Ayni sarimsi-cizgi imzasini iki ekran goruntusunde karsilastirir."""
import os

from PIL import Image

BASE = r"C:\Users\alhndgn\Desktop\carkifelek-play"

for name in ["phone-1-cark.png", "splash-onizleme.png", "phone-3-kutuphane.png"]:
    p = os.path.join(BASE, name)
    if not os.path.exists(p):
        print(name, "yok")
        continue
    im = Image.open(p).convert("RGB")
    W, H = im.size
    px = im.load()
    total = 0
    rows = []
    for y in range(0, H, 2):
        c = 0
        for x in range(0, W, 2):
            r, g, b = px[x, y]
            if r > 150 and g > 120 and b < 110 and (r - b) > 60:
                c += 1
        if c > 20:
            rows.append((y, c))
            total += c
    print("%-22s %dx%d  sari_satir=%d  piksel=%d" % (name, W, H, len(rows), total))
    for y, c in rows[:5]:
        print("     y=%4d adet=%d" % (y, c))
