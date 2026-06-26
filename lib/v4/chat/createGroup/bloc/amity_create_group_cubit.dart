import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amity_sdk/amity_sdk.dart';
import 'dart:io';
import 'dart:async';

part 'amity_create_group_state.dart';

class AmityCreateGroupCubit extends Cubit<AmityCreateGroupState> {
  AmityCreateGroupCubit() : super(const AmityCreateGroupState());

  static const List<String> _existingChannelErrorMarkers = [
    'already exists',
    'already existed',
    'duplicate',
    'conflict',
    '409',
  ];

  void updateGroupName(String name) {
    emit(state.copyWith(groupName: name));
  }

  void updatePrivacySetting(bool isPublic) {
    emit(state.copyWith(isPublic: isPublic));
  }

  void updateGroupImage(File? image) {
    emit(state.copyWith(groupImage: image));
  }

  void removeGroupImage() {
    emit(state.copyWith(groupImage: null));
  }

  Future<void> createGroup({
    required String groupName,
    required bool isPublic,
    required List<AmityUser> users,
    File? groupImage,
  }) async {
    emit(state.copyWith(status: CreateGroupStatus.loading));

    try {
      if (groupImage != null) {
        // Upload image first, then create group with avatar
        await _createGroupWithAvatar(
          groupName: groupName,
          isPublic: isPublic,
          users: users,
          imageFile: groupImage,
        );
      } else {
        // Create group without avatar
        await _createGroupWithoutAvatar(
          groupName: groupName,
          isPublic: isPublic,
          users: users,
        );
      }
    } catch (e) {
      if (e is UploadImageError) {
        emit(state.copyWith(
          status: CreateGroupStatus.uploadImageFailed,
          errorTitle: e.title,
          error: e.message,
        ));
      } else {
        // Handle other types of errors
        emit(state.copyWith(
          status: CreateGroupStatus.failure,
          errorTitle: "Upload Failed",
          error: "Please try again.",
        ));
      }
    }
  }

  Future<void> _createGroupWithAvatar({
    required String groupName,
    required bool isPublic,
    required List<AmityUser> users,
    required File imageFile,
  }) async {
    final completer = Completer<void>();

    AmityCoreClient.newFileRepository().uploadImage(imageFile).stream.listen((amityUploadResult) {
      amityUploadResult.when(
        progress: (uploadInfo, cancelToken) {
          // Progress is handled, but we don't emit state changes for progress
        },
        complete: (file) async {
          try {
            final channel = await AmityChatClient.newChannelRepository()
                .createChannel()
                .communityType()
                .withDisplayName(groupName)
                .isPublic(isPublic)
                .userIds(users.where((e) => e.userId != null).map((e) => e.userId!).toList())
                .avatar(file)
                .create();

            emit(state.copyWith(
              status: CreateGroupStatus.success,
              createdChannel: channel,
            ));
            completer.complete();
          } catch (e) {
            if (_isExistingChannelError(e)) {
              try {
                final channel = await _unarchiveExistingCommunityChannel(users);
                if (channel != null) {
                  emit(state.copyWith(
                    status: CreateGroupStatus.success,
                    createdChannel: channel,
                  ));
                  completer.complete();
                  return;
                }
              } catch (_) {
                // Fall through to original error handling.
              }
            }
            completer.completeError(e);
          }
        },
        error: (error) {
          final Map<String, dynamic> errorData = error.data as Map<String, dynamic>;
          final int uploadErrorCode = errorData["detail"]["error"]["code"];

          String errorTitle;
          String errorMessage;

          if (uploadErrorCode == 403) {
            errorTitle = "Inappropriate image";
            errorMessage = "Please choose a different image to upload.";
          } else {
            errorTitle = "Upload Failed";
            errorMessage = "Please try again.";
          }

          completer.completeError(UploadImageError(
            title: errorTitle,
            message: errorMessage,
          ));
        },
        cancel: () {},
      );
    });

    await completer.future;
  }

