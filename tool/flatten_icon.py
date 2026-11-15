"""Play ikonundaki seffafligi, ikonun kendi kenar rengiyle doldurur."""
import os
from collections import Counter

from PIL import Image

BASE = r"C:\Users\alhndgn\Desktop\carkifelek-play"
SRC = os.path.join(BASE, "icon-512.png")

im = Image.open(SRC).convert("RGBA")
W, H = im.size
px = im.load()

# Kenar bolgesindeki opak piksellerin baskin rengi
c = Counter()
for y in range(0, H, 2):
    for x in range(0, W, 2):
        if x < 24 or y < 24 or x > W - 24 or y > H - 24:
            r, g, b, a = px[x, y]
            if a >= 250:
                c[(r, g, b)] += 1

arka = c.most_common(1)[0][0] if c else (13, 11, 24)
print("  baskin kenar rengi: RGB%s" % (arka,))

payet = Image.new("RGB", im.size, arka)
payet.paste(im, mask=im.getchannel("A"))
out = os.path.join(BASE, "icon-512.png")
payet.save(out, "PNG", optimize=True)

# dogrula
chk = Image.open(out)
alfa = chk.convert("RGBA").getchannel("A").getextrema()
print("  yeni mod: %s  boyut: %dx%d  %.0f KB  alfa aralik: %s"
      % (chk.mode, chk.size[0], chk.size[1], os.path.getsize(out) / 1024, alfa))
