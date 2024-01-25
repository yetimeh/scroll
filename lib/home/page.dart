import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';
import 'package:scroll/home/video_provider.dart';
import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:video_player/video_player.dart';

class MODALL {
  VideoPlayerController? value;
  String? medium_id;
  Controller? controller;
  modal() {
    value;
    medium_id;
    controller;
  }

  void dispose() {
    value?.dispose();
  }
}

class Page extends StatefulWidget {
  final List<VideoProvider> stack;
  final List<Medium> allMedia;

  const Page({super.key, required this.stack, required this.allMedia});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  int video_index = 0;

  int scroll_index = 0;
  int widget_index = 0;

  Map keys_and_widgets = {};
  Map medium_ids = {};

  final key = GlobalKey<VideoProviderState>();

  late Controller controller = Controller()
    ..addListener((event) {
      _handleCallbackEvent(event.direction, event.success);
    });

  @override
  void dispose() {
    for (var i = 0; i < keys_and_widgets.length; i++) {
      keys_and_widgets[i]?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    initAsync();

    super.initState();
    addTenToStack();
  }

  Future<void> initAsync() async {
    await Future.delayed(const Duration(milliseconds: 900), () {
      keys_and_widgets[0].value != null
          ? Provider.of<GlobalVariableProvider>(context, listen: false)
              .setGlobalVariable(keys_and_widgets[0].value)
          : null;
      keys_and_widgets[0].value != null
          ? keys_and_widgets[0].value.play()
          : controller.jumpToPosition(controller.getScrollPosition() + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    // var medium_id = '1000287984';
    // var modal = MODALL();
    // modal.controller = controller;
    // keys_and_widgets[controller.getScrollPosition()] = modal;

    // var provider = VideoProvider(
    //     key: UniqueKey(),
    //     modal: keys_and_widgets[controller.getScrollPosition()],
    //     mediumId: medium_id);

    // return provider;

    return TikTokStyleFullPageScroller(
      contentSize: widget.stack.length,
      swipePositionThreshold: 0.2,
      // ^ the fraction of the screen needed to scroll
      swipeVelocityThreshold: 300,
      // ^ the velocity threshold for smaller scrolls
      animationDuration: const Duration(milliseconds: 400),
      // ^ how long the animation will take
      controller: controller,
      // ^ registering our own function to listen to page changes
      builder: (BuildContext context, int index) {
        return widget.stack[index];
      },
    );
  }

  void _handleCallbackEvent(ScrollDirection direction, ScrollSuccess success,
      {int? currentIndex}) async {
    print(
        "Scroll callback received with data: {direction: $direction, success: $success and index: ${currentIndex ?? 'not given'}}");

    if (direction == ScrollDirection.FORWARD &&
        success == ScrollSuccess.SUCCESS) {
      // keys_and_widgets[controller.getScrollPosition() - 1].value.dispose();
      keys_and_widgets[controller.getScrollPosition() - 1].value != null
          ? keys_and_widgets[controller.getScrollPosition() - 1].value.pause()
          : null;

      Provider.of<GlobalVariableProvider>(context, listen: false)
          .setGlobalVariable(
              keys_and_widgets[controller.getScrollPosition()].value);

      // medium_ids[controller.getScrollPosition() - 1] =
      //     keys_and_widgets[controller.getScrollPosition() - 1];

      // print("MEDIUMIDS = $medium_ids  || ${controller.getScrollPosition()}");

      // if (medium_ids.containsKey(controller.getScrollPosition())) {
      //   print("CALLED");

      //   print(
      //       "CONTROLLER POSITION: ${controller.getScrollPosition()} STACK LENGTH: ${widget.stack.length}");

      //   print(
      //       "MEDIUM_ID = ${medium_ids[controller.getScrollPosition()].medium_id}");

      //   var mediumId = medium_ids[controller.getScrollPosition()].medium_id;
      //   var modal = MODALL();
      //   modal.controller = controller;
      //   keys_and_widgets[controller.getScrollPosition()] = modal;

      //   var provider = VideoProvider(
      //       key: UniqueKey(),
      //       modal: keys_and_widgets[controller.getScrollPosition()],
      //       mediumId: mediumId);

      //   setState(() {
      //     widget.stack.removeAt(controller.getScrollPosition());

      //     widget.stack.insert(controller.getScrollPosition(), provider);
      //   });
      // }

      // widget.stack.removeWhere((element) {
      //   return element.modal ==
      //       keys_and_widgets[controller.getScrollPosition() - 1];
      // });

      await Future.delayed(const Duration(milliseconds: 100), () async {
        if (keys_and_widgets[controller.getScrollPosition()].value == null) {
          // setState(() {
          //   keys_and_widgets.remove(controller.getScrollPosition());
          //   return;
          // });
          // setState(() {
          // controller.jumpToPosition(controller.getScrollPosition() + 1);
          // });
        }

        // keys_and_widgets[controller.getScrollPosition() - 1].value.pause();
        int i = 0;

        while (keys_and_widgets[controller.getScrollPosition()].value == null &&
            i <= 10) {
          await Future.delayed(const Duration(milliseconds: 100));
          i++;
        }

        keys_and_widgets[controller.getScrollPosition()].value != null
            ? keys_and_widgets[controller.getScrollPosition()].value.play()
            : controller.jumpToPosition(controller.getScrollPosition() + 1);
      });

      if (video_index == 5) {
        video_index = 0;

        setState(() {
          addTenToStack();
        });
      }
      // }
    } else if (direction == ScrollDirection.BACKWARDS &&
        success == ScrollSuccess.SUCCESS) {
      // keys_and_widgets[controller.getScrollPosition() + 1].value.dispose();
      keys_and_widgets[controller.getScrollPosition() + 1].value.pause();
      keys_and_widgets[controller.getScrollPosition()].value != null
          ? keys_and_widgets[controller.getScrollPosition()].value.play()
          : (controller.getScrollPosition() - 1 == -1
              ? controller.jumpToPosition(controller.getScrollPosition() + 1)
              : controller.jumpToPosition(controller.getScrollPosition() - 1));

      Provider.of<GlobalVariableProvider>(context, listen: false)
          .setGlobalVariable(
              keys_and_widgets[controller.getScrollPosition()].value);

      // medium_ids[controller.getScrollPosition() + 1] =
      //     keys_and_widgets[controller.getScrollPosition() + 1];

      // print("MEDIUMIDS = $medium_ids");

      // if (medium_ids.containsKey(controller.getScrollPosition())) {
      //   print("CALLEDaa");

      //   var mediumId = medium_ids[controller.getScrollPosition()].medium_id;

      //   var modal = MODALL();
      //   modal.controller = controller;
      //   keys_and_widgets[controller.getScrollPosition()] = modal;

      //   var provider = VideoProvider(
      //       key: UniqueKey(),
      //       modal: keys_and_widgets[controller.getScrollPosition()],
      //       mediumId: mediumId);

      //   setState(() {
      //     widget.stack.removeAt(controller.getScrollPosition());

      //     widget.stack.insert(controller.getScrollPosition(), provider);

      //     print("CALLED");
      //   });
      // }

      await Future.delayed(const Duration(milliseconds: 500), () {
        keys_and_widgets[controller.getScrollPosition()].value != null
            ? keys_and_widgets[controller.getScrollPosition()].value.play()
            : controller.jumpToPosition(controller.getScrollPosition() + 1);
      });
    }
  }

  Future addVideoToStack() async {
    for (var i = 0; i < widget.stack.length; i++) {}

    var random = Random();

    var randomIndex = random.nextInt(widget.allMedia.length);

    if (widget.stack.length == widget.allMedia.length) {
      return;
    }

    for (var i = 0; i < widget.stack.length; i++) {
      if ((widget.stack[i].mediumId == widget.allMedia[randomIndex].id)) {
        while ((widget.stack[i].mediumId == widget.allMedia[randomIndex].id)) {
          randomIndex = random.nextInt(widget.allMedia.length);
          i = 0;
        }
      }
    }

    var modal = MODALL();
    modal.controller = controller;

    keys_and_widgets[widget_index] = modal;

    print("created video ${widget.allMedia[randomIndex].id}");

    GlobalKey<VideoProviderState> generateUniqueKey() {
      return GlobalKey<VideoProviderState>(
          debugLabel: 'GlobalKey#$widget_index');
    }

    setState(() {
      var key = generateUniqueKey();
      var provider = VideoProvider(
          key: key,
          modal: keys_and_widgets[widget_index],
          mediumId: widget.allMedia[randomIndex].id);

      widget.stack.add(provider);
      widget_index++;
    });

    // for (var i = 0; i < widget.stack.length; i++) {
    //   print("initlaising $i");
    //   if (keys_and_widgets[i].value != null) {
    //     keys_and_widgets[i].value.initialize();
    //   }
    // }
    return;
  }

  void addTenToStack() async {
    var i = 0;
    while (!(i == 5)) {
      print("Added video to stack");
      addVideoToStack();

      video_index++;

      i++;
    }
  }
}
