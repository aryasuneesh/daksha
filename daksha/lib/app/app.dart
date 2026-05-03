import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/app/router.dart';

class DakshaApp extends StatelessWidget {
  const DakshaApp({super.key, required this.needsSetup});

  /// When true the router starts at /setup (model not yet downloaded).
  final bool needsSetup;

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion sets dark status-bar icons (correct for the light Warm
    // Desk theme) without needing an AppBar to own the overlay style.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // iOS
      ),
      child: MaterialApp.router(
        title: 'Daksha',
        debugShowCheckedModeBanner: false,
        theme: buildDakshaTheme(),
        routerConfig: createRouter(needsSetup: needsSetup),
      ),
    );
  }
}
