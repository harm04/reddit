import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/community/screens/community_screen.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/features/post/controller/post_voting_controller.dart';
import 'package:reddit/features/profile/screens/profile_screen.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends ConsumerWidget {
  final PostModel postModel;
  const PostCard({super.key, required this.postModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePost = postModel.type == 'Image';
    final textPost = postModel.type == 'Text';
    final linkPost = postModel.type == 'Link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value!;

    final votingState = ref.watch(postVotingControllerProvider);
    final votingController = ref.read(postVotingControllerProvider.notifier);
    final currentPost = votingController.getPostVoteState(postModel);
    final isUpvoted = currentPost.upvotes.contains(currentUser.uid);
    final isDownvoted = currentPost.downvotes.contains(currentUser.uid);

    // FIXED: Show separate counts instead of net difference
    final upvoteCount = currentPost.upvotes.length;
    final downvoteCount = currentPost.downvotes.length;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.drawerTheme.backgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 4,
                      ).copyWith(right: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          userId: postModel.uid,
                                        ),
                                      ),
                                    ),
                                child: CircleAvatar(
                                  radius: 17,
                                  backgroundImage: NetworkImage(
                                    postModel.communityProfilePic,
                                  ),
                                ),
                              ),
                              Padding(
                                // FIXED: EdgeInsetsGeometry to EdgeInsets
                                padding: EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CommunityScreen(
                                                    communityName:
                                                        postModel.communityName,
                                                  ),
                                            ),
                                          ),
                                      child: Text(
                                        'r/${postModel.communityName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                    userId: postModel.uid,
                                                  ),
                                            ),
                                          ),
                                      child: Text(
                                        'u/${postModel.username} · ${timeago.format(postModel.createdAt)}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              postModel.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (imagePost) ...[
                            const SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  postModel.link!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                          if (linkPost) ...[
                            const SizedBox(height: 5),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Pallete.greyColor.withOpacity(0.3),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AnyLinkPreview(
                                  link: postModel.link!,
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                ),
                              ),
                            ),
                          ],
                          if (textPost) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                postModel.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // FIXED: Upvote button with separate count
                              GestureDetector(
                                onTap: () {
                                  votingController.upvotePost(postModel);
                                },
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isUpvoted
                                      ? SvgPicture.asset(
                                          key: ValueKey(
                                            'upvote_filled_${postModel.id}',
                                          ),
                                          Constants.likeFilledPath,
                                          colorFilter: ColorFilter.mode(
                                            Pallete.redColor,
                                            BlendMode.srcIn,
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          key: ValueKey(
                                            'upvote_outlined_${postModel.id}',
                                          ),
                                          Constants.likeOutlinePath,
                                          colorFilter: ColorFilter.mode(
                                            currentTheme.iconTheme.color!,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  key: ValueKey(
                                    'upvote_count_${upvoteCount}_${postModel.id}',
                                  ),
                                  upvoteCount.toString(),
                                  style: TextStyle(
                                    color: isUpvoted
                                        ? Pallete.redColor
                                        : currentTheme
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                    fontWeight: isUpvoted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              GestureDetector(
                                onTap: () {
                                  votingController.downvotePost(postModel);
                                },
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Transform.rotate(
                                    angle:
                                        3.14159, // 180 degrees to flip upvote icon for downvote
                                    child: isDownvoted
                                        ? SvgPicture.asset(
                                            key: ValueKey(
                                              'downvote_filled_${postModel.id}',
                                            ),
                                            Constants.likeFilledPath,
                                            colorFilter: ColorFilter.mode(
                                              Pallete.blueColor,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                        : SvgPicture.asset(
                                            key: ValueKey(
                                              'downvote_outlined_${postModel.id}',
                                            ),
                                            Constants.likeOutlinePath,
                                            colorFilter: ColorFilter.mode(
                                              currentTheme.iconTheme.color!,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  key: ValueKey(
                                    'downvote_count_${downvoteCount}_${postModel.id}',
                                  ),
                                  downvoteCount.toString(),
                                  style: TextStyle(
                                    color: isDownvoted
                                        ? Pallete.blueColor
                                        : currentTheme
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                    fontWeight: isDownvoted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Comments
                              SvgPicture.asset(
                                Constants.commentsPath,
                                colorFilter: ColorFilter.mode(
                                  currentTheme.iconTheme.color!,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text('${postModel.commentCount} Comments'),
                              SizedBox(width: 16),
                              ref
                                  .watch(
                                    communityByNameProvider(
                                      postModel.communityName,
                                    ),
                                  )
                                  .when(
                                    data: (community) {
                                      if(community!.mods.contains(currentUser.uid)) {
                                        return SvgPicture.asset(
                                          Constants.crownPath,
                                          colorFilter: ColorFilter.mode(
                                            currentTheme.iconTheme.color!,
                                            BlendMode.srcIn,
                                          ),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    },
                                    error: (error, st) =>
                                        ErrorText(error: error.toString()),
                                    loading: () => Loader(),
                                  ),
                            ],
                          ),

                          if (votingState.pendingSyncs.contains(postModel.id) &&
                              votingState.isSyncing)
                            Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Pallete.blueColor,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Syncing to server...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (postModel.commentCount != 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'View comments',
                              style: TextStyle(color: Pallete.blueColor),
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Divider(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  postModel.uid == currentUser.uid
                      ? const PopupMenuItem(
                          value: 'delete_post',
                          child: Text('Delete post'),
                        )
                      : const PopupMenuItem(
                          value: 'report_post',
                          child: Text('Report post'),
                        ),
                ],
                onSelected: (value) {
                  if (value == 'delete_post') {
                    // Handle delete post
                    ref
                        .read(postControllerProvider.notifier)
                        .deletePost(postModel.id);
                  } else if (value == 'report_post') {
                    // Handle report post
                  }
                },
                icon: const Icon(Icons.more_vert_sharp, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
