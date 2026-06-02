import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community_search_result/community_search_result.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/bloc/global_search_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/global_search/view_model/global_search_view_model.dart';
import 'package:amity_uikit_beta_service/v4/social/top_search_bar/top_search_bar.dart';
import 'package:amity_uikit_beta_service/v4/utils/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityCommunitySearchPage extends NewBasePage {
  AmityCommunitySearchPage({Key? key, String? pageId})
      : super(key: key, pageId: 'social_community_search_page');
  var textcontroller = TextEditingController();
  final ScrollController communityScrollController = ScrollController();

  final _debouncer = Debouncer(milliseconds: 300);

  bool isLoaded = false;
  late AmityGlobalSearchViewModel communitySearchViewModel;

  @override
  Widget buildPage(BuildContext context) {
    communitySearchViewModel = AmityGlobalSearchViewModel(
        searchType: AmityGlobalSearchType.community,
        scrollController: communityScrollController);

    return BlocProvider(
      create: (_) => GlobalSearchBloc()..add(const PreloadRecommendedCommunitiesEvent()),
      child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
        builder: (context, state) {
          if (state is GlobalSearchLoaded) {
            isLoaded = true;
            communitySearchViewModel.updateCommunityModel(
                communities: state.communities,
                isFetching: state.isFetching,
                loadMore: () {
                  context
                      .read<GlobalSearchBloc>()
                      .add(const GlobalSearchLoadMoreEvent());
                });
          }

          return Scaffold(
            backgroundColor: theme.backgroundColor,
            body: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      AmityTopSearchBarComponent(
                        pageId: pageId,
                        textcontroller: textcontroller,
                        hintText: context.l10n.global_search_hint,
                        onTextChanged: (value) {
                          _debouncer.run(() {
                            if (value.trim().isEmpty) {
                              context
                                  .read<GlobalSearchBloc>()
                                  .add(const PreloadRecommendedCommunitiesEvent());
                            } else {
                              context
                                  .read<GlobalSearchBloc>()
                                  .add(SearchCommunitiesEvent(value));
                            }
                          });
                        },
                      ),
                      if (isLoaded)
                        Expanded(
                          child: AmityCommunitySearchResultComponent(
                              pageId: pageId,
                              viewModel: communitySearchViewModel),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
