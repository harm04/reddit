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
      theme: ref.watch(themeNotifierProvider),

      home: Consumer(
        builder: (context, ref, child) {
          return ref
              .watch(currentUserProvider)
              .when(
                data: (user) {
                  if (user != null) {
                    return NavigationBarView();
                  } else {
                    return const LoginScreen();
                  }
                },
                loading: () {
                  return const Scaffold(body: Loader());
                },
                error: (error, stackTrace) {
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
