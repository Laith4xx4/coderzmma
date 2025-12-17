import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:maa3/features/attendance/presentation/pages/attendance_list_page.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:maa3/features/bookings/presentation/pages/booking_list_page.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:maa3/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:maa3/features/coaches/presentation/pages/coach_list_page.dart';
import 'package:maa3/features/feedbacks/presentation/bloc/feedback_cubit.dart';
import 'package:maa3/features/feedbacks/presentation/pages/feedback_list_page.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/memberpro/presentation/pages/member_list_page.dart';
import 'package:maa3/features/progress/presentation/bloc/progress_cubit.dart';
import 'package:maa3/features/progress/presentation/pages/progress_list_page.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:maa3/features/sessions/presentation/pages/session_list_page.dart';
import 'package:maa3/widgets/carousl.dart';
import 'package:maa3/widgets/sessionw.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadData();
  }

  Future<void> _loadUserRole() async {
    final role = await RoleHelper.getCurrentUserRole();
    setState(() {
      userRole = role;
      isLoading = false;
    });
  }

  void _loadData() {
    context.read<SessionCubit>().loadSessions();
    context.read<ClassTypeCubit>().loadClassTypes();
    context.read<BookingCubit>().loadBookings();
    context.read<FeedbackCubit>().loadFeedbacks();

    // Load admin/coach specific data
    RoleHelper.isAdmin().then((isAdmin) {
      if (isAdmin) {
        context.read<MemberCubit>().loadMembers();
        context.read<AttendanceCubit>().loadAttendances();
        context.read<CoachCubit>().loadCoaches();
        context.read<ProgressCubit>().loadProgress();
      }
    });

    RoleHelper.isCoach().then((isCoach) {
      if (isCoach) {
        context.read<AttendanceCubit>().loadAttendances();
        context.read<ProgressCubit>().loadProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final isAdmin = userRole?.toLowerCase() == 'admin';
    final isCoach = userRole?.toLowerCase() == 'coach';
    final isMember = userRole?.toLowerCase() == 'member';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        automaticallyImplyLeading: false,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(33)),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'MMA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SessionCubit>().loadSessions();
          context.read<ClassTypeCubit>().loadClassTypes();
          context.read<MemberCubit>().loadMembers();
          context.read<BookingCubit>().loadBookings();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            /// *************** Carousel ***************
            const Carousl(),
            const SizedBox(height: 24),

            /// *************** Statistics Cards ***************
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatisticsCards(context, isAdmin, isCoach, isMember),
            ),
            const SizedBox(height: 24),

            /// *************** Quick Access Menu ***************
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildQuickAccessMenu(context, isAdmin, isCoach, isMember),
            ),

            const SizedBox(height: 24),

            /// *************** Recent Sessions ***************
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Sessions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF129AA6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: screenHeight * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const ClassTypeListPage(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    BuildContext context,
    bool isAdmin,
    bool isCoach,
    bool isMember,
  ) {
    if (isAdmin) {
      // Admin sees all statistics
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Members',
                  Icons.people,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MemberListPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Sessions',
                  Icons.calendar_today,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionListPage()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Bookings',
                  Icons.book,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingListPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Attendance',
                  Icons.check_circle,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceListPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (isCoach) {
      // Coach sees sessions, bookings, attendance
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'My Sessions',
                  Icons.calendar_today,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionListPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Bookings',
                  Icons.book,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingListPage()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Attendance',
                  Icons.check_circle,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AttendanceListPage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Progress',
                  Icons.trending_up,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressListPage()),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Member sees sessions, bookings, progress
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Sessions',
                  Icons.calendar_today,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionListPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'My Bookings',
                  Icons.book,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingListPage()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'My Progress',
                  Icons.trending_up,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProgressListPage()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Feedbacks',
                  Icons.feedback,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackListPage()),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildQuickAccessMenu(
    BuildContext context,
    bool isAdmin,
    bool isCoach,
    bool isMember,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 12),
        if (isAdmin) ...[
          _buildQuickAccessItem(
            context,
            'Class Types',
            Icons.category,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ClassTypeListPage()),
            ),
          ),
          const SizedBox(height: 8),
          _buildQuickAccessItem(
            context,
            'Coaches',
            Icons.person_outline,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoachListPage()),
            ),
          ),
          const SizedBox(height: 8),
        ],
        _buildQuickAccessItem(
          context,
          'Feedbacks',
          Icons.feedback,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackListPage()),
          ),
        ),
        if (isAdmin || isCoach) ...[
          const SizedBox(height: 8),
          _buildQuickAccessItem(
            context,
            'Progress',
            Icons.trending_up,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressListPage()),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // color: AppTheme.primaryDark,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      decoration: AppTheme.cardDecoration(
        borderRadius: AppTheme.borderRadiusMedium,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.heading3.copyWith(fontSize: 16),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
