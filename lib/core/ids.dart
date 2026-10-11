import 'dart:math';

/// Kriptografik olarak güvenli, çakışma ihtimali çok düşük kimlik üretir.
/// Zaman damgası (sıralanabilirlik) + 12 karakterlik rastgele kısım.
String newId() {
  final String stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final Random random = Random.secure();
  final String tail = List<String>.generate(
    12,
    (_) => random.nextInt(36).toRadixString(36),
  ).join();
  return '$stamp-$tail';
}
