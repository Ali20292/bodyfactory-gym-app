import 'dart:async';
import 'dart:math';

import '../../core/config/app_config.dart';
import '../mock/mock_store.dart';
import '../models/models.dart';
import 'gym_repository.dart';

/// Simulates a realistic gym day instead of returning a constant.
///
/// The point is that the mock exercises the *real* code path: it keeps a list
/// of [CheckIn]s and derives occupancy by counting live windows on read —
/// exactly what the backend must do — rather than storing a number. So the
/// dedupe rule, the lazy expiry, and the clamped bar all get tested long
/// before a backend exists.
class MockGymRepository implements GymRepository {
  MockGymRepository({
    MockStore? store,
    Random? random,
    DateTime Function()? clock,
    Duration? sessionWindow,
    int? maxCapacity,
  }) : _store = store ?? MockStore(),
       _random = random ?? Random(),
       _now = clock ?? DateTime.now,
       _sessionWindow = sessionWindow ?? AppConfig.sessionWindow,
       _maxCapacity = maxCapacity ?? AppConfig.maxOccupancyFallback;

  /// Shared, so an event posted by staff shows up on Home.
  final MockStore _store;
  final Random _random;
  final DateTime Function() _now;
  final Duration _sessionWindow;
  final int _maxCapacity;

  final List<CheckIn> _checkIns = <CheckIn>[];
  OccupancyLevel? _forcedLevel;
  int _nextSimulatedMember = 0;

  @override
  Future<GymCapacity> fetchCapacity() async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final DateTime now = _now();
    _advanceSimulation(now);

    return GymCapacity(
      currentOccupancy: occupancyAt(now),
      maxCapacity: _maxCapacity,
      updatedAt: now,
    );
  }

  /// The count, computed on read over live windows — never a stored counter
  /// that drifts and never a scheduled decrement. This is correct even if
  /// nothing has called it for an hour.
  int occupancyAt(DateTime at) =>
      _checkIns.where((CheckIn checkIn) => checkIn.isActiveAt(at)).length;

  @override
  Future<List<GymEvent>> fetchEvents() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    // A copy, sorted — handing out the store's own list would let a caller
    // reorder the gym's data by accident.
    return _store.events.toList()
      ..sort((GymEvent a, GymEvent b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  void debugForceLevel(OccupancyLevel? level) => _forcedLevel = level;

  // --- Simulation --------------------------------------------------------

  /// Nudges the pool of check-ins toward the occupancy this time of day
  /// should show, then lets the window logic do the rest.
  void _advanceSimulation(DateTime now) {
    // Drop rows that expired long ago; keeping them would only grow the list.
    _checkIns.removeWhere(
      (CheckIn checkIn) =>
          checkIn.expiresAt.isBefore(now.subtract(const Duration(hours: 2))),
    );

    final int target = _targetOccupancy(now);
    final List<CheckIn> active = _checkIns
        .where((CheckIn checkIn) => checkIn.isActiveAt(now))
        .toList();

    if (active.length < target) {
      _admit(target - active.length, now);
      return;
    }

    if (active.length > target) {
      // Close the oldest windows early — the same path a real exit signal
      // would take if the entry system ever reported one.
      active.sort((CheckIn a, CheckIn b) => a.enteredAt.compareTo(b.enteredAt));
      for (final CheckIn leaving in active.take(active.length - target)) {
        final int index = _checkIns.indexOf(leaving);
        _checkIns[index] = leaving.closedAt(now);
      }
    }
  }

  void _admit(int count, DateTime now) {
    for (int i = 0; i < count; i++) {
      // Stagger arrivals across the window so expiries trickle rather than
      // dropping the whole room at once.
      final int minutesAgo = _random.nextInt(_sessionWindow.inMinutes);
      recordEntry(
        memberId: 'sim-${_nextSimulatedMember++}',
        at: now.subtract(Duration(minutes: minutesAgo)),
      );
    }
  }

  /// What the backend does with one signal from the entry system.
  ///
  /// Deduplicated by member: a badge re-scan inside an open window refreshes
  /// [CheckIn.expiresAt] rather than adding a second row, so stepping out and
  /// back cannot count anyone twice.
  void recordEntry({
    required String memberId,
    required DateTime at,
    CheckInSource source = CheckInSource.turnstile,
  }) {
    final int existing = _checkIns.indexWhere(
      (CheckIn checkIn) =>
          checkIn.memberId == memberId && checkIn.isActiveAt(at),
    );

    if (existing >= 0) {
      _checkIns[existing] = _checkIns[existing].refreshed(at, _sessionWindow);
      return;
    }

    _checkIns.add(
      CheckIn(
        memberId: memberId,
        enteredAt: at,
        expiresAt: at.add(_sessionWindow),
        source: source,
      ),
    );
  }

  int _targetOccupancy(DateTime now) {
    final OccupancyLevel? forced = _forcedLevel;
    if (forced != null) return _occupancyForLevel(forced);

    final int baseline = _baselineFor(now.hour);
    // Closed means closed — no jitter putting phantom members in an empty
    // gym, which is also what gives the daily reset its clean zero.
    if (baseline == 0) return 0;

    // Slight jitter each refresh so the 60-second auto-refresh is visibly
    // doing something.
    final int jitter = _random.nextInt(11) - 5;
    return (baseline + jitter).clamp(0, _maxCapacity + 10);
  }

  /// A believable curve over the day. Opening and closing hours are still an
  /// open question, so the small hours are simply treated as closed — which
  /// also gives the "reset at closing time" behaviour: the first member in the
  /// morning sees a near-empty gym, not yesterday's leftovers.
  int _baselineFor(int hour) => switch (hour) {
    < 6 => 0,
    6 || 7 || 8 => 20, // quiet mornings
    9 || 10 || 11 => 33,
    12 || 13 || 14 || 15 => 50, // moderate midday
    16 => 70,
    17 => 88,
    18 || 19 || 20 => 105, // peak
    21 => 70,
    _ => 12, // near-empty late
  };

  /// Mid-band occupancy for a forced level, expressed as a ratio so it stays
  /// correct if `maxCapacity` ever changes.
  int _occupancyForLevel(OccupancyLevel level) {
    final double ratio = switch (level) {
      OccupancyLevel.quiet => 0.25,
      OccupancyLevel.moderate => 0.55,
      OccupancyLevel.busy => 0.80,
      OccupancyLevel.packed => 0.97,
    };
    return (ratio * _maxCapacity).round();
  }
}
