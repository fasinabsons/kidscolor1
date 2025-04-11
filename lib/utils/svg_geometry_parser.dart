// utils/svg_geometry_parser.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';
import 'svg_parser.dart';

class SvgGeometry {
  final List<LineSegment> lines;
  final List<Offset> vertices;
  final List<Polygon> polygons;

  SvgGeometry({
    required this.lines,
    required this.vertices,
    required this.polygons,
  });
}

class LineSegment {
  final Offset start;
  final Offset end;

  LineSegment(this.start, this.end);
}

class Polygon {
  final List<Offset> vertices;

  Polygon(this.vertices);

  Path toPath() {
    final path = Path();
    if (vertices.isEmpty) return path;
    path.moveTo(vertices.first.dx, vertices.first.dy);
    for (var vertex in vertices.skip(1)) {
      path.lineTo(vertex.dx, vertex.dy);
    }
    path.close();
    return path;
  }
}

class EnhancedPathSvgItem {
  final PathSvgItem originalItem;
  final SvgGeometry geometry;

  EnhancedPathSvgItem({
    required this.originalItem,
    required this.geometry,
  });

  Path get path => originalItem.path;
  Color? get fill => originalItem.fill;

  EnhancedPathSvgItem copyWith({PathSvgItem? originalItem, SvgGeometry? geometry}) {
    return EnhancedPathSvgItem(
      originalItem: originalItem ?? this.originalItem,
      geometry: geometry ?? this.geometry,
    );
  }
}

Future<List<EnhancedPathSvgItem>> enhanceVectorImage(VectorImage vectorImage) async {
  final List<EnhancedPathSvgItem> enhancedItems = [];
  for (var item in vectorImage.items) {
    final geometry = await _parseGeometry(item.path);
    enhancedItems.add(EnhancedPathSvgItem(
      originalItem: item,
      geometry: geometry,
    ));
  }
  return enhancedItems;
}

Future<SvgGeometry> _parseGeometry(Path path) async {
  final lines = <LineSegment>[];
  final vertices = <Offset>[];
  final polygons = <Polygon>[];

  // Use PathMetrics to approximate the path as a series of line segments
  final pathMetrics = path.computeMetrics();
  Offset? lastPosition;

  for (var metric in pathMetrics) {
    // Sample the path at small intervals to approximate curves as lines
    for (double t = 0; t <= metric.length; t += 5.0) {
      final tangent = metric.getTangentForOffset(t);
      if (tangent == null) continue;

      final currentPosition = tangent.position;
      vertices.add(currentPosition);

      if (lastPosition != null) {
        lines.add(LineSegment(lastPosition, currentPosition));
      }
      lastPosition = currentPosition;
    }

    // Check if the path is closed to form a polygon
    if (metric.isClosed) {
      if (vertices.length > 2) {
        polygons.add(Polygon(List.from(vertices)));
      }
      vertices.clear(); // Reset for the next polygon
    }
  }

  return SvgGeometry(
    lines: lines,
    vertices: vertices,
    polygons: polygons,
  );
}

// Update the SVG parser to handle additional elements
Future<VectorImage> getVectorImageFromAssetWithGeometry(String assetPath) async {
  final String svgData = await rootBundle.loadString(assetPath);
  return getVectorImageFromStringXmlWithGeometry(svgData);
}

