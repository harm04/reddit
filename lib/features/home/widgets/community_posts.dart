import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/post/controller/post_controller.dart';

class CommunityPosts extends ConsumerStatefulWidget {
  const CommunityPosts({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommunityPostsState();
}

class _CommunityPostsState extends ConsumerState<CommunityPosts> {
  Future<void> _refresh() async {
    ref.invalidate(userCommunityPostsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(userCommunityPostsProvider)
        .when(
          data: (communityPosts) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20),
                itemCount: communityPosts.length,
                itemBuilder: (BuildContext context, int index) {
                  final post = communityPosts[index];
                  return PostCard(postModel: post);
                },
              ),
            );
          },
          error: (error, st) => ErrorText(error: error.toString()),
          loading: () => Loader(),
        );
  }
}
