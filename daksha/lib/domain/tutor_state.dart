import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/taxonomy.dart';

part 'tutor_state.freezed.dart';

/// Fire-once verdict event published whenever a graded attempt is judged.
///
/// Lives outside [TutorState] because the pop-up is an *event*, not state:
/// it fires once on transition, not on every rebuild. The UI listens via
/// `tutorVerdictEventProvider` (see providers.dart), shows a dialog, and
/// then clears the value so a re-render doesn't re-show it.
///
/// `==` is intentionally identity-based: two events with identical verdict
/// + explanation must still both fire (e.g. student attempts "x = 5" twice
/// in a row, both wrong — the parent listener should pop up twice).
class TutorVerdictEvent {
  final AttemptVerdict verdict;
  final String explanation;
  final DateTime at;
  TutorVerdictEvent({
    required this.verdict,
    required this.explanation,
    DateTime? at,
  }) : at = at ?? DateTime.now();
}

@freezed
sealed class TutorState with _$TutorState {
  const factory TutorState.idle({
    @Default(false) bool isHintLoading,
  }) = TutorIdle;
  const factory TutorState.classifying(
    String problemText, {
    @Default(false) bool isHintLoading,
  }) = TutorClassifying;
  const factory TutorState.asking({
    required String problemText,
    required Topic topic,
    required String opener,
    required String problemId,
    @Default(false) bool isHintLoading,
  }) = TutorAsking;
  const factory TutorState.checking({
    required String problemText,
    required Topic topic,
    required String attempt,
    required String problemId,
    // The Socratic opener from TutorAsking — carried through so the chat
    // can display the full conversation history (opener → attempt → spinner).
    required String opener,
    @Default(false) bool isHintLoading,
  }) = TutorChecking;
  const factory TutorState.hinting({
    required String problemText,
    required Topic topic,
    required int level,
    required String hint,
    required String problemId,
    required DateTime firstHintAt,
    // Opener carried through for consistent conversation display.
    required String opener,
    @Default(false) bool isHintLoading,
  }) = TutorHinting;
  const factory TutorState.solved({
    required String problemId,
    // Conversation context retained so the student can keep chatting after
    // the problem is marked solved (asking follow-ups, clarifications, etc.).
    // Without these the service would have no problemText/topic to feed
    // [SocraticService.judgeOrReply] from a post-solve message.
    required String problemText,
    required Topic topic,
    required String opener,
    @Default(false) bool isHintLoading,
  }) = TutorSolved;
}
