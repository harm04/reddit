import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';
import 'package:reddit/core/providers.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class StorageAPI {
  final Storage _storage;
  StorageAPI({required Storage storage}) : _storage = storage;

  Future<String> uploadFile({File? file}) async {
    final res = await _storage.createFile(
      bucketId: AppwriteConstants.imagesBucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: file!.path),
    );
    final imageUrl = await AppwriteConstants.imageUrl(res.$id);
    print('Uploaded image URL: $imageUrl');
    return imageUrl;
  }
}
