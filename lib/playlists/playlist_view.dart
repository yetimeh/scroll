import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';
import 'package:scroll/api/api.dart';
import 'package:scroll/home/video_provider.dart';
import 'package:scroll/main.dart';
import 'package:scroll/playlists/playlist_scroll_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PlaylistWidget extends StatefulWidget {
  String playlistName = "";
  final GlobalKey<PlaylistWidgetState> _myKey = GlobalKey();

  PlaylistWidget({super.key, required this.playlistName});

  @override
  State<PlaylistWidget> createState() => PlaylistWidgetState();
}

class PlaylistWidgetState extends State<PlaylistWidget> {
  final api = ScrollAPI();
  List<Widget> images = [];
  bool shuffle = false;

  @override
  void initState() {
    List videos = api.getVideos(widget.playlistName);

    createVideoThumbnails(videos);
    // refresh();
    super.initState();
  }

  Future createVideoThumbnails(List<dynamic> videos) async {
    images = [];

    for (var i = 0; i < videos.length; i++) {
      var file = await PhotoGallery.getFile(mediumId: videos[i]);

      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight:
            400, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 100,
      );

      var thumbnail = File(thumbnailPath!);

      var image = Image(
        image: FileImage(thumbnail),
      );

      // images.add(image);

      setState(() {
        images.add(GestureDetector(
          onTap: () {
            var tempList = videos;
            print("$tempList - $i YETI");

            PersistentNavBarNavigator.pushDynamicScreen(context,
                withNavBar: true, screen: MaterialPageRoute(builder: (context) {
              return PlaylistScrollView(
                  videos: tempList, isShuffled: shuffle, firstVideo: videos[i]);
            }));

            // Navigator.push(context, MaterialPageRoute(builder: (context) {

            // }));
          },
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(thumbnail), fit: BoxFit.cover)),
          ),
        ));
      });

      print("IMAGES $images");
    }
  }

  void refresh() {
    List videos = api.getVideos(widget.playlistName);

    createVideoThumbnails(videos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          height: 60,
          color: const Color.fromARGB(255, 61, 39, 57),
          child: GestureDetector(
            onTap: () {
              print("HII");
            },
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    CupertinoIcons.play_fill,
                    color: Color.fromARGB(255, 164, 67, 101),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.playlistName,
                  style: const TextStyle(fontSize: 19.0),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          shuffle = !shuffle;
                        });
                      },
                      icon: Icon(
                        Icons.shuffle,
                        color: shuffle == false ? Colors.white : Colors.green,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton(
                      onPressed: () {
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

                                    await api
                                        .deletePlaylist(widget.playlistName);

                                    setState(() {
                                      playlistPageKey.currentState!.refresh();
                                      var keys =
                                          Provider.of<GlobalVariableProvider>(
                                                  context,
                                                  listen: false)
                                              .keyForPlaylistWidget;

                                      print(
                                          "KEYS $keys[0].currentState!.widget.");

                                      for (var i = 0; i < keys!.length; i++) {
                                        if (keys[i].currentState != null) {
                                          if (keys[i]
                                                  .currentState!
                                                  .widget
                                                  .playlistName ==
                                              "Liked videos") {
                                            // why did i do this?
                                            keys[i].currentState!.refresh();
                                          } else if (keys[i]
                                                  .currentState!
                                                  .widget
                                                  .playlistName !=
                                              widget.playlistName) {
                                            // why did i do this?
                                            keys[i].currentState!.refresh();
                                          }
                                        }
                                      }
                                    });
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
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      )),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: images.isNotEmpty ? 220 : 150,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: images.length <= 3 ? 1 : 2,
                crossAxisSpacing: images.isNotEmpty ? 10 : 0,
                mainAxisSpacing: images.isNotEmpty ? 20 : 0),
            shrinkWrap: true,
            itemCount: images.isNotEmpty ? images.length : 1,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (images.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Nothing here yet!",
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                );
              }
              return images[index];
            },
            // children: [
            //   Container(
            //     color: Colors.amber,
            //   ),
            //   Container(
            //     color: Colors.green,
            //   ),
            //   Container(
            //     color: Colors.blue,
            //   ),
            //   Container(
            //     color: Colors.amber,
            //   ),
            //   Container(
            //     color: Colors.green,
            //   ),
            //   Container(
            //     color: Colors.blue,
            //   ),
            //   Container(
            //     color: Colors.amber,
            //   ),
            //   Container(
            //     color: Colors.green,
            //   ),
            //   Container(
            //     color: Colors.blue,
            //   ),
            // ]),
          ),
        )
      ],
    );
  }
}

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  ScrollAPI api = ScrollAPI();
  List keys = [];
  GlobalKey? myKey;

  @override
  void initState() {
    List playlists = api.getPlaylistLiked() + api.getPlaylists();
    print("PLAylISTS $playlists");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var i = 0; i < playlists.length; i++) {
        Provider.of<GlobalVariableProvider>(context, listen: false)
            .setGlobalKeyForPlaylist(keys[i]);
      }
    });
  }

  void refresh() {
    print("refreshed");
    setState(() {
      List playlists = api.getPlaylistLiked() + api.getPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    List playlists = api.getPlaylistLiked() + api.getPlaylists();

    for (var i = 0; i < playlists.length; i++) {
      GlobalKey<PlaylistWidgetState> myKey = GlobalKey(debugLabel: "$i");
      keys.add(myKey);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GlobalVariableProvider>(context, listen: false)
          .replaceGlobalKeyForPlaylist(keys);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                print("SETTING STATE");
                setState(() {});
              },
              child: const Text(
                "Playlists",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: playlists.length,
              itemBuilder: ((context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: PlaylistWidget(
                    key: keys[index],
                    playlistName: playlists[index][0],
                  ),
                );
              }),
            ),
          ),
        ],
      )),
    );
  }
}
