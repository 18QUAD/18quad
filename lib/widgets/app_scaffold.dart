import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'account_menu.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [AccountMenu()],
        backgroundColor: Colors.pink,
      ),
      drawer: const MainMenu(),
      body: child,
    );
  }
}
