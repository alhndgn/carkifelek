"""Palet getter'lari yuzunden kirilan `const` anahtar sozcuklerini kaldirir.

Kural: hata satirinda `const` varsa onu, yoksa yukari dogru en yakin `const`
iceren satirdaki ilk `const ` ifadesini siler. Kaldirilan const, hatanin
governing const'idir (Dart'ta const ifade icindeki tum alt ifadeler const olmak
zorundadir).
"""
import subprocess, re, io, os
from collections import defaultdict

ROOT = r'C:\dev\projeler\carkifelek'
os.chdir(ROOT)
env = dict(os.environ)
env['PATH'] = r'C:\dev\flutter\bin;' + env.get('PATH', '')


def analyze_errors():
    out = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True,
                         env=env, shell=True).stdout
    return re.findall(r'error - .*? - (lib[^ :]+\.dart):(\d+):(\d+) - (\w+)', out)


def fix_round(errors):
    byfile = defaultdict(list)
    for f, line, col, code in errors:
        if code != 'invalid_constant':
            continue
        byfile[f.replace('/', os.sep)].append(int(line))

    touched = 0
    for f, lines in byfile.items():
        src = io.open(f, encoding='utf-8').read().split('\n')
        targets = set()
        for ln in set(lines):
            idx = ln - 1
            if idx >= len(src):
                continue
            if re.search(r'\bconst\b', src[idx]):
                targets.add(idx)
                continue
            for k in range(idx - 1, max(-1, idx - 8), -1):
                if re.search(r'\bconst\b', src[k]):
                    targets.add(k)
                    break
        for idx in sorted(targets, reverse=True):
            new = re.sub(r'\bconst\s+', '', src[idx], count=1)
            if new != src[idx]:
                src[idx] = new
                touched += 1
        io.open(f, 'w', encoding='utf-8', newline='\n').write('\n'.join(src))
    return touched


total = 0
for round_no in range(1, 7):
    errors = analyze_errors()
    invalid = [e for e in errors if e[3] == 'invalid_constant']
    print('tur %d: %d hata (%d invalid_constant)' % (round_no, len(errors), len(invalid)))
    if not invalid:
        break
    n = fix_round(errors)
    total += n
    print('   kaldirilan const:', n)

print('--- kalan hatalar:')
for e in analyze_errors()[:25]:
    print('  ', e[0], e[1], e[3])
print('TOPLAM kaldirilan const:', total)
