import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/home/screens/home_screen.dart';
import 'package:reddit/features/profile/screens/profile_screen.dart';
import 'package:reddit/theme/pallete.dart';

class NavigationBarView extends ConsumerStatefulWidget {
  const NavigationBarView({super.key});

  @override
  ConsumerState<NavigationBarView> createState() => _NavigationBarViewState();
}

class _NavigationBarViewState extends ConsumerState<NavigationBarView> {
  late PersistentTabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    final currentUser = ref.watch(currentUserProvider).value;

    return [
      HomeScreen(),
      Center(child: Text('settings')),
      ProfileScreen(userId: currentUser!.uid),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.home, size: 20),
        title: ("Home"),
        activeColorPrimary: Pallete.whiteColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.add, size: 26),
        title: ("Create"),
        activeColorPrimary: Pallete.whiteColor,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(CupertinoIcons.person_alt, size: 20),
        title: ("Profile"),
        activeColorPrimary: Pallete.whiteColor,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardAppears: true,

      padding: const EdgeInsets.only(top: 8),
      backgroundColor: Pallete.blackColor,
      isVisible: true,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle:
          NavBarStyle.style6, // Choose the nav bar style with this property
    );
  }
}
