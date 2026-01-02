import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/core/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thesavage/features/support/presentation/bloc/support_cubit.dart';
import 'package:thesavage/features/support/presentation/bloc/support_state.dart';
import 'package:thesavage/features/support/data/datasources/support_api_service.dart';
import 'package:thesavage/features/support/data/repositories/support_repository_impl.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupportCubit(
        SupportRepositoryImpl(SupportApiService()),
      ),
      child: const SupportView(),
    );
  }
}

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch phone')));
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    // For WhatsApp, usually need to remove leading 0 and add country code if possible, or just try as is.
    // Assuming 0777306481 is Jordanian (Example), so +962777306481
    // But let's try direct link first.
    // Replace leading 0 with 962 (Jordan) if applicable, or ask user.
    // For now, I will use the number as provided, but often WhatsApp requires country code without +.
    // Let's assume Jordan (+962) based on typical 077 prefix.
    String formatted = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      formatted = '962${phoneNumber.substring(1)}';
    }
    
    final Uri url = Uri.parse("https://wa.me/$formatted");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('TECHNICHAL SUPPORT', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryDark,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<SupportCubit, SupportState>(
        listener: (context, state) {
          if (state is SupportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.successColor),
            );
            _subjectController.clear();
            _messageController.clear();
          } else if (state is SupportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: AppTheme.errorColor),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('WE ARE HERE TO HELP', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('How can we assist you?', style: AppTheme.heading2),
                const SizedBox(height: 32),

                // Direct Contact Cards
                Row(
                  children: [
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.phone_in_talk_rounded,
                        title: 'Call Us',
                        subTitle: '0777306481',
                        color: AppTheme.primaryColor,
                        onTap: () => _makePhoneCall('0777306481'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.message_rounded, // Use a generic message icon if WhatsApp not available or standard
                        title: 'WhatsApp',
                        subTitle: 'Chat Now',
                        color: const Color(0xFF25D366), // WhatsApp Green
                        onTap: () => _openWhatsApp('0788334761'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Text('SEND A MESSAGE', style: TextStyle(color: AppTheme.textLight, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                // Message Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration(),
                  child: Column(
                    children: [
                      _buildTextField(_subjectController, 'Subject', Icons.title),
                      const SizedBox(height: 16),
                      _buildTextField(_messageController, 'Message', Icons.edit_note, maxLines: 5),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: state is SupportLoading
                            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                            : ElevatedButton(
                                onPressed: () {
                                  context.read<SupportCubit>().submitSupportRequest(
                                    subject: _subjectController.text,
                                    message: _messageController.text,
                                  );
                                },
                                style: AppTheme.primaryButtonStyle,
                                child: const Text('SEND REQUEST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                      ),
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

  Widget _ContactCard({required IconData icon, required String title, required String subTitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subTitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textLight),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: AppTheme.backgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
