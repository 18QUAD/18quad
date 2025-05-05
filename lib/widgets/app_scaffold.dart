import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rennda_app/providers/user_provider.dart';
import 'package:rennda_app/widgets/app_drawer.dart';
import 'package:rennda_app/widgets/user_menu.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  static const String defaultUserIconUrl =
      'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final isLoggedIn = userProvider.currentUser != null;
        final iconUrl = userProvider.iconUrl;
        final status = userProvider.status;
        final isAdmin = userProvider.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              if (actions != null) ...actions!,
              UserMenu(
                iconUrl: iconUrl,
                defaultIconUrl: defaultUserIconUrl,
              ),
            ],
          ),
          drawer: AppDrawer(
            isLoggedIn: isLoggedIn,
            userStatus: status,
            isAdmin: isAdmin,
          ),
          body: child,
        );
      },
    );
  }
}
