import 'package:flutter/material.dart';
import 'package:daksha/core/security/window_security.dart';

/// Apply to any State that should prevent screenshotting while visible.
/// Usage: `class _MyScreenState extends State<MyScreen> with SecureScreenMixin`
///
/// Uses a process-wide refcount so that pushing a secure screen on top of
/// another secure screen, then popping the upper one, keeps the platform
/// flag enabled until *every* secure screen has been disposed. Without the
/// refcount, popping `/parent/voice` from on top of `/parent/shell` would
/// disable secure mode while `/parent/shell` is still visible.
mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  static int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    if (_activeCount == 0) {
      WindowSecurity.enableSecure();
    }
    _activeCount++;
  }

  @override
  void dispose() {
    _activeCount--;
    if (_activeCount <= 0) {
      _activeCount = 0;
      WindowSecurity.disableSecure();
    }
    super.dispose();
  }
}
