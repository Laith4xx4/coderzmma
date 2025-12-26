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
  bool _isAdmin = false;
  bool _isClient = false; // Add _isClient state

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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

  // داخل ملف صفحة Person -> _PersonState
  Future<void> _loadLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    // جلب البيانات مع وضع "layalasad" كقيمة افتراضية في حال وجودها
    String? savedUserName = prefs.getString("userName");
    String? savedFirstName = prefs.getString("firstName");
    String? savedEmail = prefs.getString("userEmail");

    setState(() {
      // تحديد الاسم الذي سيظهر: نفضل userName ثم الاسم الأول ثم الإيميل
      if (savedUserName != null && savedUserName.isNotEmpty) {
        displayName = savedUserName;
      } else if (savedFirstName != null && savedFirstName.isNotEmpty) {
        displayName = savedFirstName;
      } else if (savedEmail != null) {
        displayName = savedEmail.split('@')[0]; // يأخذ الاسم من الإيميل
      } else {
        displayName = "Member";
      }

      userRole = prefs.getString("userRole") ?? "Admin";
      _isAdmin = userRole.toLowerCase() == 'admin';
      _isClient = userRole.toLowerCase() == 'client'; // Check client role
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => current is AuthSuccess,
      listener: (context, state) {
        if (state is AuthSuccess) {
          // ✅ تحديث الاسم من الـ State في حال تغير في السيرفر
          final name = state.user.userName ?? state.user.email;
          final newRole = state.user.role;

          if (displayName != name || userRole != newRole) {
            setState(() {
              displayName = name;
              userRole = newRole;
              _isAdmin = newRole.toLowerCase() == 'admin';
              _isClient = newRole.toLowerCase() == 'client';
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: isLoading
            ? const ShimmerEffect(isLoading: true, itemCount: 8)
            : CustomScrollView(
          physics: const ClampingScrollPhysics(),
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
                    isClient: _isClient,
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
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String userRole;

  const _ProfileHeader({required this.displayName, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const _ProfileAvatar(),
              const SizedBox(height: 16),
              // ✅ عرض الاسم بخط عريض وواضح
              // داخل كود _ProfileHeader
              Text(
                displayName.trim().isEmpty ? "GUEST USER" : displayName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _RoleBadge(role: userRole),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 2),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 55,
        backgroundColor: AppTheme.primaryLight,
        // ✅ صورة افتراضية فخمة في حال عدم وجود صورة شخصية
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 50),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.infoColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.infoColor.withOpacity(0.5)),
      ),
      child: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.infoColor,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTheme.bodySmall.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: AppTheme.textLight,
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool isAdmin;
  final bool isClient;
  final void Function(Widget) onNavigate;

  const _QuickActions({
    required this.isAdmin,
    required this.isClient,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isAdmin) ...[
          _ActionCard(
            icon: Icons.people_alt_rounded,
            title: 'Manage Members',
            onTap: () => onNavigate(const MemberListPage()),
          ),
          _ActionCard(
            icon: Icons.badge_rounded,
            title: 'Manage Coaches',
            onTap: () => onNavigate(const CoachListPage()),
          ),
          _ActionCard(
            icon: Icons.category_rounded,
            title: 'Class Types',
            onTap: () => onNavigate(const ClassTypeListPage()),
          ),
        ],
        _ActionCard(
          icon: Icons.calendar_today_rounded,
          title: 'Sessions',
          onTap: () => onNavigate(const SessionListPage()),
        ),
        
        // Hide Attendance for Client
        if (!isClient)
        _ActionCard(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Attendance',
          onTap: () => onNavigate(const AttendanceListPage()),
        ),
        
        // Hide Bookings for Client
        if (!isClient)
        _ActionCard(
          icon: Icons.bookmark_added_rounded,
          title: 'Bookings',
          onTap: () => onNavigate(const BookingListPage()),
        ),
        
        // Hide Progress for Client
        if (!isClient)
        _ActionCard(
          icon: Icons.bar_chart_rounded,
          title: 'Progress Stats',
          onTap: () => onNavigate(const ProgressListPage()),
        ),

        // Hide Feedbacks for Client
        if (!isClient)
        _ActionCard(
          icon: Icons.rate_review_rounded,
          title: 'Feedbacks',
          onTap: () => onNavigate(const FeedbackListPage()),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 22),
        ),
        title: Text(title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textLight),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(color: AppTheme.errorColor.withOpacity(0.08)),
      child: ListTile(
        onTap: onLogout,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
        leading: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
        title: Text(
          'Logout Account',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge)),
      title: Text('Sign Out', style: AppTheme.heading3),
      content: Text('Are you sure you want to exit your profile?', style: AppTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}