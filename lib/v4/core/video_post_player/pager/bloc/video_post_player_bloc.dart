import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

part 'video_post_player_events.dart';
part 'video_post_player_state.dart';

class VideoPostPlayerBloc extends Bloc<VideoPostPlayerEvent, VideoPostPlayerState> {
  VideoPostPlayerBloc({required List<AmityPost> posts, required int initialIndex})
      : super(VideoPostPlayerStateInitial(posts, initialIndex)) {
    on<VideoPostPlayerEventInitial>((event, emit) async {
      AmityLog.debug(
          "[VideoPostPlayerBloc] Initial event received, loading videos for ${posts.length} posts, initialIndex=$initialIndex");

      var urls = <String>[];
      var thumbnails = <String>[];
      for (var post in posts) {
        final AmityVideo video = await (post.data as VideoData).getVideo(AmityVideoQuality.LOW);
        final videoUrl = video.getFileProperties!.fileUrl ?? "";
        urls.add(videoUrl);
        final String thumbnail = (post.data as VideoData).thumbnail?.fileUrl ?? "";
        thumbnails.add(thumbnail);
      }
      final uri = Uri.parse(urls[initialIndex]);
      final controller = VideoPlayerController.networkUrl(uri);
      if (!await _initialize(controller, urls[initialIndex])) {
        emit(state.copyWith(urls: urls, thumbnails: thumbnails, currentIndex: initialIndex));
        return;
      }
      emit(state.copyWith(
        urls: urls,
        thumbnails: thumbnails,
        currentIndex: initialIndex,
        videoController: controller,
      ));
    });

    on<VideoPostPlayerEventPageChanged>((event, emit) async {
      state.videoController?.pause();
      final uri = Uri.parse(state.urls[event.currentIndex]);
      final controller = VideoPlayerController.networkUrl(uri);
      if (!await _initialize(controller, state.urls[event.currentIndex])) {
        return;
      }
      state.videoController?.dispose();
      emit(state.copyWith(
        currentIndex: event.currentIndex,
        videoController: controller,
      ));
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
      AmityLog.error("[VideoPostPlayerBloc] Failed to load $source", error);
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
