import 'package:amity_uikit_beta_service/v4/utils/amity_image_viewer.dart';
import 'package:amity_uikit_beta_service/v4/utils/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmityChatPageBehavior {
  /// Called when user taps on avatar in chat page header
  /// By default, opens image viewer to show enlarged avatar
  /// Override this method to customize behavior (e.g., navigate to user profile)
  /// 
  /// [avatarUrl] - The URL of the user's avatar image
  /// [userId] - The ID of the user
  void onAvatarTap(
    BuildContext context,
    String? avatarUrl,
    String? userId,
  ) {
    if (userId != null && userId.isNotEmpty) {
      final navigationProvider = context.read<NavigationProvider>();
      navigationProvider.handleNavigation(
        context,
        event: AmityNavigationEvent.showUserProfile,
        params: {'userId': userId},
      );
      
      
      return;
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: AmityImageViewer.routeName),
          builder: (context) => AmityImageViewer(
            imageUrl: "$avatarUrl?size=large",
          ),
        ),
      );
    }
  }
}
