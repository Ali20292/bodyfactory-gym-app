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
import '../widgets/admin_widgets.dart';

/// Posts an event or an offer to the members' Home screen.
///
/// Pushed as a full page rather than a sheet: it is a long form, and a form
/// this tall in a sheet fights the keyboard the whole way down.
class EventEditorScreen extends ConsumerStatefulWidget {
  const EventEditorScreen({super.key, this.existing});

  final GymEvent? existing;

  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.existing?.description ?? '',
  );
  late final TextEditingController _imageUrl = TextEditingController(
    text: widget.existing?.imageUrl ?? '',
  );

  late GymEventType _type = widget.existing?.type ?? GymEventType.event;
  late DateTime _startsAt =
      widget.existing?.startsAt ??
      DateTime.now().add(const Duration(days: 1, hours: 1));
  late DateTime? _endsAt = widget.existing?.endsAt;

  String? _error;
  bool _isSaving = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final GymEvent draft = GymEvent(
      id: widget.existing?.id ?? '',
      title: _title.text.trim(),
      description: _description.text.trim(),
      startsAt: _startsAt,
      endsAt: _endsAt,
      type: _type,
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
    );

    final String? error = await ref
        .read(adminActionsProvider.notifier)
        .saveEvent(draft);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isNew ? 'Posted to Home.' : 'Changes saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_isNew ? 'New post' : 'Edit post'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.lg,
            AppSpacing.screenH,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            _TypeToggle(
              type: _type,
              onChanged: (GymEventType type) => setState(() => _type = type),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Title',
              controller: _title,
              hintText: 'Deadlift technique workshop',
              enabled: !_isSaving,
              maxLength: 60,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Description',
              controller: _description,
              hintText: 'What is it, and what should they bring?',
              enabled: !_isSaving,
              maxLines: 4,
              maxLength: 240,
            ),
            const SizedBox(height: AppSpacing.xl),
            DateTimeField(
              label: _type == GymEventType.offer ? 'Runs from' : 'Starts',
              value: _startsAt,
              onChanged: (DateTime value) => setState(() => _startsAt = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            DateTimeField(
              label: _type == GymEventType.offer ? 'Until' : 'Ends (optional)',
              value: _endsAt,
              onChanged: (DateTime value) => setState(() => _endsAt = value),
              onClear: () => setState(() => _endsAt = null),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Image link (optional)',
              controller: _imageUrl,
              hintText: 'https://…',
              enabled: !_isSaving,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              // Honest about the current limitation rather than offering an
              // upload button that has nowhere to upload to.
              'Paste a link for now. Uploading a picture from the phone needs '
              'a place to put it, which arrives with the backend.',
              style: AppTextStyles.caption.copyWith(color: AppColors.brandHint),
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
              label: _isNew ? 'Post it' : 'Save changes',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.type, required this.onChanged});

  final GymEventType type;
  final ValueChanged<GymEventType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _TypeChip(
            label: 'Event',
            description: 'Something happening at a time',
            isSelected: type == GymEventType.event,
            onTap: () => onChanged(GymEventType.event),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TypeChip(
            label: 'Offer',
            description: 'A deal that runs for a while',
            isSelected: type == GymEventType.offer,
            onTap: () => onChanged(GymEventType.offer),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.accent.withValues(alpha: 0.14)
          : AppColors.brandSurface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.brandLine,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isSelected ? AppColors.accent : AppColors.cream,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.brandMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
