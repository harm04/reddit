import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils/show_sncakbar.dart';
import 'package:reddit/features/auth/api/auth_api.dart';
import 'package:reddit/features/auth/api/user_api.dart';
import 'package:reddit/models/user_model.dart';

// Add this trigger provider to refresh auth state
final authStateProvider = StateProvider<int>((ref) => 0);

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
final currentUserAccountProvider = FutureProvider<User?>((ref) async {
  // Watch the auth state to refresh when login happens
  ref.watch(authStateProvider);
  final authController = ref.watch(authControllerProvider.notifier);
  final user = await authController.currentUser();
  print('Current user account: ${user?.$id}');
  return user;
});

//provider for user details
final userDetailsProvider = FutureProvider.family<UserModel?, String>((
  ref,
  String uid,
) async {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

//provider for current user details
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  try {
    // Watch the auth state to refresh when login happens
    ref.watch(authStateProvider);
    // Get the current user account
    final currentUserAccount = await ref.watch(
      currentUserAccountProvider.future,
    );

    if (currentUserAccount == null) {
      print('No current user account found');
      return null;
    }

    print('Found user account: ${currentUserAccount.$id}');

    // Get the user details using the user ID
    final userDetails = await ref.watch(
      userDetailsProvider(currentUserAccount.$id).future,
    );
    print('Current user details: $userDetails');
    return userDetails;
  } catch (e) {
    print('Error in currentUserProvider: $e');
    return null;
  }
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



  void login(BuildContext context) async {
    // set authenticated state to true
    state = true;

    //login
    final res = await _authAPI.login();

    res.fold(
      (l) {
        state = false;
        showSnackbar(context, 'Login failed');
      },
      (r) async {
        try {
          //check if userid exists in database
          final existing = await _userAPI.getUserData(r.$id);
          UserModel? userModel = existing.data.isNotEmpty
              ? UserModel.fromMap(existing.data)
              : null;
          print(userModel.toString());

          if (userModel == null) {
            //user does not exist, create new user data
            await _createNewUser(context, r);
          } else {
            //user exists, proceed to home screen

            state = false;
            print('User exists, proceed to home screen');
            // Refresh auth state for new users
            _refreshAuthState();
            if (context.mounted) {
              showSnackbar(context, 'Welcome back ${userModel.name}!');
            }
          }
        } catch (e) {
          // User doesn't exist in database - this is where the exception is caught
          print('User not found in database, creating new user: $e');
          await _createNewUser(context, r);
        }
      },
    );
  }

  Future<void> _createNewUser(BuildContext context, User r) async {
    //user does not exist, create new user data
    String name = r.email.split('@')[0];
    //retrive profile picture from email
    
    final userModel = UserModel(
      name: name,
      email: r.email,
      profilePicture: Constants.avatarDefault,
      bannerPicture: Constants.bannerDefault,
      uid: r.$id,
      isAuthenticated: true,
      karma: 0,
      awards: [],
    );

    final res2 = await _userAPI.saveUserData(userModel);
    res2.fold(
      (l) {
        state = false;
        print('Error saving user: ${l.message}');
        if (context.mounted) {
          showSnackbar(context, 'Error creating account');
        }
      },
      (r2) {
        state = false;
        print('User data saved successfully');

        // Refresh auth state for new users
        _refreshAuthState();
        if (context.mounted) {
          showSnackbar(context, 'Account created successfully');
        }
      },
    );
  }

  void _refreshAuthState() {
    final currentState = _ref.read(authStateProvider);
    _ref.read(authStateProvider.notifier).state = currentState + 1;
  }

  //current logged in user
  Future<User?> currentUser() async {
    return await _authAPI.currentUser();
  }

  //get user data from database
  Future<UserModel?> getUserData(String uid) async {
    try {
      final row = await _userAPI.getUserData(uid);
      if (row != null && row.data.isNotEmpty) {
        final updatedUser = UserModel.fromMap(row.data);
        print('Successfully got user data for uid: $uid');
        return updatedUser;
      }
      print('No user data found for uid: $uid');
      return null;
    } catch (e) {
      print('Error getting user data for uid $uid: $e');
      return null;
    }
  }
}
