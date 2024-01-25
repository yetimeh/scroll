import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:like_button/like_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:rive/rive.dart';
import 'package:scroll/api/api.dart';
import 'package:scroll/home/page.dart';
import 'package:scroll/playlists/playlist_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:smooth_video_progress/smooth_video_progress.dart';
import "package:flutter/src/painting/gradient.dart" as gradient;
import 'package:sizer/sizer.dart';
import 'package:toast/toast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// import 'package:video_thumbnail/video_thumbnail.dart';

class GlobalVariableProvider extends ChangeNotifier {
  VideoPlayerController? _globalVariable;
  dynamic _keyForPlaylistWidget = [];

  VideoPlayerController? get globalVariable => _globalVariable;
  dynamic get keyForPlaylistWidget => _keyForPlaylistWidget;

  setGlobalVariable(VideoPlayerController? newValue) {
    _globalVariable = newValue;
    notifyListeners();
  }

  setGlobalKeyForPlaylist(dynamic newValue) {
    _keyForPlaylistWidget.add(newValue!);
    notifyListeners();
  }

  replaceGlobalKeyForPlaylist(dynamic newValue) {
    _keyForPlaylistWidget = newValue;
  }
}

class VideoProvider extends StatefulWidget {
  final String mediumId;
  MODALL modal;

  VideoProvider({
    super.key,
    required this.modal,
    required this.mediumId,
  });

  @override
  VideoProviderState createState() => VideoProviderState();
}

class VideoProviderState extends State<VideoProvider> {
  VideoPlayerController? _controller;
  VideoPlayerController? get controller => _controller;
  File? _file;
  File? thumbnail;
  late RiveAnimationController _animationController1;
  late RiveAnimationController _animationController2;
  late RiveAnimationController _likeAnimationController;
  bool _isPauseVisible = false;
  bool _isPlayVisible = false;
  bool _isLikeVisible = false;
  final api = ScrollAPI();
  final TextEditingController _textFieldController = TextEditingController();
  List? playlists;
  List? saved;
  DateTime? creationDate;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    initAsync();

    _animationController1 = OneShotAnimation("ShowPause", autoplay: false);

    _animationController2 = OneShotAnimation("ShowPlay", autoplay: false);

    _likeAnimationController = OneShotAnimation("check");

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  void dispose_() {
    dispose();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: _file!.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight:
            400, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );

      thumbnail = File(thumbnailPath!);
      creationDate = (await _file!.stat()).changed;

      _controller = VideoPlayerController.file(_file!);
      print("PATH: ${_file!.path}");

      // thumbnail = await genThumbnailFile(_file!.path);

      // await Future.wait([_controller!.initialize()]);

