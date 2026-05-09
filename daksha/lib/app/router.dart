import 'package:go_router/go_router.dart';
import 'package:daksha/features/capture/capture_screen.dart';
import 'package:daksha/features/parent/gate_screen.dart';
import 'package:daksha/features/parent/setup_screen.dart';
import 'package:daksha/features/parent/shell_screen.dart';
import 'package:daksha/features/parent/voice_screen.dart';
import 'package:daksha/features/setup/language_picker_screen.dart';
import 'package:daksha/features/setup/model_setup_screen.dart';
import 'package:daksha/features/settings/settings_screen.dart';
import 'package:daksha/features/history/history_screen.dart';
import 'package:daksha/features/tutor/dashboard_screen.dart';
import 'package:daksha/features/tutor/home_screen.dart';
import 'package:daksha/features/tutor/problem_screen.dart';
import 'package:daksha/features/tutor/solved_screen.dart';
import 'package:daksha/features/tutor/subject_topics_screen.dart';
import 'package:daksha/storage/database/app_database.dart';

/// Creates the app router.
///
/// [initialLocation] — chosen by main() based on (modelPresent, localePicked):
///   - '/setup'           — no model yet, run download flow
///   - '/setup/language'  — model present but locale not yet picked
///   - '/'                — fully bootstrapped, go home
GoRouter createRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => const ModelSetupScreen(),
      ),
      GoRoute(
        path: '/setup/language',
        builder: (context, state) => const LanguagePickerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/problem',
        builder: (context, state) {
          // /problem is reached two ways:
          //   - capture / type flow → extra is the raw String problem text
          //   - history tile         → extra is the full [Problem] row,
          //                             which lets us resume the saved
          //                             conversation instead of re-running
          //                             classifier + opener on the text.
          final extra = state.extra;
          if (extra is Problem) {
            return ProblemScreen(
              problemText: extra.rawText,
              resumed: extra,
            );
          }
          return ProblemScreen(
            problemText: extra is String ? extra : '',
          );
        },
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
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/subject/:name',
        builder: (context, state) =>
            SubjectTopicsScreen(name: state.pathParameters['name'] ?? ''),
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
        builder: (context, state) => const VoiceScreen(),
      ),
    ],
  );
}
