import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/user_model.dart';


final profileAPIProvider = Provider((ref) {
  return ProfileAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class IProfileAPI {
  FutureEitherVoid updateProfile(UserModel userModel);
}

class ProfileAPI implements IProfileAPI {
  final TablesDB _db;

  ProfileAPI({required TablesDB db}) : _db = db;

  //update profile
  @override
  FutureEitherVoid updateProfile(UserModel userModel) async {
    try {
      await _db.updateRow(
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
}
