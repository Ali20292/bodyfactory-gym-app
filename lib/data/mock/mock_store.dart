import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'mock_data.dart';

/// The one in-memory copy of the gym's data, shared by every mock repository.
///
/// This exists because of the admin tools. `MockGymRepository` used to build a
/// fresh list from [MockData] on each call, which is fine when nothing writes
/// — but an event posted by staff has to appear on the members' Home screen,
/// and it cannot if the two sides are looking at different lists. One store,
/// injected into all of them, is what makes the demo behave like a backend.
///
/// Not a singleton: it is handed out by a provider, so a test can override it
/// with its own and get a clean gym.
class MockStore {
  MockStore() {
    events.addAll(MockData.events());
    trainers.addAll(MockData.trainers());
    slots.addAll(MockData.trainerSlots());
    classes.addAll(MockData.classes());
    reservations.addAll(MockData.reservations());
    reservations.addAll(MockData.otherMemberReservations());
    memberNames.addAll(MockData.otherMemberNames());

    _applySeededBookings();
  }

  final List<GymEvent> events = <GymEvent>[];
  final List<Trainer> trainers = <Trainer>[];
  final List<TrainerSlot> slots = <TrainerSlot>[];
  final List<GymClass> classes = <GymClass>[];
  final List<Reservation> reservations = <Reservation>[];

  /// Member id to display name, for the booking rosters. A real backend
  /// returns these with the roster; there is no endpoint that hands the client
  /// a list of every member, and there should not be.
  final Map<String, String> memberNames = <String, String>{
    MockData.demoMembershipId: 'yasser',
  };

  /// Who is signed in.
  ///
  /// A real backend reads this off the token — `GET /account` returns the
  /// holder's profile, not a fixed one. The mock needs somewhere to keep the
  /// same fact, and the store is it: the auth mock writes it at log-in and the
  /// account mock reads it. Without this, signing in as staff showed the
  /// member's name and invitations on the Account tab.
  Member signedInMember = MockData.member();

  int _sequence = 0;

  /// A new id that cannot collide with a seeded one.
  ///
  /// The `n` matters. The fixtures already use `rs-0`, `rs-1`, `ev-1` and so
  /// on, so a bare counter hands out ids that already exist — and then a
  /// lookup by id finds the fixture instead of the new row. That surfaced as
  /// "this booking can no longer be cancelled" when cancelling a booking made
  /// seconds earlier, because the id matched a completed one from last week.
  String nextId(String prefix) => '$prefix-n${_sequence++}';

  /// Reflects the seeded bookings in the catalogues they point at, so a slot
  /// someone holds does not also show as free.
  void _applySeededBookings() {
    for (final Reservation reservation in reservations.where(
      (Reservation r) => r.isConfirmed,
    )) {
      switch (reservation.kind) {
        case ReservationKind.trainer:
          final int index = slots.indexWhere(
            (TrainerSlot slot) => slot.id == reservation.referenceId,
          );
          if (index >= 0) {
            slots[index] = slots[index].copyWith(isBooked: true);
          }
        case ReservationKind.gymClass:
          final int index = classes.indexWhere(
            (GymClass gymClass) => gymClass.id == reservation.referenceId,
          );
          if (index >= 0) {
            final GymClass gymClass = classes[index];
            classes[index] = gymClass.copyWith(
              bookedCount: (gymClass.bookedCount + 1).clamp(
                0,
                gymClass.capacity,
              ),
            );
          }
      }
    }
  }
}

/// The store every mock repository shares.
///
/// Overriding this in a test gives that test its own gym, with none of the
/// writes another test made.
final Provider<MockStore> mockStoreProvider = Provider<MockStore>(
  (Ref ref) => MockStore(),
);
