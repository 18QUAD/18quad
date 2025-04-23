import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _rankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankingData();
  }

  Future<void> _loadRankingData() async {
    final countSnapshots = await FirebaseFirestore.instance
        .collection('counts')
        .orderBy('count', descending: true)
        .limit(100)
        .get();

    List<Map<String, dynamic>> rankingData = [];

    for (final doc in countSnapshots.docs) {
      final uid = doc.id;
      final count = doc.data()['count'] ?? 0;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final displayName = userDoc.data()?['displayName'] ?? '不明';
      final iconId = userDoc.data()?['iconId'] ?? 0;

      rankingData.add({
        'uid': uid,
        'displayName': displayName,
        'iconId': iconId,
        'count': count,
      });
    }

    setState(() {
      _rankings = rankingData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('ランキング')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _rankings.length,
              itemBuilder: (context, index) {
                final user = _rankings[index];
                final isCurrentUser = user['uid'] == currentUid;

                return Container(
                  color: isCurrentUser ? Colors.blue.shade900 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}位',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/icons/icon_${user['iconId']}.png'),
                        radius: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user['displayName'],
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Text(
                        '${user['count']}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
