import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/community/screens/mod_tools_screen.dart';

class CommunityScreen extends ConsumerWidget {
  final String communityName;
  const CommunityScreen({super.key, required this.communityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    return Scaffold(
      body: ref
          .watch(communityByNameProvider(communityName))
          .when(
            data: (community) {
              if (community == null) {
                return const Center(child: Text('Community not found'));
              }
              return NestedScrollView(
                headerSliverBuilder: (context, innerBosIsScrolled) {
                  return [
                    SliverAppBar(
                      floating: true,
                      snap: true,
                      expandedHeight: 150,
                      flexibleSpace: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(community.banner),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // child: Positioned.fill(
                            //   child: Image.network(
                            //     user!.bannerPicture,
                            //     fit: BoxFit.cover,
                            //   ),
                            // ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 50, // Height of the shadow gradient
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
                                    Colors.black.withOpacity(0.9),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundImage: NetworkImage(
                                        community.avatar,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'r/${community.name}',
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${community.members.length.toString()} members',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              community.mods.contains(currentUser!.uid)
                                  ? OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ModToolsScreen(
                                                communityName: community.name,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Text('Mod tools'),
                                    )
                                  : OutlinedButton(
                                      onPressed: () {
                                        ref
                                            .read(
                                              communityControllerProvider
                                                  .notifier,
                                            )
                                            .joinCommunity(
                                              community,
                                              currentUser.uid,
                                            );
                                      },
                                      child: Text(
                                        community.members.contains(
                                              currentUser.uid,
                                            )
                                            ? 'Leave'
                                            : 'Join',
                                      ),
                                    ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ];
                },
                body: Center(child: Text('Displaying communities')),
              );
            },
            error: (error, stackTrace) {
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}
