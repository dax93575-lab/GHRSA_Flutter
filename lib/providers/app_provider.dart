import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../repositories/plant_repository.dart';
import '../services/firebase_service.dart';
import '../services/auth_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppProvider with ChangeNotifier {
  final PlantRepository _repository = PlantRepository();
  final AuthStorageService _authStorage = AuthStorageService();
  final FirebaseService _authService = FirebaseService();
  StreamSubscription<List<Plant>>? _plantsSubscription;

  List<Plant> _plants = [];
  List<Plant> _filteredPlants = [];
  bool _isLoading = false;

  // Auth State
  bool _isGuest = false;
  String? _userName;
  String? _userEmail;
  String? _userId;

  // Cart State
  final Map<String, int> _cart = {};

  // Getters
  List<Plant> get plants => _plants;
  List<Plant> get filteredPlants => _filteredPlants;
  bool get isLoading => _isLoading;
  bool get isGuest => _isGuest;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  Map<String, int> get cart => _cart;

  // Derived Getters
  List<Plant> get popularPlants => _plants.take(5).toList();
  List<Plant> get indoorPlants =>
      _plants.where((p) => p.category == 'داخلي').toList();
  List<Plant> get outdoorPlants =>
      _plants.where((p) => p.category == 'خارجي').toList();

  List<Plant> get cartPlants =>
      _plants.where((p) => _cart.containsKey(p.id.toString())).toList();

  List<Plant> get favoritePlants => _plants.where((p) => p.isFavorite).toList();

  double get subTotal {
    double total = 0;
    _cart.forEach((key, quantity) {
      try {
        final plant = _plants.firstWhere((p) => p.id.toString() == key);
        total += plant.price * quantity;
      } catch (e) {
        // Plant might not be loaded yet or deleted
      }
    });
    return total;
  }

  // Filter Logic
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  String get selectedCategory => _selectedCategory;

  @override
  void dispose() {
    _plantsSubscription?.cancel();
    super.dispose();
  }

  // --- Actions ---

  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();

    // cancel previous subscription if any
    await _plantsSubscription?.cancel();

    _plantsSubscription = _repository.getPlants().listen(
      (plantsData) {
        _plants = plantsData;

        // Ensure guests don't see any favorites from local cache or default values
        if (_isGuest || _userId == null) {
          for (var i = 0; i < _plants.length; i++) {
            if (_plants[i].isFavorite) {
              _plants[i] = _plants[i].copyWith(isFavorite: false);
            }
          }
        } else {
          // If user is logged in, re-apply favorite status from loaded favorites
          // This handles cases where plants refresh but favorites were already loaded
          loadFavorites();
        }

        _applyFilters(); // Re-apply filters on new data
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('Error in plants stream: $error');
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addPlant(Plant plant) async {
    try {
      // Repository handles Local + Remote sync
      await _repository.savePlant(plant);

      // Optimistic Update: Add to local list immediately
      _plants.add(plant);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding plant: $e');
      }
      rethrow;
    }
  }

  Future<void> toggleFavorite(Plant plant) async {
    // Guests and logged-out users can't save favorites
    if (_isGuest || _userId == null) {
      if (kDebugMode) {
        debugPrint('Cannot save favorites for guest users');
      }
      return;
    }

    // 1. Optimistic Update (UI)
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      final oldStatus = _plants[index].isFavorite;
      _plants[index] = _plants[index].copyWith(isFavorite: !oldStatus);
      notifyListeners();

      // 2. Update Firestore user favorites collection
      try {
        final firestore = FirebaseFirestore.instance;
        final favRef = firestore
            .collection('users')
            .doc(_userId)
            .collection('favorites')
            .doc(plant.id.toString());

        if (!oldStatus) {
          // Add to favorites
          await favRef.set({
            'plantId': plant.id,
            'addedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Remove from favorites
          await favRef.delete();
        }
      } catch (e) {
        // Revert on failure
        _plants[index] = _plants[index].copyWith(isFavorite: oldStatus);
        notifyListeners();
        if (kDebugMode) {
          debugPrint('Error toggling favorite: $e');
        }
        rethrow;
      }
    }
  }

  /// Load user's favorites from Firestore
  Future<void> loadFavorites() async {
    if (_isGuest || _userId == null) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final favSnapshot = await firestore
          .collection('users')
          .doc(_userId)
          .collection('favorites')
          .get();

      // Create a set of favorite plant IDs
      final favoriteIds = favSnapshot.docs
          .map((doc) => doc.data()['plantId'] as int?)
          .where((id) => id != null)
          .toSet();

      // Update plants with favorite status
      for (var i = 0; i < _plants.length; i++) {
        final isFav = favoriteIds.contains(_plants[i].id);
        if (_plants[i].isFavorite != isFav) {
          _plants[i] = _plants[i].copyWith(isFavorite: isFav);
        }
      }
      notifyListeners();

      if (kDebugMode) {
        debugPrint('Loaded ${favoriteIds.length} favorites for user');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading favorites: $e');
      }
    }
  }

  // --- Cart & Purchasing ---

  void addToCart(Plant plant, int quantity) {
    if (plant.id == null) return;
    final pid = plant.id.toString();
    if (_cart.containsKey(pid)) {
      _cart[pid] = _cart[pid]! + quantity;
    } else {
      _cart[pid] = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(Plant plant) {
    if (plant.id == null) return;
    _cart.remove(plant.id.toString());
    notifyListeners();
  }

  void decreaseQuantity(Plant plant) {
    if (plant.id == null) return;
    final pid = plant.id.toString();
    if (_cart.containsKey(pid)) {
      if (_cart[pid]! > 1) {
        _cart[pid] = _cart[pid]! - 1;
      } else {
        _cart.remove(pid);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<void> completePurchase() async {
    // Prevent guests from purchasing
    if (_isGuest) {
      throw Exception('يرجى تسجيل الدخول للشراء');
    }

    if (_userId == null) {
      throw Exception('لا يوجد مستخدم مسجل دخول');
    }

    final cartSnapshot = Map<String, int>.from(_cart);

    // Clear cart immediately for UX
    clearCart();

    try {
      final firestore = FirebaseFirestore.instance;

      for (var entry in cartSnapshot.entries) {
        final pid = int.parse(entry.key);
        final buyQuantity = entry.value;

        // Find plant to update stock
        final index = _plants.indexWhere((p) => p.id == pid);
        if (index != -1) {
          final plant = _plants[index];
          final newQuantity = plant.quantity - buyQuantity;

          final updatedPlant = plant.copyWith(quantity: newQuantity);

          // Optimistic update in list
          _plants[index] = updatedPlant;

          // Persist to Firestore (global quantity)
          await _repository.savePlant(updatedPlant);
        }
      }

      // Save order to user's orders collection
      await firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .add({
            'items': cartSnapshot,
            'total': subTotal,
            'timestamp': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error completing purchase: $e');
      }
      rethrow;
    }
  }

  // --- Auth ---

  /// تحميل بيانات المستخدم من SharedPreferences عند بدء التطبيق
  Future<void> loadUserData() async {
    try {
      final userData = await _authStorage.getUserData();
      if (userData['isLoggedIn'] == true) {
        _userName = userData['userName'];
        _userEmail = userData['userEmail'];
        _userId = userData['userId'];
        _isGuest = userData['isGuest'] ?? false;
        notifyListeners();

        // Load favorites for this user
        if (!_isGuest && _userId != null) {
          await loadFavorites();
        } else {
          // If guest, ensure local favorites are cleared
          for (var i = 0; i < _plants.length; i++) {
            if (_plants[i].isFavorite) {
              _plants[i] = _plants[i].copyWith(isFavorite: false);
            }
          }
        }

        if (kDebugMode) {
          debugPrint('User data loaded: $_userName ($_userEmail)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user data: $e');
      }
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signIn(email, password);
      _isGuest = false;
      _userEmail = email;
      _userId = credential.user?.uid;
      _userName = credential.user?.displayName ?? 'مستخدم';

      // Save to SharedPreferences
      if (_userId != null) {
        await _authStorage.saveUserData(
          userId: _userId!,
          name: _userName!,
          email: email,
        );

        // Load favorites for this user
        await loadFavorites();
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login Error: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _authService.signUp(email, password, name);
      _isGuest = false;
      _userEmail = email;
      _userName = name;
      _userId = credential.user?.uid;

      // Save to SharedPreferences
      if (_userId != null) {
        await _authStorage.saveUserData(
          userId: _userId!,
          name: name,
          email: email,
        );

        // New user has no favorites yet, but initialize empty
        await loadFavorites();
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Signup Error: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setGuest(bool value) async {
    _isGuest = value;
    if (value) {
      _userName = 'زائر';
      _userEmail = null;
      _userId = null;
      await _authStorage.setGuestMode(true);

      // Clear favorites from memory for Guest
      for (var i = 0; i < _plants.length; i++) {
        if (_plants[i].isFavorite) {
          _plants[i] = _plants[i].copyWith(isFavorite: false);
        }
      }
    }
    notifyListeners();
  }

  // Helper to manually set user data if needed (e.g. from local storage on startup)
  void setUserData(String name, String email) {
    _isGuest = false;
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    await _authStorage.clearUserData();
    _isGuest = false;
    _userName = null;
    _userEmail = null;
    _userId = null;
    clearCart();

    // Clear favorites from memory on logout
    for (var i = 0; i < _plants.length; i++) {
      if (_plants[i].isFavorite) {
        _plants[i] = _plants[i].copyWith(isFavorite: false);
      }
    }

    notifyListeners();
  }

  // --- Filters ---

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void searchPlants(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredPlants = _plants.where((plant) {
      final matchesCategory =
          _selectedCategory == 'الكل' || plant.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          plant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          plant.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
    notifyListeners();
  }
}
