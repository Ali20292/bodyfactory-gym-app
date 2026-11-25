import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';

/// Adds a coach to the trainer list, or edits one.
class TrainerEditorScreen extends ConsumerStatefulWidget {
  const TrainerEditorScreen({super.key, this.existing});

  final Trainer? existing;

  @override
  ConsumerState<TrainerEditorScreen> createState() =>
      _TrainerEditorScreenState();
}

class _TrainerEditorScreenState extends ConsumerState<TrainerEditorScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _bio = TextEditingController(
    text: widget.existing?.bio ?? '',
  );
  late final TextEditingController _photoUrl = TextEditingController(
    text: widget.existing?.photoUrl ?? '',
  );
  final TextEditingController _specialtyInput = TextEditingController();

  late final List<String> _specialties = <String>[
    ...?widget.existing?.specialties,
  ];

  String? _error;
  bool _isSaving = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _photoUrl.dispose();
    _specialtyInput.dispose();
    super.dispose();
  }

  void _addSpecialty([String? value]) {
    final String label = (value ?? _specialtyInput.text).trim();
    if (label.isEmpty || _specialties.contains(label)) {
      _specialtyInput.clear();
      return;
    }
    setState(() {
      _specialties.add(label);
      _specialtyInput.clear();
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final Trainer draft = Trainer(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      specialties: List<String>.unmodifiable(_specialties),
      bio: _bio.text.trim(),
      photoUrl: _photoUrl.text.trim().isEmpty ? null : _photoUrl.text.trim(),
      // Ratings come from members, not from this form.
      rating: widget.existing?.rating,
    );

    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .saveTrainer(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isNew ? 'Trainer added.' : 'Saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> fieldErrors = ref
        .watch(adminActionsProvider)
        .fieldErrors;

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_isNew ? 'New trainer' : 'Edit trainer'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.lg,
            AppSpacing.screenH,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            AppTextField(
              label: 'Name',
              controller: _name,
              hintText: 'Karim Adel',
              errorText: fieldErrors['name'],
              enabled: !_isSaving,
              maxLength: 40,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Bio',
              controller: _bio,
              hintText: 'What they coach, and how they work.',
              enabled: !_isSaving,
              maxLines: 4,
              maxLength: 240,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Specialties',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.brandMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_specialties.isEmpty)
              Text(
                fieldErrors['specialties'] ?? 'Add at least one.',
                style: AppTextStyles.caption.copyWith(
                  color: fieldErrors['specialties'] == null
                      ? AppColors.brandHint
                      : AppColors.danger,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String specialty in _specialties)
                    _RemovableChip(
                      label: specialty,
                      onRemove: () =>
                          setState(() => _specialties.remove(specialty)),
                    ),
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: 'Add a specialty',
                    controller: _specialtyInput,
                    hintText: 'Powerlifting',
                    enabled: !_isSaving,
                    maxLength: 24,
                    onSubmitted: _addSpecialty,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: IconButton(
                    onPressed: _isSaving ? null : _addSpecialty,
                    icon: const Icon(Icons.add_circle_rounded),
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Photo link (optional)',
              controller: _photoUrl,
              hintText: 'https://…',
              enabled: !_isSaving,
              keyboardType: TextInputType.url,
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text(
                _error!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _isNew ? 'Add trainer' : 'Save changes',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.sm,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
