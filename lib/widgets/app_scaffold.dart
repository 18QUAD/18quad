import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final User? user;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final String? iconUrl = user?.photoURL;
    final String? displayName = user?.displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: user == null
                ? IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  )
                : PopupMenuButton<String>(
                    icon: CircleAvatar(
                      backgroundImage: iconUrl != null
                          ? NetworkImage(iconUrl)
                          : const AssetImage('assets/icons/default.png')
                              as ImageProvider,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Text(displayName ?? '(名前未設定)'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('編集'),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('ログアウト'),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'settings') {
                        Navigator.pushNamed(context, '/settings');
                      } else if (value == 'logout') {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                      }
                    },
                  ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('メニュー', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: const Text('連打画面'),
              onTap: () => Navigator.pushNamed(context, '/home'),
            ),
            ListTile(
              title: const Text('ランキング'),
              onTap: () => Navigator.pushNamed(context, '/ranking'),
            ),
            ListTile(
              title: const Text('ユーザー管理'),
              onTap: () => Navigator.pushNamed(context, '/admin'),
            ),
          ],
        ),
      ),
      body: child,
    );
  }
}
