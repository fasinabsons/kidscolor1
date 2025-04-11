// widgets/svg_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgPreview extends StatelessWidget {
  final String svgPath;
  final bool applyGreyFilter;
  final double width;
  final double height;

  const SvgPreview({
    super.key,
    required this.svgPath,
    this.applyGreyFilter = false,
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        svgPath,
        fit: BoxFit.contain,
        colorFilter: applyGreyFilter
            ? const ColorFilter.mode(Colors.grey, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}