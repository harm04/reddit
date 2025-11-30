import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/user_model.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IUserAPI {
  FutureEitherVoid saveUserData(UserModel userModel);
  Future<Row> getUserData(String uid);
  FutureEither<List<UserModel>> searchUsersTyped(String name);
}

class UserAPI implements IUserAPI {
  final TablesDB _db;
  UserAPI({required TablesDB db}) : _db = db;
  @override
  FutureEitherVoid saveUserData(UserModel userModel) async {
    try {
      //save user data to the database row
      await _db.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.userTableId,
        rowId: userModel.uid,
        data: userModel.toMap(),
      );
      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  // function to get user data from the database row
  @override
  Future<Row> getUserData(String uid) async {
    return _db.getRow(
      databaseId: AppwriteConstants.databaseId,
      tableId: AppwriteConstants.userTableId,
      rowId: uid,
    );
  }

  @override
  FutureEither<List<UserModel>> searchUsersTyped(String name) async {
    try {
      // Handle empty query
      if (name.trim().isEmpty) {
        return right([]);
      }

      print('🔍 Searching for users with name: "$name"');

      // Try search with fulltext index first
      try {
        final result = await _db.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.userTableId,
          queries: [Query.search('name', name), Query.limit(20)],
        );

        final users = result.rows.map((row) {
          final data = Map<String, dynamic>.from(row.data);
          data['\$id'] = row.$id;
          return UserModel.fromMap(data);
        }).toList();

        print('✅ Search by index found ${users.length} users');
        return right(users);
      } catch (e) {
        print('⚠️ Fulltext search failed, using fallback: $e');

        // Fallback: Get all users and filter manually
        final allResult = await _db.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.userTableId,
          queries: [Query.limit(100)],
        );

        final filteredUsers = allResult.rows
            .where((row) {
              final userName = row.data['name']?.toString().toLowerCase() ?? '';
              return userName.contains(name.toLowerCase());
            })
            .map((row) {
              final data = Map<String, dynamic>.from(row.data);
              data['\$id'] = row.$id;
              return UserModel.fromMap(data);
            })
            .toList();

        print('✅ Manual filter found ${filteredUsers.length} users');
        return right(filteredUsers);
      }
    } catch (error, st) {
      print('❌ Search error: $error');
      return left(Failure(error.toString(), st.toString()));
    }
  }
}
