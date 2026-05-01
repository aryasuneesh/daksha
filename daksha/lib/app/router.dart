import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:daksha/core/security/secure_screen_mixin.dart';
import 'package:daksha/features/capture/capture_screen.dart';
import 'package:daksha/features/parent/gate_screen.dart';
import 'package:daksha/features/parent/setup_screen.dart';
import 'package:daksha/features/parent/shell_screen.dart';
import 'package:daksha/features/tutor/dashboard_screen.dart';
import 'package:daksha/features/tutor/home_screen.dart';
import 'package:daksha/features/tutor/problem_screen.dart';
import 'package:daksha/features/tutor/solved_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/problem',
      builder: (context, state) => ProblemScreen(
        problemText: state.extra as String? ?? '',
      ),
    ),
    GoRoute(
      path: '/solved',
      builder: (context, state) => const SolvedScreen(),
    ),
    GoRoute(
      path: '/capture',
      builder: (context, state) => const CaptureScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/parent/gate',
      builder: (context, state) => const GateScreen(),
    ),
    GoRoute(
      path: '/parent/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/parent/shell',
      builder: (context, state) => const ShellScreen(),
    ),
    GoRoute(
      path: '/parent/voice',
      builder: (context, state) =>
          const _SecurePlaceholderScreen(title: 'Parent Voice'),
    ),
  ],
);

class _SecurePlaceholderScreen extends StatefulWidget {
  const _SecurePlaceholderScreen({required this.title});
  final String title;
  @override
  State<_SecurePlaceholderScreen> createState() =>
      _SecurePlaceholderScreenState();
}

class _SecurePlaceholderScreenState extends State<_SecurePlaceholderScreen>
    with SecureScreenMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: Text(widget.title)),
    );
  }
}
