"""Sari piksellerin seklinin ASCII haritasini cikarir."""
from PIL import Image

p = r"C:\Users\alhndgn\Desktop\carkifelek-play\splash-onizleme.png"
im = Image.open(p).convert("RGB")
px = im.load()

def is_yellow(x, y):
    r, g, b = px[x, y]
    return r > 200 and g > 200 and b < 120

x0, x1, y0, y1 = 220, 900, 1015, 1085
print("bolge x=%d..%d y=%d..%d  (4px adim)" % (x0, x1, y0, y1))
for y in range(y0, y1, 4):
    line = ""
    for x in range(x0, x1, 4):
        line += "#" if is_yellow(x, y) else "."
    print("y=%4d %s" % (y, line))

# toplam sari piksel ve kutu
xs, ys = [], []
for y in range(0, im.size[1]):
    for x in range(0, im.size[0], 2):
        if is_yellow(x, y):
            xs.append(x); ys.append(y)
if xs:
    print("\nsari piksel: %d  x=%d..%d  y=%d..%d" % (len(xs), min(xs), max(xs), min(ys), max(ys)))
