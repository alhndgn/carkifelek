# Çarkıfelek 🎡

Seçenekleri yazıp çevirdiğin, kararı şansa bırakan Flutter uygulaması. Android öncelikli
(kendi telefonunda APK olarak çalışır), iOS sonraki etap — tek kod tabanı sayesinde iOS
tarafı sadece derleme meselesi olacak.

Tasarım ve plan belgeleri: `docs/superpowers/specs/`, `docs/superpowers/plans/`.
Ekran görüntüleri: `docs/ekranlar/`.

## Durum

- **M1 — İskelet ve çark listesi (tamam)**: tema, veri modeli, kalıcılık, durum yönetimi,
  çark listesi ekranı (oluştur / yeniden adlandır / çoğalt / sil), hazır şablonlar.
  37 test geçiyor, `flutter analyze` temiz.
- **M2 — Çark çizimi + dönüş animasyonu + sonuç ekranı** (sırada)
- **M3** — Dilim editörü ve ayarlar (eleme modu, süre, ses, titreşim)
- **M4** — Cila (ses, konfeti, ikon), imzalı APK ve telefona kurulum

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
flutter test                     # 37 test
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
