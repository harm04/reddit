import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/appwrite_constants.dart';

// Appwrite Client Provider
final appwriteClientProvider = Provider((ref) {
  Client client = Client();
  return client
      .setEndpoint(AppwriteConstants.endpoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true);
});

// Appwrite Account Provider
final appwriteAccountProvider = Provider((ref) {
  return Account(ref.watch(appwriteClientProvider));
});

// Appwrite Database Provider
final appwriteDatabaseProvider = Provider((ref) {
  return TablesDB(ref.watch(appwriteClientProvider));
});
// Appwrite Realtime Provider
final appwriteRealtimeProvider = Provider((ref) {
  return Realtime(ref.watch(appwriteClientProvider));
});

//appwrite Storage Provider
final appwriteStorageProvider = Provider((ref) {
  return Storage(ref.watch(appwriteClientProvider));
}); 

