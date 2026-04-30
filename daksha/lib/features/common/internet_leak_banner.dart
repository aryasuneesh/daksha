import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/typography.dart';
import 'package:daksha/core/permission_guard.dart';

class InternetLeakBanner extends StatelessWidget {
  final NetworkPermissionStatus status;
  const InternetLeakBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == NetworkPermissionStatus.absent) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: DT.error,
      padding: const EdgeInsets.symmetric(horizontal: DT.cardHPad, vertical: DT.sm),
      child: Text(
        status == NetworkPermissionStatus.present
            ? '⚠ INTERNET permission detected — this build is not safe for distribution.'
            : '⚠ Could not verify network permission status.',
        style: DakshaTypography.sm.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
