import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_scaffold.dart';

class AdminCountsScreen extends StatelessWidget {
  const AdminCountsScreen({super.key});

  final String adminEmail = 'admin@example.com'; // 管理者メールをここに設定

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || currentUser.email != adminEmail) {
      return AppScaffold(
        title: 'アクセス拒否',
        child: const Center(
          child: Text(
            'この画面にアクセスする権限がありません',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    final countsRef = FirebaseFirestore.instance.collection('counts');
    final usersRef = FirebaseFirestore.instance.collection('users');

    return AppScaffold(
      title: '全ユーザー連打数一覧',
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCountsWithUsers(countsRef, usersRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          final rows = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.pink.shade700),
              dataRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.grey.shade900),
              headingTextStyle: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              dataTextStyle: const TextStyle(color: Colors.white),
              columns: const [
                DataColumn(label: Text('順位')),
                DataColumn(label: Text('名前')),
                DataColumn(label: Text('カウント')),
                DataColumn(label: Text('e-mail')),
                DataColumn(label: Text('UID')),
                DataColumn(label: Text('リセット')),
              ],
              rows: List.generate(rows.length, (index) {
                final row = rows[index];
                final uid = row['uid'];
                final count = row['count'];
                final displayName = row['displayName'] ?? '不明';
                final email = row['email'] ?? '不明';

                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(displayName)),
                  DataCell(Text('$count')),
                  DataCell(Text(email)),
                  DataCell(Text(uid.substring(0, 4) + '...' + uid.substring(uid.length - 2))),
                  DataCell(IconButton(
                    icon: const Icon(Icons.restart_alt, color: Colors.orangeAccent),
                    onPressed: () async {
                      await countsRef.doc(uid).set({'count': 0}, SetOptions(merge: true));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('「$uid」のカウントをリセットしました'),
                          backgroundColor: Colors.pink,
                        ),
                      );
                    },
                  )),
                ]);
              }),
            ),
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadCountsWithUsers(
    CollectionReference countsRef,
    CollectionReference usersRef,
  ) async {
    final countsSnapshot = await countsRef.orderBy('count', descending: true).get();
    final usersSnapshot = await usersRef.get();

    final userMap = {
      for (var doc in usersSnapshot.docs) doc.id: doc.data() as Map<String, dynamic>
    };

    final rows = countsSnapshot.docs.map((doc) {
      final uid = doc.id;
      final count = doc['count'] ?? 0;
      final userData = userMap[uid] ?? {};

      return {
        'uid': uid,
        'count': count,
        'displayName': userData['displayName'],
        'email': userData['email'],
      };
    }).toList();

    return rows;
  }
}
