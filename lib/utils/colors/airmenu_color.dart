import 'package:flutter/material.dart';

class AirMenuColors {
  AirMenuColors._();

  static const int _redPrimaryColor = 0xFFAD1B29;

  static const AirMenuColor primary = AirMenuColor(
    _redPrimaryColor,
    <int, Color>{
      0: Color(0xFFAD1B29), // main
      1: Color(0xFFB52D38),
      2: Color(0xFFBE3F47),
      3: Color(0xFFC65257),
      4: Color(0xFFCF6466),
      5: Color(0xFFD87676),
      6: Color(0xFFE08995),
      7: Color(0xFFE9ABB4),
      8: Color(0xFFF1CDD2),
      9: Color(0xFFFAEEF0),
    },
  );

  static const AirMenuColor secondary =
      AirMenuColor(_graySecondaryColor, <int, Color>{
        0: Color(_graySecondaryColor),
        1: Color(0xFF1C1C1C),
        2: Color(0xFF333333),
        3: Color(0xFF494949),
        4: Color(0xFF606060),
        5: Color(0xFF777777),
        6: Color(0xFF8D8D8D),
        7: Color(0xFFA4A4A4),
        8: Color(0xFFD2D2D2),
        9: Color(0xFFE8E8E8),
      });

  static const int _graySecondaryColor = 0xFF1C1C1C;

  static const AirMenuColor black = AirMenuColor(_black, <int, Color>{
    0: Color(_black),
    1: Color(_black),
    2: Color(_black),
    3: Color(_black),
    4: Color(_black),
    5: Color(_black),
    6: Color(_black),
    7: Color(_black),
    8: Color(_black),
    9: Color(_black),
  });

  static const int _black = 0xFF1C1C1C;
  static const AirMenuColor green = AirMenuColor(_green, <int, Color>{
    0: Color(_green),
    1: Color(0xFF13602C),
    2: Color(0xFF44B469),
    3: Color(0xFFD4DAEA),
    4: Color(0xFFE9ECF4),
    5: Color(0xFFD1DAEB),
    6: Color(0xFFE8EDF5),
  });

  static const int _green = 0xFF13602C;

  static const AirMenuColor white =
      AirMenuColor(_whitePrimaryColor, <int, Color>{
        0: Color(_whitePrimaryColor),
        1: Color(_whitePrimaryColor),
        2: Color(_whitePrimaryColor),
        3: Color(_whitePrimaryColor),
        4: Color(_whitePrimaryColor),
      });

  static const int _whitePrimaryColor = 0xFFFFFFFF;

  static const AirMenuColor success =
      AirMenuColor(_successPrimaryColor, <int, Color>{
        0: Color(_successPrimaryColor),
        1: Color(0xFFf4fbf6),
        2: Color(0xFFdff2e3),
        3: Color(0xFFc9e9d1),
        4: Color(0xFF99d5a7),
        5: Color(0xFF69c17d),
        6: Color(0xFF3db058),
        7: Color(0xFF228e3b),
        8: Color(0xFF19682b),
        9: Color(0xFF10431c),
        10: Color(0xFF08210e),
      });

  static const int _successPrimaryColor = 0xFF28a745;

  static const AirMenuColor error =
      AirMenuColor(_errorPrimaryColor, <int, Color>{
        0: Color(_errorPrimaryColor),
        1: Color(0xFFfef5f5),
        2: Color(0xFFfce4e4),
        3: Color(0xFFf9d2d2),
        4: Color(0xFFF4AAAA),
        5: Color(0xFFEE8181),
        6: Color(0xFFE95C5C),
        7: Color(0xFFD63939),
        8: Color(0xFFB02A2A),
        9: Color(0xFF8A1F1F),
        10: Color(0xFF5C1414),
      });

  static const int _errorPrimaryColor = 0xFFdc3545;

  // Text colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF606060);
  static const Color textTertiary = Color(0xFF8D8D8D);

  // Border colors
  static const Color borderDefault = Color(0xFFE0E0E0);

  // Background colors
  static const Color backgroundSecondary = Color(0xFFF5F5F5);

  /// Warning color (Orange/Amber) - Use for warnings, cautions
  static const AirMenuColor warning =
      AirMenuColor(_warningPrimaryColor, <int, Color>{
        0: Color(_warningPrimaryColor),
        1: Color(0xFFFFFBEB),
        2: Color(0xFFFEF3C7),
        3: Color(0xFFFDE68A),
        4: Color(0xFFFCD34D),
        5: Color(0xFFFBBF24),
        6: Color(0xFFF59E0B),
        7: Color(0xFFD97706),
        8: Color(0xFFB45309),
        9: Color(0xFF92400E),
        10: Color(0xFF78350F),
      });

  static const int _warningPrimaryColor = 0xFFF59E0B;

  /// Info color (Blue) - Use for informational messages
  static const AirMenuColor info = AirMenuColor(_infoPrimaryColor, <int, Color>{
    0: Color(_infoPrimaryColor),
    1: Color(0xFFEFF6FF),
    2: Color(0xFFDBEAFE),
    3: Color(0xFFBFDBFE),
    4: Color(0xFF93C5FD),
    5: Color(0xFF60A5FA),
    6: Color(0xFF3B82F6),
    7: Color(0xFF2563EB),
    8: Color(0xFF1D4ED8),
    9: Color(0xFF1E40AF),
    10: Color(0xFF1E3A8A),
  });

  static const int _infoPrimaryColor = 0xFF3B82F6;

  /// Neutral/Gray color - Use for backgrounds, borders, disabled states
  static const AirMenuColor neutral = AirMenuColor(
    _neutralPrimaryColor,
    <int, Color>{
      0: Color(_neutralPrimaryColor),
      1: Color(0xFFF9FAFB), // gray-50
      2: Color(0xFFF3F4F6), // gray-100
      3: Color(0xFFE5E7EB), // gray-200
      4: Color(0xFFD1D5DB), // gray-300
      5: Color(0xFF9CA3AF), // gray-400
      6: Color(0xFF6B7280), // gray-500
      7: Color(0xFF4B5563), // gray-600
      8: Color(0xFF374151), // gray-700
      9: Color(0xFF1F2937), // gray-800
      10: Color(0xFF111827), // gray-900
    },
  );

  static const int _neutralPrimaryColor = 0xFF6B7280;
}

class AirMenuColor extends ColorSwatch<int> {
  const AirMenuColor(super.primary, super.swatch);

  Color get shade1 => this[1]!;
  Color get shade2 => this[2]!;
  Color get shade3 => this[3]!;
  Color get shade4 => this[4]!;
  Color get shade5 => this[5]!;
  Color get shade6 => this[6]!;
  Color get shade7 => this[7]!;
  Color get shade8 => this[8]!;
  Color get shade9 => this[9]!;
  Color get shade10 => this[10]!;
}
