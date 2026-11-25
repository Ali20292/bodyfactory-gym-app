import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/theme/app_theme.dart';
import 'package:gym_app/core/utils/app_date.dart';
import 'package:gym_app/data/models/models.dart';
import 'package:gym_app/data/repositories/calendar_repository.dart';
import 'package:gym_app/data/repositories/gym_repository.dart';
import 'package:gym_app/data/repositories/repository_providers.dart';
import 'package:gym_app/features/calendar/screens/calendar_screen.dart';
import 'package:gym_app/features/calendar/screens/split_templates_screen.dart';

/// In-memory calendar with no latency, so tests assert behaviour rather than
/// waiting on a simulated network.
class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({
    Map<String, CalendarNote>? notes,
    Set<String>? attendedDays,
    List<SplitTemplate>? templates,
  }) : notes = notes ?? <String, CalendarNote>{},
       attendedDays = attendedDays ?? <String>{},
       templates = templates ?? <SplitTemplate>[];

  final Map<String, CalendarNote> notes;
  final Set<String> attendedDays;
  final List<SplitTemplate> templates;

  int applyCalls = 0;
  int restoreCalls = 0;
  int _nextId = 0;

  @override
  Future<List<AttendanceRecord>> fetchAttendance({
    required DateTime from,
    required DateTime to,
  }) async => AppDate.daysBetween(from, to)
      .where((DateTime day) => attendedDays.contains(AppDate.keyOf(day)))
      .map(
        (DateTime day) => AttendanceRecord(
          date: day,
          checkInAt: DateTime(day.year, day.month, day.day, 18),
        ),
      )
      .toList();

  @override
  Future<List<CalendarNote>> fetchNotes({
    required DateTime from,
    required DateTime to,
  }) async => AppDate.daysBetween(from, to)
      .map((DateTime day) => notes[AppDate.keyOf(day)])
      .whereType<CalendarNote>()
      .toList();

  @override
  Future<CalendarNote> upsertNote({
    required DateTime date,
    required String label,
    String? colorHex,
  }) async {
    final String key = AppDate.keyOf(date);
    final CalendarNote note = CalendarNote(
      id: notes[key]?.id ?? 'n${_nextId++}',
      date: AppDate.dayOf(date),
      label: label.trim(),
    );
    notes[key] = note;
    return note;
  }

  @override
  Future<void> deleteNote(String noteId) async =>
      notes.removeWhere((String _, CalendarNote note) => note.id == noteId);

  @override
  Future<List<SplitTemplate>> fetchTemplates() async => templates;

  @override
  Future<SplitTemplate> saveTemplate(SplitTemplate template) async {
    final SplitTemplate saved = template.id.isEmpty
        ? template.copyWith(id: 't${_nextId++}')
        : template;
    final int index = templates.indexWhere(
      (SplitTemplate t) => t.id == saved.id,
    );
    if (index >= 0) {
      templates[index] = saved;
    } else {
      templates.add(saved);
    }
    return saved;
  }

  @override
  Future<void> deleteTemplate(String templateId) async =>
      templates.removeWhere((SplitTemplate t) => t.id == templateId);

  @override
  Future<ApplyTemplateResult> applyTemplate({
    required SplitTemplate template,
    required DateTime from,
    required DateTime to,
    required SplitRepeatMode mode,
    required OverwritePolicy onConflict,
  }) async {
    applyCalls++;

    final List<CalendarNote> replaced = <CalendarNote>[];
    final List<DateTime> created = <DateTime>[];
    final List<DateTime> days = AppDate.daysBetween(from, to);
    int written = 0;
    int skipped = 0;

    for (int i = 0; i < days.length; i++) {
      final DateTime day = days[i];
      final String? label = switch (mode) {
        SplitRepeatMode.weekly => template.labelAt(day.weekday - 1),
        SplitRepeatMode.rotating => template.labelAt(i),
      };
      if (label == null) continue;

      final String key = AppDate.keyOf(day);
      final CalendarNote? existing = notes[key];
      if (existing != null) {
        if (onConflict == OverwritePolicy.keepExisting) {
          skipped++;
          continue;
        }
        replaced.add(existing);
      } else {
        created.add(day);
      }

      notes[key] = CalendarNote(
        id: existing?.id ?? 'n${_nextId++}',
        date: day,
        label: label,
      );
      written++;
    }

    return ApplyTemplateResult(
      written: written,
      skipped: skipped,
      replaced: replaced,
      createdDays: created,
    );
  }

  @override
  Future<void> restoreNotes({
    required List<CalendarNote> notes,
    required List<DateTime> clearedDays,
  }) async {
    restoreCalls++;
    for (final DateTime day in clearedDays) {
      this.notes.remove(AppDate.keyOf(day));
    }
    for (final CalendarNote note in notes) {
      this.notes[AppDate.keyOf(note.date)] = note;
    }
  }
}

