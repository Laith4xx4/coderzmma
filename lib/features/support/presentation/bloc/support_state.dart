abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportSuccess extends SupportState {
  final String message;
  SupportSuccess(this.message);
}

class SupportMessagesLoaded extends SupportState {
  final List<Map<String, dynamic>> messages;
  SupportMessagesLoaded(this.messages);
}

class SupportFailure extends SupportState {
  final String error;
  SupportFailure(this.error);
}
