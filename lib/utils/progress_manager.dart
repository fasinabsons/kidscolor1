// utils/progress_manager.dart
import 'package:flutter/material.dart';
import '../models/coloring_page.dart';
import '../models/user_progress.dart';
import '../models/badge.dart' as app_badge;
import 'storage_manager.dart';
import 'svg_geometry_parser.dart'; // Add this import

class ProgressManager {
  UserProgress? _userProgress;

  Future<void> loadProgress() async {
    try {
      _userProgress = await StorageManager.getProgress();
    } catch (e) {
      debugPrint('Error loading progress: $e');
      _userProgress = UserProgress();
    }
  }

  UserProgress get userProgress => _userProgress ?? UserProgress();

  bool isNumbered(ColoringPage page, int completedPagesThreshold) {
    return page.isNumbered && (userProgress.completedPages < completedPagesThreshold);
  }

  void applySavedColors(
      List<EnhancedPathSvgItem> items, String pageId, Function setState) {
    final coloredParts = userProgress.coloredParts[pageId] ?? {};
    setState(() {
      for (int i = 0; i < items.length; i++) {
        if (coloredParts.containsKey('$i')) {
          items[i] = items[i].copyWith(
            originalItem: items[i].originalItem.copyWith(fill: coloredParts['$i']),
          );
        }
      }
    });
  }

  app_badge.Badge? checkForNewBadge() {
    final completedPages = userProgress.completedPages;
    final currentBadges = userProgress.badges;

    for (var badge in app_badge.allBadges) {
      if (!currentBadges.contains(badge.id) && completedPages >= badge.levelRequired) {
        return app_badge.Badge(
          id: badge.id,
          name: badge.name,
          description: badge.description,
          imagePath: badge.imagePath,
          levelRequired: badge.levelRequired,
          unlockedAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  void saveProgress(ColoringPage page, List<EnhancedPathSvgItem> items) {
    userProgress.completedPages++;
    final newBadge = checkForNewBadge();
    if (newBadge != null) {
      userProgress.badges.add(newBadge.id);
    }
    userProgress.coloredParts[page.id] = Map.fromEntries(
      items.asMap().entries.map((entry) => MapEntry(
            entry.key.toString(),
            entry.value.fill!,
          )),
    );
    StorageManager.saveProgress(userProgress);
  }
}