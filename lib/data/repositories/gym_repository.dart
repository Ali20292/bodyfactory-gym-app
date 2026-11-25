import '../models/models.dart';

/// Gym-wide data: how busy it is, and what is on.
abstract class GymRepository {
  /// One call to `GET /gym/capacity`. The app displays whatever
  /// `currentOccupancy` comes back — it never counts anything itself, and it
  /// never receives raw check-in rows, because a list of who is at the gym
  /// right now must not reach a client.
  Future<GymCapacity> fetchCapacity();

  /// Events and offers for the Home tab, sorted by `startsAt`.
  Future<List<GymEvent>> fetchEvents();

  /// Debug-only: forces the next [fetchCapacity] to a chosen level so all four
  /// colour states can be checked without waiting for the clock.
  ///
  /// Declared on the interface, not on the mock, so the Home screen can offer
  /// the dev long-press without importing a `_mock` class. The API
  /// implementation ignores it.
  void debugForceLevel(OccupancyLevel? level);
}
