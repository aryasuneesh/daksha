import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/i18n.dart';
import 'package:daksha/core/security/secure_screen_mixin.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/features/parent/widgets/mastery_bar.dart';
import 'package:daksha/features/parent/widgets/metric_card.dart';
import 'package:daksha/services/parent/digest_service.dart';
import 'package:daksha/services/tts_service.dart';
import 'package:daksha/app/providers.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key});

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen>
    with SecureScreenMixin {
  AppLanguage _language = AppLanguage.en;
  I18n? _i18n;
  bool _isSpeaking = false;
  late final TtsService _tts;

  // Stub digest — real DB wiring in Task 28.
  final WeeklyDigest _digest = const WeeklyDigest(
    minutesUsed: 47,
    streakDays: 6,
    topicsCovered: 4,
    masteryBySubject: [
      ('Math', 0.72),
      ('Physics', 0.45),
      ('Chemistry', 0.30),
      ('Biology', 0.15),
    ],
    needsAttention: ['Chemistry', 'Biology'],
  );

  @override
  void initState() {
    super.initState();
    // Cache TtsService here so tests can override via ProviderScope before
    // the widget is built. ref is available from initState in ConsumerState.
    _tts = ref.read(ttsServiceProvider);
    _loadI18n();
  }

  Future<void> _loadI18n() async {
    final i18n = await I18n.load(_language);
    if (mounted) setState(() => _i18n = i18n);
  }

  void _onLanguageChanged(AppLanguage lang) {
    setState(() => _language = lang);
    _loadI18n();
  }

  /// Builds a plain-text digest summary for TTS using the loaded i18n strings.
  String _buildSummary(I18n i18n) {
    final parts = <String>[
      i18n.get('minutes_used', n: _digest.minutesUsed),
      i18n.get('streak_days', n: _digest.streakDays),
      i18n.get('topics_covered', n: _digest.topicsCovered),
    ];
    if (_digest.needsAttention.isNotEmpty) {
      parts.add(
          '${i18n.get('needs_attention_title')}: ${_digest.needsAttention.join(', ')}');
    }
    return parts.join('. ');
  }

  Future<void> _toggleReadAloud() async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      final i18n = _i18n;
      // Build summary even without i18n — use plain number fallback so TTS
      // is never silently suppressed when the asset bundle hasn't loaded yet.
      final summary = i18n != null
          ? _buildSummary(i18n)
          : '${_digest.minutesUsed} min. '
              '${_digest.streakDays} days. '
              '${_digest.topicsCovered} topics.';
      setState(() => _isSpeaking = true);
      await _tts.speak(summary, _language);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = _i18n;

    return Scaffold(
      backgroundColor: DT.bg,
      appBar: ParentTopBar(
        title: i18n?.get('parent_view') ?? 'Parent view',
        language: _language,
        onLanguageChanged: _onLanguageChanged,
        onBack: () => context.go('/parent/gate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DT.contentPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 3-column metric cards ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    value: i18n?.get('minutes_used', n: _digest.minutesUsed) ??
                        '${_digest.minutesUsed} min',
                    label: i18n?.get('time_label') ?? 'Time',
                  ),
                ),
                const SizedBox(width: DT.sm),
                Expanded(
                  child: MetricCard(
                    value: i18n?.get('streak_days', n: _digest.streakDays) ??
                        '${_digest.streakDays} days',
                    label: i18n?.get('streak_label') ?? 'Streak',
                  ),
                ),
                const SizedBox(width: DT.sm),
                Expanded(
                  child: MetricCard(
                    value:
                        i18n?.get('topics_covered', n: _digest.topicsCovered) ??
                            '${_digest.topicsCovered} topics',
                    label: i18n?.get('topics_label') ?? 'Topics',
                  ),
                ),
              ],
            ),
            const SizedBox(height: DT.lg),

            // ── Mastery section ────────────────────────────────────────────
            Text(
              key: const Key('mastery_title'),
              i18n?.get('mastery_title') ?? 'Mastery',
              style: DakshaTypography.withScript(
                DakshaTypography.headingMd,
                i18n?.get('mastery_title') ?? 'Mastery',
              ),
            ),
            const SizedBox(height: DT.sm),
            StandardCard(
              child: Column(
                children: [
                  for (int i = 0;
                      i < _digest.masteryBySubject.length;
                      i++) ...[
                    if (i > 0) const SizedBox(height: DT.sm),
                    MasteryBar(
                      label: _digest.masteryBySubject[i].$1,
                      pct: _digest.masteryBySubject[i].$2,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DT.lg),

            // ── Caution card ───────────────────────────────────────────────
            if (_digest.needsAttention.isNotEmpty)
              CautionCard(
                label: i18n?.get('needs_attention_title') ?? 'Needs attention',
                body: _digest.needsAttention.join(', '),
              )
            else
              CautionCard(
                label: i18n?.get('needs_attention_title') ?? 'Needs attention',
                body: i18n?.get('no_attention_needed') ?? 'All topics on track',
              ),

            const SizedBox(height: DT.bottomSafe),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          DakshaOutlineButton(
            label: _isSpeaking
                ? (i18n?.get('stop_reading') ?? '⏹ Stop')
                : (i18n?.get('read_aloud') ?? '🔊 Read'),
            onPressed: _toggleReadAloud,
          ),
          PrimaryButton(
            label: i18n?.get('ask_daksha') ?? '🎤 Ask Daksha',
            onPressed: () => context.go('/parent/voice'),
          ),
        ],
      ),
    );
  }
}
