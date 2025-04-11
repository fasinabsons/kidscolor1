import 'package:flutter/material.dart';
import '../utils/ad_manager.dart';

class ShopScreen extends StatelessWidget {
  final bool isParent;

  const ShopScreen({super.key, required this.isParent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ColorSpark Shop'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (!isParent)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/coin_icon.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Coins: 250',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                padding: const EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildShopItem(
                    context,
                    'assets/glitter_pack.png',
                    'Glitter Pack',
                    isParent ? '\$1.99' : '100 Coins',
                    () => _showPurchaseDialog(context),
                  ),
                  if (isParent)
                    _buildShopItem(
                      context,
                      'assets/crayon_set.png',
                      'Crayon Set',
                      '\$9.99',
                      () => _showPurchaseDialog(context),
                    ),
                  _buildShopItem(
                    context,
                    'assets/neon_pack.png',
                    'Neon Colors',
                    isParent ? '\$0.99' : '50 Coins',
                    () => _showPurchaseDialog(context),
                  ),
                  if (!isParent)
                    _buildShopItem(
                      context,
                      'assets/mega_pack.png',
                      'Mega Pack',
                      '150 Coins',
                      () => _showPurchaseDialog(context),
                    ),
                ],
              ),
            ),
            if (!isParent)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    AdManager.showRewardedAd(onReward: (reward) {
                      // Add coins logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('+$reward Coins!')),
                      );
                    });
                  },
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Watch Ad for 50 Coins'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            if (isParent) AdManager.getBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, String image, String title,
      String price, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: const Text('Are you sure you want to buy this item?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add purchase logic
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase Successful!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}