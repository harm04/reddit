import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/auth/screens/login_screen.dart';
import 'package:reddit/features/home/screens/home_screen.dart';
import 'package:reddit/theme/pallete.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit',
      debugShowCheckedModeBanner: false,
      theme: Pallete.darkModeAppTheme,

      // home: ref
      //     .watch(currentUserAccountProvider)
      //     .when(
      //       data: (currentUser) {
      //         // `currentUser` is nullable: show HomeScreen when signed in,
      //         // otherwise show LoginScreen.
      //         if (currentUser != null) {
      //           return HomeScreen();
      //         }
      //         return LoginScreen();
      //       },
      //       error: (error, st) {
      //         // For non-auth related errors, show an ErrorPage.
      //         return ErrorPage(error: error.toString());
      //       },
      //       loading: () => Loader(),
      //     ),
      // home: ref
      //     .watch(currentUserAccountProvider)
      //     .when(
      //       data: (user) {
      //         if (user != null) {
      //           final currentUser = ref.watch(currentUserProvider);
      //           return currentUser.when(
      //             data: (data) {
      //               if (data != null) {
      //                 return HomeScreen();
      //               }
      //               return LoginScreen();
      //             },
      //             error: (err, st) {
      //               return ErrorText(error: err.toString());
      //             },
      //             loading: () => Loader(),
      //           );
      //         }
      //         return LoginScreen();
      //       },
      //       error: (err, st) {
      //         return ErrorText(error: err.toString());
      //       },
      //       loading: () => Loader(),
      //     ),

       home: Consumer(
        builder: (context, ref, child) {
          // Watch the current user provider for real-time auth state
          return ref.watch(currentUserProvider).when(
            data: (user) {
              if (user != null) {
                // User is authenticated and data is available
                return const HomeScreen();
              } else {
                // User is not authenticated
                return const LoginScreen(); // Replace with your login screen
              }
            },
            loading: () {
              // Show loader while checking authentication
              return const Scaffold(
                body: Loader(),
              );
            },
            error: (error, stackTrace) {
              // Show error if authentication check fails
              return Scaffold(
                body: ErrorText(error: 'Authentication Error: ${error.toString()}'),
              );
            },
          );
        },
      ),
    );
  }
}
