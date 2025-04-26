import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  Future<String?> _getUserIconUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      final iconUrl = data?['iconUrl'];
      if (iconUrl is String && iconUrl.trim().isNotEmpty) {
        return iconUrl;
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserIconUrl(),
      builder: (context, snapshot) {
        final iconUrl = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            automaticallyImplyLeading: true,
            centerTitle: false,
            actions: [
              Builder(
                builder: (context) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FirebaseAuth.instance.currentUser == null
                        ? IconButton(
                            icon: const Icon(Icons.account_circle),
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                          )
                        : PopupMenuButton<String>(
                            offset: const Offset(0, 50),
                            icon: CircleAvatar(
                              radius: 14,
                              backgroundImage: (iconUrl != null && iconUrl.isNotEmpty)
                                  ? NetworkImage(iconUrl)
                                  : const AssetImage('assets/icons/default.png') as ImageProvider,
                              backgroundColor: Colors.grey[200],
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                enabled: false,
                                child: Text(FirebaseAuth.instance.currentUser?.displayName ?? '(名前未設定)'),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Text('編集'),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Text('ログアウト'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'settings') {
                                Navigator.pushNamed(context, '/settings');
                              } else if (value == 'logout') {
                                FirebaseAuth.instance.signOut();
                                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                              }
                            },
                          ),
                  );
                },
              ),
            ],
          ),
          body: child,
          floatingActionButton: floatingActionButton,
        );
      },
    );
  }
}
