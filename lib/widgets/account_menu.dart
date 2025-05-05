import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.isLoggedIn;

    if (!isLoggedIn) {
      return const SizedBox.shrink(); // 未ログインなら非表示
    }

    final displayName = userProvider.displayName;
    final iconUrl = userProvider.iconUrl;

    return PopupMenuButton<String>(
      icon: CircleAvatar(
        backgroundImage: iconUrl != null ? NetworkImage(iconUrl) : null,
        child: iconUrl == null ? const Icon(Icons.person) : null,
      ),
      onSelected: (value) async {
        if (value == 'settings') {
          Navigator.pushNamed(context, '/settings');
        } else if (value == 'logout') {
          await AuthService().signOut();
          userProvider.clearUser();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'display',
          enabled: false,
          child: Text(displayName),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'settings',
          child: Text('設定'),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Text('ログアウト'),
        ),
      ],
    );
  }
}
