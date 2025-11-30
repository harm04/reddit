import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:reddit/core/utils/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/profile/screens/profile_screen.dart';
import 'package:reddit/theme/pallete.dart';

class SearchUserScreen extends ConsumerStatefulWidget {
  const SearchUserScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchUserScreenState();
}

class _SearchUserScreenState extends ConsumerState<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      print('🔍 Search query changed to: "$_searchQuery"'); // Debug log
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search users by name...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Pallete.greyColor),
          ),
          style: const TextStyle(color: Pallete.whiteColor, fontSize: 18),
          onChanged: _onSearchChanged,
          autofocus: true,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Pallete.greyColor),
                  SizedBox(height: 16),
                  Text(
                    'Search for Users',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Pallete.greyColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter a user name to start searching',
                    style: TextStyle(fontSize: 16, color: Pallete.greyColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Consumer(
              builder: (context, ref, child) {
                // Debug log
                return ref
                    .watch(searchUsersProvider(_searchQuery))
                    .when(
                      data: (users) {
                        if (users.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Pallete.greyColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No users found for "$_searchQuery"',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Try searching with different keywords',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Pallete.greyColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(userId: user.uid),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user.profilePicture,
                                  ),
                                  radius: 20,
                                ),
                                title: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Karma: ${user.karma} • Awards: ${user.awards.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      error: (error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 80,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Search Error',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: $error',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ref.invalidate(
                                    searchUsersProvider(_searchQuery),
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () {
                        print(
                          '⏳ Loading search results for: "$_searchQuery"',
                        ); // Debug log
                        return const Center(child: Loader());
                      },
                    );
              },
            ),
    );
  }
}
