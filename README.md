# Çarkıfelek 🎡

Seçenekleri yazıp çevirdiğin, kararı şansa bırakan Flutter uygulaması. Android öncelikli
(kendi telefonunda APK olarak çalışır), iOS sonraki etap — tek kod tabanı sayesinde iOS
tarafı sadece derleme meselesi olacak.

Tasarım ve plan belgeleri: `docs/superpowers/specs/`, `docs/superpowers/plans/`.
Ekran görüntüleri: `docs/ekranlar/`.

## Durum

- **M1 — İskelet ve çark listesi (tamam)**: tema, veri modeli, kalıcılık, durum yönetimi,
  çark listesi ekranı (oluştur / yeniden adlandır / çoğalt / sil), hazır şablonlar.
- **M2 — Çark ve dönüş (tamam)**: `CustomPainter` çark (12 renkli palet, radyal yazılar),
  sabit ibre, 5 sn'lik yavaşlayan dönüş (`easeOutQuart`, 5-8 tam tur), dilim sınırında
  tik sesi + titreşim, konfetili kazanan kartı, eleme modu. **57 test**, analyze temiz.
- **M3 — Dilim editörü ve ayarlar (tamam)**: sürükle-sırala, satır düzenleme, silme,
  toplu yapıştırma (her satır bir seçenek), "en az 2 / 24 üstü / yinelenen" uyarıları,
  kaydedilmemiş değişiklik onayı; ayarlar sayfası (eleme modu, dönüş süresi, tik sesi,
  titreşim). **70 test**, analyze temiz.
- **M4 — Cila ve APK (tamam)**: çark ikonu (`tool/icon_gen.py` ile üretilir → adaptive ikon tüm
  yoğunluklarda), uygulama adı "Çarkıfelek", çark için ekran okuyucu etiketi,
  `flutter build apk --release` → **`dist/carkifelek-1.0.0.apk`** (50 MB, 3 ABI, debug
  anahtarıyla imzalı → kendi telefonuna kurulabilir).

## Telefona kurulum

1. `dist/carkifelek-1.0.0.apk` dosyasını telefona kopyala (USB, Drive, Telegram…).
2. Telefonda dosyaya dokun → "bilinmeyen kaynaklardan kuruluma izin ver" → **Kur**.
   (Play Protect'in "bilinmeyen geliştirici" uyarısı normaldir: debug anahtarıyla imzalı.)
3. USB ile hızlı yol (Geliştirici seçenekleri + USB hata ayıklama açıkken):
   `adb install -r dist/carkifelek-1.0.0.apk`

Play Store'a çıkmak istersen: keystore üret (`keytool -genkey -v -keystore upload-keystore.jks
-keyalg RSA -keysize 2048 -validity 10000 -alias upload`), `android/key.properties` ile imzayı
bağla, `flutter build appbundle --release` → 25$ hesap + AAB yüklemesi.

## Geliştirme ortamı (bu makine)

| Araç | Yol |
|---|---|
| Flutter 3.47.7 (Dart 3.13.5) | `C:\dev\flutter` |
| JDK 21 (Temurin) | `C:\dev\jdk-21.0.12.1+1` |
| Android SDK (platform 36, build-tools 36, platform-tools) | `C:\dev\android-sdk` |

Ortam değişkenleri kullanıcı hesabına kalıcı yazıldı (`JAVA_HOME`, `ANDROID_HOME`,
`ANDROID_SDK_ROOT`, PATH). Yeni terminal oturumunda elle yüklemek için:

```bash
source /c/dev/flutter-env.sh
```

## Komutlar

```bash
flutter analyze                  # statik analiz (0 hata olmalı)
flutter test                     # 57 test
flutter build web --release      # hızlı görsel test için web derlemesi
flutter run -d edge              # Edge'de canlı önizleme
flutter build apk --release      # telefona kurulacak APK (M4)
```

Web derlemesini yerel sunucuda açmak:

```bash
cd build/web && python -m http.server 8123 --bind 127.0.0.1   # http://localhost:8123
```

## Mimari

```
lib/
├── main.dart                  # SharedPreferences'ı yükleyip provider'a enjekte eder
├── app.dart                   # MaterialApp.router + tema
├── router.dart                # go_router rotaları
├── models/wheel.dart          # çark veri modeli (saf Dart)
├── data/
│   ├── key_value_store.dart   # kalıcılık arayüzü + shared_preferences uygulaması
│   └── wheel_repository.dart  # JSON kaydet/oku (bozuk veriye dayanıklı)
├── state/
│   ├── app_providers.dart     # global provider'lar
│   └── wheel_list_provider.dart  # oluştur/sil/çoğalt/eleme mantığı
├── screens/                   # çark listesi, çark detayı
├── widgets/                   # kart, mini çark, boş durum, metin diyaloğu
└── theme/                     # koyu tema, 12 renkli palet, 8pt ızgara
```

Veri akışı: `screens` → `state` → `data` → `models`. Model ve repository Flutter'dan bağımsız,
bu yüzden unit testleri hızlı ve güvenilir.

## Bilinen tasarım kararları

- Kalıcılık `shared_preferences` + dizi şeması (`wheels_v1`). Şema değişirse `wheels_v2`
  eklenip eski anahtar dönüştürülür.
- Depo okuması hata fırlatsa veya JSON bozuk olsa bile uygulama açılır (boş listeyle) —
  beyaz ekran yok. (Bu davranış web'de gerçek bir hatayla yakalandı ve testle korundu.)
- Eleme modunda çark 1 seçeneğe düşerse çevirme kilitlenir ve kullanıcı uyarılır.
- Diyaloglar metin alanını kendi State'inde yönetir; `TextEditingController` diyaloğun
  kapanış animasyonu bitmeden dispose edilmez.
