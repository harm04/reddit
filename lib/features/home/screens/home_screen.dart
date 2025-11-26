import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils/error.dart';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(currentUserProvider)
        .when(
          data: (currentUser) {
            if (currentUser == null) {
              return const ErrorPage(error: 'User not found');
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Center(child: Text('Welcome, ${currentUser.name}!')),
            );
          },
          error: (err, st) => ErrorText(error: err.toString()),
          loading: () => Loader(),
        );
  }
}
