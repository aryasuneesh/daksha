import 'package:flutter/material.dart';
import 'package:daksha/core/theme.dart';
import 'package:daksha/app/router.dart';

class DakshaApp extends StatelessWidget {
  const DakshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daksha',
      debugShowCheckedModeBanner: false,
      theme: buildDakshaTheme(),
      routerConfig: appRouter,
    );
  }
}
