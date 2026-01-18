import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AirMenuTextStyle {
  AirMenuTextStyle._();

  static final Color _fontColor = const Color(
    0xFF212121,
  ); // rgb(33, 33, 33) - Dark Gray
  static final Color _fontHintColor = Colors.grey.shade700;
  static const FontWeight _fontWeight = FontWeight.normal;

  // Using Sora font - matches Figma design system
  static TextStyle _baseStyle({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.sora(
      fontSize: fontSize,
      fontWeight: fontWeight ?? _fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color ?? _fontColor,
    );
  }

  /// Font size 28 - Heading H1
  static final TextStyle headingH1 = _baseStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
    height: 1.2,
  );

  /// Font size 24 - Heading H2
  static final TextStyle headingH2 = _baseStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.3,
  );

  /// Font size 20 - Heading H3
  static final TextStyle headingH3 = _baseStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.4,
  );

  /// Font size 18 - Heading H4 (matches Figma: 18px, 700, -0.45px letter spacing)
  static final TextStyle headingH4 = _baseStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.45,
    height: 1.55, // 28px line height / 18px font size
  );

  /// Font size 20 - Subheading H3
  static final TextStyle subheadingH3 = _baseStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Font size 16 - Subheading H5
  static final TextStyle subheadingH5 = _baseStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Font size 16 - Subheading H6
  static final TextStyle subheadingH6 = _baseStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Font size 14 - Normal text
  static final TextStyle normal = _baseStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Font size 14 - Small text
  static final TextStyle small = _baseStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  /// Font size 12 - Caption
  static final TextStyle caption = _baseStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: _fontHintColor,
  );

  /// Font size 12 - Small hint
  static final TextStyle smallHint = _baseStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: _fontHintColor,
  );

  /// Font size 10 - Tiny text
  static final TextStyle tiny = _baseStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  /// Font size 14 - Button text
  static final TextStyle button = _baseStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.4,
  );

  /// Font size 18 - Large text
  static final TextStyle large = _baseStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Font size 12 - Description text (italic)
  static final TextStyle description = _baseStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: _fontHintColor,
  ).copyWith(fontStyle: FontStyle.italic);

  /// Font size 16 - Regular text style
  static final TextStyle regularTextStyle = _baseStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
  );
}

/// Extension to add weight and styling to TextStyle
extension TextStyleExtension on TextStyle {
  TextStyle light300() {
    return copyWith(fontWeight: FontWeight.w300);
  }

  TextStyle regular() {
    return copyWith(fontWeight: FontWeight.w400);
  }

  TextStyle regularItalic() {
    return copyWith(fontWeight: FontWeight.w400, fontStyle: FontStyle.italic);
  }

  TextStyle medium500() {
    return copyWith(fontWeight: FontWeight.w500);
  }

  TextStyle bold600() {
    return copyWith(fontWeight: FontWeight.w600);
  }

  TextStyle bold700() {
    return copyWith(fontWeight: FontWeight.w700);
  }

  TextStyle black900() {
    return copyWith(fontWeight: FontWeight.w900);
  }

  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }
}
