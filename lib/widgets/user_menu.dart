import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rennda_app/providers/user_provider.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  static const String _defaultIconUrl = 'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final iconUrl = context.watch<UserProvider>().iconUrl ?? _defaultIconUrl;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      icon: CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(iconUrl),
        backgroundColor: Colors.grey[200],
      ),
      onSelected: (value) async {
        if (value == 'settings') {
          Navigator.pushNamed(context, '/settings');
        } else if (value == 'logout') {
          await context.read<UserProvider>().logout(context);
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
