import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/home/drawers/create_community_drawer.dart';

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
                  ClipOval(
                    child: FadeInImage(
                      placeholder: AssetImage(Constants.logoPath),
                      image: NetworkImage(currentUser.profilePicture),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          Constants.logoPath,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
              ),
              drawer: CreateCommunitiesDrawer(),
              body: SafeArea(child: Column()),
            );
          },
          error: (err, st) {
            return Scaffold(body: ErrorText(error: err.toString()));
          },
          loading: () {
            return const Scaffold(body: Loader());
          },
        );
  }
}
