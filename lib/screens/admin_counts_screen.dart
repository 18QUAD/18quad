import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/app_scaffold.dart';

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  late Future<List<Map<String, dynamic>>> _countsFuture;

  @override
  void initState() {
    super.initState();
    _countsFuture = _loadCountsWithUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ユーザ管理', // ← タイトルのみ変更
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _countsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
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
                  DataCell(Text('${uid.substring(0, 4)}...${uid.substring(uid.length - 2)}')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.restart_alt, color: Colors.orangeAccent),
                      onPressed: () async {
                        await _resetUserCounts(uid);
                        setState(() {
                          _countsFuture = _loadCountsWithUsers();
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
                ]);
              }),
            ),
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

    final totalDoc = FirebaseFirestore.instance
        .collection('daily_counts_users_total')
        .doc(uid);
    batch.delete(totalDoc);

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> _loadCountsWithUsers() async {
    final countsSnapshot = await FirebaseFirestore.instance
        .collection('daily_counts_users_total')
        .orderBy('count', descending: true)
        .get();

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    final userMap = {
      for (var doc in usersSnapshot.docs)
        doc.id: doc.data() as Map<String, dynamic>
    };

    return countsSnapshot.docs.map((doc) {
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
  }
}
