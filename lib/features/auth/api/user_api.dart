import 'package:appwrite/appwrite.dart';
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
  Future<UserModel?> getUserData(String uid);
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

  //function to get user data from the database row
  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final row = await _db.getRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.userTableId,
        rowId: uid,
      );
      return UserModel.fromMap(row.data);
    } catch (_) {
      return null;
    }
  }
}
