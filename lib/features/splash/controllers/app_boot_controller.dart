import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long the logo is held.
///
/// Sized to let the brand animation finish rather than being cut off
/// mid-assemble: the mark needs ~1.85s and the wordmark overlaps into the
/// tail of it. Still short enough not to read as a stall.
const Duration splashHold = Duration(milliseconds: 2600);

/// The brand hold, and nothing else.
///
/// Deliberately independent of the session: if this watched the auth state it
/// would re-run on every login and logout, restarting the two-second hold and
/// leaving a stray timer behind each time. The router combines this with the
/// session's own readiness instead — see `appRouter`'s redirect.
final FutureProvider<void> appBootProvider = FutureProvider<void>((
  Ref ref,
) async {
  await Future<void>.delayed(splashHold);
});
