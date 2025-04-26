import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_scaffold.dart';
import '../services/firestore_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ランキング',
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getRankingStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final count = doc['count'] ?? 0;
              final rank = index + 1;
              return ListTile(
                leading: Text(
                  '$rank位',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                title: FutureBuilder<Map<String, dynamic>?>(
                  future: FirestoreService.getUserData(doc.id),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Text('読み込み中...');
                    }
                    final userData = userSnapshot.data;
                    final displayName = userData?['displayName'] ?? '名無し';
                    return Text(displayName);
                  },
                ),
                trailing: Text('$count回'),
              );
            },
          );
        },
      ),
    );
  }
}
