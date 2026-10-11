import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/templates.dart';
import '../models/wheel.dart';
import '../state/wheel_list_provider.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state.dart';
import '../widgets/text_input_dialog.dart';
import '../widgets/wheel_card.dart';

/// Kayıtlı çarkların listesi. Çark oluşturma, yeniden adlandırma,
/// kopyalama ve silme işlemleri buradan yapılır.
class WheelListScreen extends ConsumerWidget {
  const WheelListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Wheel> wheels = ref.watch(wheelListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Çark'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.lg,
                  Spacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Çarkıfelek',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      'Seçenekleri yaz, çarkı çevir, kararı şansa bırak.',
                      style: TextStyle(fontSize: 14, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: wheels.isEmpty
                    ? EmptyState(
                        templates: kWheelTemplates,
                        onPickTemplate: (WheelTemplate template) =>
                            _createFromTemplate(context, ref, template),
                        onCreateEmpty: () => _showCreateDialog(context, ref),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.lg,
                          0,
                          Spacing.lg,
                          Spacing.xxl * 2,
                        ),
                        itemCount: wheels.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: Spacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final Wheel wheel = wheels[index];
                          return WheelCard(
                            wheel: wheel,
                            onTap: () => context.push('/wheel/${wheel.id}'),
                            onLongPress: () =>
                                _showActions(context, ref, wheel),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createFromTemplate(
    BuildContext context,
    WidgetRef ref,
    WheelTemplate template,
  ) async {
    await ref
        .read(wheelListProvider.notifier)
        .create(title: template.title, segments: template.segments);
    if (!context.mounted) return;
    _toast(context, '"${template.title}" çarkı oluşturuldu');
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final String? title = await TextInputDialog.show(
      context,
      title: 'Yeni çark',
      hint: 'Örn. Ne yesek?',
      confirmLabel: 'Oluştur',
    );
    if (title == null || !context.mounted) return;

    await ref.read(wheelListProvider.notifier).create(
      title: title,
      segments: const <String>['Seçenek 1', 'Seçenek 2'],
    );
    if (!context.mounted) return;
    _toast(context, 'Çark oluşturuldu — seçenekleri düzenlemeyi unutma');
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    Wheel wheel,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Text(
                wheel.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Yeniden adlandır'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _rename(context, ref, wheel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Çoğalt'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                ref.read(wheelListProvider.notifier).duplicate(wheel.id);
                _toast(context, 'Çark çoğaltıldı');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFE94F6B)),
              title: const Text('Sil'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmDelete(context, ref, wheel);
              },
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Wheel wheel,
  ) async {
    final String? title = await TextInputDialog.show(
      context,
      title: 'Yeniden adlandır',
      hint: 'Çark adı',
      confirmLabel: 'Kaydet',
      initialValue: wheel.title,
    );
    if (title == null || title.isEmpty || !context.mounted) return;
    await ref.read(wheelListProvider.notifier).rename(wheel.id, title);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Wheel wheel,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Çarkı sil'),
        content: Text('"${wheel.title}" çarkı kalıcı olarak silinsin mi?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE94F6B),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(wheelListProvider.notifier).remove(wheel.id);
    if (!context.mounted) return;
    _toast(context, 'Çark silindi');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
