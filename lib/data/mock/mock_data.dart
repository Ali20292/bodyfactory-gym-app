import '../../core/utils/app_date.dart';
import '../models/models.dart';

/// Every piece of fake seed data, in one file.
///
/// Dates are built relative to `DateTime.now()` so the app always looks alive
/// no matter when it is run — a fixed date would make every list read as long
/// past within a week.
///
/// None of this is a secret and none of it is a product rule. It exists so
/// every screen is buildable and navigable before a backend does.
class MockData {
  const MockData._();

  // --- Credentials -------------------------------------------------------

  /// The account you log in with while `USE_MOCK_DATA=true`.
  static const String demoMembershipId = 'GM-1001';
  static const String demoPassword = 'password123';

  /// A staff account, for the Manage tab.
  ///
  /// Staff log in through the same screen with the same kind of credentials —
  /// what differs is the role the backend puts on the session. Nothing in the
  /// app decides this, and nothing in the app can: the client only reads what
  /// it was handed.
  static const String demoStaffMembershipId = 'GM-9001';
  static const String demoStaffPassword = 'staff123';

  /// The code `MockAuthRepository` accepts. A real backend never tells the app
  /// what the code is — this constant exists only because there is no SMS.
  static const String demoOtpCode = '123456';

  /// Membership IDs the gym's records know about, so sign-up can succeed for
  /// one and fail for the rest.
  static const Set<String> knownMembershipIds = <String>{
    'GM-1001',
    'GM-1002',
    'GM-1003',
    'GM-2044',
  };

  /// Known IDs that already have an account. Sign-up must reject these with
  /// exactly the same message as an unknown ID — the difference is precisely
  /// what must not leak.
  static const Set<String> alreadyRegisteredIds = <String>{
    'GM-1001',
    'GM-1002',
  };

  /// The one ID that can complete sign-up in the mock: known, not yet
  /// registered.
  static const String signUpReadyMembershipId = 'GM-2044';

  static const String demoMaskedPhone = '+20 1** *** 4471';

  // --- Member ------------------------------------------------------------

  static Member member() => Member(
    id: demoMembershipId,
    username: 'yasser',
    phoneMasked: demoMaskedPhone,
    membershipTier: 'Standard',
    membershipExpiry: DateTime.now().add(const Duration(days: 213)),
    invitationsRemaining: 3,
  );

  /// The staff member behind [demoStaffMembershipId].
  static Member staffMember() => Member(
    id: demoStaffMembershipId,
    username: 'Front desk',
    phoneMasked: demoMaskedPhone,
    membershipTier: 'Staff',
    membershipExpiry: DateTime.now().add(const Duration(days: 3650)),
    invitationsRemaining: 0,
    role: MemberRole.staff,
  );

  static List<InvitationUsage> invitationHistory() {
    final DateTime now = DateTime.now();
    return <InvitationUsage>[
      InvitationUsage(
        id: 'inv-3',
        usedAt: now.subtract(const Duration(days: 12)),
        guestName: 'Omar',
      ),
      InvitationUsage(
        id: 'inv-2',
        usedAt: now.subtract(const Duration(days: 40)),
        guestName: 'Salma',
      ),
      InvitationUsage(
        id: 'inv-1',
        usedAt: now.subtract(const Duration(days: 76)),
      ),
    ];
  }

  // --- Events & offers ---------------------------------------------------

