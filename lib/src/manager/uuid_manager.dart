import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Manages the user's unique identifier.
class UUIDManager {
  static const String _uuidKey = 'wishkit-user-uuid';
  static String? _cachedUUID;

  /// Gets the user's UUID, creating one if it doesn't exist.
  static Future<String> getUUID() async {
    if (_cachedUUID != null) {
      return _cachedUUID!;
    }

    final prefs = await SharedPreferences.getInstance();
    var uuid = prefs.getString(_uuidKey);

    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_uuidKey, uuid);
    }

    _cachedUUID = uuid;
    return uuid;
  }

  /// Stores a specific UUID.
  static Future<void> store(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uuidKey, uuid);
    _cachedUUID = uuid;
  }

  /// Deletes the stored UUID.
  static Future<void> deleteUUID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uuidKey);
    _cachedUUID = null;
  }

  /// Clears the cached UUID (for testing).
  static void clearCache() {
    _cachedUUID = null;
  }
}
