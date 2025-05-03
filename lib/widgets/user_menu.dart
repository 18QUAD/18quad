import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMenu extends StatelessWidget {
  final String? iconUrl;
  final String defaultIconUrl;

  const UserMenu({
    super.key,
    required this.iconUrl,
    required this.defaultIconUrl,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      icon: CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(
          (iconUrl != null && iconUrl!.isNotEmpty)
              ? iconUrl!
              : defaultIconUrl,
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
            PopupMenuItem<String>(
              enabled: false,
              child: Text(user.displayName ?? '(名前未設定)'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('編集'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('ログアウト'),
            ),
          ];
        } else {
          return [
            const PopupMenuItem<String>(
              value: 'login',
              child: Text('ログイン'),
            ),
          ];
        }
      },
    );
  }
}
