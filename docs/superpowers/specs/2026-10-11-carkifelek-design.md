# Çarkıfelek — Tasarım Spesifikasyonu

Tarih: 2026-10-11 · Platform: Flutter (Android öncelikli, iOS 2. etap) · Hedef: kendi telefonunda APK

## 1. Amaç ve başarı kriterleri

Kullanıcı kendi seçenek listelerini oluşturup çevirmeli bir çarkla rastgele karar aldığı, görsel
olarak "yeni nesil" hissi veren bir uygulama. Seçenekler sadece isim değil, her türlü metin olabilir
(ör. "parka gidelim", "doğaya gidelim", "yemek yiyelim").

Başarı kriterleri:
- Uygulama açılır, kayıtlı çarklar listelenir, yeni çark oluşturulur/düzenlenir/silinir.
- Çarka dokununca gerçekçi bir yavaşlama animasyonuyla döner, adil rastgele bir sonuçta durur.
- Sonuç ekranda belirgin şekilde gösterilir; eleme modu açıksa kazanan listeden çıkarılır.
- Çark görünümü ve animasyon akıcı (hedef: 60 fps, kare düşmesi yok).
- Uygulama kapatılıp açıldığında tüm listeler ve ayarlar korunur.
- Telefona kurulabilir imzalı APK üretilir (ücretsiz, mağaza gerektirmez).

Kapsam dışı (bu sürümde yok): hesap/oturum, sunucu, reklam, analitik, mağaza yayını, iOS derlemesi,
çarkı görsel olarak paylaşma, birden fazla dil (arayüz Türkçe).

## 2. Seçilen yaklaşım

| Yaklaşım | Artı | Eksi | Karar |
|---|---|---|---|
| **A. Riverpod + go_router + shared_preferences** | Test edilebilir, standart yığın, native yapılandırma gerektirmez, büyümeye uygun | Birkaç kavram öğrenilir | **Seçildi** |
| B. setState + Provider + Hive | Daha az kavram | Kod büyüdükçe dağılır, tip güvenliği zayıf | Elendi |
| C. FlutterFlow / no-code | En hızlı görsel sonuç | "Geliştirici olma" hedefini karşılamaz, kod sahibi olmazsın | Elendi |

Gerekçe: A, `flutter-dev` skill'inin önerdiği kalıpları (Riverpod, GoRouter, const optimizasyonu)
doğrudan uygular ve devam eden derslerde öğrendiklerin gerçek projede kullanılabilir kalır.

## 3. Mimari

Katmanlar (her biri tek sorumluluk, bağımsız test edilebilir):

- `lib/models/` — `Wheel` (veri modeli), `WheelSettings`. Saf Dart, Flutter bağımlılığı yok → unit test kolay.
- `lib/data/` — `WheelRepository`: JSON (de)serializasyon + `shared_preferences` kalıcılığı.
  Tek genel arayüz: `loadAll()`, `save(Wheel)`, `delete(id)`.
- `lib/state/` — Riverpod `AsyncNotifier` (`WheelListNotifier`): çarkların listesi, aktif çark,
  CRUD işlemleri, eleme modu mantığı. UI bu katmandan `ref.watch` ile beslenir.
- `lib/screens/` — `WheelListScreen`, `WheelScreen`, `WheelEditorScreen` (+ `SettingsSheet`).
- `lib/widgets/` — `SpinWheel` (CustomPaint + animasyon), `SegmentEditorTile`, `WinnerSheet`,
  `EmptyState`, `PalettePicker`.
- `lib/theme/` — renk paleti, tipografi, boşluk (8pt ızgara), koyu tema.
- `lib/core/` — `spin_math.dart`: saf fonksiyonlar (açı → dilim indeksi, rastgele hedef açı hesabı).
  Bu dosya animasyondan bağımsız, %100 unit test edilir.

