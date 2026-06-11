import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommunityModeratorBadge extends StatelessWidget {
  const CommunityModeratorBadge({super.key, required this.theme});

  final AmityThemeColor theme;

  @override
  Widget build(BuildContext context) {
    final bgColor = theme.isLight ? theme.backgroundSubtle : theme.surfaceRaised;
    final textColor = theme.isLight ? theme.textPrimary : theme.textSecondary;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 3, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/Icons/amity_ic_community_moderator.svg',
              package: 'amity_uikit_beta_service',
              colorFilter: ColorFilter.mode(
                textColor,
                BlendMode.srcIn,
              ),
              width: 12,
              height: 10,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.general_moderator,
              style: AmityTextStyle.captionSmall(textColor),
            ),
          ],
        ),
      ),
    );
  }
}
