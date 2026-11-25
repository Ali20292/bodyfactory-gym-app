import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/reservation_repository.dart';

/// Everyone who takes one-to-one sessions.
final AutoDisposeFutureProvider<List<Trainer>> trainersProvider =
    FutureProvider.autoDispose<List<Trainer>>(
      (Ref ref) => ref.watch(reservationRepositoryProvider).fetchTrainers(),
    );

final AutoDisposeFutureProviderFamily<Trainer, String> trainerProvider =
    FutureProvider.autoDispose.family<Trainer, String>(
      (Ref ref, String trainerId) =>
          ref.watch(reservationRepositoryProvider).fetchTrainer(trainerId),
    );

/// One trainer's schedule, including slots that are taken or in the past —
/// the screen shows those greyed rather than hiding them, so a busy week reads
/// as busy rather than as an empty one.
final AutoDisposeFutureProviderFamily<List<TrainerSlot>, String>
trainerSlotsProvider = FutureProvider.autoDispose
    .family<List<TrainerSlot>, String>(
      (Ref ref, String trainerId) =>
          ref.watch(reservationRepositoryProvider).fetchTrainerSlots(trainerId),
    );

final AutoDisposeFutureProvider<List<GymClass>> classesProvider =
    FutureProvider.autoDispose<List<GymClass>>(
      (Ref ref) => ref.watch(reservationRepositoryProvider).fetchClasses(),
    );

final AutoDisposeFutureProvider<List<Reservation>> myReservationsProvider =
    FutureProvider.autoDispose<List<Reservation>>(
      (Ref ref) =>
          ref.watch(reservationRepositoryProvider).fetchMyReservations(),
    );

/// The ids the member already holds a confirmed booking for.
///
/// Lets a class the member is already in show as joined instead of offering
/// to book it twice. This is presentation only — whether a second booking is
/// actually allowed is a backend rule, and one that has not been written yet.
final AutoDisposeProvider<Set<String>> bookedReferenceIdsProvider =
    Provider.autoDispose<Set<String>>((Ref ref) {
      final List<Reservation> reservations =
          ref.watch(myReservationsProvider).valueOrNull ??
          const <Reservation>[];

      return reservations
          .where((Reservation reservation) => reservation.isConfirmed)
          .map((Reservation reservation) => reservation.referenceId)
          .toSet();
    });

