import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_palette.dart';
import '../theme/palette.dart';
import 'app_providers.dart';

/// Seçili temayı tutar ve `SharedPreferences`'a yazar.
///
/// Tema değiştiğinde `setActivePalette` çağrılır; uygulama kökü yeniden
/// çizildiği için tüm renkler (arka plan, yüzey, çark paleti) güncellenir.
class ThemeNotifier extends Notifier<AppPalette> {
  static const String storageKey = 'theme_id_v1';

  @override
  AppPalette build() {
    String? id;
    try {
      id = ref.read(sharedPreferencesProvider).getString(storageKey);
    } catch (_) {
      // Testlerde sharedPreferencesProvider override edilmemişse varsayılan.
      id = null;
    }
    final AppPalette palette = paletteById(id);
    setActivePalette(palette.id);
    return palette;
  }

  Future<void> select(String id) async {
    final AppPalette palette = paletteById(id);
    if (palette.id == state.id) return;
    setActivePalette(palette.id);
    state = palette;
    try {
      await ref
          .read(sharedPreferencesProvider)
          .setString(storageKey, palette.id);
    } catch (_) {
      // Kalıcılık başarısız olsa da tema bu oturumda uygulanmış olur.
    }
  }
}

final NotifierProvider<ThemeNotifier, AppPalette> themeProvider =
    NotifierProvider<ThemeNotifier, AppPalette>(ThemeNotifier.new);
