/// Every route path and name in one place. Widgets navigate with these
/// constants, never with a string literal.
class AppRoutes {
  const AppRoutes._();

  // --- Boot & auth -------------------------------------------------------
  static const String splash = '/splash';

  static const String login = '/login';
  static const String forgotPassword = '/login/forgot-password';
  static const String signUp = '/signup';

  /// Pushed after sign-up submits. Carries the masked phone number so the
  /// screen can tell the user which phone to check.
  static const String otp = '/signup/otp';

  // --- Shell tabs --------------------------------------------------------
  static const String home = '/home';
  static const String reservations = '/reservations';
  static const String calendar = '/calendar';
  static const String account = '/account';

  // --- Reservations sub-routes -------------------------------------------
  // Trainers, classes and the member's own bookings are tabs *inside*
  // `/reservations`, not routes of their own — a tab is UI state, and putting
  // it in the URL would mean three locations that all render the same screen.
  // A trainer's schedule is a real push, so it keeps a route.
  static const String trainerDetail = '/reservations/trainer/:trainerId';

  static String trainerDetailFor(String trainerId) =>
      '/reservations/trainer/$trainerId';

  // --- Staff -------------------------------------------------------------
  // Only reachable with `MemberRole.staff`. The redirect enforces that in the
  // app; the backend enforces it where it counts.
  static const String manage = '/manage';
  static const String manageEvents = '/manage/events';
  static const String manageClasses = '/manage/classes';
  static const String manageTrainers = '/manage/trainers';
  static const String manageTrainerSlots = '/manage/trainers/:trainerId/slots';
  static const String manageClassRoster = '/manage/classes/:classId/roster';

  static String manageTrainerSlotsFor(String trainerId) =>
      '/manage/trainers/$trainerId/slots';

  static String manageClassRosterFor(String classId) =>
      '/manage/classes/$classId/roster';

  // --- Calendar sub-routes -----------------------------------------------
  static const String splits = '/calendar/splits';

  // --- Account sub-routes ------------------------------------------------
  static const String settings = '/account/settings';
  static const String invitations = '/account/invitations';
  static const String editUsername = '/account/username';

  /// Route names, used for `goNamed` where a path would be awkward to build.
  static const String nameSplash = 'splash';
  static const String nameLogin = 'login';
  static const String nameForgotPassword = 'forgotPassword';
  static const String nameSignUp = 'signUp';
  static const String nameOtp = 'otp';
  static const String nameHome = 'home';
  static const String nameReservations = 'reservations';
  static const String nameCalendar = 'calendar';
  static const String nameSplits = 'splits';
  static const String nameAccount = 'account';
  static const String nameTrainerDetail = 'trainerDetail';
  static const String nameManage = 'manage';
  static const String nameManageEvents = 'manageEvents';
  static const String nameManageClasses = 'manageClasses';
  static const String nameManageTrainers = 'manageTrainers';
  static const String nameManageTrainerSlots = 'manageTrainerSlots';
  static const String nameManageClassRoster = 'manageClassRoster';
  static const String nameSettings = 'settings';
  static const String nameInvitations = 'invitations';
  static const String nameEditUsername = 'editUsername';
}
