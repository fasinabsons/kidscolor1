// utils/svg_parser.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'svg_geometry_parser.dart';

class VectorImage {
  const VectorImage({
    required this.items,
    this.size,
  });

  final List<PathSvgItem> items;
  final Size? size;
}

class PathSvgItem {
  const PathSvgItem({
    required this.path,
    this.fill,
  });

  final Path path;
  final Color? fill;

  PathSvgItem copyWith({Path? path, Color? fill}) {
    return PathSvgItem(
      path: path ?? this.path,
      fill: fill ?? this.fill,
    );
  }
}

Future<VectorImage> getVectorImageFromAsset(String assetPath) async {
  final String svgData = await rootBundle.loadString(assetPath);
  return getVectorImageFromStringXml(svgData);
}

Future<VectorImage> getVectorImageFromStringXml(String svgData) async {
  return getVectorImageFromStringXmlWithGeometry(svgData);
}