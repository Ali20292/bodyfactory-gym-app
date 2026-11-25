import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../auth/controllers/auth_session_controller.dart';

/// Bottom-navigation container for the main tabs.
///
/// Wraps a [StatefulNavigationShell] so each tab keeps its own navigation
/// stack and scroll position when the user switches away and back.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// The four every member gets.
  static const List<NavigationDestination> _memberDestinations =
      <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_available_outlined),
          selectedIcon: Icon(Icons.event_available_rounded),
          label: 'Reservations',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Account',
        ),
      ];

  /// The fifth, for staff only.
  static const NavigationDestination _manageDestination = NavigationDestination(
    icon: Icon(Icons.tune_outlined),
    selectedIcon: Icon(Icons.tune_rounded),
    label: 'Manage',
  );

  void _onDestinationSelected(int index) {
    // Re-tapping the active tab pops that branch back to its root, which is
    // the behaviour users expect from a bottom bar.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Member? member = ref.watch(authSessionProvider).valueOrNull?.member;
    final bool isStaff = member?.isStaff ?? false;

    // The branch list is always five long — a StatefulShellRoute cannot change
    // shape at runtime — so the *destinations* are what varies. Index 4 simply
    // has no way to be reached without the fifth item, and the router's
    // redirect closes the deep-link route in as well.
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex.clamp(0, isStaff ? 4 : 3),
        onDestinationSelected: _onDestinationSelected,
        destinations: <NavigationDestination>[
          ..._memberDestinations,
          if (isStaff) _manageDestination,
        ],
      ),
    );
  }
}
