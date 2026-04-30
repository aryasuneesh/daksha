import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  CameraController? _controller;
  bool _cameraReady = false;

  // Type-mode text entry
  final TextEditingController _typeController = TextEditingController();

  // OCR state via ValueNotifier — avoids addPostFrameCallback accumulation
  final _ocrNotifier = ValueNotifier<({bool loading, String? text})>(
    (loading: false, text: null),
  );

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraReady = true;
      });
    } catch (_) {
      // Camera unavailable (simulator / test) — stay in degraded mode.
    }
  }

  @override
  void dispose() {
    _ocrNotifier.dispose();
    _controller?.dispose();
    _typeController.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _onCapture() async {
    if (_controller == null || !_cameraReady) return;

    _ocrNotifier.value = (loading: true, text: null);
    _showOcrSheet();

    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      // Pass bytes to OCR (no disk persistence — bytes are discarded after use)
      final text = await _runOcr(bytes);
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

  /// Delegates to [OcrService] via [engineProvider]. Returns null if the engine
  /// is not yet loaded (model not downloaded), letting the UI show the fallback.
  Future<String?> _runOcr(Uint8List bytes) async {
    final engineAsync = ref.read(engineProvider);
    final engine = engineAsync.valueOrNull;
    if (engine == null) return null; // engine not loaded yet
    if (!engine.isLoaded) {
      await engine.load();
    }
    final service = OcrService(engine);
    return service.extractProblemText(bytes);
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
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Camera preview ─────────────────────────────────────────────────
        if (_cameraReady && _controller != null)
          CameraPreview(_controller!)
        else
          const ColoredBox(
            color: DT.canvasBg,
            child: Center(
              child: Text(
                'Camera unavailable',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

        // ── Alignment guide: 310×200 dashed-style rect ────────────────────
        Center(
          child: Container(
            width: 310,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // ── Capture button ─────────────────────────────────────────────────
        Positioned(
          bottom: DT.bottomSafe + DT.lg,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _onCapture,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: DT.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: DT.outline, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: DT.text),
              ),
            ),
          ),
        ),
      ],
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
