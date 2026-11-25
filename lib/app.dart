import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class GymApp extends ConsumerWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Body Factory',
      debugShowCheckedModeBanner: false,
      // One theme, both slots, and the mode pinned: the app is black and
      // orange whatever the phone is set to. Passing it as `darkTheme` too
      // means a device in light mode cannot fall back to something else.
      theme: AppTheme.brand,
      darkTheme: AppTheme.brand,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
