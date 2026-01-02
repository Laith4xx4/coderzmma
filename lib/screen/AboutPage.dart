import 'package:flutter/material.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/support/presentation/pages/support_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _animateIn(
                    delay: 100,
                    child: _buildSectionHeader('OUR MISSION'),
                  ),
                  const SizedBox(height: 16),
                  _animateIn(
                    delay: 200,
                    child: _buildInfoCard(
                      title: 'Empowering Warriors',
                      content: 'Providing professional management tools for MMA athletes and trainers to track progress, manage sessions, and elevate performance.',
                      icon: Icons.shield_rounded,
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  _animateIn(
                    delay: 300,
                    child: _buildStatsRow(),
                  ),

                  const SizedBox(height: 32),
                  
                  _animateIn(
                    delay: 400,
                    child: _buildSectionHeader('CONTACT US'),
                  ),
                  const SizedBox(height: 16),
                  
                  _animateIn(
                    delay: 500,
                    child: _buildInfoCard(
                      title: 'Support Team',
                      content: 'Available 24/7 for technical assistance and feature requests.',
                      icon: Icons.headset_mic_rounded,
                      isSmall: true, 
                    ),
                  ),
                   const SizedBox(height: 12),
                  _animateIn(
                    delay: 600,
                    child: _buildInfoCard(
                      title: 'Version',
                      content: '1.0.0 (Beta)',
                      icon: Icons.verified_rounded,
                      isSmall: true,
                    ),
                  ),

                  const SizedBox(height: 40),
                  _animateIn(
                    delay: 600,
                    child: _buildContactButton(context),
                  ),

                  const SizedBox(height: 40),
                  _animateIn(
                    delay: 700,
                    child: Center(
                      child: Column(
                        children: [
                          const Text('Developed by', 
                            style: TextStyle(color: AppTheme.textLight, fontSize: 10, letterSpacing: 1)
                          ),
                          const SizedBox(height: 4),
                          const Text('LAITH YASSEN', 
                            style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)
                          ),
                          const SizedBox(height: 4),
                          const Text('0777306481', 
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 24),
                          const Text('MAA TECH SOLUTIONS', 
                            style: TextStyle(color: AppTheme.textLight, letterSpacing: 2, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 91),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.backgroundColor,
      iconTheme: const IconThemeData(color: Colors.white), // Ensure back button is white
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradiente), // Dark gradient
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.info_outline_rounded, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                'ABOUT APP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'MAA MANAGEMENT SYSTEM',
                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.bodySmall.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: AppTheme.textLight,
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon, bool isSmall = false}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: AppTheme.cardDecoration(),
      child: Row(
        crossAxisAlignment: isSmall ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.heading3.copyWith(fontSize: 18)),
                if (!isSmall) const SizedBox(height: 8),
                Text(content, style: AppTheme.bodyMedium.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('100+', 'Athletes', Icons.people_outline)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('50+', 'Classes', Icons.sports_mma_outlined)),
      ],
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: AppTheme.cardDecoration(
        // color: AppTheme.cardBackground, 
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 28),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 28, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage())); 
        },
        style: AppTheme.primaryButtonStyle,
        icon: const Icon(Icons.support_agent_rounded, color: Colors.black),
        label: const Text('CONTACT SUPPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _animateIn({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}