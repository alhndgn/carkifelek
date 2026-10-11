import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/key_value_store.dart';
import '../data/wheel_repository.dart';

/// `main()` içinde override edilir: SharedPreferences asenkron yüklendiği için
/// ağacın kurulmasından önce elde edilip buraya enjekte edilir.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
      (Ref ref) => throw UnimplementedError(
        'sharedPreferencesProvider main() içinde override edilmeli',
      ),
    );

final Provider<WheelRepository> wheelRepositoryProvider =
    Provider<WheelRepository>(
      (Ref ref) => WheelRepository(
        SharedPrefsStore(ref.watch(sharedPreferencesProvider)),
      ),
    );
