// ÜRETİLMİŞ DOSYA — elle düzenleme. Kaynak: çark web sürümü kütüphanesi.
// Dönüştürücü: tool/gen_wheel_library.py

/// Hazır çark kütüphanesinden bir kayıt.
class LibraryWheel {
  const LibraryWheel({
    required this.category,
    required this.emoji,
    required this.title,
    required this.segments,
  });

  final String category;
  final String emoji;
  final String title;
  final List<String> segments;
}

/// Kullanıcının tek dokunuşla ekleyebileceği hazır çarklar.
const List<LibraryWheel> kWheelLibrary = <LibraryWheel>[
  LibraryWheel(
    category: 'Yemek',
    emoji: '🍽️',
    title: 'Ne yiyelim?',
    segments: <String>['Pizza', 'Burger', 'Döner', 'Lahmacun', 'Makarna', 'Kebap', 'Sushi', 'Çorba', 'Salata', 'Pide'],
  ),
  LibraryWheel(
    category: 'Yemek',
    emoji: '🍳',
    title: 'Kahvaltıda ne olsun?',
    segments: <String>['Menemen', 'Omlet', 'Simit', 'Peynir', 'Zeytin', 'Yumurta', 'Bal Kaymak', 'Sucuklu Yumurta', 'Börek'],
  ),
  LibraryWheel(
    category: 'Yemek',
    emoji: '🍰',
    title: 'Tatlı ne yiyelim?',
    segments: <String>['Baklava', 'Sütlaç', 'Kazandibi', 'Profiterol', 'Cheesecake', 'Dondurma', 'Kek', 'Tiramisu', 'Künefe'],
  ),
  LibraryWheel(
    category: 'Yemek',
    emoji: '🍜',
    title: 'Hangi mutfağı deneyelim?',
    segments: <String>['İtalyan', 'Türk', 'Japon', 'Meksika', 'Hint', 'Çin', 'Fransız', 'Lübnan', 'Tayland'],
  ),
  LibraryWheel(
    category: 'Yemek',
    emoji: '🍕',
    title: 'Kaç dilim pizza yiyelim?',
    segments: <String>['1 dilim', '2 dilim', '3 dilim', '4 dilim', '5 dilim', 'Yarım pizza', 'Bütün pizza'],
  ),
  LibraryWheel(
    category: 'Yemek',
    emoji: '☕',
    title: 'Akşam çayına ne olsun?',
    segments: <String>['Kurabiye', 'Kek', 'Poğaça', 'Açma', 'Simit', 'Bisküvi', 'Çikolata', 'Kuru Meyve'],
  ),
  LibraryWheel(
    category: 'Yemek',
    emoji: '🥤',
    title: 'Hangi içecek içelim?',
    segments: <String>['Çay', 'Kahve', 'Limonata', 'Meyve Suyu', 'Ayran', 'Su', 'Soda', 'Çilekli Süt', 'Kola'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '🎬',
    title: 'Hangi filmi izlesek?',
    segments: <String>['Komedi', 'Aksiyon', 'Korku', 'Dram', 'Animasyon', 'Bilim Kurgu', 'Romantik', 'Belgesel', 'Gerilim'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '📺',
    title: 'Hangi diziyi başlatalım?',
    segments: <String>['Suç', 'Fantastik', 'Komedi', 'Dram', 'Bilim Kurgu', 'Tarih', 'Romantik', 'Gerilim', 'Anime'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '🎵',
    title: 'Hangi müzik türünü dinlesek?',
    segments: <String>['Pop', 'Rock', 'Türkü', 'Caz', 'Klasik', 'Rap', 'Elektronik', 'Arabesk', 'Klasik Türk'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '🎮',
    title: 'Hangi oyunu oynasak?',
    segments: <String>['Saklambaç', 'İsim Şehir', 'Tombala', 'Satranç', 'Yakar Top', 'Misket', 'Mendil Kapmaca', 'Kutu Kutu'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '🎸',
    title: 'Konserde ne çalsın?',
    segments: <String>['Gitar', 'Piyano', 'Keman', 'Davul', 'Saz', 'Flüt', 'Bağlama', 'Klarnet'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '🎉',
    title: 'Hangi partiyi yapalım?',
    segments: <String>['Pijama Partisi', 'Doğum Günü', 'Piknik', 'Dans Partisi', 'Film Gecesi', 'Karaoke', 'Barbekü'],
  ),
  LibraryWheel(
    category: 'Eğlence',
    emoji: '🎢',
    title: 'Hangi eğlence mekanına gidelim?',
    segments: <String>['Sinema', 'Lunapark', 'Tiyatro', 'Konser', 'Müze', 'Bowling', 'Hayvanat Bahçesi', 'Akvaryum'],
  ),
  LibraryWheel(
    category: 'Oyun',
    emoji: '🃏',
    title: 'Hangi kart oyunu oynayalım?',
    segments: <String>['İskambil', 'UNO', 'Batak', 'Pişti', 'Blöf', 'Solitaire', 'King', 'Papaz Kaçtı'],
  ),
  LibraryWheel(
    category: 'Oyun',
    emoji: '🕹️',
    title: 'Hangi video oyunu oynasak?',
    segments: <String>['Macera', 'Yarış', 'Dövüş', 'Spor', 'Bulmaca', 'Strateji', 'Simülasyon', 'Nişancı'],
  ),
  LibraryWheel(
    category: 'Oyun',
    emoji: '🎲',
    title: 'Masa oyunu seç',
    segments: <String>['Monopoly', 'Tabu', 'Kızma Birader', 'Scrabble', 'Risk', 'Satranç', 'Jenga', 'Tavla'],
  ),
  LibraryWheel(
    category: 'Oyun',
    emoji: '🧠',
    title: 'Hangi bilgi yarışması?',
    segments: <String>['Genel Kültür', 'Tarih', 'Bilim', 'Coğrafya', 'Spor', 'Sinema', 'Müzik', 'Edebiyat'],
  ),
  LibraryWheel(
    category: 'Oyun',
    emoji: '🎯',
    title: 'Kaç el oynayalım?',
    segments: <String>['1 el', '2 el', '3 el', '5 el', '7 el', '10 el', 'Kazanana kadar'],
  ),
  LibraryWheel(
    category: 'Oyun',
    emoji: '🏆',
    title: 'Hangi takım oyunu?',
    segments: <String>['Saklambaç', 'Yakalama', 'İstop', 'Körebe', 'Yakan Top', 'Halat Çekme', 'Bayrak Yarışı'],
  ),
  LibraryWheel(
    category: 'Spor',
    emoji: '🏃',
    title: 'Bugün hangi sporu yapalım?',
    segments: <String>['Koşu', 'Yüzme', 'Bisiklet', 'Futbol', 'Basketbol', 'Tenis', 'Yürüyüş', 'Yoga'],
  ),
  LibraryWheel(
    category: 'Spor',
    emoji: '💪',
    title: 'Hangi antrenman?',
    segments: <String>['Kardiyo', 'Ağırlık', 'Pilates', 'Esneme', 'HIIT', 'Direnç', 'Denge', 'Isınma'],
  ),
  LibraryWheel(
    category: 'Spor',
    emoji: '⏱️',
    title: 'Kaç dakika koşalım?',
    segments: <String>['10 dakika', '15 dakika', '20 dakika', '30 dakika', '45 dakika', '1 saat', '5 km', '10 km'],
  ),
  LibraryWheel(
    category: 'Spor',
    emoji: '🦵',
    title: 'Hangi kas grubunu çalışalım?',
    segments: <String>['Karın', 'Bacak', 'Kol', 'Sırt', 'Göğüs', 'Omuz', 'Kalça', 'Tüm Vücut'],
  ),
  LibraryWheel(
    category: 'Spor',
    emoji: '🏟️',
    title: 'Hangi spor dalını izleyelim?',
    segments: <String>['Futbol', 'Basketbol', 'Voleybol', 'Tenis', 'Formula', 'Güreş', 'Atletizm', 'Yüzme'],
  ),
  LibraryWheel(
    category: 'Spor',
    emoji: '🤸',
    title: 'Kaç şınav çekelim?',
    segments: <String>['5', '10', '15', '20', '25', '30', '40', '50'],
  ),
  LibraryWheel(
    category: 'Günlük',
    emoji: '📅',
    title: 'Bugün ne yapalım?',
    segments: <String>['Piknik', 'Alışveriş', 'Yürüyüş', 'Kitap Okuma', 'Film İzleme', 'Uyku', 'Temizlik', 'Arkadaş Ziyareti'],
  ),
  LibraryWheel(
    category: 'Günlük',
    emoji: '✅',
    title: 'İlk hangi işi yapalım?',
    segments: <String>['Bulaşık', 'Çamaşır', 'Süpürme', 'Toz Alma', 'Market', 'Yemek', 'Duş', 'Dinlenme'],
  ),
  LibraryWheel(
    category: 'Günlük',
    emoji: '☀️',
    title: 'Bugün hava nasıl?',
    segments: <String>['Güneşli', 'Yağmurlu', 'Bulutlu', 'Karlı', 'Rüzgarlı', 'Sisli', 'Sıcak', 'Soğuk'],
  ),
  LibraryWheel(
    category: 'Günlük',
    emoji: '🕐',
    title: 'Kaçta buluşalım?',
    segments: <String>['10:00', '12:00', '14:00', '16:00', '18:00', '19:00', '20:00', '21:00'],
  ),
  LibraryWheel(
    category: 'Günlük',
    emoji: '👕',
    title: 'Bugün nasıl giyinelim?',
    segments: <String>['Rahat', 'Şık', 'Spor', 'Resmi', 'Renkli', 'Sade', 'Katmanlı', 'Klasik'],
  ),
  LibraryWheel(
    category: 'Karar',
    emoji: '🪙',
    title: 'Yazı mı tura mı?',
    segments: <String>['Yazı', 'Tura', 'Yazı Kazanır', 'Tura Kazanır', 'Berabere', 'Tekrar At'],
  ),
  LibraryWheel(
    category: 'Karar',
    emoji: '🤔',
    title: 'Evet mi hayır mı?',
    segments: <String>['Evet', 'Hayır', 'Belki', 'Kesinlikle Evet', 'Kesinlikle Hayır', 'Sonra Karar Veririm'],
  ),
  LibraryWheel(
    category: 'Karar',
    emoji: '⏳',
    title: 'Şimdi mi sonra mı?',
    segments: <String>['Şimdi', 'Birazdan', 'Yarın', 'Sonra', 'Hemen', 'Bekle'],
  ),
  LibraryWheel(
    category: 'Karar',
    emoji: '🎯',
    title: 'Hangisini seçsem?',
    segments: <String>['Birinci', 'İkinci', 'Üçüncü', 'Dördüncü', 'Beşinci', 'Altıncı'],
  ),
  LibraryWheel(
    category: 'Karar',
    emoji: '🎲',
    title: 'Riske gireyim mi?',
    segments: <String>['Evet Gir', 'Girme', 'Küçük Dene', 'Bekle', 'Cesur Ol', 'Temkinli Ol'],
  ),
  LibraryWheel(
    category: 'Ekip',
    emoji: '🎤',
    title: 'Kim sunum yapsın?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Ekip',
    emoji: '📝',
    title: 'Kim not tutsun?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Ekip',
    emoji: '💰',
    title: 'Kim ödesin?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Ekip',
    emoji: '📋',
    title: 'Kime hangi görev?',
    segments: <String>['Toplantı', 'Rapor', 'Sunum', 'Araştırma', 'Tasarım', 'Test', 'Belgeler', 'İletişim'],
  ),
  LibraryWheel(
    category: 'Ekip',
    emoji: '🗣️',
    title: 'Kim toplantıyı yönetsin?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Ekip',
    emoji: '👉',
    title: 'Sıradaki kim?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Yaratıcı',
    emoji: '🎨',
    title: 'Hangi renk?',
    segments: <String>['Kırmızı', 'Mavi', 'Sarı', 'Yeşil', 'Mor', 'Turuncu', 'Pembe', 'Turkuaz'],
  ),
  LibraryWheel(
    category: 'Yaratıcı',
    emoji: '💡',
    title: 'Hangi konu?',
    segments: <String>['Aşk', 'Doğa', 'Şehir', 'Deniz', 'Uzay', 'Tarih', 'Gelecek', 'Çocukluk'],
  ),
  LibraryWheel(
    category: 'Yaratıcı',
    emoji: '✍️',
    title: 'Kaç kelime yazayım?',
    segments: <String>['50', '100', '150', '200', '300', '500', '1000'],
  ),
  LibraryWheel(
    category: 'Yaratıcı',
    emoji: '🖌️',
    title: 'Hangi tarz?',
    segments: <String>['Modern', 'Klasik', 'Vintage', 'Minimal', 'Retro', 'Gotik', 'Bohem', 'Endüstriyel'],
  ),
  LibraryWheel(
    category: 'Yaratıcı',
    emoji: '🏷️',
    title: 'Hangi isim?',
    segments: <String>['Yıldız', 'Rüzgar', 'Deniz', 'Ateş', 'Ay', 'Güneş', 'Bulut', 'Yağmur'],
  ),
  LibraryWheel(
    category: 'Çocuk',
    emoji: '🧸',
    title: 'Hangi oyuncağı oynayalım?',
    segments: <String>['Top', 'Araba', 'Bebek', 'Lego', 'Puzzle', 'Uçak', 'Tren', 'Bloklar'],
  ),
  LibraryWheel(
    category: 'Çocuk',
    emoji: '📖',
    title: 'Hangi masalı okuyalım?',
    segments: <String>['Külkedisi', 'Pamuk Prenses', 'Kırmızı Başlıklı Kız', 'Uyuyan Güzel', 'Pinokyo', 'Kurbağa Prens', 'Çirkin Ördek'],
  ),
  LibraryWheel(
    category: 'Çocuk',
    emoji: '🖍️',
    title: 'Hangi boyama?',
    segments: <String>['Hayvanlar', 'Çiçekler', 'Arabalar', 'Deniz Canlıları', 'Dinozorlar', 'Uzay', 'Meyveler'],
  ),
  LibraryWheel(
    category: 'Çocuk',
    emoji: '🙈',
    title: 'Kim saklambaçta ebe?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif'],
  ),
  LibraryWheel(
    category: 'Çocuk',
    emoji: '🎶',
    title: 'Hangi şarkıyı söyleyelim?',
    segments: <String>['Mini Mini Bir Kuş', 'Ali Babanın Çiftliği', 'Küçük Kurbağa', 'Dandini Dandini', 'Horozumu Kaçırdılar', 'Kırmızı Balık'],
  ),
  LibraryWheel(
    category: 'Öğrenme',
    emoji: '📚',
    title: 'Hangi konuyu çalışayım?',
    segments: <String>['Matematik', 'Türkçe', 'Fen', 'Tarih', 'Coğrafya', 'İngilizce', 'Fizik', 'Kimya'],
  ),
  LibraryWheel(
    category: 'Öğrenme',
    emoji: '🗣️',
    title: 'Hangi dil pratiği?',
    segments: <String>['İngilizce', 'Almanca', 'Fransızca', 'İspanyolca', 'İtalyanca', 'Rusça', 'Japonca', 'Arapça'],
  ),
  LibraryWheel(
    category: 'Öğrenme',
    emoji: '❓',
    title: 'Kaç soru çözeyim?',
    segments: <String>['5', '10', '15', '20', '25', '30', '50'],
  ),
  LibraryWheel(
    category: 'Öğrenme',
    emoji: '📗',
    title: 'Hangi kitabı okuyayım?',
    segments: <String>['Roman', 'Şiir', 'Öykü', 'Tarih', 'Bilim', 'Biyografi', 'Deneme', 'Fantastik'],
  ),
  LibraryWheel(
    category: 'Öğrenme',
    emoji: '🧮',
    title: 'Hangi dersi tekrar edeyim?',
    segments: <String>['Matematik', 'Türkçe', 'Fen', 'Sosyal', 'İngilizce', 'Din Kültürü', 'Beden', 'Müzik'],
  ),
  LibraryWheel(
    category: 'Ev',
    emoji: '🍽️',
    title: 'Kim bulaşıkları yıkasın?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Ev',
    emoji: '🗑️',
    title: 'Kim çöpü atsın?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Ev',
    emoji: '🧹',
    title: 'Bugün hangi oda temizlensin?',
    segments: <String>['Salon', 'Mutfak', 'Yatak Odası', 'Banyo', 'Balkon', 'Koridor', 'Çalışma Odası', 'Kiler'],
  ),
  LibraryWheel(
    category: 'Ev',
    emoji: '🍲',
    title: 'Akşam yemeği ne olsun?',
    segments: <String>['Mercimek Çorbası', 'Karnıyarık', 'Makarna', 'Pilav', 'Köfte', 'Tavuk', 'Balık', 'Sebze Yemeği'],
  ),
  LibraryWheel(
    category: 'Ev',
    emoji: '🔧',
    title: 'Hangi tamirat önce?',
    segments: <String>['Musluk', 'Lamba', 'Kapı', 'Duvar', 'Koltuk', 'Dolap', 'Priz', 'Boya'],
  ),
  LibraryWheel(
    category: 'Sosyal',
    emoji: '💬',
    title: 'Kime mesaj atayım?',
    segments: <String>['Annem', 'Babam', 'Kardeşim', 'Arkadaşım', 'Kuzenim', 'İş Arkadaşım', 'Komşum', 'Sevgilim'],
  ),
  LibraryWheel(
    category: 'Sosyal',
    emoji: '📞',
    title: 'Hangi arkadaşı arayayım?',
    segments: <String>['Ali', 'Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif', 'Burak', 'Deniz'],
  ),
  LibraryWheel(
    category: 'Sosyal',
    emoji: '🗓️',
    title: 'Hafta sonu ne yapalım?',
    segments: <String>['Piknik', 'Sinema', 'Gezi', 'Alışveriş', 'Ev Partisi', 'Doğa Yürüyüşü', 'Müze', 'Kahve'],
  ),
  LibraryWheel(
    category: 'Sosyal',
    emoji: '📍',
    title: 'Nereye gidelim?',
    segments: <String>['Sahil', 'Park', 'Kafe', 'Sinema', 'Müze', 'AVM', 'Dağ', 'Göl'],
  ),
];

/// Kütüphanedeki kategori sırası.
const List<String> kWheelCategories = <String>[
  'Yemek',
  'Eğlence',
  'Oyun',
  'Spor',
  'Günlük',
  'Karar',
  'Ekip',
  'Yaratıcı',
  'Çocuk',
  'Öğrenme',
  'Ev',
  'Sosyal',
];
