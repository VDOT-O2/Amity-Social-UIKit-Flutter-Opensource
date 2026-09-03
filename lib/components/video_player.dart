import 'dart:async';
import 'dart:io';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:amity_uikit_beta_service/v4/core/utils/log.dart';
import 'package:amity_uikit_beta_service/viewmodel/configuration_viewmodel.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayer extends StatefulWidget {
  final File file;
  const LocalVideoPlayer({Key? key, required this.file}) : super(key: key);

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    AmityLog.debug("[LocalVideoPlayer] Initializing with file=${widget.file.path}");
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    AmityLog.debug("[LocalVideoPlayer] Initializing player for file=${widget.file.path}");
    videoPlayerController = VideoPlayerController.file(widget.file);
    try {
      await videoPlayerController.initialize();
    } catch (error) {
      AmityLog.error("[LocalVideoPlayer] Failed to load ${widget.file.path}", error);
      return;
    }

    // autoPlay makes Chewie's constructor re-enter
    // VideoPlayerController.initialize() once a failed video has reset
    // `isInitialized`, throwing into a future nobody awaits. Drive playback here
    // instead - the controller is already initialised above.
    ChewieController controller = ChewieController(
      showControlsOnInitialize: true,
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      autoInitialize: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
      looping: true,
    );

    controller.setVolume(0.0);
    unawaited(videoPlayerController.play().catchError((Object _) {}));

    setState(() {
      chewieController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 250,
        color: const Color.fromRGBO(0, 0, 0, 1),
        child: Center(
          child: chewieController != null &&
                  chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: chewieController!,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Provider.of<AmityUIConfiguration>(context)
                          .appColors
                          .primary,
                    ),
                    const SizedBox(height: 20),
                    const Text('Loading',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final List<AmityPost> files;
  final bool isFillScreen;
  final int initialIndex;
  const VideoPlayerScreen(
      {Key? key,
      required this.files,
      this.isFillScreen = false,
      required this.initialIndex})
      : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  int _currentIndex = 0;
  // Index-aligned with widget.files; a file whose video could not be loaded is null.
  List<VideoPlayerController?>? _controllers;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
   AmityLog.debug("_initializeControllers");
    final controllers = await Future.wait(
      widget.files.map((file) async {
        var videoData = file.data
            as VideoData; // Assuming VideoData is a type from your code
        var fileURL = await videoData.getVideo(AmityVideoQuality.MEDIUM);
       AmityLog.debug("$fileURL");

       AmityLog.debug("  ");
        var controller =
            VideoPlayerController.networkUrl(Uri.parse(fileURL.fileUrl!));
        try {
          await controller.initialize();
        } catch (error) {
          // One unplayable file used to reject the whole Future.wait as an
          // unhandled async error and leak every controller in the batch.
          AmityLog.error("[VideoPlayerScreen] Failed to load ${fileURL.fileUrl}", error);
          await controller.dispose().catchError((Object _) {});
          return null;
        }
        return controller;
      }),
    );

    if (!mounted) {
      for (final controller in controllers) {
        controller?.dispose();
      }
      return;
    }

    setState(() {
      _controllers = controllers;
     AmityLog.debug("success");
    });
  }

  @override
  void dispose() {
    _controllers?.forEach((controller) {
      controller?.dispose();
    });

    super.dispose();
  }

  void _openFullScreenVideo(VideoPlayerController controller) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          FullScreenVideoPlayerWidget(videoPlayerController: controller),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final firstPlayable = _controllers?.firstWhere(
      (controller) => controller != null,
      orElse: () => null,
    );

    return widget.isFillScreen
        ? firstPlayable != null
            ? FullScreenVideoPlayerWidget(videoPlayerController: firstPlayable)
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                backgroundColor: Colors.black,
                body: Center(
                    child: CircularProgressIndicator(
                  color: Provider.of<AmityUIConfiguration>(context)
                      .appColors
                      .primary,
                )))
        : Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text('${_currentIndex + 1}/${widget.files.length}'),
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: _controllers != null && _controllers!.isNotEmpty
                ? PageView.builder(
                    controller:
                        PageController(initialPage: widget.initialIndex),
                    itemCount: widget.files.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      var controller = _controllers![index];
                      var videoData = widget.files[index].data as VideoData;
                      return GestureDetector(
                        onTap: controller == null
                            ? null
                            : () {
                                _openFullScreenVideo(controller);
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        videoData.thumbnail!.fileUrl!),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 70.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(
                    color: Provider.of<AmityUIConfiguration>(context)
                        .appColors
                        .primary,
                  )),
          );
  }
}

class FullScreenVideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const FullScreenVideoPlayerWidget(
      {Key? key, required this.videoPlayerController})
      : super(key: key);

  @override
  _FullScreenVideoPlayerWidgetState createState() =>
      _FullScreenVideoPlayerWidgetState();
}

class _FullScreenVideoPlayerWidgetState
    extends State<FullScreenVideoPlayerWidget> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // autoPlay would make Chewie's constructor re-enter
    // VideoPlayerController.initialize() once a failed video has reset
    // `isInitialized`, throwing into a future nobody awaits.
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      autoPlay: false,
      autoInitialize: false,
      looping: true,
      // Additional Chewie configuration...
    );

    unawaited(Future<void>.microtask(widget.videoPlayerController.play)
        .catchError((Object _) {}));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        maxChildSize: 1.0,
        minChildSize: 0.5,
        initialChildSize: 1.0,
        builder: (BuildContext context, ScrollController scrollController) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: SafeArea(
              child: Chewie(
                controller: _chewieController,
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _chewieController.dispose();
    widget.videoPlayerController.pause();

    super.dispose();
  }
}
