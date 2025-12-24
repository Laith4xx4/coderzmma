import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa3/core/app_theme.dart'; // استيراد الثيم الجديد
import 'package:maa3/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:maa3/features/auth1/presentation/bloc/auth_state.dart';
import 'package:maa3/features/auth1/presentation/pages/register_screen.dart';
import '../../../../widgets/AnimatedNavExample.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // استخدام السكني الفاتح جداً من الثيم
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString("token", state.token);
            await prefs.setString("userEmail", state.user.email);
            await prefs.setString("firstName", state.user.firstName ?? "");
            await prefs.setString("lastName", state.user.lastName ?? "");

            Map<String, dynamic> decodedToken = JwtDecoder.decode(state.token);
            final String realRole = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
                decodedToken['role'] ?? "Member";

            await prefs.setString("userRole", realRole);

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AnimatedNavExample()),
              );
            }
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login Failed: ${state.error}'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderSection(), // الجزء العلوي الأسود
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLG),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      _buildCustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 32),
                      state is AuthLoading
                          ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AuthCubit>().login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          },
                          style: AppTheme.primaryButtonStyle,
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildFooterSection(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // تصميم الجزء العلوي متناغم مع صفحة البروفايل
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.borderRadiusXLarge),
          bottomRight: Radius.circular(AppTheme.borderRadiusXLarge),
        ),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Icon(Icons.fitness_center_rounded, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'MAA3 MANAGEMENT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Train Like a Pro',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // حقول إدخال متجانسة مع تصميم الـ Cards
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: AppTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.bodySmall,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textLight),
            onPressed: onToggle,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? ", style: AppTheme.bodyMedium),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              child: const Text(
                "Register Now",
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}