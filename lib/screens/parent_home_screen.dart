import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shop_screen.dart';
import 'contests_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  ParentHomeScreenState createState() => ParentHomeScreenState();
}

class ParentHomeScreenState extends State<ParentHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> completedPages = [];
  List<String> badges = [];
  String childName = 'Alex';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadChildProgress();
  }

  void loadChildProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedPages = prefs.getStringList('completedPages') ?? [];
      badges = prefs.getStringList('badges') ?? [];
      childName = prefs.getString('childName') ?? 'Alex';
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$childName’s Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShopScreen(isParent: true)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContestsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Works'),
              Tab(text: 'Achievements'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Works Tab
                ListView.builder(
                  itemCount: completedPages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.image),
                      title: Text('Completed: ${completedPages[index]}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              Share.share('Check out my child’s work on ColorSpark! 🎨');
                            },
                          ),
                          const Icon(Icons.check_circle, color: Colors.green),
                        ],
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
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(badges[index]),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              Share.share('My child earned the ${badges[index]} badge on ColorSpark! 🎨');
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}