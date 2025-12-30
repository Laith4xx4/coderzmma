import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Ensure Bloc is imported for AuthCubit
import 'package:thesavage/core/app_theme.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_state.dart';
import 'package:thesavage/features/auth1/presentation/pages/register_screen.dart'; // Navigation

import '../../../../widgets/AnimatedNavExample.dart'; // Navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            // Ambient Background
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ).blurred(blur: 80),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
              ).blurred(blur: 60),
            ),
            
            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AnimatedNavExample()),
                        );
                      } else if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                      }
                      
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo / Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Icon(Icons.bolt, size: 48, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Welcome Back",
                            style: AppTheme.heading1.copyWith(fontSize: 32),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to continue your journey",
                            style: AppTheme.bodyMedium,
                          ),
                          const SizedBox(height: 48),

                          // Inputs
                          _buildAuthField(
                            controller: _emailController,
                            hint: "Email Address",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildAuthField(
                            controller: _passwordController,
                            hint: "Password",
                            icon: Icons.lock_outline,
                            obscure: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {}, // Forgot Password Logic
                              child: const Text("Forgot Password?", style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<AuthCubit>().login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              },
                              style: AppTheme.primaryButtonStyle,
                              child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: Colors.white12)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("OR", style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(child: Divider(color: Colors.white12)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Premium Google Sign In
                          GestureDetector(
                            onTap: () {
                              context.read<AuthCubit>().googleSignIn();
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png',
                                    height: 24,
                                    errorBuilder: (context, error,
                                        stackTrace) => const Icon(
                                        Icons.g_mobiledata, color: Colors.black,
                                        size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                                },
                                child: const Text("Sign Up", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAuthField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414), // Dark Surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white), 
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// Improved Blur extension
extension WidgetModifier on Widget {
  Widget blurred({double blur = 20}) {
     return ImageFiltered(
       imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
       child: this,
     );
  }
}