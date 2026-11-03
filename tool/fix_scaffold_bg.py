"""Scaffold'un kendi `backgroundColor: Colors.transparent` satirini kaldirir.

Tema `scaffoldBackgroundColor` veriyor; widget seviyesindeki transparent bunu
eziyor ve AppBar arkasinda pencere rengi (beyaz) siziyordu.
FAB/AppBar gibi diger transparent kullanimlarina DOKUNMAZ.
"""
import io, os

ROOT = r'C:\dev\projeler\carkifelek'
files = [
    'lib/screens/library_screen.dart',
    'lib/screens/wheel_editor_screen.dart',
    'lib/screens/wheel_list_screen.dart',
    'lib/screens/wheel_screen.dart',
]

for rel in files:
    p = os.path.join(ROOT, rel)
    lines = io.open(p, encoding='utf-8').read().split('\n')
    out = []
    removed = 0
    for i, line in enumerate(lines):
        is_target = (
            line.strip() == 'backgroundColor: Colors.transparent,'
            and i > 0
            and 'Scaffold(' in lines[i - 1]
        )
        if is_target:
            removed += 1
            continue
        out.append(line)
    if removed:
        io.open(p, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
    print('%-42s kaldirilan: %d' % (rel, removed))
