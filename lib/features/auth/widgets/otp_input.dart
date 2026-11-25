import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One box per digit, with auto-advance, backspace-to-previous, and paste.
///
/// Built on a single hidden [EditableText] rather than one controller per box.
/// Per-box fields fight the platform over autofill, break paste of a whole
/// code, and make backspace behaviour inconsistent — the boxes here are
/// purely a drawing of one string.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
    this.hasError = false,
  });

  final int length;

  /// Fired when the last digit is entered.
  final ValueChanged<String> onCompleted;

  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool hasError;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String get _value => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // The code is the only thing on this screen; focus it immediately so the
    // keyboard is up and an SMS autofill suggestion can appear.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTextChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_value);
    if (_value.length == widget.length) {
      widget.onCompleted(_value);
    }
  }

  /// Empties the boxes and returns focus, for a rejected code.
  void clear() {
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // The real field, invisible but fully functional: it owns the
        // keyboard, the paste menu, and SMS autofill.
        SizedBox(
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              autofillHints: const <String>[AutofillHints.oneTimeCode],
              maxLength: widget.length,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              showCursor: false,
              style: const TextStyle(height: 1),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // Tapping anywhere on the boxes puts the caret back in the real field.
        GestureDetector(
          onTap: widget.enabled ? _focusNode.requestFocus : null,
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Six fixed-width boxes do not fit a 320px phone. Size them to
              // whatever room there is, capped so they never look oversized
              // on a tablet.
              const double gap = AppSpacing.xs * 2;
              final double available =
                  constraints.maxWidth - gap * widget.length;
              final double boxWidth = (available / widget.length).clamp(
                28.0,
                48.0,
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(widget.length, (int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: _DigitBox(
                      width: boxWidth,
                      digit: index < _value.length ? _value[index] : '',
                      isFocused: _focusNode.hasFocus && index == _value.length,
                      hasError: widget.hasError,
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.width,
    required this.digit,
    required this.isFocused,
    required this.hasError,
  });

  final double width;
  final String digit;
  final bool isFocused;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final Color border = hasError
        ? AppColors.danger
        : isFocused
        ? AppColors.accent
        : Colors.white24;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: width,
      // Keeps the boxes a consistent shape as they shrink on narrow screens.
      height: width * 1.25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border, width: isFocused ? 1.8 : 1),
      ),
      child: Text(
        digit,
        style: AppTextStyles.digits.copyWith(color: AppColors.cream),
      ),
    );
  }
}
