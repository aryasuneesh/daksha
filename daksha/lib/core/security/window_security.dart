import 'package:flutter/services.dart';

class WindowSecurity {
  static const _channel = MethodChannel('daksha/window');

  static Future<void> enableSecure() =>
      _channel.invokeMethod('enableSecure');

  static Future<void> disableSecure() =>
      _channel.invokeMethod('disableSecure');
}
