// lib/core/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:thesavage/core/api_strings.dart';

// Auth
import 'package:thesavage/features/auth1/data/datasource/auth_api_service.dart';
import 'package:thesavage/features/auth1/data/repositories/auth_repository_impl.dart';
import 'package:thesavage/features/auth1/domain/use_cases/login_user.dart';
import 'package:thesavage/features/auth1/domain/use_cases/register_user.dart';
import 'package:thesavage/features/auth1/domain/use_cases/google_login_user.dart'; // Added
import 'package:thesavage/features/auth1/presentation/bloc/auth_cubit.dart';

// Members
import 'package:thesavage/features/memberpro/data/datasource/member_api_service.dart';
import 'package:thesavage/features/memberpro/data/repositories/member_repository_impl.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/create_member.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/delete_member.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/get_all_members.dart';
import 'package:thesavage/features/memberpro/domain/use_cases/update_member.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';

// Bookings
import 'package:thesavage/features/bookings/data/datasource/booking_api_service.dart';
import 'package:thesavage/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:thesavage/features/bookings/domain/use_cases/create_booking.dart';
import 'package:thesavage/features/bookings/domain/use_cases/delete_booking.dart';
import 'package:thesavage/features/bookings/domain/use_cases/get_all_bookings.dart';
import 'package:thesavage/features/bookings/domain/use_cases/update_booking.dart';
import 'package:thesavage/features/bookings/domain/use_cases/book_session.dart';
import 'package:thesavage/features/bookings/domain/use_cases/get_my_bookings.dart';
import 'package:thesavage/features/bookings/domain/use_cases/cancel_booking.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_cubit.dart';

// Attendance
import 'package:thesavage/features/attendance/data/datasource/attendance_api_service.dart';
import 'package:thesavage/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:thesavage/features/attendance/domain/use_cases/create_attendance.dart';
import 'package:thesavage/features/attendance/domain/use_cases/delete_attendance.dart';
import 'package:thesavage/features/attendance/domain/use_cases/get_all_attendances.dart';
import 'package:thesavage/features/attendance/domain/use_cases/update_attendance.dart';
import 'package:thesavage/features/attendance/presentation/bloc/attendance_cubit.dart';

// Coaches
import 'package:thesavage/features/coaches/data/datasource/coach_api_service.dart';
import 'package:thesavage/features/coaches/data/repositories/coach_repository_impl.dart';
import 'package:thesavage/features/coaches/domain/use_cases/create_coach.dart';
import 'package:thesavage/features/coaches/domain/use_cases/delete_coach.dart';
import 'package:thesavage/features/coaches/domain/use_cases/get_all_coaches.dart';
import 'package:thesavage/features/coaches/domain/use_cases/update_coach.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';

// ClassTypes
import 'package:thesavage/features/classtypes/data/datasource/class_type_api_service.dart';
import 'package:thesavage/features/classtypes/data/repositories/class_type_repository_impl.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/create_class_type.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/delete_class_type.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/get_all_class_types.dart';
import 'package:thesavage/features/classtypes/domain/use_cases/update_class_type.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';

// Feedbacks
import 'package:thesavage/features/feedbacks/data/datasource/feedback_api_service.dart';
import 'package:thesavage/features/feedbacks/data/repositories/feedback_repository_impl.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/create_feedback.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/delete_feedback.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/get_all_feedbacks.dart';
import 'package:thesavage/features/feedbacks/domain/use_cases/update_feedback.dart';
import 'package:thesavage/features/feedbacks/presentation/bloc/feedback_cubit.dart';

// Progress
import 'package:thesavage/features/progress/data/datasource/member_progress_api_service.dart';
import 'package:thesavage/features/progress/data/repositories/member_progress_repository_impl.dart';
import 'package:thesavage/features/progress/domain/use_cases/create_progress.dart';
import 'package:thesavage/features/progress/domain/use_cases/delete_progress.dart';
import 'package:thesavage/features/progress/domain/use_cases/get_all_progress.dart';
import 'package:thesavage/features/progress/domain/use_cases/update_progress.dart';
import 'package:thesavage/features/progress/presentation/bloc/progress_cubit.dart';

