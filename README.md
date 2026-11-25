# BodyFactory — Gym Members App

A Flutter app for a local gym. Members log in with their membership ID, see how
busy the gym is right now, book trainers and classes, and plan their training
split on a calendar.

> **Status:** the UI and features are complete and run on built-in mock data.
> The real backend (API repositories) hasn't been built yet.

## Features

- **Live occupancy.** A capacity bar shows how full the gym is (Quiet,
  Moderate, Busy or Packed) and refreshes every 60 seconds.
- **Events & offers.** A feed of upcoming gym events and promotions.
- **Reservations.** Book personal-trainer slots or group classes, and cancel
  upcoming bookings.
- **Training calendar.** Attendance markers, day notes ("Leg Day"),
  copy and paste between days, and split templates (weekly or rotating PPL-style
  cycles) you can apply across a whole year.
- **Account.** Profile photo, username, guest invitations and settings.
- **Members-only sign-up.** You need a real membership ID plus SMS OTP
  verification to create an account.
- **Staff tools.** A Manage tab for staff to edit classes, trainers, slots and
  events.

## Tech stack

Flutter · Riverpod · go_router · Dio · freezed / json_serializable ·
table_calendar · flutter_secure_storage

## Getting started

```bash
cp .env.example .env
flutter pub get
flutter run --dart-define-from-file=.env
```

Every config value has a default, so a plain `flutter run` also works.

### Demo logins (mock mode)

| Role   | Membership ID | Password      |
|--------|---------------|---------------|
| Member | `GM-1001`     | `password123` |
| Staff  | `GM-9001`     | `staff123`    |

To try the sign-up flow, use ID `GM-2044` with OTP code `123456`.

## Configuration

Config is read at compile time through
[`lib/core/config/app_config.dart`](lib/core/config/app_config.dart).
The main switch is:

| Key             | Default | Effect |
|-----------------|---------|--------|
| `USE_MOCK_DATA` | `true`  | `true` serves everything from in-memory fake data. `false` points the app at `API_BASE_URL`. |

[`.env.example`](.env.example) has the full list. Nothing in `.env` is
secret, because anything bundled into the app can be extracted from it.

## Project layout

```
lib/
  core/        config, theme, router, network, shared widgets
  data/        freezed models, repository interfaces + mock implementations
  features/    splash, auth, home, reservations, calendar, account, admin, shell
test/          widget + repository tests
design/        logo animation source
```

Each repository is an abstract interface. A single Riverpod provider chooses
the mock or the real implementation, so the move to a real backend won't touch
any UI code. [CLAUDE.md](CLAUDE.md) has the full product spec and architecture
notes.

## Development

```bash
dart run build_runner build   # regenerate freezed/json code after model changes
dart format .
flutter analyze
flutter test
```
