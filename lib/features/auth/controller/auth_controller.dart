import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/api/auth_api.dart';
import 'package:reddit/features/home/screens/home_screen.dart';

//provider for AuthController
final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController(authAPI: ref.watch(authAPIProvider));
});

//providere for current user
final currentUserAccountProvider = FutureProvider<User?>((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

//controller for authentication
class AuthController extends StateNotifier<bool> {
  final AuthAPI _authAPI;
  AuthController({required AuthAPI authAPI}) : _authAPI = authAPI, super(false);

  void login({required BuildContext context}) async {
    // set authenticated state to true
    state = true;
    //login
    final res = await _authAPI.login();
    // set authenticated state to false
    state = false;
    //error handling or navigate to home screen if success
    res.fold((l) => showSnackbar(context, l.message), (r) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen();
          },
        ),
      );
      showSnackbar(context, 'Login successful');
    });
  }

  //current logged in user
  Future<User?> currentUser() async {
    return await _authAPI.currentUser();
  }
}
