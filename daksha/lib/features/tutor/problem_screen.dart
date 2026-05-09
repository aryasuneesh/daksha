import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/domain/socratic_tools.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/domain/tutor_state.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/tutor/widgets/daksha_bubble.dart';
import 'package:daksha/features/tutor/widgets/student_bubble.dart';
import 'package:daksha/features/tutor/widgets/problem_header.dart';
import 'package:daksha/features/tutor/widgets/hint_level_dots.dart';
import 'package:daksha/storage/database/app_database.dart';

class ProblemScreen extends ConsumerStatefulWidget {
  const ProblemScreen({
    super.key,
    this.problemText = '',
    this.resumed,
  });

  /// Raw text shown in the header. For a new problem this is the only
  /// thing we have; for a resumed one it's [resumed?.rawText].
  final String problemText;

  /// When non-null we re-enter an existing problem. The classifier and
  /// opener generation are skipped — the chat hydrates from the DB.
  final Problem? resumed;

  @override
  ConsumerState<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends ConsumerState<ProblemScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _started = false;
  int _lastChatItemCount = 0;

  @override
  void initState() {
    super.initState();
    // Reset any stale tutor state from a previous problem before this
    // screen starts its own. Without this, opening problem B from history
    // while problem A's state is still in memory would briefly route the
    // first sent message at A's problemId.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(tutorServiceProvider.notifier).reset();
      }
    });
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

  void _safeBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final engineAsync = ref.watch(engineProvider);
    final dbAsync = ref.watch(dbProvider);
    final taxonomyAsync = ref.watch(taxonomyProvider);

    final allReady =
        engineAsync.hasValue && dbAsync.hasValue && taxonomyAsync.hasValue;

    if (!allReady) {
      final firstError =
          engineAsync.error ?? dbAsync.error ?? taxonomyAsync.error;
      return Scaffold(
        backgroundColor: DT.bg,
        appBar: ProblemTopBar(
          subject: '',
          topic: '',
          onBack: _safeBack,
          onClose: _safeBack,
        ),
        body: SafeArea(
          child: Center(
            child: firstError != null
                ? Padding(
                    padding: const EdgeInsets.all(DT.contentPad),
                    child: Text(
                      'Failed to load model: $firstError',
                      style: DakshaTypography.body.copyWith(color: DT.error),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: DT.lg),
                      Text('Warming up Daksha…',
                          style: DakshaTypography.sm),
                    ],
                  ),
          ),
        ),
      );
    }

    final tutorState = ref.watch(tutorServiceProvider);

    // Show a verdict dialog when the service emits a fire-once event. Done
    // via ref.listen (not ref.watch) so we react to *transitions*, not every
    // rebuild — otherwise a rebuild while the dialog is open would re-show
    // it. We clear the provider after consuming so the dialog doesn't
    // re-fire on the next listener registration.
    ref.listen<TutorVerdictEvent?>(tutorVerdictEventProvider, (prev, next) {
      if (next == null || !mounted) return;
      _showVerdictDialog(next);
      ref.read(tutorVerdictEventProvider.notifier).state = null;
    });

    // Trigger startProblem or resumeProblem exactly once per screen instance.
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final notifier = ref.read(tutorServiceProvider.notifier);
        final resumed = widget.resumed;
        if (resumed != null) {
          // Reconstruct the topic from the stored slug. If the slug isn't
          // in the current taxonomy (e.g. taxonomy.json updated since the
          // problem was captured), fall back to a best-effort Topic so the
          // header still renders something readable.
          final topics = taxonomyAsync.requireValue;
          final topic = topics.firstWhere(
            (t) => t.subject == resumed.subject && t.slug == resumed.topic,
            orElse: () => Topic(
              subject: resumed.subject,
              slug: resumed.topic,
              displayName: resumed.topic.replaceAll('-', ' '),
            ),
          );
          await notifier.resumeProblem(
            problemId: resumed.id,
            problemText: resumed.rawText,
            topic: topic,
          );
        } else if (widget.problemText.isNotEmpty) {
          await notifier.startProblem(widget.problemText);
        }
      });
    }

    final displayProblem = switch (tutorState) {
      TutorIdle() => widget.problemText,
      TutorClassifying(:final problemText) => problemText,
      TutorAsking(:final problemText) => problemText,
      TutorChecking(:final problemText) => problemText,
      TutorHinting(:final problemText) => problemText,
      TutorSolved(:final problemText) => problemText,
    };

    final topicSubject = switch (tutorState) {
      TutorAsking(:final topic)   => topic.subject,
      TutorChecking(:final topic) => topic.subject,
      TutorHinting(:final topic)  => topic.subject,
      TutorSolved(:final topic)   => topic.subject,
      TutorClassifying()          => 'Identifying…',
      _                           => widget.resumed?.subject ?? '',
    };

    final topicName = switch (tutorState) {
      TutorAsking(:final topic)   => topic.displayName,
      TutorChecking(:final topic) => topic.displayName,
      TutorHinting(:final topic)  => topic.displayName,
      TutorSolved(:final topic)   => topic.displayName,
      _                           => widget.resumed?.topic.replaceAll('-', ' ') ?? '',
    };

    // Resolve the active problemId from either the resumed problem (most
    // reliable, available before any inference completes) or the current
    // tutor state.
    final problemId = widget.resumed?.id ??
        switch (tutorState) {
          TutorAsking(:final problemId) => problemId,
          TutorChecking(:final problemId) => problemId,
          TutorHinting(:final problemId) => problemId,
          TutorSolved(:final problemId) => problemId,
          _ => null,
        };

    final isSolved =
        (widget.resumed?.solved ?? false) || tutorState is TutorSolved;
    final isThinking =
        tutorState is TutorChecking || tutorState is TutorClassifying;
    // Disable input while inference is in flight — but never disable just
    // because the problem is "solved". The student may have a follow-up
    // doubt, and locking them out of the textbox is part of the bug we're
    // fixing.
    final canInput = !isThinking && problemId != null;

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: ProblemTopBar(
        subject: topicSubject,
        topic: topicName,
        solved: isSolved,
        onBack: _safeBack,
        onClose: () {
          ref.read(tutorServiceProvider.notifier).reset();
          _safeBack();
        },
      ),
      body: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.30,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: DT.contentPad,
                vertical: DT.sm,
              ),
              child: ProblemHeader(
                problemText: displayProblem,
                label: topicName.isNotEmpty ? topicName : 'Problem',
              ),
            ),
          ),
          Expanded(
            child: problemId == null
                ? const _StartingPlaceholder()
                : _ChatArea(
                    problemId: problemId,
                    isThinking: isThinking,
                    scrollController: _scrollController,
                    onItemCountChange: _maybeAutoScroll,
                  ),
          ),
          if (tutorState is TutorHinting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DT.xs),
              child: HintLevelDots(level: tutorState.level),
            ),
          Center(
            child: _HintButton(
              isLoading: _isHintLoading(tutorState),
              onPressed: (_canRequestHint(tutorState) &&
                      !_isHintLoading(tutorState))
                  ? _onHint
                  : null,
            ),
          ),
          _buildInputRow(canInput),
        ],
      ),
    );
  }

  void _maybeAutoScroll(int n) {
    if (n != _lastChatItemCount) {
      _lastChatItemCount = n;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool _canRequestHint(TutorState state) {
    return state is TutorAsking || state is TutorHinting;
  }

  bool _isHintLoading(TutorState state) {
    return switch (state) {
      TutorAsking(:final isHintLoading)   => isHintLoading,
      TutorHinting(:final isHintLoading)  => isHintLoading,
      TutorChecking(:final isHintLoading) => isHintLoading,
      TutorSolved(:final isHintLoading)   => isHintLoading,
      TutorClassifying(:final isHintLoading) => isHintLoading,
      TutorIdle(:final isHintLoading)     => isHintLoading,
    };
  }

  /// Shows a modal dialog acknowledging a graded attempt. Fired once per
  /// verdict event from the service (see the [ref.listen] in [build]).
  ///
  /// The "close" verdict deliberately never reaches here — see TutorService
  /// for the rationale (close = "almost there, keep guiding", not a final
  /// judgement worth interrupting the chat for).
  void _showVerdictDialog(TutorVerdictEvent event) {
    final isCorrect = event.verdict == AttemptVerdict.correct;
    final title = isCorrect ? 'Solved!' : 'Not quite yet';
    final emoji = isCorrect ? '🎉' : '💭';
    final message = isCorrect
        ? 'Great job! You can ask follow-up questions or start a new problem.'
        : 'Your answer wasn\'t right, but keep going — try again, ask a question, or use a hint.';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: DT.sm),
            Text(title),
          ],
        ),
        content: Text(message, style: DakshaTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow(bool canInput) {
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
              enabled: canInput,
              decoration: const InputDecoration(
                hintText: 'Type your answer or ask a question…',
              ),
              onSubmitted: canInput ? (_) => _onSend() : null,
            ),
          ),
          const SizedBox(width: DT.sm),
          GestureDetector(
            onTap: canInput ? _onSend : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: canInput ? DT.primary : DT.muted,
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

/// Streams the conversation log from the DB and renders it as bubbles.
/// Switching the chat to a DB-backed source is what makes resume work — the
/// previous design rebuilt the bubble list from in-memory [TutorState] alone,
/// so reopening a problem started from scratch.
class _ChatArea extends ConsumerWidget {
  const _ChatArea({
    required this.problemId,
    required this.isThinking,
    required this.scrollController,
    required this.onItemCountChange,
  });

  final String problemId;
  final bool isThinking;
  final ScrollController scrollController;
  final void Function(int) onItemCountChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider).valueOrNull;
    if (db == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final turnsAsync =
        ref.watch(turnsProvider((db: db, problemId: problemId)));

    return turnsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(DT.contentPad),
          child: Text(
            'Could not load conversation: $e',
            style: DakshaTypography.body.copyWith(color: DT.error),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (turns) {
        // Append a thinking spinner while inference is in flight so the
        // student sees that something is happening after they hit send.
        final tail = isThinking ? 1 : 0;
        final itemCount = turns.length + tail;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onItemCountChange(itemCount);
        });

        if (itemCount == 0) {
          return const _StartingPlaceholder();
        }

        return ListView.separated(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: DT.contentPad,
            vertical: DT.sm,
          ),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: DT.sm),
          itemBuilder: (context, i) {
            if (i >= turns.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(DT.sm),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: DT.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }
            final t = turns[i];
            if (t.role == 'student') {
              return StudentBubble(text: t.content);
            }
            return DakshaBubble(text: t.content);
          },
        );
      },
    );
  }
}

/// "Need a hint" CTA. Renders a 16x16 spinner alongside the label while a
/// hint request is in flight; [onPressed] is null in that state so the button
/// is fully disabled and tap-spamming can't queue concurrent inferences.
/// Spinner styling matches home_screen's _StatusLine for visual consistency.
class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return DakshaTextButton(
        label: '💡 Need a hint',
        onPressed: onPressed,
      );
    }
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(
        foregroundColor: DT.accent,
        padding: const EdgeInsets.all(DT.sm),
        minimumSize: const Size(DT.minTouch, DT.minTouch),
        textStyle: DakshaTypography.sm.copyWith(fontWeight: FontWeight.w400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: DT.sm),
          Text(
            'Thinking…',
            style: DakshaTypography.sm.copyWith(color: DT.muted),
          ),
        ],
      ),
    );
  }
}

class _StartingPlaceholder extends StatelessWidget {
  const _StartingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(DT.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DT.primary),
            SizedBox(height: DT.md),
            Text('Reading your problem…', style: DakshaTypography.sm),
          ],
        ),
      ),
    );
  }
}