      try {
        await _controller?.initialize();

        print("Controller initialized");

        _controller!.setLooping(true);

        setState(() {
          widget.modal.value = _controller;
          widget.modal.medium_id = widget.mediumId;
        });

        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.

        // _controller!.play();

        // _controller!.setLooping(true);

        _controller?.addListener(() {
          if (_controller!.value.hasError) {
            print('error');
            print("VIDEO ERROR: ${_controller!.value.errorDescription}");
          }
          if (_controller!.value.isBuffering) {}
        });
      } on PlatformException catch (ee) {
        print("errora $ee");

        _controller = null;
        widget.modal.controller!
            .jumpToPosition(widget.modal.controller!.getScrollPosition() + 1);
        dispose();
      }
    } catch (e) {
      print("Failed : $e");
    }
  }

  void initialize() async {
    await initAsync().then((value) => setState(
          () {},
        ));
  }

  // Future<File> genThumbnailFile(String path) async {
  //   final fileName = await VideoThumbnail.thumbnailFile(
  //     video: path,

  //     imageFormat: ImageFormat.PNG,
  //     maxHeight:
  //         100, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
  //     quality: 75,
  //   );
  //   File file = File(fileName!);
  //   return file;
  // }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      print(_controller);
      // setState(() {
      //   initialize();
      // });

      return Container(
        decoration: const BoxDecoration(color: Colors.black),
      );
    } else {
      saved = api.isSaved(widget.mediumId);

      return PageView(
        children: [
          Center(
            child: Stack(children: [
              SizedBox.expand(
                child: Container(color: Colors.black),
              ),
              Positioned(
                child: GestureDetector(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  onDoubleTap: () async {
                    setState(() {
                      if (!api.isLiked(widget.mediumId)) {
                        api.likeVideo(widget.mediumId);
                      }

                      _isLikeVisible = true;
                    });

                    _likeAnimationController.isActive = true;

                    await Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        _isLikeVisible = false;
                      });
                    });
                  },
                  onTap: () async {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();

                      setState(() {
                        _isPauseVisible = true;
                      });
                      _animationController1.isActive = true;
                    } else {
                      _controller!.play();

                      setState(() {
                        if (_isPauseVisible) {
                          _isPauseVisible = false;
                        }

                        _isPlayVisible = true;
                      });

                      _animationController2.isActive = true;

                      await Future.delayed(const Duration(seconds: 1), () {
                        setState(
                          () {
                            _isPlayVisible = false;
                          },
                        );
                      });
                    }
                  },
                ),
              ),
              Positioned.fill(
                child: Visibility(
                  visible: _isLikeVisible,
                  child: Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: RiveAnimation.asset(
                        "assets/riv/like_button.riv",
                        fit: BoxFit.fill,
                        controllers: [_likeAnimationController],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Visibility(
                    visible: _isPauseVisible,
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: RiveAnimation.asset(
                        "assets/riv/play_pause.riv",
                        controllers: [
                          _animationController1,
                        ],
                        animations: const ["ShowPause"],
                        fit: BoxFit.fill,
                        onInit: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Visibility(
                  visible: _isPlayVisible,
                  child: Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: RiveAnimation.asset(
                        "assets/riv/play_pause.riv",
                        controllers: [_animationController2],
                        animations: const ["ShowPlay"],
                        fit: BoxFit.fill,
                        onInit: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 100,
                  width: 700,
                  child: Container(
                      decoration: const BoxDecoration(
                          gradient: gradient.LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black]))),
                ),
              )),
              Positioned.fill(
                top: 480,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          SizedBox(
                              height: 50,
                              width: 50,
                              child: LikeButton(
                                isLiked: api.isLiked(widget.mediumId),
                                likeCountAnimationType:
                                    LikeCountAnimationType.all,
                                size: 40,
                                onTap: (isLiked) async {
                                  api.likeVideo(widget.mediumId);
                                  return api.isLiked(widget.mediumId);
                                },
                              )),
                          // IconButton(
                          //     onPressed: () {},
                          //     icon: const Icon(
                          //       CupertinoIcons.heart,
                          //       size: 40.0,
                          //     )),
                          const SizedBox(height: 10),
                          IconButton(
                              onPressed: () {
                                playlists = api.getPlaylists();

                                showModalBottomSheet(
                                    context: context,
                                    builder: ((BuildContext context) {
                                      return SizedBox(
                                        height: 40.h,
                                        width: 100.h,
                                        child: SingleChildScrollView(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: playlists!.length + 1,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                if (index == 0) {
                                                  return ListTile(
                                                    leading: const Icon(
                                                        CupertinoIcons.add),
                                                    title: const Text(
                                                        "Create a new playlist"),
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder:
                                                              (dialogContext) {
                                                            var dialog =
                                                                AlertDialog(
                                                              title: const Text(
                                                                  'Create playlist 🎉'),
                                                              content:
                                                                  TextField(
                                                                controller:
                                                                    _textFieldController,
                                                                decoration:
                                                                    const InputDecoration(
                                                                        hintText:
                                                                            "Enter a nice name for your playlist!"),
                                                              ),
                                                              actions: <Widget>[
                                                                FilledButton(
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        dialogContext);
                                                                  },
                                                                ),
                                                                FilledButton(
                                                                  child:
                                                                      const Text(
                                                                          'Okay'),
                                                                  onPressed:
                                                                      () async {
                                                                    if (_textFieldController
                                                                        .text
                                                                        .trim()
                                                                        .isEmpty) {
                                                                      ToastContext()
                                                                          .init(
                                                                              dialogContext);

                                                                      Toast.show(
                                                                          "You didn't provide a name!",
                                                                          duration: Toast
                                                                              .lengthLong,
                                                                          gravity: Toast
                                                                              .bottom,
                                                                          border:
                                                                              Border.all(color: Colors.red));

                                                                      return;
                                                                    }

                                                                    var playlistExists =
                                                                        await api.createNewPlaylist(_textFieldController
                                                                            .text
                                                                            .trim());

                                                                    ToastContext()
                                                                        .init(
                                                                            context);

                                                                    playlistExists ==
                                                                            false
                                                                        ? Toast.show(
                                                                            "A playlist with that name already exists!",
                                                                            duration: Toast
                                                                                .lengthLong,
                                                                            gravity: Toast
                                                                                .bottom,
                                                                            border: Border.all(
                                                                                color: Colors
                                                                                    .red))
                                                                        : Toast.show(
                                                                            "Playlist created succesfully!",
                                                                            duration:
                                                                                Toast.lengthLong,
                                                                            gravity: Toast.bottom,
                                                                            border: Border.all(color: Colors.green));

                                                                    setState(
                                                                        () {
                                                                      playlists =
                                                                          api.getPlaylists();
                                                                    });

                                                                    _textFieldController
                                                                        .text = "";

                                                                    Navigator.pop(
                                                                        dialogContext);
                                                                  },
                                                                ),
                                                              ],
                                                            );

                                                            return dialog;
                                                          });
                                                    },
                                                  );
                                                }

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: ListTile(
                                                    tileColor: saved!.contains(
                                                            playlists![
                                                                index - 1][0])
                                                        ? const Color.fromARGB(
                                                            255, 70, 78, 61)
                                                        : null,
                                                    leading: SizedBox(
                                                        height: 40,
                                                        width: 40,
                                                        child: Image.asset(
                                                            "assets/video-player.png")),
                                                    title: Text(
                                                        playlists![index - 1]
                                                            [0]),
                                                    subtitle: Text(
                                                        "${playlists![index - 1][1]} videos"),
                                                    onTap: () {
                                                      api.saveToPlaylist(
                                                          playlists![index - 1]
                                                              [0],
                                                          widget.mediumId);
                                                      setState(() {
                                                        playlists =
                                                            api.getPlaylists();
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                );
                                              }),
                                        ),
                                      );
                                    }));
                              },
                              icon: Icon(
                                CupertinoIcons.bookmark_fill,
                                size: 40.0,
                                color: saved!.isEmpty
                                    ? Colors.white
                                    : Colors.amber,
                              )),
                          const SizedBox(height: 10),
                          IconButton(
                              onPressed: () async {
                                Share.shareXFiles([XFile(_file!.path)]);
                              },
                              icon: const Icon(
                                Icons.share,
                                size: 40,
                                color: Colors.white,
                              )),
                        ],
                      )),
                ),
              ),
              Positioned.fill(
                  bottom: 30,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25.0),
                        child: SizedBox(
                          height: 10,
                          width: 320,
                          child: SmoothVideoProgress(
                            controller: _controller!,
                            builder: (context, position, duration, child) =>
                                SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                  thumbColor: Colors.transparent,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 0.0)),
                              child: Slider(
                                label: "Hello",
                                onChangeStart: (_) => _controller!.pause(),
                                onChangeEnd: (_) => _controller!.play(),
                                onChanged: (value) => _controller!.seekTo(
                                    Duration(milliseconds: value.toInt())),
                                value: position.inMilliseconds.toDouble(),
                                min: 0,
                                max: duration.inMilliseconds.toDouble(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(
                      //   width: 70,
                      // ),
                      const Padding(
                        padding: EdgeInsets.only(top: 49.0, right: 20),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: RiveAnimation.asset(
                              "assets/riv/audio_soundwave.riv",
                              fit: BoxFit.fill),
                        ),
                      ),
                    ],
                  )),
            ]),
          ),
          Container(
            child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image(
                          image: FileImage(thumbnail!),
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Location: ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            // width: 100.w,
                            child: Text(
                              _file!.path,
                              softWrap: true,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Duration: ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(_controller!.value.duration.toString())
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Creation date: ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text("$creationDate"),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FilledButton.icon(
                                  style: const ButtonStyle(
                                      foregroundColor: MaterialStatePropertyAll(
                                          Colors.white),
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.redAccent)),
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text(
                                              "Are you sure you want to perform this action? This action can't be undone"),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                // Perform the action when the user confirms
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                // Add your action here
                                                print('Action confirmed');

                                                await _file!.delete();
                                              },
                                              child: const Text('Yes'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // Cancel the action when the user dismisses the dialog
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                                print('Action canceled');
                                              },
                                              child: const Text('No'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text("Delete video")),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          )
        ],
      );
    }

    // ? Container(
    //     child: Container(
    //       decoration: BoxDecoration(
    //           image: DecorationImage(image: FileImage(thumbnail!))),
    //     ),
    //   )
  }
}
