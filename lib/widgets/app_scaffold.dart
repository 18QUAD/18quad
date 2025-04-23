import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (user != null)
            FutureBuilder<AppUser?>(
              future: UserService.fetchUser(user.uid),
              builder: (context, snapshot) {
                final appUser = snapshot.data;
                final iconUrl = appUser?.iconUrl ?? '';

                return _buildUserMenu(
                  context,
                  iconImage: iconUrl.isNotEmpty
                      ? NetworkImage(iconUrl)
                      : const AssetImage('assets/icons/default.png') as ImageProvider,
                  isLoggedIn: true,
                );
              },
            )
          else
            _buildUserMenu(
              context,
              iconImage: const AssetImage('assets/icons/default.png'),
              isLoggedIn: false,
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('メニュー', style: Theme.of(context).textTheme.headlineSmall),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('タイトル'),
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('ランキング'),
              onTap: () => Navigator.pushNamed(context, '/ranking'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
      body: child,
    );
  }

  Widget _buildUserMenu(BuildContext context,
      {required ImageProvider iconImage, required bool isLoggedIn}) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundImage: iconImage,
        radius: 16,
      ),
      onSelected: (value) {
        switch (value) {
          case 'login':
            Navigator.pushNamed(context, '/login');
            break;
          case 'register':
            Navigator.pushNamed(context, '/register');
            break;
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'logout':
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/');
            break;
        }
      },
      itemBuilder: (context) {
        if (isLoggedIn) {
          return [
            const PopupMenuItem(value: 'settings', child: Text('ユーザー設定')),
            const PopupMenuItem(value: 'logout', child: Text('ログアウト')),
          ];
        } else {
          return [
            const PopupMenuItem(value: 'login', child: Text('ログイン')),
            const PopupMenuItem(value: 'register', child: Text('新規登録')),
          ];
        }
      },
    );
  }
}
