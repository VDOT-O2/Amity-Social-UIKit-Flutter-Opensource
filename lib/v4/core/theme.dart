import 'package:flutter/material.dart';

const kAmityCommunityPhotoRecommendedSize = Size(1600, 600);
const kAmityCommunityPhotoRatio = 1600 / 600;

class AmityTheme {
  final Color brandPrimary;
  final Color background;
  final Color backgroundSubtle;
  final Color backgroundDisabled;
  final Color surfaceCard;
  final Color surfaceRaised;
  final Color surfaceModal;
  final Color surfaceAvatar;
  final Color surfaceOverlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color iconDefault;
  final Color iconActive;
  final Color iconMuted;
  final Color border;
  final Color borderSubtle;
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
  final Color vdotGreenText;
  final Color avatarBackgroundColor;
  final Color avatarBorderColor;
  final Color avatarTextColor;
  final Color leftBubbleColor;
  final Color leftBubbleTextColor;
  final Color rightBubbleColor;
  final Color rightBubbleTextColor;

  AmityTheme({
    required this.brandPrimary,
    required this.background,
    required this.backgroundSubtle,
    required this.backgroundDisabled,
    required this.surfaceCard,
    required this.surfaceRaised,
    required this.surfaceModal,
    required this.surfaceAvatar,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.iconDefault,
    required this.iconActive,
    required this.iconMuted,
    required this.border,
    required this.borderSubtle,
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
    required this.vdotGreenText,
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
      brandPrimary: _colorFromJson(
            json,
            'brand_primary',
            aliases: ['brandPrimary', 'vdot_green'],
          ) ??
          fallbackTheme.brandPrimary,
      background: _colorFromJson(
            json,
            'background',
            aliases: ['background_color'],
          ) ??
          fallbackTheme.background,
      backgroundSubtle: _colorFromJson(
            json,
            'background_subtle',
            aliases: ['backgroundSubtle', 'base_shade4_color'],
          ) ??
          fallbackTheme.backgroundSubtle,
      backgroundDisabled: _colorFromJson(
            json,
            'background_disabled',
            aliases: ['backgroundDisabled'],
          ) ??
          fallbackTheme.backgroundDisabled,
      surfaceCard: _colorFromJson(
            json,
            'surface_card',
            aliases: ['surfaceCard'],
          ) ??
          fallbackTheme.surfaceCard,
      surfaceRaised: _colorFromJson(
            json,
            'surface_raised',
            aliases: ['surfaceRaised'],
          ) ??
          fallbackTheme.surfaceRaised,
      surfaceModal: _colorFromJson(
            json,
            'surface_modal',
            aliases: ['surfaceModal'],
          ) ??
          fallbackTheme.surfaceModal,
      surfaceAvatar: _colorFromJson(
            json,
            'surface_avatar',
            aliases: ['surfaceAvatar', 'avatar_background_color'],
          ) ??
          fallbackTheme.surfaceAvatar,
      surfaceOverlay: _colorFromJson(
            json,
            'surface_overlay',
            aliases: ['surfaceOverlay'],
          ) ??
          fallbackTheme.surfaceOverlay,
      textPrimary: _colorFromJson(
            json,
            'text_primary',
            aliases: ['textPrimary', 'base_color'],
          ) ??
          fallbackTheme.textPrimary,
      textSecondary: _colorFromJson(
            json,
            'text_secondary',
            aliases: ['textSecondary', 'base_shade2_color'],
          ) ??
          fallbackTheme.textSecondary,
      textMuted: _colorFromJson(
            json,
            'text_muted',
            aliases: ['textMuted', 'base_shade3_color'],
          ) ??
          fallbackTheme.textMuted,
      iconDefault: _colorFromJson(
            json,
            'icon_default',
            aliases: ['iconDefault', 'base_color'],
          ) ??
          fallbackTheme.iconDefault,
      iconActive: _colorFromJson(
            json,
            'icon_active',
            aliases: ['iconActive', 'base_color'],
          ) ??
          fallbackTheme.iconActive,
      iconMuted: _colorFromJson(
            json,
            'icon_muted',
            aliases: ['iconMuted', 'base_shade3_color'],
          ) ??
          fallbackTheme.iconMuted,
      border: _colorFromJson(
            json,
            'border',
            aliases: ['base_shade4_color'],
          ) ??
          fallbackTheme.border,
      borderSubtle: _colorFromJson(
            json,
            'border_subtle',
            aliases: ['borderSubtle', 'avatar_border_color'],
          ) ??
          fallbackTheme.borderSubtle,
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
      vdotGreenText: _colorFromHex(json['vdot_green_text']) ?? fallbackTheme.vdotGreenText,
      avatarBackgroundColor: _colorFromHex(json['avatar_background_color']) ?? fallbackTheme.avatarBackgroundColor,
      avatarBorderColor: _colorFromHex(json['avatar_border_color']) ?? fallbackTheme.avatarBorderColor,
      avatarTextColor: _colorFromHex(json['avatar_text_color']) ?? fallbackTheme.avatarTextColor,
      leftBubbleColor: _colorFromHex(json['left_bubble_color']) ?? fallbackTheme.leftBubbleColor,
      leftBubbleTextColor: _colorFromHex(json['left_bubble_text_color']) ?? fallbackTheme.leftBubbleTextColor,
      rightBubbleColor: _colorFromHex(json['right_bubble_color']) ?? fallbackTheme.rightBubbleColor,
      rightBubbleTextColor: _colorFromHex(json['right_bubble_text_color']) ?? fallbackTheme.rightBubbleTextColor,
    );
  }

