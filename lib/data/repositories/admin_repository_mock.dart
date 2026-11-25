import 'dart:async';

import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../mock/mock_store.dart';
import '../models/models.dart';
import 'admin_repository.dart';

/// Staff writes against the shared [MockStore].
///
/// Because it is the same store the member-facing mocks read, an event posted
/// here appears on Home and a class posted here appears under Reservations —
/// which is the only way to tell whether the admin tools actually work.
///
/// It also enforces the rules the real backend will have to: capacity cannot
/// be cut below what is booked, a trainer with sessions cannot be deleted, a
/// booked slot cannot be withdrawn. Those checks living here means the UI is
/// built against a backend that says no.
class MockAdminRepository implements AdminRepository {
  MockAdminRepository({MockStore? store, DateTime Function()? clock})
    : _store = store ?? MockStore(),
      _now = clock ?? DateTime.now;

  final MockStore _store;
  final DateTime Function() _now;

  // --- Events ------------------------------------------------------------

  @override
  Future<List<GymEvent>> fetchAllEvents() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _store.events.toList()
      ..sort((GymEvent a, GymEvent b) => b.startsAt.compareTo(a.startsAt));
  }

  @override
  Future<GymEvent> createEvent(GymEvent draft) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _validateEvent(draft);

    final GymEvent created = draft.copyWith(id: _store.nextId('ev'));
    _store.events.add(created);
    return created;
  }

  @override
  Future<GymEvent> updateEvent(GymEvent event) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _validateEvent(event);

    final int index = _store.events.indexWhere(
      (GymEvent e) => e.id == event.id,
    );
    if (index < 0) throw const NotFoundFailure('That post no longer exists.');

    _store.events[index] = event;
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _store.events.removeWhere((GymEvent event) => event.id == eventId);
  }

  void _validateEvent(GymEvent event) {
    if (event.title.trim().isEmpty) {
      throw const ValidationFailure(
        'Give it a title.',
        fieldErrors: <String, String>{'title': 'Give it a title.'},
      );
    }
    final DateTime? endsAt = event.endsAt;
    if (endsAt != null && !endsAt.isAfter(event.startsAt)) {
      throw const ValidationFailure(
        'It has to end after it starts.',
        fieldErrors: <String, String>{'endsAt': 'Must be after the start.'},
      );
    }
  }

  // --- Classes -----------------------------------------------------------

  @override
  Future<List<GymClass>> fetchAllClasses() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return _store.classes.toList()
      ..sort((GymClass a, GymClass b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<GymClass> createClass(GymClass draft) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _validateClass(draft);

    final GymClass created = draft.copyWith(
      id: _store.nextId('cl'),
      // A new class starts empty whatever the draft said.
      bookedCount: 0,
    );
    _store.classes.add(created);
    return created;
  }

  @override
  Future<GymClass> updateClass(GymClass gymClass) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _validateClass(gymClass);

    final int index = _store.classes.indexWhere(
      (GymClass c) => c.id == gymClass.id,
    );
    if (index < 0) throw const NotFoundFailure('That class no longer exists.');

    final int booked = _store.classes[index].bookedCount;
    if (gymClass.capacity < booked) {
      throw ValidationFailure(
        '$booked ${booked == 1 ? "person has" : "people have"} already booked. '
        'Capacity cannot go below that.',
        fieldErrors: <String, String>{'capacity': 'At least $booked.'},
      );
    }

    // bookedCount is the backend's to maintain, never the form's.
    final GymClass saved = gymClass.copyWith(bookedCount: booked);
    _store.classes[index] = saved;
    return saved;
  }

  @override
  Future<int> cancelClass(String classId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final List<Reservation> affected = _store.reservations
        .where(
          (Reservation r) =>
              r.kind == ReservationKind.gymClass &&
              r.referenceId == classId &&
              r.isConfirmed,
        )
        .toList();

    for (final Reservation reservation in affected) {
      final int index = _store.reservations.indexOf(reservation);
      _store.reservations[index] = reservation.copyWith(
        status: ReservationStatus.cancelled,
      );
    }

    _store.classes.removeWhere((GymClass gymClass) => gymClass.id == classId);
    return affected.length;
  }

  void _validateClass(GymClass gymClass) {
    final Map<String, String> errors = <String, String>{};
    if (gymClass.name.trim().isEmpty) errors['name'] = 'Give it a name.';
    if (gymClass.instructorName.trim().isEmpty) {
      errors['instructor'] = 'Who is taking it?';
    }
    if (gymClass.room.trim().isEmpty) errors['room'] = 'Where is it?';
    if (gymClass.capacity < 1) errors['capacity'] = 'At least one place.';
    if (gymClass.durationMinutes < 5) {
      errors['duration'] = 'At least 5 minutes.';
    }

    if (errors.isNotEmpty) {
      throw ValidationFailure(errors.values.first, fieldErrors: errors);
    }
  }

  // --- Trainers ----------------------------------------------------------

  @override
  Future<Trainer> createTrainer(Trainer draft) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _validateTrainer(draft);

    final Trainer created = draft.copyWith(id: _store.nextId('tr'));
    _store.trainers.add(created);
    return created;
  }

  @override
  Future<Trainer> updateTrainer(Trainer trainer) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _validateTrainer(trainer);

    final int index = _store.trainers.indexWhere(
      (Trainer t) => t.id == trainer.id,
    );
    if (index < 0) {
      throw const NotFoundFailure('That trainer no longer exists.');
    }

    _store.trainers[index] = trainer;
    return trainer;
  }

  @override
  Future<void> deleteTrainer(String trainerId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final bool hasBookings = _store.slots.any(
      (TrainerSlot slot) =>
          slot.trainerId == trainerId &&
          slot.isBooked &&
          !slot.isPastAt(_now()),
    );
    if (hasBookings) {
      throw const ConflictFailure(
        'That trainer still has booked sessions. Cancel those first.',
      );
    }

    _store.trainers.removeWhere((Trainer trainer) => trainer.id == trainerId);
    _store.slots.removeWhere((TrainerSlot slot) => slot.trainerId == trainerId);
  }

  void _validateTrainer(Trainer trainer) {
    final Map<String, String> errors = <String, String>{};
    if (trainer.name.trim().isEmpty) errors['name'] = 'Give them a name.';
    if (trainer.specialties.isEmpty) {
      errors['specialties'] = 'Add at least one specialty.';
    }
    if (errors.isNotEmpty) {
      throw ValidationFailure(errors.values.first, fieldErrors: errors);
    }
  }

  @override
  Future<List<TrainerSlot>> publishSlots({
    required String trainerId,
    required List<DateTime> startTimes,
    required int durationMinutes,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    if (startTimes.isEmpty) {
      throw const ValidationFailure('Pick at least one time.');
    }
    if (!_store.trainers.any((Trainer t) => t.id == trainerId)) {
      throw const NotFoundFailure('That trainer no longer exists.');
    }

    final List<TrainerSlot> created = <TrainerSlot>[];
    for (final DateTime startsAt in startTimes) {
      // Publishing the same week twice is a thing staff will do by accident;
      // it should be a no-op rather than a doubled schedule.
      final bool exists = _store.slots.any(
        (TrainerSlot slot) =>
            slot.trainerId == trainerId &&
            slot.startsAt.isAtSameMomentAs(startsAt),
      );
      if (exists) continue;

      final TrainerSlot slot = TrainerSlot(
        id: _store.nextId('slot'),
        trainerId: trainerId,
        startsAt: startsAt,
        durationMinutes: durationMinutes,
        isBooked: false,
      );
      _store.slots.add(slot);
      created.add(slot);
    }

    return created;
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final int index = _store.slots.indexWhere(
      (TrainerSlot slot) => slot.id == slotId,
    );
    if (index < 0) return;

    if (_store.slots[index].isBooked) {
      throw const ConflictFailure(
        'Someone holds that time. Cancel their booking first.',
      );
    }

    _store.slots.removeAt(index);
  }

  // --- Rosters -----------------------------------------------------------

  @override
  Future<List<RosterEntry>> fetchClassRoster(String classId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    return _store.reservations
        .where(
          (Reservation r) =>
              r.kind == ReservationKind.gymClass &&
              r.referenceId == classId &&
              r.isConfirmed,
        )
        .map(_entryFor)
        .toList();
  }

  @override
  Future<Map<String, RosterEntry>> fetchTrainerRoster(String trainerId) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final Set<String> slotIds = _store.slots
        .where((TrainerSlot slot) => slot.trainerId == trainerId)
        .map((TrainerSlot slot) => slot.id)
        .toSet();

    return <String, RosterEntry>{
      for (final Reservation reservation in _store.reservations.where(
        (Reservation r) =>
            r.kind == ReservationKind.trainer &&
            r.isConfirmed &&
            slotIds.contains(r.referenceId),
      ))
        reservation.referenceId: _entryFor(reservation),
    };
  }

  RosterEntry _entryFor(Reservation reservation) => RosterEntry(
    memberId: reservation.memberId,
    // A member the store has no name for still gets a row: staff need to know
    // a place is taken even when the lookup came back thin.
    username: _store.memberNames[reservation.memberId] ?? 'Member',
    bookedAt: reservation.startsAt,
  );
}
