import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:scroll/home/video_provider.dart';

import 'package:video_player/video_player.dart';
import 'package:scroll/home/page.dart' as VideoPage;

class HomePage extends StatefulWidget {
  VideoPlayerController? _videoPlayerController;
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Medium> allMedia = [];
  List<VideoProvider> stack = [];

  @override
  void initState() {
    super.initState();

    _promptPermissionSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getAllMedia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print("Done lmao");

            return VideoPage.Page(
              stack: stack,
              allMedia: allMedia,
            );
          }

          return const Scaffold(
            backgroundColor: Colors.black26,
            body: Center(
                child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text("Loading media...")
              ],
            )),
          );
        },
      ),
    );
  }

  Future getAllMedia() async {
    final List<Album> videoAlbums = await PhotoGallery.listAlbums();

    MediaPage page = await videoAlbums.first.listMedia();

    for (var i = 0; i < page.items.length; i++) {
      if (page.items[i].mediumType == MediumType.video) {
        print("yeah");
        allMedia.add(page.items[i]);
      }
    }

    while (!page.isLast) {
      print('yes');
      page = await page.nextPage();

      for (var i = 0; i < page.items.length; i++) {
        if (page.items[i].mediumType == MediumType.video) {
          allMedia.add(page.items[i]);
        }
      }
    }

    print("Done");

    return;
  }

  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }
}
