import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/post_model.dart';

final postAPIProvider = Provider((ref) {
  return PostAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IPostAPI {
  FutureEitherVoid createPost(PostModel postModel);
  FutureEither<List<PostModel>> getUserPosts(String uid);
  // FutureEither<List<PostModel>?> getPostByUid(String uid);
  FutureEither<List<PostModel>> getPostByCommunity(String communityName);
}

class PostAPI implements IPostAPI {
  final TablesDB _db;
  PostAPI({required TablesDB db}) : _db = db;

  @override
  FutureEitherVoid createPost(PostModel postModel) async {
    try {
      // Create new Post
      await _db.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        rowId: ID.unique(),
        data: postModel.toMap(),
      );

      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  @override
  FutureEither<List<PostModel>> getUserPosts(String uid) async {
    try {
      final result = await _db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        queries: [Query.search('uid', uid)],
      );

      final posts = result.rows.map((row) {
        final data = Map<String, dynamic>.from(row.data);
        data['\$id'] = row.$id; // Add the row ID to the data
        return PostModel.fromMap(data);
      }).toList();

      return right(posts);
    } catch (error, stackTrace) {
      return left(Failure(error.toString(), stackTrace.toString()));
    }
  }
  
  @override
  FutureEither<List<PostModel>> getPostByCommunity(String communityName) async{
    try {
      final result = await _db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        queries: [Query.search('communityName', communityName)],
      );

      final posts = result.rows.map((row) {
        final data = Map<String, dynamic>.from(row.data);
        data['\$id'] = row.$id; // Add the row ID to the data
        return PostModel.fromMap(data);
      }).toList();

      return right(posts);
    } catch (error, stackTrace) {
      return left(Failure(error.toString(), stackTrace.toString()));
    }
  }

  // //get communities by name
  // @override
  // FutureEither<List<PostModel>?> getPostByUid(String uid) async {
  //   try {
  //     final result = await _db.listRows(
  //       databaseId: AppwriteConstants.databaseId,
  //       tableId: AppwriteConstants.postTableId,
  //       queries: [Query.equal('uid', uid)],
  //     );

  //     if (result.rows.isEmpty) {
  //       return right(null);
  //     }
  //     final row = result.rows.first;
  //     final data = Map<String, dynamic>.from(row.data);
  //     data['\$id'] = row.$id;
  //     final post = PostModel.fromMap(data);

  //     return right(post);
  //   } catch (error, stackTrace) {
  //     return left(Failure(error.toString(), stackTrace.toString()));
  //   }
  // }

  // //update community details
  // @override
  // FutureEitherVoid updateCommunity(CommunityModel communityModel) async {
  //   try {
  //     await _db.updateRow(
  //       databaseId: AppwriteConstants.databaseId,
  //       tableId: AppwriteConstants.communityTableId,
  //       rowId: communityModel.id,
  //       data: communityModel.toMap(),
  //     );
  //     return right(null);
  //   } catch (error, st) {
  //     return left(Failure(error.toString(), st.toString()));
  //   }
  // }

  // @override
  // Future<List<Row>> searchCommunity(String name) async {
  //   try {
  //     // Handle empty query
  //     if (name.trim().isEmpty) {
  //       return [];
  //     }

  //     // If search by name attribute fails (no fulltext index), get all and filter
  //     try {
  //       final result = await _db.listRows(
  //         databaseId: AppwriteConstants.databaseId,
  //         tableId: AppwriteConstants.communityTableId,
  //         queries: [Query.search('name', name)],
  //       );
  //       return result.rows;
  //     } catch (e) {
  //       print('Search failed, trying alternative approach: $e');

  //       // Fallback: Get all communities and filter manually
  //       final allResult = await _db.listRows(
  //         databaseId: AppwriteConstants.databaseId,
  //         tableId: AppwriteConstants.communityTableId,
  //         queries: [Query.limit(100)],
  //       );

  //       // Filter manually
  //       final filteredRows = allResult.rows.where((row) {
  //         final communityName =
  //             row.data['name']?.toString().toLowerCase() ?? '';
  //         return communityName.contains(name.toLowerCase());
  //       }).toList();

  //       return filteredRows;
  //     }
  //   } catch (error) {
  //     print('Search error: $error');
  //     return [];
  //   }
  // }
}
