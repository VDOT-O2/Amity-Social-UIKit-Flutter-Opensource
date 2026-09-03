import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/home/base_chat_list_component.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/amity_uikit_toast.dart';
import 'package:amity_uikit_beta_service/v4/core/toast/bloc/amity_uikit_toast_bloc.dart';
import 'package:amity_uikit_beta_service/v4/utils/bloc_extension.dart';
import 'package:amity_uikit_beta_service/v4/utils/error_util.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_list_events.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListType chatListType;
  List<AmityChannelType> channelTypes;
  AmityToastBloc toastBloc;
  final Set<String> _archivedChannelIdsCache = <String>{};
  DateTime? _archivedChannelIdsLastFetchedAt;
  static const Duration _archivedChannelIdsCacheTtl = Duration(seconds: 15);

  late final LiveCollectionStream<AmityChannel> channelLiveCollection;

  ChatListBloc({required this.chatListType, required this.channelTypes, required this.toastBloc})
      : super(const ChatListState()) {
    if (chatListType == ChatListType.ARCHIVED) {
      channelLiveCollection =
          AmityChatClient.newChannelRepository().getArchivedChannels();
    } else {
      channelLiveCollection = AmityChatClient.newChannelRepository()
          .getChannels()
          .types(channelTypes)
          .filter(AmityChannelFilter.MEMBER)
          .excludeArchives(true)
          .getLiveCollection();
    }

    on<ChatListEventChannelsUpdated>((event, emit) async {
      final filteredChannels = await _applyArchiveSafetyGuard(event.channels);

      final channelIds = filteredChannels
          .where(
              (channel) => !state.channelMembers.containsKey(channel.channelId))
          .map((e) => e.channelId ?? "")
          .where((e) => e.isNotEmpty)
          .toList();

      addEvent(ChatListEventFetchMembers(channelIds: channelIds));

      // Calculate if there are any unread messages
      final hasUnreadMessages = filteredChannels
          .any((channel) => (channel.unreadCount ?? 0) > 0);

      emit(state.copyWith(
        channels: filteredChannels,
        hasUnreadMessages: hasUnreadMessages,
      ));
    });

    on<ChatListEventFetchMembers>((event, emit) async {
      var membersMap =
          Map<String, AmityChannelMember?>.from(state.channelMembers);
      for (final channelId in event.channelIds) {
        final List<AmityChannelMember?> members =
            await AmityChatClient.newChannelRepository()
                .membership(channelId)
                .getMembersFromCache();

        // Get other participant for this channel.
        AmityChannelMember? member;
        for (var i = 0; i < members.length; i++) {
          if (members[i]?.userId != AmityCoreClient.getUserId()) {
            member = members[i];
            break;
          }
        }

        membersMap[channelId] = member;
      }

      emit(state.copyWith(
        channelMembers: membersMap,
      ));
    });

    on<ChatListEventLoadingStateUpdated>((event, emit) {
      emit(state.copyWith(
        isLoading: event.isLoading,
      ));
    });

    on<ChatListLoadNextPage>((event, emit) {
      if (channelLiveCollection.hasNextPage()) {
        channelLiveCollection.loadNext();
      }
    });

    on<ChatListPushNotificationEvent>((event, emit) {
      emit(state.copyWith(
        isPushNotificationEnabled: event.isPushNotificationEnabled,
      ));
    });

    on<ChatListEventChannelArchive>((event, emit) async {
      try {
        await AmityChatClient.newChannelRepository()
            .archiveChannel(event.channelId);
        _archivedChannelIdsCache.add(event.channelId);
        toastBloc.add(AmityToastShort(
            message: event.successMessage, icon: AmityToastIcon.success));
      } catch (error) {
        String errorMessage = error.toString();
        if (errorMessage.contains('Archive limit exceeded')) {
          emit(state.copyWith(
            error: AmityErrorInfo(
              title: event.limitErrorTitle,
              message: event.limitErrorMessage,
            ),
            showArchiveErrorDialog: true,
          ));
        } else {
          toastBloc.add(AmityToastShort(
              message: event.errorMessage, 
              icon: AmityToastIcon.warning));
        }
      }
    });

    on<ChatListEventChannelUnarchive>((event, emit) async {
      try {
        await AmityChatClient.newChannelRepository()
            .unarchiveChannel(event.channelId);
        _archivedChannelIdsCache.remove(event.channelId);
        toastBloc.add(AmityToastShort(
            message: event.successMessage, icon: AmityToastIcon.success));
      } catch (error) {
        toastBloc.add(AmityToastShort(
            message: event.errorMessage, 
            icon: AmityToastIcon.warning));
      }
    });

    on<ChatListEventResetDialogState>((event, emit) {
      emit(state.copyWith(
        showArchiveErrorDialog: false,
        error: null,
      ));
    });

    channelLiveCollection.getStream().listen((event) {
      addEvent(ChatListEventLoadingStateUpdated(isLoading: event.isFetching));
      addEvent(ChatListEventChannelsUpdated(channels: event.data));
    });

    // Query for notification settings
    fetchNotificationSettings();
  }

  @override
  Future<void> close() {
    channelLiveCollection.dispose();
    return super.close();
  }

  void fetchNotificationSettings() async {
    final settings = await AmityNotification().user().getSettings();
    final chatModuleSettings = settings.events?.whereType<Chat>().first;

    final isPushNotificationEnabled =
        (settings.isEnabled ?? true) && (chatModuleSettings?.isEnabled ?? true);
    addEvent(ChatListPushNotificationEvent(
        isPushNotificationEnabled: isPushNotificationEnabled));
  }

  Future<List<AmityChannel>> _applyArchiveSafetyGuard(List<AmityChannel> channels) async {
    if (channels.isEmpty) {
      return channels;
    }

    final archivedIds = await _getArchivedChannelIdsSafe();
    if (archivedIds.isEmpty) {
      return channels;
    }

    if (chatListType == ChatListType.ARCHIVED) {
      return channels.where((channel) {
        final channelId = channel.channelId;
        return channelId != null && archivedIds.contains(channelId);
      }).toList();
    }

    return channels.where((channel) {
      final channelId = channel.channelId;
      return channelId == null || !archivedIds.contains(channelId);
    }).toList();
  }

  Future<Set<String>> _getArchivedChannelIdsSafe() async {
    final shouldUseCache =
        _archivedChannelIdsCache.isNotEmpty &&
        _archivedChannelIdsLastFetchedAt != null &&
        DateTime.now().difference(_archivedChannelIdsLastFetchedAt!) <
            _archivedChannelIdsCacheTtl;

    if (shouldUseCache) {
      return _archivedChannelIdsCache;
    }

    try {
      final archivedIds =
          await AmityChatClient.newChannelRepository().getArchivedChannelIds();
      _archivedChannelIdsCache
        ..clear()
        ..addAll(archivedIds);
      _archivedChannelIdsLastFetchedAt = DateTime.now();
    } catch (_) {
      // Best-effort guard: keep using current query results when ids are unavailable.
    }

    return _archivedChannelIdsCache;
  }
}
