"""Play yayını için upload keystore üretir; şifreleri sohbete yazmaz.

- android/app/upload-keystore.jks  (imza anahtarı)
- android/key.properties           (gradle okur, .gitignore'da)
- ~/carkifelek-yayin-bilgileri.txt (kullanıcı için yedek not)
"""
import io, os, secrets, string, subprocess, sys, time

ROOT = r'C:\dev\projeler\carkifelek'
APP = os.path.join(ROOT, 'android', 'app')
STORE = os.path.join(APP, 'upload-keystore.jks')
PROPS = os.path.join(ROOT, 'android', 'key.properties')
VAULT = os.path.join(os.path.expanduser('~'), 'carkifelek-yayin-bilgileri.txt')

KEYTOOL = r'C:\dev\jdk-21\bin\keytool.exe'
if not os.path.exists(KEYTOOL):
    # jdk klasörünü bul
    base = r'C:\dev'
    for d in os.listdir(base):
        if d.startswith('jdk') and os.path.exists(os.path.join(base, d, 'bin', 'keytool.exe')):
            KEYTOOL = os.path.join(base, d, 'bin', 'keytool.exe')
            break

if not os.path.exists(KEYTOOL):
    print('HATA: keytool bulunamadi')
    sys.exit(1)

ALIAS = 'upload'
if os.path.exists(STORE):
    print('  upload-keystore.jks zaten var, dokunulmadi (yedek onemli!)')
    sys.exit(0)

alphabet = string.ascii_letters + string.digits
password = ''.join(secrets.choice(alphabet) for _ in range(28))

env = dict(os.environ)
env['CARKPASS'] = password

cmd = [
    KEYTOOL, '-genkeypair',
    '-v',
    '-keystore', STORE,
    '-alias', ALIAS,
    '-keyalg', 'RSA', '-keysize', '2048',
    '-validity', '10000',
    '-storepass:env', 'CARKPASS',
    '-keypass:env', 'CARKPASS',
    '-dname', 'CN=Teq Studio, OU=Mobile, O=Teq Studio, L=Istanbul, ST=Istanbul, C=TR',
]
r = subprocess.run(cmd, capture_output=True, text=True, env=env)
print('  keytool cikis kodu:', r.returncode)
if r.returncode != 0:
    print('  hata:', (r.stderr or r.stdout)[-600:])
    sys.exit(1)

props = (
    '# Play yayini icin upload anahtari — bu dosya paylasilmaz.\n'
    'storePassword=%s\n'
    'keyPassword=%s\n'
    'keyAlias=%s\n'
    'storeFile=upload-keystore.jks\n'
) % (password, password, ALIAS)
io.open(PROPS, 'w', encoding='utf-8', newline='\n').write(props)

vault = (
    'CARKIFELEK — GOOGLE PLAY YAYIN BILGILERI\n'
    'Olusturma: %s\n'
    '\n'
    '!!! BU DOSYAYI KAYBETME. Upload anahtari ve sifresi burada.\n'
    '!!! Play App Signing acikken bile ileride yeni surum yuklemek icin gerekir.\n'
    '\n'
    'Keystore dosyasi : android/app/upload-keystore.jks\n'
    'Alias            : %s\n'
    'Store sifresi     : %s\n'
    'Key sifresi       : %s\n'
    '\n'
    'GUVENLI YEDEK: keystore dosyasini ve bu notu sifreli bir yere (bulut/disk) kopyala.\n'
    'Kaybedersen ayni paket adiyla guncelleme yayinlayamazsin (Play destek ile cozulur, uzun surer).\n'
) % (time.strftime('%Y-%m-%d %H:%M'), ALIAS, password, password)
io.open(VAULT, 'w', encoding='utf-8', newline='\n').write(vault)

print('  keystore:', STORE, os.path.getsize(STORE), 'bayt')
print('  key.properties yazildi (gitignore kapsaminda)')
print('  yedek not:', VAULT)
print('  (sifreler sohbete YAZILMADI)')
