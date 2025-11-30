import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/home/drawers/home_drawer.dart';
import 'package:reddit/features/home/screens/search_community_screen.dart';
import 'package:reddit/features/home/screens/search_user_screen.dart';
import 'package:reddit/features/home/widgets/community_posts.dart';
import 'package:reddit/features/home/widgets/home_post.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/theme/pallete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

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
              drawer: const HomeDrawer(),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    pinned: false,
                    expandedHeight: 0,
                    forceElevated: innerBoxIsScrolled,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(Constants.logoPath, height: 30),
                        const SizedBox(width: 8),
                        const Text(
                          'Reddit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    leading: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => const SearchUserScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.search),
                      ),

                      const SizedBox(width: 18),
                    ],
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: Pallete.redColor,
                      labelColor: Pallete.redColor,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: const [
                        Tab(text: 'Home'),
                        Tab(text: 'Communities'),
                      ],
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController, // FIXED: Added controller
                  children: [
                    // Home Posts Tab
                    HomePosts(),
                    // Communities Tab
                    CommunityPosts(),
                  ],
                ),
              ),
            );
          },
          error: (err, st) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: ErrorText(error: err.toString()),
            );
          },
          loading: () {
            return const Scaffold(body: Loader());
          },
        );
  }
}
