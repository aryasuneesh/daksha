import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';
import 'package:daksha/features/common/top_bar.dart';
import 'package:daksha/services/ocr_service.dart';

// ── Public screen ─────────────────────────────────────────────────────────────

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  bool _photoMode = true;

  // Type-mode text entry
  final TextEditingController _typeController = TextEditingController();

  // OCR state via ValueNotifier — avoids addPostFrameCallback accumulation
  final _ocrNotifier = ValueNotifier<({bool loading, String? text})>(
    (loading: false, text: null),
  );

  @override
  void dispose() {
    _ocrNotifier.dispose();
    _typeController.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  /// Launch the device's native camera app via image_picker.  When the user
  /// returns with a captured photo, kick off OCR immediately.
  Future<void> _onCapture() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (photo == null) return; // user cancelled

    _ocrNotifier.value = (loading: true, text: null);
    _showOcrSheet();

    try {
      final text = await _runOcr(photo.path);
      if (mounted) {
        _ocrNotifier.value = (
          loading: false,
          text: text ?? 'Could not read problem — please try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        _ocrNotifier.value = (
          loading: false,
          text: 'Could not read problem — please try again.',
        );
      }
    }
  }

  /// Pass 1 uses ML Kit on-device OCR (always works, no model download needed).
  /// Pass 2 feeds the raw OCR text to the LLM for cleanup, if the engine is
  /// already loaded — otherwise the raw ML Kit text is returned as-is.
  Future<String?> _runOcr(String filePath) async {
    final recognitionEngine = MlKitTextRecognitionEngine();
    try {
      final engineAsync = ref.read(engineProvider);
      final inferenceEngine = engineAsync.valueOrNull;
      final service = OcrService(
        recognitionEngine: recognitionEngine,
        inferenceEngine: inferenceEngine,
      );
      return await service.extractProblemText(filePath);
    } finally {
      await recognitionEngine.close();
    }
  }

  void _showOcrSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DT.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(DT.radiusDialog),
        ),
      ),
      builder: (_) => ValueListenableBuilder<({bool loading, String? text})>(
        valueListenable: _ocrNotifier,
        builder: (context, state, _) => _OcrSheet(
          isLoading: state.loading,
          parsedText: state.text,
          onEdit: () {
            Navigator.of(context).pop();
            if (state.text != null) {
              _typeController.text = state.text!;
            }
            setState(() => _photoMode = false);
          },
          onUse: () {
            Navigator.of(context).pop();
            if (state.text != null) {
              context.push('/problem', extra: state.text);
            }
          },
          onTypeInstead: () {
            Navigator.of(context).pop();
            setState(() => _photoMode = false);
          },
        ),
      ),
    );
  }

  // ── Toggle ───────────────────────────────────────────────────────────────────

  void _onToggle(bool photoMode) => setState(() => _photoMode = photoMode);

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.canvasBg,
      appBar: CaptureTopBar(
        photoMode: _photoMode,
        onToggle: _onToggle,
        onBack: () => context.pop(),
        onClose: () => context.go('/'),
      ),
      body: _photoMode ? _buildCameraBody() : _buildTypeBody(),
    );
  }

  /// Photo mode: a full-screen prompt that launches the native camera on tap.
  /// Using the native camera app avoids any viewfinder aspect-ratio issues and
  /// gives students the camera UX they already know from their device.
  Widget _buildCameraBody() {
    return GestureDetector(
      onTap: _onCapture,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: DT.canvasBg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Camera icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DT.bg.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: DT.bg.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: DT.bg.withValues(alpha: 0.8),
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap to take a photo',
              style: DakshaTypography.body.copyWith(
                color: DT.bg.withValues(alpha: 0.8),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Point your camera at the problem',
              style: DakshaTypography.caption.copyWith(
                color: DT.bg.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBody() {
    return Padding(
      padding: const EdgeInsets.all(DT.contentPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _typeController,
            maxLines: null,
            autofocus: true,
            style: DakshaTypography.body,
            decoration: InputDecoration(
              hintText: 'Type your problem here…',
              hintStyle: DakshaTypography.body.copyWith(color: DT.muted),
              filled: true,
              fillColor: DT.elev1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DT.radius),
                borderSide: const BorderSide(color: DT.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DT.radius),
                borderSide: const BorderSide(color: DT.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DT.radius),
                borderSide: const BorderSide(color: DT.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: DT.lg),
          PrimaryButton(
            label: 'Use this ✓',
            onPressed: () {
              final text = _typeController.text.trim();
              if (text.isNotEmpty) {
                context.push('/problem', extra: text);
              }
            },
            enabled: true,
          ),
        ],
      ),
    );
  }
}

// ── OCR bottom sheet ──────────────────────────────────────────────────────────

class _OcrSheet extends StatelessWidget {
  const _OcrSheet({
    required this.isLoading,
    required this.parsedText,
    required this.onEdit,
    required this.onUse,
    required this.onTypeInstead,
  });

  final bool isLoading;
  final String? parsedText;
  final VoidCallback onEdit;
  final VoidCallback onUse;
  final VoidCallback onTypeInstead;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: DT.contentPad,
          right: DT.contentPad,
          top: DT.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + DT.bottomSafe,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: DT.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: DT.lg),

            // ── Loading / content ──────────────────────────────────────────
            if (isLoading) ...[
              Text(
                'Reading your problem…',
                style:
                    DakshaTypography.body.copyWith(color: DT.muted),
              ),
              const SizedBox(height: DT.lg),
              const LinearProgressIndicator(),
            ] else ...[
              Text(
                'Reading your problem…',
                style:
                    DakshaTypography.caption.copyWith(color: DT.muted),
              ),
              const SizedBox(height: DT.sm),
              StandardCard(
                child: Text(
                  parsedText ?? '',
                  style: DakshaTypography.body,
                ),
              ),
              const SizedBox(height: DT.lg),
              Row(
                children: [
                  Expanded(
                    child: DakshaOutlineButton(
                      label: 'Edit',
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: DT.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Use this ✓',
                      onPressed: onUse,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: DT.sm),

            // ── "Type instead" always visible ──────────────────────────────
            Center(
              child: DakshaTextButton(
                label: 'Type instead',
                onPressed: onTypeInstead,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
