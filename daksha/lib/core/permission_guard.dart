import 'package:flutter/services.dart';

enum NetworkPermissionStatus { absent, present, unknown }

class PermissionGuard {
  static const _channel = MethodChannel('daksha/security');

  /// Returns [NetworkPermissionStatus.absent] if INTERNET is not granted,
  /// [NetworkPermissionStatus.present] if it is, [NetworkPermissionStatus.unknown] on error.
  static Future<NetworkPermissionStatus> checkInternetPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasInternetPermission');
      if (result == null) return NetworkPermissionStatus.unknown;
      return result ? NetworkPermissionStatus.present : NetworkPermissionStatus.absent;
    } on PlatformException {
      return NetworkPermissionStatus.unknown;
    }
  }
}
