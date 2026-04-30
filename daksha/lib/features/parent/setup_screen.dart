import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/app/providers.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/security/secure_screen_mixin.dart';
import 'package:daksha/core/typography.dart';

// ---------------------------------------------------------------------------
// SetupScreen — PIN creation (two-phase: enter then confirm)
// ---------------------------------------------------------------------------

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with SecureScreenMixin {
  final List<String> _pin = [];
  String? _firstPin;
  bool _confirming = false;
  String? _errorMessage;

  void _onKey(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin.add(digit);
      _errorMessage = null;
    });
    if (_pin.length == 4) {
      _advance();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin.removeLast();
      _errorMessage = null;
    });
  }

  Future<void> _advance() async {
    if (!_confirming) {
      // First phase — store PIN and move to confirm
      setState(() {
        _firstPin = _pin.join();
        _pin.clear();
        _confirming = true;
      });
    } else {
      // Second phase — confirm match
      final entered = _pin.join();
      if (entered != _firstPin) {
        setState(() {
          _pin.clear();
          _confirming = false;
          _firstPin = null;
          _errorMessage = 'PINs did not match. Try again.';
        });
        return;
      }

      final service = ref.read(parentAuthServiceProvider);
      await service.setup(entered);

      if (!mounted) return;
      context.go('/parent/gate');
    }
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
                  _confirming ? 'Confirm PIN' : 'Create PIN',
                  style: DakshaTypography.headingLg.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: DT.textStrong,
                  ),
                ),
                const SizedBox(height: DT.xs),
                Text(
                  _confirming
                      ? 'Re-enter your new PIN'
                      : 'Choose a 4-digit PIN',
                  style: DakshaTypography.body.copyWith(color: DT.muted),
                ),
                const SizedBox(height: DT.contentPad + DT.xs),
                _PinDotsSetup(enteredCount: _pin.length),
                if (_errorMessage != null) ...[
                  const SizedBox(height: DT.sm),
                  Text(
                    _errorMessage!,
                    style: DakshaTypography.caption.copyWith(color: DT.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: DT.contentPad + DT.xs),
                _PinKeypadSetup(onKey: _onKey, onDelete: _onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _PinDotsSetup
// ---------------------------------------------------------------------------

class _PinDotsSetup extends StatelessWidget {
  final int enteredCount;

  const _PinDotsSetup({required this.enteredCount});

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
// _PinKeypadSetup
// ---------------------------------------------------------------------------

class _PinKeypadSetup extends StatelessWidget {
  final void Function(String digit) onKey;
  final VoidCallback onDelete;

  const _PinKeypadSetup({
    required this.onKey,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
                child: _SetupKey(
                  label: label,
                  onTap: label.isEmpty
                      ? null
                      : label == '⌫'
                          ? onDelete
                          : () => onKey(label),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _SetupKey extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SetupKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox(width: 80, height: 64);
    }

    return SizedBox(
      width: 80,
      height: 64,
      child: Material(
        color: DT.elev1,
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
                color: DT.textStrong,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
