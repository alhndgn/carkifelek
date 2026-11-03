import 'package:flutter/material.dart';

import '../core/templates.dart';
import '../theme/palette.dart';
import '../theme/spacing.dart';

/// Hiç çark yokken gösterilen karşılama ekranı: boş liste yerine
/// tek dokunuşla kullanılabilir hazır şablonlar sunar.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.templates,
    required this.onPickTemplate,
    required this.onCreateEmpty,
  });

  final List<WheelTemplate> templates;
  final ValueChanged<WheelTemplate> onPickTemplate;
  final VoidCallback onCreateEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: Spacing.xl),
          Center(
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[kAccent, kAccentAlt],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: kAccent.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.casino_outlined,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Henüz çarkın yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Bir şablonla başla ya da kendi seçeneklerinle sıfırdan oluştur.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: kTextSecondary),
          ),
          const SizedBox(height: Spacing.xl),
          Text(
            'Hazır şablonlar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextSecondary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          ...templates.map(
            (WheelTemplate template) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _TemplateTile(
                template: template,
                onTap: () => onPickTemplate(template),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          OutlinedButton.icon(
            onPressed: onCreateEmpty,
            style: OutlinedButton.styleFrom(
              foregroundColor: kTextPrimary,
              side: BorderSide(
                color: kBorder.withValues(alpha: 0.8),
                width: 1.4,
              ),
              minimumSize: const Size(0, Spacing.minTouchTarget),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Sıfırdan çark oluştur'),
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.onTap});

  final WheelTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, size: 20, color: kAccent),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      template.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                    ),
                    Text(
                      '${template.segments.length} seçenek',
                      style: TextStyle(
                        fontSize: 13,
                        color: kTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.add_circle_outline, color: kTextSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
