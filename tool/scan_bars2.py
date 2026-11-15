"""DPR 1 / 2 / 3 splash goruntulerinde sari alt cizgi var mi?"""
import os

from PIL import Image

OUT = r"C:\Users\alhndgn\Desktop\carkifelek-play"


def bars(path):
    im = Image.open(path).convert("RGB")
    W, H = im.size
    px = im.load()
    found = []
    for y in range(H):
        run = 0
        best = 0
        for x in range(W):
            r, g, b = px[x, y]
            if r > 220 and g > 220 and b < 90:
                run += 1
                best = max(best, run)
            else:
                run = 0
        if best > 60:
            found.append((y, best))
    return W, H, found


for name in ["_splash-dpr1.png", "_splash-dpr2.png", "splash-onizleme.png"]:
    p = os.path.join(OUT, name)
    if not os.path.exists(p):
        continue
    W, H, f = bars(p)
    print("%-20s %4dx%-4d bar_satiri=%d" % (name, W, H, len(f)))
    for y, w in f[:4]:
        print("      y=%4d uzunluk=%d" % (y, w))
