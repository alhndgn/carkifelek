import 'package:shared_preferences/shared_preferences.dart';

/// Kalıcılık arayüzü. Repository bu arayüzü kullanır; testler bellek içi
/// uygulamayı enjekte eder, böylece platform eklentisi gerekmez.
abstract class KeyValueStore {
  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}

/// Testler için bellek içi uygulama.
class InMemoryStore implements KeyValueStore {
  InMemoryStore([Map<String, String>? initial])
    : _data = <String, String>{...?initial};

  final Map<String, String> _data;

  @override
  String? read(String key) => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

/// Gerçek uygulama: shared_preferences üzerinden okuma/yazma.
class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? read(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      // Beklenmeyen biçimdeki kayıt (elle müdahale, eski sürüm, bozuk veri)
      // cast hatası fırlatıp uygulamayı beyaz ekranda bırakmasın.
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}