VectorImage getVectorImageFromStringXmlWithGeometry(String svgData) {
  List<PathSvgItem> items = [];

  // Parse the XML
  XmlDocument document = XmlDocument.parse(svgData);

  // Get the size of the SVG
  Size? size;
  String? width = document.findAllElements('svg').first.getAttribute('width');
  String? height = document.findAllElements('svg').first.getAttribute('height');
  String? viewBox = document.findAllElements('svg').first.getAttribute('viewBox');
  if (width != null && height != null) {
    width = width.replaceAll(RegExp(r'[^0-9.]'), '');
    height = height.replaceAll(RegExp(r'[^0-9.]'), '');
    size = Size(double.parse(width), double.parse(height));
  } else if (viewBox != null) {
    List<String> viewBoxList = viewBox.split(' ');
    size = Size(double.parse(viewBoxList[2]), double.parse(viewBoxList[3]));
  }

  // Parse <path> elements
  final List<XmlElement> paths = document.findAllElements('path').toList();
  for (int i = 0; i < paths.length; i++) {
    final XmlElement element = paths[i];
    String? pathString = element.getAttribute('d');
    if (pathString == null) continue;
    Path path = parseSvgPathData(pathString);
    items.add(_processElement(element, path));
  }

  // Parse <polygon> elements
  final List<XmlElement> polygons = document.findAllElements('polygon').toList();
  for (var element in polygons) {
    String? points = element.getAttribute('points');
    if (points == null) continue;
    Path path = _pointsToPath(points);
    items.add(_processElement(element, path));
  }

  // Parse <polyline> elements
  final List<XmlElement> polylines = document.findAllElements('polyline').toList();
  for (var element in polylines) {
    String? points = element.getAttribute('points');
    if (points == null) continue;
    Path path = _pointsToPath(points, close: false);
    items.add(_processElement(element, path));
  }

  // Parse <line> elements
  final List<XmlElement> lines = document.findAllElements('line').toList();
  for (var element in lines) {
    String? x1 = element.getAttribute('x1');
    String? y1 = element.getAttribute('y1');
    String? x2 = element.getAttribute('x2');
    String? y2 = element.getAttribute('y2');
    if (x1 == null || y1 == null || x2 == null || y2 == null) continue;
    Path path = Path()
      ..moveTo(double.parse(x1), double.parse(y1))
      ..lineTo(double.parse(x2), double.parse(y2));
    items.add(_processElement(element, path));
  }

  return VectorImage(items: items, size: size);
}

PathSvgItem _processElement(XmlElement element, Path path) {
  // Get the fill color
  String? fill = element.getAttribute('fill');
  String? style = element.getAttribute('style');
  if (style != null) {
    fill = _getFillColor(style);
  }

  // Get the transformations
  String? transformAttribute = element.getAttribute('transform');
  double scaleX = 1.0;
  double scaleY = 1.0;
  double? translateX;
  double? translateY;
  if (transformAttribute != null) {
    var scale = _getScale(transformAttribute);
    if (scale != null) {
      scaleX = scale.x;
      scaleY = scale.y;
    }
    var translate = _getTranslate(transformAttribute);
    if (translate != null) {
      translateX = translate.x;
      translateY = translate.y;
    }
  }

  final Matrix4 matrix4 = Matrix4.identity();
  if (translateX != null && translateY != null) {
    matrix4.translate(translateX, translateY);
  }
  matrix4.scale(scaleX, scaleY);

  path = path.transform(matrix4.storage);

  return PathSvgItem(
    path: path,
    fill: _getColorFromString(fill),
  );
}

Path _pointsToPath(String points, {bool close = true}) {
  final path = Path();
  final pointList = points.trim().split(RegExp(r'[\s,]+'));
  if (pointList.length < 4) return path; // Need at least 2 points (x1, y1, x2, y2)

  for (int i = 0; i < pointList.length; i += 2) {
    final x = double.parse(pointList[i]);
    final y = double.parse(pointList[i + 1]);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  if (close) path.close();
  return path;
}

String? _getFillColor(String data) {
  RegExp regExp = RegExp(r'fill:\s*(#[a-fA-F0-9]{6})');
  RegExpMatch? match = regExp.firstMatch(data);
  return match?.group(1);
}

Color? _getColorFromString(String? colorString) {
  if (colorString == null) return null;
  if (colorString.startsWith('#')) {
    return _hexToColor(colorString);
  } else {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      default:
        return Colors.transparent;
    }
  }
}

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

({double x, double y})? _getScale(String data) {
  RegExp regExp = RegExp(r'scale\(([^,]+),([^)]+)\)');
  var match = regExp.firstMatch(data);
  if (match != null) {
    double scaleX = double.parse(match.group(1)!);
    double scaleY = double.parse(match.group(2)!);
    return (x: scaleX, y: scaleY);
  }
  return null;
}

({double x, double y})? _getTranslate(String data) {
  RegExp regExp = RegExp(r'translate\(([^,]+),([^)]+)\)');
  var match = regExp.firstMatch(data);
  if (match != null) {
    double translateX = double.parse(match.group(1)!);
    double translateY = double.parse(match.group(2)!);
    return (x: translateX, y: translateY);
  }
  return null;
}