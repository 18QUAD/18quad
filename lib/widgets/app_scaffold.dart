import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_drawer.dart';
import 'user_menu.dart';
import 'notification_menu.dart';

class AppScaffold extends StatefulWidget {
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

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const String defaultUserIconUrl =
      'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

  Future<String?> _getUserIconUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['iconUrl'];
  }

  Future<String> _getUserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'none';
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['status'] ?? 'none';
  }

  Future<bool> _isAdminUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _getUserIconUrl().catchError((e) {
          print('[AppScaffold] iconUrl error: $e');
          return null;
        }),
        _getUserStatus().catchError((e) {
          print('[AppScaffold] status error: $e');
          return 'none';
        }),
        _isAdminUser().catchError((e) {
          print('[AppScaffold] admin error: $e');
          return false;
        }),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final iconUrl = snapshot.data![0] as String?;
        final String userStatus = snapshot.data![1] as String;
        final bool isAdmin = snapshot.data![2] as bool;

        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(widget.title),
            centerTitle: false,
            actions: [
              if (widget.actions != null) ...widget.actions!,
              const NotificationMenu(),
              UserMenu(
                iconUrl: iconUrl,
                defaultIconUrl: defaultUserIconUrl,
              ),
            ],
          ),
          drawer: AppDrawer(
            isLoggedIn: isLoggedIn,
            userStatus: userStatus,
            isAdmin: isAdmin,
          ),
          body: widget.child,
          floatingActionButton: widget.floatingActionButton,
        );
      },
    );
  }
}
