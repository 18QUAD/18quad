import 'package:flutter/material.dart';
import 'package:rennda_app/widgets/app_drawer.dart';
import 'package:rennda_app/widgets/user_menu.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (actions != null) ...actions!,
          const UserMenu(),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
