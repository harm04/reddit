import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/common/storage/storage_api.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/api/post_api.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';

//provider to get post by community name
final postsByCommunityProvider = FutureProvider.family<List<PostModel>, String>(
  (ref, communityName) async {
    final postController = ref.watch(postControllerProvider.notifier);
    final result = await postController.getPostsByCommunity(communityName);

    return result;
  },
);

//provider to get user posts
final userPostsProvider = FutureProvider.family<List<PostModel>, String>((
  ref,
  uid,
) async {
  final postAPI = ref.watch(postAPIProvider);
  final result = await postAPI.getUserPosts(uid);

  return result.fold((failure) {
    print('Error getting user posts: ${failure.message}');
    return <PostModel>[];
  }, (posts) => posts);
});

//provider to get posts by uid
// final postsByUidProvider = FutureProvider.family<PostModel?, String>((
//   ref,
//   uid,
// ) async {
//   final postAPI = ref.watch(postAPIProvider);
//   final result = await postAPI.getPostByUid(uid);

//   return result.fold((failure) {
//     print('Error getting post by uid: ${failure.message}');
//     return null;
//   }, (post) => post);
// });

//provider for post controller
final postControllerProvider = StateNotifierProvider<PostController, bool>((
  ref,
) {
  return PostController(
    postAPI: ref.watch(postAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    ref: ref,
  );
});

class PostController extends StateNotifier<bool> {
  final PostAPI postAPI;
  final Ref ref;
  final StorageAPI storageAPI;

  PostController({
    required this.postAPI,
    required this.ref,
    required this.storageAPI,
  }) : super(false);

  Future<void> createTextPost({
    required String title,
    required CommunityModel selectedCommunity,
    required String description,
    required BuildContext context,
  }) async {
    if (state) return;
    state = true;
    //get current user id
    final currentUser = ref.read(currentUserProvider).value!;
    PostModel postModel = PostModel(
      id: '',
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      username: currentUser.name,
      uid: currentUser.uid,
      type: 'Text',
      createdAt: DateTime.now(),
      commentCount: 0,
      upvotes: [],
      downvotes: [],
      awards: [],
      description: description,
      link: '',
    );
    final res = await postAPI.createPost(postModel);
    res.fold(
      (l) {
        state = false;

        print('Create post error: ${l.message}');
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackbar(context, 'Failed to create text post: ${l.message}');
      },
      (r) {
        ref.invalidate(userPostsProvider(currentUser.uid));

        state = false;

        // Navigate back after a short delay to avoid conflicts
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackbar(context, 'Text post created successfully!');
      },
    );
  }

  Future<void> createLinkPost({
    required String title,
    required CommunityModel selectedCommunity,
    required String link,
    required BuildContext context,
  }) async {
    if (state) return;
    state = true;
    //get current user id
    final currentUser = ref.read(currentUserProvider).value!;
    PostModel postModel = PostModel(
      id: '',
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      username: currentUser.name,
      uid: currentUser.uid,
      type: 'Link',
      createdAt: DateTime.now(),
      commentCount: 0,
      upvotes: [],
      downvotes: [],
      awards: [],
      description: '',
      link: link,
    );
    final res = await postAPI.createPost(postModel);
    res.fold(
      (l) {
        state = false;

        print('Create link post error: ${l.message}');
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackbar(context, 'Failed to create link post: ${l.message}');
      },
      (r) {
        ref.invalidate(userPostsProvider(currentUser.uid));

        state = false;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackbar(context, 'Link post created successfully!');
      },
    );
  }

  Future<void> createImagePost({
    required String title,
    required CommunityModel selectedCommunity,
    required File image,
    required BuildContext context,
  }) async {
    if (state) return;
    state = true;
    //get current user id
    final currentUser = ref.read(currentUserProvider).value!;
    final imageUrl = await storageAPI.uploadFile(file: image);
    PostModel postModel = PostModel(
      id: '',
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      username: currentUser.name,
      uid: currentUser.uid,
      type: 'Image',
      createdAt: DateTime.now(),
      commentCount: 0,
      upvotes: [],
      downvotes: [],
      awards: [],
      description: '',
      link: imageUrl,
    );
    final res = await postAPI.createPost(postModel);
    res.fold(
      (l) {
        state = false;

        print('Create image post error: ${l.message}');
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackbar(context, 'Failed to create image post: ${l.message}');
      },
      (r) {
        ref.invalidate(userPostsProvider(currentUser.uid));

        state = false;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        showSnackbar(context, 'Image post created successfully!');
      },
    );
  }

  //get post by community name
  Future<List<PostModel>> getPostsByCommunity(String communityName) async {
    final result = await postAPI.getPostByCommunity(communityName);
    return result.fold((l) {
      print('Error getting posts by community: ${l.message}');
      return <PostModel>[];
    }, (posts) => posts);
  }

  // Future<PostModel?> getPostByUid(String uid) async {
  //   final result = await postAPI.getPostByUid(uid);
  //   return result.fold((l) => null, (r) => r);
  // }
}
