// lib/core/bloc_providers.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:thesavage/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:thesavage/features/feedbacks/presentation/bloc/feedback_cubit.dart';
import 'package:thesavage/features/progress/presentation/bloc/progress_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'injection_container.dart';

List<BlocProvider> get appBlocProviders => [
  BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
  BlocProvider<MemberCubit>(create: (_) => sl<MemberCubit>()),
  BlocProvider<BookingCubit>(create: (_) => sl<BookingCubit>()),
  BlocProvider<AttendanceCubit>(create: (_) => sl<AttendanceCubit>()),
  BlocProvider<CoachCubit>(create: (_) => sl<CoachCubit>()),
  BlocProvider<ClassTypeCubit>(create: (_) => sl<ClassTypeCubit>()),
  BlocProvider<FeedbackCubit>(create: (_) => sl<FeedbackCubit>()),
  BlocProvider<ProgressCubit>(create: (_) => sl<ProgressCubit>()),
  BlocProvider<SessionCubit>(create: (_) => sl<SessionCubit>()),
];