import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/base_element.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/bloc/my_community_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/shared/community_list.dart';
import 'package:amity_uikit_beta_service/v4/utils/compact_string_converter.dart';
import 'package:amity_uikit_beta_service/v4/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

part 'my_community_elements.dart';
part 'my_community_ui_ids.dart';

class AmityMyCommunitiesComponent extends BaseStatefulComponent {
  final String? noCommunitiesHint;

  AmityMyCommunitiesComponent({Key? key, String? pageId, this.noCommunitiesHint})
      : super(key: key, pageId: pageId, componentId: AmityComponent.myCommunities.stringValue);

  @override
  State createState() => _AmityMyCommunitiesComponentState();
}

class _AmityMyCommunitiesComponentState extends BaseStatefulComponentState<AmityMyCommunitiesComponent> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == (scrollController.position.maxScrollExtent)) {
        context.read<MyCommunityBloc>().add(MyCommunityEventLoadMore());
      }
    });

    super.initState();
  }

  @override
  Widget buildComponent(BuildContext context) {
    return BlocProvider(
      create: (context) => MyCommunityBloc()..add(MyCommunityEventInitial()),
      child: Builder(builder: (context) {
        return BlocBuilder<MyCommunityBloc, MyCommunityState>(
          builder: (context, state) {
            if (state is MyCommunityLoading) {
              return communitySkeletonList(theme, configProvider);
            } else if (state is MyCommunityLoaded) {
              if (state.list.isEmpty) {
                return _MyCommunitiesListEmptyState(
                  theme: theme,
                  noCommunitiesHint: widget.noCommunitiesHint ?? '',
                );
              }

              return Column(children: [
                Expanded(
                  child: communityList(context, scrollController, state.list, theme),
                ),
              ]);
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }
}

class _MyCommunitiesListEmptyState extends StatelessWidget {
  final AmityThemeColor theme;
  final String noCommunitiesHint;

  const _MyCommunitiesListEmptyState({
    required this.theme,
    required this.noCommunitiesHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/Icons/amity_ic_chat_empty_state.svg',
            package: 'amity_uikit_beta_service',
            width: 160,
            height: 140,
          ),
          const SizedBox(height: 16),
          Text(
            "No groups yet",
            style: AmityTextStyle.titleSemiBold(theme.baseColorShade3),
          ),
          if (noCommunitiesHint.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              noCommunitiesHint,
              style: AmityTextStyle.caption(theme.baseColorShade3),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
