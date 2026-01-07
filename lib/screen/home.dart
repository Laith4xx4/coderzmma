import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/core/role_helper.dart';
import 'package:thesavage/widgets/carousl.dart';
import '../widgets/ShimmerEffect.dart';

// Cubits & Pages Imports
import 'package:thesavage/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:thesavage/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:thesavage/features/classtypes/presentation/bloc/class_type_state.dart';
import 'package:thesavage/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:thesavage/features/feedbacks/presentation/bloc/feedback_cubit.dart';
import 'package:thesavage/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:thesavage/features/progress/presentation/bloc/progress_cubit.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_cubit.dart';
import 'package:thesavage/features/sessions/presentation/pages/session_list_page.dart';

import 'package:thesavage/features/attendance/presentation/pages/attendance_list_page.dart';
import 'package:thesavage/features/bookings/presentation/pages/booking_list_page.dart';
import 'package:thesavage/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:thesavage/features/coaches/presentation/pages/coach_list_page.dart';
import 'package:thesavage/features/feedbacks/presentation/pages/feedback_list_page.dart';
import 'package:thesavage/features/memberpro/presentation/pages/member_list_page.dart';
import 'package:thesavage/features/progress/presentation/pages/progress_list_page.dart';
import 'package:thesavage/features/users/presentation/pages/user_management_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  String? userRole;
  bool isRoleLoading = true;
  late bool _isAdmin;
  late bool _isCoach;
  late bool _isMember;
  late bool _isClient;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHome();
    });
  }

  Future<void> _initHome() async {
    await _loadUserRole();
    _loadInitialData();
  }

  Future<void> _loadUserRole() async {
    final role = await RoleHelper.getCurrentUserRole();
    if (mounted) {
      _isAdmin = role?.toLowerCase() == 'admin';
      _isCoach = role?.toLowerCase() == 'coach';
      _isMember = role?.toLowerCase() == 'member';
      _isClient = role?.toLowerCase() == 'client';
      setState(() {
        userRole = role;
        isRoleLoading = false;
      });
    }
  }

  void _loadInitialData() {
    context.read<SessionCubit>().loadSessions();
    context.read<ClassTypeCubit>().loadClassTypes();
    if (_isAdmin) {
      context.read<MemberCubit>().loadMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (isRoleLoading) {
      return const Scaffold(
        body: ShimmerEffect(isLoading: true, itemCount: 6),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.surfaceColor,
          onRefresh: () async => _loadInitialData(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStitchHeader(),
                
                // Weekly Goal / Stats Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xD20C0C0C), // Dark Green Card
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Weekly Goal", style: AppTheme.heading3.copyWith(fontSize: 18)),
                                Text("Keep your streak alive!", style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                              ],
                            ),
                            Container(
                              width: 45, height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryColor, width: 2.5),
                                color: AppTheme.primaryColor.withOpacity(0.1),
                              ),
                              child: Center(
                                child: Text("3/5", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Attendance", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            Text("60%", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             _buildMiniStat("Calories", "1,240"),
                             _buildMiniStat("Hours", "4.5h"),
                             _buildMiniStat("Points", "850", isColor: true),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Carousel
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: const Carousl(),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Quick Actions", style: AppTheme.heading3.copyWith(fontSize: 18)),
                ),
                
                const SizedBox(height: 12),

                // Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StatisticsGrid(
                    isAdmin: _isAdmin,
                    isCoach: _isCoach,
                    isMember: _isMember,
                    isClient: _isClient,
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Classes
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Latest Classes", style: AppTheme.heading3.copyWith(fontSize: 18)),
                      TextButton(
                        onPressed: () => Navigator.push(context, _createRoute(const ClassTypeListPage())),
                        child: Text("See all", style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _RecentClasses(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStitchHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade800,
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WELCOME BACK", style: AppTheme.bodySmall.copyWith(fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.bold)),
                  Text(userRole ?? "User", style: AppTheme.heading2.copyWith(fontSize: 18)),
                ],
              ),
            ],
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardBackground,
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {bool isColor = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          color: isColor ? AppTheme.primaryColor : Colors.white, 
          fontWeight: FontWeight.bold, 
          fontSize: 16)
        ),
      ],
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  final bool isAdmin;
  final bool isCoach;
  final bool isMember;
  final bool isClient;

  const _StatisticsGrid({
    required this.isAdmin,
    required this.isCoach,
    required this.isMember,
    required this.isClient,
  });

  @override
  Widget build(BuildContext context) {
    // Custom logic to match the "Quick Actions" grid look
    // 1. Sessions (Book Class style) - Big Green Button if possible, or just first tile
    
    return Column(
      children: [
        // Row 1: Book Class (Sessions) or Schedule
        _ActionCard(
          title: isClient ? "View Schedule" : "Book Class",
          icon: Icons.calendar_today_rounded,
          isPrimary: true,
          onTap: () {
            context.read<SessionCubit>().loadSessions();
            Navigator.push(context, _createRoute(const SessionListPage()));
          },
        ),
        const SizedBox(height: 12),
        // Row 2: Grid for others
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment
          children: [
            // Admin/Coach: Members
            if (isAdmin || isCoach)
              Expanded(
                child: _ActionCard(
                  title: "Members",
                  icon: Icons.people_outline_rounded,
                  isPrimary: false,
                  onTap: () {
                    context.read<MemberCubit>().loadMembers();
                    Navigator.push(context, _createRoute(const MemberListPage()));
                  },
                ),
              )
            // Client: Coaches
            else if (isClient)
              Expanded(
                child: _ActionCard(
                  title: "Coaches",
                  icon: Icons.sports_gymnastics_outlined,
                  isPrimary: false,
                  onTap: () {
                    // Navigate to CoachListPage
                    // Ensure you assume read-only inside that page
                     Navigator.push(context, _createRoute(const CoachListPage()));
                  },
                ),
              )
            // Member: Feedback
            else 
              Expanded(
                child: _ActionCard(
                  title: "Feedback",
                  icon: Icons.thumb_up_alt_outlined,
                  isPrimary: false,
                  onTap: () {
                    context.read<FeedbackCubit>().loadFeedbacks();
                    Navigator.push(context, _createRoute(const FeedbackListPage()));
                  },
                ),
              ),
            
            const SizedBox(width: 12),

            // History (for non-clients) or Features (for Clients)
            if (!isClient) 
              Expanded(
                child: _ActionCard(
                  title: "History",
                  icon: Icons.history_rounded,
                  isPrimary: false,
                  onTap: () {
                    context.read<BookingCubit>().loadBookings();
                    Navigator.push(context, _createRoute(const BookingListPage()));
                  },
                ),
              )
            else 
             Expanded(
                child: _ActionCard(
                  title: "Features", // Class Types
                  icon: Icons.category_outlined,
                  isPrimary: false,
                  onTap: () {
                    context.read<ClassTypeCubit>().loadClassTypes();
                     Navigator.push(context, _createRoute(const ClassTypeListPage()));
                  },
                ),
             )
          ],
        ),
        if (!isClient) ...[
          const SizedBox(height: 12),
           _ActionCard(
            title: "Analytics",
            icon: Icons.bar_chart_rounded,
            isPrimary: false,
             onTap: () {
              context.read<ProgressCubit>().loadProgress();
              Navigator.push(context, _createRoute(const ProgressListPage()));
            },
          ),
        ]
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72, // Further reduced height for a more compact look
        padding: const EdgeInsets.symmetric(horizontal: 16), // Vertical centering handles the rest
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryColor : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: isPrimary ? null : Border.all(color: const Color(0xFFDDDDDD), width: 0.5),
          boxShadow: isPrimary 
              ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))] 
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40, // Slightly smaller icon container
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPrimary ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.05),
              ),
              child: Icon(icon, color: isPrimary ? const Color(0xFF112117) : Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTheme.heading3.copyWith(
                color: isPrimary ? const Color(0xFF112117) : Colors.white,
                fontSize: 15 // Slightly smaller text
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RecentClasses extends StatelessWidget {
  const _RecentClasses();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassTypeCubit, ClassTypeState>(
      builder: (context, state) {
        if (state is ClassTypeLoading) return const ShimmerEffect(isLoading: true, itemCount: 1);
        if (state is ClassTypesLoaded) {
          return Column(
            children: state.classTypes.take(2).map((item) => _ClassItem(item: item)).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ClassItem extends StatelessWidget {
  final dynamic item;
  const _ClassItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("NOW", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 9)),
                const Icon(Icons.bolt, color: AppTheme.primaryColor, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? 'Class', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('60 min', style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                  ],
                )
              ],
            ),
          ),
          Container(
             width: 36, height: 36,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: Colors.white.withOpacity(0.05),
             ),
             child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
          )
        ],
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}