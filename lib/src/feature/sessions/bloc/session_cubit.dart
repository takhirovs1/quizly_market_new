import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/session_repository.dart';
import '../model/session_models.dart';

/// Drives one random / mistakes session run (Figma "D" / "E"): start, per-answer
/// check with immediate feedback, advance, and finish into the result view.
class SessionState extends Equatable {
  const SessionState({
    this.status = StateStatus.loading,
    this.session,
    this.index = 0,
    this.selectedOptionId,
    this.feedback,
    this.checking = false,
    this.finishing = false,
    this.result,
    this.error,
  });

  final StateStatus status;
  final SessionResponse? session;
  final int index;

  /// The option the user tapped for the current question (locked once checked).
  final String? selectedOptionId;

  /// The server's feedback for the current question (null until checked).
  final SessionAnswerResult? feedback;
  final bool checking;
  final bool finishing;
  final SessionResult? result;
  final String? error;

  SessionQuestion? get question {
    final qs = session?.questions ?? const <SessionQuestion>[];
    return index >= 0 && index < qs.length ? qs[index] : null;
  }

  int get total => session?.total ?? session?.questions.length ?? 0;
  bool get isChecked => feedback != null;
  bool get isLast => index >= total - 1;

  SessionState copyWith({
    StateStatus? status,
    SessionResponse? session,
    int? index,
    String? selectedOptionId,
    SessionAnswerResult? feedback,
    bool? checking,
    bool? finishing,
    SessionResult? result,
    String? error,
    bool clearSelection = false,
  }) => SessionState(
    status: status ?? this.status,
    session: session ?? this.session,
    index: index ?? this.index,
    selectedOptionId: clearSelection ? null : (selectedOptionId ?? this.selectedOptionId),
    feedback: clearSelection ? null : (feedback ?? this.feedback),
    checking: checking ?? this.checking,
    finishing: finishing ?? this.finishing,
    result: result ?? this.result,
    error: error,
  );

  @override
  List<Object?> get props => [status, session, index, selectedOptionId, feedback, checking, finishing, result, error];
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required this.repository}) : super(const SessionState());

  final ISessionRepository repository;
  DateTime? _questionShownAt;
  final Stopwatch _elapsed = Stopwatch();

  Future<void> start(StartSessionRequest request) async {
    emit(const SessionState(status: StateStatus.loading));
    try {
      final session = await repository.start(request);
      _elapsed
        ..reset()
        ..start();
      _questionShownAt = DateTime.now();
      emit(SessionState(status: StateStatus.success, session: session));
    } on Object catch (e, s) {
      info('SESSION START ERROR: $e $s');
      emit(SessionState(status: StateStatus.error, error: e.toString()));
    }
  }

  /// Resume an existing session by id.
  Future<void> resume(String sessionId) async {
    emit(const SessionState(status: StateStatus.loading));
    try {
      final session = await repository.get(sessionId);
      _elapsed
        ..reset()
        ..start();
      _questionShownAt = DateTime.now();
      emit(SessionState(status: StateStatus.success, session: session, index: session.currentIndex));
    } on Object catch (e, s) {
      info('SESSION RESUME ERROR: $e $s');
      emit(SessionState(status: StateStatus.error, error: e.toString()));
    }
  }

  Future<void> check(String optionId) async {
    final q = state.question;
    final session = state.session;
    if (q == null || session == null || state.isChecked || state.checking) return;
    emit(state.copyWith(selectedOptionId: optionId, checking: true));
    try {
      final spentMs = _questionShownAt == null ? null : DateTime.now().difference(_questionShownAt!).inMilliseconds;
      final result = await repository.answer(
        session.sessionId,
        SessionAnswerRequest(questionId: q.id, optionId: optionId, timeSpentMs: spentMs),
      );
      emit(state.copyWith(feedback: result, checking: false));
    } on Object catch (e, s) {
      info('SESSION ANSWER ERROR: $e $s');
      // Fall back to a client-side result so the run never stalls.
      emit(state.copyWith(checking: false, selectedOptionId: optionId));
    }
  }

  void next() {
    if (!state.isChecked) return;
    if (state.isLast) {
      finish();
      return;
    }
    _questionShownAt = DateTime.now();
    emit(state.copyWith(index: state.index + 1, clearSelection: true));
  }

  Future<void> finish() async {
    final session = state.session;
    if (session == null || state.finishing) return;
    emit(state.copyWith(finishing: true));
    try {
      _elapsed.stop();
      final result = await repository.finish(
        session.sessionId,
        SessionFinishRequest(timeSpentSec: _elapsed.elapsed.inSeconds),
      );
      emit(state.copyWith(finishing: false, result: result));
    } on Object catch (e, s) {
      info('SESSION FINISH ERROR: $e $s');
      emit(state.copyWith(finishing: false, error: e.toString()));
    }
  }
}
