"""8 cark gorunumunu tek kontak sayfasinda birlestirir + bos render kontrolu."""
import os
from collections import Counter

from PIL import Image, ImageDraw, ImageFont

SRC = r"C:\dev\projeler\carkifelek\store\styles"
OUT = r"C:\dev\projeler\carkifelek\store\styles-kontak.png"

ADLAR = {
    "classic": "Klasik", "donut": "Halka", "target": "Hedef", "needle": "İbre",
    "petal": "Çiçek (yeni)", "star": "Yıldız (yeni)",
    "pinwheel": "Rüzgâr Gülü (yeni)", "segments": "Bölmeli (yeni)",
}

dosyalar = sorted(
    [f for f in os.listdir(SRC) if f.endswith(".png")],
    key=lambda f: int(f.split("-")[0]),
)

CELL_W, CELL_H, LABEL_H = 360, 640, 46

def font(size):
    for ad in ("segoeuib.ttf", "segoeui.ttf", "arialbd.ttf"):
        p = os.path.join(r"C:\Windows\Fonts", ad)
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    return ImageFont.load_default()

f = font(26)

cols, rows = 4, 2
sheet = Image.new("RGB", (CELL_W * cols, (CELL_H + LABEL_H) * rows), (13, 11, 24))
draw = ImageDraw.Draw(sheet)

for idx, ad in enumerate(dosyalar):
    key = ad.split("-", 1)[1].replace(".png", "")
    im = Image.open(os.path.join(SRC, ad)).convert("RGB")

    # bos/bozuk render kontrolu: cark bolgesindeki renk cesitliligi
    w, h = im.size
    crop = im.crop((int(w * 0.15), int(h * 0.20), int(w * 0.85), int(h * 0.62)))
    renk = Counter(crop.resize((60, 60)).getdata())
    print("%-28s %dx%d  farkli renk: %d" % (ad, w, h, len(renk)))

    im = im.resize((CELL_W, CELL_H), Image.LANCZOS)
    col, row = idx % cols, idx // cols
    x, y = col * CELL_W, row * (CELL_H + LABEL_H)

    draw.rectangle([x, y, x + CELL_W, y + LABEL_H], fill=(25, 21, 49))
    etiket = ADLAR.get(key, key)
    tw = draw.textlength(etiket, font=f)
    draw.text((x + (CELL_W - tw) / 2, y + 9), etiket, font=f, fill=(244, 241, 255))
    sheet.paste(im, (x, y + LABEL_H))

sheet.save(OUT, "PNG", optimize=True)
print("\nkontak sayfa: %s  %dx%d  %.0f KB" % (OUT, sheet.size[0], sheet.size[1], os.path.getsize(OUT) / 1024))
