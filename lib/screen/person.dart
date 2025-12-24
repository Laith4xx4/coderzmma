import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:maa3/features/auth1/presentation/bloc/auth_state.dart';
import 'package:maa3/features/auth1/presentation/pages/login_screen.dart';
import 'package:maa3/widgets/ShimmerEffect.dart';

// استيراد الصفحات
import 'package:maa3/features/memberpro/presentation/pages/member_list_page.dart';
import 'package:maa3/features/bookings/presentation/pages/booking_list_page.dart';
import 'package:maa3/features/attendance/presentation/pages/attendance_list_page.dart';
import 'package:maa3/features/progress/presentation/pages/progress_list_page.dart';
import 'package:maa3/features/coaches/presentation/pages/coach_list_page.dart';
import 'package:maa3/features/sessions/presentation/pages/session_list_page.dart';
import 'package:maa3/features/feedbacks/presentation/pages/feedback_list_page.dart';
import 'package:maa3/features/classtypes/presentation/pages/class_type_list_page.dart';

class Person extends StatefulWidget {
  const Person({super.key});

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> with AutomaticKeepAliveClientMixin {
  String displayName = "User";
  String userRole = "Member";
  bool isLoading = true;

  // ✅ تخزين قيمة isAdmin
  bool _isAdmin = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // ✅ تأجيل كل العمليات لما بعد البناء الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPage();
    });
  }

  Future<void> _initPage() async {
    await _loadLocalUserData();
    if (mounted) {
      context.read<AuthCubit>().fetchUserProfile();
    }
  }

  Future<void> _loadLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final firstName = prefs.getString("firstName") ?? "";
    final lastName = prefs.getString("lastName") ?? "";
    final email = prefs.getString("userEmail") ?? "User";
    final role = prefs.getString("userRole") ?? "Member";

    setState(() {
      displayName = (firstName.isNotEmpty && firstName != "null")
          ? "$firstName $lastName".trim()
          : email;
      userRole = role;
      _isAdmin = role.toLowerCase() == 'admin';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ مطلوب لـ AutomaticKeepAliveClientMixin

    return BlocListener<AuthCubit, AuthState>(
      // ✅ الاستماع فقط عند النجاح
      listenWhen: (previous, current) => current is AuthSuccess,
      listener: (context, state) {
        if (state is AuthSuccess) {
          final fName = state.user.firstName ?? "";
          final newDisplayName = fName.isNotEmpty
              ? "$fName ${state.user.lastName ?? ""}".trim()
              : state.user.email;
          final newRole = state.user.role;

          // ✅ تحديث فقط إذا تغيرت القيم
          if (displayName != newDisplayName || userRole != newRole) {
            setState(() {
              displayName = newDisplayName;
              userRole = newRole;
              _isAdmin = newRole.toLowerCase() == 'admin';
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: isLoading
            ? const ShimmerEffect(isLoading: true, itemCount: 8)
            : CustomScrollView(
          physics: const ClampingScrollPhysics(), // ✅ أخف من BouncingScrollPhysics
          cacheExtent: 500, // ✅ تخزين مؤقت
          slivers: [
            _ProfileHeader(
              displayName: displayName,
              userRole: userRole,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _SectionHeader(title: 'DASHBOARD CONTROL'),
                  const SizedBox(height: 16),
                  _QuickActions(
                    isAdmin: _isAdmin,
                    onNavigate: _navigateTo,
                  ),
                  const SizedBox(height: 32),
                  const _SectionHeader(title: 'ACCOUNT SETTINGS'),
                  const SizedBox(height: 16),
                  _LogoutButton(onLogout: _logout),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _LogoutDialog(),
    );

    if (confirm == true && mounted) {
      context.read<AuthCubit>().logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Header منفصل مع RepaintBoundary
// ═══════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String userRole;

  const _ProfileHeader({
    required this.displayName,
    required this.userRole,
  });

  // ✅ ألوان ثابتة
  static const _bgColor = Color(0xFF1A1A1A);
  static const _gradientStart = Colors.black;
  static final _gradientEnd = Colors.grey[900]!;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: _bgColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: RepaintBoundary(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gradientStart, _gradientEnd],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // ✅ صورة البروفايل
                const _ProfileAvatar(),
                const SizedBox(height: 15),
                // ✅ اسم المستخدم
                Text(
                  displayName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                // ✅ شارة الدور
                _RoleBadge(role: userRole),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ صورة البروفايل ثابتة
// ═══════════════════════════════════════════════════════════════

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: const CircleAvatar(
        radius: 55,
        backgroundImage: AssetImage('assets/4.jpg'),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ شارة الدور
// ═══════════════════════════════════════════════════════════════

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ عنوان القسم
// ═══════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Color(0xFF9E9E9E), // ✅ لون ثابت بدلاً من Colors.grey[500]
        letterSpacing: 1.2,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ قائمة الإجراءات السريعة
// ═══════════════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  final bool isAdmin;
  final void Function(Widget) onNavigate;

  const _QuickActions({
    required this.isAdmin,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAdmin) ...[
          _ActionCard(
            icon: Icons.people_alt_outlined,
            title: 'Manage Members',
            onTap: () => onNavigate(const MemberListPage()),
          ),
          _ActionCard(
            icon: Icons.badge_outlined,
            title: 'Manage Coaches',
            onTap: () => onNavigate(const CoachListPage()),
          ),
          _ActionCard(
            icon: Icons.category_outlined,
            title: 'Class Types',
            onTap: () => onNavigate(const ClassTypeListPage()),
          ),
        ],
        _ActionCard(
          icon: Icons.calendar_month_outlined,
          title: 'Sessions',
          onTap: () => onNavigate(const SessionListPage()),
        ),
        _ActionCard(
          icon: Icons.fact_check_outlined,
          title: 'Attendance',
          onTap: () => onNavigate(const AttendanceListPage()),
        ),
        _ActionCard(
          icon: Icons.confirmation_number_outlined,
          title: 'Bookings',
          onTap: () => onNavigate(const BookingListPage()),
        ),
        _ActionCard(
          icon: Icons.insights_outlined,
          title: 'Progress Stats',
          onTap: () => onNavigate(const ProgressListPage()),
        ),
        _ActionCard(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Feedbacks',
          onTap: () => onNavigate(const FeedbackListPage()),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ بطاقة إجراء واحدة - محسّنة
// ═══════════════════════════════════════════════════════════════

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        // ✅ إزالة BoxShadow تماماً - أو استخدام border خفيف
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ زر تسجيل الخروج
// ═══════════════════════════════════════════════════════════════

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

  // ✅ لون ثابت
  static const _bgColor = Color(0x0DF44336); // 5% red

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bgColor,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(15),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 16),
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Dialog تسجيل الخروج
// ═══════════════════════════════════════════════════════════════

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Logout'),
      content: const Text('Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}