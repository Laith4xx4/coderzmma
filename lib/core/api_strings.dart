class ApiStrings {
  static const String baseUrl = 'http://192.168.100.66:5086/api';

  // Auth
  static const String loginEndpoint = '/Auth/login';
  static const String registerEndpoint = '/Auth/register';

  // Members
  static const String memberProfilesEndpoint = '/MemberProfiles';

  // Coaches
  static const String coachProfilesEndpoint = '/CoachProfiles';

  // Sessions / Classes / Bookings / Attendance
  static const String sessionsEndpoint = '/Sessions';
  static const String classTypesEndpoint = '/ClassTypes';
  static const String bookingsEndpoint = '/Bookings';
  static const String attendancesEndpoint = '/Attendances';

  // Feedback & Progress
  static const String feedbackEndpoint = '/Feedbacks';
  static const String memberSetProgressEndpoint = '/MemberSetProgress';
}
