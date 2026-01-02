import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/features/support/data/datasources/support_api_service.dart';
import 'package:thesavage/features/support/domain/repositories/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportApiService apiService;

  SupportRepositoryImpl(this.apiService);

  @override
  Future<void> contactSupport({
    required String subject,
    required String message,
    String? email,
    String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Try to get token if logged in
    
    // Auto-fill user info if available and not provided
    final savedEmail = email ?? prefs.getString('userEmail');
    final savedName = userName ?? prefs.getString('userName');

    await apiService.sendSupportMessage(
      subject: subject,
      message: message,
      email: savedEmail,
      userName: savedName,
      token: token,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Unauthorized");

    final response = await apiService.fetchSupportMessages(token);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> deleteMessage(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Unauthorized");

    await apiService.deleteSupportMessage(id, token);
  }
}
