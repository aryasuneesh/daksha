import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      builder: (context, state) => const _PlaceholderScreen(title: 'Capture'),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/parent/gate',
      builder: (context, state) =>
          const _PlaceholderScreen(title: 'Parent Gate'),
    ),
    GoRoute(
      path: '/parent/shell',
      builder: (context, state) =>
          const _PlaceholderScreen(title: 'Parent Shell'),
    ),
    GoRoute(
      path: '/parent/voice',
      builder: (context, state) =>
          const _PlaceholderScreen(title: 'Parent Voice'),
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}
