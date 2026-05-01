import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/security/secure_screen_mixin.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/language_toggle.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/services/stt_service.dart';

// ---------------------------------------------------------------------------
// VoiceScreen
// ---------------------------------------------------------------------------

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key, this.sttForTesting});

  /// Injected in widget tests; production uses [sttServiceProvider].
  final SttService? sttForTesting;

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen>
    with SecureScreenMixin, TickerProviderStateMixin {
  late final SttService _stt;
  AppLanguage _language = AppLanguage.en;

  bool _initialised = false;
  bool _permissionDenied = false;
  bool _isListening = false;
  String? _transcription;

  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _stt = widget.sttForTesting ?? ref.read(sttServiceProvider);
    // Controller is created but NOT started — only runs while _isListening.
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _initStt();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    if (_isListening) _stt.stop();
    super.dispose();
  }

  Future<void> _initStt() async {
    final ok = await _stt.initialize();
    if (mounted) {
      setState(() {
        _initialised = ok;
        _permissionDenied = !ok;
      });
    }
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _stt.stop();
      if (mounted) {
        _waveCtrl.stop();
        setState(() => _isListening = false);
      }
    } else {
      if (!_initialised) await _initStt();
      if (!_initialised) return; // still not available
      setState(() {
        _isListening = true;
        _transcription = null;
      });
      _waveCtrl.repeat(reverse: true);
      await _stt.listen(
        language: _language,
        onResult: (words) {
          if (mounted) setState(() => _transcription = words);
        },
        onDone: () {
          if (mounted) {
            _waveCtrl.stop();
            setState(() => _isListening = false);
          }
        },
      );
    }
  }

  void _onLanguageChanged(AppLanguage lang) {
    setState(() => _language = lang);
    if (_isListening) {
      _stt.stop();
      _waveCtrl.stop();
      setState(() {
        _isListening = false;
        _transcription = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg,
      appBar: ParentTopBar(
        title: 'Ask Daksha',
        language: _language,
        onLanguageChanged: _onLanguageChanged,
        onBack: () => context.go('/parent/shell'),
      ),
      body: _permissionDenied
          ? _PermissionDeniedView(onRetry: _initStt)
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: _isListening
                        ? _WaveformView(controller: _waveCtrl)
                        : _EmptyState(transcription: _transcription),
                  ),
                ),
                _MicButton(
                  isListening: _isListening,
                  enabled: _initialised,
                  onTap: _toggleListen,
                ),
                const SizedBox(height: DT.bottomSafe),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.transcription});

  final String? transcription;

  @override
  Widget build(BuildContext context) {
    if (transcription != null) {
      return Padding(
        key: const Key('transcription_text'),
        padding: const EdgeInsets.all(DT.contentPad),
        child: Text(
          transcription!,
          style: DakshaTypography.body.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      key: const Key('empty_state'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎤', style: TextStyle(fontSize: 64)),
        const SizedBox(height: DT.lg),
        Text(
          'Tap to speak',
          style: DakshaTypography.body.copyWith(color: DT.muted),
        ),
      ],
    );
  }
}

class _WaveformView extends StatelessWidget {
  const _WaveformView({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('waveform'),
      mainAxisSize: MainAxisSize.min,
      children: [
        // 5 animated bars
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (i) {
                // Phase-shift each bar so they don't all move together
                final phase = (controller.value + i * 0.2) % 1.0;
                final h = 16.0 + 40.0 * _curve(phase);
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: DT.xs),
                  child: Container(
                    width: 6,
                    height: h,
                    decoration: BoxDecoration(
                      color: DT.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: DT.lg),
        Text(
          'Listening…',
          style: DakshaTypography.body.copyWith(color: DT.muted),
        ),
      ],
    );
  }

  static double _curve(double t) {
    // Simple bell curve: peaks at 0.5
    return 1.0 - (2.0 * t - 1.0) * (2.0 * t - 1.0);
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isListening,
    required this.enabled,
    required this.onTap,
  });

  final bool isListening;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        key: const Key('mic_button'),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening ? DT.error : DT.primary,
        ),
        child: Center(
          child: Text(
            isListening ? '⏹' : '🎤',
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('permission_denied'),
      child: Padding(
        padding: const EdgeInsets.all(DT.contentPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎙️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: DT.lg),
            Text(
              'Microphone permission required',
              style:
                  DakshaTypography.body.copyWith(color: DT.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DT.lg),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