  static List<GymEvent> events() {
    final DateTime today = AppDate.today();
    return <GymEvent>[
      GymEvent(
        id: 'ev-1',
        title: 'Deadlift technique workshop',
        description:
            'Two hours with Coach Karim on setup, bracing, and lockout. '
            'Fifteen places, first come first served.',
        startsAt: today.add(const Duration(days: 2, hours: 19)),
        endsAt: today.add(const Duration(days: 2, hours: 21)),
        type: GymEventType.event,
        imageUrl: 'https://picsum.photos/seed/deadlift/800/450',
      ),
      GymEvent(
        id: 'of-1',
        title: '20% off personal training packs',
        description:
            'Ten-session packs with any trainer, this month only. Ask at the '
            'front desk to redeem.',
        startsAt: today.add(const Duration(days: 3)),
        endsAt: today.add(const Duration(days: 24)),
        type: GymEventType.offer,
        imageUrl: 'https://picsum.photos/seed/ptoffer/800/450',
      ),
      GymEvent(
        id: 'ev-2',
        title: 'Saturday morning 5K',
        description:
            'Group run from the front door along the corniche. All paces '
            'welcome — nobody gets left behind.',
        startsAt: today.add(const Duration(days: 5, hours: 7)),
        endsAt: today.add(const Duration(days: 5, hours: 9)),
        type: GymEventType.event,
        imageUrl: 'https://picsum.photos/seed/run5k/800/450',
      ),
      GymEvent(
        id: 'of-2',
        title: 'Bring a friend free — all week',
        description:
            'Guest passes do not count against your invitations from Sunday '
            'to Thursday.',
        startsAt: today.add(const Duration(days: 9)),
        endsAt: today.add(const Duration(days: 14)),
        type: GymEventType.offer,
        imageUrl: 'https://picsum.photos/seed/bringfriend/800/450',
      ),
      GymEvent(
        id: 'ev-3',
        title: 'Inbody scan day',
        description:
            'Free body composition scan with a printed breakdown. Come '
            'fasted for the cleanest reading.',
        startsAt: today.add(const Duration(days: 16, hours: 10)),
        type: GymEventType.event,
      ),
    ];
  }

  // --- Trainers ----------------------------------------------------------

  static List<Trainer> trainers() => <Trainer>[
    const Trainer(
      id: 'tr-1',
      name: 'Karim Adel',
      specialties: <String>['Powerlifting', 'Strength'],
      bio:
          'Twelve years coaching barbell lifts. Competed nationally at 93kg. '
          'Patient with beginners, blunt about form.',
      photoUrl: 'https://i.pravatar.cc/300?img=12',
      rating: 4.8,
    ),
    const Trainer(
      id: 'tr-2',
      name: 'Nada Hassan',
      specialties: <String>['HIIT', 'Conditioning', 'Mobility'],
      bio:
          'Ex-handball player turned conditioning coach. Builds programmes '
          'around what you can actually keep doing.',
      photoUrl: 'https://i.pravatar.cc/300?img=45',
      rating: 4.9,
    ),
    const Trainer(
      id: 'tr-3',
      name: 'Sherif Mostafa',
      specialties: <String>['Hypertrophy', 'Nutrition'],
      bio:
          'Physique coach. Works in twelve-week blocks with weekly check-ins '
          'and no fad diets.',
      photoUrl: 'https://i.pravatar.cc/300?img=33',
      rating: 4.6,
    ),
    const Trainer(
      id: 'tr-4',
      name: 'Mariam Fouad',
      specialties: <String>['Rehab', 'Posture', 'Beginners'],
      bio:
          'Physiotherapy background. Good first stop if something hurts or '
          'you have never touched a barbell.',
      photoUrl: 'https://i.pravatar.cc/300?img=25',
    ),
  ];

  /// Slots for the next seven days: hourly 09:00–12:00 and 17:00–21:00, with a
  /// scattering already booked so the UI has both states to render.
  static List<TrainerSlot> trainerSlots() {
    final DateTime today = AppDate.today();
    final List<TrainerSlot> slots = <TrainerSlot>[];
    const List<int> hours = <int>[9, 10, 11, 17, 18, 19, 20];

    for (final Trainer trainer in trainers()) {
      final int trainerIndex = trainers().indexOf(trainer);
      for (int day = 0; day < 7; day++) {
        for (int i = 0; i < hours.length; i++) {
          // Trainers do not all work the same hours.
          if ((day + i + trainerIndex) % 3 == 0) continue;

          final DateTime startsAt = today.add(
            Duration(days: day, hours: hours[i]),
          );
          slots.add(
            TrainerSlot(
              id: '${trainer.id}-d$day-h${hours[i]}',
              trainerId: trainer.id,
              startsAt: startsAt,
              durationMinutes: 60,
              isBooked: (day * 7 + i + trainerIndex) % 5 == 0,
            ),
          );
        }
      }
    }
    return slots;
  }

