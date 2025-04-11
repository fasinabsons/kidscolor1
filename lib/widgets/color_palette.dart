// widgets/color_palette.dart
import 'package:flutter/material.dart';

class ColorPalette extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;
  final Color selectedColor;

  const ColorPalette({
    super.key,
    required this.onColorSelected,
    required this.selectedColor,
  });

  final List<Color> colors = const [
    // Original colors
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    // Additional vibrant colors
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.amber,
    // Pastel shades
    Color(0xFFFFB3BA), // Pastel pink
    Color(0xFFFFDFBA), // Pastel peach
    Color(0xFFFFF9BA), // Pastel yellow
    Color(0xFFBAFFC9), // Pastel green
    Color(0xFFBAE1FF), // Pastel blue
    // Neon shades
    Color(0xFFFF00FF), // Neon magenta
    Color(0xFF00FF00), // Neon green
    Color(0xFFFFFF00), // Neon yellow
    Color(0xFF00FFFF), // Neon cyan
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: colors.map((color) {
          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor == color ? Colors.black : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}