import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// Deliberately a stub — the recovery flow is not specified yet.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Forgot password',
      buildStep: 'Not specified yet — flow to be defined with the gym',
    );
  }
}
