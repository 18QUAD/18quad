import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  Future<String?> _getUserIconUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final iconUrl = data?['iconUrl'];
      if (iconUrl is String && iconUrl.trim().isNotEmpty) {
        return iconUrl;
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserIconUrl(),
      builder: (context, snapshot) {
        final iconUrl = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(title),
            centerTitle: false,
            actions: [
              Builder(
                builder: (context) {
                  final user = FirebaseAuth.instance.currentUser;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      icon: CircleAvatar(
                        radius: 14,
                        backgroundImage: (iconUrl != null && iconUrl.isNotEmpty)
                            ? NetworkImage(iconUrl)
                            : const AssetImage('assets/icons/default.png') as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                      onSelected: (value) {
                        if (value == 'settings') {
                          Navigator.pushNamed(context, '/settings');
                        } else if (value == 'logout') {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                        } else if (value == 'login') {
                          Navigator.pushNamed(context, '/login');
                        }
                      },
                      itemBuilder: (context) {
                        if (user != null) {
                          return [
                            PopupMenuItem(
                              enabled: false,
                              child: Text(user.displayName ?? '(名前未設定)'),
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
                          ];
                        } else {
                          return [
                            const PopupMenuItem(
                              value: 'login',
                              child: Text('ログイン'),
                            ),
                          ];
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('メニュー', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('ホーム'),
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sports_handball),
                  title: const Text('連打'),
                  onTap: () {
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.leaderboard),
                  title: const Text('ランキング'),
                  onTap: () {
                    Navigator.pushNamed(context, '/ranking');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('ユーザ管理'),
                  onTap: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                ),
              ],
            ),
          ),
          body: child,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
