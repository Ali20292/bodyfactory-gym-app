import '../models/models.dart';

/// Trainers, classes, and the member's own bookings.
///
/// Booking rules — cancellation windows, per-member limits, waitlists,
/// double-booking prevention — are not specified yet. This interface assumes
/// none of them: the write methods take an id and return the resulting
/// [Reservation], so a rule can be added behind any of them without changing a
/// signature or restructuring the UI.
abstract class ReservationRepository {
  Future<List<Trainer>> fetchTrainers();

  /// Throws `NotFoundFailure` if the trainer is gone.
  Future<Trainer> fetchTrainer(String trainerId);

  /// All slots for one trainer, ascending by start time. Includes booked and
  /// past slots — the UI decides how to present them.
  Future<List<TrainerSlot>> fetchTrainerSlots(String trainerId);

  /// Upcoming classes, ascending by start time.
  Future<List<GymClass>> fetchClasses();

  /// The signed-in member's reservations, newest start first.
  Future<List<Reservation>> fetchMyReservations();

  /// Throws `ConflictFailure` if the slot was taken between load and tap.
  Future<Reservation> bookTrainerSlot(String slotId);

  /// Throws `ConflictFailure` if the class filled up between load and tap.
  Future<Reservation> bookClass(String classId);

  /// Throws `NotFoundFailure` if the reservation is unknown, `ConflictFailure`
  /// if the backend refuses — which is where a cancellation window will land.
  Future<void> cancelReservation(String reservationId);
}