  // --- Classes -----------------------------------------------------------

  static List<GymClass> classes() {
    final DateTime today = AppDate.today();
    final List<GymClass> result = <GymClass>[];

    const List<(String, String, String, int, int, String)> template =
        <(String, String, String, int, int, String)>[
          ('Spin', 'Nada Hassan', 'Studio 2', 45, 20, 'Intervals on the bike.'),
          (
            'Body Pump',
            'Sherif Mostafa',
            'Studio 1',
            55,
            24,
            'Barbell circuits, high reps, light load.',
          ),
          (
            'Yoga Flow',
            'Mariam Fouad',
            'Studio 3',
            60,
            16,
            'Vinyasa with a long stretch at the end.',
          ),
          (
            'Boxing Basics',
            'Karim Adel',
            'Ring',
            50,
            12,
            'Stance, jab, cross, and pad work.',
          ),
        ];

    for (int day = 0; day < 10; day++) {
      for (int i = 0; i < template.length; i++) {
        if ((day + i) % 2 == 1) continue;

        final (
          String name,
          String instructor,
          String room,
          int minutes,
          int capacity,
          String description,
        ) = template[i];

        final int hour = i.isEven ? 18 : 19;
        // A deterministic spread that includes at least one full class.
        final int booked = ((day * 5 + i * 7) % (capacity + 1)).clamp(
          0,
          capacity,
        );

        result.add(
          GymClass(
            id: 'cl-d$day-$i',
            name: name,
            description: description,
            instructorName: instructor,
            startsAt: today.add(Duration(days: day, hours: hour)),
            durationMinutes: minutes,
            capacity: capacity,
            bookedCount: booked,
            room: room,
          ),
        );
      }
    }
    return result;
  }

  // --- Reservations ------------------------------------------------------

  static List<Reservation> reservations() {
    final DateTime today = AppDate.today();
    return <Reservation>[
      Reservation(
        id: 'rs-1',
        memberId: demoMembershipId,
        kind: ReservationKind.trainer,
        referenceId: 'tr-1-d1-h18',
        startsAt: today.add(const Duration(days: 1, hours: 18)),
        status: ReservationStatus.confirmed,
      ),
      Reservation(
        id: 'rs-2',
        memberId: demoMembershipId,
        kind: ReservationKind.gymClass,
        // Must be an id `classes()` actually generates — `cl-d<day>-<index>`.
        // A reference to a class that does not exist renders as an unnamed
        // "Class" card, which looks like a bug in the app rather than a hole
        // in the fixture.
        referenceId: 'cl-d2-0',
        startsAt: today.add(const Duration(days: 2, hours: 18)),
        status: ReservationStatus.confirmed,
      ),
      Reservation(
        id: 'rs-0',
        memberId: demoMembershipId,
        kind: ReservationKind.gymClass,
        referenceId: 'cl-past-1',
        startsAt: today.subtract(const Duration(days: 4, hours: -19)),
        status: ReservationStatus.completed,
      ),
    ];
  }

  /// Other members, by id, so a staff roster has more than one name on it.
  ///
  /// There is no endpoint that hands the client a list of every member and
  /// there should not be — this is the roster lookup a real `GET /classes/:id
  /// /roster` would return inline.
  static Map<String, String> otherMemberNames() => const <String, String>{
    'GM-1002': 'Hana Fathy',
    'GM-1003': 'Omar Zaki',
    'GM-1004': 'Laila Sami',
    'GM-1005': 'Tarek Nour',
  };

