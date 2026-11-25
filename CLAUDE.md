# Gym App — Project Context

Flutter mobile app for a local gym. Members log in with their gym membership ID,
see how busy the gym is, book trainers and classes, track their attendance and
training split on a calendar, and manage their account.

Platforms: Android + iOS. Flutter is already installed and set up.

---

## Ground rules for Claude Code

1. **Dummy data first.** Every screen must be fully buildable and navigable
   against in-memory fake data before any backend exists. Real data is swapped in
   later by changing one line, not by rewriting UI.
2. **Never talk to a database directly from the Flutter app.** No SQL strings,
   no DB drivers, no DB credentials in the client. Anything shipped in an APK is
   readable by anyone who downloads it. The app talks HTTP to a backend; the
   backend talks to the database.
3. **Parameterized queries are a backend requirement**, not a client one — see
   the Security section. If you generate backend code, every query is
   parameterized/prepared. No string concatenation into SQL. Ever.
4. **One feature at a time.** Follow the Build Order at the bottom. Don't
   scaffold all four tabs at once.
5. **Ask before inventing product rules.** If a business rule isn't written here
   (cancellation windows, how many trainer slots per day, etc.), stop and ask
   rather than guessing.

---

## Tech stack

| Concern | Choice | Notes |
|---|---|---|
| Framework | Flutter (stable channel) | |
| Language | Dart, null-safety on | |
| State management | Riverpod (`flutter_riverpod`) | Swap for Provider/Bloc only if asked |
| Routing | `go_router` | Declarative, handles the auth redirect cleanly |
| HTTP | `dio` | Interceptors for auth token + error mapping |
| Local storage | `shared_preferences` for prefs, `flutter_secure_storage` for tokens | Tokens NEVER in shared_preferences |
| Models | `freezed` + `json_serializable` | Immutable models, generated `fromJson`/`toJson` |
| Calendar UI | `table_calendar` | |
| Config | `--dart-define-from-file` or `flutter_dotenv` | See `.env.example` |
| Testing | `flutter_test` + `mocktail` | Widget test per screen, unit test per repository |

---

## Architecture

Feature-first folders. Each feature owns its screens, widgets, controllers.

```
lib/
  main.dart
  app.dart                    # MaterialApp.router, theme, router config
  core/
    config/app_config.dart    # reads env vars, exposes useMockData flag
    theme/                    # colors, text styles, spacing constants
    router/app_router.dart
    network/dio_client.dart
    errors/failures.dart
    widgets/                  # shared: primary_button, app_text_field, loading_view
  data/
    models/                   # freezed models, shared across features
    repositories/
      auth_repository.dart          # abstract interface
      auth_repository_mock.dart
      auth_repository_api.dart
      gym_repository.dart           # capacity + events/offers
      gym_repository_mock.dart
      gym_repository_api.dart
      reservation_repository.dart   # + _mock + _api
      calendar_repository.dart      # + _mock + _api
      account_repository.dart       # + _mock + _api
    mock/mock_data.dart       # all fake seed data lives here, one file
  features/
    splash/
    auth/           # login, signup, otp
    home/
    reservations/
    calendar/
    account/
```

### The dummy-to-real swap

