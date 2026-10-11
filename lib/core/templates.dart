/// Uygulama açılışında sunulan hazır çark şablonları.
/// Boş ekran yerine tek dokunuşla kullanılabilir bir çark verir.
class WheelTemplate {
  const WheelTemplate({required this.title, required this.segments});

  final String title;
  final List<String> segments;
}

const List<WheelTemplate> kWheelTemplates = <WheelTemplate>[
  WheelTemplate(
    title: 'Ne yesek?',
    segments: <String>[
      'Pizza',
      'Burger',
      'Kebap',
      'Makarna',
      'Sushi',
      'Çorba',
      'Lahmacun',
      'Tavuk',
    ],
  ),
  WheelTemplate(
    title: 'Kim ısmarlayacak?',
    segments: <String>['Alihan', 'Doğan', 'Mehmet', 'Ahmet', 'Ali'],
  ),
  WheelTemplate(
    title: 'Hafta sonu ne yapalım?',
    segments: <String>[
      'Parka gidelim',
      'Doğaya gidelim',
      'Yemek yiyelim',
      'Sinemaya gidelim',
      'Evde film izleyelim',
      'Bisiklet sürelim',
    ],
  ),
];
