import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/screens/account_screen.dart';
import '../../features/admin/screens/class_roster_screen.dart';
import '../../features/admin/screens/manage_classes_screen.dart';
import '../../features/admin/screens/manage_events_screen.dart';
import '../../features/admin/screens/manage_screen.dart';
import '../../features/admin/screens/manage_trainers_screen.dart';
import '../../features/admin/screens/trainer_slots_screen.dart';
import '../../features/account/screens/edit_username_screen.dart';
import '../../features/account/screens/invitations_screen.dart';
import '../../features/account/screens/settings_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/calendar/screens/split_templates_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/reservations/screens/reservations_screen.dart';
import '../../features/reservations/screens/trainer_detail_screen.dart';
import '../../features/auth/controllers/auth_session_controller.dart';
import '../../features/shell/screens/app_shell.dart';
import '../../features/splash/controllers/app_boot_controller.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../data/models/models.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Routes reachable while logged out. Everything else requires a session.
const Set<String> _publicRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.forgotPassword,
  AppRoutes.signUp,
  AppRoutes.otp,
};

bool _isPublic(String location) => _publicRoutes.any(
  (String route) => location == route || location.startsWith('$route/'),
);

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final _RouterRefresh refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,

    // The auth gate. Driven by the session provider rather than by any screen
    // calling `go` after a delay, so a token that expires mid-session bounces
    // the user to Login the moment it happens.
    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;

      // Hold on the splash until the brand hold has elapsed *and* the saved
      // session has been read. Redirecting before both would flash Login at a
      // user who is in fact still signed in.
      final AsyncValue<AuthSession?> sessionAsync = ref.read(
        authSessionProvider,
      );
      final bool ready =
          ref.read(appBootProvider).hasValue && sessionAsync.hasValue;

      if (!ready) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final AuthSession? session = sessionAsync.valueOrNull;
      final bool signedIn = session != null && !session.isExpired;

      if (!signedIn) {
        // Splash has done its job; there is nothing to restore.
        if (location == AppRoutes.splash) return AppRoutes.login;
        return _isPublic(location) ? null : AppRoutes.login;
      }

      // Signed in: keep them out of the auth screens entirely.
      if (_isPublic(location)) return AppRoutes.home;

      // Staff-only. This closes the deep link and the restored-route case; it
      // is not what stops a member editing the gym's classes. The backend
      // re-checks the role on every write, because the app is public and this
      // check is trivially bypassed by anyone who cares to.
      if (location.startsWith(AppRoutes.manage) && !(session.member.isStaff)) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.nameSplash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.nameLogin,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'forgot-password',
            name: AppRoutes.nameForgotPassword,
            builder: (BuildContext context, GoRouterState state) =>
                const ForgotPasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.nameSignUp,
        builder: (BuildContext context, GoRouterState state) =>
            const SignUpScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'otp',
            name: AppRoutes.nameOtp,
            builder: (BuildContext context, GoRouterState state) {
              // Passed as `extra` rather than a path segment: the challenge is
              // only meaningful for one in-flight sign-up, and neither it nor
              // the masked number belongs in a restorable URL.
              final Object? extra = state.extra;
              if (extra is SignUpChallenge) {
                return OtpScreen(challenge: extra);
              }
              // Reached by deep link or a restored route with no challenge —
              // there is nothing to verify, so send them back to sign up.
              return const _MissingChallengeScreen();
            },
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.nameHome,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.reservations,
                name: AppRoutes.nameReservations,
                builder: (BuildContext context, GoRouterState state) =>
                    const ReservationsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'trainer/:trainerId',
                    name: AppRoutes.nameTrainerDetail,
                    builder: (BuildContext context, GoRouterState state) =>
                        TrainerDetailScreen(
                          trainerId: state.pathParameters['trainerId'] ?? '',
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.calendar,
                name: AppRoutes.nameCalendar,
                builder: (BuildContext context, GoRouterState state) =>
                    const CalendarScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'splits',
                    name: AppRoutes.nameSplits,
                    builder: (BuildContext context, GoRouterState state) =>
                        const SplitTemplatesScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.account,
                name: AppRoutes.nameAccount,
                builder: (BuildContext context, GoRouterState state) =>
                    const AccountScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'settings',
                    name: AppRoutes.nameSettings,
                    builder: (BuildContext context, GoRouterState state) =>
                        const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'invitations',
                    name: AppRoutes.nameInvitations,
                    builder: (BuildContext context, GoRouterState state) =>
                        const InvitationsScreen(),
                  ),
                  GoRoute(
                    path: 'username',
                    name: AppRoutes.nameEditUsername,
                    builder: (BuildContext context, GoRouterState state) =>
                        const EditUsernameScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Staff branch. Always present — a StatefulShellRoute's shape is
          // fixed — but the tab is only shown, and the routes only reachable,
          // for staff.
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.manage,
                name: AppRoutes.nameManage,
                builder: (BuildContext context, GoRouterState state) =>
                    const ManageScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'events',
                    name: AppRoutes.nameManageEvents,
                    builder: (BuildContext context, GoRouterState state) =>
                        const ManageEventsScreen(),
                  ),
                  GoRoute(
                    path: 'classes',
                    name: AppRoutes.nameManageClasses,
                    builder: (BuildContext context, GoRouterState state) =>
                        const ManageClassesScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':classId/roster',
                        name: AppRoutes.nameManageClassRoster,
                        builder: (BuildContext context, GoRouterState state) =>
                            ClassRosterScreen(
                              classId: state.pathParameters['classId'] ?? '',
                            ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'trainers',
                    name: AppRoutes.nameManageTrainers,
                    builder: (BuildContext context, GoRouterState state) =>
                        const ManageTrainersScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: ':trainerId/slots',
                        name: AppRoutes.nameManageTrainerSlots,
                        builder: (BuildContext context, GoRouterState state) =>
                            TrainerSlotsScreen(
                              trainerId:
                                  state.pathParameters['trainerId'] ?? '',
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        _RouteNotFoundScreen(location: state.uri.toString()),
  );
});

/// Shown if the OTP route is reached without a challenge — a deep link, or a
/// route restored after the process was killed. There is nothing to verify in
/// that state, so the only honest move is to send the user back to sign up.
class _MissingChallengeScreen extends StatelessWidget {
  const _MissingChallengeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'That verification has expired.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRoutes.signUp),
                child: const Text('Start again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bridges Riverpod to `go_router`, which re-evaluates its `redirect` when the
/// listenable it was given notifies.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(appBootProvider, (_, _) => notifyListeners());
    ref.listen(authSessionProvider, (_, _) => notifyListeners());
  }
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'No screen at $location',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
