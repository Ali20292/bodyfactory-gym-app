import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/models.dart';

/// Builds or edits a split.
///
/// Returns the template to save — the caller writes it, so this sheet stays a
/// form and nothing more. Null means the user backed out.
Future<SplitTemplate?> showTemplateEditorSheet(
  BuildContext context, {
  SplitTemplate? existing,
}) {
  return showModalBottomSheet<SplitTemplate>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.brandSurface,
    builder: (BuildContext context) => _TemplateEditor(existing: existing),
  );
}

class _TemplateEditor extends StatefulWidget {
  const _TemplateEditor({this.existing});

  final SplitTemplate? existing;

  @override
  State<_TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<_TemplateEditor> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  final TextEditingController _dayInput = TextEditingController();

  late final List<String> _days = <String>[...?widget.existing?.days];

  @override
  void dispose() {
    _name.dispose();
    _dayInput.dispose();
    super.dispose();
  }

  void _addDay([String? value]) {
    final String label = (value ?? _dayInput.text).trim();
    if (label.isEmpty) return;
    setState(() {
      _days.add(label);
      _dayInput.clear();
    });
  }

  void _move(int index, int delta) {
    final int target = index + delta;
    if (target < 0 || target >= _days.length) return;
    setState(() {
      final String moved = _days.removeAt(index);
      _days.insert(target, moved);
    });
  }

  void _submit() {
    if (_name.text.trim().isEmpty || _days.isEmpty) return;

    Navigator.of(context).pop(
      SplitTemplate(
        // Empty id means "new" — the repository assigns one.
        id: widget.existing?.id ?? '',
        name: _name.text.trim(),
        days: List<String>.unmodifiable(_days),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.existing == null ? 'New split' : 'Edit split',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.cream),
                decoration: const InputDecoration(
                  hintText: 'Push Pull Legs',
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'The cycle, in order',
                style: AppTextStyles.fieldLabel.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                // The ordering rule is not guessable, so it is stated where
                // the order is being decided rather than buried in the apply
                // screen.
                'Applied weekly, the first entry is Monday. Applied rotating, '
                'it starts on the first day of the range and rolls on.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandHint,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_days.isEmpty)
                Text(
                  'No days yet — add the first one below.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.brandHint,
                  ),
                )
              else
                for (int i = 0; i < _days.length; i++)
                  _DayRow(
                    index: i,
                    label: _days[i],
                    isFirst: i == 0,
                    isLast: i == _days.length - 1,
                    onUp: () => _move(i, -1),
                    onDown: () => _move(i, 1),
                    onRemove: () => setState(() => _days.removeAt(i)),
                  ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _dayInput,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 30,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.cream,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Add a day — Push, Rest…',
                        counterText: '',
                        isDense: true,
                      ),
                      onSubmitted: _addDay,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: _addDay,
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppColors.accent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _name.text.trim().isEmpty || _days.isEmpty
                    ? null
                    : _submit,
                child: Text(
                  _days.isEmpty
                      ? 'Add at least one day'
                      : 'Save ${_days.length}-day split',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.index,
    required this.label,
    required this.isFirst,
    required this.isLast,
    required this.onUp,
    required this.onDown,
    required this.onRemove,
  });

  final int index;
  final String label;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.brandSurfaceHi,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.brandLine),
      ),
      child: Row(
        children: <Widget>[
          Text(
            '${index + 1}',
            style: AppTextStyles.caption.copyWith(color: AppColors.brandHint),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cream),
            ),
          ),
          // Arrows rather than drag handles: a reorderable list inside a
          // scrolling sheet fights the sheet's own drag, and a cycle is rarely
          // more than seven entries.
          IconButton(
            onPressed: isFirst ? null : onUp,
            icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
            color: AppColors.brandMuted,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: isLast ? null : onDown,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            color: AppColors.brandMuted,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            color: AppColors.danger,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
