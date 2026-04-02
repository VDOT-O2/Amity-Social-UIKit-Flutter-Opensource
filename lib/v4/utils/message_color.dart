
import 'dart:ui';

import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart' show Colors;

class MessageColor {
  final AmityThemeColor theme;
  final Map<String, dynamic> config;
  late Color leftBubbleDefault;
  late Color leftBubblePressed;
  late Color leftBubbleText;
  late Color leftBubbleSubtleText;
  late Color rightBubbleDefault;
  late Color rightBubblePressed;
  late Color rightBubbleText;
  late Color rightBubbleSubtleText;
  late Color leftBubblePreviewLinkColor;
  late Color rightBubblePreviewLinkColor;
  late Color bubbleDivider;

  MessageColor({
    required this.theme,
    required this.config,
  }) {
    leftBubbleDefault = getColor('left_bubble_color', theme.leftBubbleColor);
    leftBubblePressed = getColor('left_bubble_pressed_color', theme.leftBubbleColor.darken(15));
    leftBubbleText = getColor('left_bubble_text_color', theme.leftBubbleTextColor);
    leftBubbleSubtleText = getColor('left_bubble_subtle_text_color', theme.baseColorShade2);
    rightBubbleDefault = getColor('right_bubble_color', theme.rightBubbleColor);
    rightBubblePressed = getColor('right_bubble_pressed_color', theme.rightBubbleColor.darken(15));
    rightBubbleText = getColor('right_bubble_text_color', theme.rightBubbleTextColor);
    rightBubbleSubtleText = getColor('right_bubble_subtle_text_color', theme.primaryColor.blend(ColorBlendingOption.shade2));
    leftBubblePreviewLinkColor = getColor('left_bubble_preview_link_color', theme.leftBubbleTextColor);
    rightBubblePreviewLinkColor = getColor('right_bubble_preview_link_color', theme.rightBubbleTextColor);
    bubbleDivider = getColor('bubble_divider_color', theme.baseColorShade4);
  }
  
  Color getColor(String configName, Color defaultColor) {
    try {
      final configString = config[configName] as String?;
      return _colorFromHex(configString, defaultColor);
    } catch (e) {
      return defaultColor;
    }
  }



  static Color _colorFromHex(String? hexColor, [Color defaultColor = const Color(0x00000000)]) {
    if (hexColor == null) return defaultColor;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
