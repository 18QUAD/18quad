import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.actions,
  });

  // ✅ 正しいデフォルトアイコンURLに修正
  static const String defaultUserIconUrl =
      'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

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

  Future<String> _getUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'none';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final status = data?['status'];
      if (status is String && status.isNotEmpty) {
        return status;
      }
    } catch (_) {}
    return 'none';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _getUserIconUrl(),
        _getUserStatus(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final iconUrl = snapshot.data![0] as String?;
        final String userStatus = snapshot.data![1] as String;

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
              if (actions != null) ...actions!,
              Builder(
                builder: (context) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, 50),
                      icon: CircleAvatar(
                        radius: 14,
                        backgroundImage: NetworkImage(
                          (iconUrl != null && iconUrl.isNotEmpty)
                              ? iconUrl
                              : defaultUserIconUrl,
                        ),
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
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('メニュー', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('ホーム'),
                  onTap: () => Navigator.pushNamed(context, '/'),
                ),
                ListTile(
                  leading: const Icon(Icons.sports_handball),
                  title: const Text('連打'),
                  onTap: () => Navigator.pushNamed(context, '/home'),
                ),
                ListTile(
                  leading: const Icon(Icons.leaderboard),
                  title: const Text('ランキング'),
                  onTap: () => Navigator.pushNamed(context, '/ranking'),
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('ユーザ管理'),
                  onTap: () => Navigator.pushNamed(context, '/admin'),
                ),
                const Divider(),
                ListTile(
                  enabled: isLoggedIn && userStatus == 'none',
                  leading: const Icon(Icons.group_add),
                  title: const Text('グループ作成'),
                  onTap: (isLoggedIn && userStatus == 'none')
                      ? () => Navigator.pushNamed(context, '/groupCreate')
                      : null,
                ),
                ListTile(
                  enabled: isLoggedIn && userStatus == 'none',
                  leading: const Icon(Icons.input),
                  title: const Text('グループリクエスト'),
                  onTap: (isLoggedIn && userStatus == 'none')
                      ? () => Navigator.pushNamed(context, '/groupRequest')
                      : null,
                ),
                ListTile(
                  enabled: isLoggedIn && userStatus == 'member',
                  leading: const Icon(Icons.group),
                  title: const Text('グループ管理'),
                  onTap: (isLoggedIn && userStatus == 'member')
                      ? () => Navigator.pushNamed(context, '/groupManage')
                      : null,
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
