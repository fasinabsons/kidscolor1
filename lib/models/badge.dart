// models/badge.dart
/// Represents an achievement badge that a user can earn.
class Badge {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int levelRequired;
  final DateTime? unlockedAt;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.levelRequired = 1,
    this.unlockedAt,
  });
}

/// List of all available badges in the app.
final List<Badge> allBadges = [
  const Badge(
    id: 'beginner_artist',
    name: 'Beginner Artist',
    description: 'Complete your first coloring page!',
    imagePath: 'assets/badges/beginner_artist.png',
    levelRequired: 1,
  ),
  const Badge(
    id: 'color_master',
    name: 'Color Master',
    description: 'Complete 5 coloring pages!',
    imagePath: 'assets/badges/color_master.png',
    levelRequired: 5,
  ),
  const Badge(
    id: 'creative_genius',
    name: 'Creative Genius',
    description: 'Complete 10 coloring pages!',
    imagePath: 'assets/badges/creative_genius.png',
    levelRequired: 10,
  ),
];