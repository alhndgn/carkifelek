import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ids.dart';
import '../models/wheel.dart';
import '../state/wheel_list_provider.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';
import '../widgets/app_background.dart';
import '../widgets/text_input_dialog.dart';

/// Düzenlenebilir satır: yinelenen seçeneklerde de anahtar çakışmasın diye
/// her satırın kendi kimliği var.
class _SegmentRow {
  _SegmentRow(this.id, this.text);

  final String id;
  String text;
}

/// Dilim (seçenek) editörü: ekle, düzenle, sil, sürükleyerek sırala, toplu yapıştır.
class WheelEditorScreen extends ConsumerStatefulWidget {
  const WheelEditorScreen({super.key, required this.wheelId});

  final String wheelId;

  @override
  ConsumerState<WheelEditorScreen> createState() => _WheelEditorScreenState();
}

class _WheelEditorScreenState extends ConsumerState<WheelEditorScreen> {
  List<_SegmentRow>? _rows;
  bool _dirty = false;

  List<_SegmentRow> _ensureRows(Wheel wheel) {
    return _rows ??= wheel.segments
        .map((String segment) => _SegmentRow(newId(), segment))
        .toList();
  }

  List<String> get _texts =>
      Wheel.normalizeSegments(_rows!.map((_SegmentRow row) => row.text));

  int get _duplicateCount {
    final List<String> texts = _texts;
    final Map<String, int> counts = <String, int>{};
    for (final String text in texts) {
      counts[text] = (counts[text] ?? 0) + 1;
    }
    return counts.values.where((int value) => value > 1).length;
  }

  @override
  Widget build(BuildContext context) {
    final Wheel? wheel = ref.watch(
      wheelListProvider.select(
        (List<Wheel> wheels) =>
            wheels.where((Wheel w) => w.id == widget.wheelId).firstOrNull,
      ),
    );

    if (wheel == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Düzenle')),
        body: const AppBackground(
          child: Center(
            child: Text(
              'Bu çark bulunamadı.',
              style: TextStyle(color: kTextSecondary),
            ),
          ),
        ),
      );
    }