Veri akışı: `WheelListScreen` → `WheelScreen` → çevirme → `spin_math` sonuç indeksi →
`WinnerSheet` → (eleme modu açıksa) `WheelListNotifier.removeSegment()` → `Repository.save()` →
`shared_preferences`.

## 4. Veri modeli

```dart
class Wheel {
  final String id;            // uuid (crypto ile üretilir)
  final String title;         // "Ne yesek?" / "Kim ısmarlayacak?"
  final List<String> segments;// sıralı, en az 2, en çok 24 önerilen
  final bool eliminateMode;   // kazanan listeden çıkarılsın mı
  final int spinDurationMs;   // 3000-8000, varsayılan 5000
  final bool soundOn;         // dilim geçiş tik sesi
  final bool hapticsOn;       // dilim geçişinde dokunsal geri bildirim
  final DateTime updatedAt;
  Map<String, dynamic> toJson();  factory Wheel.fromJson(Map<String, dynamic>);
}
```

Kalıcılık: `shared_preferences` anahtarı `wheels_v1` → JSON dizi. Şema sürümü anahtar adında tutulur;
ileride migrasyon gerekirse `wheels_v2` eklenir, eski anahtar okunup dönüştürülür.

## 5. Ekranlar ve akış

1. **Çarklarım (`/`)** — kayıtlı çarklar kart olarak (başlık, dilim sayısı, renk noktaları,
   mini çark önizlemesi). Sağ altta "+ Yeni Çark". Karta dokun → çark. Uzun bas → Yeniden adlandır /
   Çoğalt / Sil (onay ister). Liste boşsa `EmptyState`: hazır şablonlar
   ("Ne yesek?", "Kim ısmarlayacak?", "Hafta sonu ne yapalım?") tek dokunuşla oluşturur.
2. **Çark (`/wheel/:id`)** — ekranı dolduran çark, üstte sabit ibre, ortada gradyan "ÇEVİR" düğmesi.
   Çarka ya da düğmeye dokununca döner. Üst sağda ayarlar. Sonuç: `WinnerSheet` (büyük metin,
   "Tekrar çevir", "Kazananı çıkar", "Tamam"). Çark kilitliyken (1 dilim) çevirme devre dışı + uyarı.
3. **Düzenle (`/wheel/:id/edit`)** — `ReorderableListView` ile sıralama, satır içi metin düzenleme,
   kaydırarak silme, tek tek ekleme. **Çoklu yapıştırma**: her satır bir dilim olacak şekilde
   toplu ekleme (10 ismi tek seferde yazma/kopyalama).
4. **Ayarlar (bottom sheet)** — eleme modu, dönüş süresi (kaydırıcı 3-8 sn), ses, titreşim.

## 6. Animasyon ve görsel dil

- **Çark çizimi**: `CustomPainter` — dilimler eşit açılı, 12 renkli küratörlü paletten döngüsel renk;
  dilim içi metin yarıçapa göre döndürülür, uzun metin `ellipsis`. Merkez göbek, dış halka, hafif gölge.
- **Dönüş**: `AnimationController` + **`FrictionCurve`** (kendi eğrimiz), 5 sn varsayılan.
  Hız profili: ilk %8'de duruştan tepe hıza yumuşak hızlanma → sürtünmeyle (`(1-u)^1.4`)
  dönüşün tamamına yayılan yavaşlama → son %18'de hedefin ~0.02 rad ötesine geçip geri
  oturma. Toplam dönüş = 3-5 tam tur + hedef açı; hedef açı `spin_math` içinde
  `Random.secure()` ile hesaplanır (sonuç önceden kestirilemez).
  *Neden `easeOutQuart` değil:* o eğri hızı ilk karede tepeye çıkarıp ilk saniyede bitiriyor,
  kalan 4 saniyede çark ölü gibi sürünüyordu — "bir anda durdu" hissi. Ölçüm: son %20'lik
  zaman diliminde alınan yol `easeOutQuart` ile %0.88, `FrictionCurve` ile %2.32 (2.6x).
  Hız tablosu (4 tur / 5 sn / 8 dilim): 660 → 559 → 464 → 374 → 290 → 212 → 142 → 80 → 0 °/sn.
