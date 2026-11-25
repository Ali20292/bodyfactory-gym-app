import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/gym_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// How full the gym is, kept fresh while the Home tab is on screen.
///
/// The app does no counting: it shows whatever `currentOccupancy` the
/// repository hands back. Everything here is about *when* to ask again.
class CapacityController extends AutoDisposeAsyncNotifier<GymCapacity> {
  Timer? _timer;

  /// Set in `onDispose`. A poll already in flight when the provider goes away
  /// would otherwise come back and assign to a dead notifier.
  bool _disposed = false;

  OccupancyLevel? _forcedLevel;

  /// Non-null while a debug build is pinning the bar to one level.
  OccupancyLevel? get forcedLevel => _forcedLevel;

  @override
  Future<GymCapacity> build() async {
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    return ref.watch(gymRepositoryProvider).fetchCapacity();
  }

  /// Starts or stops the 60-second poll.
  ///
  /// Driven by whether the Home tab is actually visible. The tab shell keeps
  /// every branch alive so its scroll position survives, which means `dispose`
  /// does not fire when you switch tabs — polling has to be stopped
  /// explicitly or the app quietly hits the endpoint forever from a screen
  /// nobody is looking at.
  void setPolling(bool enabled) {
    if (enabled == (_timer != null)) return;

    if (!enabled) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    _timer = Timer.periodic(
      AppConfig.capacityRefreshInterval,
      (Timer _) => unawaited(_poll()),
    );
  }

  /// The background refresh. Deliberately silent: a failed poll keeps the last
  /// good reading on screen rather than replacing a working bar with an error,
  /// and the next tick will try again anyway.
  Future<void> _poll() async {
    try {
      final GymCapacity next = await ref
          .read(gymRepositoryProvider)
          .fetchCapacity();
      if (_disposed) return;
      state = AsyncValue<GymCapacity>.data(next);
    } on Object {
      // Intentionally swallowed — see above.
    }
  }

  /// Pull-to-refresh. Unlike [_poll] this one surfaces failures, because the
  /// user asked for it and deserves to be told it did not work.
  Future<void> refresh() async {
    final AsyncValue<GymCapacity> next = await AsyncValue.guard<GymCapacity>(
      () => ref.read(gymRepositoryProvider).fetchCapacity(),
    );
    if (_disposed) return;
    state = next;
  }

  /// Debug builds only: steps quiet → moderate → busy → packed → live, so all
  /// four colour states can be checked without waiting for the clock.
  ///
  /// Returns the level now being forced, or null once it is back to live data.
  Future<OccupancyLevel?> cycleForcedLevel() async {
    if (!AppConfig.enableDevTools) return null;

    const List<OccupancyLevel> levels = OccupancyLevel.values;
    final OccupancyLevel? current = _forcedLevel;
    final OccupancyLevel? next;
    if (current == null) {
      next = levels.first;
    } else {
      final int index = levels.indexOf(current) + 1;
      next = index < levels.length ? levels[index] : null;
    }

    _forcedLevel = next;
    ref.read(gymRepositoryProvider).debugForceLevel(next);
    await refresh();
    return next;
  }
}

final AutoDisposeAsyncNotifierProvider<CapacityController, GymCapacity>
capacityControllerProvider =
    AsyncNotifierProvider.autoDispose<CapacityController, GymCapacity>(
      CapacityController.new,
    );

/// Events and offers for the Home tab.
///
/// Sorted by `startsAt` by the repository; anything already finished is
/// dropped here, since a list headed "what's on" should not open with last
/// week's workshop.
final AutoDisposeFutureProvider<List<GymEvent>> homeEventsProvider =
    FutureProvider.autoDispose<List<GymEvent>>((Ref ref) async {
      final GymRepository repository = ref.watch(gymRepositoryProvider);
      final List<GymEvent> events = await repository.fetchEvents();
      final DateTime now = DateTime.now();

      return events.where((GymEvent event) => !event.isPastAt(now)).toList();
    });
