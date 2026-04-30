import 'package:flutter/material.dart';
import 'design_tokens.dart';

enum _Script { latin, indic }

abstract final class DakshaTypography {
  static const display   = TextStyle(fontFamily: 'DMSans', fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 28, fontWeight: FontWeight.w700, height: 1.2, color: DT.textStrong);
  static const headingLg = TextStyle(fontFamily: 'DMSans', fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 22, fontWeight: FontWeight.w700, height: 1.2, color: DT.textStrong);
  static const headingMd = TextStyle(fontFamily: 'DMSans', fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: DT.textStrong);
  static const body      = TextStyle(fontFamily: 'DMSans', fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 16, fontWeight: FontWeight.w400, height: 1.6, color: DT.text);
  static const sm        = TextStyle(fontFamily: 'DMSans', fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: DT.text);
  static const caption   = TextStyle(fontFamily: 'DMSans', fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 13, fontWeight: FontWeight.w400, height: 1.4, color: DT.text);
  static const mono      = TextStyle(fontFamily: 'DMMono',  fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansMalayalam'], fontSize: 22, fontWeight: FontWeight.w700, height: 1.0, color: DT.textStrong);

  /// Returns [base] with script-aware line-height boost for Indic scripts.
  /// Pass a short sample of the string being rendered (first ~20 chars).
  static TextStyle withScript(TextStyle base, String? sample) {
    final script = _detectScript(sample ?? '');
    if (script == _Script.indic) {
      return base.copyWith(height: (base.height ?? 1.6) * 1.12);
    }
    return base;
  }

  static _Script _detectScript(String sample) {
    for (final rune in sample.runes) {
      // Devanagari: U+0900–U+097F
      if (rune >= 0x0900 && rune <= 0x097F) return _Script.indic;
      // Malayalam: U+0D00–U+0D7F
      if (rune >= 0x0D00 && rune <= 0x0D7F) return _Script.indic;
    }
    return _Script.latin;
  }
}
