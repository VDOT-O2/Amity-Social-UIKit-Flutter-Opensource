import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/social/shared/community_list.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmityCommunitySearchResultComponent extends BaseStatefulComponent {
  final AmityGlobalSearchViewModel viewModel;

  const AmityCommunitySearchResultComponent({
    Key? key,
    String? pageId,
    required this.viewModel,
  }) : super(key: key, pageId: pageId, componentId: 'community_search_result');

  @override
  State createState() => _AmityCommunitySearchResultComponentState();
}

class _AmityCommunitySearchResultComponentState
    extends BaseStatefulComponentState<AmityCommunitySearchResultComponent> {
  @override
  void initState() {
    widget.viewModel.scrollController.addListener(_onScrollChanged);
    super.initState();
  }

  void _onScrollChanged() {
    final onLoadMore = widget.viewModel.onLoadMore;
    if (onLoadMore == null) {
      return;
    }

    final scrollController = widget.viewModel.scrollController;
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      onLoadMore.call();
    }
  }

  @override
  Widget buildComponent(BuildContext context) {
    final viewModel = widget.viewModel;

    if (viewModel.communities.isEmpty) {
      if (viewModel.isCommunitiesFetching) {
        return Container(
          child: communitySkeletonList(theme, configProvider),
        );
      } else {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/Icons/amity_ic_search_not_found.svg',
                package: 'amity_uikit_beta_service',
                colorFilter: ColorFilter.mode(theme.baseColorShade4, BlendMode.srcIn),
                width: 47,
                height: 47,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.search_no_results,
                style: AmityTextStyle.titleBold(theme.baseColorShade3),
              ),
            ],
          ),
        );
      }
    } else {
      return Container(
        color: theme.backgroundColor,
        child: communityList(
          context,
          viewModel.scrollController,
          viewModel.communities,
          theme,
        ),
      );
    }
  }
}
