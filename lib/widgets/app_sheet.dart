import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Uygulamanın ortak alt-sayfa (bottom sheet) görünümü.
///
/// Tek yerden yönetilir: yuvarlak üst köşe, yüzey rengi, klavye açılınca
/// yukarı kayma. Native `showModalBottomSheet` kullanır — böylece içerik
/// Material atası bulur (ListTile, SwitchListTile vb. sorunsuz çalışır) ve
/// tema değişiklikleri `kSurface` üzerinden otomatik yansır.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    backgroundColor: kSurface,
    barrierColor: const Color(0xB3000000),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: builder(sheetContext),
    ),
  );
}
