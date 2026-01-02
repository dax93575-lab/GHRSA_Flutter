import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../data/database_helper.dart';
import '../services/firebase_service.dart';

class PlantRepository {
  final DatabaseHelper _localDb = DatabaseHelper.instance;
  final FirebaseService _remoteDb = FirebaseService();

  /// returns stream of plants:
  /// 1. Yields Local Data immediately (Offline/Cache).
  /// 2. Fetches Remote, updates Local, yields Remote (Fresh).
  Stream<List<Plant>> getPlants() async* {
    // 1. Emit Local Data (Fast)
    // On Web, local DB is empty/unused except for standard Firebase persistence,
    // so we might skip or rely on in-memory initial data if needed.
    // But for simplicity and consistency with "Offline Mode" request:
    if (!kIsWeb) {
      try {
        final localData = await _localDb.getAllPlants();
        if (localData.isNotEmpty) {
          yield localData;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching local plants: $e');
        }
      }
    }

    // 2. Fetch Remote & Sync (Source of Truth)
    try {
      final remoteData = await _remoteDb.getPlants();

      if (!kIsWeb && remoteData.isNotEmpty) {
        // Update Local Cache
        await _localDb.upsertPlants(remoteData);
      }

      yield remoteData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching remote plants: $e');
      }
      // If offline and we already yielded local data, UI remains populated.
      // If no local data, we could rethrow or yield empty.
      if (!kIsWeb) {
        // We rely on the local data already yielded.
      } else {
        // On web, if offline, Firebase SDK usually handles caching automatically.
      }
    }
  }

  /// Toggle Favorite: Optimistic update
  Future<void> toggleFavorite(Plant plant) async {
    final newStatus = !plant.isFavorite;
    final updatedPlant = plant.copyWith(isFavorite: newStatus);

    // 1. Update Local (Optimistic)
    if (!kIsWeb) {
      await _localDb.toggleFavorite(plant.id!, newStatus);
    }

    // 2. Update Remote
    try {
      await _remoteDb.savePlant(updatedPlant);
    } catch (e) {
      // Rollback Local if Remote fails?
      // Or Queue for later sync? For now, we log error.
      // In a real robust app, we'd use a SyncQueue.
      if (kDebugMode) {
        debugPrint('Error syncing favorite to cloud: $e');
      }
      rethrow;
    }
  }

  /// Add to Cart: Handled by User Collection in Firestore normally,
  /// but `Plant` model has `quantity` (Stock).
  /// So purchasing implies reducing stock in `plants` collection.
  Future<void> updateStock(int plantId, int newQuantity) async {
    // This is a simplified "Purchase" logic
    // 1. Update Local
    if (!kIsWeb) {
      await _localDb.updateQuantity(plantId, newQuantity);
    }

    // We need to fetch the plant to save full object or use a partial update method
    // Since our FirebaseService uses set(merge: true), we can construct a partial object
    // But Plant model creates full object.
    // Let's create a partial object just for the ID and Quantity if possible,
    // or we need to pass the full Plant object.
    // For this demo, assuming we have the full object in Provider.
    // We will let Provider pass the full object to a `savePlant` method here.
  }

  Future<void> savePlant(Plant plant) async {
    await _remoteDb.savePlant(plant);
    if (!kIsWeb) {
      await _localDb.upsertPlants([plant]);
    }
  }
}
