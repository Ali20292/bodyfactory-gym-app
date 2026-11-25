import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../home/controllers/home_controller.dart';
import '../../reservations/controllers/reservations_controller.dart';

/// Everything staff have posted, including what has already happened.
final AutoDisposeFutureProvider<List<GymEvent>> adminEventsProvider =
    FutureProvider.autoDispose<List<GymEvent>>(
      (Ref ref) => ref.watch(adminRepositoryProvider).fetchAllEvents(),
    );

final AutoDisposeFutureProvider<List<GymClass>> adminClassesProvider =
    FutureProvider.autoDispose<List<GymClass>>(
      (Ref ref) => ref.watch(adminRepositoryProvider).fetchAllClasses(),
    );

/// The trainer list, read through the member-facing repository — staff and
/// members are looking at the same roster of coaches.
final AutoDisposeFutureProvider<List<Trainer>> adminTrainersProvider =
    FutureProvider.autoDispose<List<Trainer>>(
      (Ref ref) => ref.watch(reservationRepositoryProvider).fetchTrainers(),
    );

final AutoDisposeFutureProviderFamily<List<TrainerSlot>, String>
adminTrainerSlotsProvider = FutureProvider.autoDispose
    .family<List<TrainerSlot>, String>(
      (Ref ref, String trainerId) =>
          ref.watch(reservationRepositoryProvider).fetchTrainerSlots(trainerId),
    );

final AutoDisposeFutureProviderFamily<List<RosterEntry>, String>
classRosterProvider = FutureProvider.autoDispose
    .family<List<RosterEntry>, String>(
      (Ref ref, String classId) =>
          ref.watch(adminRepositoryProvider).fetchClassRoster(classId),
    );

/// Who holds each of a trainer's slots, keyed by slot id.
final AutoDisposeFutureProviderFamily<Map<String, RosterEntry>, String>
trainerRosterProvider = FutureProvider.autoDispose
    .family<Map<String, RosterEntry>, String>(
      (Ref ref, String trainerId) =>
          ref.watch(adminRepositoryProvider).fetchTrainerRoster(trainerId),
    );

@immutable
class AdminActionState {
  const AdminActionState({
    this.isSaving = false,
    this.fieldErrors = const <String, String>{},
  });

  final bool isSaving;

  /// Per-field messages from the last rejected write, so a form can put the
  /// reason under the field that caused it.
  final Map<String, String> fieldErrors;
}

/// Every staff write.
///
/// Each one refreshes the member-facing providers as well as the staff ones —
/// posting an event is pointless if Home does not show it until the next cold
/// start.
class AdminActions extends Notifier<AdminActionState> {
  @override
  AdminActionState build() => const AdminActionState();

  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  void _refreshEvents() {
    ref.invalidate(adminEventsProvider);
    ref.invalidate(homeEventsProvider);
  }

  void _refreshClasses() {
    ref.invalidate(adminClassesProvider);
    ref.invalidate(classesProvider);
    ref.invalidate(myReservationsProvider);
  }

  void _refreshTrainers() {
    ref.invalidate(adminTrainersProvider);
    ref.invalidate(trainersProvider);
    ref.invalidate(trainerProvider);
  }

  void _refreshSlots() {
    ref.invalidate(adminTrainerSlotsProvider);
    ref.invalidate(trainerSlotsProvider);
    ref.invalidate(trainerRosterProvider);
  }

  // --- Events ------------------------------------------------------------

  /// Creates when [event] has no id, updates when it does. Returns null on
  /// success, a message otherwise.
  Future<String?> saveEvent(GymEvent event) => _write(() async {
    if (event.id.isEmpty) {
      await _repository.createEvent(event);
    } else {
      await _repository.updateEvent(event);
    }
    _refreshEvents();
  });

  Future<String?> deleteEvent(String eventId) => _write(() async {
    await _repository.deleteEvent(eventId);
    _refreshEvents();
  });

  // --- Classes -----------------------------------------------------------

  Future<String?> saveClass(GymClass gymClass) => _write(() async {
    if (gymClass.id.isEmpty) {
      await _repository.createClass(gymClass);
    } else {
      await _repository.updateClass(gymClass);
    }
    _refreshClasses();
  });

  /// Returns the number of bookings released, or an error message.
  Future<(int?, String?)> cancelClass(String classId) async {
    state = const AdminActionState(isSaving: true);
    try {
      final int released = await _repository.cancelClass(classId);
      _refreshClasses();
      return (released, null);
    } on Failure catch (failure) {
      return (null, failure.message);
    } finally {
      state = const AdminActionState();
    }
  }

  // --- Trainers ----------------------------------------------------------

  Future<String?> saveTrainer(Trainer trainer) => _write(() async {
    if (trainer.id.isEmpty) {
      await _repository.createTrainer(trainer);
    } else {
      await _repository.updateTrainer(trainer);
    }
    _refreshTrainers();
  });

  Future<String?> deleteTrainer(String trainerId) => _write(() async {
    await _repository.deleteTrainer(trainerId);
    _refreshTrainers();
    _refreshSlots();
  });

  Future<String?> publishSlots({
    required String trainerId,
    required List<DateTime> startTimes,
    required int durationMinutes,
  }) => _write(() async {
    await _repository.publishSlots(
      trainerId: trainerId,
      startTimes: startTimes,
      durationMinutes: durationMinutes,
    );
    _refreshSlots();
  });

  Future<String?> deleteSlot(String slotId) => _write(() async {
    await _repository.deleteSlot(slotId);
    _refreshSlots();
  });

  /// Runs a write, keeping any per-field errors for the form to show.
  Future<String?> _write(Future<void> Function() action) async {
    state = const AdminActionState(isSaving: true);
    try {
      await action();
      return null;
    } on ValidationFailure catch (failure) {
      state = AdminActionState(fieldErrors: failure.fieldErrors);
      return failure.message;
    } on Failure catch (failure) {
      return failure.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      state = state.isSaving ? const AdminActionState() : state;
    }
  }
}

final NotifierProvider<AdminActions, AdminActionState> adminActionsProvider =
    NotifierProvider<AdminActions, AdminActionState>(AdminActions.new);
