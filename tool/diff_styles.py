"""Gorunumlerin birbirinden gercekten farkli oldugunu olcer."""
import itertools
import os

from PIL import Image, ImageChops, ImageStat

SRC = r"C:\dev\projeler\carkifelek\store\styles"
dosyalar = sorted(
    [f for f in os.listdir(SRC) if f.endswith(".png")],
    key=lambda f: int(f.split("-")[0]),
)

# Cark bolgesine kirp, kucult (hizli karsilastirma)
kesitler = {}
for ad in dosyalar:
    im = Image.open(os.path.join(SRC, ad)).convert("L")
    w, h = im.size
    kesitler[ad.split("-", 1)[1].replace(".png", "")] = im.crop(
        (int(w * 0.15), int(h * 0.20), int(w * 0.85), int(h * 0.62))
    ).resize((120, 120))

print("ikili ortalama fark (dusuk = benzer):")
en_kucuk = None
for a, b in itertools.combinations(kesitler, 2):
    d = ImageStat.Stat(ImageChops.difference(kesitler[a], kesitler[b])).mean[0]
    if en_kucuk is None or d < en_kucuk[0]:
        en_kucuk = (d, a, b)
    if d < 12:
        print("  !! COK BENZER: %-10s / %-10s  fark=%.1f" % (a, b, d))

print("\nen dusuk fark: %.1f  (%s vs %s)" % en_kucuk)
print("toplam karsilastirma: %d" % len(list(itertools.combinations(kesitler, 2))))
