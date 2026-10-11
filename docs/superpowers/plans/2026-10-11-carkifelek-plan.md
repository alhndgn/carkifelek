# Çarkıfelek — Uygulama Planı

Spec: `docs/superpowers/specs/2026-10-11-carkifelek-design.md` (onaylandı: 2026-10-11)
Proje: `C:\dev\projeler\carkifelek` · Paket: `com.ezforme.carkifelek`

## Global kurallar (her görevde geçerli)

1. Küçük, tek sorumluluklu dosyalar. Katman sınırı: `screens` → `state` → `data` → `models`.
   `models` ve `core` hiçbir zaman `screens`/`state`'i import etmez.
2. Her yeni davranış için önce test (unit/widget), sonra uygulama.
3. Bir kilometre taşı, `flutter analyze` **ve** `flutter test` temiz olmadan bitmiş sayılmaz.
4. Kullanıcıya görünen tüm metinler Türkçe; kod/isimler İngilizce.
5. Her taş sonunda git commit (`feat:` / `test:` / `chore:`).
6. Kanıt: çalışan uygulamadan ekran görüntüsü (web/desktop hedefi veya cihaz).

| # | Görev | Dosyalar | Doğrulama |
|---|---|---|---|
| **M1 — İskelet ve çark listesi** | | | |
| M1.1 | Proje iskeleti + bağımlılıklar + git | `pubspec.yaml`, `.gitignore` | `flutter pub get` hatasız |
| M1.2 | Tema ve palet | `lib/theme/app_theme.dart`, `lib/theme/palette.dart`, `lib/theme/spacing.dart` | `flutter analyze` temiz |
| M1.3 | Veri modeli | `lib/models/wheel.dart` | unit: `toJson`/`fromJson` gidiş-dönüş |
| M1.4 | Kalıcılık | `lib/data/wheel_repository.dart` | unit: kaydet-yükle-sil, bozuk JSON'da çökmeme |
| M1.5 | Durum yönetimi | `lib/state/wheel_list_provider.dart` | unit: ekle/sil/kopyala/eleme |
| M1.6 | Çark listesi ekranı | `lib/screens/wheel_list_screen.dart`, `lib/widgets/wheel_card.dart`, `lib/widgets/empty_state.dart`, `lib/core/templates.dart` | widget testi + ekran görüntüsü |
| M1.7 | Uygulama kabuğu + router | `lib/main.dart`, `lib/app.dart`, `lib/router.dart` | uygulama açılıyor, taş kapanışı |
| **M2 — Çark ve dönüş** | | | |
| M2.1 | Dönüş matematiği (saf Dart) | `lib/core/spin_math.dart` | unit: açı→indeks, 10.000 denemede tekdüze dağılım |
| M2.2 | Çark çizimi | `lib/widgets/spin_wheel.dart` | görsel kontrol (ekran görüntüsü) |
| M2.3 | Dönüş animasyonu + tik/haptik | `lib/widgets/spin_wheel.dart`, `lib/core/feedback.dart` | manuel: 5 sn'de yavaşlayarak duruyor, sınırda tik |
| M2.4 | Sonuç kartı + konfeti | `lib/widgets/winner_sheet.dart`, `lib/widgets/confetti.dart` | widget testi: doğru dilim adı gösteriliyor |
| M2.5 | Çark ekranı entegrasyonu | `lib/screens/wheel_screen.dart` | uçtan uca: çevir → sonuç → tekrar çevir |
| **M3 — Editör ve ayarlar** | | | |
| M3.1 | Dilim editörü | `lib/screens/wheel_editor_screen.dart`, `lib/widgets/segment_tile.dart` | widget: ekle/sil/sırala |
| M3.2 | Toplu yapıştırma | `lib/screens/wheel_editor_screen.dart` (sheet) | widget: 5 satır → 5 dilim, boş/tekrar temizliği |
| M3.3 | Ayarlar sheet'i | `lib/widgets/settings_sheet.dart` | widget: eleme modu, süre, ses, titreşim kalıcı |
| M3.4 | Çark yönetimi (kopyala/sil/adlandır) | `lib/screens/wheel_list_screen.dart` | widget: silme onayı, kopya ayrı kayıt |
| **M4 — Cila ve APK** | | | |
| M4.1 | Ses varlığı + tik sesi | `assets/sounds/tick.wav`, `lib/core/feedback.dart` | cihazda duyuluyor |
| M4.2 | İkon + açılış ekranı | `android/app/src/main/res/**`, `pubspec.yaml` | telefonda ikon görünüyor |
| M4.3 | Boş durumlar + erişilebilirlik | tüm ekranlar | kontrast, 48dp dokunma alanı |
| M4.4 | Sürüm derlemesi | `android/app/build.gradle.kts`, keystore | `flutter build apk --release` |
| M4.5 | Telefona kurulum + README | `README.md` | `adb install -r`, uygulama açılıyor |

## Riskler ve önlemler

- **Android SDK lisans/bağlantı sorunları** → `sdkmanager --licenses` boru ile, `flutter doctor -v` ile doğrula.
- **İlk Gradle derlemesi 10-20 dk sürebilir** → ilk `flutter build apk` arka planda çalıştırılır.
- **Emülatör/hipervizör** → Windows'ta HAXM/WHPX sorun çıkarabilir; birincil test yolu **gerçek telefon (USB)**,
  ikincil yol `flutter run -d chrome` (hızlı görsel kontrol).
- **Uzun metin/çok dilim okunabilirliği** → 24 dilim üstünde uyarı, metin `ellipsis`, sonuç ekranında tam metin.
- **Türkçe karakterler** → font alt kümesi sorunu çıkarsa `google_fonts` yerine sistem fontu; testte "ğüşıöç" kontrolü.

## Kilometre taşı kapanış protokolü

1. `flutter analyze` → 0 issue.
2. `flutter test` → tümü geçti.
3. Çalışan uygulamadan ekran görüntüsü al, kullanıcıya göster.
4. `git add -A && git commit`.
5. Kullanıcıya kısa rapor: ne yapıldı, ne doğrulandı, sıradaki adım.
