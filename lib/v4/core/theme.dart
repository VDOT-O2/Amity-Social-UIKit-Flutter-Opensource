import 'package:flutter/material.dart';

class AmityTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color baseColor;
  final Color baseInverseColor;
  final Color baseColorShade1;
  final Color baseColorShade2;
  final Color baseColorShade3;
  final Color baseColorShade4;
  final Color alertColor;
  final Color backgroundColor;
  final Color backgroundShade1Color;
  final Color highlightColor;
  final Color vdotGreen;
  final Color avatarBackgroundColor;
  final Color avatarBorderColor;
  final Color avatarTextColor;
  final Color leftBubbleColor;
  final Color leftBubbleTextColor;
  final Color rightBubbleColor;
  final Color rightBubbleTextColor;

  AmityTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.baseColor,
    required this.baseInverseColor,
    required this.baseColorShade1,
    required this.baseColorShade2,
    required this.baseColorShade3,
    required this.baseColorShade4,
    required this.alertColor,
    required this.backgroundColor,
    required this.backgroundShade1Color,
    required this.highlightColor,
    required this.vdotGreen,
    required this.avatarBackgroundColor,
    required this.avatarBorderColor,
    required this.avatarTextColor,
    required this.leftBubbleColor,
    required this.leftBubbleTextColor,
    required this.rightBubbleColor,
    required this.rightBubbleTextColor,
  });

  factory AmityTheme.fromJson(Map<String, dynamic> json, AmityTheme fallbackTheme) {
    return AmityTheme(
      primaryColor: _colorFromHex(json['primary_color']) ?? fallbackTheme.primaryColor,
      secondaryColor: _colorFromHex(json['secondary_color']) ?? fallbackTheme.secondaryColor,
      buttonColor: _colorFromHex(json['button_color']) ?? fallbackTheme.buttonColor,
      buttonTextColor: _colorFromHex(json['button_text_color']) ?? fallbackTheme.buttonTextColor,
      baseColor: _colorFromHex(json['base_color']) ?? fallbackTheme.baseColor,
      baseInverseColor: _colorFromHex(json['base_inverse_color']) ?? fallbackTheme.baseInverseColor,
      baseColorShade1: _colorFromHex(json['base_shade1_color']) ?? fallbackTheme.baseColorShade1,
      baseColorShade2: _colorFromHex(json['base_shade2_color']) ?? fallbackTheme.baseColorShade2,
      baseColorShade3: _colorFromHex(json['base_shade3_color']) ?? fallbackTheme.baseColorShade3,
      baseColorShade4: _colorFromHex(json['base_shade4_color']) ?? fallbackTheme.baseColorShade4,
      alertColor: _colorFromHex(json['alert_color']) ?? fallbackTheme.alertColor,
      backgroundColor: _colorFromHex(json['background_color']) ?? fallbackTheme.backgroundColor,
      backgroundShade1Color: _colorFromHex(json['background_shade1_color']) ?? fallbackTheme.backgroundShade1Color,
      highlightColor: _colorFromHex(json['highlight_color']) ?? fallbackTheme.highlightColor,
      vdotGreen: _colorFromHex(json['vdot_green']) ?? fallbackTheme.vdotGreen,
      avatarBackgroundColor: _colorFromHex(json['avatar_background_color']) ?? fallbackTheme.avatarBackgroundColor,
      avatarBorderColor: _colorFromHex(json['avatar_border_color']) ?? fallbackTheme.avatarBorderColor,
      avatarTextColor: _colorFromHex(json['avatar_text_color']) ?? fallbackTheme.avatarTextColor,
      leftBubbleColor: _colorFromHex(json['left_bubble_color']) ?? fallbackTheme.leftBubbleColor,
      leftBubbleTextColor: _colorFromHex(json['left_bubble_text_color']) ?? fallbackTheme.leftBubbleTextColor,
      rightBubbleColor: _colorFromHex(json['right_bubble_color']) ?? fallbackTheme.rightBubbleColor,
      rightBubbleTextColor: _colorFromHex(json['right_bubble_text_color']) ?? fallbackTheme.rightBubbleTextColor,
    );
  }

  static Color? _colorFromHex(String? hexColor) {
    if (hexColor == null) return null;
    hexColor = hexColor.replaceAll('#', '');

    // Validate hex characters
    if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(hexColor)) {
      return null;
    }
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    try {
      final colorValue = int.parse(hexColor, radix: 16);
      return Color(colorValue);
    } catch (e) {
      return null;
    }
  }
}

