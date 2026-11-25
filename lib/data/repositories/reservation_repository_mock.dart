import 'dart:async';

import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../mock/mock_data.dart';
import '../mock/mock_store.dart';
import '../models/models.dart';
import 'reservation_repository.dart';

/// In-memory bookings. Writes mutate the seeded lists, so booking a slot and
/// then reopening the screen shows it taken — the UI gets a moving target
/// rather than a frozen fixture.
class MockReservationRepository implements ReservationRepository {
  MockReservationRepository({MockStore? store, DateTime Function()? clock})
    : _store = store ?? MockStore(),
      _now = clock ?? DateTime.now;

  /// Shared with the gym and admin repositories, so a class posted by staff
  /// turns up here without anything having to be told about it.
  final MockStore _store;
  final DateTime Function() _now;

  List<Trainer> get _trainers => _store.trainers;
  List<TrainerSlot> get _slots => _store.slots;
  List<GymClass> get _classes => _store.classes;
  List<Reservation> get _reservations => _store.reservations;

  @override
  Future<List<Trainer>> fetchTrainers() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return List<Trainer>.unmodifiable(_trainers);
  }

  @override
  Future<Trainer> fetchTrainer(String trainerId) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    final int index = _trainers.indexWhere((Trainer t) => t.id == trainerId);
    if (index < 0) {
      throw const NotFoundFailure('That trainer is no longer listed.');
    }
    return _trainers[index];
  }

  @override
  Future<List<TrainerSlot>> fetchTrainerSlots(String trainerId) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _slots
        .where((TrainerSlot slot) => slot.trainerId == trainerId)
        .toList()
      ..sort(
        (TrainerSlot a, TrainerSlot b) => a.startsAt.compareTo(b.startsAt),
      );
  }

  @override
  Future<List<GymClass>> fetchClasses() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    final DateTime now = _now();
    return _classes
        .where((GymClass gymClass) => !gymClass.isPastAt(now))
        .toList()
      ..sort((GymClass a, GymClass b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<List<Reservation>> fetchMyReservations() async {
    await Future<void>.delayed(AppConfig.mockLatency);

    // Filtered by member, because the store now holds other people's bookings
    // too — they are what the staff rosters are made of. The real endpoint
    // scopes to the token holder; this is the same rule, enforced here.
    return _reservations
        .where(
          (Reservation reservation) =>
              reservation.memberId == MockData.demoMembershipId,
        )
        .toList()
      ..sort(
        (Reservation a, Reservation b) => a.startsAt.compareTo(b.startsAt),
      );
  }

  @override
  Future<Reservation> bookTrainerSlot(String slotId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final int index = _slots.indexWhere(
      (TrainerSlot slot) => slot.id == slotId,
    );
    if (index < 0) {
      throw const NotFoundFailure('That slot is no longer available.');
    }

    final TrainerSlot slot = _slots[index];
    // Re-checked here, not just in the UI: the slot may have gone between the
    // list loading and the tap.
    if (!slot.isBookableAt(_now())) {
      throw const ConflictFailure(
        'That slot has just been taken. Please pick another time.',
      );
    }

    _slots[index] = slot.copyWith(isBooked: true);

    final Reservation reservation = Reservation(
      id: _store.nextId('rs'),
      memberId: MockData.demoMembershipId,
      kind: ReservationKind.trainer,
      referenceId: slot.id,
      startsAt: slot.startsAt,
      status: ReservationStatus.confirmed,
    );
    _reservations.add(reservation);
    return reservation;
  }

  @override
  Future<Reservation> bookClass(String classId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final int index = _classes.indexWhere((GymClass c) => c.id == classId);
    if (index < 0) {
      throw const NotFoundFailure('That class is no longer listed.');
    }

    final GymClass gymClass = _classes[index];
    if (!gymClass.isBookableAt(_now())) {
      throw const ConflictFailure(
        'That class just filled up. Please pick another one.',
      );
    }

    _classes[index] = gymClass.copyWith(bookedCount: gymClass.bookedCount + 1);

    final Reservation reservation = Reservation(
      id: _store.nextId('rs'),
      memberId: MockData.demoMembershipId,
      kind: ReservationKind.gymClass,
      referenceId: gymClass.id,
      startsAt: gymClass.startsAt,
      status: ReservationStatus.confirmed,
    );
    _reservations.add(reservation);
    return reservation;
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final int index = _reservations.indexWhere(
      (Reservation r) => r.id == reservationId,
    );
    if (index < 0) {
      throw const NotFoundFailure('That booking no longer exists.');
    }

    final Reservation reservation = _reservations[index];
    if (!reservation.isCancellableAt(_now())) {
      throw const ConflictFailure('That booking can no longer be cancelled.');
    }

    _reservations[index] = reservation.copyWith(
      status: ReservationStatus.cancelled,
    );

    // Hand the place back so the lists stay consistent.
    _releasePlace(reservation);
  }

  void _releasePlace(Reservation reservation) {
    switch (reservation.kind) {
      case ReservationKind.trainer:
        final int index = _slots.indexWhere(
          (TrainerSlot slot) => slot.id == reservation.referenceId,
        );
        if (index >= 0) {
          _slots[index] = _slots[index].copyWith(isBooked: false);
        }
      case ReservationKind.gymClass:
        final int index = _classes.indexWhere(
          (GymClass gymClass) => gymClass.id == reservation.referenceId,
        );
        if (index >= 0) {
          final GymClass gymClass = _classes[index];
          _classes[index] = gymClass.copyWith(
            bookedCount: (gymClass.bookedCount - 1).clamp(0, gymClass.capacity),
          );
        }
    }
  }
}
