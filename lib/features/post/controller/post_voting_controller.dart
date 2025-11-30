import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/api/post_api.dart';
import 'package:reddit/models/post_model.dart';

// State class to hold vote data
class PostVoteState {
  final Map<String, PostModel> localVotes;
  final Queue<String> pendingSyncs;
  final bool isSyncing;

  PostVoteState({
    required this.localVotes,
    required this.pendingSyncs,
    required this.isSyncing,
  });

  PostVoteState copyWith({
    Map<String, PostModel>? localVotes,
    Queue<String>? pendingSyncs,
    bool? isSyncing,
  }) {
    return PostVoteState(
      localVotes: localVotes ?? this.localVotes,
      pendingSyncs: pendingSyncs ?? this.pendingSyncs,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

// Provider for the voting controller
final postVotingControllerProvider = StateNotifierProvider<PostVotingController, PostVoteState>((ref) {
  return PostVotingController(
    postAPI: ref.watch(postAPIProvider),
    ref: ref,
  );
});

class PostVotingController extends StateNotifier<PostVoteState> {
  final PostAPI postAPI;
  final Ref ref;
  Timer? _syncTimer;

  PostVotingController({
    required this.postAPI,
    required this.ref,
  }) : super(PostVoteState(
          localVotes: {},
          pendingSyncs: Queue<String>(),
          isSyncing: false,
        ));

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  // Get the current vote state for a post (local or original)
  PostModel getPostVoteState(PostModel originalPost) {
    return state.localVotes[originalPost.id] ?? originalPost;
  }

  // Handle upvote - INSTANT UI UPDATE
  void upvotePost(PostModel post) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final currentPost = getPostVoteState(post);
    final userId = currentUser.uid;
    
    List<String> upvotes = List.from(currentPost.upvotes);
    List<String> downvotes = List.from(currentPost.downvotes);

    // Remove from downvotes if present
    downvotes.remove(userId);

    // Toggle upvote
    if (upvotes.contains(userId)) {
      upvotes.remove(userId);
    } else {
      upvotes.add(userId);
    }

    // INSTANT UPDATE - Update state immediately
    _updateLocalVoteInstantly(post, upvotes, downvotes);
  }

  // Handle downvote - INSTANT UI UPDATE
  void downvotePost(PostModel post) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    final currentPost = getPostVoteState(post);
    final userId = currentUser.uid;
    
    List<String> upvotes = List.from(currentPost.upvotes);
    List<String> downvotes = List.from(currentPost.downvotes);

    // Remove from upvotes if present
    upvotes.remove(userId);

    // Toggle downvote
    if (downvotes.contains(userId)) {
      downvotes.remove(userId);
    } else {
      downvotes.add(userId);
    }

    // INSTANT UPDATE - Update state immediately
    _updateLocalVoteInstantly(post, upvotes, downvotes);
  }

  // FIXED: Update local state INSTANTLY and schedule delayed sync
  void _updateLocalVoteInstantly(PostModel originalPost, List<String> upvotes, List<String> downvotes) {
    final updatedPost = originalPost.copyWith(
      upvotes: upvotes,
      downvotes: downvotes,
    );

    // Update local state immediately for instant UI feedback
    final newLocalVotes = Map<String, PostModel>.from(state.localVotes);
    newLocalVotes[originalPost.id] = updatedPost;

    final newPendingSyncs = Queue<String>.from(state.pendingSyncs);
    if (!newPendingSyncs.contains(originalPost.id)) {
      newPendingSyncs.add(originalPost.id);
    }

    // INSTANT STATE UPDATE
    state = state.copyWith(
      localVotes: newLocalVotes,
      pendingSyncs: newPendingSyncs,
    );

    print('✅ INSTANT vote update for post ${originalPost.id}');
    print('📊 Upvotes: ${upvotes.length}, Downvotes: ${downvotes.length}');

    // Start delayed sync timer (debounced)
    _startSyncTimer();
  }

  // Start or restart the sync timer (2 second delay)
  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 2), () {
      _syncPendingVotes();
    });
  }

  // Sync pending votes to Appwrite (background operation)
  Future<void> _syncPendingVotes() async {
    if (state.isSyncing || state.pendingSyncs.isEmpty) return;

    state = state.copyWith(isSyncing: true);
    print('🔄 Starting sync to Appwrite...');

    final pendingIds = List<String>.from(state.pendingSyncs);
    final newPendingSyncs = Queue<String>();

    for (final postId in pendingIds) {
      final localPost = state.localVotes[postId];
      if (localPost != null) {
        try {
          final result = await postAPI.upvotePost(
            postId,
            localPost.upvotes,
            localPost.downvotes,
          );

          result.fold(
            (failure) {
              print('❌ Failed to sync vote for post $postId: ${failure.message}');
              // Re-add to pending if failed
              newPendingSyncs.add(postId);
            },
            (_) {
              print('✅ Successfully synced vote for post $postId to Appwrite');
            },
          );
        } catch (e) {
          print('❌ Error syncing vote for post $postId: $e');
          newPendingSyncs.add(postId);
        }
      }
    }

    state = state.copyWith(
      pendingSyncs: newPendingSyncs,
      isSyncing: false,
    );

    // If there are still pending syncs, try again later
    if (newPendingSyncs.isNotEmpty) {
      print('⏳ Retrying failed syncs...');
      _startSyncTimer();
    } else {
      print('✅ All votes synced successfully');
    }
  }

  // Force sync all pending votes (useful for manual sync)
  Future<void> forceSyncAll() async {
    _syncTimer?.cancel();
    await _syncPendingVotes();
  }

  // Clear local vote state (useful when refreshing data)
  void clearLocalVotes() {
    state = PostVoteState(
      localVotes: {},
      pendingSyncs: Queue<String>(),
      isSyncing: false,
    );
  }
}