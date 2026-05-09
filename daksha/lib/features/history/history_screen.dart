import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/storage/database/app_database.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(problemsProvider);

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: _HistoryTopBar(onBack: () => context.pop()),
      body: switch (problemsAsync) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(DT.contentPad),
              child: Text(
                'Could not load history: $error',
                style: DakshaTypography.body.copyWith(color: DT.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        AsyncData(:final value) => value.isEmpty
            ? _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: DT.contentPad,
                  vertical: DT.lg,
                ),
                itemCount: value.length,
                separatorBuilder: (_, __) => const SizedBox(height: DT.sm),
                itemBuilder: (context, i) => _ProblemTile(
                  problem: value[i],
                  // Pass the full Problem so /problem can resume the
                  // existing conversation instead of inserting a new row
                  // and re-running the classifier on its rawText.
                  onTap: () => context.push(
                    '/problem',
                    extra: value[i],
                  ),
                  onDelete: () => _confirmAndDelete(context, ref, value[i]),
                ),
              ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Problem problem,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DT.elev1,
        title: const Text('Delete problem?', style: DakshaTypography.headingMd),
        content: const Text(
          'This will permanently remove the problem and its conversation.',
          style: DakshaTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: DakshaTypography.body.copyWith(color: DT.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: DakshaTypography.body
                    .copyWith(color: DT.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final db = await ref.read(dbProvider.future);
    await db.deleteProblem(problem.id);
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _HistoryTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _HistoryTopBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(DT.topBarH);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(DT.lg, topPadding, DT.lg, 0),
      decoration: const BoxDecoration(
        color: DT.bg,
        border: Border(bottom: BorderSide(color: DT.outline, width: 1)),
      ),
      child: SizedBox(
        height: DT.topBarH,
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: DT.lg, vertical: DT.md),
                child: Icon(Icons.arrow_back_ios_new, size: 20, color: DT.text),
              ),
            ),
            const SizedBox(width: DT.sm),
            Text('Problem History', style: DakshaTypography.headingMd),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DT.contentPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 56, color: DT.outline),
            const SizedBox(height: DT.lg),
            Text(
              'No problems yet',
              style: DakshaTypography.headingMd.copyWith(color: DT.muted),
            ),
            const SizedBox(height: DT.xs),
            Text(
              'Solved problems will appear here.',
              style: DakshaTypography.sm.copyWith(color: DT.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Problem tile ──────────────────────────────────────────────────────────────

class _ProblemTile extends StatelessWidget {
  const _ProblemTile({
    required this.problem,
    required this.onTap,
    required this.onDelete,
  });

  final Problem problem;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subjectColor = _subjectColor(problem.subject);
    final date = _formatDate(problem.capturedAt);

    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (details) => _showContextMenu(context, details.globalPosition),
      child: Container(
        padding: const EdgeInsets.all(DT.cardHPad),
        decoration: BoxDecoration(
          color: DT.elev1,
          borderRadius: BorderRadius.circular(DT.radius),
          border: Border.all(color: DT.outline, width: DT.bwCard),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject color dot
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: subjectColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: DT.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject · topic chip
                  Row(
                    children: [
                      Text(
                        problem.subject,
                        style: DakshaTypography.caption
                            .copyWith(color: subjectColor, fontWeight: FontWeight.w600),
                      ),
                      if (problem.topic.isNotEmpty &&
                          problem.topic != 'general') ...[
                        Text(
                          ' · ',
                          style: DakshaTypography.caption
                              .copyWith(color: DT.muted),
                        ),
                        Text(
                          problem.topic.replaceAll('-', ' '),
                          style: DakshaTypography.caption
                              .copyWith(color: DT.muted),
                        ),
                      ],
                      const Spacer(),
                      // Solved badge or date
                      if (problem.solved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: DT.success.withAlpha(30),
                            borderRadius: BorderRadius.circular(DT.radiusBtn),
                          ),
                          child: Text(
                            '✓ solved',
                            style: DakshaTypography.caption
                                .copyWith(color: DT.success, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: DT.xs),
                  // Problem text preview — two lines max
                  Text(
                    problem.rawText,
                    style: DakshaTypography.sm,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: DT.xs),
                  Text(
                    date,
                    style: DakshaTypography.caption.copyWith(color: DT.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: DT.sm),
            const Icon(Icons.chevron_right, size: 18, color: DT.outline),
          ],
        ),
      ),
    );
  }

  Future<void> _showContextMenu(BuildContext context, Offset globalPosition) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      color: DT.elev1,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        overlay.size.width - globalPosition.dx,
        overlay.size.height - globalPosition.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18, color: DT.error),
              const SizedBox(width: DT.sm),
              Text(
                'Delete',
                style: DakshaTypography.body.copyWith(color: DT.error),
              ),
            ],
          ),
        ),
      ],
    );
    if (selected == 'delete') onDelete();
  }

  Color _subjectColor(String subject) {
    return switch (subject.toLowerCase()) {
      'math' || 'mathematics' || 'maths' => const Color(0xFF5C6BC0),
      'physics'   => const Color(0xFF0288D1),
      'chemistry' => const Color(0xFF00897B),
      'biology'   => const Color(0xFF43A047),
      _           => DT.accent,
    };
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
