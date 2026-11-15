import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/wheel_library.dart';
import '../models/wheel.dart';
import '../state/wheel_list_provider.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import '../widgets/app_background.dart';

/// Hazır çark kütüphanesi: 66 çark, 12 kategori. Tek dokunuşla kendi
/// çarklarının arasına eklenir; eklenmişse doğrudan açılır.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _category = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final List<Wheel> wheels = ref.watch(wheelListProvider);
    final Set<String> titles = wheels.map((Wheel w) => w.title).toSet();

    final List<LibraryWheel> items = _category == 'Tümü'
        ? kWheelLibrary
        : kWheelLibrary
              .where((LibraryWheel w) => w.category == _category)
              .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Hazır çarklar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              children: <Widget>[
                for (final String cat in <String>['Tümü', ...kWheelCategories])
                  Padding(
                    padding: const EdgeInsets.only(right: Spacing.xs),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _category == cat,
                      onSelected: (_) => setState(() => _category = cat),
                      selectedColor: kAccent.withValues(alpha: 0.22),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _category == cat ? kAccent : kTextSecondary,
                      ),
                      side: BorderSide(
                        color: _category == cat ? kAccent : kBorder,
                      ),
                      backgroundColor: kSurface,
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.lg,
            ),
            itemCount: items.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: Spacing.xs),
            itemBuilder: (BuildContext context, int index) {
              final LibraryWheel entry = items[index];
              final bool added = titles.contains(entry.title);
              return _LibraryCard(
                entry: entry,
                added: added,
                onTap: () => _open(context, entry, added, wheels),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    LibraryWheel entry,
    bool added,
    List<Wheel> wheels,
  ) async {
    if (added) {
      final Wheel existing = wheels.firstWhere(
        (Wheel w) => w.title == entry.title,
      );
      if (context.mounted) context.push('/wheel/${existing.id}');
      return;
    }
    await ref
        .read(wheelListProvider.notifier)
        .create(title: entry.title, segments: entry.segments);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${entry.title} eklendi'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.entry,
    required this.added,
    required this.onTap,
  });

  final LibraryWheel entry;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label:
          '${entry.title}, ${entry.segments.length} seçenek'
          '${added ? ', eklendi' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: <Widget>[
              Text(entry.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.category} · ${entry.segments.length} seçenek',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              if (added)
                Icon(Icons.check_circle, color: kAccent, size: 22)
              else
                Icon(Icons.add_circle_outline, color: kTextSecondary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
