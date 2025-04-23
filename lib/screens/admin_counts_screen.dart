// lib/screens/admin_counts_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_scaffold.dart';

class AdminCountsScreen extends StatelessWidget {
  const AdminCountsScreen({super.key});

  final String adminEmail = 'admin@example.com'; // ← あなたの管理者メールに変更

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
      child: StreamBuilder<QuerySnapshot>(
        stream: countsRef.orderBy('count', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.pink),
            );
          }

          final countDocs = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.pink.shade700),
              dataRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.grey.shade900),
              headingTextStyle:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              dataTextStyle: const TextStyle(color: Colors.white),
              columns: const [
                DataColumn(label: Text('順位')),
                DataColumn(label: Text('名前')),
                DataColumn(label: Text('カウント')),
                DataColumn(label: Text('e-mail')),
                DataColumn(label: Text('UID')),
                DataColumn(label: Text('リセット')),
              ],
              rows: List<DataRow>.generate(countDocs.length, (index) {
                final countDoc = countDocs[index];
                final uid = countDoc.id;
                final count = countDoc['count'] ?? 0;
                final rank = index + 1;

                return DataRow(cells: [
                  DataCell(Text('$rank')),
                  DataCell(FutureBuilder<DocumentSnapshot>(
                    future: usersRef.doc(uid).get(),
                    builder: (context, userSnap) {
                      final data = userSnap.data?.data() as Map<String, dynamic>?;
                      final name = data?['name'] ?? '不明';
                      return Text(name);
                    },
                  )),
                  DataCell(Text('$count')),
                  DataCell(FutureBuilder<DocumentSnapshot>(
                    future: usersRef.doc(uid).get(),
                    builder: (context, userSnap) {
                      final data = userSnap.data?.data() as Map<String, dynamic>?;
                      final email = data?['email'] ?? '不明';
                      return Text(email);
                    },
                  )),
                  DataCell(Text(uid.substring(0, 6) + '...')),
                  DataCell(IconButton(
                    icon: const Icon(Icons.restart_alt, color: Colors.orangeAccent),
                    onPressed: () async {
                      await countsRef.doc(uid).set({'count': 0});
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
}
