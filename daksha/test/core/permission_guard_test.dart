import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/core/permission_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('daksha/security'),
      (call) async {
        if (call.method == 'hasInternetPermission') return false;
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('daksha/security'),
      null,
    );
  });

  test('returns absent when channel returns false', () async {
    final status = await PermissionGuard.checkInternetPermission();
    expect(status, NetworkPermissionStatus.absent);
  });

  test('returns present when channel returns true', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('daksha/security'),
      (call) async => true,
    );
    final status = await PermissionGuard.checkInternetPermission();
    expect(status, NetworkPermissionStatus.present);
  });

  test('returns unknown on PlatformException', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('daksha/security'),
      (call) async => throw PlatformException(code: 'ERROR'),
    );
    final status = await PermissionGuard.checkInternetPermission();
    expect(status, NetworkPermissionStatus.unknown);
  });

  test('returns unknown when channel returns null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('daksha/security'),
      (call) async => null,
    );
    final status = await PermissionGuard.checkInternetPermission();
    expect(status, NetworkPermissionStatus.unknown);
  });
}
