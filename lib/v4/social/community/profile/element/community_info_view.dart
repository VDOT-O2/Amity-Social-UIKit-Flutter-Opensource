import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/svg_asset.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_membership/community_membership_page.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:flutter/material.dart';

class AmityCommunityInfoView extends BaseElement {
  final AmityCommunity community;

  AmityCommunityInfoView({super.key, required this.community}) : super(elementId: 'community_info');

  @override
  Widget buildElement(BuildContext context) {
    final postCount = community.postsCount ?? 0;
    final memberCount = community.membersCount ?? 0;
    final isPublic = community.isPublic ?? true;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0, right: 4.0),
          child: SvgAsset(
            'assets/Icons/amity_ic_community_posts.svg',
            color: theme.textSecondary,
            height: 20,
          ),
        ),
        Text(
          postCount.formattedCompactString(),
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          context.l10n.profile_posts_count(postCount),
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AmityCommunityMembershipPage(community: community),
              ),
            ),
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 1.0, right: 4.0),
                child: SvgAsset(
                  'assets/Icons/amity_ic_community_members.svg',
                  color: theme.textSecondary,
                  height: 20,
                ),
              ),
              Text(
                memberCount.formattedCompactString(),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.profile_members_count(memberCount),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        if (!isPublic) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 1.0, right: 4.0),
            child: SvgAsset(
              'assets/Icons/amity_ic_coach_group_badge.svg',
              color: theme.textSecondary,
              height: 22,
            ),
          ),
        ],
        Text(
          isPublic ? 'Public Group' : 'Coach Group',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
