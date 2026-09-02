import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays an already initialised [VideoPlayerController] through Chewie, owning
/// the [ChewieController] lifecycle.
///
/// Building a [ChewieController] inline inside `build()` is unsafe twice over.
/// It leaks a controller on every rebuild, and its constructor starts an
/// unawaited `_initialize()`. When a video fails mid playback the player value
/// is replaced by `VideoPlayerValue.erroneous`, which resets `isInitialized`
/// back to false, so that unawaited initialiser calls
/// `VideoPlayerController.initialize()` a second time. `video_player` has no
/// re-entry guard, so the retry allocates another native player and its
/// PlatformException is thrown into a future nobody awaits - an unhandled error
/// on every rebuild for as long as the broken video is on screen.
///
/// Creating the controller once with `autoInitialize` and `autoPlay` both off
/// removes that path entirely; playback is started here instead.
class ManagedChewiePlayer extends StatefulWidget {
  const ManagedChewiePlayer({
    Key? key,
    required this.videoPlayerController,
    this.autoPlay = true,
    this.looping = true,
    this.showControlsOnInitialize = false,
    this.aspectRatio,
  }) : super(key: key);

  final VideoPlayerController videoPlayerController;
  final bool autoPlay;
  final bool looping;
  final bool showControlsOnInitialize;
  final double? aspectRatio;

  @override
  State<ManagedChewiePlayer> createState() => _ManagedChewiePlayerState();
}

class _ManagedChewiePlayerState extends State<ManagedChewiePlayer> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = _createController();
  }

  @override
  void didUpdateWidget(covariant ManagedChewiePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final unchanged =
        oldWidget.videoPlayerController == widget.videoPlayerController &&
            oldWidget.autoPlay == widget.autoPlay &&
            oldWidget.looping == widget.looping &&
            oldWidget.showControlsOnInitialize ==
                widget.showControlsOnInitialize &&
            oldWidget.aspectRatio == widget.aspectRatio;
    if (unchanged) {
      return;
    }

    _chewieController.dispose();
    _chewieController = _createController();
  }

  ChewieController _createController() {
    final controller = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      showControlsOnInitialize: widget.showControlsOnInitialize,
      aspectRatio: widget.aspectRatio,
      looping: widget.looping,
      // Both of these make Chewie's constructor re-enter
      // VideoPlayerController.initialize() once a failed video has reset
      // `isInitialized`. The controller handed to us is already initialised.
      autoInitialize: false,
      autoPlay: false,
    );

    if (widget.autoPlay) {
      // Deferred so playback never mutates the controller's value while this
      // widget is still building, matching when Chewie used to start playback.
      unawaited(Future<void>.microtask(widget.videoPlayerController.play)
          .catchError((Object _) {}));
    }

    return controller;
  }

  @override
  void dispose() {
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(controller: _chewieController);
  }
}