Every repository is an **abstract class** with two implementations. A single
Riverpod provider decides which one is live:

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AppConfig.useMockData
      ? MockAuthRepository()
      : ApiAuthRepository(ref.watch(dioClientProvider));
});
```

`AppConfig.useMockData` comes from the `USE_MOCK_DATA` env var. Flipping it to
`false` moves the whole app onto the real backend. **No widget or controller may
ever import a `_mock` or `_api` class directly** — they depend only on the
abstract interface.

Mock implementations should include a small artificial delay
(`await Future.delayed(const Duration(milliseconds: 600))`) so loading states
are actually visible and get built properly.

---

## Data models

Keep these in `lib/data/models/`. Field names are the contract with the backend.

- **Member** — `id` (gym membership ID, String), `username`, `phoneMasked`,
  `profileImageUrl?`, `membershipTier`, `membershipExpiry`, `invitationsRemaining`
- **AuthSession** — `accessToken`, `refreshToken`, `expiresAt`, `member`
- **CheckIn** — `memberId`, `enteredAt` (DateTime), `expiresAt` (DateTime,
  = `enteredAt` + session window), `source` (`turnstile` / `frontDesk` / `manual`).
  Backend-side concept; the app usually only sees the aggregate.
- **GymCapacity** — `currentOccupancy` (int), `maxCapacity` (int),
  `updatedAt`, plus computed `occupancyRatio` (0.0–1.0) and
  `level` (`quiet` / `moderate` / `busy` / `packed`)
- **GymEvent** — `id`, `title`, `description`, `imageUrl?`, `startsAt`,
  `endsAt?`, `type` (`event` / `offer`)
- **Trainer** — `id`, `name`, `photoUrl?`, `specialties` (List<String>), `bio`, `rating?`
- **TrainerSlot** — `id`, `trainerId`, `startsAt`, `durationMinutes`, `isBooked`
- **GymClass** — `id`, `name`, `description`, `instructorName`, `startsAt`,
  `durationMinutes`, `capacity`, `bookedCount`, `room`
- **Reservation** — `id`, `memberId`, `kind` (`trainer` / `class`),
  `referenceId`, `startsAt`, `status` (`confirmed` / `cancelled` / `completed`)
- **AttendanceRecord** — `date`, `checkInAt?`, `checkOutAt?`
- **CalendarNote** — `id`, `date`, `label` (e.g. "Leg Day"), `colorHex?`
- **SplitTemplate** — `id`, `name`, `days` (ordered List<String>, e.g.
  `["Push","Pull","Legs","Rest"]`) — used by the repeat feature

---

## Screens

### 1. Splash
Gym logo centered on brand background, held for ~2 seconds while the app:
restores any saved session token, loads remote config, warms the theme.
Then redirect: valid session → Home shell, otherwise → Login.
Do **not** use a bare `Future.delayed` and `pushReplacement` — the redirect is
driven by `go_router`'s `redirect` callback watching an auth state provider, so
it stays correct if the token expires mid-session.

### 2. Login
Fields: **membership ID** and **password**. Both required.
- "Forgot password?" text button (route can be a stub for now).
- "Don't have an account? **Sign up**" link at the bottom → Sign Up screen.
- Inline validation errors under each field, never a snackbar for validation.
- Generic error message on failure: *"Incorrect membership ID or password."*
  Never reveal whether the ID exists — that leaks who is a member.
- Loading state disables the button and shows a spinner inside it.

### 3. Sign Up
The point of this flow: **only real gym members can create an account.** The
membership ID must already exist in the gym's member table, and the OTP proves
the person holds the phone number attached to that ID.

Fields, in order:
1. **Username** — free text, any value the user wants. Validate: 3–30 chars,
   trimmed, no leading/trailing whitespace. Uniqueness is checked server-side.
2. **Membership ID** — validated against the gym's member records. Two failure
   cases the backend distinguishes but the UI should blur together:
   ID not found, or ID already registered to an account. Show one message:
   *"We couldn't set up an account with that membership ID. Please check with
   the front desk."*
3. **Password** + **Confirm password** — min 8 chars, at least one letter and
   one number. Show a strength hint. Never log or print the password.

On submit → backend verifies the ID and sends an OTP to the phone number stored
against that member. App navigates to OTP screen. The masked number
(`+20 1** *** 4471`) is shown so the user knows which phone to check.

### 4. OTP verification
- 6-digit code, one box per digit, auto-advance, paste support.
- Countdown timer (60s) before "Resend code" becomes tappable.
- Wrong code → clear the boxes, show attempts remaining. Backend locks after 5.
- On success: account created, show a brief success state, then return to Login.
- A **back arrow** in the app bar returns to Login at any point, as specified.
  Warn with a dialog if there's an OTP in flight ("Your code will expire").

### 5. App shell — bottom navigation
Four tabs, persistent state per tab (use `go_router`'s `StatefulShellRoute`
so each tab keeps its own navigation stack and scroll position):

| Tab | Icon | Label |
|---|---|---|
| 0 | `home_rounded` | Home |
| 1 | `event_available_rounded` | Reservations |
| 2 | `calendar_month_rounded` | Calendar |
| 3 | `person_rounded` | Account |

### 6. Home
Pull-to-refresh. Two sections:

**Capacity bar** — the hero element at the top. A horizontal bar showing how
full the gym is right now. See **Occupancy calculation** below for where the
number comes from.
- Displays occupancy as a percentage and as a label: Quiet / Moderate / Busy / Packed.
- Also show the raw count under the percentage: "38 of 120 members in the gym".
- Color bands against a max of 120: green < 40% (0–47), amber 40–70% (48–83),
  orange 70–90% (84–107), red > 90% (108+).
- Animate the fill on load (`TweenAnimationBuilder`, ~800ms, `Curves.easeOut`).
- Show "Updated 2 min ago" under the bar.
- Auto-refresh every 60 seconds while the Home tab is visible; stop the timer
  when it isn't (cancel in `dispose`, don't leak timers).
- The app **never computes occupancy itself** — it displays whatever
  `currentOccupancy` the repository returns. All counting logic is server-side.

**Events & offers** — a vertical list of `GymEvent` cards below the bar, sorted
by `startsAt`. Card shows image, title, date, and a short description. Offers get
a distinct accent color from events. Empty state: friendly illustration + "No
upcoming events right now."

### 7. Reservations
Landing view with **two large option cards**: *Trainers* and *Classes*. Tapping
either pushes a dedicated screen. (A `TabBar` is an acceptable alternative if it
feels better in the build — ask before switching.)

**Trainers flow:** list of trainers with photo, name, specialties → tap a trainer
→ detail screen with bio + available `TrainerSlot`s grouped by day → tap a slot →
confirmation sheet → booked.

**Classes flow:** list of upcoming classes grouped by date, each showing name,
instructor, time, room, and a "12/20 spots" indicator. Full classes are visibly
disabled. Tap → confirmation sheet → booked.

**My reservations:** a section or tab listing the member's confirmed upcoming
reservations with a cancel action.

> Detailed booking rules (cancellation window, max bookings per member, waitlists,
> double-booking prevention) will be specified in a later session. Build the UI
> and repository interfaces so these can be added without restructuring.

### 8. Calendar
Month view (`table_calendar`), swipeable between months, with a
month/two-week/week format toggle.

Day cell markers:
- **Attendance** — a filled dot on days the member checked into the gym.
- **Events** — a differently-colored marker on days with a `GymEvent`.
- **Notes** — days with a `CalendarNote` show the label text under the date
  number, truncated (e.g. "Legs").

Tapping a day opens a bottom sheet showing: attendance status, any events that
day, and the note for that day with edit/delete.

**Split tracking** — the feature the user cares most about:
- Add free text to any day ("Sunday is leg day", "Push", "Rest").
- **Copy** a day's note, **paste** onto another day.
- **Repeat across the year**: select a set of days that form one cycle (e.g.
  Mon=Push, Tue=Pull, Wed=Legs, Thu=Rest), save it as a `SplitTemplate`, then
  apply it over a date range. Two repeat modes:
  - *Weekly* — repeats on the same weekdays every week.
  - *Rotating* — an N-day cycle that rolls forward regardless of weekday
    (common for PPL splits).
- Applying a template over a range where notes already exist must prompt:
  *Overwrite* / *Keep existing* / *Cancel*. Never silently destroy user data.
- Applying across a year writes up to ~365 rows — batch it in one repository
  call, show a progress indicator, and make it undoable for the session.

### 9. Account
- **Settings icon** top-right in the app bar → settings screen containing
  **Log out** (with a confirm dialog). Logout clears secure storage, wipes
  cached state, and redirects to Login.
- **Profile header**: profile picture (tap to change — `image_picker`, crop,
  compress to ≤ 500KB before upload), username with an edit action, membership ID
  displayed read-only.
- **Invitations**: card showing how many guest invitations the member has left,
  tied to their membership ID. Tapping shows usage history.
- **Editing username**: inline dialog or dedicated screen, same validation as
  sign up, optimistic update with rollback on failure.

---

## Occupancy calculation

The gym already has an occupancy/entry system. This app integrates with it —
it does not replace it and does not do the counting.

### The model

There is no exit signal. Presence is **inferred from entry plus a fixed session
window**:

1. A member enters the gym. The entry system fires a signal to the backend the
   app integrates with.
2. That check-in starts a **75-minute (1h 15m) window** for that member.
3. A member is counted as *currently in the gym* if `now` is inside their
   window — i.e. `enteredAt <= now < enteredAt + 75 minutes`.
4. Current occupancy = the number of members with an active window.
5. Percentage shown to the user = `currentOccupancy / MAX_OCCUPANCY`, where
   **`MAX_OCCUPANCY = 120`**.

So at 6:00 PM, if 41 members have checked in since 4:45 PM and not yet expired,
the bar reads **34% — Quiet — 41 of 120**.

> Corrected 2026-08-06: this example previously read "Moderate", which
> contradicted the colour bands above (green < 40%, i.e. 0–47). The **bands are
> authoritative**; 34% is Quiet.

### Rules the backend must follow

- **Deduplicate by member ID.** If the same member's signal fires twice inside
  their window (badge re-scan, stepping out and back), do not count them twice.
  Refresh `expiresAt` to `latestEntry + 75 minutes` instead.
- **Expiry is lazy, not scheduled.** Don't run a cron job that decrements a
  counter — that drifts and breaks on restart. Compute the count on read:
  `COUNT(*) WHERE expires_at > NOW()`. This is correct even if the service was
  down for an hour.
- **Clamp the ratio to 1.0** for the bar's fill. If 130 people are somehow
  inside, show "108%" in text but don't overflow the bar widget.
- **Cap the displayed count** at something sane if the source system sends
  garbage (negative, or 10x max). Log it, show the last known good value.
- **Reset at closing time.** Any window still open when the gym closes is
  discarded, so the first member the next morning sees 1, not yesterday's
  leftovers.
- **Expose one endpoint**: `GET /gym/capacity` →
  `{ "currentOccupancy": 41, "maxCapacity": 120, "updatedAt": "..." }`.
  The app calls this and nothing else. No raw check-in rows go to the client —
  that would leak who is at the gym right now.

### Known limitations of the 75-minute assumption

Write these down; they are real and will show up in the numbers.

- A member who trains for two hours **disappears from the count at 75 minutes**
  while still physically present → undercount during long-session hours.
- A member who leaves after 30 minutes **stays counted for another 45** →
  overcount, especially in off-peak hours with short visits.
- These partially cancel out at peak, but not at the edges of the day.
- If the gym's system ever exposes an **exit signal**, use it: close the window
  on exit and fall back to the 75-minute expiry only when no exit is seen.
  Build `CheckIn` so `expiresAt` can be overwritten early — don't hardcode the
  window as immutable.
- 75 minutes is a tunable, not a law. Keep it as one backend config value
  (`SESSION_WINDOW_MINUTES=75`), not scattered through the code, so it can be
  corrected once real data shows the true average session length.

### Dummy data behaviour

While `USE_MOCK_DATA=true`, `MockGymRepository` should **simulate a realistic
day** rather than returning a constant:

- Keep an in-memory list of fake `CheckIn`s with staggered `enteredAt` values
  and apply the same 75-minute window logic, so the mock exercises the real
  code path.
- Vary by time of day so the bar visibly moves during testing: quiet mornings
  (~15–25), moderate midday (~40–60), peak 6–9 PM (~95–115), near-empty late.
- Add slight random jitter (±5) on each refresh so the 60-second auto-refresh
  is visibly doing something.
- Include a debug-only way to force a level — a long-press on the bar in dev
  builds cycling quiet → moderate → busy → packed — so all four color states can
  be checked without waiting for the clock.

---

## Security requirements

These are non-negotiable. Flag it in the response if a request would break one.

**Parameterized queries — backend only.** Every database query that touches
user input uses placeholders bound by the driver:

```js
// correct
db.query('SELECT id, username FROM members WHERE membership_id = $1', [id]);

