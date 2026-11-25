import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/models.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';

/// Adds a class to the timetable, or changes one.
class ClassEditorScreen extends ConsumerStatefulWidget {
  const ClassEditorScreen({super.key, this.existing});

  final GymClass? existing;

  @override
  ConsumerState<ClassEditorScreen> createState() => _ClassEditorScreenState();
}

class _ClassEditorScreenState extends ConsumerState<ClassEditorScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final TextEditingController _instructor = TextEditingController(
    text: widget.existing?.instructorName ?? '',
  );
  late final TextEditingController _room = TextEditingController(
    text: widget.existing?.room ?? '',
  );
  late final TextEditingController _duration = TextEditingController(
    text: '${widget.existing?.durationMinutes ?? 45}',
  );
  late final TextEditingController _capacity = TextEditingController(
    text: '${widget.existing?.capacity ?? 20}',
  );

  late DateTime _startsAt =
      widget.existing?.startsAt ??
      DateTime.now().add(const Duration(days: 1, hours: 1));

  String? _error;
  bool _isSaving = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _instructor.dispose();
    _room.dispose();
    _duration.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final GymClass draft = GymClass(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      description: _description.text.trim(),
      instructorName: _instructor.text.trim(),
      startsAt: _startsAt,
      durationMinutes: int.tryParse(_duration.text.trim()) ?? 0,
      capacity: int.tryParse(_capacity.text.trim()) ?? 0,
      // Owned by the backend; the form never sets it.
      bookedCount: widget.existing?.bookedCount ?? 0,
      room: _room.text.trim(),
    );

    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .saveClass(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isNew ? 'Class added to the timetable.' : 'Saved.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Trainer> trainers =
        ref.watch(adminTrainersProvider).valueOrNull ?? const <Trainer>[];
    final Map<String, String> fieldErrors = ref
        .watch(adminActionsProvider)
        .fieldErrors;
    final int booked = widget.existing?.bookedCount ?? 0;

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_isNew ? 'New class' : 'Edit class'),
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
              hintText: 'Spin',
              errorText: fieldErrors['name'],
              enabled: !_isSaving,
              maxLength: 40,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Description',
              controller: _description,
              hintText: 'Intervals on the bike.',
              enabled: !_isSaving,
              maxLines: 3,
              maxLength: 160,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Instructor',
              controller: _instructor,
              hintText: 'Who is taking it?',
              errorText: fieldErrors['instructor'],
              enabled: !_isSaving,
              maxLength: 40,
              textInputAction: TextInputAction.next,
            ),
            if (trainers.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              // Free text with the roster as shortcuts: classes are often
              // taken by someone who is not on the trainer list, so the field
              // cannot be a closed dropdown.
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final Trainer trainer in trainers)
                    _NameChip(
                      label: trainer.name,
                      onTap: () => setState(() {
                        _instructor.text = trainer.name;
                      }),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Room',
              controller: _room,
              hintText: 'Studio 2',
              errorText: fieldErrors['room'],
              enabled: !_isSaving,
              maxLength: 30,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.xl),
            DateTimeField(
              label: 'Starts',
              value: _startsAt,
              onChanged: (DateTime value) => setState(() => _startsAt = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                Expanded(
                  child: AppTextField(
                    label: 'Minutes',
                    controller: _duration,
                    errorText: fieldErrors['duration'],
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: AppTextField(
                    label: 'Places',
                    controller: _capacity,
                    errorText: fieldErrors['capacity'],
                    enabled: !_isSaving,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 3,
                  ),
                ),
              ],
            ),
            if (booked > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$booked ${booked == 1 ? "person has" : "people have"} booked. '
                'Places cannot go below that.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
            ],
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
              label: _isNew ? 'Add to timetable' : 'Save changes',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _NameChip extends StatelessWidget {
  const _NameChip({required this.label, required this.onTap});

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
            vertical: AppSpacing.xs + 1,
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
