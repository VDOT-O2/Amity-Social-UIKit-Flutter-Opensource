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
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 6),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: theme.baseColorShade4,
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
            Container(
              child: SvgPicture.asset(
                'assets/Icons/amity_ic_community_moderator.svg',
                package: 'amity_uikit_beta_service',
                colorFilter: ColorFilter.mode(
                  theme.primaryColor,
                  BlendMode.srcIn,
                ),
                width: 12,
                height: 10,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              context.l10n.general_moderator,
              style: AmityTextStyle.captionSmall(theme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
