import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/theme/pallete.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to rebuild when text changes
    _communityNameController.addListener(() {
      setState(() {});
    });
    _descriptionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _communityNameController.dispose();
    _descriptionController.dispose();
  }

  bool get _isFormValid {
    return _communityNameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
  }

  void createCommunity() {
    if (!_isFormValid) return;
    ref
        .read(communityControllerProvider.notifier)
        .createCommunity(
          _communityNameController.text.trim(),
          _descriptionController.text.trim(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return isLoading
        ? Loader()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Create a Community'),
              actions: [
                ElevatedButton(
                  onPressed: _isFormValid ? createCommunity : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid
                        ? Pallete.blueColor
                        : Pallete.greyColor,
                    foregroundColor: Pallete.whiteColor,
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),

            body: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Tell us about your community',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'A name and description help people understand what your community is all about.',
                      style: TextStyle(
                        color: Pallete.greyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _communityNameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Community name*',
                      filled: true,
                      fillColor: Pallete.greyColor,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 21,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Description*',
                      filled: true,
                      fillColor: Pallete.greyColor,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 500,
                  ),
                ],
              ),
            ),
          );
  }
}
