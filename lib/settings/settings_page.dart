import 'package:flutter/material.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = VideoPlayerController.asset("assets/video_1.mp4");

  final __controller = VideoPlayerController.asset("assets/video_2.mp4");

  @override
  Widget build(BuildContext context) {
    _controller.initialize().then((value) => setState(() {}));

    List<Widget> stack = [
      Container(
        color: Colors.amber,
      ),
      Container(
        color: Colors.blue,
      ),
      Container(
        color: Colors.green,
      ),
      Container(
        color: Colors.pink,
      ),
      VideoPlayer(_controller)
    ];

    return TikTokStyleFullPageScroller(
      contentSize: stack.length,
      swipePositionThreshold: 0.2,
      // ^ the fraction of the screen needed to scroll
      swipeVelocityThreshold: 300,
      // ^ the velocity threshold for smaller scrolls
      animationDuration: const Duration(milliseconds: 400),
      // ^ how long the animation will take
      // ^ registering our own function to listen to page changes
      builder: (BuildContext context, int index) {
        return stack[index];

        // return Center(
        //   child: _controller.value.isInitialized
        //       ? VideoPlayer(_controller)
        //       : Container(),
        // );
      },
    );
  }
}
