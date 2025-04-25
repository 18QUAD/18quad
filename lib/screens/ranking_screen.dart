import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/app_scaffold.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> rankings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      final countSnapshot = await FirebaseFirestore.instance
          .collection('counts')
          .get();

      List<Map<String, dynamic>> data = [];

      for (var doc in countSnapshot.docs) {
        final uid = doc.id;
        final count = doc.data()['count'] ?? 0;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        final displayName = userDoc.data()?['displayName'] ?? '(不明)';
        final iconUrl = userDoc.data()?['iconUrl'] ?? null;

        data.add({
          'uid': uid,
          'displayName': displayName,
          'iconUrl': iconUrl,
          'count': count,
        });
      }

      data.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      setState(() {
        rankings = data;
        isLoading = false;
      });
    } catch (e) {
      print('ランキング取得失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;
    final user = context.watch<AuthService>().currentUser;

    return AppScaffold(
      title: 'ランキング',
      user: user,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final userData = rankings[index];
                final isCurrent = userData['uid'] == currentUid;

                return Container(
                  color: isCurrent ? Colors.blue.shade900 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}位',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundImage: userData['iconUrl'] != null
                            ? NetworkImage(userData['iconUrl'])
                            : const AssetImage('assets/icons/default.png')
                                as ImageProvider,
                        radius: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          userData['displayName'],
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${userData['count']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
