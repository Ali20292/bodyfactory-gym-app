import '../models/models.dart';

/// What to do where a template would land on a day that already has a note.
///
/// There is no `cancel` here — cancelling happens in the dialog and never
/// reaches the repository.
enum OverwritePolicy { overwrite, keepExisting }

/// The outcome of applying a [SplitTemplate] over a range.
///
/// Between them, [replaced] and [createdDays] describe everything the call
/// changed, which is what makes it undoable for the session: hand both
/// straight back to [CalendarRepository.restoreNotes].
class ApplyTemplateResult {
  const ApplyTemplateResult({
    required this.written,
    required this.skipped,
    required this.replaced,
    required this.createdDays,
  });

  /// Days that got a label.
  final int written;

  /// Days left alone because they already had a note and the policy was
  /// [OverwritePolicy.keepExisting].
  final int skipped;

  /// The pre-write state of notes this call overwrote.
  final List<CalendarNote> replaced;

  /// Days that had no note before. Undoing clears these rather than
  /// restoring anything.
  final List<DateTime> createdDays;

  bool get hasUndo => replaced.isNotEmpty || createdDays.isNotEmpty;
}

/// Attendance, day notes, and split templates.
abstract class CalendarRepository {
  /// The member's own attendance between two days, inclusive.
  Future<List<AttendanceRecord>> fetchAttendance({
    required DateTime from,
    required DateTime to,
  });

  Future<List<CalendarNote>> fetchNotes({
    required DateTime from,
    required DateTime to,
  });

  /// Creates or replaces the note on [date]. One note per day.
  Future<CalendarNote> upsertNote({
    required DateTime date,
    required String label,
    String? colorHex,
  });

  Future<void> deleteNote(String noteId);

  Future<List<SplitTemplate>> fetchTemplates();

  /// Creates or updates a template, returning the stored version.
  Future<SplitTemplate> saveTemplate(SplitTemplate template);

  Future<void> deleteTemplate(String templateId);

  /// Writes the template across [from]..[to] in **one call**.
  ///
  /// Applying across a year is up to ~365 rows; batching it here is what keeps
  /// that from becoming 365 round trips. Days that already have a note are
  /// governed by [onConflict] — nothing is destroyed silently, and whatever is
  /// replaced comes back in the result so the caller can offer an undo.
  Future<ApplyTemplateResult> applyTemplate({
    required SplitTemplate template,
    required DateTime from,
    required DateTime to,
    required SplitRepeatMode mode,
    required OverwritePolicy onConflict,
  });

  /// Puts back a set of notes captured before a batch write. Days that had no
  /// note before are cleared rather than restored.
  Future<void> restoreNotes({
    required List<CalendarNote> notes,
    required List<DateTime> clearedDays,
  });
}
