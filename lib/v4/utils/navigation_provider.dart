import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/chat/add_group_member/amity_add_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/create/channel_create_conversation_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_select_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/group_message/amity_group_chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/message/chat_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/notification_preference/notification_preference_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/post/amity_post_content_component.dart';
import 'package:amity_uikit_beta_service/v4/social/post/common/post_action.dart';
import 'package:amity_uikit_beta_service/v4/social/post/post_detail/amity_post_detail_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';

enum AmityNavigationEvent {
  showCommunity,
  showCommunityEdit,
  showCommunityNotificationPreferences,
  showPostDetail,
  showUserProfile,
  showChat,
  showCreateChat,
  showAddGroupMembers,
  showChatNotificationPreferences,
}

final RouteObserver<PageRoute<dynamic>> navigationRouteObserver = RouteObserver<PageRoute<dynamic>>();

class NavigationProvider extends ChangeNotifier {
  String? _activeChannelId;

  String? get activeChannelId => _activeChannelId;

  bool isActiveChannel(String? channelId) {
    return channelId != null && channelId.isNotEmpty && _activeChannelId == channelId;
  }

  void setActiveChannelId(String? channelId) {
    if (_activeChannelId == channelId) {
      return;
    }

    _activeChannelId = channelId;
  }

  void clearActiveChannelId({String? channelId}) {
    if (channelId != null && _activeChannelId != channelId) {
      return;
    }

    if (_activeChannelId == null) {
      return;
    }

    _activeChannelId = null;
  }

  Future<void> handleNavigation(BuildContext context, {required AmityNavigationEvent event, Map<String, dynamic>? params}) async {
    switch (event) {
      case AmityNavigationEvent.showCommunity:
        var communityId = params?['communityId'] as String;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AmityCommunityProfilePage(communityId: communityId),
          ),
        );
        return;
      case AmityNavigationEvent.showCommunityEdit:
        // Default implementation does not handle this event
        var mode = params?['mode'] as EditMode;
        Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (context) => AmityCommunitySetupPage(mode: mode)));
        return;
      case AmityNavigationEvent.showCommunityNotificationPreferences:
        {
          final community = params?['community'];
          final state = params?['state'];
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AmityCommunityNotificationSettingPage(community: community, notificationSettings: state.notificationSettings)),
          );
        }
        return;
      case AmityNavigationEvent.showPostDetail:
        var postId = params?['postId'] as String;
        var category = params?['category'] as AmityPostCategory? ?? AmityPostCategory.general;
        var hideMenu = params?['hideMenu'] as bool? ?? false;
        var action = params?['action'] as AmityPostAction?;

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AmityPostDetailPage(
            postId: postId,
            category: category,
            hideMenu: hideMenu,
            action: action,
          ),
        ));
        return;
      case AmityNavigationEvent.showUserProfile:
        var userId = params?['userId'] as String;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmityUserProfilePage(
              userId: userId,
            ),
          ),
        );
        return;
      case AmityNavigationEvent.showCreateChat:
        final isGroupChat = params?['isGroupChat'] as bool? ?? false;
        if (isGroupChat) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AmitySelectGroupMemberPage()),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AmityChannelCreateConversationPage()),
          );
        }
        return;
      case AmityNavigationEvent.showChat:
        {
          final channelId = params?['channelId'] as String?;
          final userId = params?['userId'] as String?;
          final displayName = params?['displayName'] as String?;
          final avatarUrl = params?['avatarUrl'] as String?;
          final isGroupChat = params?['isGroupChat'] as bool? ?? false;

          if (isGroupChat) {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => AmityGroupChatPage(
                        channelId: channelId ?? "",
                      )),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AmityChatPage(
                  key: Key("${channelId ?? ""}_${userId ?? ""}"),
                  channelId: channelId,
                  userId: userId ?? "",
                  userDisplayName: displayName ?? "",
                  avatarUrl: avatarUrl ?? "",
                ),
              ),
            );
          }
        } return;
      case AmityNavigationEvent.showAddGroupMembers:
        {
          final channel = params?['channel'] as AmityChannel;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AmityAddGroupMemberPage(channel: channel),
            ),
          );
        }
        return;
      case AmityNavigationEvent.showChatNotificationPreferences:
        {
          final channel = params?['channel'];

          await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder: (context) => AmityGroupNotificationPreferencePage(
                channel: channel,
              ),
            ),
          );
        }
        return;
      default:
        return;
    }
  }
}
