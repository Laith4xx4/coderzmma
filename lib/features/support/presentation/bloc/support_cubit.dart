import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thesavage/features/support/domain/repositories/support_repository.dart';
import 'package:thesavage/features/support/presentation/bloc/support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  final SupportRepository repository;

  SupportCubit(this.repository) : super(SupportInitial());

  Future<void> submitSupportRequest({
    required String subject,
    required String message,
  }) async {
    if (subject.isEmpty || message.isEmpty) {
      emit(SupportFailure("Please fill all fields"));
      return;
    }

    emit(SupportLoading());

    try {
      await repository.contactSupport(subject: subject, message: message);
      emit(SupportSuccess("Message sent successfully!"));
    } catch (e) {
      emit(SupportFailure(e.toString()));
    }
  }


  Future<void> loadMessages() async {
    emit(SupportLoading());
    try {
      final messages = await repository.fetchMessages();
      emit(SupportMessagesLoaded(messages));
    } catch (e) {
      emit(SupportFailure(e.toString()));
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      await repository.deleteMessage(id);
      await loadMessages(); // Reload list after delete
    } catch (e) {
      emit(SupportFailure(e.toString()));
    }
  }
}
