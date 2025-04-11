// models/coloring_page.dart

class ColoringPage {
  final String id;
  final String category;
  final String svgPath;
  final String funFact;
  final bool isNumbered;
  int partsCount;

  ColoringPage({
    required this.id,
    required this.category,
    required this.svgPath,
    required this.funFact,
    required this.isNumbered,
    this.partsCount = 0, // Updated dynamically when parsing SVG
  });

  @override
  String toString() {
    return 'ColoringPage(id: $id, category: $category, partsCount: $partsCount)';
  }
}

final Map<String, List<ColoringPage>> pagesByCategory = {
  'Animals': [
    ColoringPage(
      id: '1',
      category: 'Animals',
      svgPath: 'assets/coloring_pages/parrot.svg',
      funFact: 'Parrots can live up to 50 years and are known for mimicking sounds!',
      isNumbered: true,
    ),
    ColoringPage(
      id: '2',
      category: 'Animals',
      svgPath: 'assets/coloring_pages/unicorn.svg',
      funFact: 'Unicorns are mythical creatures often symbolizing purity and magic!',
      isNumbered: true,
    ),
    ColoringPage(
      id: '3',
      category: 'Animals',
      svgPath: 'assets/coloring_pages/baby_dragon.svg',
      funFact: 'Dragons in mythology are often depicted as fire-breathing creatures!',
      isNumbered: true,
    ),
    ColoringPage(
      id: '4',
      category: 'Animals',
      svgPath: 'assets/coloring_pages/mermaid.svg',
      funFact: 'Mermaids are legendary beings said to live in the ocean and sing enchanting songs!',
      isNumbered: true,
    ),
  ],
};

final List<ColoringPage> pages = pagesByCategory.values.expand((pages) => pages).toList();