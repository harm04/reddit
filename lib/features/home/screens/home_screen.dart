import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(currentUserProvider)
        .when(
          data: (currentUser) {
            if (currentUser == null) {
              return const Scaffold(
                body: Center(
                  child: Text('User not found. Please try logging in again.'),
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Constants.logoPath, height: 30),
                    const SizedBox(width: 8),
                    const Text('Reddit'),
                  ],
                ),
                actions: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(currentUser.profilePicture),
                  ),
                  SizedBox(width: 18),
                ],
              ),
              drawer: Drawer(
                elevation: 20,
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            drawerItem(
                              iconPath: Constants.discoverPath,
                              title: 'Discover Communities',
                            ),
                            drawerItem(
                              iconPath: Constants.settingsPath,
                              title: 'Settings',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.profilePicture),
                      radius: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${currentUser.name}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${currentUser.email}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Karma: ${currentUser.karma}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (err, st) {
            print('Error in HomeScreen: $err');
            return Scaffold(body: ErrorText(error: err.toString()));
          },
          loading: () {
            print('Loading user data in HomeScreen...');
            return const Scaffold(body: Loader());
          },
        );
  }
}

Widget drawerItem({required String title, required String iconPath}) {
  return Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Row(
      children: [
        SvgPicture.asset(
          iconPath,
          height: 20,
          colorFilter: ColorFilter.mode(Pallete.whiteColor, BlendMode.srcIn),
        ),
        SizedBox(width: 15),
        Text(title, style: TextStyle(fontSize: 16)),
      ],
    ),
  );
}
