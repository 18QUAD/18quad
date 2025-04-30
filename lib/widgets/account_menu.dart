import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountMenu extends StatefulWidget {
  const AccountMenu({super.key});

  @override
  State<AccountMenu> createState() => _AccountMenuState();
}

class _AccountMenuState extends State<AccountMenu> {
  String displayName = '-';

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          displayName = doc.data()?['name'] ?? '-';
        });
      } catch (e) {
        print('ユーザー名の取得に失敗: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Text(
            displayName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: Colors.white),
          color: Colors.black,
          onSelected: (value) async {
            if (value == 'login') {
              Navigator.pushNamed(context, '/login');
            } else if (value == 'view') {
              Navigator.pushNamed(context, '/settings', arguments: {'readOnly': true});
            } else if (value == 'edit') {
              Navigator.pushNamed(context, '/settings', arguments: {'readOnly': false});
            } else if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); // ← 修正済み
              }
            }
          },
          itemBuilder: (context) {
            if (user == null) {
              return [
                const PopupMenuItem(
                  value: 'login',
                  child: Text('ログイン', style: TextStyle(color: Colors.white)),
                ),
              ];
            } else {
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Text(user.email ?? 'ユーザー',
                      style: const TextStyle(color: Colors.white70)),
                ),
                const PopupMenuItem(
                  value: 'view',
                  child: Text('照会', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('変更', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('ログアウト', style: TextStyle(color: Colors.white)),
                ),
              ];
            }
          },
        ),
      ],
    );
  }
}
