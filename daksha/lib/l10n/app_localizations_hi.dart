// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'दक्ष';

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get home => 'होम';

  @override
  String get history => 'इतिहास';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get malayalam => 'मलयालम';

  @override
  String get chooseLanguage => 'अपनी भाषा चुनें';

  @override
  String get chooseLanguageSubtitle =>
      'आप इसे सेटिंग्स में कभी भी बदल सकते हैं।';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get viewHistory => 'इतिहास देखें';

  @override
  String viewHistoryWithCount(int count) {
    return 'इतिहास देखें ($count)';
  }

  @override
  String get noRecentActivity => 'कोई हाल की गतिविधि नहीं';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-दिन की स्ट्रीक',
      one: '1-दिन की स्ट्रीक',
      zero: 'अभी कोई स्ट्रीक नहीं',
    );
    return '$_temp0';
  }

  @override
  String problemsSolved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count प्रश्न हल किए',
      one: '1 प्रश्न हल किया',
      zero: 'अभी तक कोई प्रश्न हल नहीं',
    );
    return '$_temp0';
  }

  @override
  String get replayTutorial => 'वॉकथ्रू फिर से देखें';

  @override
  String get aboutDaksha => 'बारे में';

  @override
  String get aboutBody =>
      'दक्ष कक्षा 5–8 के लिए डिवाइस पर चलने वाला सॉक्रेटिक अध्ययन साथी है। शैक्षिक उपयोग के लिए बनाया गया; सारा डेटा आपके डिवाइस पर रहता है।';

  @override
  String get back => 'वापस';

  @override
  String get warmingUp => 'दक्ष तैयार हो रहा है…';

  @override
  String get engineFailed =>
      'दक्ष शुरू नहीं हो सका — अन्य ऐप बंद करें और फिर से खोलें।';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get tourSubjectsTitle => 'विषय चुनें';

  @override
  String get tourSubjectsBody =>
      'अपने पढ़े हुए विषय देखने और नया प्रश्न शुरू करने के लिए विषय कार्ड पर टैप करें।';

  @override
  String get tourCaptureTitle => 'प्रश्न दर्ज करें';

  @override
  String get tourCaptureBody =>
      'अपनी किताब की फ़ोटो लें या प्रश्न टाइप करके शुरू करें।';

  @override
  String get tourHistoryTitle => 'आपका इतिहास';

  @override
  String get tourHistoryBody =>
      'पुराने प्रश्न और समझाइशें यहाँ सहेजे जाते हैं।';

  @override
  String get tourStreakTitle => 'रोज़ाना स्ट्रीक';

  @override
  String get tourStreakBody =>
      'स्ट्रीक बनाए रखने के लिए हर दिन कम से कम एक प्रश्न हल करें।';

  @override
  String get tourSkip => 'छोड़ें';

  @override
  String get tourNext => 'आगे';

  @override
  String get tourDone => 'समझ गया';
}
