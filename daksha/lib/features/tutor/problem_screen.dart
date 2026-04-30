import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/domain/tutor_state.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/tutor/widgets/daksha_bubble.dart';
import 'package:daksha/features/tutor/widgets/student_bubble.dart';
import 'package:daksha/features/tutor/widgets/problem_header.dart';
import 'package:daksha/features/tutor/widgets/hint_level_dots.dart';

class ProblemScreen extends ConsumerStatefulWidget {
  const ProblemScreen({super.key, this.problemText = ''});

  final String problemText;

  @override
  ConsumerState<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.problemText.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(tutorServiceProvider.notifier)
            .startProblem(widget.problemText);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(tutorServiceProvider.notifier).submitAttempt(text);
  }

  void _onHint() {
    ref.read(tutorServiceProvider.notifier).requestHint();
  }

  @override
  Widget build(BuildContext context) {
    final tutorState = ref.watch(tutorServiceProvider);

    // Navigate to solved screen when solved
    ref.listen<TutorState>(tutorServiceProvider, (_, next) {
      if (next is TutorSolved && mounted) {
        context.go('/');
      }
    });

    final displayProblem = switch (tutorState) {
      TutorIdle() => widget.problemText,
      TutorClassifying(:final problemText) => problemText,
      TutorAsking(:final problemText) => problemText,
      TutorChecking(:final problemText) => problemText,
      TutorHinting(:final problemText) => problemText,
      TutorSolved() => widget.problemText,
    };

    final topicSubject = switch (tutorState) {
      TutorAsking(:final topic) => topic.subject,
      TutorChecking(:final topic) => topic.subject,
      TutorHinting(:final topic) => topic.subject,
      _ => 'general',
    };

    final topicName = switch (tutorState) {
      TutorAsking(:final topic) => topic.displayName,
      TutorChecking(:final topic) => topic.displayName,
      TutorHinting(:final topic) => topic.displayName,
      _ => '',
    };

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: ProblemTopBar(
        subject: topicSubject,
        topic: topicName,
        onBack: () => context.go('/'),
        onClose: () {
          ref.read(tutorServiceProvider.notifier).reset();
          context.go('/');
        },
      ),
      body: Column(
        children: [
          // Pinned problem header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DT.contentPad,
              vertical: DT.sm,
            ),
            child: ProblemHeader(problemText: displayProblem),
          ),
          // Chat area
          Expanded(
            child: _buildChatArea(tutorState),
          ),
          // Hint button
          Center(
            child: DakshaTextButton(
              label: '💡 Need a hint',
              onPressed: _canRequestHint(tutorState) ? _onHint : null,
            ),
          ),
          // Input row
          _buildInputRow(),
        ],
      ),
    );
  }

  bool _canRequestHint(TutorState state) {
    return state is TutorAsking || state is TutorHinting;
  }

  Widget _buildChatArea(TutorState state) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: DT.contentPad,
        vertical: DT.sm,
      ),
      children: _buildChatItems(state),
    );
  }

  List<Widget> _buildChatItems(TutorState state) {
    return switch (state) {
      TutorIdle() => [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(DT.lg),
              child: Text(
                'Enter a problem to get started.',
                style: DakshaTypography.sm,
              ),
            ),
          ),
        ],
      TutorClassifying() => [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(DT.lg),
              child: CircularProgressIndicator(color: DT.primary),
            ),
          ),
        ],
      TutorAsking(:final opener) => [
          DakshaBubble(text: opener),
          const SizedBox(height: DT.sm),
        ],
      TutorChecking(:final attempt, :final topic) => [
          const DakshaBubble(
            text: 'What do you think? Try working it through.',
          ),
          const SizedBox(height: DT.sm),
          StudentBubble(text: attempt),
          const SizedBox(height: DT.sm),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: DT.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          // suppress unused variable warning — topic used only for type pattern
          if (topic.subject.isEmpty) const SizedBox.shrink(),
        ],
      TutorHinting(:final hint, :final level) => [
          AmberCard(label: 'Hint $level', body: hint),
          const SizedBox(height: DT.sm),
          HintLevelDots(level: level),
          const SizedBox(height: DT.sm),
        ],
      TutorSolved() => [
          const Center(
            child: Padding(
              padding: EdgeInsets.all(DT.lg),
              child: Text('Solved!', style: DakshaTypography.headingMd),
            ),
          ),
        ],
    };
  }

  Widget _buildInputRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DT.lg,
        vertical: DT.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Your answer...'),
              onSubmitted: (_) => _onSend(),
            ),
          ),
          const SizedBox(width: DT.sm),
          GestureDetector(
            onTap: _onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: DT.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: DT.primaryFg, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
