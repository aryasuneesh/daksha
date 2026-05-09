// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get appTitle => 'ദക്ഷ';

  @override
  String get goodMorning => 'സുപ്രഭാതം';

  @override
  String get home => 'ഹോം';

  @override
  String get history => 'ചരിത്രം';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get language => 'ഭാഷ';

  @override
  String get english => 'ഇംഗ്ലീഷ്';

  @override
  String get hindi => 'ഹിന്ദി';

  @override
  String get malayalam => 'മലയാളം';

  @override
  String get chooseLanguage => 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseLanguageSubtitle =>
      'ക്രമീകരണങ്ങളിൽ നിന്ന് ഇത് എപ്പോൾ വേണമെങ്കിലും മാറ്റാം.';

  @override
  String get continueLabel => 'തുടരുക';

  @override
  String get viewHistory => 'ചരിത്രം കാണുക';

  @override
  String viewHistoryWithCount(int count) {
    return 'ചരിത്രം കാണുക ($count)';
  }

  @override
  String get noRecentActivity => 'സമീപകാല പ്രവർത്തനങ്ങൾ ഇല്ല';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-ദിവസ സ്ട്രീക്ക്',
      one: '1-ദിവസ സ്ട്രീക്ക്',
      zero: 'ഇതുവരെ സ്ട്രീക്ക് ഇല്ല',
    );
    return '$_temp0';
  }

  @override
  String problemsSolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count പ്രശ്നങ്ങൾ പരിഹരിച്ചു',
      one: '1 പ്രശ്നം പരിഹരിച്ചു',
      zero: 'ഇതുവരെ പ്രശ്നങ്ങളൊന്നും പരിഹരിച്ചിട്ടില്ല',
    );
    return '$_temp0';
  }

  @override
  String get replayTutorial => 'വാക്ക്‌ത്രൂ വീണ്ടും കാണുക';

  @override
  String get aboutDaksha => 'കുറിച്ച്';

  @override
  String get aboutBody =>
      'ദക്ഷ 5–8 ക്ലാസുകൾക്കായുള്ള ഉപകരണത്തിൽ പ്രവർത്തിക്കുന്ന സോക്രട്ടിക് പഠന കൂട്ടാളിയാണ്. വിദ്യാഭ്യാസ ആവശ്യങ്ങൾക്കായി നിർമ്മിച്ചത്; എല്ലാം നിങ്ങളുടെ ഉപകരണത്തിൽ തന്നെ നിലനിൽക്കുന്നു.';

  @override
  String get back => 'തിരികെ';

  @override
  String get warmingUp => 'ദക്ഷ തയ്യാറെടുക്കുന്നു…';

  @override
  String get engineFailed =>
      'ദക്ഷയ്ക്ക് ആരംഭിക്കാനായില്ല — മറ്റ് ആപ്പുകൾ അടച്ച് വീണ്ടും തുറക്കുക.';

  @override
  String get openSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get tourSubjectsTitle => 'ഒരു വിഷയം തിരഞ്ഞെടുക്കുക';

  @override
  String get tourSubjectsBody =>
      'നിങ്ങൾ പഠിച്ചവ കാണാനും പുതിയ പ്രശ്നം തുടങ്ങാനും വിഷയ കാർഡിൽ ടാപ്പ് ചെയ്യുക.';

  @override
  String get tourCaptureTitle => 'പ്രശ്നം നൽകുക';

  @override
  String get tourCaptureBody =>
      'നിങ്ങളുടെ പുസ്തകത്തിന്റെ ഫോട്ടോ എടുക്കുക അല്ലെങ്കിൽ പ്രശ്നം ടൈപ്പ് ചെയ്ത് ആരംഭിക്കുക.';

  @override
  String get tourHistoryTitle => 'നിങ്ങളുടെ ചരിത്രം';

  @override
  String get tourHistoryBody =>
      'മുൻ പ്രശ്നങ്ങളും വിശദീകരണങ്ങളും ഇവിടെ സൂക്ഷിക്കുന്നു.';

  @override
  String get tourStreakTitle => 'ദിന സ്ട്രീക്ക്';

  @override
  String get tourStreakBody =>
      'സ്ട്രീക്ക് നിലനിർത്താൻ ദിവസവും ചുരുങ്ങിയത് ഒരു പ്രശ്നമെങ്കിലും പരിഹരിക്കുക.';

  @override
  String get tourSkip => 'ഒഴിവാക്കുക';

  @override
  String get tourNext => 'അടുത്തത്';

  @override
  String get tourDone => 'മനസ്സിലായി';
}
