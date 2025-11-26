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
              return const Scaffold(
                body: Center(
                  child: Text('User not found. Please try logging in again.'),
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Home'),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Add logout functionality here if needed
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(currentUser.profilePicture),
                      radius: 50,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome, ${currentUser.name}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${currentUser.email}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Karma: ${currentUser.karma}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (err, st) {
            print('Error in HomeScreen: $err');
            return Scaffold(body: ErrorText(error: err.toString()));
          },
          loading: () {
            print('Loading user data in HomeScreen...');
            return const Scaffold(body: Loader());
          },
        );
  }
}
