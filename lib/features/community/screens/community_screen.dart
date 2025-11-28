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
                          Positioned.fill(
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(18),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      onPressed: () {},
                                      child: Text(
                                        community.members.contains(
                                              currentUser.uid,
                                            )
                                            ? 'Joined'
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
