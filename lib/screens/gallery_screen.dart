// screens/gallery_screen.dart
import 'package:flutter/material.dart';
import '../models/coloring_page.dart';
import '../models/user_progress.dart';
import '../models/badge.dart' as app_badge;
import '../utils/storage_manager.dart';
import '../widgets/svg_preview.dart';
import 'reward_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProgress? _userProgress;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await StorageManager.getProgress();
      setState(() {
        _userProgress = progress;
      });
    } catch (e) {
      debugPrint('Error loading progress: $e');
      setState(() {
        _userProgress = UserProgress();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildWorks() {
    final works = <Map<String, dynamic>>[];
    final coloredParts = _userProgress?.coloredParts ?? {};

    for (var page in pages) {
      final pageColors = coloredParts[page.id];
      if (pageColors == null || pageColors.isEmpty) continue;

      final isCompleted = pageColors.length == page.partsCount;

      works.add({
        'page': page,
        'status': isCompleted ? 'Completed' : 'In Progress',
      });
    }

    return works;
  }

  @override
  Widget build(BuildContext context) {
    if (_userProgress == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final works = _buildWorks();
    final earnedBadges = _userProgress?.badges ?? [];

    return Column(
      children: [
        Container(
          color: Colors.pinkAccent,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Works'),
              Tab(text: 'Achievements'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Works Tab
              works.isEmpty
                  ? const Center(
                      child: Text(
                        'No works yet. Start coloring!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: works.length,
                      itemBuilder: (context, index) {
                        final work = works[index];
                        final page = work['page'] as ColoringPage;
                        final status = work['status'] as String;

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: SvgPreview(
                              svgPath: page.svgPath,
                              applyGreyFilter: status != 'Completed',
                            ),
                            title: Text(
                              '${page.category} - Page ${page.id} ($status)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              status == 'Completed'
                                  ? 'Completed on ${DateTime.now().toString().split(' ')[0]}'
                                  : 'In Progress',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      },
                    ),
              // Achievements Tab
              GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: app_badge.allBadges.length,
                itemBuilder: (context, index) {
                  final badge = app_badge.allBadges[index];
                  final isEarned = earnedBadges.contains(badge.id);

                  return GestureDetector(
                    onTap: () {
                      if (isEarned) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RewardScreen(badge: badge),
                          ),
                        );
                      }
                    },
                    child: Opacity(
                      opacity: isEarned ? 1.0 : 0.3,
                      child: Card(
                        elevation: isEarned ? 5 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              badge.imagePath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              badge.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}