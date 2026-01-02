abstract class SupportRepository {
  Future<void> contactSupport({
    required String subject,
    required String message,
    String? email,
    String? userName,
  });

  Future<List<Map<String, dynamic>>> fetchMessages();
  Future<void> deleteMessage(int id);
}
