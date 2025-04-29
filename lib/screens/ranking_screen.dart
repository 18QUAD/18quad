import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../services/firestore_service.dart';

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
      child: StreamBuilder(
        stream: FirestoreService.getRankingStream(), // ★ countsコレクショングループを購読
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('データが存在しません'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final parentPath = doc.reference.parent.parent;
              final uid = parentPath?.id ?? '';

              if (uid.isEmpty) {
                return const ListTile(title: Text('不明なユーザー'));
              }

              final count = doc['count'] ?? 0;

              return FutureBuilder(
                future: FirestoreService.getUserData(uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('読み込み中...'));
                  }
                  if (userSnapshot.hasError) {
                    return const ListTile(title: Text('ユーザー情報取得エラー'));
                  }

                  final userData = userSnapshot.data;
                  final displayName = userData?['displayName'] ?? '名無し';
                  final iconUrl = userData?['iconUrl'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: iconUrl != null
                          ? NetworkImage(iconUrl)
                          : const AssetImage('assets/icons/default.png') as ImageProvider,
                    ),
                    title: Text(displayName, style: AppTextStyles.body),
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
