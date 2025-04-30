import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_scaffold.dart';

class AdminGroupRequestsScreen extends StatefulWidget {
  const AdminGroupRequestsScreen({super.key});

  @override
  State<AdminGroupRequestsScreen> createState() => _AdminGroupRequestsScreenState();
}

class _AdminGroupRequestsScreenState extends State<AdminGroupRequestsScreen> {
  String? _groupId;
  String? _groupName;

  @override
  void initState() {
    super.initState();
    _loadGroupInfo();
  }

  Future<void> _loadGroupInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final gid = userDoc.data()?['groupId'];
    if (gid == null) return;

    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(gid).get();
    final name = groupDoc.data()?['name'];

    setState(() {
      _groupId = gid;
      _groupName = name ?? '不明なグループ';
    });
  }

  Future<Map<String, dynamic>> _getUserInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      return {
        'displayName': data?['displayName'] ?? uid,
        'iconUrl': data?['iconUrl'] ?? '',
      };
    } catch (_) {
      return {
        'displayName': uid,
        'iconUrl': '',
      };
    }
  }

  Future<void> _approveRequest(String requesterId, String requestDocPath) async {
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(requesterId);
    final requestRef = FirebaseFirestore.instance.doc(requestDocPath);

    batch.update(userRef, {
      'groupId': _groupId,
      'status': 'member',
    });

    batch.update(requestRef, {
      'status': 'approved',
    });

    await batch.commit();

    await FirebaseFirestore.instance.collection('notifications').add({
      'toUid': requesterId,
      'message': '$_groupName のグループ参加申請が承認されました',
      'timestamp': Timestamp.now(),
      'isRead': false,
    });

    setState(() {});
  }

  Future<void> _rejectRequest(String requestDocPath) async {
    final requestRef = FirebaseFirestore.instance.doc(requestDocPath);
    final requestDoc = await requestRef.get();
    final data = requestDoc.data() as Map<String, dynamic>?;
    final requesterId = data?['requesterId'];

    await requestRef.update({'status': 'rejected'});

    if (requesterId != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'toUid': requesterId,
        'message': '$_groupName のグループ参加申請が却下されました',
        'timestamp': Timestamp.now(),
        'isRead': false,
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループ参加リクエスト管理',
      child: _groupId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collectionGroup('group_requests')
                  .where('groupId', isEqualTo: _groupId)
                  .where('status', isEqualTo: 'pending')
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!.docs;

                if (requests.isEmpty) {
                  return const Center(child: Text('現在、申請中のリクエストはありません。'));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final requesterId = data['requesterId'] ?? '';
                    final message = data['message'] ?? '（メッセージなし）';
                    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                    final requestPath = requests[index].reference.path;

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _getUserInfo(requesterId),
                      builder: (context, snapshot) {
                        final userInfo = snapshot.data ?? {};
                        final displayName = userInfo['displayName'] ?? requesterId;
                        final iconUrl = userInfo['iconUrl'] ?? '';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: iconUrl.isNotEmpty
                                      ? NetworkImage(iconUrl)
                                      : null,
                                  child: iconUrl.isEmpty ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(message),
                                      const SizedBox(height: 6),
                                      if (createdAt != null)
                                        Text('申請日時: ${createdAt.toLocal()}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            label: const Text('承認'),
                                            onPressed: () => _approveRequest(requesterId, requestPath),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton.icon(
                                            icon: const Icon(Icons.clear, color: Colors.red),
                                            label: const Text('却下'),
                                            onPressed: () => _rejectRequest(requestPath),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
