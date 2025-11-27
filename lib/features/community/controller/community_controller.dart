import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/api/community_api.dart';
import 'package:reddit/models/community_model.dart';

final userCommunitiesProvider =
    FutureProvider.family<List<CommunityModel>, String>((ref, uid) async {
      final communityAPI = ref.watch(communityAPIProvider);
      final result = await communityAPI.getUserCommunities(uid);

      return result.fold((failure) {
        print('Error getting user communities: ${failure.message}');
        return <CommunityModel>[];
      }, (communities) => communities);
    });

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
      return CommunityController(
        communityAPI: ref.watch(communityAPIProvider),
        ref: ref,
      );
    });

class CommunityController extends StateNotifier<bool> {
  final CommunityAPI communityAPI;
  final Ref ref;

  CommunityController({required this.communityAPI, required this.ref})
    : super(false);

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
        state = false;
        showSnackbar(context, 'Community created successfully!');

        Navigator.pop(context);
      },
    );
  }
}
