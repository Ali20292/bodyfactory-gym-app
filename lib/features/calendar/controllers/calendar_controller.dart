import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/app_date.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/repositories/repository_providers.dart';

/// Everything the month grid needs, indexed by day.
///
/// Keyed by [AppDate.keyOf] rather than by `DateTime`: two DateTimes for the
/// same calendar day are not equal if their time components differ, which is
/// the classic way markers end up on the wrong cell.
@immutable
class CalendarMonthData {
  const CalendarMonthData({
    required this.attendance,
    required this.notes,
    required this.events,
  });

  final Map<String, AttendanceRecord> attendance;
  final Map<String, CalendarNote> notes;
  final Map<String, List<GymEvent>> events;

  AttendanceRecord? attendanceOn(DateTime day) =>
      attendance[AppDate.keyOf(day)];

  CalendarNote? noteOn(DateTime day) => notes[AppDate.keyOf(day)];

  List<GymEvent> eventsOn(DateTime day) =>
      events[AppDate.keyOf(day)] ?? const <GymEvent>[];

  bool attendedOn(DateTime day) => attendanceOn(day)?.attended ?? false;
}

/// The window a month's grid actually shows.
///
/// A month view spills into the weeks either side, so fetching exactly the
/// month leaves those cells blank. Seven days of padding covers the worst case
/// on both ends.
({DateTime from, DateTime to}) monthWindow(DateTime month) {
  final DateTime first = DateTime(month.year, month.month);
  return (
    from: first.subtract(const Duration(days: 7)),
    to: DateTime(month.year, month.month + 1, 7),
  );
}

/// Attendance, notes and events for the month containing [month].
///
/// The family key must be the first of the month — `DateTime` equality is
/// exact, so passing an arbitrary day would create a separate cache entry per
/// day and refetch constantly.
final AutoDisposeFutureProviderFamily<CalendarMonthData, DateTime>
calendarMonthDataProvider = FutureProvider.autoDispose
    .family<CalendarMonthData, DateTime>((Ref ref, DateTime month) async {
      final CalendarRepository repository = ref.watch(
        calendarRepositoryProvider,
      );
      final ({DateTime from, DateTime to}) window = monthWindow(month);

      final (
        List<AttendanceRecord> attendance,
        List<CalendarNote> notes,
        List<GymEvent> events,
      ) = await (
        repository.fetchAttendance(from: window.from, to: window.to),
        repository.fetchNotes(from: window.from, to: window.to),
        // Events are gym-wide and few, so the whole list is cheaper than a
        // windowed endpoint would be.
        ref.watch(gymRepositoryProvider).fetchEvents(),
      ).wait;

      final Map<String, List<GymEvent>> eventsByDay =
          <String, List<GymEvent>>{};
      for (final GymEvent event in events) {
        eventsByDay
            .putIfAbsent(AppDate.keyOf(event.startsAt), () => <GymEvent>[])
            .add(event);
      }

      return CalendarMonthData(
        attendance: <String, AttendanceRecord>{
          for (final AttendanceRecord record in attendance)
            AppDate.keyOf(record.date): record,
        },
        notes: <String, CalendarNote>{
          for (final CalendarNote note in notes) AppDate.keyOf(note.date): note,
        },
        events: eventsByDay,
      );
    });

final AutoDisposeFutureProvider<List<SplitTemplate>> splitTemplatesProvider =
    FutureProvider.autoDispose<List<SplitTemplate>>(
      (Ref ref) => ref.watch(calendarRepositoryProvider).fetchTemplates(),
    );

/// The copy buffer for day notes.
///
/// Deliberately not persisted: copying a label is a gesture inside one
/// session, and a "Leg Day" left on the clipboard from last week would be
/// noise rather than help.
class NoteClipboard extends Notifier<String?> {
  @override
  String? build() => null;

  void copy(String label) => state = label.trim();

  void clear() => state = null;
}

final NotifierProvider<NoteClipboard, String?> noteClipboardProvider =
    NotifierProvider<NoteClipboard, String?>(NoteClipboard.new);

/// What the last batch write did, kept so it can be undone.
@immutable
class UndoableApply {
  const UndoableApply({required this.templateName, required this.result});

  final String templateName;
  final ApplyTemplateResult result;
}

@immutable
class CalendarActionState {
  const CalendarActionState({this.isWriting = false, this.lastApply});

  /// True while a write is in flight. A template applied across a year is
  /// ~365 rows in one call, and that call is not instant.
  final bool isWriting;

  /// The most recent template application, while it can still be undone.
  final UndoableApply? lastApply;

