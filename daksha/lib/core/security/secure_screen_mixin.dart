import 'package:flutter/material.dart';
import 'package:daksha/core/security/window_security.dart';

/// Apply to any State that should prevent screenshotting while visible.
/// Usage: `class _MyScreenState extends State<MyScreen> with SecureScreenMixin`
mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WindowSecurity.enableSecure();
  }

  @override
  void dispose() {
    WindowSecurity.disableSecure();
    super.dispose();
  }
}