- **İbre geçişi**: animasyon dinleyicisi dilim sınırını geçtiğinde tik sesi + `HapticFeedback.selectionClick()`.
- **Kazanan anı**: kısa parlama + dilim vurgusu + konfeti katmanı (saf Dart `CustomPainter`,
  harici ağır paket yok), sonra `WinnerSheet`.
- **Tema**: koyu (deep gradient) arka plan, canlı ama uyumlu dilim renkleri, 8pt ızgara, yuvarlatılmış
  kartlar, yumuşak gölgeler. Material 3. `flutter-ui-design-system` skill'i ile cilalanır.

## 7. Hata durumları

- Hiç çark yok → `EmptyState` + şablonlar (boş ekran değil).
- 1 dilim → çevirme kapalı, "En az 2 seçenek gerekli" uyarısı.
- Boş/yalnız boşluk dilim → kaydederken kırpılır, boşsa eklenmez; yinelenen metin uyarısı (eklemeye izin var).
- Çok uzun metin → çarkta `ellipsis`, sonuç ekranında tam metin.
- 24'ten fazla dilim → uyarı gösterilir, ekleme engellenmez; çark okunabilirliği için metin küçülür.
- Bozuk/eski JSON → okuma hatası yakalanır, o kayıt atlanır, uygulama açılmaya devam eder (veri kaybı yok).
- Tüm kullanıcı metinleri Türkçe karakterlerle doğru gösterilir (font: Roboto/Inter, `UTF-8`).

## 8. Test planı

- **Unit** (`spin_math`): açı → indeks dönüşümü (0°, 359°, negatif açı, tam tur sınırları);
  üretilen hedef açının her zaman geçerli bir indekse denk gelmesi; 10.000 denemede dağılımın
  tekdüze olması (hiçbir dilim %0 veya %100 değil).
- **Unit** (`WheelRepository`): `toJson`/`fromJson` gidiş-dönüş eşitliği; bozuk JSON'da çökmemesi.
- **Widget**: editörde ekleme/silme/sıralama; eleme modunda kazananın listeden çıkması;
  1 dilimde çevirme düğmesinin kapalı olması.
- **Manuel uçtan uca**: telefonda (USB) çark çevirme, ses/titreşim, uygulamayı kapat-aç veri kalıcılığı.
- **Kalite kapısı**: `flutter analyze` ve `flutter test` temiz olmadan sürüm derlenmez.

## 9. Kilometre taşları

1. **M1 — İskelet**: proje + tema + model + repository + Riverpod + çark listesi (CRUD + kalıcılık).
2. **M2 — Çark ve dönüş**: `CustomPainter` çark + animasyon + `spin_math` (testli) + sonuç ekranı.
3. **M3 — Editör ve ayarlar**: dilim düzenleme, toplu yapıştırma, eleme modu, ayarlar.
4. **M4 — Cila ve yayın**: tik sesi/titreşim, konfeti, uygulama ikonu + açılış ekranı,
   boş durumlar, testler, `flutter build apk --release` ve telefona kurulum.

Her kilometre taşı sonunda `flutter analyze` + `flutter test` temiz + ekran görüntüsü kanıtı.

## 10. Teknik ortam

- Kurulum kökü (Windows): `C:\dev\flutter`, `C:\dev\jdk-21`, `C:\dev\android-sdk`
- Proje dizini: `C:\dev\projeler\carkifelek`
- Paket adı: `com.ezforme.carkifelek`
- Flutter stable 3.47.7 (Dart 3.13.5), JDK 21, Android SDK 36
- Bağımlılıklar: `flutter_riverpod`, `go_router`, `shared_preferences`, (opsiyonel) `google_fonts`
