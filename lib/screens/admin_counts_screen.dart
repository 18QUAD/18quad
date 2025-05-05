import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';
import 'user_add_dialog.dart';

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ユーザ管理',
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.pink,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => UserAddDialog(
                onUserAdded: () {
                  setState(() {
                    _usersFuture = _loadUsers();
                  });
                },
              ),
            );
          },
          child: const Text('追加'),
        ),
      ],
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          final users = snapshot.data!;

          if (users.isEmpty) {
            return const Center(child: Text('ユーザが存在しません'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final uid = user['uid'];
              final name = user['displayName'] ?? '不明';
              final email = user['email'] ?? '不明';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(
                    '$email\nUID: ${uid.substring(0, 4)}...${uid.substring(uid.length - 2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restart_alt, color: Colors.orange),
                    onPressed: () async {
                      await _resetUserCounts(uid);
                      setState(() {
                        _usersFuture = _loadUsers();
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('「$uid」のカウントをリセットしました'),
                            backgroundColor: Colors.pink,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _resetUserCounts(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final countsQuery = await FirebaseFirestore.instance
        .collection('daily_counts')
        .where('uid', isEqualTo: uid)
        .get();

    for (var doc in countsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt')
        .get();

    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'displayName': data['displayName'],
        'email': data['email'],
      };
    }).toList();
  }
}
