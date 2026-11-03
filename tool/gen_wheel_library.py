"""Web sürümündeki library.js'yi (66 çark) Dart sabit listesine dönüştürür."""
import io, json, os, re

SRC = r'C:\dev\projeler\cark\assets\js\library.js'
OUT = r'C:\dev\projeler\carkifelek\lib\core\wheel_library.dart'


def dart_str(s):
    s = str(s)
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    s = s.replace('\r', '').replace('\n', '\\n')
    return "'" + s + "'"


def main():
    raw = io.open(SRC, encoding='utf-8').read()
    m = re.search(r'window\.CARK_LIBRARY\s*=\s*(\[.*\])\s*;?\s*$', raw, re.S)
    data = json.loads(m.group(1))
    print('kaynak cark:', len(data))

    lines = []
    lines.append('// ÜRETİLMİŞ DOSYA — elle düzenleme. Kaynak: çark web sürümü kütüphanesi.')
    lines.append('// Dönüştürücü: tool/gen_wheel_library.py')
    lines.append('')
    lines.append('/// Hazır çark kütüphanesinden bir kayıt.')
    lines.append('class LibraryWheel {')
    lines.append('  const LibraryWheel({')
    lines.append('    required this.category,')
    lines.append('    required this.emoji,')
    lines.append('    required this.title,')
    lines.append('    required this.segments,')
    lines.append('  });')
    lines.append('')
    lines.append('  final String category;')
    lines.append('  final String emoji;')
    lines.append('  final String title;')
    lines.append('  final List<String> segments;')
    lines.append('}')
    lines.append('')
    lines.append('/// Kullanıcının tek dokunuşla ekleyebileceği hazır çarklar.')
    lines.append('const List<LibraryWheel> kWheelLibrary = <LibraryWheel>[')

    cats = []
    for w in data:
        if w['cat'] not in cats:
            cats.append(w['cat'])
        segs = ', '.join(dart_str(x) for x in w['items'])
        lines.append('  LibraryWheel(')
        lines.append('    category: %s,' % dart_str(w['cat']))
        lines.append('    emoji: %s,' % dart_str(w['emoji']))
        lines.append('    title: %s,' % dart_str(w['name']))
        lines.append('    segments: <String>[%s],' % segs)
        lines.append('  ),')
    lines.append('];')
    lines.append('')
    lines.append('/// Kütüphanedeki kategori sırası.')
    lines.append('const List<String> kWheelCategories = <String>[')
    for c in cats:
        lines.append('  %s,' % dart_str(c))
    lines.append('];')
    lines.append('')

    io.open(OUT, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
    print('yazildi:', OUT)
    print('cark:', len(data), '| kategori:', len(cats), '| satir:', len(lines))
    print('kategoriler:', ', '.join(cats))


main()
