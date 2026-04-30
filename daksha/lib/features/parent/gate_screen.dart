import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/security/secure_screen_mixin.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/services/parent/parent_auth_service.dart';

// ---------------------------------------------------------------------------
// GateScreen
// ---------------------------------------------------------------------------

class GateScreen extends ConsumerStatefulWidget {
  const GateScreen({super.key});

  @override
  ConsumerState<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends ConsumerState<GateScreen>
    with SingleTickerProviderStateMixin, SecureScreenMixin {
  final List<String> _pin = [];
  bool _locked = false;
  DateTime? _lockoutUntil;
  bool _restartRequired = false;
  String? _errorMessage;

  // Shake animation controller
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKey(String digit) {
    if (_locked || _pin.length >= 4) return;
    setState(() {
      _pin.add(digit);
      _errorMessage = null;
    });
    if (_pin.length == 4) {
      _verify();
    }
  }

  void _onDelete() {
    if (_locked || _pin.isEmpty) return;
    setState(() {
      _pin.removeLast();
      _errorMessage = null;
    });
  }

  Future<void> _verify() async {
    final service = ref.read(parentAuthServiceProvider);
    final entered = _pin.join();
    final result = await service.verify(entered);

    if (!mounted) return;

    switch (result) {
      case AuthSuccess():
        context.go('/parent/shell');
      case AuthFailure(:final failedCount):
        await _shakeController.forward(from: 0);
        setState(() {
          _pin.clear();
          _errorMessage = 'Incorrect PIN ($failedCount failed attempt${failedCount == 1 ? '' : 's'})';
        });
      case AuthLockout(:final until, :final restartRequired):
        setState(() {
          _pin.clear();
          _locked = true;
          _lockoutUntil = until;
          _restartRequired = restartRequired;
        });
    }
  }

  void _onReset() {
    // Navigate to setup for PIN reset
    context.go('/parent/setup');
  }

  String _lockoutMessage() {
    if (_restartRequired) return 'Too many attempts. Restart the app to try again.';
    final now = DateTime.now();
    final diff = _lockoutUntil!.difference(now);
    final minutes = diff.inMinutes + 1;
    return 'Locked. Try again in ${minutes}m.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.elev1,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DT.contentPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 40)),
                const SizedBox(height: DT.sm),
                Text(
                  'Parent view',
                  style: DakshaTypography.headingLg.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: DT.textStrong,
                  ),
                ),
                const SizedBox(height: DT.xs),
                Text(
                  _locked ? _lockoutMessage() : 'Enter PIN',
                  style: DakshaTypography.body.copyWith(color: DT.muted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DT.contentPad + DT.xs),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final offset = _shakeAnimation.value == 0
                        ? 0.0
                        : ((_shakeAnimation.value * 4).round() % 2 == 0 ? 8.0 : -8.0)
                            * (1 - _shakeAnimation.value);
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: _PinDots(enteredCount: _pin.length),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: DT.sm),
                  Text(
                    _errorMessage!,
                    style: DakshaTypography.caption.copyWith(color: DT.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: DT.contentPad + DT.xs),
                _PinKeypad(
                  onKey: _onKey,
                  onDelete: _onDelete,
                  disabled: _locked,
                ),
                const SizedBox(height: DT.lg),
                TextButton(
                  onPressed: _onReset,
                  style: TextButton.styleFrom(
                    foregroundColor: DT.error,
                    padding: const EdgeInsets.all(DT.sm),
                    minimumSize: const Size(DT.minTouch, DT.minTouch),
                    textStyle: DakshaTypography.caption,
                  ),
                  child: const Text('Forgot PIN? Reset access.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PinDots
// ---------------------------------------------------------------------------

class _PinDots extends StatelessWidget {
  final int enteredCount;

  const _PinDots({required this.enteredCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < enteredCount;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeInOut,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? DT.primary : DT.elev2,
              border: filled
                  ? null
                  : Border.all(color: DT.outline, width: DT.bwCard),
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// _PinKeypad
// ---------------------------------------------------------------------------

class _PinKeypad extends StatelessWidget {
  final void Function(String digit) onKey;
  final VoidCallback onDelete;
  final bool disabled;

  const _PinKeypad({
    required this.onKey,
    required this.onDelete,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Layout: 3 columns, 4 rows
    // Row 1: 1 2 3
    // Row 2: 4 5 6
    // Row 3: 7 8 9
    // Row 4: _ 0 ⌫
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: DT.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((label) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: DT.xs),
                child: _PinKey(
                  label: label,
                  onTap: label.isEmpty
                      ? null
                      : label == '⌫'
                          ? (disabled ? null : onDelete)
                          : (disabled ? null : () => onKey(label)),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _PinKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox(width: 80, height: 64);
    }

    return SizedBox(
      width: 80,
      height: 64,
      child: Material(
        color: onTap == null && label.isNotEmpty ? DT.elev2 : DT.elev1,
        borderRadius: BorderRadius.circular(DT.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DT.radius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DT.radius),
              border: Border.all(color: DT.outline, width: DT.bwCard),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: DakshaTypography.headingLg.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: onTap == null && label.isNotEmpty
                    ? DT.muted
                    : DT.textStrong,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