  /// Bookings held by those other members.
  ///
  /// Seeded so the roster screen has something real to show. They are excluded
  /// from "my bookings" by member id, the same way the endpoint would.
  static List<Reservation> otherMemberReservations() {
    final DateTime today = AppDate.today();
    return <Reservation>[
      Reservation(
        id: 'rs-o1',
        memberId: 'GM-1002',
        kind: ReservationKind.gymClass,
        referenceId: 'cl-d0-0',
        startsAt: today.add(const Duration(hours: 18)),
        status: ReservationStatus.confirmed,
      ),
      Reservation(
        id: 'rs-o2',
        memberId: 'GM-1003',
        kind: ReservationKind.gymClass,
        referenceId: 'cl-d0-0',
        startsAt: today.add(const Duration(hours: 18)),
        status: ReservationStatus.confirmed,
      ),
      Reservation(
        id: 'rs-o3',
        memberId: 'GM-1004',
        kind: ReservationKind.gymClass,
        referenceId: 'cl-d0-2',
        startsAt: today.add(const Duration(hours: 18)),
        status: ReservationStatus.confirmed,
      ),
      Reservation(
        id: 'rs-o4',
        memberId: 'GM-1005',
        kind: ReservationKind.trainer,
        referenceId: 'tr-2-d1-h17',
        startsAt: today.add(const Duration(days: 1, hours: 17)),
        status: ReservationStatus.confirmed,
      ),
    ];
  }

  // --- Calendar ----------------------------------------------------------

  /// Roughly four sessions a week over the last 120 days, so the month view
  /// has a believable pattern of dots rather than a solid block.
  static List<AttendanceRecord> attendance() {
    final DateTime today = AppDate.today();
    final List<AttendanceRecord> records = <AttendanceRecord>[];

    for (int back = 0; back < 120; back++) {
      final DateTime day = DateTime(today.year, today.month, today.day - back);
      // Friday off, plus an occasional skipped day.
      if (day.weekday == DateTime.friday) continue;
      if ((back * 7) % 11 < 2) continue;

      final int hour = day.weekday == DateTime.saturday ? 10 : 18;
      records.add(
        AttendanceRecord(
          date: day,
          checkInAt: DateTime(day.year, day.month, day.day, hour, back % 60),
          // No exit signal exists, so check-out is unknown for most days.
          checkOutAt: back % 9 == 0
              ? DateTime(day.year, day.month, day.day, hour + 1, 20)
              : null,
        ),
      );
    }
    return records;
  }

  /// A four-week PPL history, so copy/paste and templates have something to
  /// collide with when they are built.
  static List<CalendarNote> notes() {
    final DateTime today = AppDate.today();
    const List<String> cycle = <String>['Push', 'Pull', 'Legs', 'Rest'];
    final List<CalendarNote> result = <CalendarNote>[];

    for (int back = 0; back < 28; back++) {
      final DateTime day = DateTime(today.year, today.month, today.day - back);
      result.add(
        CalendarNote(
          id: 'note-${AppDate.keyOf(day)}',
          date: day,
          label: cycle[back % cycle.length],
        ),
      );
    }
    return result;
  }

  static List<SplitTemplate> splitTemplates() => <SplitTemplate>[
    const SplitTemplate(
      id: 'tpl-ppl',
      name: 'Push / Pull / Legs',
      days: <String>['Push', 'Pull', 'Legs', 'Rest'],
    ),
    const SplitTemplate(
      id: 'tpl-ul',
      name: 'Upper / Lower',
      days: <String>['Upper', 'Lower', 'Rest'],
    ),
    const SplitTemplate(
      id: 'tpl-bro',
      name: 'Five-day split',
      days: <String>['Chest', 'Back', 'Shoulders', 'Arms', 'Legs', 'Rest'],
    ),
  ];
}
