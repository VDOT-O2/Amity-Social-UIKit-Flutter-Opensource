import 'dart:io';

import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'single_video_player_state.dart';
part 'single_video_player_event.dart';

class SingleVideoPlayerBloc extends Bloc<SingleVideoPlayerEvent, SingleVideoPlayerState> {
  SingleVideoPlayerBloc({required String? filePath, required String? fileUrl})
      : super(VideoPostPlayerStateInitial(filePath, fileUrl)) {
    on<SingleVideoPlayerEventInitial>((event, emit) async {
      if (state.videoController != null) {
        return;
      }

      if (filePath != null) {
        final controller = VideoPlayerController.file(File(filePath));
        if (!await _initialize(controller, filePath)) {
          return;
        }
        emit(state.copyWith(
          filePath: filePath,
          fileUrl: null,
          videoController: controller,
        ));
      } else if (fileUrl != null) {
        final uri = Uri.parse(fileUrl);
        final controller = VideoPlayerController.networkUrl(uri);
        if (!await _initialize(controller, fileUrl)) {
          return;
        }
        emit(state.copyWith(
          filePath: null,
          fileUrl: fileUrl,
          videoController: controller,
        ));
      }
    });

  }

  /// Initialises [controller], returning false when the source cannot be
  /// played. Without this the PlatformException escapes the event handler as an
  /// unhandled async error and the controller is leaked.
  static Future<bool> _initialize(
      VideoPlayerController controller, String source) async {
    try {
      await controller.initialize();
      return true;
    } catch (error) {
      AmityLog.error("[SingleVideoPlayerBloc] Failed to load $source", error);
      await controller.dispose().catchError((Object _) {});
      return false;
    }
  }

  @override
  Future close() {
    state.videoController?.dispose();
    return super.close();
  }
}
