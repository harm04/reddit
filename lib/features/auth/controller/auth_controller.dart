import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/api/auth_api.dart';
import 'package:reddit/features/auth/api/user_api.dart';
import 'package:reddit/features/home/screens/home_screen.dart';
import 'package:reddit/models/user_model.dart';

//provider for AuthController
final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(
    authAPI: ref.watch(authAPIProvider),
    userAPI: ref.watch(userAPIProvider),
    ref: ref,
  );
});

//providere for current user
final currentUserAccountProvider = FutureProvider((ref) async {
  final authController = ref.watch(authControllerProvider.notifier);
  final user = await authController.currentUser();
  if (user != null) {
    return user;
  }
  return null;
});

//provider for user details
final userDetailsProvider = FutureProvider.family((ref, String uid) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

//provider for current user details
final currentUserProvider = FutureProvider((ref) async {
  final currentUser = await ref.watch(currentUserAccountProvider).value?.$id;

  if (currentUser == null) return null;

  final user = await ref.watch(userDetailsProvider(currentUser).future);
  return user;
});

//controller for authentication
class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;
  final Ref _ref;
  AuthController({
    required AuthAPI authAPI,
    required UserAPI userAPI,
    required Ref ref,
  }) : _authAPI = authAPI,
       _userAPI = userAPI,
       _ref = ref,
       super(false);

  void login({required BuildContext context}) async {
    // set authenticated state to true
    state = true;

    //login
    final res = await _authAPI.login();
    res.fold(
      (l) {
        // set authenticated state to false
        state = false;
        showSnackbar(context, l.message);
      },
      (r) async {
        final existing = await _userAPI.getUserData(r.$id);
        if (existing != null) {
          state = false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return HomeScreen();
              },
            ),
          );
          final existingUserData = UserModel.fromMap(existing.data);
          showSnackbar(context, 'Welcome back ${existingUserData.name}!');
        }
        String name = r.email.split('@')[0];
        UserModel userModel = UserModel(
          name: name,
          email: r.email,
          profilePicture: Constants.avatarDefault,
          bannerPicture: Constants.bannerDefault,
          uid: r.$id,
          isAuthenticated: true,
          karma: 0,
          awards: [],
        );
        //save user data to database
        final res2 = await _userAPI.saveUserData(userModel);
        res2.fold(
          (l) {
            state = false;
            showSnackbar(context, l.message);
          },
          (r2) async {
            await _userAPI.getUserData(r.$id);

            state = false;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );

            showSnackbar(context, "Account created successfully!");
          },
        );
      },
    );
  }

  //current logged in user
  Future<User?> currentUser() async {
    return await _authAPI.currentUser();
  }

  //get user data from database
  Future<UserModel> getUserData(String uid) async {
    final row = await _userAPI.getUserData(uid);
    final updatedUser = UserModel.fromMap(row.data);
    return updatedUser;
  }
}
