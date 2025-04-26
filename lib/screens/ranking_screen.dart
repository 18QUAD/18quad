import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ランキング',
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('counts').orderBy('count', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final uid = doc.id;
              final count = doc['count'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('読み込み中...'));
                  }

                  final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final displayName = userData?['displayName'] ?? '名無し';
                  final iconUrl = userData?['iconUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: iconUrl != null
                          ? NetworkImage(iconUrl)
                          : const AssetImage('assets/icons/default.png') as ImageProvider,
                    ),
                    title: Text('$displayName', style: AppTextStyles.body),
                    trailing: Text('$count', style: AppTextStyles.label),
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
