"""Iki ekranda yatay sari bar (alt cizgi) var mi diye bakar."""
from PIL import Image

FILES = [
    r"C:\Users\alhndgn\Desktop\carkifelek-play\_anaekran.png",
    r"C:\Users\alhndgn\Desktop\carkifelek-play\splash-onizleme.png",
]

def scan(p):
    im = Image.open(p).convert("RGB")
    W, H = im.size
    px = im.load()
    bars = []
    for y in range(H):
        run = 0
        best = 0
        start = None
        for x in range(W):
            r, g, b = px[x, y]
            if r > 220 and g > 220 and b < 90:
                if start is None:
                    start = x
                run += 1
                best = max(best, run)
            else:
                run = 0
        if best > 80:  # en az 80 px kesintisiz sari
            bars.append((y, best, start))
    return W, H, bars

for p in FILES:
    W, H, bars = scan(p)
    print("%-18s %dx%d  uzun sari bar satiri: %d" % (p.split("\\")[-1], W, H, len(bars)))
    for y, w, s in bars[:10]:
        print("      y=%4d  uzunluk=%d  baslangic_x=%s" % (y, w, s))