/// The calendar pulls events for its markers; nothing here tests them, so
/// this keeps that call from reaching the real mock.
class EmptyGymRepository implements GymRepository {
  @override
  Future<GymCapacity> fetchCapacity() async => GymCapacity(
    currentOccupancy: 0,
    maxCapacity: 120,
    updatedAt: DateTime.now(),
  );

  @override
  Future<List<GymEvent>> fetchEvents() async => const <GymEvent>[];

  @override
  void debugForceLevel(OccupancyLevel? level) {}
}

CalendarNote noteOn(DateTime day, String label) => CalendarNote(
  id: 'seed-${AppDate.keyOf(day)}',
  date: AppDate.dayOf(day),
  label: label,
);

Future<void> pumpCalendar(
  WidgetTester tester,
  FakeCalendarRepository repository, {
  Widget screen = const CalendarScreen(),
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        calendarRepositoryProvider.overrideWithValue(repository),
        gymRepositoryProvider.overrideWithValue(EmptyGymRepository()),
      ],
      child: MaterialApp(theme: AppTheme.brand, home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

/// A day in the current month that is safely inside the grid, so tapping it
/// never lands on a neighbouring month's cell.
DateTime dayInThisMonth(int day) {
  final DateTime today = AppDate.today();
  return DateTime(today.year, today.month, day);
}

void main() {
  group('Month grid', () {
    testWidgets('shows the note label on the day it belongs to', (
      WidgetTester tester,
    ) async {
      await pumpCalendar(
        tester,
        FakeCalendarRepository(
          notes: <String, CalendarNote>{
            AppDate.keyOf(dayInThisMonth(12)): noteOn(
              dayInThisMonth(12),
              'Legs',
            ),
          },
        ),
      );

      expect(find.text('Legs'), findsOneWidget);
    });

    testWidgets('opens the day sheet on tap, with attendance and the note', (
      WidgetTester tester,
    ) async {
      final DateTime day = dayInThisMonth(12);
      await pumpCalendar(
        tester,
        FakeCalendarRepository(
          notes: <String, CalendarNote>{
            AppDate.keyOf(day): noteOn(day, 'Legs'),
          },
          attendedDays: <String>{AppDate.keyOf(day)},
        ),
      );

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();

      // Matched on the check-in time, not just "You trained" — the legend
      // behind the sheet carries that phrase too.
      expect(find.textContaining('checked in at'), findsOneWidget);
      // "Your note" appears in the legend as well, so the sheet is identified
      // by an action only it has.
      expect(find.text('Copy'), findsOneWidget);
      // The label shows in the grid behind the sheet as well as in it.
      expect(find.text('Legs'), findsWidgets);
    });
  });

  group('Notes', () {
    testWidgets('adding one writes it and shows it on the grid', (
      WidgetTester tester,
    ) async {
      final FakeCalendarRepository repository = FakeCalendarRepository();
      await pumpCalendar(tester, repository);

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add note'));
      await tester.pumpAndSettle();

      // The suggestion chips are there so the common labels need no typing.
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save note'));
      await tester.pumpAndSettle();

      expect(
        repository.notes[AppDate.keyOf(dayInThisMonth(12))]?.label,
        'Push',
      );
      expect(find.text('Push'), findsOneWidget);
    });

    testWidgets('deleting one removes it', (WidgetTester tester) async {
      final DateTime day = dayInThisMonth(12);
      final FakeCalendarRepository repository = FakeCalendarRepository(
        notes: <String, CalendarNote>{AppDate.keyOf(day): noteOn(day, 'Legs')},
      );
      await pumpCalendar(tester, repository);

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(repository.notes, isEmpty);
      expect(find.text('Legs'), findsNothing);
    });

    testWidgets('copy then paste puts the same label on another day', (
      WidgetTester tester,
    ) async {
      final DateTime source = dayInThisMonth(12);
      final FakeCalendarRepository repository = FakeCalendarRepository(
        notes: <String, CalendarNote>{
          AppDate.keyOf(source): noteOn(source, 'Legs'),
        },
      );
      await pumpCalendar(tester, repository);

      await tester.tap(find.text('12'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      // The banner is the only cue that something is on the clipboard.
      expect(find.textContaining('copied'), findsWidgets);

      await tester.tap(find.text('14'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Paste'));
      await tester.pumpAndSettle();

      expect(
        repository.notes[AppDate.keyOf(dayInThisMonth(14))]?.label,
        'Legs',
      );
    });
  });

  group('Splits', () {
    SplitTemplate ppl() => const SplitTemplate(
      id: 't1',
      name: 'PPL',
      days: <String>['Push', 'Pull', 'Legs'],
    );

    testWidgets('creating a split saves the cycle in order', (
      WidgetTester tester,
    ) async {
      final FakeCalendarRepository repository = FakeCalendarRepository();
      await pumpCalendar(
        tester,
        repository,
        screen: const SplitTemplatesScreen(),
      );

      await tester.tap(find.text('New split'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'PPL');
      await tester.enterText(find.byType(TextField).last, 'Push');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Pull');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Save 2-day split'));
      await tester.pumpAndSettle();

      expect(repository.templates.single.name, 'PPL');
      expect(repository.templates.single.days, <String>['Push', 'Pull']);
    });

    testWidgets('applying over empty days writes without prompting', (
      WidgetTester tester,
    ) async {
      final FakeCalendarRepository repository = FakeCalendarRepository(
        templates: <SplitTemplate>[ppl()],
      );
      await pumpCalendar(
        tester,
        repository,
        screen: const SplitTemplatesScreen(),
      );

      await tester.tap(find.text('Repeat over a range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4 weeks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply to calendar'));
      await tester.pumpAndSettle();

      // No conflicts, so no dialog: 28 days written straight through.
      expect(repository.applyCalls, 1);
      expect(repository.notes.length, 28);
      expect(find.textContaining('written to 28 days'), findsOneWidget);
    });

    testWidgets('an occupied range prompts, and Cancel writes nothing', (
      WidgetTester tester,
    ) async {
      final DateTime today = AppDate.today();
      final FakeCalendarRepository repository = FakeCalendarRepository(
        notes: <String, CalendarNote>{
          AppDate.keyOf(today): noteOn(today, 'Keep me'),
        },
        templates: <SplitTemplate>[ppl()],
      );
      await pumpCalendar(
        tester,
        repository,
        screen: const SplitTemplatesScreen(),
      );

      await tester.tap(find.text('Repeat over a range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply to calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Some days already have notes'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.applyCalls, 0);
      expect(repository.notes[AppDate.keyOf(today)]?.label, 'Keep me');
    });

    testWidgets('Keep existing leaves the day alone', (
      WidgetTester tester,
    ) async {
      final DateTime today = AppDate.today();
      final FakeCalendarRepository repository = FakeCalendarRepository(
        notes: <String, CalendarNote>{
          AppDate.keyOf(today): noteOn(today, 'Keep me'),
        },
        templates: <SplitTemplate>[ppl()],
      );
      await pumpCalendar(
        tester,
        repository,
        screen: const SplitTemplatesScreen(),
      );

      await tester.tap(find.text('Repeat over a range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply to calendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep existing'));
      await tester.pumpAndSettle();

      expect(repository.notes[AppDate.keyOf(today)]?.label, 'Keep me');
      expect(find.textContaining('1 left alone'), findsOneWidget);
    });

    testWidgets('Overwrite replaces, and Undo puts it back', (
      WidgetTester tester,
    ) async {
      final DateTime today = AppDate.today();
      final FakeCalendarRepository repository = FakeCalendarRepository(
        notes: <String, CalendarNote>{
          AppDate.keyOf(today): noteOn(today, 'Keep me'),
        },
        templates: <SplitTemplate>[ppl()],
      );
      await pumpCalendar(
        tester,
        repository,
        screen: const SplitTemplatesScreen(),
      );

      await tester.tap(find.text('Repeat over a range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply to calendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Overwrite'));
      await tester.pumpAndSettle();

      expect(repository.notes[AppDate.keyOf(today)]?.label, 'Push');

      // The undo outlives the snackbar: it is on the screen as a card.
      await tester.tap(find.widgetWithText(TextButton, 'Undo').last);
      await tester.pumpAndSettle();

      expect(repository.restoreCalls, 1);
      expect(repository.notes[AppDate.keyOf(today)]?.label, 'Keep me');
      // The days the apply created are cleared, not left behind.
      expect(repository.notes.length, 1);
    });

    testWidgets('the snackbar Undo still works after leaving the screen', (
      WidgetTester tester,
    ) async {
      final DateTime today = AppDate.today();
      final FakeCalendarRepository repository = FakeCalendarRepository(
        notes: <String, CalendarNote>{
          AppDate.keyOf(today): noteOn(today, 'Keep me'),
        },
        templates: <SplitTemplate>[ppl()],
      );

      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);

      // Pushed onto a navigator, as it is in the app, so it can be popped
      // while its snackbar stays on screen.
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            calendarRepositoryProvider.overrideWithValue(repository),
            gymRepositoryProvider.overrideWithValue(EmptyGymRepository()),
          ],
          child: MaterialApp(
            theme: AppTheme.brand,
            home: Builder(
              builder: (BuildContext context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SplitTemplatesScreen(),
                      ),
                    ),
                    child: const Text('Open splits'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open splits'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Repeat over a range'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply to calendar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Overwrite'));
      await tester.pumpAndSettle();

      expect(repository.notes[AppDate.keyOf(today)]?.label, 'Push');

      // Leave the screen. The snackbar follows, because ScaffoldMessenger
      // lives above the route.
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Open splits'), findsOneWidget);

      await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
      await tester.pumpAndSettle();

      // Would have thrown on a disposed WidgetRef before the notifier was
      // captured up front.
      expect(repository.restoreCalls, 1);
      expect(repository.notes[AppDate.keyOf(today)]?.label, 'Keep me');
    });

    testWidgets('deleting a split asks first', (WidgetTester tester) async {
      final FakeCalendarRepository repository = FakeCalendarRepository(
        templates: <SplitTemplate>[ppl()],
      );
      await pumpCalendar(
        tester,
        repository,
        screen: const SplitTemplatesScreen(),
      );

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete PPL?'), findsOneWidget);
      await tester.tap(find.text('Keep'));
      await tester.pumpAndSettle();

      expect(repository.templates, hasLength(1));
    });
  });

  testWidgets('lays out on a small phone without overflowing', (
    WidgetTester tester,
  ) async {
    await pumpCalendar(
      tester,
      FakeCalendarRepository(
        notes: <String, CalendarNote>{
          AppDate.keyOf(dayInThisMonth(12)): noteOn(
            dayInThisMonth(12),
            'Legs day',
          ),
        },
      ),
      size: const Size(320, 640),
    );

    expect(find.text('Calendar'), findsOneWidget);
  });
}