  CalendarActionState copyWith({
    bool? isWriting,
    UndoableApply? lastApply,
    bool clearUndo = false,
  }) => CalendarActionState(
    isWriting: isWriting ?? this.isWriting,
    lastApply: clearUndo ? null : (lastApply ?? this.lastApply),
  );
}

/// Every write the calendar can do.
///
/// Not auto-disposed: the undo for a batch apply has to outlive the sheet that
/// started it, and the spec asks for it to stay available for the session.
class CalendarActions extends Notifier<CalendarActionState> {
  @override
  CalendarActionState build() => const CalendarActionState();

  CalendarRepository get _repository => ref.read(calendarRepositoryProvider);

  /// Invalidating the whole family refreshes every month that is cached, not
  /// just the visible one — a template applied across a year changes them all.
  void _refresh() => ref.invalidate(calendarMonthDataProvider);

  Future<String?> saveNote({
    required DateTime date,
    required String label,
  }) async {
    return _write(() async {
      await _repository.upsertNote(date: date, label: label);
    });
  }

  Future<String?> deleteNote(String noteId) =>
      _write(() => _repository.deleteNote(noteId));

  Future<String?> pasteOnto(DateTime date) async {
    final String? label = ref.read(noteClipboardProvider);
    if (label == null || label.isEmpty) return 'Nothing copied yet.';
    return saveNote(date: date, label: label);
  }

  /// How many days in the range already have a note.
  ///
  /// Asked before a batch write so the overwrite prompt only appears when
  /// there is genuinely something to lose. Costs one read; silently destroying
  /// a month of someone's plan would cost more.
  Future<int> countExistingNotes({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final List<CalendarNote> notes = await _repository.fetchNotes(
        from: from,
        to: to,
      );
      return notes.length;
    } on Failure {
      // If the check fails, treat the range as occupied: the prompt is the
      // safe default, and the user still gets to choose.
      return -1;
    }
  }

  Future<SplitTemplate?> saveTemplate(SplitTemplate template) async {
    state = state.copyWith(isWriting: true);
    try {
      final SplitTemplate saved = await _repository.saveTemplate(template);
      ref.invalidate(splitTemplatesProvider);
      return saved;
    } on Failure {
      return null;
    } finally {
      state = state.copyWith(isWriting: false);
    }
  }

  Future<String?> deleteTemplate(String templateId) async {
    final String? error = await _write(
      () => _repository.deleteTemplate(templateId),
    );
    ref.invalidate(splitTemplatesProvider);
    return error;
  }

  /// Applies [template] across the range in one repository call.
  ///
  /// Returns the result so the caller can report what it did and offer the
  /// undo; a [Failure] comes back as a message rather than an exception.
  Future<(ApplyTemplateResult?, String?)> applyTemplate({
    required SplitTemplate template,
    required DateTime from,
    required DateTime to,
    required SplitRepeatMode mode,
    required OverwritePolicy onConflict,
  }) async {
    state = state.copyWith(isWriting: true);

    try {
      final ApplyTemplateResult result = await _repository.applyTemplate(
        template: template,
        from: from,
        to: to,
        mode: mode,
        onConflict: onConflict,
      );

      state = CalendarActionState(
        lastApply: result.hasUndo
            ? UndoableApply(templateName: template.name, result: result)
            : null,
      );
      _refresh();
      return (result, null);
    } on Failure catch (failure) {
      state = state.copyWith(isWriting: false);
      return (null, failure.message);
    } catch (_) {
      state = state.copyWith(isWriting: false);
      return (null, 'Something went wrong. Please try again.');
    }
  }

  /// Puts back exactly what the last apply changed: notes it replaced are
  /// restored, days it created are cleared.
  Future<String?> undoLastApply() async {
    final UndoableApply? undo = state.lastApply;
    if (undo == null) return 'Nothing to undo.';

    final String? error = await _write(
      () => _repository.restoreNotes(
        notes: undo.result.replaced,
        clearedDays: undo.result.createdDays,
      ),
    );

    if (error == null) state = state.copyWith(clearUndo: true);
    return error;
  }

  /// Runs a write, refreshes the grid, and turns a [Failure] into a message.
  /// Returns null on success.
  Future<String?> _write(Future<void> Function() action) async {
    state = state.copyWith(isWriting: true);
    try {
      await action();
      _refresh();
      return null;
    } on Failure catch (failure) {
      return failure.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      state = state.copyWith(isWriting: false);
    }
  }
}

final NotifierProvider<CalendarActions, CalendarActionState>
calendarActionsProvider =
    NotifierProvider<CalendarActions, CalendarActionState>(CalendarActions.new);
