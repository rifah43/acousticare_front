

class AuthService {
  static const String _deviceIdKey = 'device_id';
  static const String _userIdKey = 'user_id';


  // Get device ID (uses DeviceHelper)
  static Future<String?> getDeviceId() async {
    String? deviceId = 'device_id';
    // String? deviceId = await ReadCache.getString(key: _deviceIdKey);
    return deviceId;
  }

  // Initialize device
  static Future<void> initializeDevice() async {
    String? deviceId = await getDeviceId();
    if (deviceId == null) {
      throw Exception('Failed to initialize device ID');
    }
  }

  // Set active user ID
  static Future<void> setUserId(String userId) async {
    // await WriteCache.setString(key: _userIdKey, value: userId);
  }

  // Get active user ID
  static Future<String?> getUserId() async {
    return null;
  
    // return await ReadCache.getString(key: _userIdKey);
  }

  // Remove user ID
  static Future<void> removeUserId() async {
    // await DeleteCache.deleteKey(_userIdKey);
  }

  // Clear all auth data
  static Future<void> clearAuth() async {
    await removeUserId();
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final userId = await getUserId();
    return userId != null;
  }

  // Save full auth data (used after successful login/registration)
  static Future<void> saveAuthData({
    required String userId,
  }) async {
    await setUserId(userId);
  }
}


// import 'package:get_storage/get_storage.dart';

// class AuthService {
//   static const String _deviceIdKey = 'device_id';
//   static const String _userIdKey = 'user_id';
  
//   // Initialize storage
//   static final GetStorage _storage = GetStorage();

//   // Get device ID (uses DeviceHelper)
//   static String? getDeviceId() {
//     return _storage.read(_deviceIdKey) ?? 'device_id';
//   }

//   // Initialize device
//   static Future<void> initializeDevice() async {
//     String? deviceId = getDeviceId();
//     if (deviceId == null) {
//       throw Exception('Failed to initialize device ID');
//     }
//   }

//   // Set active user ID
//   static Future<void> setUserId(String userId) async {
//     await _storage.write(_userIdKey, userId);
//   }

//   // Get active user ID
//   static String? getUserId() {
//     return _storage.read(_userIdKey);
//   }

//   // Remove user ID
//   static Future<void> removeUserId() async {
//     await _storage.remove(_userIdKey);
//   }

//   // Clear all auth data
//   static Future<void> clearAuth() async {
//     await removeUserId();
//   }

//   // Check if user is authenticated
//   static bool isAuthenticated() {
//     final userId = getUserId();
//     return userId != null;
//   }

//   // Save full auth data (used after successful login/registration)
//   static Future<void> saveAuthData({
//     required String userId,
//   }) async {
//     await setUserId(userId);
//   }
// }