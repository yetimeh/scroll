import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:scroll/home/home_page.dart';
import 'package:scroll/home/video_provider.dart';
import 'package:scroll/playlists/playlist_view.dart';
import 'package:scroll/settings/settings_page.dart';
import 'package:sizer/sizer.dart' as sr;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.initFlutter();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return sr.Sizer(builder: (context, orientation, deviceType) {
      return ChangeNotifierProvider(
        create: (context) => GlobalVariableProvider(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scroll(),
            theme: ThemeData.dark()
                .copyWith(scaffoldBackgroundColor: const Color(0xff2A2B2A))),
      );
    });
  }
}

final GlobalKey<PlaylistPageState> playlistPageKey = GlobalKey();

class Scroll extends StatefulWidget {
  const Scroll({super.key});

  @override
  State<Scroll> createState() => _ScrollState();
}

class _ScrollState extends State<Scroll> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  bool firstTime = true;

  List<Widget> screens = [
    HomePage(),
    PlaylistPage(
      key: playlistPageKey,
    ),
    const SettingsPage(),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: ("Home"),
        activeColorPrimary: const Color(0xff52D1DC),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.play_fill),
        title: ("Playlists"),
        activeColorPrimary: const Color(0xff52D1DC),
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.settings),
        title: ("Settings"),
        activeColorPrimary: const Color(0xff52D1DC),
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: screens,
      controller: _controller,
      items: _navBarsItems(),
      backgroundColor: const Color.fromARGB(255, 15, 12, 20),

      hideNavigationBarWhenKeyboardShows:
          true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(16.0),
        colorBehindNavBar: Colors.transparent,
      ),
      navBarStyle: NavBarStyle.style9,
      screenTransitionAnimation: const ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200)),
      onItemSelected: (value) {
        var controller =
            Provider.of<GlobalVariableProvider>(context, listen: false)
                .globalVariable;
        if (!(controller == null)) {
          if (value == 0) {
            controller.play();
            return;
          } else {
            setState(() {
              controller.pause();
              var keys =
                  Provider.of<GlobalVariableProvider>(context, listen: false)
                      .keyForPlaylistWidget;

              if (keys != null) {
                if (firstTime == true) {
                  firstTime = false;
                  return;
                } else {
                  for (var i = 0; i < keys.length; i++) {
                    if (keys[i].currentState != null) {
                      keys[i].currentState!.refresh();
                    }
                  }

                  playlistPageKey.currentState!.refresh();
                }
              }
            });
          }
        }
      },
    );
  }
}
