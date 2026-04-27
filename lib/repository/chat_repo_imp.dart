import 'dart:developer';

import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';

import '../model/amity_channel_model.dart';
import '../model/amity_message_model.dart';
import '../model/amity_response_model.dart';
import '../utils/env_manager.dart';
import 'chat_repo.dart';

class AmityChatRepoImp implements AmityChatRepo {

  @override
  Future<void> initRepo(String accessToken) async {
  }

  @override
  Future<void> fetchChannelById(
      {String? paginationToken,
      int? limit = 30,
      required String channelId,
      required Function(
        AmityMessage?,
        String?,
      ) callback}) async {
   AmityLog.debug("fetchChannelById...");
  }

  @override
  Future<void> listenToChannel(Function(AmityMessage) callback) async {
   AmityLog.debug("listenToChannelById...");
  }

  //   @override
  // Future<void> listenToChannelList(Function(AmityMessage) callback) async {
  //  AmityLog.debug("listenToChannelById...");
  //   socket.on('channel.didCreate', (data) async {
  //     var messageObj = await AmityMessage.fromJson(data);

  //     callback(messageObj);
  //   });
  // }

  @override
  Future<void> reactMessage(String messageId) async {
   AmityLog.debug("reactMessage...");
  }

  @override
  Future<void> sendImageMessage(String channelId, String text,
      Function(AmityMessage?, String?) callback) async {
   AmityLog.debug("sendImageMessage...");
  }

  @override
  Future<void> sendTextMessage(String channelId, String text,
      Function(AmityMessage?, String?) callback) async {
   AmityLog.debug("sendTextMessage...");
   AmityLog.debug("fetchChannelById...");
  }

  void disposeRepo() {
  }

  Future<void> fetchChannelsList(
      Function(ChannelList? data, String? error) callback) async {
   AmityLog.debug("fetchChannels...");
  }

  Future<void> listenToChannelList(Function(Channels) callback) async {
   AmityLog.debug("listenToChannelListUpdate...");
  }

  Future<void> startReading(String channelId,
      {Function(String? data, String? error)? callback}) async {
  }

  Future<void> createGroupChannel(String displayName, List<String> userIds,
      Function(ChannelList? data, String? error) callback,
      {String? avatarFileId}) async {
   AmityLog.debug("createChannels...");
  }

  Future<void> createConversationChannel(List<String> userIds,
      Function(ChannelList? data, String? error) callback) async {
   AmityLog.debug("createChannels...");
  }

  Future<void> stopReading(String channelId,
      {Function(String? data, String? error)? callback}) async {
  }

  Future<void> markSeen(String channelId) async {
  }

  Future<void> getChannelById(
      {required String channelId,
      required Function(ChannelList? data, String? error) callback}) async {
   AmityLog.debug("getChannelById...");
  }
}
