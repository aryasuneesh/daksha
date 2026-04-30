import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/core/design_tokens.dart';
import 'package:daksha/core/typography.dart';
import 'package:daksha/features/common/bottom_action_bar.dart';
import 'package:daksha/features/common/buttons.dart';
import 'package:daksha/features/common/cards.dart';

class SolvedScreen extends StatelessWidget {
  const SolvedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DT.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DT.contentPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: DT.success, width: 3),
                ),
                child: const Icon(Icons.check, color: DT.success, size: 28),
              ),
              const SizedBox(height: DT.lg),
              Text(
                'Right.',
                style: DakshaTypography.headingLg.copyWith(color: DT.success),
              ),
              const SizedBox(height: DT.sm),
              Text(
                'Well done! Keep going.',
                style: DakshaTypography.body.copyWith(color: DT.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DT.lg),
              const StandardCard(
                child: Text(
                  'Next review: Tomorrow',
                  style: DakshaTypography.sm,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: 'Next problem',
            onPressed: () => context.go('/'),
          ),
          DakshaTextButton(
            label: 'Back to home',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}
