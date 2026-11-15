# Çarkıfelek — Google Play yayın adımları

Paket: `com.teqstudio.carkifelek` · Sürüm: **1.2.1 (versionCode 4)** · minSdk 24 · targetSdk 36
Yüklenecek dosya: **`store/carkifelek-1.2.1.aab`** (AAB — Play APK kabul etmez)
İmza: upload anahtarı (CN=Carkifelek) ✅ — debug imzalı değil

---

## 0) Hazır olanlar (bu klasörde)

| Dosya | Play'de yeri | Kural |
|---|---|---|
| `icon-512.png` | Uygulama ikonu | 512×512, şeffaflık yok |
| `feature-graphic.png` | Öne çıkan grafik | 1024×500, şeffaflık yok |
| `phone-1..4.png` | Telefon ekran görüntüleri | 1080×1920 (9:16), 2–8 adet |
| `carkifelek-1.2.1.aab` | Sürüm yükleme | İmzalı app bundle |

Kullanılacak metinler:
- **Uygulama adı:** `Çarkıfelek`
- **Kısa açıklama (≤80):** `Kararsız kalınca çarkı çevir: 66 hazır çark, 4 görünüm, 6 tema.`
- **Tam açıklama:** aşağıdaki "Mağaza metni" bölümünü kopyala.

---

## 1) Play Console'da uygulama oluştur

Tüm uygulamalar → **Uygulama oluştur**

| Alan | Değer |
|---|---|
| Uygulama adı | Çarkıfelek |
| Varsayılan dil | Türkçe (tr-TR) |
| Uygulama / Oyun | **Uygulama** (alternatif: Oyun → Gündelik) |
| Ücretsiz / Ücretli | **Ücretsiz** |
| Beyanlar | İkisini de işaretle |

> Ücretli seçersen sonradan ücretsize çevrilebilir; tersi mümkün değil. Ücretsiz başla.

## 2) Mağaza girişi (Store listing)

- Uygulama adı, kısa açıklama, tam açıklama → yukarıdaki metinler
- **Grafikler:** `icon-512.png`, `feature-graphic.png`, 4 telefon görseli
- **Kategori:** Eğlence · **Etiketler:** Çark, Karar, Eğlence, Rastgele
- **İletişim e-postası:** kendi e-postan (zorunlu, herkese görünür)
- **Gizlilik politikası URL'si:** zorunlu → aşağıdaki not

### Gizlilik politikası (zorunlu)
Uygulama **hiçbir veri toplamıyor** (her şey cihazda, ağ isteği yok). Yine de bir URL
gerekiyor. En kolayı: GitHub Gist / GitHub Pages üzerinde 1 sayfalık metin yayınla:

```
Çarkıfelek gizlilik politikası
Bu uygulama hiçbir kişisel veri toplamaz, sunucuya veri göndermez ve reklam göstermez.
Çarklar, seçenekler ve ayarlar yalnızca cihazınızda saklanır; uygulamayı silerseniz silinir.
İletişim: <e-posta adresin>
```

## 3) Uygulama içeriği (App content) — hepsi zorunlu

| Bölüm | Cevap |
|---|---|
| Gizlilik politikası | URL'yi gir |
| Uygulama erişimi | "Tüm işlevler kısıtlama olmadan kullanılabilir" (hesap/oturum yok) |
| Reklamlar | **Hayır, reklam içermiyor** |
| İçerik derecelendirmesi | Anketi doldur → şiddet/cinsellik/kumar yok → **3+ / Herkes** çıkar |
| Hedef kitle | **13+** (çocuklara yönelik DEĞİL → Families politikasına girmez) |
| Haberler | Hayır |
| Veri güvenliği | **Veri toplamıyorum / paylaşmıyorum**; "Veriler cihazda saklanır" işaretle |
| Finans / Sağlık / Devlet | Hayır |

> Veri güvenliği formunda "Toplanan veri yok" demek, uygulamanın ağ isteği yapmamasıyla tutarlı.
> İleride analitik/reklam eklersen bu formu güncellemek zorunlu.

## 4) İmzalama (Play App Signing)

- **Play App Signing'i açık bırak** (önerilen). Yüklediğin AAB kendi *upload anahtarınla*
  imzalı; Google dağıtım için kendi anahtarıyla yeniden imzalar.
