import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

class AmityUserImage extends StatelessWidget {
  final AmityUser? user;
  final AmityThemeColor theme;
  final double size;
  // final String? imageUrl;
  // final String displayName;

  const AmityUserImage({
    super.key,
    required this.user,
    required this.size,
    required this.theme,
  });

  String? get imageUrl => user?.avatarUrl;
  String get displayName => user?.displayName ?? "";

  double _mapSizeToFontSize(double size) {
    final maxFontSize = size * 0.3;

    if (size == 64) return maxFontSize > 32 ? 32 : maxFontSize;
    if (size == 56) return maxFontSize > 32 ? 32 : maxFontSize;
    if (size == 40) return maxFontSize > 20 ? 20 : maxFontSize;
    if (size == 32) return maxFontSize > 17 ? 17 : maxFontSize;
    if (size == 28) return maxFontSize > 13 ? 13 : maxFontSize;
    if (size == 16) return maxFontSize > 10 ? 10 : maxFontSize;
    return 10; // default case
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: theme.avatarBackgroundColor,
        border: Border.all(color: theme.avatarBorderColor, width: 1.0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: AmityTextStyle.custom(_mapSizeToFontSize(size), FontWeight.w400, theme.avatarTextColor)
        ),
      ),
    );
  }

  String _getInitials() {
    if (displayName.trim().isEmpty) {
      return 'A';
    }

    final nameParts = displayName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty && !kDebugMode) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          } else {
            return _buildPlaceholder();
          }
        },
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }
}
