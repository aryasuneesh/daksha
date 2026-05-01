import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:daksha/features/common/language_toggle.dart';

export 'package:daksha/features/common/language_toggle.dart' show AppLanguage;

class I18n {
  final Map<String, String> _strings;

  I18n._(this._strings);

  static Future<I18n> load(AppLanguage lang) async {
    final langCode = lang.name; // 'en', 'hi', 'ml'
    final raw = await rootBundle.loadString('assets/i18n/$langCode.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    return I18n._(map.map((k, v) => MapEntry(k, v.toString())));
  }

  /// Get a localized string. Optionally replace {n} with [n].
  String get(String key, {int? n}) {
    final s = _strings[key] ?? key;
    if (n != null) return s.replaceAll('{n}', '$n');
    return s;
  }
}