    final List<_SegmentRow> rows = _ensureRows(wheel);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Seçenekleri düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: TextButton(
              onPressed: _dirty ? _save : null,
              child: Text(
                'Kaydet',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _dirty ? kAccent : kTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(
                total: _texts.length,
                duplicates: _duplicateCount,
                onPasteMany: _pasteMany,
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: Spacing.sm,
                  ),
                  itemCount: rows.length,
                  // onReorderItem: newIndex zaten "öğe çıkarılmış" indekstir.
                  onReorderItem: _reorder,
                  buildDefaultDragHandles: false,
                  itemBuilder: (BuildContext context, int index) {
                    final _SegmentRow row = rows[index];
                    return _SegmentTile(
                      key: ValueKey<String>(row.id),
                      index: index,
                      text: row.text,
                      color: paletteColorAt(index),
                      onEdit: () => _editRow(index),
                      onDelete: () => _deleteRow(index),
                    );
                  },
                ),
              ),
              _AddBar(onAdd: _addOne, onClear: rows.isEmpty ? null : _clearAll),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBack() async {
    if (_dirty) {
      final bool? discard = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Kaydedilmeyen değişiklikler'),
          content: const Text(
            'Değişiklikler kaydedilmedi. Çıkmak istiyor musun?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Düzenlemeye dön'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Kaydetmeden çık'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _save() async {
    await ref
        .read(wheelListProvider.notifier)
        .updateSegments(widget.wheelId, _texts);
    if (!mounted) return;
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${_texts.length} seçenek kaydedildi')),
      );
  }

  void _addOne(String value) {
    if (value.trim().isEmpty) return;
    setState(() {
      _rows!.add(_SegmentRow(newId(), value.trim()));
      _dirty = true;
    });
  }

  Future<void> _editRow(int index) async {
    final String? value = await TextInputDialog.show(
      context,
      title: 'Seçeneği düzenle',
      hint: 'Örn. Pizza',
      confirmLabel: 'Tamam',
      initialValue: _rows![index].text,
    );
    if (value == null || !mounted) return;
    if (value.isEmpty) {
      _deleteRow(index);
      return;
    }
    setState(() {
      _rows![index].text = value;
      _dirty = true;
    });
  }

  void _deleteRow(int index) {
    setState(() {
      _rows!.removeAt(index);
      _dirty = true;
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final _SegmentRow row = _rows!.removeAt(oldIndex);
      _rows!.insert(newIndex, row);
      _dirty = true;
    });
  }

  void _clearAll() {
    setState(() {
      _rows!.clear();
      _dirty = true;
    });
  }

  /// Toplu ekleme: her satır bir seçenek. Boş satırlar atılır, kırpılır.
  Future<void> _pasteMany() async {
    final String? raw = await TextInputDialog.show(
      context,
      title: 'Toplu ekle',
      hint: 'Her satıra bir seçenek:\nAlihan\nDoğan\nMehmet\nAhmet\nAli',
      confirmLabel: 'Ekle',
      maxLines: 8,
      minLines: 5,
      capitalizeSentences: false,
    );

    if (raw == null || !mounted) return;
    final List<String> added = Wheel.normalizeSegments(raw.split('\n'));
    if (added.isEmpty) return;

    setState(() {
      _rows!.addAll(added.map((String text) => _SegmentRow(newId(), text)));
      _dirty = true;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${added.length} seçenek eklendi')),
      );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.total,
    required this.duplicates,
    required this.onPasteMany,
  });

  final int total;
  final int duplicates;
  final VoidCallback onPasteMany;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '$total seçenek',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onPasteMany,
                icon: const Icon(Icons.playlist_add, size: 20),
                label: const Text('Toplu ekle'),
              ),
            ],
          ),
          if (total < Wheel.minSegments)
            const _Note(
              'Çarkın dönebilmesi için en az 2 seçenek gerekli.',
              color: Color(0xFFF4B942),
            ),
          if (total > Wheel.recommendedMaxSegments)
            _Note(
              '$total seçenek çarkta okunması zor olabilir. '
              '${Wheel.recommendedMaxSegments} civarı idealdir.',
              color: const Color(0xFFF2833F),
            ),
          if (duplicates > 0)
            _Note(
              '$duplicates seçenek birden fazla kez yazılmış '
              '(izin verilir, çarkta ayrı dilim olur).',
              color: kTextSecondary,
            ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Text(text, style: TextStyle(fontSize: 12.5, color: color)),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({
    super.key,
    required this.index,
    required this.text,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final String text;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Material(
        color: kSurface,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(Radii.sm),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: kBorder),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: kTextPrimary),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, size: 20),
                  color: kTextSecondary,
                  tooltip: 'Seçeneği sil',
                  constraints: const BoxConstraints(
                    minWidth: Spacing.minTouchTarget,
                    minHeight: Spacing.minTouchTarget,
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: Spacing.xs),
                    child: Icon(Icons.drag_handle, color: kTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddBar extends StatefulWidget {
  const _AddBar({required this.onAdd, required this.onClear});

  final ValueChanged<String> onAdd;
  final VoidCallback? onClear;

  @override
  State<_AddBar> createState() => _AddBarState();
}

class _AddBarState extends State<_AddBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String value) {
    widget.onAdd(value);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.md,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Yeni seçenek yaz…',
                  ),
                  onSubmitted: _submit,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              FilledButton(
                onPressed: () => _submit(_controller.text),
                child: const Text('Ekle'),
              ),
            ],
          ),
          if (widget.onClear != null)
            TextButton(
              onPressed: widget.onClear,
              child: const Text(
                'Tüm seçenekleri temizle',
                style: TextStyle(color: kTextSecondary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
