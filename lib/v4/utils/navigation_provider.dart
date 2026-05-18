import 'package:amity_uikit_beta_service/v4/chat/create/channel_create_conversation_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/createGroup/ui/amity_select_group_member_page.dart';
import 'package:amity_uikit_beta_service/v4/chat/notification_preference/notification_preference_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/bloc/community_setting_page_bloc.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_setting/notification_setting/community_notification_setting_page.dart';
import 'package:amity_uikit_beta_service/v4/social/community/profile/amity_community_profile_page.dart';
import 'package:amity_uikit_beta_service/v4/social/user/profile/amity_user_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AmityNavigationEvent {
  showCommunity,
  showCommunityEdit,
  showCommunityNotificationPreferences,
  showUserProfile,
  showCreateChat,
  showChatNotificationPreferences,
}

class NavigationProvider extends ChangeNotifier {
  Future<void> handleNavigation(BuildContext context,
      {required AmityNavigationEvent event,
      Map<String, dynamic>? params}) async {
    switch (event) {
      case AmityNavigationEvent.showCommunity:
        var communityId = params?['communityId'] as String ?? '';
        Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AmityCommunityProfilePage(communityId: communityId),
        ),
      );
        return;
      case AmityNavigationEvent.showCommunityEdit:
        // Default implementation does not handle this event
        var mode = params?['mode'] as EditMode;
        Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => AmityCommunitySetupPage(mode: mode)));
        return;
      case AmityNavigationEvent.showCommunityNotificationPreferences:
        {
          final community = params?['community'];
          final state = params?['state'];
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AmityCommunityNotificationSettingPage(
                    community: community,
                    notificationSettings: state.notificationSettings)),
          );
        }
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
            MaterialPageRoute(
                builder: (context) => AmitySelectGroupMemberPage()),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AmityChannelCreateConversationPage()),
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
