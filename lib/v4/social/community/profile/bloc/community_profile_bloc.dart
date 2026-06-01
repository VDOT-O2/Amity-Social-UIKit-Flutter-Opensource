import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/debug/amity_debug_log_controller.dart';
import 'package:amity_uikit_beta_service/v4/core/shared/debug/amity_debug_log_entry.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log_level.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'community_profile_events.dart';
part 'community_profile_state.dart';

class CommunityProfileBloc extends Bloc<CommunityProfileEvent, CommunityProfileState> {
  final AmityDebugLogController debugLogController = AmityDebugLogController(maxHistory: 100);
  StreamSubscription<dynamic>? _communitySubscription;
  VoidCallback? _scrollListener;

  List<AmityDebugLogEntry> get debugLogHistory => debugLogController.history;
  Stream<List<AmityDebugLogEntry>> get debugLogHistoryStream => debugLogController.historyStream;
  PostLiveCollection? _pendingPostsLiveCollection;
  StreamSubscription<List<AmityPost>>? _pendingPostsSubscription;

  CommunityProfileBloc(
    String communityId,
    ScrollController scrollController,
  ) : super(CommunityProfileState(
          communityId: communityId,
          scrollController: scrollController,
        )) {
    AmityLog.debug('CommunityProfileBloc initialized with communityId: $communityId');
    _log(
      action: 'init',
      message: 'CommunityProfileBloc initialized with communityId: $communityId',
      snapshot: state.toString(),
    );

    on<CommunityProfileEventUpdated>((event, emit) async {
      _log(
        action: 'CommunityProfileEventUpdated',
        message: 'Community updated: ${event.community.communityId}',
        snapshot: state.toString(),
      );
      
      if (event.community != null) {
        final isModerator = AmityCoreClient.hasPermission(AmityPermission.EDIT_COMMUNITY).atCommunity(communityId).check() ?? false;
        final canManageStory =
            AmityCoreClient.hasPermission(AmityPermission.MANAGE_COMMUNITY_STORY).atCommunity(event.community.communityId!).check() ??
                false;
        emit(state.copyWith(
            community: event.community, isJoined: event.community.isJoined, isModerator: isModerator, canManageStory: canManageStory));
      }
    });

    on<CommunityProfileEventExpanded>((event, emit) async {
      emit(state.copyWith(isExpanded: true));
      _log(
        action: 'CommunityProfileEventExpanded',
        message: 'Profile header expanded',
      );
    });

    on<CommunityProfileEventCollapsed>((event, emit) async {
      emit(state.copyWith(isExpanded: false));
      _log(
        action: 'CommunityProfileEventCollapsed',
        message: 'Profile header collapsed',
      );
    });

    on<CommunityProfileEventGetPendingPosts>((event, emit) async {
      final community = state.community;
      if (community != null) {
        final pendingPostCount = await community.getPostCount(AmityFeedType.REVIEWING);
        emit(state.copyWith(pendingPostCount: pendingPostCount));
        _log(
          action: 'CommunityProfileEventGetPendingPosts',
          message: 'Pending post count updated: $pendingPostCount',
        );
      }
    });

    on<CommunityProfileEventPendingPostsObserved>((event, emit) async {
      emit(state.copyWith(pendingPostCount: event.count));
    });

    on<CommunityProfileEventRefreshFromPendingPage>((event, emit) async {
      final community = state.community;
      if (community != null) {
        try {
          final updatedCommunity = await AmitySocialClient.newCommunityRepository().getCommunity(state.communityId);
          final pendingPostCount = await updatedCommunity.getPostCount(AmityFeedType.REVIEWING);
          emit(state.copyWith(pendingPostCount: pendingPostCount));
          _log(
            action: 'CommunityProfileEventRefreshFromPendingPage',
            message: 'Pending post count refreshed: $pendingPostCount',
          );
        } catch (e) {
          AmityLog.debug("Error fetching pending post count: $e");
          _log(
            action: 'CommunityProfileEventRefreshFromPendingPage',
            message: 'Error fetching pending post count: $e',
            level: AmityLogLevel.error,
            snapshot: state.toString(),
          );
        }
      }
    });

    on<CommunityProfileEventTabSelected>((event, emit) async {
      emit(state.copyWith(selectedIndex: event.tab, isExpanded: true));
      _log(
        action: 'CommunityProfileEventTabSelected',
        message: 'Tab selected: ${event.tab.name}',
      );
    });

    on<CommunityProfileEventJoining>((event, emit) async {
      try {
        emit(state.copyWith(isJoined: true));
        await AmitySocialClient.newCommunityRepository().joinCommunity(event.communityId);
        _log(
          action: 'CommunityProfileEventJoining',
          message: 'Joined community: ${event.communityId}',
          snapshot: state.toString(),
        );
      } catch (e) {
        emit(state.copyWith(isJoined: false));
        _log(
          action: 'CommunityProfileEventJoining',
          message: 'Failed to join community: ${event.communityId} ($e)',
          level: AmityLogLevel.error,
          snapshot: state.toString(),
        );
      }
    });

    on<CommunityProfileEventRefresh>((event, emit) async {
      try {
        final community = await AmitySocialClient.newCommunityRepository().getCommunity(event.communityId);
        addEvent(CommunityProfileEventUpdated(community: community));
        addEvent(CommunityProfileEventGetPendingPosts());
        _log(
          action: 'CommunityProfileEventRefresh',
          message: 'Community refresh requested for ${event.communityId}',
        );
      } catch (e) {
        _log(
          action: 'CommunityProfileEventRefresh',
          message: 'Failed to refresh community ${event.communityId}: $e',
          level: AmityLogLevel.error,
          snapshot: state.toString(),
        );
      }
    });

    on<CommunityProfileEventExpandDetail>((event, emit) async {
      emit(state.copyWith(isDetailExpanded: true));
      _log(
        action: 'CommunityProfileEventExpandDetail',
        message: 'Community detail section expanded',
      );
    });

    try {
      final communityStream = AmitySocialClient.newCommunityRepository().live.getCommunity(communityId);
      _communitySubscription = communityStream.listen((community) {
        addEvent(CommunityProfileEventUpdated(community: community));
        addEvent(CommunityProfileEventGetPendingPosts());
        _log(
          action: 'communityStream',
          message: 'Received live community update ${community.postsCount} posts, ${community.membersCount} members',
        );
      }, onError: (error) {
        _log(
          action: 'communityStream',
          message: 'Live community stream error: $error',
          level: AmityLogLevel.error,
        );
      });

      // Real-time observer for pending (REVIEWING) posts in this community.
      // We derive the banner count directly from the live collection's local
      // page count. Using community.getPostCount() would read from the
      // community-feed cache, which lags behind local create/delete actions
      // until the server pushes the new count.
      //
      // The banner UI caps the displayed value at "10+", so first-page items
      // (default page size) are sufficient.
      _pendingPostsLiveCollection = AmitySocialClient.newPostRepository()
          .getPosts()
          .targetCommunity(communityId)
          .feedType(AmityFeedType.REVIEWING)
          .includeDeleted(false)
          .getLiveCollection();

      _pendingPostsSubscription = _pendingPostsLiveCollection!.getStreamController().stream.listen((posts) {
        addEvent(CommunityProfileEventPendingPostsObserved(count: posts.length));
      });

      _pendingPostsLiveCollection!.loadNext();

      AmityLog.debug("CommunityProfileBloc listening to community updates for communityId: $communityId");
      _scrollListener = () {
        if (state.scrollController.hasClients && state.scrollController.offset > 330 && state.isExpanded) {
          AmityLog.debug("Scroll offset: ${state.scrollController.offset}, collapsing header");
          addEvent(CommunityProfileEventCollapsed());
        } else if (state.scrollController.hasClients && state.scrollController.offset <= 330 && !state.isExpanded) {
          AmityLog.debug("Scroll offset: ${state.scrollController.offset}, expanding header");
          addEvent(CommunityProfileEventExpanded());
        }
      };
      scrollController.addListener(_scrollListener!);

      AmityLog.debug('CommunityProfileBloc successfully initialized and listening to community updates');
      _log(
        action: 'init',
        message: 'CommunityProfileBloc subscriptions are ready',
      );
    } catch (e) {
      AmityLog.error("Error initializing CommunityProfileBloc", e);
      _log(
        action: 'init',
        message: 'Error initializing bloc: $e',
        level: AmityLogLevel.error,
        snapshot: state.toString(),
      );
    }
  }

  void _log({
    required String action,
    required String message,
    AmityLogLevel level = AmityLogLevel.debug,
    String? snapshot,
  }) {
    addDebugLog(
      controller: debugLogController,
      scope: 'CommunityProfileBloc',
      action: action,
      message: message,
      level: level,
      snapshot: snapshot,
    );
  }

  void clearDebugLogHistory() {
    debugLogController.clear();
  }

  @override
  Future<void> close() async {
    if (_scrollListener != null) {
      state.scrollController.removeListener(_scrollListener!);
    }
    await _communitySubscription?.cancel();
    debugLogController.dispose();
    return super.close();
  }
}