// Sessions
import 'package:thesavage/features/sessions/data/datasource/session_api_service.dart';
import 'package:thesavage/features/sessions/data/repositories/session_repository_impl.dart';
import 'package:thesavage/features/sessions/domain/use_cases/create_session.dart';
import 'package:thesavage/features/sessions/domain/use_cases/delete_session.dart';
import 'package:thesavage/features/sessions/domain/use_cases/get_all_sessions.dart';
import 'package:thesavage/features/sessions/domain/use_cases/update_session.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //========================================
  //              AUTH
  //========================================
  // إنشاء AuthRepositoryImpl مع baseUrl
  sl.registerLazySingleton<AuthRepositoryImpl>(
        () => AuthRepositoryImpl(baseUrl: ApiStrings.baseUrl),
  );

  sl.registerLazySingleton(() => LoginUser(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => RegisterUser(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => GoogleLoginUser(sl<AuthRepositoryImpl>())); // Added
  sl.registerFactory(
        () => AuthCubit(
      sl<LoginUser>(),
      sl<RegisterUser>(),
      sl<GoogleLoginUser>(), // Added
      sl<AuthRepositoryImpl>(),
    ),
  );
  //========================================
  //              MEMBERS
  //========================================
  sl.registerLazySingleton(() => MemberApiService());
  sl.registerLazySingleton(() => MemberRepositoryImpl(sl<MemberApiService>()));
  sl.registerLazySingleton(() => GetAllMembers(sl<MemberRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateMember(sl<MemberRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateMember(sl<MemberRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteMember(sl<MemberRepositoryImpl>()));
  sl.registerFactory(() => MemberCubit(
    getAllMembers: sl<GetAllMembers>(),
    createMember: sl<CreateMember>(),
    updateMember: sl<UpdateMember>(),
    deleteMember: sl<DeleteMember>(),
  ));

  //========================================
  //              BOOKINGS
  //========================================
  sl.registerLazySingleton(() => BookingApiService());
  sl.registerLazySingleton(() => BookingRepositoryImpl(sl<BookingApiService>()));
  sl.registerLazySingleton(() => GetAllBookings(sl<BookingRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateBooking(sl<BookingRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateBooking(sl<BookingRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteBooking(sl<BookingRepositoryImpl>()));
  sl.registerLazySingleton(() => BookSession(sl<BookingRepositoryImpl>()));
  sl.registerLazySingleton(() => GetMyBookings(sl<BookingRepositoryImpl>()));
  sl.registerLazySingleton(() => CancelBooking(sl<BookingRepositoryImpl>()));
  sl.registerFactory(() => BookingCubit(
    getAllBookings: sl<GetAllBookings>(),
    createBooking: sl<CreateBooking>(),
    updateBooking: sl<UpdateBooking>(),
    deleteBooking: sl<DeleteBooking>(),
    bookSession: sl<BookSession>(),
    getMyBookings: sl<GetMyBookings>(),
    cancelBooking: sl<CancelBooking>(),
  ));

  //========================================
  //              ATTENDANCE
  //========================================
  sl.registerLazySingleton(() => AttendanceApiService());
  sl.registerLazySingleton(() => AttendanceRepositoryImpl(sl<AttendanceApiService>()));
  sl.registerLazySingleton(() => GetAllAttendances(sl<AttendanceRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateAttendance(sl<AttendanceRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateAttendance(sl<AttendanceRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteAttendance(sl<AttendanceRepositoryImpl>()));
  sl.registerFactory(() => AttendanceCubit(
    getAllAttendances: sl<GetAllAttendances>(),
    createAttendance: sl<CreateAttendance>(),
    updateAttendance: sl<UpdateAttendance>(),
    deleteAttendance: sl<DeleteAttendance>(),
  ));

  //========================================
  //              COACHES
  //========================================
  sl.registerLazySingleton(() => CoachApiService());
  sl.registerLazySingleton(() => CoachRepositoryImpl(sl<CoachApiService>()));
  sl.registerLazySingleton(() => GetAllCoaches(sl<CoachRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateCoach(sl<CoachRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateCoach(sl<CoachRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteCoach(sl<CoachRepositoryImpl>()));
  sl.registerFactory(() => CoachCubit(
    getAllCoaches: sl<GetAllCoaches>(),
    createCoach: sl<CreateCoach>(),
    updateCoach: sl<UpdateCoach>(),
    deleteCoach: sl<DeleteCoach>(),
  ));

  //========================================
  //              CLASS TYPES
  //========================================
  sl.registerLazySingleton(() => ClassTypeApiService());
  sl.registerLazySingleton(() => ClassTypeRepositoryImpl(sl<ClassTypeApiService>()));
  sl.registerLazySingleton(() => GetAllClassTypes(sl<ClassTypeRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateClassType(sl<ClassTypeRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateClassType(sl<ClassTypeRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteClassType(sl<ClassTypeRepositoryImpl>()));
  sl.registerFactory(() => ClassTypeCubit(
    getAllClassTypes: sl<GetAllClassTypes>(),
    createClassType: sl<CreateClassType>(),
    updateClassType: sl<UpdateClassType>(),
    deleteClassType: sl<DeleteClassType>(),
  ));

  //========================================
  //              FEEDBACKS
  //========================================
  sl.registerLazySingleton(() => FeedbackApiService());
  sl.registerLazySingleton(() => FeedbackRepositoryImpl(sl<FeedbackApiService>()));
  sl.registerLazySingleton(() => GetAllFeedbacks(sl<FeedbackRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateFeedback(sl<FeedbackRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateFeedback(sl<FeedbackRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteFeedback(sl<FeedbackRepositoryImpl>()));
  sl.registerFactory(() => FeedbackCubit(
    getAllFeedbacks: sl<GetAllFeedbacks>(),
    createFeedback: sl<CreateFeedback>(),
    updateFeedback: sl<UpdateFeedback>(),
    deleteFeedback: sl<DeleteFeedback>(),
  ));

  //========================================
  //              PROGRESS
  //========================================
  sl.registerLazySingleton(() => MemberProgressApiService());
  sl.registerLazySingleton(() => MemberProgressRepositoryImpl(sl<MemberProgressApiService>()));
  sl.registerLazySingleton(() => GetAllProgress(sl<MemberProgressRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateProgress(sl<MemberProgressRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateProgress(sl<MemberProgressRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteProgress(sl<MemberProgressRepositoryImpl>()));
  sl.registerFactory(() => ProgressCubit(
    getAllProgress: sl<GetAllProgress>(),
    createProgress: sl<CreateProgress>(),
    updateProgress: sl<UpdateProgress>(),
    deleteProgress: sl<DeleteProgress>(),
  ));

  //========================================
  //              SESSIONS
  //========================================
  sl.registerLazySingleton(() => SessionApiService());
  sl.registerLazySingleton(() => SessionRepositoryImpl(sl<SessionApiService>()));
  sl.registerLazySingleton(() => GetAllSessions(sl<SessionRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateSession(sl<SessionRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateSession(sl<SessionRepositoryImpl>()));
  sl.registerLazySingleton(() => DeleteSession(sl<SessionRepositoryImpl>()));
  sl.registerFactory(() => SessionCubit(
    getAllSessions: sl<GetAllSessions>(),
    createSession: sl<CreateSession>(),
    updateSession: sl<UpdateSession>(),
    deleteSession: sl<DeleteSession>(),
  ));
}