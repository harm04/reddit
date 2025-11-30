import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/features/profile/screens/edit_profile_screen.dart';
import 'package:reddit/theme/pallete.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    bool isLoading = ref.watch(authControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return isLoading
        ? Loader()
        : ref
              .watch(userDetailsProvider(widget.userId))
              .when(
                data: (user) {
                  return Scaffold(
                    body: NestedScrollView(
                      headerSliverBuilder: (context, innerBosIsScrolled) {
                        return [
                          SliverAppBar(
                            automaticallyImplyActions: false,
                            floating: true,
                            snap: true,
                            expandedHeight: 150,
                            title: Text(
                              'Profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            flexibleSpace: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(user!.bannerPicture),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Pallete.blackColor.withOpacity(0.9),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(18),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 35,
                                            backgroundImage: NetworkImage(
                                              user.profilePicture,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name,
                                                style: const TextStyle(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text('karma: ${user.karma}'),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'awards: ${user.awards.length}',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    user.uid == currentUser!.uid
                                        ? IconButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditProfileScreen(
                                                        userId: user.uid,
                                                        name: user.name,
                                                      ),
                                                ),
                                              );
                                            },
                                            icon: SvgPicture.asset(
                                              Constants.pencilPath,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                currentTheme.iconTheme.color!,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        ];
                      },
                      body: ref
                          .watch(userPostsProvider(user!.uid))
                          .when(
                            data: (userPost) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),

                                  Expanded(
                                    child: userPost.isEmpty
                                        ? const Center(
                                            child: Text('No posts yet'),
                                          )
                                        : ListView.builder(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            itemCount: userPost.length,
                                            itemBuilder: (context, index) {
                                              final post = userPost[index];
                                              return PostCard(postModel: post);
                                            },
                                          ),
                                  ),
                                ],
                              );
                            },
                            error: (error, st) =>
                                ErrorText(error: error.toString()),
                            loading: () => Loader(),
                          ),
                    ),
                  );
                },
                error: (error, st) => ErrorText(error: error.toString()),
                loading: () => Loader(),
              );
  }
}