  Future<void> _createGroupWithoutAvatar({
    required String groupName,
    required bool isPublic,
    required List<AmityUser> users,
  }) async {
    AmityChannel channel;

    try {
      channel = await AmityChatClient.newChannelRepository()
          .createChannel()
          .communityType()
          .withDisplayName(groupName)
          .isPublic(isPublic)
          .userIds(users.where((e) => e.userId != null).map((e) => e.userId!).toList())
          .create();
    } catch (e) {
      if (_isExistingChannelError(e)) {
        final existingChannel = await _unarchiveExistingCommunityChannel(users);
        if (existingChannel != null) {
          channel = existingChannel;
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    emit(state.copyWith(
      status: CreateGroupStatus.success,
      createdChannel: channel,
    ));
  }

  bool _isExistingChannelError(Object error) {
    final text = error.toString().toLowerCase();
    return _existingChannelErrorMarkers.any(text.contains);
  }

  Future<AmityChannel?> _unarchiveExistingCommunityChannel(List<AmityUser> users) async {
    final repository = AmityChatClient.newChannelRepository();
    final archivedChannelIds = await repository.getArchivedChannelIds();
    if (archivedChannelIds.isEmpty) {
      return null;
    }

    final targetMemberIds = _targetMemberIds(users);
    if (targetMemberIds.isEmpty) {
      return null;
    }

    for (final channelId in archivedChannelIds) {
      final channel = await _tryGetChannel(channelId);
      if (channel == null || channel.amityChannelType != AmityChannelType.COMMUNITY) {
        continue;
      }

      final memberIds = await _getMemberIdsFromCache(channelId);
      if (memberIds.isEmpty) {
        continue;
      }

      if (_isSameMemberSet(memberIds, targetMemberIds)) {
        await repository.unarchiveChannel(channelId);
        return await _tryGetChannel(channelId) ?? channel;
      }
    }

    return null;
  }

  Set<String> _targetMemberIds(List<AmityUser> users) {
    final memberIds = users.where((user) => user.userId != null && user.userId!.isNotEmpty).map((user) => user.userId!).toSet();

    final currentUserId = AmityCoreClient.getUserId();
    if (currentUserId.isNotEmpty) {
      memberIds.add(currentUserId);
    }

    return memberIds;
  }

  Future<Set<String>> _getMemberIdsFromCache(String channelId) async {
    try {
      final members = await AmityChatClient.newChannelRepository().membership(channelId).getMembersFromCache();
      return members.where((member) => member?.userId != null && member!.userId!.isNotEmpty).map((member) => member!.userId!).toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<AmityChannel?> _tryGetChannel(String channelId) async {
    try {
      return await AmityChatClient.newChannelRepository().getChannel(channelId);
    } catch (_) {
      return null;
    }
  }

  bool _isSameMemberSet(Set<String> left, Set<String> right) {
    if (left.length != right.length) {
      return false;
    }
    return left.containsAll(right);
  }

  // Helper method to generate display name from member names
  String generateDisplayNameFromMembers(List<AmityUser> users) {
    if (users.isEmpty) return "";

    final StringBuffer nameBuffer = StringBuffer();
    const int maxLength = 100;
    bool isFirst = true;

    for (final AmityUser user in users) {
      final String displayName = user.displayName ?? "Unknown";

      if (!isFirst) {
        if (nameBuffer.length + 2 + displayName.length > maxLength) {
          break;
        }
        nameBuffer.write(", ");
      } else {
        isFirst = false;
      }

      // Add as much of the name as will fit
      if (nameBuffer.length + displayName.length <= maxLength) {
        nameBuffer.write(displayName);
      } else {
        // Add partial name to reach exactly maxLength
        final int remainingSpace = maxLength - nameBuffer.length;
        if (remainingSpace > 0) {
          nameBuffer.write(displayName.substring(0, remainingSpace));
        }
        break;
      }
    }

    return nameBuffer.toString();
  }
}

class UploadImageError {
  final String title;
  final String message;

  UploadImageError({required this.title, required this.message});
}
