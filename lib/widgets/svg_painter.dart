// widgets/svg_painter.dart
import 'package:flutter/material.dart';
import '../utils/svg_geometry_parser.dart';

class SvgPainter extends CustomPainter {
  const SvgPainter(this.enhancedItem, {this.onTap});

  final EnhancedPathSvgItem enhancedItem;
  final VoidCallback? onTap;

  @override
  void paint(Canvas canvas, Size size) {
    final path = enhancedItem.path;
    final geometry = enhancedItem.geometry;

    // Fill the path with the selected color (or white if uncolored)
    final fillPaint = Paint()
      ..color = enhancedItem.fill ?? Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw the lines (edges) with high precision
    final linePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5; // Increased stroke width for better visibility
    for (var line in geometry.lines) {
      canvas.drawLine(line.start, line.end, linePaint);
    }

    // Draw vertices for extra clarity
    final vertexPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    for (var vertex in geometry.vertices) {
      canvas.drawCircle(vertex, 1.0, vertexPaint);
    }

    // Draw polygons (if any)
    for (var polygon in geometry.polygons) {
      canvas.drawPath(polygon.toPath(), linePaint);
    }
  }

  @override
  bool? hitTest(Offset position) {
    final path = enhancedItem.path;
    bool isHit = path.contains(position);
    debugPrint('Hit test at position $position: $isHit');
    if (isHit) {
      onTap?.call();
      return true;
    }
    return false;
  }

  @override
  bool shouldRepaint(SvgPainter oldDelegate) {
    return enhancedItem.fill != oldDelegate.enhancedItem.fill ||
        enhancedItem.path != oldDelegate.enhancedItem.path;
  }
}

class SvgPainterImage extends StatelessWidget {
  const SvgPainterImage({
    super.key,
    required this.item,
    this.onTap,
  });

  final EnhancedPathSvgItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SvgPainter(item, onTap: onTap),
      child: const SizedBox.expand(),
    );
  }
}