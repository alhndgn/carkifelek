import subprocess, re, io, os
from collections import defaultdict

ROOT = r'C:\dev\projeler\carkifelek'
os.chdir(ROOT)

env = dict(os.environ)
env['PATH'] = r'C:\dev\flutter\bin;' + env.get('PATH', '')

out = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True,
                     env=env, shell=True).stdout

locs = re.findall(r'error - .*? - (lib[^ :]+\.dart):(\d+):(\d+) - invalid_constant', out)
byfile = defaultdict(list)
for f, l, c in locs:
    byfile[f.replace('/', os.sep)].append(int(l))

print('TOPLAM:', len(locs), 'hata,', len(byfile), 'dosya')
for f, lines in byfile.items():
    src = io.open(f, encoding='utf-8').read().split('\n')
    print('==', f.replace(os.sep, '/'))
    for ln in sorted(set(lines)):
        for i in range(max(1, ln - 3), min(len(src), ln) + 1):
            marker = '>>' if i == ln else '  '
            print('  %s %4d| %s' % (marker, i, src[i - 1]))
        print('  --')
