import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/domain/taxonomy.dart';
import 'package:daksha/storage/database/app_database.dart';

/// Per-subject topics screen. Lists every topic the learner has touched
/// in this subject with a problem count and the last-studied relative date.
///
/// Reached by tapping a subject card on the home screen → /subject/:name.
class SubjectTopicsScreen extends ConsumerWidget {
  const SubjectTopicsScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problems = ref.watch(problemsProvider).value ?? const <Problem>[];
    final topics = ref.watch(taxonomyProvider).value ?? const <Topic>[];

    final key = name.toLowerCase();
    final mine = problems.where((p) => p.subject.toLowerCase() == key).toList();

    // Group by topic slug, tracking count and the most-recent capturedAt.
    final byTopic = <String, _TopicAgg>{};
    for (final p in mine) {
      final agg = byTopic.putIfAbsent(
        p.topic,
        () => _TopicAgg(slug: p.topic, lastAt: p.capturedAt, count: 0),
      );
      agg.count += 1;
      if (p.capturedAt.isAfter(agg.lastAt)) {
        agg.lastAt = p.capturedAt;
      }
    }
    final rows = byTopic.values.toList()
      ..sort((a, b) => b.lastAt.compareTo(a.lastAt));

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: _SubjectTopicsTopBar(
        title: name,
        onBack: () => context.pop(),
      ),
      body: rows.isEmpty
          ? _EmptyState(subject: name, onBackHome: () => context.go('/'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: DT.contentPad,
                vertical: DT.lg,
              ),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: DT.sm),
              itemBuilder: (context, i) {
                final r = rows[i];
                return _TopicRow(
                  display: _topicDisplay(topics, name, r.slug),
                  count: r.count,
                  lastAt: r.lastAt,
                  // TODO: filter history by topic. For now we just push the
                  // full history so the list is reachable from this screen.
                  onTap: () => context.push('/history'),
                );
              },
            ),
    );
  }
}

class _TopicAgg {
  _TopicAgg({required this.slug, required this.lastAt, required this.count});
  final String slug;
  DateTime lastAt;
  int count;
}

String _topicDisplay(List<Topic> topics, String subject, String slug) {
  for (final t in topics) {
    if (t.subject.toLowerCase() == subject.toLowerCase() && t.slug == slug) {
      return t.displayName;
    }
  }
  return slug.replaceAll('-', ' ');
}

String _relativeDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  return '${dt.day}/${dt.month}/${dt.year}';
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _SubjectTopicsTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _SubjectTopicsTopBar({required this.title, required this.onBack});
  final String title;
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
                padding: EdgeInsets.symmetric(
                    horizontal: DT.lg, vertical: DT.md),
                child: Icon(Icons.arrow_back_ios_new,
                    size: 20, color: DT.text),
              ),
            ),
            const SizedBox(width: DT.sm),
            Text(title, style: DakshaTypography.headingMd),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.subject, required this.onBackHome});
  final String subject;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DT.contentPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 56, color: DT.outline),
            const SizedBox(height: DT.lg),
            Text(
              'No topics studied yet in $subject',
              style: DakshaTypography.headingMd.copyWith(color: DT.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DT.lg),
            TextButton(
              onPressed: onBackHome,
              child: Text(
                'Back to home',
                style: DakshaTypography.body.copyWith(
                  color: DT.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Topic row ────────────────────────────────────────────────────────────────

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.display,
    required this.count,
    required this.lastAt,
    required this.onTap,
  });

  final String display;
  final int count;
  final DateTime lastAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DT.cardHPad),
        decoration: BoxDecoration(
          color: DT.elev1,
          borderRadius: BorderRadius.circular(DT.radius),
          border: Border.all(color: DT.outline, width: DT.bwCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    display,
                    style: DakshaTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: DT.xs),
                  Text(
                    '$count problem${count == 1 ? '' : 's'} · ${_relativeDate(lastAt)}',
                    style: DakshaTypography.caption.copyWith(color: DT.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: DT.outline),
          ],
        ),
      ),
    );
  }
}
