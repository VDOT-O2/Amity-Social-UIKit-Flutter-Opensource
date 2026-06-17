import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'video_message_player_events.dart';
part 'video_message_player_state.dart';

class VideoMessagePlayerBloc extends Bloc<VideoMessagePlayerEvent, VideoMessagePlayerState> {
  VideoMessagePlayerBloc({required AmityVideo video, required String thumbnailUrl})
      : super(VideoMessagePlayerStateInitial(video, thumbnailUrl)) {
    on<VideoMessagePlayerEventInitial>((event, emit) async {
      final videoUrl = video.getVideoUrl(AmityVideoResolution.RES_1080) ??
          video.getVideoUrl(AmityVideoResolution.RES_720) ??
          video.getVideoUrl(AmityVideoResolution.RES_480) ??
          video.getVideoUrl(AmityVideoResolution.RES_360) ??
          video.getVideoUrl(AmityVideoResolution.ORIGINAL) ??
          video.getFilePath ??
          video.fileProperties.fileUrl ??
          '';
      final uri = Uri.parse(videoUrl);
      if (uri.isScheme('file')) {
        final controller = VideoPlayerController.file(File(videoUrl));
        await controller.initialize();
        emit(state.copyWith(
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          videoController: controller,
        ));
        return;
      } else {
        final controller = VideoPlayerController.networkUrl(uri);
        await controller.initialize();
        emit(state.copyWith(
          videoUrl: videoUrl,
          thumbnailUrl: thumbnailUrl,
          videoController: controller,
        ));
      }
    });

    // Start loading video
    add(VideoMessagePlayerEventInitial());
    AmityLog.debug("[VideoMessagePlayerBloc] Dispatched initial event to start loading video");
  }

  @override
  Future close() {
    AmityLog.debug("[VideoMessagePlayerBloc] Closing bloc, disposing video controller");
    state.videoController?.dispose();
    return super.close();
  }
}
