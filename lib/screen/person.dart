import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maa3/core/app_theme.dart';
import 'package:maa3/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:maa3/features/auth1/presentation/bloc/auth_state.dart'; // تأكد من استيراد State
import 'package:maa3/features/auth1/presentation/pages/login_screen.dart';

// Import remaining pages
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

class _PersonState extends State<Person> {
  String displayName = "Loading...";
  String userRole = "Member";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 1. تحميل البيانات المخزنة محلياً أولاً
    _loadLocalUserData();

    // 2. طلب تحديث البيانات من السيرفر في الخلفية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().fetchUserProfile();
    });
  }

  Future<void> _loadLocalUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      String firstName = prefs.getString("firstName") ?? "";
      String lastName = prefs.getString("lastName") ?? "";
      String email = prefs.getString("userEmail") ?? "User";

      // التحقق من وجود الاسم محلياً
      if (firstName.isNotEmpty && firstName != "null") {
        displayName = "$firstName $lastName".trim();
      } else {
        displayName = email;
      }

      userRole = prefs.getString("userRole") ?? "Member";
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
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
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    // استخدام BlocListener للاستماع لتحديثات البيانات القادمة من السيرفر
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // عندما تنجح عملية جلب البروفايل، نحدث الواجهة فوراً
          setState(() {
            final fName = state.user.firstName ?? "";
            final lName = state.user.lastName ?? "";

            if (fName.isNotEmpty) {
              displayName = "$fName $lName".trim();
            } else {
              displayName = state.user.email;
            }

            userRole = state.user.role;
          });
        }
      },
      child: isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 30),
                decoration: BoxDecoration(
                  // بدلاً من color، نستخدم image
                  image: DecorationImage(
                    // ضع مسار صورتك هنا
                    image: const AssetImage('assets/mma3.png'),
                    // أو استخدم NetworkImage إذا كانت من الإنترنت:
                    // image: NetworkImage('https://example.com/bg.jpg'),

                    fit: BoxFit.cover, // لتغطية كامل المساحة

                    // فلتر لوني خفيف فوق الصورة ليجعل النص الأبيض واضحاً
                    colorFilter: ColorFilter.mode(
                      AppTheme.primaryColor.withOpacity(0.8), // لون الثيم بشفافية
                      BlendMode.darken, // دمج اللون مع الصورة
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        // يمكنك أيضاً وضع صورة المستخدم هنا إذا أردت
                         image: const DecorationImage(
                          image: AssetImage('assets/4.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // child: const Icon(
                      //   Icons.person,
                      //   size: 60,
                      //   color: AppTheme.primaryColor,
                      // ),
                    ),
                    const SizedBox(height: 16),

                    // الاسم
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          // ظل خفيف للنص لزيادة الوضوح
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Role
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // جعل خلفية الـ Role شبه شفافة أكثر
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Text(
                        userRole,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildQuickActions(context),
              ),

              const SizedBox(height: 24),

              // Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsCard(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: _logout,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final role = userRole.toLowerCase();
    final isAdmin = role == 'admin';
    final isCoach = role == 'coach';
    final isMember = role == 'member';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),

        // أزرار خاصة بالأدمن
        if (isAdmin) ...[
          _buildActionCard(
            icon: Icons.people,
            title: 'Manage Members',
            subtitle: 'View and manage all members',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemberListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.person_outline,
            title: 'Manage Coaches',
            subtitle: 'View and manage coaches',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoachListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.category,
            title: 'Class Types',
            subtitle: 'Manage class types',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassTypeListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // أزرار للمدرب والأدمن
        if (isAdmin || isCoach) ...[
          _buildActionCard(
            icon: Icons.calendar_today,
            title: isAdmin ? 'All Sessions' : 'My Sessions',
            subtitle: 'View and manage sessions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SessionListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.check_circle,
            title: 'Attendance',
            subtitle: 'View attendance records',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // أزرار للجميع (Booking)
        _buildActionCard(
          icon: Icons.book,
          title: isMember ? 'My Bookings' : 'Bookings',
          subtitle: 'View bookings',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingListPage()),
            );
          },
        ),
        const SizedBox(height: 12),

        // التقدم (Progress)
        if (isMember || isAdmin) ...[
          _buildActionCard(
            icon: Icons.trending_up,
            title: isMember ? 'My Progress' : 'Progress',
            subtitle: 'View progress records',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressListPage()),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // التقييمات (Feedback)
        _buildActionCard(
          icon: Icons.feedback,
          title: 'Feedbacks',
          subtitle: 'View and manage feedbacks',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackListPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF129AA6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF129AA6)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDestructive ? Colors.red : const Color(0xFF129AA6))
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF129AA6),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}