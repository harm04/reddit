import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/common/storage/storage_api.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/api/community_api.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/user_model.dart';

//provider to get user communities
final userCommunitiesProvider =
    FutureProvider.family<List<CommunityModel>, String>((ref, uid) async {
      final communityAPI = ref.watch(communityAPIProvider);
      final result = await communityAPI.getUserCommunities(uid);

      return result.fold((failure) {
        print('Error getting user communities: ${failure.message}');
        return <CommunityModel>[];
      }, (communities) => communities);
    });

//provider to get community by name
final communityByNameProvider = FutureProvider.family<CommunityModel?, String>((
  ref,
  name,
) async {
  final communityAPI = ref.watch(communityAPIProvider);
  final result = await communityAPI.getCommunityByName(name);

  return result.fold((failure) {
    print('Error getting community by name: ${failure.message}');
    return null;
  }, (community) => community);
});

//provider to search communities
final searchCommunitiesProvider =
    FutureProvider.family<List<CommunityModel>, String>((ref, query) async {
      if (query.trim().isEmpty) {
        return [];
      }

      final communityAPI = ref.watch(communityAPIProvider);

      try {
        final docs = await communityAPI.searchCommunity(query);
        return docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data);
          data['\$id'] = doc.$id; // Add document ID
          return CommunityModel.fromMap(data);
        }).toList();
      } catch (error) {
        print('Error in searchCommunitiesProvider: $error');
        return [];
      }
    });

//community members provider
final communityMembersProvider = FutureProvider.family<List<UserModel>, String>(
  (ref, communityName) async {
    final communityAPI = ref.watch(communityAPIProvider);
    final result = await communityAPI.getCommunityMembers(communityName);

    return result.fold((failure) {
      print('Error getting community members: ${failure.message}');
      return <UserModel>[];
    }, (members) => members);
  },
);

//provider for community controller
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
      return CommunityController(
        communityAPI: ref.watch(communityAPIProvider),
        storageAPI: ref.watch(storageAPIProvider),
        ref: ref,
      );
    });

class CommunityController extends StateNotifier<bool> {
  final CommunityAPI communityAPI;
  final Ref ref;
  final StorageAPI storageAPI;

  CommunityController({
    required this.communityAPI,
    required this.ref,
    required this.storageAPI,
  }) : super(false);

  Future<void> createCommunity(
    String name,
    String description,
    BuildContext context,
  ) async {
    state = true;
    //get current user id
    final uid = ref.read(currentUserProvider).value!.uid;
    CommunityModel communityModel = CommunityModel(
      name: name,
      description: description,
      avatar: Constants.avatarDefault,
      banner: Constants.bannerDefault,
      id: '',
      members: [uid],
      mods: [uid],
    );

    final res = await communityAPI.createCommunity(communityModel);
    res.fold(
      (l) {
        state = false;
        showSnackbar(context, l.message);
        print(l.message);
      },
      (r) {
        ref.invalidate(userCommunitiesProvider);
        ref.invalidate(communityByNameProvider);

        state = false;
        showSnackbar(context, 'Community created successfully!');

        Navigator.pop(context);
      },
    );
  }

  Future<CommunityModel?> getCommunityByName(String name) async {
    final result = await communityAPI.getCommunityByName(name);
    return result.fold((l) => null, (r) => r);
  }

  //update community
  void updateCommunityImages({
    required File? bannerFile,
    required File? avatarFile,
    required CommunityModel community,
    required BuildContext context,
  }) async {
    state = true;

    CommunityModel updatedCommunity = community;

    try {
      // Upload banner image if provided
      if (bannerFile != null) {
        try {
          final bannerUrl = await storageAPI.uploadFile(file: bannerFile);
          updatedCommunity = updatedCommunity.copyWith(banner: bannerUrl);
        } catch (e) {
          state = false;
          showSnackbar(context, 'Failed to upload banner: $e');
          return;
        }
      }

      // Upload avatar image if provided
      if (avatarFile != null) {
        try {
          final avatarUrl = await storageAPI.uploadFile(file: avatarFile);
          updatedCommunity = updatedCommunity.copyWith(avatar: avatarUrl);
        } catch (e) {
          state = false;
          showSnackbar(context, 'Failed to upload avatar: $e');
          return;
        }
      }

      // Update the community in the database
      final updateRes = await communityAPI.updateCommunity(updatedCommunity);

      updateRes.fold(
        (l) {
          state = false;
          showSnackbar(context, l.message);
        },
        (r) {
          state = false;

          // Invalidate providers to refresh the data
          ref.invalidate(communityByNameProvider);
          ref.invalidate(userCommunitiesProvider);

          showSnackbar(context, 'Community updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      state = false;
      showSnackbar(context, 'An error occurred while updating the community');
      print('Update community error: $e');
    }
  }

  //update community description
  void updateCommunityDescription({
    required CommunityModel community,
    required String description,
    required BuildContext context,
  }) async {
    state = true;

    try {
      final updatedCommunity = community.copyWith(description: description);

      final res = await communityAPI.updateCommunity(updatedCommunity);

      res.fold(
        (l) {
          state = false;
          showSnackbar(context, l.message);
        },
        (r) {
          state = false;

          // Invalidate providers to refresh the data
          ref.invalidate(communityByNameProvider);
          ref.invalidate(userCommunitiesProvider);

          showSnackbar(context, 'Description updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      state = false;
      showSnackbar(context, 'An error occurred while updating description');
      print('Update description error: $e');
    }
  }

  //join community
  void joinCommunity(CommunityModel community, String uid) async {
    List<String> members = community.members;

    if (!members.contains(uid)) {
      members.add(uid);
    } else {
      members.remove(uid);
    }

    CommunityModel updatedCommunity = community.copyWith(members: members);

    final res = await communityAPI.updateCommunity(updatedCommunity);

    res.fold((l) => null, (r) {
      // Invalidate providers to refresh the data
      ref.invalidate(communityByNameProvider);
      ref.invalidate(userCommunitiesProvider);
    });
  }
}
