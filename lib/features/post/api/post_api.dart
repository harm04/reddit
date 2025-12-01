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
  FutureEitherVoid deletePost(String postId);
  FutureEither<List<PostModel>> getPostByCommunity(String communityName);
  FutureEither<PostModel?> getPostById(String postId);
  FutureEither<List<PostModel>> getAllPosts();
 FutureEitherVoid downvotePost(
    String postId,
    List<String> upvotes,
    List<String> downvotes,
  );
  FutureEitherVoid upvotePost(
    String postId,
    List<String> upvotes,
    List<String> downvotes,
  );
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
  FutureEither<List<PostModel>> getPostByCommunity(String communityName) async {
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

  //get all post
  FutureEither<List<PostModel>> getAllPosts() async {
    try {
      final result = await _db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
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

  // ADDED: Upvote post method
  @override
  FutureEitherVoid upvotePost(
    String postId,
    List<String> upvotes,
    List<String> downvotes,
  ) async {
    try {
      await _db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        rowId: postId,
        data: {'upvotes': upvotes, 'downvotes': downvotes},
      );
      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  // ADDED: Downvote post method
  @override
  FutureEitherVoid downvotePost(
    String postId,
    List<String> upvotes,
    List<String> downvotes,
  ) async {
    try {
      await _db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        rowId: postId,
        data: {'upvotes': upvotes, 'downvotes': downvotes},
      );
      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  //delete post
  FutureEitherVoid deletePost(String postId) async {
    try {
      await _db.deleteRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        rowId: postId,
      );
      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  //get post by post id
  @override
  FutureEither<PostModel?> getPostById(String postId) async {
    try {
      final row = await _db.getRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.postTableId,
        rowId: postId,
      );

      final data = Map<String, dynamic>.from(row.data);
      data['\$id'] = row.$id; // Add the row ID to the data
      final post = PostModel.fromMap(data);

      return right(post);
    } catch (error, stackTrace) {
      return left(Failure(error.toString(), stackTrace.toString()));
    }
  }


}
