import 'dart:async';

import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/app_date.dart';
import '../mock/mock_data.dart';
import '../models/models.dart';
import 'calendar_repository.dart';

/// In-memory calendar. Notes are keyed by day, which is what makes "one note
/// per day" true by construction rather than by convention.
class MockCalendarRepository implements CalendarRepository {
  MockCalendarRepository() {
    for (final CalendarNote note in MockData.notes()) {
      _notes[AppDate.keyOf(note.date)] = note;
    }
    for (final AttendanceRecord record in MockData.attendance()) {
      _attendance[AppDate.keyOf(record.date)] = record;
    }
    _templates.addAll(MockData.splitTemplates());
  }

  final Map<String, CalendarNote> _notes = <String, CalendarNote>{};
  final Map<String, AttendanceRecord> _attendance =
      <String, AttendanceRecord>{};
  final List<SplitTemplate> _templates = <SplitTemplate>[];

  int _nextNoteId = 0;
  int _nextTemplateId = 0;

  @override
  Future<List<AttendanceRecord>> fetchAttendance({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    return AppDate.daysBetween(from, to)
        .map((DateTime day) => _attendance[AppDate.keyOf(day)])
        .whereType<AttendanceRecord>()
        .toList();
  }

  @override
  Future<List<CalendarNote>> fetchNotes({
    required DateTime from,
    required DateTime to,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    return AppDate.daysBetween(from, to)
        .map((DateTime day) => _notes[AppDate.keyOf(day)])
        .whereType<CalendarNote>()
        .toList();
  }

  @override
  Future<CalendarNote> upsertNote({
    required DateTime date,
    required String label,
    String? colorHex,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    final String trimmed = label.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('A note needs some text.');
    }

    final DateTime day = AppDate.dayOf(date);
    final String key = AppDate.keyOf(day);
    final CalendarNote note = CalendarNote(
      id: _notes[key]?.id ?? 'note-new-${_nextNoteId++}',
      date: day,
      label: trimmed,
      colorHex: colorHex,
    );

    _notes[key] = note;
    return note;
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _notes.removeWhere((String _, CalendarNote note) => note.id == noteId);
  }

  @override
  Future<List<SplitTemplate>> fetchTemplates() async {
    await Future<void>.delayed(AppConfig.mockLatency);
    return List<SplitTemplate>.unmodifiable(_templates);
  }

  @override
  Future<SplitTemplate> saveTemplate(SplitTemplate template) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    if (!template.isValid) {
      throw const ValidationFailure(
        'A split needs a name and at least one day.',
      );
    }

    final int index = _templates.indexWhere(
      (SplitTemplate t) => t.id == template.id,
    );
    if (index >= 0) {
      _templates[index] = template;
      return template;
    }

    final SplitTemplate created = template.id.isEmpty
        ? template.copyWith(id: 'tpl-new-${_nextTemplateId++}')
        : template;
    _templates.add(created);
    return created;
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    await Future<void>.delayed(AppConfig.mockLatency);
    _templates.removeWhere((SplitTemplate t) => t.id == templateId);
  }

  @override
  Future<ApplyTemplateResult> applyTemplate({
    required SplitTemplate template,
    required DateTime from,
    required DateTime to,
    required SplitRepeatMode mode,
    required OverwritePolicy onConflict,
  }) async {
    if (!template.isValid) {
      throw const ValidationFailure(
        'A split needs a name and at least one day.',
      );
    }

    final List<DateTime> days = AppDate.daysBetween(from, to);
    if (days.isEmpty) {
      throw const ValidationFailure('Pick a range that ends after it starts.');
    }

    // One call for the whole range, however long it is — up to ~365 rows.
    // The delay scales a little with size so the progress indicator has
    // something to show.
    await Future<void>.delayed(
      AppConfig.mockLatency + Duration(milliseconds: days.length),
    );

    final List<CalendarNote> replaced = <CalendarNote>[];
    final List<DateTime> createdDays = <DateTime>[];
    int written = 0;
    int skipped = 0;

    for (int i = 0; i < days.length; i++) {
      final DateTime day = days[i];
      final String? label = switch (mode) {
        // Weekly: the same weekday always gets the same label. Index 0 of the
        // template is Monday.
        SplitRepeatMode.weekly => template.labelAt(day.weekday - 1),
        // Rotating: an N-day cycle that rolls forward regardless of weekday,
        // counted from the first day of the range.
        SplitRepeatMode.rotating => template.labelAt(i),
      };
      if (label == null) continue;

      final String key = AppDate.keyOf(day);
      final CalendarNote? existing = _notes[key];

      if (existing != null) {
        if (onConflict == OverwritePolicy.keepExisting) {
          skipped++;
          continue;
        }
        replaced.add(existing);
      } else {
        createdDays.add(day);
      }

      _notes[key] = CalendarNote(
        id: existing?.id ?? 'note-tpl-${_nextNoteId++}',
        date: day,
        label: label,
      );
      written++;
    }

    return ApplyTemplateResult(
      written: written,
      skipped: skipped,
      replaced: replaced,
      createdDays: createdDays,
    );
  }

  @override
  Future<void> restoreNotes({
    required List<CalendarNote> notes,
    required List<DateTime> clearedDays,
  }) async {
    await Future<void>.delayed(AppConfig.mockLatency);

    for (final DateTime day in clearedDays) {
      _notes.remove(AppDate.keyOf(day));
    }
    for (final CalendarNote note in notes) {
      _notes[AppDate.keyOf(note.date)] = note;
    }
  }
}
