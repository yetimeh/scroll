import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll/home/page.dart';
import 'package:scroll/home/video_provider.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';

class PlaylistScrollView extends StatefulWidget {
  List videos = []; // List of videos
  // video that is tapped on
  bool isShuffled = false;
  String? firstVideo;

  PlaylistScrollView(
      {super.key,
      required this.videos,
      required this.isShuffled,
      required this.firstVideo});

  @override
  State<PlaylistScrollView> createState() => _PlaylistScrollViewState();
}

class _PlaylistScrollViewState extends State<PlaylistScrollView> {
  late Controller controller = Controller()
    ..addListener((event) {
      _handleCallbackEvent(event.direction, event.success);
    });

  Map keys_and_widgets = {};
  final stack = [];
  int widget_index = 0;

  @override
  void dispose() {
    super.dispose();

    // for (var i = 0; i < keys_and_widgets.length; i++) {
    //   keys_and_widgets[i]?.dispose();
    // }
    print("DISPOSE IS CALLED");
  }

  @override
  void initState() {
    createStack();

    super.initState();
  }

  void createStack() {
    for (var i0 = 0; i0 < widget.videos.length; i0++) {
      if (widget.isShuffled == true) {
        var random = Random();

        var randomIndex = random.nextInt(widget.videos.length);

        for (var i = 0; i < stack.length; i++) {
          if ((stack[i].mediumId == widget.videos[randomIndex])) {
            while ((stack[i].mediumId == widget.videos[randomIndex])) {
              randomIndex = random.nextInt(widget.videos.length);
              i = 0;
            }
          }
        }

        GlobalKey<VideoProviderState> generateUniqueKey() {
          return GlobalKey<VideoProviderState>(
              debugLabel: 'GlobalKey#$widget_index');
        }

        var modal = MODALL();
        modal.controller = controller;

        keys_and_widgets[widget_index] = modal;

        setState(() {
          var key = generateUniqueKey();
          var provider = VideoProvider(
              key: key,
              modal: keys_and_widgets[widget_index],
              mediumId: widget.videos[randomIndex]);

          stack.add(provider);

          widget_index++;
        });
      } else {
        GlobalKey<VideoProviderState> generateUniqueKey() {
          return GlobalKey<VideoProviderState>(
              debugLabel: 'GlobalKey#$widget_index');
        }

        var modal = MODALL();
        modal.controller = controller;

        keys_and_widgets[widget_index] = modal;

        setState(() {
          var key = generateUniqueKey();
          var provider = VideoProvider(
              key: key,
              modal: keys_and_widgets[widget_index],
              mediumId: widget.videos[i0]);

          if (provider.mediumId == widget.firstVideo!) {
            stack.insert(0, provider);
            return;
          }

          stack.add(provider);

          widget_index++;
        });
      }
    }
  }

  void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success) {}

  @override
  Widget build(BuildContext context) {
    print('YETI - $stack');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: TikTokStyleFullPageScroller(
        contentSize: stack.length,
        swipePositionThreshold: 0.2,
        // ^ the fraction of the screen needed to scroll
        swipeVelocityThreshold: 300,
        // ^ the velocity threshold for smaller scrolls
        animationDuration: const Duration(milliseconds: 400),
        // ^ how long the animation will take
        controller: controller,
        // ^ registering our own function to listen to page changes
        builder: (BuildContext context, int index) {
          return stack[index];
        },
      ),
    );
  }
}
