import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
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

  /// Full capture flow:
  ///   1. Launch native camera → user takes photo
  ///   2. Launch uCrop crop UI → user frames just the question
  ///   3. Run ML Kit + LLM OCR on the cropped image
  Future<void> _onCapture() async {
    // Step 1 — native camera
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // lossless for OCR — compression artefacts hurt recognition
    );
    if (photo == null) return; // user cancelled

    // Step 2 — crop to the question area.
    //
    // Key uCrop settings for textbook use:
    //   - maxResultWidth/Height: preserve full resolution so ML Kit gets sharp
    //     text even after a tight crop of a small region.
    //   - aspectRatioOptions: offer the full preset list + a free-form option
    //     so the student can match any question shape.
    //   - No lockAspectRatio, no initAspectRatio lock — free crop is essential
    //     when two questions share the same photo and you need just one.
    //   - showCropGrid: true gives a reference grid to align to text lines.
    //   - The uCrop library supports two-finger pinch-to-zoom inside the crop
    //     frame by default; the handles can be dragged to any size down to the
    //     library minimum (~40 dp).  There is no separate Dart API to change
    //     the min crop size — it is a uCrop compile-time constant.
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: photo.path,
      // Preserve source resolution — downsizing now hurts OCR on small text.
      maxWidth: 4096,
      maxHeight: 4096,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Select just the question',
          toolbarColor: DT.bg,
          toolbarWidgetColor: DT.text,
          activeControlsWidgetColor: DT.primary,
          backgroundColor: DT.canvasBg,
          // Start in free-form (original aspect ratio) so handles are
          // unconstrained — student can drag them very tightly.
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          // Show the full preset list (square, 3:2, 4:3, 16:9, original).
          // This lets the student quickly switch to "original" if they
          // accidentally tap a fixed ratio.
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          hideBottomControls: false,
          showCropGrid: true,
        ),
      ],
    );
    if (croppedFile == null) return; // user cancelled crop

    // Step 3 — OCR on the cropped region
    _ocrNotifier.value = (loading: true, text: null);
    _showOcrSheet();

    try {
      final text = await _runOcr(croppedFile.path);
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
              'You\'ll crop to just the question next',
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
    // maxHeight: 85 % of screen so the sheet never tries to exceed the viewport
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: DT.contentPad,
            right: DT.contentPad,
            top: DT.md,
            bottom: MediaQuery.viewInsetsOf(context).bottom + DT.bottomSafe,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ──────────────────────────────────────────────
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

              // ── Loading / content ────────────────────────────────────────
              if (isLoading) ...[
                Text(
                  'Reading your problem…',
                  style: DakshaTypography.body.copyWith(color: DT.muted),
                ),
                const SizedBox(height: DT.lg),
                const LinearProgressIndicator(),
              ] else ...[
                Text(
                  'Recognised text',
                  style: DakshaTypography.caption.copyWith(color: DT.muted),
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

              // ── "Type instead" always visible ────────────────────────────
              Center(
                child: DakshaTextButton(
                  label: 'Type instead',
                  onPressed: onTypeInstead,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