// forbidden — SQL injection
db.query(`SELECT id, username FROM members WHERE membership_id = '${id}'`);
```

This applies to the login lookup, the sign-up ID check, and every other query.
The Flutter app never constructs SQL because it never touches the database.

**Passwords** are hashed with bcrypt or Argon2id on the backend, never stored or
transmitted in plain text beyond the TLS request body, never logged, never
written to local storage.

**Tokens** live in `flutter_secure_storage` (Keychain / EncryptedSharedPreferences),
never `shared_preferences`, never in app state that gets serialized.

**OTP**: 6 digits, 5-minute expiry, single use, rate-limited server-side by both
phone number and IP. The app never receives or checks the code itself — it
posts the entered code and gets back a yes/no.

**Input validation happens twice** — client-side for UX, server-side for safety.
Client validation is never trusted.

**Enumeration**: login and sign-up error messages must not reveal whether a
membership ID exists in the system.

**Nothing in the app is secret.** No API keys, no DB strings, no admin
endpoints. Assume every string in the APK is public.

---

## Code conventions

- `const` constructors wherever possible; `prefer_const_constructors` lint on.
- Widgets over 150 lines get split. No `build` method longer than ~80 lines.
- No business logic in widgets — it lives in Riverpod controllers/notifiers.
- No magic numbers for spacing/color — use `core/theme` constants.
- Every async UI path handles three states explicitly: loading, error, data.
  Riverpod's `AsyncValue.when` is the standard pattern.
- Errors are mapped to a `Failure` type in the repository layer; UI never sees
  a raw `DioException`.
- File names `snake_case.dart`, classes `PascalCase`, providers end in `Provider`.
- Run `dart format .` and `flutter analyze` before considering a task done.

---

## Build order

Work through these in sequence. Finish and verify each before starting the next.

1. Project scaffold, folder structure, theme, `AppConfig`, `go_router` with
   placeholder screens for all routes.
2. All models with `freezed` + generated JSON. Run `build_runner`.
3. `mock_data.dart` seed data + all mock repositories.
4. Splash screen + auth redirect logic.
5. Login screen wired to `MockAuthRepository`.
6. Sign Up + OTP screens, full flow, back arrow to Login.
7. Bottom nav shell with the four tabs.
8. Home: capacity bar, then events/offers list.
9. Reservations: trainers flow, then classes flow, then my-reservations.
10. Calendar: month view + markers, then notes, then copy/paste, then split templates.
11. Account: profile header, invitations, edit username, settings + logout.
12. Widget tests per screen, unit tests per repository.
13. Only then: API repository implementations, `USE_MOCK_DATA=false`.

---

## Open questions

Ask before implementing anything that depends on these:

- What exactly is the gym's entry system, and how does it emit the check-in
  signal — webhook, polled API, direct DB table, or something manual?
- Does that system also record exits? If yes, the 75-minute fallback becomes a
  fallback only.
- What are the gym's opening and closing hours (needed for the daily reset)?
- Is there an existing member database, and what's its schema/access method?
- Which SMS provider for OTP (Twilio, Vonage, a local Egyptian gateway)?
- Are trainer slots fixed-length or variable?
- Do invitations expire? Can they be gifted?
- Arabic/RTL support needed alongside English?
