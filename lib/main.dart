import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/app_providers.dart';

/// SharedPreferences ağaçtan önce yüklenir ve provider'a enjekte edilir;
/// böylece çark listesi senkron okunur, açılışta bekleme olmaz.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CarkifelekApp(),
    ),
  );
}
