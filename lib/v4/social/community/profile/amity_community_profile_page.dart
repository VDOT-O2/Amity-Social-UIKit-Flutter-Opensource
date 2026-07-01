import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_page.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/core/ui/bottom_sheet_menu.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_feed/community_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_media_feed/community_image_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_media_feed/community_video_feed_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_pin/community_pin_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/community_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/bloc/community_profile_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/component/community_header_component.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_cover_view.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_join_button.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_pending_post.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/element/community_profile_tab.dart';
import 'package:amity_uikit_beta_service/v4/social/my_community/my_community_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_model.dart';
import 'package:amity_uikit_beta_service/v4/social/post_composer_page/post_composer_page.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component.dart';
import 'package:amity_uikit_beta_service/v4/social/story/target/amity_story_tab_component_type.dart';
import 'package:amity_uikit_beta_service/v4/utils/amity_dialog.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider.dart';
import 'package:amity_uikit_beta_service/v4/utils/config_provider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../post_poll_composer_page/post_poll_composer_page.dart';

class AmityCommunityProfilePage extends NewBasePage {
  final String communityId;
  AmityCommunityProfilePage({super.key, required this.communityId}) : super(pageId: 'community_profile');

  final ScrollController _scrollController = ScrollController();

  @override
  Widget buildPage(BuildContext context) {
    return BlocProvider(
        create: (context) => CommunityProfileBloc(communityId, _scrollController),
        child: Builder(builder: (context) {
          return BlocBuilder<CommunityProfileBloc, CommunityProfileState>(builder: (context, state) {
            final featureConfig = configProvider.getFeatureConfig();
            final bgColor = theme.isLight ? theme.borderSubtle : theme.surfaceRaised;
            final mediaQuery = MediaQuery.of(context);
            final bottomInset = mediaQuery.viewPadding.bottom > mediaQuery.systemGestureInsets.bottom
                ? mediaQuery.viewPadding.bottom
                : mediaQuery.systemGestureInsets.bottom;

            return Scaffold(
              backgroundColor: bgColor,
              body: CustomScrollView(controller: state.scrollController, slivers: <Widget>[
                _buildAppBar(context, state),
                _buildHeader(context, state),
                _buildJoinButton(context, state, theme),
                _buildStoryTab(context, state, featureConfig),
                _buildPendingPost(context, state),
                _buildFeedTabSelector(context, state),
                _buildFeed(context, state),
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomInset),
                ),
              ]),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: (state.isJoined && !(state.community?.onlyAdminCanPost == true && !state.isModerator))
                  ? Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showActions(context, state.canManageStory, state.community, state.isModerator);
                        },
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: ShapeDecoration(
                                    color: theme.buttonColor,
                                    shape: const OvalBorder(),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                top: 16,
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: SvgPicture.asset(
                                          'assets/Icons/amity_ic_plus_button.svg',
                                          package: 'amity_uikit_beta_service',
                                          width: 32,
                                          height: 32,
                                          colorFilter: ColorFilter.mode(theme.buttonTextColor, BlendMode.srcIn),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            );
          });
        }));

    // final statusBarHeight = Platform.isIOS
    //     ? 44.0
    //     : 24.0; // iOS status bar height is 44 and android status bar height is 34
    // final appBarHeight = statusBarHeight + 56;
    // return BlocProvider(
    //   create: (context) => CommunityProfileBloc(communityId, _scrollController),
    //   child: Builder(builder: (context) {
    //     return BlocBuilder<CommunityProfileBloc, CommunityProfileState>(
    //       builder: (context, state) {
    //         state.scrollController.addListener(() {
    //           if (state.scrollController.hasClients &&
    //               state.scrollController.offset > 330) {
    //             context
    //                 .read<CommunityProfileBloc>()
    //                 .add(CommunityProfileEventCollapsed());
    //           } else {
    //             context
    //                 .read<CommunityProfileBloc>()
    //                 .add(CommunityProfileEventExpanded());
    //           }
    //         });

    //         final featureConfig = configProvider.getFeatureConfig();

