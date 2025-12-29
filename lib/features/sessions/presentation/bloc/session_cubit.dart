import 'package:bloc/bloc.dart';
import 'package:thesavage/features/sessions/data/models/create_session_model.dart';
import 'package:thesavage/features/sessions/data/models/update_session_model.dart';
import 'package:thesavage/features/sessions/domain/use_cases/create_session.dart';
import 'package:thesavage/features/sessions/domain/use_cases/delete_session.dart';
import 'package:thesavage/features/sessions/domain/use_cases/get_all_sessions.dart';
import 'package:thesavage/features/sessions/domain/use_cases/update_session.dart';
import 'package:thesavage/features/sessions/presentation/bloc/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final GetAllSessions getAllSessions;
  final CreateSession createSession;
  final UpdateSession updateSession;
  final DeleteSession deleteSession;

  SessionCubit({
    required this.getAllSessions,
    required this.createSession,
    required this.updateSession,
    required this.deleteSession,
  }) : super(SessionInitial());

  Future<void> loadSessions() async {
    emit(SessionLoading());
    try {
      final sessions = await getAllSessions.call();
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> createSessionAction(CreateSessionModel data) async {
    emit(SessionLoading());
    try {
      await createSession.call(data);
      emit(SessionOperationSuccess('Session created successfully'));
      await loadSessions();
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> updateSessionAction(int id, UpdateSessionModel data) async {
    emit(SessionLoading());
    try {
      await updateSession.call(id, data);
      emit(SessionOperationSuccess('Session updated successfully'));
      await loadSessions();
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> deleteSessionAction(int id) async {
    emit(SessionLoading());
    try {
      await deleteSession.call(id);
      emit(SessionOperationSuccess('Session deleted successfully'));
      await loadSessions();
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}

