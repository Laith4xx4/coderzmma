import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/core/role_helper.dart';
import 'package:maa3/widgets/carousl.dart';
import '../widgets/ShimmerEffect.dart';

// Cubits & Pages Imports
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

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  String? userRole;
  bool isRoleLoading = true;

  // ✅ تخزين القيم مرة واحدة لمنع إعادة الحساب
  late bool _isAdmin;
  late bool _isCoach;
  late bool _isMember;

  @override
  bool get wantKeepAlive => true; // ✅ الحفاظ على الحالة

  @override
  void initState() {
    super.initState();
    // ✅ تأخير التحميل لما بعد البناء الأول
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
      setState(() {
        userRole = role;
        isRoleLoading = false;
      });
    }
  }

  void _loadInitialData() {
    // ✅ تحميل البيانات بدون await لعدم حظر الـ UI
    context.read<SessionCubit>().loadSessions();
    context.read<ClassTypeCubit>().loadClassTypes();
    if (_isAdmin) {
      context.read<MemberCubit>().loadMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ مطلوب لـ AutomaticKeepAliveClientMixin

    if (isRoleLoading) {
      return const Scaffold(
        body: ShimmerEffect(isLoading: true, itemCount: 6),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: RefreshIndicator(
        color: const Color(0xFF1A1A1A),
        onRefresh: () async => _loadInitialData(),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(), // ✅ أخف من BouncingScrollPhysics
          cacheExtent: 500, // ✅ تخزين مؤقت للعناصر
          slivers: [
            _buildModernHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ RepaintBoundary لعزل إعادة الرسم
                    const RepaintBoundary(child: Carousl()),
                    const SizedBox(height: 24),
                    const _SectionHeader(title: 'Dashboard Overview'),
                    _StatisticsGrid(
                      isAdmin: _isAdmin,
                      isCoach: _isCoach,
                      isMember: _isMember,
                    ),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: 'Quick Management'),
                    _QuickAccessList(isAdmin: _isAdmin, isCoach: _isCoach),
                    const SizedBox(height: 32),
                    const _SectionHeader(title: 'Live Classes'),
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
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1A1A1A),
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              userRole?.toUpperCase() ?? 'USER',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        // ✅ إزالة الأيقونة الكبيرة في الخلفية (تسبب lag)
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: Colors.white10, // ✅ قيمة ثابتة
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
        )
      ],
    );
  }
}

// ✅ Widget منفصل مع const constructor
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A1A),
        ),
      ),
    );
  }
}

// ✅ شبكة الإحصائيات كـ Widget منفصل
class _StatisticsGrid extends StatelessWidget {
  final bool isAdmin;
  final bool isCoach;
  final bool isMember;

  const _StatisticsGrid({
    required this.isAdmin,
    required this.isCoach,
    required this.isMember,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.2,
        children: [
          _StatCard(
            title: 'Sessions',
            icon: Icons.event_available_rounded,
            onTap: () {
              context.read<SessionCubit>().loadSessions();
              Navigator.push(
                context,
                _createRoute(const SessionListPage()),
              );
            },
          ),
          _StatCard(
            title: isAdmin || isCoach ? 'Members' : 'Feedbacks',
            icon: isAdmin || isCoach
                ? Icons.people_outline_rounded
                : Icons.rate_review_outlined,
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
            icon: Icons.local_activity_outlined,
            onTap: () {
              context.read<BookingCubit>().loadBookings();
              Navigator.push(context, _createRoute(const BookingListPage()));
            },
          ),
          _StatCard(
            title: 'Analytics',
            icon: Icons.stacked_line_chart_rounded,
            onTap: () {
              context.read<ProgressCubit>().loadProgress();
              Navigator.push(context, _createRoute(const ProgressListPage()));
            },
          ),
        ],
      ),
    );
  }
}

// ✅ بطاقة إحصائيات محسّنة
class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(28),
      // ✅ إزالة الـ boxShadow - سبب رئيسي للـ Lag
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ قائمة الوصول السريع كـ Widget منفصل
class _QuickAccessList extends StatelessWidget {
  final bool isAdmin;
  final bool isCoach;

  const _QuickAccessList({required this.isAdmin, required this.isCoach});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuickTile(
            title: 'Client Feedbacks',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {
              context.read<FeedbackCubit>().loadFeedbacks();
              Navigator.push(context, _createRoute(const FeedbackListPage()));
            },
          ),
          if (isAdmin) ...[
            const Divider(height: 1, indent: 60),
            _QuickTile(
              title: 'Coach Directory',
              icon: Icons.assignment_ind_outlined,
              onTap: () {
                context.read<CoachCubit>().loadCoaches();
                Navigator.push(context, _createRoute(const CoachListPage()));
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

  const _QuickTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
    );
  }
}

// ✅ الكلاسات الأخيرة مع buildWhen للتحكم بإعادة البناء
class _RecentClasses extends StatelessWidget {
  const _RecentClasses();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassTypeCubit, ClassTypeState>(
      // ✅ منع إعادة البناء غير الضرورية
      buildWhen: (previous, current) {
        return current is ClassTypeLoading || current is ClassTypesLoaded;
      },
      builder: (context, state) {
        if (state is ClassTypeLoading) {
          return const ShimmerEffect(isLoading: true, itemCount: 2);
        }
        if (state is ClassTypesLoaded) {
          final items = state.classTypes.take(2).toList();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) => _ClassItem(item: item)).toList(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // ✅ إزالة الـ shadow أو تخفيفها جداً
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'New Class',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Standard Session',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              _createRoute(const ClassTypeListPage()),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF0F2F5),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'View',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

// ✅ Route مُحسّن بدون animation ثقيلة
Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}