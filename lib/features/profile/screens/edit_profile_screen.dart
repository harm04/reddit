import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/core/utils/pick_image.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/profile/controller/profile_controller.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String name;
  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? avatarFile;
  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectAvatarImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatarFile = File(res.files.first.path!);
      });
    }
  }

  void updateProfile(UserModel userModel) {
    bool hasImageChanges = bannerFile != null || avatarFile != null;
    bool hasNameChange = _nameController.text.trim() != widget.name;

    if (!hasImageChanges && !hasNameChange) {
      // No changes made
      showSnackbar(context, 'No changes to save');
      return;
    }

    if (hasImageChanges && hasNameChange) {
      // Both images and name changed
      final updatedUser = userModel.copyWith(name: _nameController.text.trim());
      ref
          .read(profileControllerProvider.notifier)
          .updateProfileImages(
            avatarFile: avatarFile,
            bannerFile: bannerFile,
            userModel: updatedUser, // Pass updated user with new name
            context: context,
          );
    } else if (hasImageChanges) {
      // Only images changed
      ref
          .read(profileControllerProvider.notifier)
          .updateProfileImages(
            avatarFile: avatarFile,
            bannerFile: bannerFile,
            userModel: userModel,
            context: context,
          );
    } else if (hasNameChange) {
      // Only name changed
      ref
          .read(profileControllerProvider.notifier)
          .updateProfileName(
            name: _nameController.text.trim(),
            context: context,
            user: userModel,
          );
    }
  }

  late final TextEditingController _nameController = TextEditingController(
    text: widget.name,
  );

  //update description function
  void updateUsername(String name, UserModel userModel) {
    ref
        .read(profileControllerProvider.notifier)
        .updateProfileName(name: name, context: context, user: userModel);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileControllerProvider);
    return ref
        .watch(userDetailsProvider(widget.userId))
        .when(
          data: (user) {
            return isLoading
                ? Loader()
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('Edit Profile'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: OutlinedButton(
                            onPressed: () {
                              updateProfile(user!);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Pallete.whiteColor,
                              side: BorderSide(color: Pallete.whiteColor),
                            ),
                            child: Text('Save'),
                          ),
                        ),
                      ],
                    ),
                    body: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              selectBannerImage();
                            },
                            child: DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                radius: const Radius.circular(10),
                                color: Pallete.greyColor,
                                strokeCap: StrokeCap.round,
                                dashPattern: const [10, 4],
                              ),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: bannerFile != null
                                    ? Image.file(bannerFile!, fit: BoxFit.cover)
                                    : user!.bannerPicture.isEmpty ||
                                          user.bannerPicture ==
                                              Constants.bannerDefault
                                    ? Center(
                                        child: SvgPicture.asset(
                                          Constants.cameraPath,
                                          height: 40,
                                          colorFilter: ColorFilter.mode(
                                            Pallete.whiteColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      )
                                    : Image.network(
                                        user.bannerPicture,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),

                          Row(
                            children: [
                              // Profile Picture Section
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Pallete.greyColor,
                                    backgroundImage: avatarFile != null
                                        ? FileImage(avatarFile!)
                                              as ImageProvider
                                        : user!.profilePicture.isNotEmpty
                                        ? NetworkImage(user.profilePicture)
                                        : null,
                                    child:
                                        avatarFile == null &&
                                            user!.profilePicture.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Pallete.greyColor,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Pallete.greyColor,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 15,
                                          color: Pallete.whiteColor,
                                        ),
                                        onPressed: () {
                                          selectAvatarImage();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 15),

                              // TextField Section - WRAPPED IN EXPANDED
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Pallete
                                        .darkModeAppTheme
                                        .inputDecorationTheme
                                        .fillColor,
                                    hintText: 'Name',
                                    hintStyle: TextStyle(
                                      color: Pallete.greyColor,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:  BorderSide(
                                        color: Pallete.blueColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Pallete.greyColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
          },
          error: (error, st) => ErrorText(error: error.toString()),
          loading: () => Loader(),
        );
  }
}
