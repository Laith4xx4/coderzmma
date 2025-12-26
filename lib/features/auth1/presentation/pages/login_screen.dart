import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa3/core/app_theme.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        // داخل BlocConsumer -> listener
        listener: (context, state) async {
          if (state is AuthSuccess) {
            print("---------------- LOGIN DEBUG INFO ----------------");
            SharedPreferences prefs = await SharedPreferences.getInstance();

            // 1. فك تشفير التوكن لاستخراج الاسم الحقيقي
            Map<String, dynamic> decodedToken = JwtDecoder.decode(state.token);

            // استخراج الاسم من الحقل القياسي في JWT الخاص بك
            String? nameFromToken = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
                ?? decodedToken['unique_name']
                ?? decodedToken['sub'];
            
            // استخراج firstName و lastName من JWT
            String? firstName = decodedToken['firstName'];
            String? lastName = decodedToken['lastName'];

            print("EXTRACTED NAME FROM TOKEN: $nameFromToken");
            print("EXTRACTED FIRST NAME: $firstName");
            print("EXTRACTED LAST NAME: $lastName");

            // 2. حفظ التوكن والمعلومات الأساسية
            await prefs.setString("token", state.token);
            await prefs.setString("userEmail", state.user.email);

            // ✅ حفظ الاسم: استخدم firstName + lastName إذا موجودان (Google Sign-In)، وإلا استخدم المنطق القديم
            String nameToSave;
            if (firstName != null && firstName.isNotEmpty && lastName != null && lastName.isNotEmpty) {
              // Google Sign-In - استخدم الاسم الكامل
              nameToSave = "${firstName} ${lastName}".trim();
            } else {
              // تسجيل دخول عادي - استخدم المنطق القديم
              nameToSave = (nameFromToken != null && nameFromToken.isNotEmpty)
                  ? nameFromToken
                  : (state.user.userName.isNotEmpty ? state.user.userName : "User");
            }

            await prefs.setString("userName", nameToSave);
            
            // حفظ firstName و lastName
            await prefs.setString("firstName", firstName ?? state.user.firstName ?? "");
            await prefs.setString("lastName", lastName ?? state.user.lastName ?? "");

            // 3. استخراج الدور (Role)
            final String realRole = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
                decodedToken['role'] ?? "Member";

            await prefs.setString("userRole", realRole);
            print("FINAL SAVED NAME: $nameToSave");
            print("--------------------------------------------------");

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AnimatedNavExample()),
              );
            }
          } else if (state is AuthFailure) {
            print("DEBUG: Login Error -> ${state.error}");
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
                _buildHeaderSection(),
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
                              _emailController.text.trim(),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("OR", style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<AuthCubit>().googleSignIn();
                          },
                          icon: const Icon(Icons.login, color: Colors.blue), // Placeholder for Google Icon
                          label: const Text(
                            'Sign in with Google',
                            style: TextStyle(
                                letterSpacing: 1.0, 
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            ),
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
    return Row(
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}