import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/user_provider.dart';

class NotificationMenu extends StatelessWidget {
  const NotificationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      return const Icon(Icons.notifications_none);
    }

    final uid = currentUser.uid;
    final stream = FirebaseFirestore.instance
        .collection('notifications')
        .where('toUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final unreadNotices = snapshot.data?.docs ?? [];

        return PopupMenuButton<String>(
          offset: const Offset(0, 50),
          icon: badges.Badge(
            showBadge: unreadNotices.isNotEmpty,
            badgeContent: Text(
              '${unreadNotices.length}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            position: badges.BadgePosition.topEnd(top: -4, end: -4),
            child: const Icon(Icons.notifications),
          ),
          itemBuilder: (context) {
            if (unreadNotices.isEmpty) {
              return [
                const PopupMenuItem<String>(
                  enabled: false,
                  child: Text('通知はありません'),
                ),
              ];
            }

            return unreadNotices.map((doc) {
              final data = doc.data();
              return PopupMenuItem<String>(
                enabled: true,
                child: Text(data['message'] ?? '（内容なし）'),
                onTap: () async {
                  await doc.reference.update({'isRead': true});
                },
              );
            }).toList();
          },
        );
      },
    );
  }
}
