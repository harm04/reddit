import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/user_model.dart';

final communityAPIProvider = Provider((ref) {
  return CommunityAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class ICommunityAPI {
  FutureEitherVoid createCommunity(CommunityModel communityModel);
  FutureEither<List<CommunityModel>> getUserCommunities(String uid);
  FutureEitherVoid getCommunityByName(String name);
  FutureEitherVoid updateCommunity(CommunityModel communityModel);
  Future<List<Row>> searchCommunity(String name);
  FutureEitherVoid joinCommunity(String communityId, String userId);
  FutureEither<List<UserModel>> getCommunityMembers(String communityName);
  FutureEitherVoid makeModerator(String communityId, String userId);
}

class CommunityAPI implements ICommunityAPI {
  final TablesDB _db;
  CommunityAPI({required TablesDB db}) : _db = db;

  @override
  FutureEitherVoid createCommunity(CommunityModel communityModel) async {
    try {
      final existingCommunities = await _db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        queries: [Query.equal('name', communityModel.name)],
      );

      if (existingCommunities.total > 0) {
        return left(Failure('Community name already taken', ''));
      }

      // Create new community
      await _db.createRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        rowId: ID.unique(),
        data: communityModel.toMap(),
      );

      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  @override
  FutureEither<List<CommunityModel>> getUserCommunities(String uid) async {
    try {
      final result = await _db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        queries: [Query.search('members', uid)],
      );

      final communities = result.rows.map((row) {
        final data = Map<String, dynamic>.from(row.data);
        data['\$id'] = row.$id; // Add the row ID to the data
        return CommunityModel.fromMap(data);
      }).toList();

      return right(communities);
    } catch (error, stackTrace) {
      return left(Failure(error.toString(), stackTrace.toString()));
    }
  }

  //get communities by name
  @override
  FutureEither<CommunityModel?> getCommunityByName(String name) async {
    try {
      final result = await _db.listRows(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        queries: [Query.equal('name', name), Query.limit(1)],
      );

      if (result.rows.isEmpty) {
        return right(null);
      }
      final row = result.rows.first;
      final data = Map<String, dynamic>.from(row.data);
      data['\$id'] = row.$id;
      final community = CommunityModel.fromMap(data);

      return right(community);
    } catch (error, stackTrace) {
      return left(Failure(error.toString(), stackTrace.toString()));
    }
  }

  //update community details
  @override
  FutureEitherVoid updateCommunity(CommunityModel communityModel) async {
    try {
      await _db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        rowId: communityModel.id,
        data: communityModel.toMap(),
      );
      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  @override
  Future<List<Row>> searchCommunity(String name) async {
    try {
      // Handle empty query
      if (name.trim().isEmpty) {
        return [];
      }

      // If search by name attribute fails (no fulltext index), get all and filter
      try {
        final result = await _db.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.communityTableId,
          queries: [Query.search('name', name)],
        );
        return result.rows;
      } catch (e) {
        print('Search failed, trying alternative approach: $e');

        // Fallback: Get all communities and filter manually
        final allResult = await _db.listRows(
          databaseId: AppwriteConstants.databaseId,
          tableId: AppwriteConstants.communityTableId,
          queries: [Query.limit(100)],
        );

        // Filter manually
        final filteredRows = allResult.rows.where((row) {
          final communityName =
              row.data['name']?.toString().toLowerCase() ?? '';
          return communityName.contains(name.toLowerCase());
        }).toList();

        return filteredRows;
      }
    } catch (error) {
      print('Search error: $error');
      return [];
    }
  }

  //join or leave community function
  @override
  FutureEitherVoid joinCommunity(String communityId, String userId) async {
    try {
      final row = await _db.getRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        rowId: communityId,
      );

      List<dynamic> members = row.data['members'] ?? [];
      if (!members.contains(userId)) {
        members.add(userId);
      } else {
        members.remove(userId);
      }

      await _db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        rowId: communityId,
        data: {'members': members},
      );

      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }

  // Add this method to your CommunityAPI class
  @override
  FutureEither<List<UserModel>> getCommunityMembers(
    String communityName,
  ) async {
    try {
      // First get the community
      final communityResult = await getCommunityByName(communityName);

      return communityResult.fold((failure) => left(failure), (
        community,
      ) async {
        if (community == null) {
          return left(Failure('Community not found', ''));
        }

        // Get all users who are members of this community
        List<UserModel> members = [];

        for (String memberId in community.members) {
          try {
            final userResult = await _db.listRows(
              databaseId: AppwriteConstants.databaseId,
              tableId: AppwriteConstants.userTableId,
              queries: [Query.equal('\$id', memberId), Query.limit(1)],
            );

            if (userResult.rows.isNotEmpty) {
              final userData = Map<String, dynamic>.from(
                userResult.rows.first.data,
              );
              userData['\$id'] = userResult.rows.first.$id;
              members.add(UserModel.fromMap(userData));
            }
          } catch (e) {
            print('Error fetching user $memberId: $e');
          }
        }

        return right(members);
      });
    } catch (error, stackTrace) {
      return left(Failure(error.toString(), stackTrace.toString()));
    }
  }

  //make moderator
  @override
  FutureEitherVoid makeModerator(String communityId, String userId) async {
    try {
      final row = await _db.getRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        rowId: communityId,
      );

      List<dynamic> mods = row.data['mods'] ?? [];
      if (!mods.contains(userId)) {
        mods.add(userId);
      } else {
        mods.remove(userId);
      }

      await _db.updateRow(
        databaseId: AppwriteConstants.databaseId,
        tableId: AppwriteConstants.communityTableId,
        rowId: communityId,
        data: {'mods': mods},
      );

      return right(null);
    } catch (error, st) {
      return left(Failure(error.toString(), st.toString()));
    }
  }
}
