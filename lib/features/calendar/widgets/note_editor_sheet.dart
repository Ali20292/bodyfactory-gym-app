import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_format.dart';

/// Labels offered as one-tap chips.
///
/// Suggestions, not a vocabulary: the field is free text, and "Sunday is leg
/// day" has to be typeable. These just save the typing for the ones almost
/// everyone uses.
const List<String> _suggestions = <String>[
  'Push',
  'Pull',
  'Legs',
  'Upper',
  'Lower',
  'Chest',
  'Back',
  'Arms',
  'Cardio',
  'Rest',
];

/// Free text for one day. Returns the label, or null if the user backed out.
Future<String?> showNoteEditorSheet(
  BuildContext context, {
  required DateTime date,
  String? initial,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.brandSurface,
    builder: (BuildContext context) =>
        _NoteEditor(date: date, initial: initial),
  );
}

class _NoteEditor extends StatefulWidget {
  const _NoteEditor({required this.date, this.initial});

  final DateTime date;
  final String? initial;

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String label = _controller.text.trim();
    if (label.isEmpty) return;
    Navigator.of(context).pop(label);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lifts the sheet clear of the keyboard, which otherwise covers the
      // field it belongs to.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
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
                AppDateFormat.dayLabel(widget.date),
                style: AppTextStyles.fieldLabel.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.initial == null ? 'Add a note' : 'Edit note',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                maxLength: 40,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.cream),
                decoration: const InputDecoration(
                  hintText: 'Leg day, Push, Rest…',
                  counterText: '',
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String suggestion in _suggestions)
                    _SuggestionChip(
                      label: suggestion,
                      onTap: () => setState(() {
                        _controller.text = suggestion;
                        _controller.selection = TextSelection.collapsed(
                          offset: suggestion.length,
                        );
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (BuildContext context, TextEditingValue value, _) {
                  return FilledButton(
                    onPressed: value.text.trim().isEmpty ? null : _submit,
                    child: const Text('Save note'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandSurfaceHi,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.brandLine),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm - 1,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.cream),
          ),
        ),
      ),
    );
  }
}
