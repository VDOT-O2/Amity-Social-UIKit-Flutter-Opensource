import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class PostReactionButton extends StatelessWidget {
  final AmityPost post;
  final AmityPostAction action;
  final bool isReacting;
  final bool showLabel;
  final bool isOptimisticUi;
  final AmityThemeColor theme;
  final VoidCallback? onReactionLabelTap;

  const PostReactionButton({
    super.key,
    required this.post,
    required this.action,
    required this.isReacting,
    required this.theme,
    this.showLabel = false,
    this.isOptimisticUi = false,
    this.onReactionLabelTap,
  });

  @override
  Widget build(BuildContext context) {
    var reactionIcon = SvgPicture.asset(
      'assets/Icons/amity_ic_post_quick_reaction.svg',
      package: 'amity_uikit_beta_service',
      width: 20,
      height: 20,
    );
    if (post.myReactions?.isNotEmpty ?? false) {
      reactionIcon = post.myReactions!.first == 'like'
          ? SvgPicture.asset(
              'assets/Icons/amity_ic_post_quick_reaction.svg',
              package: 'amity_uikit_beta_service',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.vdotGreen,
                BlendMode.srcIn,
              ),
            )
          : SvgPicture.asset(
              'assets/Icons/amity_ic_post_reaction_heart.svg',
              package: 'amity_uikit_beta_service',
              width: 20,
              height: 20,
            );
    }
    // var iconAsset = 'assets/Icons/amity_ic_post_quick_reaction.svg';
    // if (post.myReactions?.isNotEmpty ?? false) {
    //   iconAsset = post.myReactions!.first == 'like'
    //       ? 'assets/Icons/amity_ic_post_reaction_like.svg'
    //       : 'assets/Icons/amity_ic_post_reaction_heart.svg';
    // }
    return Container(
      height: 44,
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (!isReacting) {
                if (post.myReactions?.isNotEmpty ?? false) {
                  action.onRemoveReaction("like");
                } else {
                  action.onAddReaction("like");
                }
                HapticFeedback.lightImpact();
              }
            },
            child: (isReacting && isOptimisticUi)
                ? Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    child: loadingIndicator(context, !(post.myReactions?.isNotEmpty ?? false)))
                : Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(bottom: 4),
                    child: reactionIcon,
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onReactionLabelTap,
            child: (isReacting && isOptimisticUi)
                ? getReactingLabel(context, post, showLabel)
                : getReactionLabel(context, post, showLabel),
          ),
        ],
      ),
    );
  }

  Widget getReactionLabel(BuildContext context, AmityPost post, bool showLabel) {
    final appTheme = Provider.of<ConfigProvider>(context).getTheme(null, null);
    var text = showLabel ?  context.l10n.post_like :  context.l10n.post_like_count(post.reactionCount ?? 0);

    return Text(
      text,
      style: TextStyle(
        color: appTheme.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget getReactingLabel(BuildContext context, AmityPost post, bool showLabel) {
    bool hasMyReaction = post.myReactions?.isNotEmpty ?? false;
    final isAdding = !hasMyReaction;
    var count = post.reactionCount ?? 0;
    if (isAdding) {
      count++;
    } else {
      count--;
    }
    var text = showLabel ?  context.l10n.post_like :  context.l10n.post_like_count(count);
    
    return Text(
      text,
      style: TextStyle(
        color: theme.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget loadingIndicator(BuildContext context, bool isAdding) {
    return (isAdding)
        ? Container(
            alignment: Alignment.center,
            height: 44,
            child: SvgPicture.asset(
              'assets/Icons/amity_ic_post_quick_reaction.svg',
              package: 'amity_uikit_beta_service',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.vdotGreen,
                BlendMode.srcIn,
              ),
            ))
        : Container(
            alignment: Alignment.center,
            height: 44,
            child: SvgPicture.asset(
              'assets/Icons/amity_ic_post_quick_reaction.svg',
              package: 'amity_uikit_beta_service',
              width: 20,
              height: 20,
            ),
          );
  }
}