- Upload anahtarı ve şifresi: `C:\Users\alhndgn\carkifelek-yayin-bilgileri.txt`
  **Bu dosyayı yedekle.** Kaybedersen aynı paket adıyla güncelleme yükleyemezsin.

## 5) Test turları (KRİTİK — kişisel hesap kuralı)

13 Kasım 2023'ten sonra açılan **kişisel** geliştirici hesapları için üretime geçmeden önce:

1. **İç test (Internal testing)** — hemen yayınlanır, 100 testere kadar.
   AAB'yi burada yükle, kendi telefonuna kur, dene. (İnceleme beklemez, dakikalar içinde.)
2. **Kapalı test (Closed testing)** — **en az 12 tester, 14 gün kesintisiz**.
   Bu süre dolmadan üretim başvurusu yapılamaz. Testerler uygulamayı en az bir kez açmalı.
3. **Üretim erişimi başvurusu** — 14 gün dolunca "Production access" sekmesinden başvur;
   sorulara uygulamayı anlatan kısa cevaplar ver.
4. **Üretim (Production)** — ülke seç, sürümü gönder. İnceleme genelde 1–7 gün.

## 6) Sürüm yükleme

Test → İç test → **Yeni sürüm oluştur** → `store/carkifelek-1.2.1.aab` dosyasını yükle.

Yeni sürümlerde:
- `pubspec.yaml` içindeki `version:` **artmalı** (örn. `1.3.0+4` → versionCode 4).
- Aynı versionCode iki kez yüklenemez: "Version code 3 has already been used".

## 7) Mağaza metni (tam açıklama — kopyala)

```
Kararsız kaldığın her an yanında: çarkı çevir, kararı şansa bırak.

Çarkıfelek, "ne yiyelim, kim ödesin, hangi filmi izlesek" gibi günlük kararları
eğlenceli hale getiren sade bir çark uygulaması. Kendi seçeneklerini yaz, çarkı çevir,
sonucu gör. İnternet gerekmez, reklam yok, hesap açmak yok.

• 66 HAZIR ÇARK — Yemek, eğlence, oyun, spor, günlük, karar, ekip görevleri,
  yaratıcılık, çocuklar, öğrenme, ev işleri ve sosyal planlar. Tek dokunuşla ekle.
• 4 ÇARK GÖRÜNÜMÜ — Klasik dilim, halka, hedef tahtası ve ibreli kadran.
• 6 TEMA — Gece, Okyanus, Gün Batımı, Orman, Altın ve açık tema Kâğıt.
• GERÇEKÇİ DÖNÜŞ — Kısa hızlanma, uzun sürtünmeli yavaşlama ve yerine oturma;
  dilim sınırında tik sesi ve titreşim.
• KENDİ ÇARKINI YAP — Sınırsız seçenek, sürükle-sırala, toplu yapıştırma.
• ELEME MODU — Kazanan listeden çıkar, son kişi kalana kadar.
• TAMAMEN ÇEVRİMDIŞI — Tüm veriler cihazında kalır; hiçbir bilgi toplanmaz.

Arkadaş grubunda, aile sofrasında, ofiste görev dağıtırken ya da sadece canın
sıkıldığında aç; çark karar versin.
```

---

## Teknik doğrulama (yapıldı)

```
Paket          : com.teqstudio.carkifelek
versionCode    : 3      versionName: 1.2.0
minSdk / target: 24 / 36          (Play 2026 için 35+ istiyor → uygun)
İmza           : CN=Carkifelek (upload anahtarı) — debug değil
AAB boyutu     : 50 MB
Testler        : 99/99 geçti, flutter analyze temiz
Keystore       : android/app/upload-keystore.jks  (git dışında)
```

## Sık takılınan noktalar

- **"App bundle was signed with the wrong key"** → yanlış keystore. `key.properties` doğru mu?
- **"Version code already used"** → `pubspec.yaml` sürümünü artır.
- **"Uploaded an APK"** → AAB yükle (`flutter build appbundle`).
- **Gizlilik politikası URL'si yok** → mağaza girişi kaydedilmez.
- **Kapalı test 14 günü dolmadan üretim yok** → testerleri erken topla.
