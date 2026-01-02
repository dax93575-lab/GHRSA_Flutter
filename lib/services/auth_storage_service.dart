import 'package:shared_preferences/shared_preferences.dart';

/// خدمة تخزين بيانات المصادقة محلياً باستخدام SharedPreferences
class AuthStorageService {
  // Keys for storing data
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyIsGuest = 'isGuest';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  /// حفظ بيانات المستخدم بعد تسجيل الدخول أو إنشاء الحساب
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setBool(_keyIsGuest, false);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// تعيين وضع الزائر
  Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, isGuest);
    if (isGuest) {
      // Clear user data when in guest mode
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserName);
      await prefs.remove(_keyUserEmail);
      await prefs.setBool(_keyIsLoggedIn, false);
    }
  }

  /// استرجاع بيانات المستخدم المحفوظة
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'userId': prefs.getString(_keyUserId),
      'userName': prefs.getString(_keyUserName),
      'userEmail': prefs.getString(_keyUserEmail),
      'isGuest': prefs.getBool(_keyIsGuest) ?? false,
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
    };
  }

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// التحقق من وضع الزائر
  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsGuest) ?? false;
  }

  /// مسح جميع بيانات المستخدم (عند تسجيل الخروج)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyIsGuest);
    await prefs.remove(_keyIsLoggedIn);
  }

  /// الحصول على userId المحفوظ
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }
}
