import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/buttons.dart';

// ── Model constants ───────────────────────────────────────────────────────────

/// HuggingFace URL for the Gemma 4 E4B instruction-tuned LiteRT-LM model.
///
/// Uses the /resolve/ redirect endpoint which bounces to HuggingFace's CDN
/// (cdn-lfs-us-1.huggingface.co). dart:io HttpClient follows the redirect
/// automatically and gets a proper Content-Length for progress tracking.
const _kModelUrl =
    'https://huggingface.co/litert-community/gemma-4-E4B-it-litert-lm'
    '/resolve/main/gemma-4-E4B-it.litertlm';

const _kModelFilename = 'gemma-4-E4B-it.litertlm';
const _kModelSizeBytes = 3_921_000_000; // ~3.65 GB, used as fallback

// ── Screen ────────────────────────────────────────────────────────────────────

/// First-launch screen that downloads and installs the Gemma 4 on-device model.
///
/// Downloads using dart:io [HttpClient] directly — no WorkManager, no 10-minute
/// OS timeout, full network speed. After streaming to disk, registers the file
/// with flutter_gemma via [fromFile], which is instant (no copy).
class ModelSetupScreen extends StatefulWidget {
  const ModelSetupScreen({super.key});

  @override
  State<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

enum _SetupState { idle, downloading, loadingFile, done, error }

class _ModelSetupScreenState extends State<ModelSetupScreen> {
  _SetupState _state = _SetupState.idle;
  double _progress = 0.0;   // 0.0 – 1.0
  int _receivedBytes = 0;
  int _totalBytes = _kModelSizeBytes;
  double _speedBytesPerSec = 0.0;
  String? _errorMessage;

  // Allow cancellation by closing the HTTP response.
  HttpClient? _activeClient;

  @override
  void dispose() {
    _activeClient?.close(force: true);
    super.dispose();
  }

  // ── Download ──────────────────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    // Notification permission: needed on Android 13+ if the user later triggers
    // any system notification (e.g. from image_picker). Not required for our
    // own in-process download, but good hygiene to request it at first launch.
    final status = await Permission.notification.status;
    if (!status.isGranted) await Permission.notification.request();

    setState(() {
      _state = _SetupState.downloading;
      _progress = 0.0;
      _receivedBytes = 0;
      _totalBytes = _kModelSizeBytes;
      _speedBytesPerSec = 0.0;
      _errorMessage = null;
    });

    // Keep CPU + screen alive for the duration of the download.
    await WakelockPlus.enable();

    File? tempFile;
    try {
      final dir = await getApplicationSupportDirectory();
      final modelDir = Directory('${dir.path}/models');
      await modelDir.create(recursive: true);
      final targetPath = '${modelDir.path}/$_kModelFilename';
      tempFile = File(targetPath);

      // Remove any partial file from a previous attempt so we start clean.
      if (await tempFile.exists()) await tempFile.delete();

      // ── Direct dart:io HTTP stream ──────────────────────────────────────────
      // Why NOT background_downloader / WorkManager:
      //   WorkManager background jobs have a hard 10-minute OS timeout on
      //   Android. A 3.65 GB file on a typical home WiFi connection takes
      //   15–30 minutes. Despite foreground-service flags and manifest
      //   permissions, WorkManager's DownloadTaskWorker never promoted to a
      //   true foreground service on Android 15, consistently timing out at
      //   ~30% and draining battery through repeated retries.
      //
      // dart:io HttpClient runs in the Dart event loop:
      //   - Zero WorkManager overhead, zero OS job timeout
      //   - Download runs at full WiFi speed
      //   - Response body streams in OS-managed TCP chunks directly to disk
      //   - Progress tracked from Content-Length + bytes received
      //   - Cancelled cleanly via HttpClient.close(force: true) on dispose
      final client = HttpClient();
      _activeClient = client;
      client.connectionTimeout = const Duration(seconds: 30);
      client.idleTimeout = const Duration(seconds: 60);

      final request = await client.getUrl(Uri.parse(_kModelUrl));
      request.headers.add(HttpHeaders.connectionHeader, 'keep-alive');
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Server returned HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength; // -1 if unknown
      if (contentLength > 0) {
        setState(() => _totalBytes = contentLength);
      }

      var received = 0;
      var lastUpdateAt = DateTime.now();
      var lastSpeedSample = 0;

      final sink = tempFile.openWrite();
      try {
        await for (final chunk in response) {
          if (!mounted) break; // screen disposed while downloading
          sink.add(chunk);
          received += chunk.length;

          // Throttle UI updates to ~10 fps to avoid rebuilding on every chunk.
          final now = DateTime.now();
          final elapsed = now.difference(lastUpdateAt).inMilliseconds;
          if (elapsed >= 100) {
            final speed =
                (received - lastSpeedSample) / (elapsed / 1000.0); // B/s
            lastSpeedSample = received;
            lastUpdateAt = now;
            if (mounted) {
              setState(() {
                _receivedBytes = received;
                _progress = contentLength > 0
                    ? (received / contentLength).clamp(0.0, 1.0)
                    : 0.0;
                _speedBytesPerSec = speed;
              });
            }
          }
        }
      } finally {
        await sink.flush();
        await sink.close();
      }
      _activeClient = null;
      client.close();

      // Register the downloaded file with flutter_gemma.
      // fromFile() does NO copying — it just records the path in
      // SharedPreferences and sets it as the active model. Instant.
      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(targetPath).install();

      if (mounted) {
        setState(() => _state = _SetupState.done);
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/');
      }
    } catch (e) {
      // Clean up partial file so the next attempt starts fresh.
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
      _activeClient = null;
      if (mounted) {
        setState(() {
          _state = _SetupState.error;
          _errorMessage = e.toString();
        });
      }
    } finally {
      await WakelockPlus.disable();
    }
  }

