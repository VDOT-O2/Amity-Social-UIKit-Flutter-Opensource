import 'package:amity_uikit_beta_service/v4/chat/message_composer/bloc/message_composer_bloc.dart';
import 'package:amity_uikit_beta_service/v4/chat/message_composer/message_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

extension MessageComposerWithCamera on AmityMessageComposer {
  Future<void> onCameraTap(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null || !context.mounted) {
      return;
    }

    action.onMessageCreated();
    context.read<MessageComposerBloc>().add(
      MessageComposerSelectImageAndVideoEvent(
        selectedMedia: pickedFile,
        fromCamera: true,
      ),
    );
  }

  Future<void> onVideoTap(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);

    if (pickedFile == null || !context.mounted) {
      return;
    }

    action.onMessageCreated();
    context.read<MessageComposerBloc>().add(
      MessageComposerSelectImageAndVideoEvent(
        selectedMedia: pickedFile,
        fromCamera: true,
      ),
    );
  }

  Future<void> onMediaTap(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultipleMedia();

    if (pickedFiles.isEmpty || !context.mounted) {
      return;
    }

    final remainingSlots = mediaAttachmentLimit - selectedFiles.length;
    if (remainingSlots <= 0) {
      return;
    }

    final filesToUpload = pickedFiles.take(remainingSlots).toList();

    action.onMessageCreated();
    for (final pickedFile in filesToUpload) {
      if (!context.mounted) {
        return;
      }

      context.read<MessageComposerBloc>().add(
        MessageComposerSelectImageAndVideoEvent(
          selectedMedia: pickedFile,
        ),
      );
    }
  }

  
}