/// A reservation with enough attached to it to render a card.
@immutable
class ReservationView {
  const ReservationView({
    required this.reservation,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final Reservation reservation;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// The member's upcoming bookings, each resolved to a name.
///
/// A [Reservation] carries only a `referenceId`, so the name has to be looked
/// up in the catalogues. Classes resolve exactly, by id. Trainer sessions do
/// not: the reference is a *slot* id, and slots are only fetched per trainer,
/// so this matches the id prefix instead.
///
/// That prefix match is a stopgap, and it is worth naming as one: it works
/// because the mock builds slot ids as `<trainerId>-d<day>-h<hour>`, which is
/// a coincidence of the fixture rather than a contract. The real fix is on the
/// backend — `GET /reservations` should return a display label (or the
/// embedded trainer and class summary) so the client is not reverse-engineering
/// ids. Until it does, an unmatched booking degrades to "Personal training"
/// with the right date, rather than showing a raw id or vanishing.
final AutoDisposeProvider<AsyncValue<List<ReservationView>>>
myReservationViewsProvider =
    Provider.autoDispose<AsyncValue<List<ReservationView>>>((Ref ref) {
      final AsyncValue<List<Reservation>> reservations = ref.watch(
        myReservationsProvider,
      );
      final List<Trainer> trainers =
          ref.watch(trainersProvider).valueOrNull ?? const <Trainer>[];
      final List<GymClass> classes =
          ref.watch(classesProvider).valueOrNull ?? const <GymClass>[];

      return reservations.whenData((List<Reservation> list) {
        final DateTime now = DateTime.now();

        return list
            .where((Reservation reservation) => reservation.isUpcomingAt(now))
            .map(
              (Reservation reservation) =>
                  _viewOf(reservation, trainers: trainers, classes: classes),
            )
            .toList();
      });
    });

ReservationView _viewOf(
  Reservation reservation, {
  required List<Trainer> trainers,
  required List<GymClass> classes,
}) {
  switch (reservation.kind) {
    case ReservationKind.trainer:
      final Trainer? trainer = trainers
          .where(
            (Trainer trainer) =>
                reservation.referenceId.startsWith('${trainer.id}-'),
          )
          .firstOrNull;

      return ReservationView(
        reservation: reservation,
        title: trainer?.name ?? 'Personal training',
        subtitle: trainer == null
            ? 'One-to-one session'
            : 'One-to-one · ${trainer.specialties.take(2).join(', ')}',
        icon: Icons.fitness_center_rounded,
      );

    case ReservationKind.gymClass:
      final GymClass? gymClass = classes
          .where((GymClass gymClass) => gymClass.id == reservation.referenceId)
          .firstOrNull;

      return ReservationView(
        reservation: reservation,
        title: gymClass?.name ?? 'Class',
        subtitle: gymClass == null
            ? 'Group class'
            : 'with ${gymClass.instructorName} · ${gymClass.room}',
        icon: Icons.groups_rounded,
      );
  }
}

/// Which booking is in flight, if any.
@immutable
class BookingState {
  const BookingState({this.pendingId});

  /// The slot, class, or reservation id currently being written. Held as an id
  /// rather than a bool so only the row that was tapped shows a spinner.
  final String? pendingId;

  bool get isBusy => pendingId != null;

  bool isPending(String id) => pendingId == id;
}

/// Writes: booking a trainer slot, joining a class, cancelling either.
///
/// Every success invalidates the lists the write touched, so a taken slot or a
/// filled class is reflected the moment the user comes back to it rather than
/// on the next cold load.
class BookingController extends AutoDisposeNotifier<BookingState> {
  /// Set in `onDispose`. A write still in flight when the screen is popped
  /// would otherwise come back and assign to a dead notifier.
  bool _disposed = false;

  @override
  BookingState build() {
    ref.onDispose(() => _disposed = true);
    return const BookingState();
  }

  ReservationRepository get _repository =>
      ref.read(reservationRepositoryProvider);

  Future<BookingOutcome> bookTrainerSlot(TrainerSlot slot) => _run(
    id: slot.id,
    action: () => _repository.bookTrainerSlot(slot.id),
    onSuccess: () {
      // Invalidating the family itself clears every trainer's schedule. The
      // alternative is to guess which keys are live, which is how a stale
      // "available" slot survives on a screen further back in the stack.
      ref.invalidate(trainerSlotsProvider);
      ref.invalidate(myReservationsProvider);
    },
  );

  Future<BookingOutcome> joinClass(GymClass gymClass) => _run(
    id: gymClass.id,
    action: () => _repository.bookClass(gymClass.id),
    onSuccess: () {
      ref.invalidate(classesProvider);
      ref.invalidate(myReservationsProvider);
    },
  );

  Future<BookingOutcome> cancel(Reservation reservation) => _run(
    id: reservation.id,
    action: () async {
      await _repository.cancelReservation(reservation.id);
      return null;
    },
    onSuccess: () {
      // A cancellation hands the place back, so both catalogues are stale.
      ref.invalidate(trainerSlotsProvider);
      ref.invalidate(classesProvider);
      ref.invalidate(myReservationsProvider);
    },
  );

  Future<BookingOutcome> _run({
    required String id,
    required Future<Reservation?> Function() action,
    required VoidCallback onSuccess,
  }) async {
    if (state.isBusy) {
      return const BookingOutcome.failure('One at a time — still working.');
    }

    state = BookingState(pendingId: id);

    try {
      final Reservation? reservation = await action();
      // If the screen was popped mid-write there is nothing to refresh: those
      // providers auto-disposed with it and will re-fetch when next mounted.
      if (!_disposed) onSuccess();
      return BookingOutcome.success(reservation);
    } on Failure catch (failure) {
      // ConflictFailure lands here: the slot went, or the class filled up,
      // between the list loading and the tap. The message is the backend's.
      return BookingOutcome.failure(failure.message);
    } catch (_) {
      return const BookingOutcome.failure(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (!_disposed) state = const BookingState();
    }
  }
}

/// What a write returned, in the one shape the UI needs to react to.
@immutable
class BookingOutcome {
  const BookingOutcome.success(this.reservation) : error = null;
  const BookingOutcome.failure(this.error) : reservation = null;

  final Reservation? reservation;
  final String? error;

  bool get isSuccess => error == null;
}

final AutoDisposeNotifierProvider<BookingController, BookingState>
bookingControllerProvider =
    NotifierProvider.autoDispose<BookingController, BookingState>(
      BookingController.new,
    );
