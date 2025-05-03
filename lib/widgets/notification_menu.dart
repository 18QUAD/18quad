import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;

class NotificationMenu extends StatefulWidget {
  const NotificationMenu({super.key});

  @override
  State<NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _unreadNotices = [];

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();
  }

  Future<void> _loadUnreadNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('toUid', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    setState(() {
      _unreadNotices = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      icon: badges.Badge(
        showBadge: _unreadNotices.isNotEmpty,
        badgeContent: Text(
          '${_unreadNotices.length}',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        position: badges.BadgePosition.topEnd(top: -4, end: -4),
        child: const Icon(Icons.notifications),
      ),
      itemBuilder: (context) {
        if (_unreadNotices.isEmpty) {
          return [
            const PopupMenuItem<String>(
              enabled: false,
              child: Text('通知はありません'),
            ),
          ];
        }

        return _unreadNotices.map((doc) {
          final data = doc.data();
          return PopupMenuItem<String>(
            enabled: true,
            child: Text(data['message'] ?? '（内容なし）'),
            onTap: () async {
              await doc.reference.update({'isRead': true});
              setState(() {
                _unreadNotices.remove(doc);
              });
            },
          );
        }).toList();
      },
    );
  }
}
