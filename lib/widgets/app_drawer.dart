import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    // 🔓 未ログイン状態のメニュー表示
    if (uid == null) {
      return Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Icon(Icons.warning, size: 48),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('ログイン'),
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('新規登録'),
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ),
      );
    }

    // ✅ ログイン済み状態のメニュー表示
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final userData = snapshot.data!;
          final displayName = userData['displayName'] ?? '名無し';
          final isAdmin = userData['isAdmin'] == true;

          return ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_circle, size: 48),
                    const SizedBox(height: 8),
                    Text(displayName, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('ホーム'),
                onTap: () => Navigator.pushNamed(context, '/home'),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('ランキング'),
                onTap: () => Navigator.pushNamed(context, '/ranking'),
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('ユーザ管理'),
                  onTap: () => Navigator.pushNamed(context, '/adminUsers'),
                ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('設定'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          );
        },
      ),
    );
  }
}
