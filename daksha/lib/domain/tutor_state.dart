import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:daksha/domain/taxonomy.dart';

part 'tutor_state.freezed.dart';

@freezed
sealed class TutorState with _$TutorState {
  const factory TutorState.idle() = TutorIdle;
  const factory TutorState.classifying(String problemText) = TutorClassifying;
  const factory TutorState.asking({
    required String problemText,
    required Topic topic,
    required String opener,
    required String problemId,
  }) = TutorAsking;
  const factory TutorState.checking({
    required String problemText,
    required Topic topic,
    required String attempt,
    required String problemId,
  }) = TutorChecking;
  const factory TutorState.hinting({
    required String problemText,
    required Topic topic,
    required int level,
    required String hint,
    required String problemId,
    required DateTime firstHintAt,
  }) = TutorHinting;
  const factory TutorState.solved({
    required String problemId,
  }) = TutorSolved;
}
