import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/app_theme.dart'; // استيراد الثيم الجديد
import 'package:thesavage/features/auth1/presentation/bloc/auth_cubit.dart';
import 'package:thesavage/features/auth1/presentation/bloc/auth_state.dart';
import 'package:thesavage/features/auth1/presentation/pages/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController(); // Added
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _obscurePassword = true;
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.black, // Text on selected date
              surface: AppTheme.cardBackground, // Dialog background
              onSurface: Colors.white, // Text color
            ),
            dialogBackgroundColor: AppTheme.cardBackground,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!'), backgroundColor: AppTheme.successColor),
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.error}'), backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 10),
                  Text('Create Account', style: AppTheme.heading1),
                  const SizedBox(height: 8),
                  Text('Sign up to start your training journey', style: AppTheme.bodyMedium),
                  const SizedBox(height: 32),

                  _buildRegisterField(
                    _userNameController, 
                    'Username', 
                    Icons.person,
                    validator: (v) => (v == null || v.length < 3) ? 'Min 3 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // الحقول في بطاقات (Cards) كما في تصميم الـ Login
                  _buildRegisterField(_firstNameController, 'First Name', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildRegisterField(_lastNameController, 'Last Name', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildRegisterField(
                    _emailController,
                    'Email Address',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildRegisterField(
                    _passwordController,
                    'Password',
                    Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscurePassword,
                    onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildRegisterField(_phoneController, 'Phone Number', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildRegisterField(_dobController, 'Date of Birth', Icons.calendar_today_outlined, readOnly: true, onTap: _pickDate),

                  const SizedBox(height: 40),

                  // زر التسجيل الموحد
                  state is AuthLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                      : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onRegisterPressed,
                      style: AppTheme.primaryButtonStyle,
                      child: const Text('REGISTER', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isPassword = false,
        bool obscure = false,
        VoidCallback? onToggle,
        TextInputType? keyboardType,
        bool readOnly = false,
        VoidCallback? onTap,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        style: AppTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.bodySmall,
          prefixIcon: Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          suffixIcon: isPassword
              ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey), onPressed: onToggle)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? ', style: AppTheme.bodyMedium),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: const Text('Login', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        userName: _userNameController.text, 
        email: _emailController.text,
        password: _passwordController.text,
        role: 'Client', // Forced Client role for new registrations
        firstName: _firstNameController.text.isEmpty ? null : _firstNameController.text,
        lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        dateOfBirth: _selectedDate,
      );
    }
  }

  @override
  void dispose() {
    _userNameController.dispose(); // Dispose userName
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}