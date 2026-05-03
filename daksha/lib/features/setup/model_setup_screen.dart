import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:go_router/go_router.dart';

import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/buttons.dart';

// ── Model download constants ──────────────────────────────────────────────────

/// HuggingFace URL for the Gemma 4 E4B instruction-tuned LiteRT-LM model.
///
/// Blob page: https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm/blob/main/gemma-4-E4B-it.litertlm
///
/// Note: this repo may be gated. If downloads return 401/403, accept the
/// model terms on HuggingFace and pass your token to
/// [FlutterGemma.initialize(huggingFaceToken: 'hf_...')] in main.dart.
const _kModelUrl =
    'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm'
    '/resolve/main/gemma-4-E4B-it.litertlm';

const _kModelSizeLabel = '3.65 GB';

// ── Screen ────────────────────────────────────────────────────────────────────

/// First-launch screen that downloads and installs the Gemma 4 on-device model.
///
/// Shown only when [FlutterGemma.hasActiveModel] returns false.
/// Navigates to ['/'] automatically once the download completes successfully.
class ModelSetupScreen extends StatefulWidget {
  const ModelSetupScreen({super.key});

  @override
  State<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

enum _SetupState { idle, downloading, done, error }

class _ModelSetupScreenState extends State<ModelSetupScreen> {
  _SetupState _state = _SetupState.idle;
  double _progress = 0.0; // 0.0 – 1.0
  String? _errorMessage;

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    setState(() {
      _state = _SetupState.downloading;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      )
          .fromNetwork(_kModelUrl)
          .withProgress((pct) {
            if (mounted) {
              setState(() => _progress = pct / 100.0);
            }
          })
          .install();

      if (mounted) {
        setState(() => _state = _SetupState.done);
        // Brief pause so the user sees "Ready!" before the redirect.
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _SetupState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DT.contentPad,
            vertical: DT.contentPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              _buildHeader(),
              const SizedBox(height: DT.lg * 2),
              _buildContent(),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App wordmark
        Text(
          'Daksha',
          style: DakshaTypography.display.copyWith(
            color: DT.primary,
            fontSize: 36,
          ),
        ),
        const SizedBox(height: DT.sm),
        Text(
          'Your on-device study companion',
          style: DakshaTypography.body.copyWith(color: DT.muted),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return switch (_state) {
      _SetupState.idle => _buildIdleCard(),
      _SetupState.downloading => _buildProgressCard(),
      _SetupState.done => _buildDoneCard(),
      _SetupState.error => _buildErrorCard(),
    };
  }

  // ── Idle card ─────────────────────────────────────────────────────────────────

  Widget _buildIdleCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'One-time setup',
            style: DakshaTypography.headingMd.copyWith(color: DT.textStrong),
          ),
          const SizedBox(height: DT.sm),
          Text(
            'Daksha uses Gemma 4 — a small, powerful AI that runs entirely '
            'on your phone. We need to download it once ($_kModelSizeLabel). '
            'After that, everything works without internet.',
            style: DakshaTypography.body.copyWith(color: DT.text),
          ),
          const SizedBox(height: DT.lg),
          _InfoRow(icon: Icons.wifi_outlined, label: 'Wi-Fi recommended'),
          const SizedBox(height: DT.sm),
          _InfoRow(
              icon: Icons.storage_outlined, label: 'Needs ~5 GB free space'),
          const SizedBox(height: DT.sm),
          _InfoRow(
              icon: Icons.lock_outline, label: 'All learning stays on device'),
          const SizedBox(height: DT.lg * 1.5),
          PrimaryButton(
            label: 'Download Gemma 4',
            onPressed: _startDownload,
            enabled: true,
          ),
        ],
      ),
    );
  }

  // ── Downloading card ──────────────────────────────────────────────────────────

  Widget _buildProgressCard() {
    final pct = (_progress * 100).toStringAsFixed(0);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Downloading…',
            style: DakshaTypography.headingMd.copyWith(color: DT.textStrong),
          ),
          const SizedBox(height: DT.sm),
          Text(
            'Gemma 4 is being downloaded and installed. '
            'Please keep the app open.',
            style: DakshaTypography.body.copyWith(color: DT.muted),
          ),
          const SizedBox(height: DT.lg),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(DT.radiusBtn),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: DT.elev2,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(DT.primary),
            ),
          ),
          const SizedBox(height: DT.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct% complete',
                style:
                    DakshaTypography.caption.copyWith(color: DT.muted),
              ),
              Text(
                _kModelSizeLabel,
                style:
                    DakshaTypography.caption.copyWith(color: DT.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Done card ─────────────────────────────────────────────────────────────────

  Widget _buildDoneCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: DT.success, size: 24),
              const SizedBox(width: DT.sm),
              Text(
                'Ready!',
                style: DakshaTypography.headingMd.copyWith(color: DT.success),
              ),
            ],
          ),
          const SizedBox(height: DT.sm),
          Text(
            'Gemma 4 is installed. Daksha is ready to help you learn.',
            style: DakshaTypography.body.copyWith(color: DT.text),
          ),
        ],
      ),
    );
  }

  // ── Error card ────────────────────────────────────────────────────────────────

  Widget _buildErrorCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: DT.error, size: 24),
              const SizedBox(width: DT.sm),
              Text(
                'Download failed',
                style: DakshaTypography.headingMd.copyWith(color: DT.error),
              ),
            ],
          ),
          const SizedBox(height: DT.sm),
          Text(
            'Check your connection and try again. '
            'Make sure you have at least 3 GB of free storage.',
            style: DakshaTypography.body.copyWith(color: DT.text),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: DT.sm),
            Container(
              padding: const EdgeInsets.all(DT.sm),
              decoration: BoxDecoration(
                color: DT.elev1,
                borderRadius: BorderRadius.circular(DT.radius),
              ),
              child: Text(
                _errorMessage!,
                style: DakshaTypography.caption
                    .copyWith(color: DT.muted, fontFamily: 'monospace'),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const SizedBox(height: DT.lg),
          PrimaryButton(
            label: 'Try again',
            onPressed: _startDownload,
            enabled: true,
          ),
        ],
      ),
    );
  }
}

// ── Internal widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DT.contentPad),
      decoration: BoxDecoration(
        color: DT.elev1,
        borderRadius: BorderRadius.circular(DT.radiusDialog),
        border: Border.all(color: DT.outline),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: DT.muted),
        const SizedBox(width: DT.sm),
        Text(
          label,
          style: DakshaTypography.body.copyWith(color: DT.muted),
        ),
      ],
    );
  }
}
