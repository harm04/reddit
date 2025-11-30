import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/post/controller/post_controller.dart';

class HomePosts extends ConsumerStatefulWidget {
  const HomePosts({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePostsState();
}

class _HomePostsState extends ConsumerState<HomePosts> {
  Future<void> _refresh() async {
    ref.invalidate(allPostsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(allPostsProvider)
        .when(
          data: (allPosts) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20),
                itemCount: allPosts.length,
                itemBuilder: (BuildContext context, int index) {
                  final post = allPosts[index];
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
