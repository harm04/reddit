import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/models/community_model.dart';

class EditDescriptionScreen extends ConsumerStatefulWidget {
  final String communityName;
  final String description;
  const EditDescriptionScreen({
    super.key,
    required this.communityName,
    required this.description,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditDescriptionScreenState();
}

class _EditDescriptionScreenState extends ConsumerState<EditDescriptionScreen> {
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.description);

  //update description function
  void updateDescription(String description, CommunityModel communityModel) {
    ref
        .read(communityControllerProvider.notifier)
        .updateCommunityDescription(
          description: description,
          community: communityModel,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isloading = ref.watch(communityControllerProvider);
    return ref
        .watch(communityByNameProvider(widget.communityName))
        .when(
          data: (community) {
            return isloading
                ? Loader()
                : Scaffold(
                    appBar: AppBar(
                      title: const Text('Edit Description'),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: OutlinedButton(
                            onPressed: () {
                              if (community!.description !=
                                  _descriptionController.text) {
                                updateDescription(
                                  _descriptionController.text,
                                  community,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white),
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
                          TextField(
                            maxLines: null,
                            controller: _descriptionController,
                            maxLength: 500,
                            decoration: InputDecoration(
                              hintText: 'Enter community description',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
