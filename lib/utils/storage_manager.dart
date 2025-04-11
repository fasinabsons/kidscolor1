// utils/storage_manager.dart
import 'dart:convert';
import 'dart:developer'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

/// Manages the storage of user progress using SharedPreferences.
class StorageManager {
  static const String _progressKey = 'user_progress';

  /// Saves the user's progress to storage.
  static Future<void> saveProgress(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(progress.toJson());
      await prefs.setString(_progressKey, jsonString);
    } catch (e) {
      log('Error saving progress: $e');
    }
  }

  /// Retrieves the user's progress from storage.
  static Future<UserProgress> getProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_progressKey);
      if (jsonString == null) {
        return UserProgress();
      }
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(jsonMap);
    } catch (e) {
      log('Error retrieving progress: $e');
      return UserProgress();
    }
  }
}