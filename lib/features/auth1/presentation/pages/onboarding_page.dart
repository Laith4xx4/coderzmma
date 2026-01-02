import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/auth1/presentation/pages/login_screen.dart';
import 'package:thesavage/features/auth1/presentation/pages/register_screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "icon": Icons.admin_panel_settings_rounded, // Using rounded icons for cleaner look
      "title": "Your Gym,\nYour Role",
      "highlight": "Your Role",
      "desc": "Whether you're an Admin, Coach, or Member, manage your profile and permissions with ease.",
      "bg": "assets/images/onboarding1.jpg", // Placeholder - will use colors/gradients if asset missing
    },
    {
      "icon": Icons.calendar_month_rounded,
      "title": "Book Classes\nInstantly",
      "highlight": "Instantly",
      "desc": "Secure your spot in seconds. Browse the schedule and never miss a session again.",
      "bg": "assets/images/onboarding2.jpg",
    },
    {
      "icon": Icons.trending_up_rounded,
      "title": "Track Your\nGains",
      "highlight": "Gains",
      "desc": "Visualize your attendance streaks and personal bests to stay motivated.",
      "bg": "assets/images/onboarding3.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          
          // Top Navigation (Skip)
          Positioned(
            top: 50,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primaryColor),
                ),
                TextButton(
                  onPressed: _finishOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text("Skip", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.backgroundColor.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    children: List.generate(_pages.length, (index) => _buildIndicator(index == _currentPage)),
                  ),
                  const SizedBox(height: 32),
                  
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: AppTheme.primaryButtonStyle.copyWith(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) return const Color(0xFF16cc5f);
                          return AppTheme.primaryColor;
                        }),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_currentPage == _pages.length - 1 ? "Get Started" : "Next", 
                               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.backgroundColor)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: AppTheme.backgroundColor),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                      GestureDetector(
                        onTap: () async {
                           await _markOnboardingSeen();
                           if (context.mounted) {
                             Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                           }
                        },
                        child: const Text("Log In", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image / Gradient
        Container(
           color: AppTheme.backgroundColor, // Fallback
           child: Stack(
             fit: StackFit.expand,
             children: [
               // Placeholder Pattern if image fails
               Opacity(
                 opacity: 0.3,
                 child: Image.asset(
                   data['bg'], 
                   fit: BoxFit.cover,
                   errorBuilder: (c,e,s) => Container(
                     decoration: const BoxDecoration(
                       gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A3224), Color(0xFF112117)])
                     ),
                   ),
                 ),
               ),
               // Gradient Overlay
               Container(
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     begin: Alignment.topCenter,
                     end: Alignment.bottomCenter,
                     colors: [
                       AppTheme.backgroundColor.withOpacity(0.3),
                       AppTheme.backgroundColor.withOpacity(0.9),
                       AppTheme.backgroundColor,
                     ],
                     stops: const [0.0, 0.6, 1.0]
                   ),
                 ),
               )
             ],
           ),
        ),
        
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Icon(data['icon'], color: AppTheme.primaryColor, size: 30),
              ),
              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  children: _parseTitle(data['title'], data['highlight']),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data['desc'],
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.5),
              ),
              const Spacer(), // Pushes content up to leave room for bottom controls
              const SizedBox(height: 140), // Height of bottom controls
            ],
          ),
        )
      ],
    );
  }

  List<TextSpan> _parseTitle(String title, String highlight) {
    // Simple parser to highlight one part
    final parts = title.split(highlight);
    if (parts.length < 2) return [TextSpan(text: title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Lexend'))];
    
    return [
      TextSpan(text: parts[0], style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Lexend', height: 1.1)),
      TextSpan(text: highlight, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontFamily: 'Lexend', height: 1.1)),
      TextSpan(text: parts[1], style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Lexend', height: 1.1)),
    ];
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: isActive ? 32 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
        boxShadow: isActive ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 8)] : [],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    await _markOnboardingSeen();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())); // Or Login
    }
  }

  Future<void> _markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }
}
