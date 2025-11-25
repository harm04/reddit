import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers.dart';
import 'package:reddit/core/type_defs.dart';

//provider for AuthAPI
final authAPIProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

abstract class IAuthAPI {
  FutureEither<User> login();
  Future<User?> currentUser();
}

class AuthAPI implements IAuthAPI {
  final Account _account;
  AuthAPI({required Account account}) : _account = account;

  //login with google
  @override
  FutureEither<User> login() async {
    try {
      //create oauth2 session
      await _account.createOAuth2Session(provider: OAuthProvider.google);
      //get user account details
      final user = await _account.get();

      //return user details
      return Right(user);
    } catch (e, stackTrace) {
      return Left(Failure(e.toString(), stackTrace.toString()));
    }
  }

  //current logged in user
  @override
  Future<User?> currentUser() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException catch (_) {
      // Unauthorized or other Appwrite-specific errors — treat as no user
      return null;
    } catch (_) {
      // Any other errors — return null so the app can show login UI
      return null;
    }
  }
}
