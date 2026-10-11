import 'package:flutter/material.dart';

/// Tek satır metin isteyen basit onay diyaloğu.
///
/// Controller'ı State sahiplenir ve `dispose()` içinde bırakır; böylece
/// diyaloğun kapanış animasyonu sırasında "controller used after dispose"
/// hatası oluşmaz (dialog çağıran tarafta controller tutmak bu hatayı verir).
class TextInputDialog extends StatefulWidget {
  const TextInputDialog({
    super.key,
    required this.title,
    required this.hint,
    required this.confirmLabel,
    this.initialValue,
    this.capitalizeSentences = true,
    this.maxLines = 1,
    this.minLines = 1,
  });

  final String title;
  final String hint;
  final String confirmLabel;
  final String? initialValue;
  final bool capitalizeSentences;

  /// 1'den büyükse çok satırlı giriş (toplu ekleme) için kullanılır.
  final int maxLines;
  final int minLines;

  /// Diyaloğu açar; onaylanırsa kırpılmış metni, vazgeçilirse null döner.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String hint,
    required String confirmLabel,
    String? initialValue,
    bool capitalizeSentences = true,
    int maxLines = 1,
    int minLines = 1,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => TextInputDialog(
        title: title,
        hint: hint,
        confirmLabel: confirmLabel,
        initialValue: initialValue,
        capitalizeSentences: capitalizeSentences,
        maxLines: maxLines,
        minLines: minLines,
      ),
    );
  }

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    // Çok satırlı girişte satır sonu korunur; tek satırda kırpılır.
    if (widget.maxLines > 1) {
      Navigator.of(context).pop(_controller.text);
      return;
    }
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        textCapitalization: widget.capitalizeSentences
            ? TextCapitalization.sentences
            : TextCapitalization.none,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
