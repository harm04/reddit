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
  );
});

//providere for current user
final currentUserAccountProvider = FutureProvider<User?>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

//controller for authentication
class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  final UserAPI _userAPI;
  AuthController({required AuthAPI authAPI, required UserAPI userAPI})
    : _authAPI = authAPI,
      _userAPI = userAPI,
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
        // Fetch user data from database
        final user = await _userAPI.getUserData(r.$id);

        //if user exists then just login else save user data
        if (user == null) {
          print('saving new user data ${r.$id}');
          //extract user name from email
          String name = r.email.split('@')[0];

          // store data in user model
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
          print('saved user data ${r.$id}');
          res2.fold(
            (l) => print('Failed to save user data: ${l.message}'),
            (r) => print('User data saved successfully.'),
          );
        }

        // set authenticated state to false
        state = false;

        //navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return HomeScreen();
            },
          ),
        );
        showSnackbar(context, 'Login successful');
      },
    );
  }

  //current logged in user
  Future<User?> currentUser() async {
    return await _authAPI.currentUser();
  }
}
