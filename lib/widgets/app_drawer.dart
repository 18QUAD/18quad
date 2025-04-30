import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final String userStatus;
  final bool isAdmin;

  const AppDrawer({
    super.key,
    required this.isLoggedIn,
    required this.userStatus,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            enabled: isAdmin,
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('ユーザ管理'),
            onTap: isAdmin ? () => Navigator.pushNamed(context, '/admin') : null,
          ),
          const Divider(),
          ListTile(
            enabled: isLoggedIn && userStatus == 'none',
            leading: const Icon(Icons.group_add),
            title: const Text('グループ作成'),
            onTap: isLoggedIn && userStatus == 'none'
                ? () => Navigator.pushNamed(context, '/groupCreate')
                : null,
          ),
          ListTile(
            enabled: isLoggedIn && userStatus == 'none',
            leading: const Icon(Icons.input),
            title: const Text('グループリクエスト'),
            onTap: isLoggedIn && userStatus == 'none'
                ? () => Navigator.pushNamed(context, '/groupRequest')
                : null,
          ),
          ListTile(
            enabled: isLoggedIn && userStatus == 'manager',
            leading: const Icon(Icons.group),
            title: const Text('グループ管理'),
            onTap: isLoggedIn && userStatus == 'manager'
                ? () => Navigator.pushNamed(context, '/groupManage')
                : null,
          ),
          ListTile(
            enabled: isLoggedIn && userStatus == 'manager',
            leading: const Icon(Icons.assignment_ind),
            title: const Text('参加リクエスト管理'),
            onTap: isLoggedIn && userStatus == 'manager'
                ? () => Navigator.pushNamed(context, '/adminGroupRequests')
                : null,
          ),
        ],
      ),
    );
  }
}
