import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/core/utils/pick_image.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/community/screens/edit_description_screen.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/theme/pallete.dart';

class ModToolsScreen extends ConsumerStatefulWidget {
  final String communityName;
  const ModToolsScreen({super.key, required this.communityName});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ModToolsScreenState();
}

class _ModToolsScreenState extends ConsumerState<ModToolsScreen> {
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

  //update community function
  void updateCommunity(CommunityModel communityModel) {
    ref
        .read(communityControllerProvider.notifier)
        .updateCommunityImages(
          avatarFile: avatarFile,
          bannerFile: bannerFile,
          community: communityModel,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref
        .watch(communityByNameProvider(widget.communityName))
        .when(
          data: (community) {
            return isLoading
                ? Loader()
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('Mod Tools'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: OutlinedButton(
                            onPressed: () {
                              updateCommunity(community!);
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
                                color:Pallete.greyColor,
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
                                    : community!.banner.isEmpty ||
                                          community.banner ==
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
                                        community.banner,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),

                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: avatarFile != null
                                        ? FileImage(avatarFile!)
                                              as ImageProvider
                                        : NetworkImage(community!.avatar),
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
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'r/${community!.name}',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditDescriptionScreen(
                                                communityName: community.name,
                                                description:
                                                    community.description,
                                              ),
                                        ),
                                      );
                                    },
                                    child: Text('View description'),
                                  ),
                                ],
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
