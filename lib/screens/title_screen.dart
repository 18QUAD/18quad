import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '18QUAD',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/18quad_logo.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.flash_on),
              label: const Text('連打入力'),
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.bar_chart),
              label: const Text('ランキング'),
              onPressed: () {
                Navigator.pushNamed(context, '/ranking');
              },
            ),
          ],
        ),
      ),
    );
  }
}
