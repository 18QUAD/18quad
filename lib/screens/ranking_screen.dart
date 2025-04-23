// lib/screens/ranking_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
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

        final name = userDoc.data()?['name'] ?? '(不明)';

        data.add({
          'uid': uid,
          'name': name,
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
    return AppScaffold(
      title: 'ランキング',
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : ListView.builder(
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final entry = rankings[index];
                return ListTile(
                  title: Text('${index + 1}位：${entry['name']}',
                      style: const TextStyle(color: Colors.white)),
                  trailing: Text('${entry['count']}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                );
              },
            ),
    );
  }
}
