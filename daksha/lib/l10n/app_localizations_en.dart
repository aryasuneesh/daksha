// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daksha';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get malayalam => 'Malayalam';

  @override
  String get chooseLanguage => 'Choose your language';

  @override
  String get chooseLanguageSubtitle =>
      'You can change this anytime in Settings.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get viewHistory => 'View history';

  @override
  String viewHistoryWithCount(int count) {
    return 'View history ($count)';
  }

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String problemsSolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems solved',
      one: '1 problem solved',
      zero: 'No problems solved yet',
    );
    return '$_temp0';
  }

  @override
  String get replayTutorial => 'Replay walkthrough';

  @override
  String get aboutDaksha => 'About';

  @override
  String get aboutBody =>
      'Daksha is an on-device Socratic study buddy for grades 5–8. Built for educational use; everything stays on your device.';

  @override
  String get back => 'Back';

  @override
  String get warmingUp => 'Warming up Daksha…';

  @override
  String get engineFailed =>
      'Daksha could not start — close other apps and reopen.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get tourSubjectsTitle => 'Pick a subject';

  @override
  String get tourSubjectsBody =>
      'Tap a subject card to see what you\'ve studied and start a new problem.';

  @override
  String get tourCaptureTitle => 'Capture a problem';

  @override
  String get tourCaptureBody =>
      'Snap a photo of your textbook or type a problem to begin.';

  @override
  String get tourHistoryTitle => 'Your history';

  @override
  String get tourHistoryBody =>
      'Past problems and explanations are saved here.';

  @override
  String get tourStreakTitle => 'Daily streak';

  @override
  String get tourStreakBody =>
      'Solve at least one problem each day to keep your streak going.';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourDone => 'Got it';
}
