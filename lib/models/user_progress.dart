// models/user_progress.dart
import 'package:flutter/material.dart';

/// Represents the user's progress in the app.
class UserProgress {
  int level;
  int coins;
  List<String> badges;
  Map<String, Map<String, Color>> coloredParts; // Page ID -> Part ID -> Color
  bool isGuest;
  int completedPages;

  UserProgress({
    this.level = 1,
    this.coins = 0,
    this.badges = const [],
    this.coloredParts = const {},
    this.isGuest = true,
    this.completedPages = 0,
  });

  /// Converts the UserProgress to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'coins': coins,
      'badges': badges,
      'coloredParts': coloredParts.map(
        (pageId, parts) => MapEntry(
          pageId,
          parts.map((partId, color) => MapEntry(partId, {
  'r': color.r,
  'g': color.g,
  'b': color.b,
  'a': color.a,
})),
        ),
      ),
      'isGuest': isGuest,
      'completedPages': completedPages,
    };
  }

  /// Creates a UserProgress instance from a JSON map.
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      level: json['level'] ?? 1,
      coins: json['coins'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      coloredParts: (json['coloredParts'] as Map<String, dynamic>?)?.map(
            (pageId, parts) => MapEntry(
              pageId,
              (parts as Map<String, dynamic>).map(
                (partId, colorValue) => MapEntry(partId, Color(colorValue as int)),
              ),
            ),
          ) ??
          {},
      isGuest: json['isGuest'] ?? true,
      completedPages: json['completedPages'] ?? 0,
    );
  }
}