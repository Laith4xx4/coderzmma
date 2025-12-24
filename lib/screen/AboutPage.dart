import 'package:flutter/material.dart';
import 'package:maa3/core/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar أسود فخم
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('MAA MANAGEMENT',
                  style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, fontSize: 16)),
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: Center(
                  child: Icon(Icons.sports_mma, size: 100, color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              child: Column(
                children: [
                  const SizedBox(height: AppTheme.spacingLG),

                  _animateIn(
                    delay: 100,
                    child: _buildMainInfo(),
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  _animateIn(
                    delay: 300,
                    child: _buildModernCard(
                      title: 'Our Mission',
                      content: 'Providing professional management tools for MMA warriors and trainers.',
                      icon: Icons.shield,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingMD),

                  _animateIn(
                    delay: 500,
                    child: _buildStatsRow(),
                  ),

                  const SizedBox(height: AppTheme.spacingXL),

                  _buildFooter(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      children: [
        const Text('PREMIUM SYSTEM',
            style: TextStyle(color: AppTheme.textLight, letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Elevating The Game', style: AppTheme.heading2),
        const SizedBox(height: 16),
        Container(height: 2, width: 40, color: AppTheme.primaryColor),
      ],
    );
  }

  Widget _buildModernCard({required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.primaryColor),
          const SizedBox(height: AppTheme.spacingMD),
          Text(title, style: AppTheme.heading3),
          const SizedBox(height: AppTheme.spacingSM),
          Text(content, textAlign: TextAlign.center, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('100+', 'Athletes')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('50+', 'Classes')),
      ],
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: AppTheme.cardDecoration(color: AppTheme.primaryColor),
      child: Column(
        children: [
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text('MAA TECH SOLUTIONS', style: TextStyle(color: AppTheme.textLight, letterSpacing: 2, fontSize: 10)),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _animateIn({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 40 * (1 - value)), child: child),
        );
      },
      child: child,
    );
  }
}