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
      home: ref
          .watch(currentUserAccountProvider)
          .when(
            data: (currentUser) {
              // `currentUser` is nullable: show HomeScreen when signed in,
              // otherwise show LoginScreen.
              if (currentUser != null) {
                return HomeScreen();
              }
              return LoginScreen();
            },
            error: (error, st) {
              // For non-auth related errors, show an ErrorPage.
              return ErrorPage(error: error.toString());
            },
            loading: () => Loader(),
          ),
    );
  }
}
