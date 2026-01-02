import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/plant.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection References
  CollectionReference get _plantsRef => _firestore.collection('plants');
  CollectionReference get _usersRef => _firestore.collection('users');

  /// Fetches all plants from Firestore
  Future<List<Plant>> getPlants() async {
    try {
      final snapshot = await _plantsRef.get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        // Ensure ID is preserved. Firestore IDs are strings, but our model uses int.
        // We try to parse the document ID if the 'id' field is missing.
        if (data['id'] == null) {
          data['id'] = int.tryParse(doc.id);
        }
        return Plant.fromMap(data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching plants from Firebase: $e');
      }
      rethrow;
    }
  }

  /// Updates or Adds a plant to Firestore
  /// Uses the plant's ID as the Document ID to ensure consistency
  Future<void> savePlant(Plant plant) async {
    try {
      if (plant.id == null) throw Exception('Plant ID cannot be null');

      await _plantsRef
          .doc(plant.id.toString())
          .set(
            plant.toMap(),
            SetOptions(
              merge: true,
            ), // Merge to avoid overwriting partial updates if any
          );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving plant to Firebase: $e');
      }
      rethrow;
    }
  }

  /// Sign In with Email & Password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing in: $e');
      }
      rethrow;
    }
  }

  /// Sign Up with Email, Password & Name
  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update Display Name
      await credential.user?.updateDisplayName(name);

      // Create User Document
      await _usersRef.doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing up: $e');
      }
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sync user profile
  Future<void> syncUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _usersRef.doc(user.uid).set({
        'email': user.email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
