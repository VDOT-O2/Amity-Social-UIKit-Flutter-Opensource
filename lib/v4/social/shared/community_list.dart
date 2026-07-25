import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/my_community_component.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/navigation_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/shimmer_widget.dart';
import 'package:amity_uikit_beta_service/v4/utils/skeleton.dart';
import 'package:amity_uikit_beta_service/v4/utils/url_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _publicGroupApprovalStatusMetadataKey = 'publicGroupApprovalStatus';
const _publicGroupInReviewStatus = 'in_review';

Widget communityList(
  BuildContext context,
  ScrollController scrollController,
  List<AmityCommunity> communities,
  AmityThemeColor theme, {
  Set<String>? unseenCommunityIds,
}) {
  if (communities.isEmpty) {
    return communityEmptyList(context);
  }

  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: IntrinsicHeight(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        controller: scrollController,
        itemCount: communities.length,
        separatorBuilder: (context, index) {
          return Divider(
            color: theme.borderSubtle,
            thickness: 1.0,
            indent: 16,
            endIndent: 16,
            height: 25,
          );
        },
        itemBuilder: (context, index) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    communityRow(context, communities[index], theme,
                        isUnseen: unseenCommunityIds?.contains(communities[index].communityId) ?? false)
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget communityRow(BuildContext context, AmityCommunity community, AmityThemeColor theme, {bool isUnseen = false}) {
  var categoriesName = community.categories?.map((category) => category?.name).toList();
  var hasCommunityImage = (community.avatarImage?.fileUrl?.isNotEmpty ?? false);
  final isInReview = _isCommunityInReview(community);

  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      context
          .read<NavigationProvider>()
          .handleNavigation(context, event: AmityNavigationEvent.showCommunity, params: {'communityId': community.communityId});
    },
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: theme.backgroundSubtle,
            width: 80,
            height: 80,
            child: CommunityImageAvatarElement(
                avatarUrl: community.avatarImage?.getUrl(AmityImageSize.LARGE),
                placeHolderPath: hasCommunityImage ? "" : "assets/Icons/amity_ic_community_avatar_placeholder_rectangle.svg",
                placeHolderColorFilter: ColorFilter.mode(theme.textPrimary, BlendMode.srcIn),
                elementId: AmityMyCommunityElement.communityAvatar.stringValue),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      community.displayName ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (community.isOfficial ?? true)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: AmityOfficialBadgeElement(),
                    ),
                  // if (isInReview) ...[
                  //   const SizedBox(width: 8),
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  //     decoration: BoxDecoration(
                  //       color: theme.highlightColor,
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Text(
                  //       'In Review',
                  //       style: TextStyle(
                  //         fontSize: 11,
                  //         fontWeight: FontWeight.w600,
                  //         color: theme.textPrimary,
                  //       ),
                  //     ),
                  //   ),
                  // ],
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isUnseen) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.vdotGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                      child: CommunityMemberCountElement(
                    memberCount: community.membersCount,
                  )),
                ],
              ),
              if (categoriesName != null && categoriesName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!(community.isPublic ?? false) && !isInReview) ...[
                      Container(
                        width: 20,
                        height: 20,
                        transform: Matrix4.translationValues(-2, -2, 0),
                        margin: const EdgeInsets.only(right: 1),
                        child: AmityCoachGroupBadgeElement(),
                      ),
                    ],
                    Expanded(child: AmityCommunityCategoriesName(tags: categoriesName, labelOnly: true)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

bool _isCommunityInReview(AmityCommunity community) {
  final metadata = community.metadata;
  if (metadata == null) {
    return false;
  }

  final status = metadata[_publicGroupApprovalStatusMetadataKey]?.toString().trim().toLowerCase();
  return status == _publicGroupInReviewStatus;
}

Widget communitySkeletonList(AmityThemeColor theme, ConfigProvider configProvider) {
  return Container(
    decoration: BoxDecoration(color: theme.backgroundColor),
    child: Container(
      alignment: Alignment.topCenter,
      child: Shimmer(
        linearGradient: configProvider.getShimmerGradient(),
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 16),
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return Divider(
              color: theme.baseColorShade4,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
              height: 25,
            );
          },
          itemBuilder: (context, index) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(
                    isLoading: true,
                    child: communitySkeletonRow(),
                  ),
                ],
              ),
            );
          },
          itemCount: 5,
        ),
      ),
    ),
  );
}

Widget communitySkeletonRow() {
  return SizedBox(
    height: 96,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 104,
          height: 96,
          padding: const EdgeInsets.only(top: 8, left: 16, right: 8, bottom: 8),
          child: const SkeletonImage(
            height: 80,
            width: 80,
            borderRadius: 16,
          ),
        ),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 30.0),
          SkeletonText(width: 180, height: 12),
          SizedBox(height: 12.0),
          SkeletonText(
            width: 108,
            height: 10,
          )
        ]),
      ],
    ),
  );
}

Widget communityEmptyList(BuildContext context) {
  return const Center(
    child: Text('There are no communities.'),
  );
}
