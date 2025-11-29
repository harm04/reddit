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
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/theme/pallete.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String postType;
  const CreatePostScreen({super.key, required this.postType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  File? image;
  CommunityModel? selectedCommunity; // Initialize as null
  List<CommunityModel> communities = [];

  @override
  void initState() {
    super.initState();
    // Add listeners to update the UI when text changes
    titleController.addListener(_updateFormState);
    descriptionController.addListener(_updateFormState);
    linkController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
      // This will trigger a rebuild and update the button color
    });
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    titleController.removeListener(_updateFormState);
    descriptionController.removeListener(_updateFormState);
    linkController.removeListener(_updateFormState);

    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    // Must have selected community and title
    if (selectedCommunity == null || titleController.text.trim().isEmpty) {
      return false;
    }

    if (widget.postType == 'Text') {
      return descriptionController.text.trim().isNotEmpty;
    } else if (widget.postType == 'Link') {
      return linkController.text.trim().isNotEmpty;
    } else if (widget.postType == 'Image') {
      return image != null;
    }
    return false;
  }

  void selectImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        image = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (!_isFormValid || selectedCommunity == null) {
      showSnackbar(context, 'Please complete all required fields');
      return;
    }
    final isLoading = ref.read(postControllerProvider);
    if (isLoading) return;
    if (widget.postType == 'Text') {
      ref
          .read(postControllerProvider.notifier)
          .createTextPost(
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            description: descriptionController.text.trim(),
            context: context,
          );
    } else if (widget.postType == 'Link') {
      ref
          .read(postControllerProvider.notifier)
          .createLinkPost(
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            link: linkController.text.trim(),
            context: context,
          );
    } else if (widget.postType == 'Image') {
      ref
          .read(postControllerProvider.notifier)
          .createImagePost(
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity!,
            image: image!,
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(postControllerProvider);
    final imagePost = widget.postType == 'Image';
    final textPost = widget.postType == 'Text';
    final linkPost = widget.postType == 'Link';

    return isLoading
        ? Loader()
        : Scaffold(
            appBar: AppBar(
              title: Text('Create ${widget.postType} Post'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _isFormValid && !isLoading ? sharePost : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid
                          ? Pallete.blueColor
                          : Pallete.greyColor,
                      foregroundColor: Pallete.whiteColor,
                    ),
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Community Selection - MOVED TO TOP
                        const Text(
                          'Select Community *',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ref
                            .watch(
                              userCommunitiesProvider(
                                ref.read(currentUserProvider).value!.uid,
                              ),
                            )
                            .when(
                              data: (data) {
                                communities = data;

                                if (data.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      'You need to join a community first to create a post.',
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  );
                                }

                                return DropdownButtonFormField<CommunityModel>(
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Pallete.greyColor,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  hint: const Text('Choose a community'),
                                  value:
                                      selectedCommunity, // This will be null initially
                                  items: data
                                      .map(
                                        (e) => DropdownMenuItem<CommunityModel>(
                                          value: e,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  e.avatar,
                                                ),
                                                radius: 12,
                                              ),
                                              const SizedBox(width: 10),
                                              Text('r/${e.name}'),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedCommunity = val;
                                    });
                                  },
                                );
                              },
                              error: (error, stackTrace) =>
                                  ErrorText(error: error.toString()),
                              loading: () => const Loader(),
                            ),

                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'Title *',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter a title here',
                            filled: true,
                            fillColor: Pallete.greyColor,
                            contentPadding: EdgeInsets.all(18),
                          ),
                          maxLength: 30,
                        ),
                        const SizedBox(height: 10),

                        // Image Post
                        if (imagePost)
                          GestureDetector(
                            onTap: selectImage,
                            child: DottedBorder(
                              options: RectDottedBorderOptions(
                                color: Pallete.greyColor,
                                strokeCap: StrokeCap.round,
                                dashPattern: const [10, 4],
                              ), // FIXED: Use borderType

                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          image!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              Constants.cameraPath,
                                              height: 40,
                                              colorFilter:
                                                  const ColorFilter.mode(
                                                    Pallete.whiteColor,
                                                    BlendMode.srcIn,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Tap to select image',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),

                        // Text Post
                        if (textPost) ...[
                          const Text(
                            'Description *',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter a description here',
                              filled: true,
                              fillColor: Pallete.greyColor,
                              contentPadding: EdgeInsets.all(18),
                            ),
                            maxLines: 5,
                            maxLength: 300,
                          ),
                        ],

                        // Link Post
                        if (linkPost) ...[
                          const Text(
                            'Link *',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: linkController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  'Enter a link here (https://example.com)',
                              filled: true,
                              fillColor: Pallete.greyColor,
                              contentPadding: EdgeInsets.all(18),
                              prefixIcon: Icon(Icons.link, color: Colors.grey),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          );
  }
}
