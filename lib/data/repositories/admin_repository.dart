import '../models/models.dart';

/// Everything gym staff can post or change.
///
/// **The client is not the security boundary.** `MemberRole.staff` decides
/// what the app *shows*; it decides nothing about what the backend accepts.
/// Every method here maps to an endpoint that must re-check the caller's role
/// from the token before it writes, because the APK is public and these paths
/// are trivially discoverable in it. A member who calls
/// `POST /admin/events` by hand must get a 403 — not because the app would
/// never send it, but because the server refused.
///
/// Kept separate from [GymRepository] and [ReservationRepository] on purpose:
/// the member-facing interfaces stay read-only, so a screen cannot acquire the
/// ability to write by accident, and the admin surface is one file to audit.
abstract class AdminRepository {
  // --- Events & offers ---------------------------------------------------

  /// Everything, including items that have already finished — staff need to
  /// see and fix the past, where members only see what is coming.
  Future<List<GymEvent>> fetchAllEvents();

  /// Creates an event or offer. The `id` on [draft] is ignored; the backend
  /// assigns one.
  Future<GymEvent> createEvent(GymEvent draft);

  Future<GymEvent> updateEvent(GymEvent event);

  Future<void> deleteEvent(String eventId);

  // --- Classes -----------------------------------------------------------

  Future<List<GymClass>> fetchAllClasses();

  Future<GymClass> createClass(GymClass draft);

  /// Throws `ValidationFailure` if capacity is cut below the number already
  /// booked — that would silently strand members who hold a place.
  Future<GymClass> updateClass(GymClass gymClass);

  /// Removes the class and releases every booking against it.
  ///
  /// Whether members are told, and whether a class with bookings may be
  /// cancelled at all, are product rules that have not been written yet. The
  /// count comes back so the UI can at least warn before it happens.
  Future<int> cancelClass(String classId);

  // --- Trainers ----------------------------------------------------------

  Future<Trainer> createTrainer(Trainer draft);

  Future<Trainer> updateTrainer(Trainer trainer);

  /// Throws `ConflictFailure` when the trainer still has booked sessions.
  Future<void> deleteTrainer(String trainerId);

  /// Publishes bookable times. Slots that already exist are left alone rather
  /// than duplicated, so publishing the same week twice is harmless.
  Future<List<TrainerSlot>> publishSlots({
    required String trainerId,
    required List<DateTime> startTimes,
    required int durationMinutes,
  });

  /// Throws `ConflictFailure` if the slot is booked.
  Future<void> deleteSlot(String slotId);

  // --- Rosters -----------------------------------------------------------

  /// Who is booked into a class.
  ///
  /// This is other members' data. It exists so staff can run the session, and
  /// carries only a name and a membership ID — see [RosterEntry].
  Future<List<RosterEntry>> fetchClassRoster(String classId);

  /// Who holds a trainer's slots, keyed by slot id.
  Future<Map<String, RosterEntry>> fetchTrainerRoster(String trainerId);
}