class AmityThemeColor {
  final Color primaryColor;
  final Color secondaryColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color baseColor;
  final Color baseInverseColor;
  final Color baseColorShade1;
  final Color baseColorShade2;
  final Color baseColorShade3;
  final Color baseColorShade4;
  final Color alertColor;
  final Color backgroundColor;
  final Color backgroundShade1Color;
  final Color highlightColor;
  final Color vdotGreen;
  final Color avatarBackgroundColor;
  final Color avatarBorderColor;
  final Color avatarTextColor;
  final Color leftBubbleColor;
  final Color leftBubbleTextColor;
  final Color rightBubbleColor;
  final Color rightBubbleTextColor;

  AmityThemeColor({
    required this.primaryColor,
    required this.secondaryColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.baseColor,
    required this.baseInverseColor,
    required this.baseColorShade1,
    required this.baseColorShade2,
    required this.baseColorShade3,
    required this.baseColorShade4,
    required this.alertColor,
    required this.backgroundColor,
    required this.backgroundShade1Color,
    required this.highlightColor,
    required this.vdotGreen,
    required this.avatarBackgroundColor,
    required this.avatarBorderColor,
    required this.avatarTextColor,
    required this.leftBubbleColor,
    required this.leftBubbleTextColor,
    required this.rightBubbleColor,
    required this.rightBubbleTextColor,
  });
}

// Enum to define theme styles
enum AmityThemeStyle { light, dark, system }

final lightTheme = AmityTheme(
  primaryColor: const Color(0xFF1054DE),
  secondaryColor: const Color(0xFF292B32),
  buttonColor: const Color(0xFF111111),
  buttonTextColor: const Color(0xFFFFFFFF),
  baseColor: const Color(0xFF292B32),
  baseInverseColor: const Color(0xFF292B32),
  baseColorShade1: const Color(0xFF636878),
  baseColorShade2: const Color(0xFF898E9E),
  baseColorShade3: const Color(0xFFA5A9B5),
  baseColorShade4: const Color(0xFFEBECEF),
  alertColor: const Color(0xFFFA4D30),
  backgroundColor: const Color(0xFFFFFFFF),
  backgroundShade1Color: const Color(0xFFF6F7F8),
  highlightColor: const Color(0xFF1054DE),
  vdotGreen: const Color(0xFF00C805),
  avatarBackgroundColor: const Color(0xff000000),
  avatarBorderColor: const Color(0xffd9d9d9),
  avatarTextColor: const Color(0xffffffff),
  leftBubbleColor: const Color(0xFFF1F1F1),
  leftBubbleTextColor: const Color(0xFF000000),
  rightBubbleColor: const Color(0xFF000000),
  rightBubbleTextColor: const Color(0xFFFFFFFF),
);

final darkTheme = AmityTheme(
  primaryColor: const Color(0xFF1054DE),
  secondaryColor: const Color(0xFF292B32),
  buttonColor: const Color(0xFFFFFFFF),
  buttonTextColor: const Color(0xFF000000),
  baseColor: const Color(0xFFEBECEF),
  baseInverseColor: const Color(0xFFFFFFFF),
  baseColorShade1: const Color(0xFFA5A9B5),
  baseColorShade2: const Color(0xFF6E7487),
  baseColorShade3: const Color(0xFF40434E),
  baseColorShade4: const Color(0xFF292B32),
  alertColor: const Color(0xFFFA4D30),
  backgroundColor: const Color(0xFF191919),
  backgroundShade1Color: const Color(0xFF40434E),
  highlightColor: const Color(0xFF1054DE),
  vdotGreen: const Color(0xFF3AFF64),
  avatarBackgroundColor: const Color(0xff0f1217),
  avatarBorderColor: const Color(0xff2E3742),
  avatarTextColor: const Color(0xFFFFFFFF),
  leftBubbleColor: const Color(0xFF222222),
  leftBubbleTextColor: const Color(0xFFFFFFFF),
  rightBubbleColor: const Color(0xFFFFFFFF),
  rightBubbleTextColor: const Color(0xFF000000),
);

enum ColorBlendingOption {
  shade1(25),
  shade2(40),
  shade3(50),
  shade4(75);

  final double luminance;
  const ColorBlendingOption(this.luminance);
}

extension ColorBlending on Color {
  Color blend(ColorBlendingOption option) {
    final hslColor = HSLColor.fromColor(this);
    final blendedHslColor = hslColor.withLightness(
      (hslColor.lightness + option.luminance / 100).clamp(0.0, 1.0),
    );
    return blendedHslColor.toColor();
  }

  Color darken(double luminance) {
    final hslColor = HSLColor.fromColor(this);
    final blendedHslColor = hslColor.withLightness(
      (hslColor.lightness - luminance / 100).clamp(0.0, 1.0),
    );
    return blendedHslColor.toColor();
  }
}
