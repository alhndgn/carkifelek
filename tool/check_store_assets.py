"""Play magaza girisi: metin uzunluklari ve gorsel kurallari kontrolu."""
import os

from PIL import Image

BASE = r"C:\Users\alhndgn\Desktop\carkifelek-play"

kisa_a = "Kararsız kalınca çarkı çevir: 66 hazır çark, 4 görünüm, 6 tema."
kisa_b = "Ne yiyelim, kim ödesin? Çarkı çevir, kararı şansa bırak. Reklamsız."
kisa_c = "Kararsız kalınca çarkı çevir. 66 hazır çark, 4 görünüm, 6 tema."

for etiket, metin in [("A", kisa_a), ("B", kisa_b), ("C", kisa_c)]:
    n = len(metin)
    print("kisa %s: %3d/80  %s  %s" % (etiket, n, "OK " if n <= 80 else "UZUN", metin))

print()
for ad in ["icon-512.png", "feature-graphic.png", "phone-1-cark.png",
           "phone-2-hedef.png", "phone-3-kutuphane.png", "phone-4-temalar.png"]:
    p = os.path.join(BASE, ad)
    if not os.path.exists(p):
        print("%-22s YOK" % ad)
        continue
    im = Image.open(p)
    w, h = im.size
    kb = os.path.getsize(p) / 1024
    oran = w / h
    alpha = im.mode in ("RGBA", "LA")
    seffaf = False
    if alpha:
        a = im.convert("RGBA").getchannel("A")
        seffaf = a.getextrema()[0] < 255
    print("%-22s %4dx%-4d %6.0f KB  oran=%.3f  seffaflik=%s"
          % (ad, w, h, kb, oran, "VAR!" if seffaf else "yok"))
