"""Sari bantlarin tam RGB degerini ve dikey profilini yazar."""
import os
from collections import Counter

from PIL import Image

p = r"C:\Users\alhndgn\Desktop\carkifelek-play\splash-onizleme.png"
im = Image.open(p).convert("RGB")
W, H = im.size
px = im.load()

print("boyut:", W, H)
print("\n--- y=1030..1070 arasi, x=100..300 (her 4 px) ---")
for y in range(1030, 1072, 4):
    satir = []
    for x in range(100, 300, 8):
        r, g, b = px[x, y]
        satir.append("%02X%02X%02X" % (r, g, b))
    print("y=%4d  %s" % (y, " ".join(satir)))

print("\n--- sari bant piksel renkleri (y=1040..1052) ---")
c = Counter()
for y in range(1040, 1053):
    for x in range(0, W, 2):
        r, g, b = px[x, y]
        if r > 150 and g > 120 and b < 110 and (r - b) > 60:
            c[(r, g, b)] += 1
for col, n in c.most_common(6):
    print("   RGB%s  adet=%d" % (col, n))

print("\n--- bant x araligi (y=1046) ---")
xs = [x for x in range(W) if (lambda t: t[0] > 150 and t[1] > 120 and t[2] < 110)(px[x, 1046])]
print("   ilk=%s son=%s adet=%d" % (xs[0] if xs else None, xs[-1] if xs else None, len(xs)))
