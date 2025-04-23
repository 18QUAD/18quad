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
            const Icon(Icons.warning_rounded, size: 100, color: Colors.white),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              icon: const Icon(Icons.flash_on),
              label: const Text('連打入力'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/ranking'),
              icon: const Icon(Icons.bar_chart),
              label: const Text('ランキング'),
            ),
          ],
        ),
      ),
    );
  }
}
