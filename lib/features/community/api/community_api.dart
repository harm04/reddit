import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';

final communityAPIProvider = Provider((ref) {
  return CommunityAPI(db: ref.watch(appwriteDatabaseProvider));
});

abstract class ICommunityAPI {
  FutureEitherVoid createCommunity(CommunityModel communityModel);
  FutureEither<List<CommunityModel>> getUserCommunities(String uid);
  FutureEitherVoid getCommunityByName(String name);
  FutureEitherVoid updateCommunity(CommunityModel communityModel);
  Future<List<Row>> searchCommunity(String name);
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
          final communityName = row.data['name']?.toString().toLowerCase() ?? '';
          return communityName.contains(name.toLowerCase());
        }).toList();
        
        return filteredRows;
      }
    } catch (error) {
      print('Search error: $error');
      return [];
    }
  }
}
