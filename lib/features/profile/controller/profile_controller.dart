import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/common/storage/storage_api.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/profile/api/profile_api.dart';
import 'package:reddit/models/user_model.dart';

//profile controller provider
final profileControllerProvider =
    StateNotifierProvider<ProfileController, bool>((ref) {
      final storageAPI = ref.watch(storageAPIProvider);
      final profileAPI = ref.watch(profileAPIProvider);
      return ProfileController(
        storageAPI: storageAPI,
        profileAPI: profileAPI,
        ref: ref,
      );
    });

class ProfileController extends StateNotifier<bool> {
  final StorageAPI storageAPI;
  final ProfileAPI profileAPI;
  final Ref ref;

  ProfileController({
    required this.storageAPI,
    required this.profileAPI,
    required this.ref,
  }) : super(false);

  //update profile
  void updateProfileImages({
    required File? bannerFile,
    required File? avatarFile,
    required UserModel userModel,
    required BuildContext context,
  }) async {
    state = true;

    UserModel updatedUser = userModel;

    try {
      // Upload banner image if provided
      if (bannerFile != null) {
        try {
          final bannerUrl = await storageAPI.uploadFile(file: bannerFile);
          updatedUser = updatedUser.copyWith(bannerPicture: bannerUrl);
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
          updatedUser = updatedUser.copyWith(profilePicture: avatarUrl);
        } catch (e) {
          state = false;
          showSnackbar(context, 'Failed to upload avatar: $e');
          return;
        }
      }

      // Update the user profile in the database
      final updateRes = await profileAPI.updateProfile(updatedUser);

      updateRes.fold(
        (l) {
          state = false;
          showSnackbar(context, l.message);
        },
        (r) {
          state = false;

          // Invalidate providers to refresh the data
          
          ref.invalidate(userDetailsProvider);
          ref.invalidate(currentUserProvider);

          showSnackbar(context, 'Profile updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      state = false;
      showSnackbar(context, 'An error occurred while updating the profile');
      print('Update profile error: $e');
    }
  }

  //update community description
  void updateProfileName({
    required UserModel user,
    required String name,
    required BuildContext context,
  }) async {
    state = true;

    try {
      final updatedUser = user.copyWith(name: name);

      final res = await profileAPI.updateProfile(updatedUser);

      res.fold(
        (l) {
          state = false;
          showSnackbar(context, l.message);
        },
        (r) {
          state = false;

        
          ref.invalidate(userDetailsProvider);
          ref.invalidate(currentUserProvider);

          showSnackbar(context, 'Name updated successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      state = false;
      showSnackbar(context, 'An error occurred while updating name');
      print('Update name error: $e');
    }
  }
}
