// screens/coloring_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/coloring_page.dart';
import '../utils/history_manager.dart';
import '../utils/progress_manager.dart';
import '../utils/svg_parser.dart'; // Import svg_parser.dart
import '../utils/svg_geometry_parser.dart'; // Import svg_geometry_parser.dart
import '../widgets/color_palette.dart';
import '../widgets/svg_painter.dart';

class ColoringScreen extends StatefulWidget {
  final ColoringPage page;

  const ColoringScreen({super.key, required this.page});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen>
    with SingleTickerProviderStateMixin, HistoryManager<List<EnhancedPathSvgItem>> {
  Size? _size;
  List<EnhancedPathSvgItem> _items = [];
  Color selectedColor = Colors.red;
  bool showFunFact = false;
  bool isNumbered = true;
  late ConfettiController _confettiController;
  late ProgressManager _progressManager;
  int? _highlightedIndex;
  late AnimationController _highlightAnimation;
  late Animation<double> _highlightOpacity;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _highlightAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _highlightOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _highlightAnimation, curve: Curves.easeInOut),
    );
    _progressManager = ProgressManager();
    _loadProgress();
    _init();
  }

  Future<void> _loadProgress() async {
    await _progressManager.loadProgress();
    setState(() {
      isNumbered = _progressManager.isNumbered(widget.page, 5);
      _progressManager.applySavedColors(_items, widget.page.id, setState);
    });
  }

  Future<void> _init() async {
    try {
      final vectorImage = await getVectorImageFromAsset(widget.page.svgPath);
      final enhancedItems = await enhanceVectorImage(vectorImage);
      setState(() {
        _size = vectorImage.size ?? const Size(300, 400);
        _items = enhancedItems;
        widget.page.partsCount = _items.length;
        saveToHistory(_items);
        _highlightedIndex = _findNextUncoloredIndex();
        _progressManager.applySavedColors(_items, widget.page.id, setState);
      });
    } catch (e) {
      debugPrint('Error initializing coloring page: $e');
      setState(() {
        _size = const Size(300, 400);
      });
    }
  }

  void _onTap(int index) {
    debugPrint('Tapped on index: $index, applying color: $selectedColor');
    saveToHistory(_items);
    setState(() {
      _items[index] = _items[index].copyWith(
        originalItem: _items[index].originalItem.copyWith(fill: selectedColor),
      );
      debugPrint('Updated item at index $index with fill: ${_items[index].fill}');

      if (_items.every((item) => item.fill != null)) {
        debugPrint('All parts colored, showing fun fact');
        showFunFact = true;
        _progressManager.saveProgress(widget.page, _items);
        _confettiController.play();
      }
      _highlightedIndex = _findNextUncoloredIndex();
    });
  }

  int? _findNextUncoloredIndex() {
    if (isNumbered) return null;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].fill == null) return i;
    }
    return null;
  }

  void _undo() {
    final previousState = undo();
    if (previousState != null) {
      setState(() {
        _items = List.from(previousState);
        _highlightedIndex = _findNextUncoloredIndex();
      });
    }
  }

  void _redo() {
    final nextState = redo();
    if (nextState != null) {
      setState(() {
        _items = List.from(nextState);
        _highlightedIndex = _findNextUncoloredIndex();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _highlightAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_size == null || _items.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.page.category),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: Center(
                    child: FittedBox(
                      child: SizedBox(
                        width: _size!.width,
                        height: _size!.height,
                        child: Stack(
                          children: [
                            // Render each path
                            for (int index = 0; index < _items.length; index++)
                              SvgPainterImage(
                                item: _items[index],
                                onTap: () => _onTap(index),
                              ),
                            // Highlight the next uncolored region in non-numbered mode
                            if (!isNumbered && _highlightedIndex != null)
                              AnimatedBuilder(
                                animation: _highlightOpacity,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: HighlightPainter(
                                      path: _items[_highlightedIndex!].path,
                                      opacity: _highlightOpacity.value,
                                    ),
                                  );
                                },
                              ),
                            // Numbered labels in numbered mode
                            if (isNumbered)
                              ..._items.asMap().entries.map((entry) {
                                final index = entry.key;
                                final path = entry.value.path;
                                final bounds = path.getBounds();
                                final centroidX = bounds.left + bounds.width / 2;
                                final centroidY = bounds.top + bounds.height / 2;

                                return Positioned(
                                  left: centroidX - 15,
                                  top: centroidY - 15,
                                  child: GestureDetector(
                                    onTap: () => _onTap(index),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _items[index].fill != null
                                            ? Colors.transparent
                                            : Colors.white.withAlpha(179),
                                        border: Border.all(
                                          color: Colors.black54,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Undo/Redo buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.undo, color: Colors.grey),
                      onPressed: canUndo ? _undo : null,
                      tooltip: 'Undo',
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.redo, color: Colors.grey),
                      onPressed: canRedo ? _redo : null,
                      tooltip: 'Redo',
                    ),
                  ],
                ),
              ),
              // Color palette
              ColorPalette(
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                    debugPrint('Selected color: $selectedColor');
                  });
                },
                selectedColor: selectedColor,
              ),
            ],
          ),
          // Confetti effect on completion
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              Colors.pink,
              Colors.yellow,
              Colors.green,
              Colors.blue,
            ],
            shouldLoop: false,
            numberOfParticles: 50,
            minBlastForce: 10,
            maxBlastForce: 50,
          ),
          // Fun fact dialog on completion
          if (showFunFact)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 40,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.page.funFact,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Library',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HighlightPainter extends CustomPainter {
  final Path path;
  final double opacity;

  const HighlightPainter({required this.path, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HighlightPainter oldDelegate) {
    return opacity != oldDelegate.opacity || path != oldDelegate.path;
  }
}