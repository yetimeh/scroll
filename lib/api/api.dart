import 'package:hive/hive.dart';

class ScrollAPI {
  final likedBox = Hive.openBox("liked");
  final playlistBox = Hive.openBox("playlists");

  void likeVideo(String mediumID) async {
    Box box = Hive.box("liked");

    if (isLiked(mediumID)) {
      await box.delete(mediumID);
      print("Unliked");
      return;
    }

    print("Liked");
    await box.put(mediumID, 1);
  }

  bool isLiked(String mediumID) {
    Box box = Hive.box("liked");

    return box.containsKey(mediumID);
  }

  Future<bool> createNewPlaylist(String playlistName) async {
    Box box = Hive.box("playlists");

    if (box.containsKey(playlistName)) {
      return false;
    }

    await box.put(playlistName, []);
    return true;
  }

  List getPlaylistLiked() {
    Box box = Hive.box("liked");
    print("${["Liked videos", box.keys.length]}");

    return [
      ["Liked videos", box.keys.length]
    ];
  }

  List getPlaylists() {
    var playlists = [];
    Box box = Hive.box("playlists");

    for (var key in box.keys) {
      playlists.add([key, box.toMap()[key].length]);
    }

    return playlists;
  }

  List isSaved(String mediumID) {
    Box box = Hive.box("playlists");

    var data = box.toMap();
    var saved = [];

    for (var key in box.keys) {
      if (data[key].contains(mediumID) == true) {
        saved.add(key);
      }
    }

    return saved;
  }

  bool saveToPlaylist(String playlist, String mediumID) {
    Box box = Hive.box("playlists");

    var data = box.toMap();
    print("DATA $data $playlist ${playlist == box.keys.toList()[0]}");

    if (data[playlist].contains(mediumID)) {
      data[playlist].remove(mediumID);
      box.put(playlist, data[playlist]);
      return false;
    }

    data[playlist].add(mediumID);
    box.put(playlist, data[playlist]);

    return true;
  }

  List<dynamic> getVideos(String playlistName) {
    if (playlistName == "Liked videos") {
      Box box = Hive.box("liked");
      return box.keys.toList();
    }

    Box box = Hive.box("playlists");
    var map = box.toMap();

    return map[playlistName];
  }

  Future deletePlaylist(String playlistName) async {
    if (playlistName == "Liked videos") {
      Box box = Hive.box("liked");
      await box.clear();

      return;
    }

    Box box = Hive.box("playlists");

    await box.delete(playlistName);
  }
}