    //         return Scaffold(
    //           backgroundColor: theme.baseColorShade4,
    //           body: CustomScrollView(
    //             controller: state.scrollController,
    //             slivers: <Widget>[
    //               _buildAppBar(context, state),
    //               _buildHeader(context, state),
    //               _buildJoinButton(context, state, theme),
    //               _buildStoryTab(context, state, featureConfig),
    //               _buildPendingPost(context, state),
    //               _buildFeedTabSelector(context, state),
    //               _buildFeed(context, state),
    //             ],
    //           ),
    //
    //         );
    //       },
    //     );
    //   }),
    // );
  }

  void showActions(BuildContext context, bool canManageStory, AmityCommunity? community, bool isModerator) {
    final postOption = BottomSheetMenuOption(
        title: context.l10n.general_post,
        icon: "assets/Icons/amity_ic_create_post_button.svg",
        onTap: () {
          // Dismiss popup
          Navigator.of(context).pop();

          final createOptions = AmityPostComposerOptions.createOptions(
              targetId: communityId, community: community, targetType: AmityPostTargetType.COMMUNITY);

          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityPostComposerPage(
              options: createOptions,
              onPopRequested: (shouldPopCaller) {
                if (shouldPopCaller) {
                  // Show dialog if post review is enabled and user is not a moderator
                  if (community?.isPostReviewEnabled == true && !isModerator) {
                    _showPostReviewDialog(context);
                  }
                }
              },
            ),
          ));
        });

    final storyOption = BottomSheetMenuOption(
        title: context.l10n.general_story,
        icon: "assets/Icons/ic_create_stroy_black.svg",
        onTap: () {
          // Dismiss bottom sheet
          Navigator.pop(context);

          // Show story creation screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return CreateStoryConfigProviderWidget(
                  targetType: AmityStoryTargetType.COMMUNITY,
                  targetId: communityId,
                  pageId: 'create_story_page',
                );
              },
            ),
          );
        });

    final pollOption = BottomSheetMenuOption(
        title: context.l10n.general_poll,
        icon: "assets/Icons/amity_ic_create_poll_button.svg",
        onTap: () {
          // Dismiss popup
          Navigator.of(context).pop();

          Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityPollPostComposerPage(
              targetId: communityId,
              targetType: AmityPostTargetType.COMMUNITY,
              onPopRequested: (shouldPopCaller) {
                if (shouldPopCaller) {
                  // Show dialog if post review is enabled and user is not a moderator
                  if (community?.isPostReviewEnabled == true && !isModerator) {
                    _showPostReviewDialog(context);
                  }
                }
              },
            ),
          ));
        });

    List<BottomSheetMenuOption> userActions = [];

    final featureConfig = configProvider.getFeatureConfig();

    if (featureConfig.post.isPostCreationEnabled()) {
      userActions.add(postOption);
    }

    if (featureConfig.story.createEnabled && canManageStory) {
      userActions.add(storyOption);
    }

    if (featureConfig.post.poll.createEnabled) {
      userActions.add(pollOption);
    }

    BottomSheetMenu(options: userActions).show(context, theme);
  }

  void showCommunityProfileAction(
    BuildContext context,
    AmityThemeColor theme,
    bool canManageStory,
    AmityCommunity? community,
    bool isModerator,
  ) {
    double height = 0;
    double baseHeight = 80;
    double itemHeight = 48;
    double itemCount = 3;
    height = baseHeight + (itemHeight * itemCount);

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return SizedBox(
            height: height,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 36,
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: ShapeDecoration(
                          color: theme.baseColorShade3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    final createOptions = AmityPostComposerOptions.createOptions(
                        targetId: communityId, community: community, targetType: AmityPostTargetType.COMMUNITY);
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween = Tween(begin: begin, end: end);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: curve,
                          );

                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        },
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) => PopScope(
                          canPop: true,
                          child: AmityPostComposerPage(
                            options: createOptions,
                            onPopRequested: (shouldPopCaller) {
                              if (shouldPopCaller) {
                                Navigator.of(context).pop();
                                // Show dialog if post review is enabled and user is not a moderator
                                if (community?.isPostReviewEnabled == true && !isModerator) {
                                  _showPostReviewDialog(context);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_create_post_button.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          context.l10n.general_post,
                          style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (canManageStory)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return CreateStoryConfigProviderWidget(
                              targetType: AmityStoryTargetType.COMMUNITY,
                              targetId: communityId,
                              pageId: 'create_story_page',
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: SvgPicture.asset(
                              'assets/Icons/ic_create_stroy_black.svg',
                              package: 'amity_uikit_beta_service',
                              width: 24,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n.general_story,
                            style: TextStyle(
                              color: theme.baseColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween = Tween(begin: begin, end: end);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: curve,
                          );

                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        },
                        reverseTransitionDuration: Duration.zero,
                        pageBuilder: (context, animation, secondaryAnimation) => PopScope(
                          canPop: true,
                          child: AmityPollPostComposerPage(
                            targetId: communityId,
                            targetType: AmityPostTargetType.COMMUNITY,
                            targetCommunityName: community?.displayName ?? '',
                            onPopRequested: (shouldPopCaller) {
                              if (shouldPopCaller) {
                                Navigator.of(context).pop();
                                // Show dialog if post review is enabled and user is not a moderator
                                if (community?.isPostReviewEnabled == true && !isModerator) {
                                  _showPostReviewDialog(context);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: SvgPicture.asset(
                            'assets/Icons/amity_ic_create_poll_button.svg',
                            package: 'amity_uikit_beta_service',
                            width: 24,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          context.l10n.general_poll,
                          style: TextStyle(
                            color: theme.baseColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showPostReviewDialog(BuildContext context) {
    AmityV4Dialog().showAlertErrorDialog(
      title: "Posts sent for review",
      message: "Your post has been submitted to the pending list. It will be published once approved by the community moderator.",
      closeText: "OK",
    );
  }

  Widget _buildAppBar(BuildContext context, CommunityProfileState state) {
    final progress = state.collapseProgress.clamp(0.0, 1.0);
    final coverOpacity = (1 - (progress * 3.0)).clamp(0.0, 1.0);
    final isExpandedAtTop = progress < 0.05;
    final iconBackground = isExpandedAtTop ? Colors.black.withOpacity(0.5) : Colors.transparent;
    final iconBorderColor = isExpandedAtTop ? Colors.white.withOpacity(0.6) : Colors.transparent;
    final iconColor = isExpandedAtTop ? Colors.white : theme.textPrimary;
    final appBarBackgroundColor = Color.lerp(Colors.transparent, theme.backgroundSubtle, progress) ?? theme.backgroundSubtle;
    final mediaQuery = MediaQuery.of(context);
    final expandedHeight = mediaQuery.size.width / kAmityCommunityPhotoRatio;

    return SliverAppBar(
      floating: false,
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      elevation: 0,
      leadingWidth: 48,
      backgroundColor: appBarBackgroundColor,
      surfaceTintColor: appBarBackgroundColor,
      flexibleSpace: state.community == null
          ? null
          : Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  opacity: coverOpacity,
                  child: AmityCommunityCoverView(
                    community: state.community,
                    style: AmityCommunityHeaderStyle.EXPANDED,
                  ),
                ),
                IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    color: theme.backgroundSubtle.withOpacity(progress),
                  ),
                ),
              ],
            ),
      
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            height: 32,
            width: 32,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: iconBorderColor),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/Icons/amity_ic_back_button.svg",
                    package: 'amity_uikit_beta_service',
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      title: AnimatedOpacity(
        opacity: progress,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Text(
                  state.community?.displayName ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (state.community?.isOfficial == true)
                Container(width: 28, height: 28, margin: const EdgeInsets.only(top: 2), child: AmityOfficialBadgeElement()),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (state.community != null) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context2) => AmityCommunitySettingPage(community: state.community!)));
              }
            },
            child: Container(
              height: 32,
              width: 32,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: iconBorderColor),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/Icons/amity_ic_post_item_option.svg",
                      package: 'amity_uikit_beta_service',
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, CommunityProfileState state) {
    return SliverToBoxAdapter(
      child: AmityCommunityHeaderComponent(
        community: state.community,
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, CommunityProfileState state, AmityThemeColor theme) {
    return SliverToBoxAdapter(
      child: (state.community != null && state.isJoined == false)
          ? Container(
              width: double.infinity,
              color: theme.backgroundColor,
              padding: const EdgeInsets.all(16),
              child: AmityCommunityJoinButton(
                community: state.community!,
              ),
            )
          : Container(),
    );
  }

  Widget _buildStoryTab(BuildContext context, CommunityProfileState state, AmityFeatureFlag featureConfig) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: featureConfig.story.viewStoryTabEnabled,
        child: Container(
          color: theme.backgroundColor,
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AmityStoryTabComponent(
                type: CommunityFeedStoryTab(communityId: communityId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingPost(BuildContext context, CommunityProfileState state) {
    return SliverToBoxAdapter(
      child: (state.community != null && state.isJoined && state.pendingPostCount > 0 && (state.community!.isPostReviewEnabled ?? false))
          ? Container(
              color: theme.backgroundColor,
              padding: const EdgeInsets.all(16),
              child: AmityCommunityPendingPost(
                community: state.community!,
                pendingPostCount: state.pendingPostCount,
                isModerator: state.isModerator,
                onReturnCallback: () {
                  context.read<CommunityProfileBloc>().add(CommunityProfileEventRefreshFromPendingPage());
                },
              ),
            )
          : Container(),
    );
  }

  Widget _buildFeedTabSelector(BuildContext context, CommunityProfileState state) {
    return SliverToBoxAdapter(
      child: CommunityProfileTab(
        selectedIndex: state.selectedIndex,
        onTabSelected: (index) {
          context.read<CommunityProfileBloc>().add(CommunityProfileEventTabSelected(tab: index));
        },
      ),
    );
  }

  Widget _buildFeed(BuildContext context, CommunityProfileState state) {
    if (state.selectedIndex == CommunityProfileTabIndex.feed) {
      return CommunityFeedComponent(
        communityId: state.communityId,
        scrollController: _scrollController,
      );
    }
    if (state.selectedIndex == CommunityProfileTabIndex.pin) {
      return CommunityPinComponent(
        communityId: state.communityId,
        scrollController: _scrollController,
      );
    }
    if (state.selectedIndex == CommunityProfileTabIndex.image) {
      return AmityCommunityImageFeedComponent(
        communityId: state.communityId,
        scrollController: _scrollController,
      );
    }
    if (state.selectedIndex == CommunityProfileTabIndex.video) {
      return AmityCommunityVideoFeedComponent(
        communityId: state.communityId,
        scrollController: _scrollController,
      );
    }
    return Container();
  }
}
