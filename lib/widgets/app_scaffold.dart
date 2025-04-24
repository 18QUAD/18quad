import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? drawer; // ← Drawerパラメータを追加

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.drawer, // ← optionalにする
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: drawer, // ← ここで適用
      body: child,
    );
  }
}