  /// Load a pre-existing file via file picker (e.g. transferred via USB).
  /// fromFile() registers it without copying — instant regardless of size.
  Future<void> _loadFromFile() async {
    setState(() {
      _state = _SetupState.loadingFile;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['litertlm', 'task'],
        dialogTitle: 'Select Gemma 4 model file',
        allowMultiple: false,
      );

      if (result == null || result.files.single.path == null) {
        if (mounted) setState(() => _state = _SetupState.idle);
        return;
      }

      await FlutterGemma.installModel(
        modelType: ModelType.gemma4,
        fileType: ModelFileType.litertlm,
      ).fromFile(result.files.single.path!).install();

      if (mounted) {
        setState(() => _state = _SetupState.done);
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

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatSpeed(double bps) {
    if (bps < 1024) return '${bps.toStringAsFixed(0)} B/s';
    if (bps < 1024 * 1024) return '${(bps / 1024).toStringAsFixed(1)} KB/s';
    return '${(bps / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  String _etaLabel() {
    if (_speedBytesPerSec <= 0 || _totalBytes <= 0) return '';
    final remaining = _totalBytes - _receivedBytes;
    final secs = (remaining / _speedBytesPerSec).round();
    if (secs < 60) return '~${secs}s left';
    final mins = (secs / 60).ceil();
    return '~${mins}min left';
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
      _SetupState.loadingFile => _buildLoadingFileCard(),
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
            'on your phone. We need to download it once (3.65 GB). '
            'After that, everything works without internet.',
            style: DakshaTypography.body.copyWith(color: DT.text),
          ),
          const SizedBox(height: DT.lg),
          const _InfoRow(icon: Icons.wifi_outlined, label: 'Wi-Fi recommended'),
          const SizedBox(height: DT.sm),
          const _InfoRow(
              icon: Icons.storage_outlined, label: 'Needs ~5 GB free space'),
          const SizedBox(height: DT.sm),
          const _InfoRow(
              icon: Icons.lock_outline, label: 'All learning stays on device'),
          const SizedBox(height: DT.lg * 1.5),
          PrimaryButton(
            label: 'Download Gemma 4',
            onPressed: _startDownload,
            enabled: true,
          ),
          const SizedBox(height: DT.md),
          SecondaryButton(
            label: 'Load from file…',
            onPressed: _loadFromFile,
            enabled: true,
          ),
        ],
      ),
    );
  }

  // ── Downloading card ──────────────────────────────────────────────────────────

  Widget _buildProgressCard() {
    final pct = (_progress * 100).toStringAsFixed(1);
    final received = _formatBytes(_receivedBytes);
    final total = _formatBytes(_totalBytes);
    final speed = _speedBytesPerSec > 0 ? _formatSpeed(_speedBytesPerSec) : '';
    final eta = _etaLabel();

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
            'Keep the app open. Gemma 4 is downloading directly '
            'at your full WiFi speed.',
            style: DakshaTypography.body.copyWith(color: DT.muted),
          ),
          const SizedBox(height: DT.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(DT.radiusBtn),
            child: LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              minHeight: 10,
              backgroundColor: DT.elev2,
              valueColor: const AlwaysStoppedAnimation<Color>(DT.primary),
            ),
          ),
          const SizedBox(height: DT.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$pct%  •  $received / $total',
                style: DakshaTypography.caption.copyWith(color: DT.muted),
              ),
              if (speed.isNotEmpty)
                Text(
                  '$speed  $eta',
                  style: DakshaTypography.caption.copyWith(color: DT.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Loading-file card ─────────────────────────────────────────────────────────

  Widget _buildLoadingFileCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecting file…',
            style: DakshaTypography.headingMd.copyWith(color: DT.textStrong),
          ),
          const SizedBox(height: DT.sm),
          Text(
            'Choose the Gemma 4 model file (.litertlm) from your storage.',
            style: DakshaTypography.body.copyWith(color: DT.muted),
          ),
          const SizedBox(height: DT.lg),
          const LinearProgressIndicator(),
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
            'Make sure you have at least 5 GB of free storage.',
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
          const SizedBox(height: DT.md),
          SecondaryButton(
            label: 'Load from file…',
            onPressed: _loadFromFile,
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

// ignore: unused_element
double _log10(num x) => math.log(x) / math.ln10;
