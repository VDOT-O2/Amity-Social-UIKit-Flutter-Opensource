import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_reaction_button.dart';
import 'package:amity_uikit_beta_service/v4/social/reaction/reaction_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostItemBottom extends NewBaseComponent {
  final AmityPost post;
  final AmityPostAction action;
  final bool isReacting;
  final bool hideReactionCount;
  final bool isOptimisticUi;

  PostItemBottom({
    Key? key,
    required this.post,
    required this.action,
    this.isReacting = false,
    this.hideReactionCount = false,
    String? pageId,
    required String componentId,
    required this.isOptimisticUi,
  }) : super(key: key, pageId: pageId, componentId: componentId);

  @override
  Widget buildComponent(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Center(
                    child: PostReactionButton(
              theme: theme,
              post: post,
              action: action,
              isReacting: isReacting,
              showLabel: hideReactionCount,
              isOptimisticUi: isOptimisticUi,
              onReactionLabelTap: () {
                _showReactionsBottomSheet(context);
              },
            ))),
            const SizedBox(width: 12),
            Expanded(child: Center(child: getCommentButton(context, hideReactionCount))),
          ],
        ));
  }

  void _showReactionsBottomSheet(BuildContext context) {
    if ((post.reactionCount ?? 0) <= 0) {
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.25,
          maxChildSize: 0.75,
          builder: (sheetContext, scrollController) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(sheetContext).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: AmityReactionList(
                pageId: pageId,
                referenceId: post.postId ?? '',
                referenceType: AmityReactionReferenceType.POST,
              ),
            );
          },
        );
      },
    );
  }

  Widget getCommentButton(BuildContext context, bool hideCommentCount) {
    final commentCountText = context.l10n.post_comment_count(post.commentCount ?? 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/Icons/amity_ic_post_comment.svg',
          package: 'amity_uikit_beta_service',
          width: 20,
          height: 17,
          colorFilter: ColorFilter.mode(
            theme.textPrimary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          hideCommentCount ? context.l10n.post_comment : commentCountText,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget getShareButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/Icons/amity_ic_post_share.svg',
          package: 'amity_uikit_beta_service',
          width: 20,
          height: 18,
        ),
        const SizedBox(width: 4),
        Text(
          context.l10n.post_share,
          style: TextStyle(
            color: theme.baseColorShade2,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
