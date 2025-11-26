import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/nav_bar.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/auth/screens/login_screen.dart';
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

      home: Consumer(
        builder: (context, ref, child) {
          // Watch the current user provider for real-time auth state
          return ref
              .watch(currentUserProvider)
              .when(
                data: (user) {
                  if (user != null) {
                    // User is authenticated and data is available
                    return NavigationBarView();
                  } else {
                    // User is not authenticated
                    return const LoginScreen(); // Replace with your login screen
                  }
                },
                loading: () {
                  // Show loader while checking authentication
                  return const Scaffold(body: Loader());
                },
                error: (error, stackTrace) {
                  // Show error if authentication check fails
                  return Scaffold(
                    body: ErrorText(
                      error: 'Authentication Error: ${error.toString()}',
                    ),
                  );
                },
              );
        },
      ),
    );
  }
}
