import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/profile/screens/profile_screen.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/theme/pallete.dart';

class CommunityMembersScreen extends ConsumerStatefulWidget {
  final String communityName;
  const CommunityMembersScreen({super.key, required this.communityName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunityMembersScreenState();
}

class _CommunityMembersScreenState
    extends ConsumerState<CommunityMembersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('r/${widget.communityName} Members'),
        backgroundColor: Pallete.darkModeAppTheme.appBarTheme.backgroundColor,
      ),
      body: ref
          .watch(communityMembersProvider(widget.communityName))
          .when(
            data: (members) {
              if (members.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Members Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This community has no members yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Members count header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      '${members.length} Members',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  // Members list
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(communityMembersProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  member.profilePicture,
                                ),
                              ),
                              title: Text(
                                member.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${member.karma} karma',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: _buildMemberBadge(member),
                              onTap: () {
                                // Navigate to member's profile screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(userId: member.uid),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (error, stackTrace) =>
                Scaffold(body: ErrorText(error: error.toString())),
            loading: () => const Scaffold(body: Loader()),
          ),
    );
  }

  Widget _buildMemberBadge(UserModel member) {
    final currentUser = ref.watch(currentUserProvider).value;

    return ref
        .watch(communityByNameProvider(widget.communityName))
        .when(
          data: (community) {
            if (community == null) return const SizedBox();

            if (community.mods.contains(member.uid)) {
              return SvgPicture.asset(
                Constants.crownPath,
                height: 16,
                colorFilter: ColorFilter.mode(Colors.amber, BlendMode.srcIn),
              );
            }

            return PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'message',
                  child: Text('Send Message'),
                ),
                community.mods.contains(currentUser!.uid)
                    ? PopupMenuItem(
                        value: 'make_mod',
                        child: Text('Make Moderator'),
                      )
                    : PopupMenuItem(
                        value: 'report_user',
                        child: Text('Report User'),
                      ),
              ],
              onSelected: (value) {},
              icon: const Icon(
                Icons.more_vert_sharp,
                size: 16,
                color: Colors.grey,
              ),
            );
          },
          error: (error, st) => const SizedBox(),
          loading: () => const SizedBox(),
        );
  }
}
