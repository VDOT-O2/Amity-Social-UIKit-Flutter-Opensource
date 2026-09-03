import 'dart:async';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:equatable/equatable.dart';

part 'my_community_events.dart';
part 'my_community_state.dart';

class MyCommunityBloc extends Bloc<MyCommunityEvent, MyCommunityState> {
  final int pageSize = 20;
  late CommunityLiveCollection communityLiveCollection;
  late StreamSubscription<LiveResult<AmityCommunity>> _subscription;

  MyCommunityBloc() : super(const MyCommunityState()) {
    communityLiveCollection = AmitySocialClient.newCommunityRepository()
        .getCommunities()
        .filter(AmityCommunityFilter.MEMBER)
        .includeDeleted(false)
        .sortBy(AmityCommunitySortOption.DISPLAY_NAME)
        .getLiveCollection(pageSize: 20);

    _subscription =
        communityLiveCollection.getStream().debounceTime(const Duration(milliseconds: 150)).listen((result) async {
      final communities = result.data;
      AmityLog.debug(
          "MyCommunityBloc: Received update with ${communities.length} communities. isFetching: ${result.isFetching}, hasNextPage: ${communityLiveCollection.hasNextPage()}");

      if (result.isFetching == true && communities.isEmpty) {
        add(MyCommunityEventLoading());
      } else if (result.isFetching == false && communities.isEmpty) {
        add(const MyCommunityEventLoaded(MyCommunityLoaded(list: [], hasMoreItems: false, isFetching: false)));
      } else {
        var state = MyCommunityLoaded(
          list: communities,
          hasMoreItems: communityLiveCollection.hasNextPage(),
          isFetching: result.isFetching,
        );
        add(MyCommunityEventLoaded(state));
      }
    });

    on<MyCommunityEventLoaded>((event, emit) async {
      AmityLog.debug("MyCommunityEventLoaded");

      emit(event.loadedState);
    });

    on<MyCommunityEventLoading>((event, emit) async {
      emit(MyCommunityLoading());
    });

    on<MyCommunityEventInitial>((event, emit) async {
      AmityLog.debug("MyCommunityBloc: Initial event triggered, resetting live collection");

      communityLiveCollection.reset();
    });

    on<MyCommunityEventLoadMore>((event, emit) async {
      if (communityLiveCollection.hasNextPage()) {
        communityLiveCollection.loadNext();
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
