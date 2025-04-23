// lib/widgets/navigation_menu.dart
import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      color: Colors.black,
      onSelected: (value) {
        if (value == 'home') {
          Navigator.pushNamed(context, '/home');
        } else if (value == 'ranking') {
          Navigator.pushNamed(context, '/ranking');
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'home',
          child: Text('連打入力', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem(
          value: 'ranking',
          child: Text('ランキング', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
