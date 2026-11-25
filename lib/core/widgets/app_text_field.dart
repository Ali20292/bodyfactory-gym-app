import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

/// Labelled text field with inline error text.
///
/// Validation messages render under the field — never in a snackbar.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.centerLabel = false,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;

  /// Centres the label over the field, for centre-aligned layouts.
  final bool centerLabel;

  /// More than one turns the field into a text area, for descriptions and
  /// notes. An obscured field ignores it — Flutter does not allow a
  /// multi-line password.
  final int maxLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      // Always stretch: the field must fill the width. The label is centred
      // by its own textAlign, not by the column, which would shrink the
      // field to its intrinsic size.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          widget.label,
          textAlign: widget.centerLabel ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          maxLength: widget.maxLength,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperStyle: theme.textTheme.labelSmall,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon, size: 20),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                    ),
                    tooltip: _isObscured ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