  static Color? _colorFromJson(
    Map<String, dynamic> json,
    String key, {
    List<String> aliases = const [],
  }) {
    final value = json[key];
    if (value is String) {
      return _colorFromHex(value);
    }

    for (final alias in aliases) {
      final legacyValue = json[alias];
      if (legacyValue is String) {
        return _colorFromHex(legacyValue);
      }
    }

    return null;
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
  final Brightness brightness;
  final Color brandPrimary;
  final Color background;
  final Color backgroundSubtle;
  final Color backgroundDisabled;
  final Color surfaceCard;
  final Color surfaceRaised;
  final Color surfaceModal;
  final Color surfaceAvatar;
  final Color surfaceOverlay;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color iconDefault;
  final Color iconActive;
  final Color iconMuted;
  final Color border;
  final Color borderSubtle;
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
  final Color vdotGreenText;
  final Color avatarBackgroundColor;
  final Color avatarBorderColor;
  final Color avatarTextColor;
  final Color leftBubbleColor;
  final Color leftBubbleTextColor;
  final Color rightBubbleColor;
  final Color rightBubbleTextColor;

  bool get isDark => brightness == Brightness.dark;
  bool get isLight => brightness == Brightness.light;

  Color get iconBackground => isLight ? backgroundSubtle : surfaceRaised;
  Color get textFieldBackground => isLight ?  backgroundSubtle : surfaceCard;
  Color get textFieldBackgroundFocused => isDark ? surfaceCard : surfaceRaised;

  AmityThemeColor({
    required this.brightness,
    required this.brandPrimary,
    required this.background,
    required this.backgroundSubtle,
    required this.backgroundDisabled,
    required this.surfaceCard,
    required this.surfaceRaised,
    required this.surfaceModal,
    required this.surfaceAvatar,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.iconDefault,
    required this.iconActive,
    required this.iconMuted,
    required this.border,
    required this.borderSubtle,
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
    required this.vdotGreenText,
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
  brandPrimary: const Color(0xFF00C805),
  background: const Color(0xFFFFFFFF),
  backgroundSubtle: const Color(0xFFF5F5F5),
  backgroundDisabled: const Color(0xFFF0F0F0),
  surfaceCard: const Color(0xFFFFFFFF),
  surfaceRaised: const Color(0xFFFFFFFF),
  surfaceModal: const Color(0xFFF7F8FA),
  surfaceAvatar: const Color(0xFF0F1217),
  surfaceOverlay: const Color(0xFF2F2F2F),
  textPrimary: const Color(0xFF111111),
  textSecondary: const Color(0xFF747474),
  textMuted: const Color(0xFF989898),
  iconDefault: const Color(0xFF111111),
  iconActive: const Color(0xFF111111),
  iconMuted: const Color(0xFF989898),
  border: const Color(0xFFDCDCDC),
  borderSubtle: const Color(0xFFE7E7E7),
  primaryColor: const Color(0xFF1054DE),
  secondaryColor: const Color(0xFF292B32),
  buttonColor: const Color(0xFF111111),
  buttonTextColor: const Color(0xFFFFFFFF),
  baseColor: const Color(0xFF292B32),
  baseInverseColor: const Color(0xFF292B32),
  baseColorShade1: const Color(0xFF636878),
  baseColorShade2: const Color(0xFF898E9E),
  baseColorShade3: const Color(0xFFA5A9B5),
  baseColorShade4: const Color(0xFFE7E7E7),
  alertColor: const Color(0xFFFA4D30),
  backgroundColor: const Color(0xFFFFFFFF),
  backgroundShade1Color: const Color(0xFFF6F7F8),
  highlightColor: const Color(0xFF1054DE),
  vdotGreen: const Color(0xFF00C805),
  vdotGreenText: const Color(0xFFFFFFFF),
  avatarBackgroundColor: const Color(0xff000000),
  avatarBorderColor: const Color(0xffe7e7e7),
  avatarTextColor: const Color(0xffffffff),
  leftBubbleColor: const Color(0xFFF5F5F5),
  leftBubbleTextColor: const Color(0xFF000000),
  rightBubbleColor: const Color(0xFF00C805),
  rightBubbleTextColor: const Color(0xFFFFFFFF),
);

final darkTheme = AmityTheme(
  brandPrimary: const Color(0xFF3AFF64),
  background: const Color(0xFF06080B),
  backgroundSubtle: const Color(0xFF0C1016),
  backgroundDisabled: const Color(0xFF10151D),
  surfaceCard: const Color(0xFF1B1E22),
  surfaceRaised: const Color(0xFF25272A),
  surfaceModal: const Color(0xFF14171B),
  surfaceAvatar: const Color(0xFF0F1217),
  surfaceOverlay: const Color(0xFF2F2F2F),
  textPrimary: const Color(0xFFFFFFFF),
  textSecondary: const Color(0xFFD1D7E0),
  textMuted: const Color(0xFFA8B0BC),
  iconDefault: const Color(0xFFFFFFFF),
  iconActive: const Color(0xFFFFFFFF),
  iconMuted: const Color(0xFFA8B0BC),
  border: const Color(0xFF3E4A58),
  borderSubtle: const Color(0xFF2E3742),
  primaryColor: const Color(0xFF1054DE),
  secondaryColor: const Color(0xFF292B32),
  buttonColor: const Color(0xFFFFFFFF),
  buttonTextColor: const Color(0xFF000000),
  baseColor: const Color(0xFFEBECEF),
  baseInverseColor: const Color(0xFFFFFFFF),
  baseColorShade1: const Color(0xFFA5A9B5),
  baseColorShade2: const Color(0xFF6E7487),
  baseColorShade3: const Color(0xFF40434E),
  baseColorShade4: const Color(0xFF2E3742),
  alertColor: const Color(0xFFFA4D30),
  backgroundColor: const Color(0xFF191919),
  backgroundShade1Color: const Color(0xFF40434E),
  highlightColor: const Color(0xFF1054DE),
  vdotGreen: const Color(0xFF3AFF64),
  vdotGreenText: const Color(0xFF000000),
  avatarBackgroundColor: const Color(0xff0f1217),
  avatarBorderColor: const Color(0xff2E3742),
  avatarTextColor: const Color(0xFFFFFFFF),
  leftBubbleColor: const Color(0xFF1B1E22),
  leftBubbleTextColor: const Color(0xFFFFFFFF),
  rightBubbleColor: const Color(0xFF3AFF64),
  rightBubbleTextColor: const Color(0xFF111111),
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
