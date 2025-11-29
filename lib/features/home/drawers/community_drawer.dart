import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/community/screens/community_screen.dart';
import 'package:reddit/features/community/screens/create_community_screen.dart';
import 'package:reddit/theme/pallete.dart';

class CreateCommunitiesDrawer extends ConsumerWidget {
  const CreateCommunitiesDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    return Drawer(
      elevation: 20,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20),
                ListTile(
                  title: const Text('Create Communities'),
                  leading: SvgPicture.asset(
                    Constants.addPath,
                    height: 20,

                    colorFilter: ColorFilter.mode(
                      currentTheme.iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => CreateCommunityScreen(),
                      ),
                    );
                  },
                ),
                //display the list of communities the user is part of
                ref
                    .watch(
                      userCommunitiesProvider(
                        ref.read(currentUserProvider).value!.uid,
                      ),
                    )
                    .when(
                      data: (communities) {
                        if (communities.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'You are not part of any communities yet.',
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: communities.length,
                          
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            print(community);
                            return ListTile(
                              title: Text(community.name),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => CommunityScreen(
                                      communityName: community.name,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      error: (error, st) => ErrorText(error: error.toString()),
                      loading: () => Loader(),
                    ),
                Divider(),

                ListTile(
                  title: const Text('Discover Communities'),
                  leading: SvgPicture.asset(
                    Constants.discoverPath,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      currentTheme.iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  title: const Text('Settings'),
                  leading: SvgPicture.asset(
                    Constants.settingsPath,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      currentTheme.iconTheme.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
