import 'package:flutter/services.dart';

/// Tik sesi ve dokunsal geri bildirim.
///
/// Tüm çağrılar hata yutar: masaüstü/web gibi platformlarda ses/titreşim
/// eklentisi bulunmayabilir ve bu, uygulamayı çökertmemeli.
class WheelFeedback {
  const WheelFeedback._();

  /// İbre yeni bir dilime geçtiğinde.
  static Future<void> tick({bool sound = true, bool haptics = true}) async {
    if (haptics) {
      try {
        await HapticFeedback.selectionClick();
      } catch (_) {
        // platform desteklemiyor
      }
    }
    if (sound) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {
        // platform desteklemiyor
      }
    }
  }

  /// Çark durduğunda, kazanan açıklanmadan hemen önce.
  static Future<void> result({bool haptics = true, bool sound = false}) async {
    if (haptics) {
      try {
        await HapticFeedback.mediumImpact();
      } catch (_) {
        // platform desteklemiyor
      }
    }
    if (sound) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {
        // platform desteklemiyor
      }
    }
  }
}
