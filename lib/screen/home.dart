import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/widgets/carousl.dart';
import '../widgets/ShimmerEffect.dart';

// Cubits & Pages Imports (بقيت كما هي)
import 'package:maa3/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:maa3/features/bookings/presentation/bloc/booking_cubit.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_cubit.dart';
import 'package:maa3/features/classtypes/presentation/bloc/class_type_state.dart';
import 'package:maa3/features/coaches/presentation/bloc/coach_cubit.dart';
import 'package:maa3/features/feedbacks/presentation/bloc/feedback_cubit.dart';
import 'package:maa3/features/memberpro/presentation/bloc/member_cubit.dart';
import 'package:maa3/features/progress/presentation/bloc/progress_cubit.dart';
import 'package:maa3/features/sessions/presentation/bloc/session_cubit.dart';

import 'package:maa3/features/attendance/presentation/pages/attendance_list_page.dart';
import 'package:maa3/features/bookings/presentation/pages/booking_list_page.dart';
import 'package:maa3/features/classtypes/presentation/pages/class_type_list_page.dart';
import 'package:maa3/features/coaches/presentation/pages/coach_list_page.dart';
import 'package:maa3/features/feedbacks/presentation/pages/feedback_list_page.dart';
import 'package:maa3/features/memberpro/presentation/pages/member_list_page.dart';
import 'package:maa3/features/progress/presentation/pages/progress_list_page.dart';
import 'package:maa3/features/sessions/presentation/pages/session_list_page.dart';
import 'package:maa3/features/users/presentation/pages/user_management_page.dart';

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
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.surfaceColor,
        onRefresh: () async => _loadInitialData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildModernHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacingLG),

                    // Carousel بتصميم متوافق مع الثيم
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        child: const RepaintBoundary(child: Carousl()),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXL),
                    const _SectionHeader(title: 'Dashboard Overview'),
                    const SizedBox(height: AppTheme.spacingMD),

                    _StatisticsGrid(
                      isAdmin: _isAdmin,
                      isCoach: _isCoach,
                      isMember: _isMember,
                      isClient: _isClient,
                    ),

                    const SizedBox(height: AppTheme.spacingXL),
                    const _SectionHeader(title: 'Quick Management'),
                    const SizedBox(height: AppTheme.spacingMD),

                    _QuickAccessList(isAdmin: _isAdmin, isCoach: _isCoach),

                    const SizedBox(height: AppTheme.spacingXL),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader(title: 'Latest Classes', padding: EdgeInsets.zero),
                        TextButton(
                            onPressed: (){},
                            child: Text("Explore All", style: AppTheme.bodySmall.copyWith(color: AppTheme.infoColor, fontWeight: FontWeight.bold))
                        )
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMD),

                    const _RecentClasses(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good Morning' : now.hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final formattedDate = DateFormat('EEEE, d MMMM').format(now);

    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppTheme.borderRadiusXLarge)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userRole?.toUpperCase() ?? 'USER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            // أيقونة خلفية خفيفة جداً
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.fitness_center,
                size: 150,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.1),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        )
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;
  const _SectionHeader({required this.title, this.padding = const EdgeInsets.only(left: 4)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: AppTheme.heading3,
      ),
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppTheme.spacingMD,
      crossAxisSpacing: AppTheme.spacingMD,
      childAspectRatio: 1.1,
      children: [
        _StatCard(
          title: 'Sessions',
          subtitle: 'Active track',
          icon: Icons.calendar_today_rounded,
          onTap: () {
            context.read<SessionCubit>().loadSessions();
            Navigator.push(context, _createRoute(const SessionListPage()));
          },
        ),
        _StatCard(
          title: isAdmin || isCoach ? 'Members' : 'Feedbacks',
          subtitle: isAdmin || isCoach ? 'Directory' : 'Your voice',
          icon: isAdmin || isCoach ? Icons.people_outline_rounded : Icons.chat_bubble_outline_rounded,
          onTap: () {
            if (isAdmin || isCoach) {
              context.read<MemberCubit>().loadMembers();
              Navigator.push(context, _createRoute(const MemberListPage()));
            } else {
              context.read<FeedbackCubit>().loadFeedbacks();
              Navigator.push(context, _createRoute(const FeedbackListPage()));
            }
          },
        ),
        _StatCard(
          title: 'Bookings',
          subtitle: 'Schedule',
          icon: Icons.confirmation_number_outlined,
          onTap: () {
            context.read<BookingCubit>().loadBookings();
            Navigator.push(context, _createRoute(const BookingListPage()));
          },
        ),
        _StatCard(
          title: 'Analytics',
          subtitle: 'Reports',
          icon: Icons.analytics_outlined,
          onTap: () {
            context.read<ProgressCubit>().loadProgress();
            Navigator.push(context, _createRoute(const ProgressListPage()));
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.cardDecoration(
          color: AppTheme.primaryColor, // البطاقات باللون الأسود الكربوني
          shadows: AppTheme.elevatedShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -5,
              bottom: -5,
              child: Icon(icon, size: 60, color: Colors.white.withOpacity(0.05)),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppTheme.infoColor, size: 28),
                  const SizedBox(height: AppTheme.spacingSM),
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessList extends StatelessWidget {
  final bool isAdmin;
  final bool isCoach;

  const _QuickAccessList({required this.isAdmin, required this.isCoach});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          _QuickTile(
            title: 'Customer Feedbacks',
            icon: Icons.star_outline_rounded,
            color: AppTheme.warningColor,
            onTap: () {
              context.read<FeedbackCubit>().loadFeedbacks();
              Navigator.push(context, _createRoute(const FeedbackListPage()));
            },
          ),
          if (isAdmin) ...[
            const Divider(height: 1, indent: 20, endIndent: 20),
            _QuickTile(
              title: 'Coaches Portal',
              icon: Icons.shield_outlined,
              color: AppTheme.successColor,
              onTap: () {
                context.read<CoachCubit>().loadCoaches();
                Navigator.push(context, _createRoute(const CoachListPage()));
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _QuickTile(
              title: 'User Management',
              icon: Icons.manage_accounts_outlined,
              color: Colors.purple,
              onTap: () {
                Navigator.push(context, _createRoute(const UserManagementPage()));
              },
            ),
          ]
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuickTile({required this.title, required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
    );
  }
}

class _RecentClasses extends StatelessWidget {
  const _RecentClasses();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassTypeCubit, ClassTypeState>(
      builder: (context, state) {
        if (state is ClassTypeLoading) return const ShimmerEffect(isLoading: true, itemCount: 2);
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
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: const Icon(Icons.bolt, color: Colors.white),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? 'Class', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text('Professional Training', style: AppTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, _createRoute(const ClassTypeListPage())),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
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