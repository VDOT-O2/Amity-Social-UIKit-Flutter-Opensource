part of 'my_community_component.dart';

class AmityCommunityCategoriesName extends BaseElement {
  final List<String?> tags;
  final bool labelOnly;

  AmityCommunityCategoriesName(
      {Key? key, String? pageId, String? componentId, required this.tags, this.labelOnly = false})
      : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId:
                AmityMyCommunityElement.communityCetegoryName.stringValue);

  @override
  Widget buildElement(BuildContext context) {
    return getCategoryRow(tags);
  }

  Widget getCategoryRow(List<String?> tags) {
    const int maxTags = 3;
    final int remainingTagsCount = tags.length - maxTags;
    final List<String?> displayedTags = tags.take(maxTags).toList();

    if (remainingTagsCount > 0) {
      displayedTags.add('+$remainingTagsCount');
    }
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double maxTagWidth =
                (constraints.maxWidth / displayedTags.length)
                    .clamp(0.0, constraints.maxWidth);

            return Wrap(
              spacing: 4.0,
              children: displayedTags.map((tag) {
                return getCategoryWidget(
                    label: tag ?? '', maxWidth: maxTagWidth, labelOnly: labelOnly);
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget getCategoryWidget({required String label, required double maxWidth, bool labelOnly = false}) {
    final textWidget = Text(
      label,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
          color: labelOnly ? theme.textPrimary : theme.baseColor,
          fontSize: 13,
          fontWeight: FontWeight.w500),
    );

    if (labelOnly) {
      return SizedBox(
        width: maxWidth,
        child: textWidget,
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: theme.baseColorShade4,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: textWidget,
    );
  }
}

class CommunityImageAvatarElement extends BaseElement {
  final String? avatarUrl;
  final String placeHolderPath;
  final ColorFilter? placeHolderColorFilter;

  CommunityImageAvatarElement(
      {Key? key,
      String? pageId,
      String? componentId,
      this.placeHolderPath =
          "assets/Icons/amity_ic_community_avatar_placeholder.svg",
        this.placeHolderColorFilter,
      required String elementId,
      required this.avatarUrl})
      : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId: elementId);

  @override
  Widget buildElement(BuildContext context) {
    return AmityNetworkImage(
        imageUrl: avatarUrl,
        placeHolderPath: placeHolderPath,
        placeHolderColorFilter: placeHolderColorFilter);
  }
}

class AmityPrivateBadgeElement extends BaseElement {
  final ColorFilter? colorFilter;

  AmityPrivateBadgeElement({
    Key? key,
    String? pageId,
    String? componentId,
    this.colorFilter,
  }) : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId:
                AmityMyCommunityElement.communityPrivateBadge.stringValue);

  @override
  Widget buildElement(BuildContext context) {
    return SvgPicture.asset("assets/Icons/amity_ic_private_badge.svg",
        colorFilter: colorFilter ?? ColorFilter.mode(theme.textPrimary, BlendMode.srcIn),
        package: 'amity_uikit_beta_service');
  }
}


class AmityCoachGroupBadgeElement extends BaseElement {
  final ColorFilter? colorFilter;

  AmityCoachGroupBadgeElement({
    Key? key,
    String? pageId,
    String? componentId,
    this.colorFilter,
  }) : super(
            key: key,
            pageId: pageId,
            componentId: componentId,
            elementId:
                AmityMyCommunityElement.communityCoachGroupBadge.stringValue);

  @override
  Widget buildElement(BuildContext context) {
    return SvgPicture.asset("assets/Icons/amity_ic_coach_group_badge.svg",
        colorFilter: colorFilter ?? ColorFilter.mode(theme.textPrimary, BlendMode.srcIn),
        package: 'amity_uikit_beta_service');
  }
}


class AmityOfficialBadgeElement extends BaseElement {
  AmityOfficialBadgeElement({
    Key? key,
    String? pageId,
    String? componentId,
  }) : super(
          key: key,
          pageId: pageId,
          componentId: componentId,
          elementId: AmityMyCommunityElement.communityOfficialBadge.stringValue,
        );

  @override
  Widget buildElement(BuildContext context) {
    return SvgPicture.asset("assets/Icons/amity_ic_official_badge.svg",
        package: 'amity_uikit_beta_service');
  }
}

class CommunityMemberCountElement extends BaseElement {
  final int? memberCount;
  final Color? color;

  CommunityMemberCountElement({
    Key? key,
    String? pageId,
    String? componentId,
    this.color,
    required this.memberCount,
  }) : super(
          key: key,
          pageId: pageId,
          componentId: componentId,
          elementId: AmityMyCommunityElement.communityMemberCount.stringValue,
        );

  @override
  Widget buildElement(BuildContext context) {
    return Text(
      '${memberCount?.formattedCompactString()} ${context.l10n.community_members.toLowerCase()}',
      style: TextStyle(
        color: color ?? theme.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }
}
