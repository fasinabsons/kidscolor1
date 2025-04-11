import 'package:flutter/material.dart';

class BadgeDisplay extends StatelessWidget {
  final List<String> badges;

  const BadgeDisplay({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: badges.map((badge) {
        return Chip(
          label: Text(badge),
          avatar: const Icon(Icons.star, color: Colors.amber),
          backgroundColor: Colors.pink[50],
        );
      }).toList(),
    );
  }
}
