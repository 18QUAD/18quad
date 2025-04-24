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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Drawer(child: Center(child: Text('ログインしてください')));
    }

    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          final displayName = user['displayName'] ?? '名無し';
          final isAdmin = user['isAdmin'] == true;

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
