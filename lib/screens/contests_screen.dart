import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ContestsScreen extends StatelessWidget {
  const ContestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contests')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Contest Coming Soon! Prepare for It.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Share.share('Follow @ColorSparkApp on Instagram for contest updates! 🎨');
              },
              child: const Text('Follow Us on Instagram'),
            ),
          ],
        ),
      ),
    );
  }
}