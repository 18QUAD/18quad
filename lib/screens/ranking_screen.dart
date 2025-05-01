import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../widgets/app_scaffold.dart';
import '../services/firestore_service.dart';
import '../theme/text_styles.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _myGroupId;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCurrentUserGroup();
  }

  Future<void> _loadCurrentUserGroup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await FirestoreService.getUserData(uid);
      setState(() {
        _myGroupId = data?['groupId'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ランキング',
      child: Column(
        children: [
          _buildDateSelector(),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '個人ランキング'),
              Tab(text: 'グループランキング'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIndividualRanking(),
                _buildGroupRanking(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('日付選択: '),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(_selectedDate),
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            },
            child: Text(_selectedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualRanking() {
    return StreamBuilder(
      stream: FirestoreService.getDailyRankingStream(_selectedDate),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('ランキングの取得に失敗しました'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('まだ誰も連打していません'));
        }

        final currentUid = FirebaseAuth.instance.currentUser?.uid;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final uid = doc['uid'] ?? '';
            final count = doc['count'] ?? 0;
            final rank = index + 1;

            if (uid.isEmpty) return const ListTile(title: Text('不明なユーザー'));

            return FutureBuilder(
              future: FirestoreService.getUserData(uid),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('読み込み中...'));
                }
                final user = userSnapshot.data!;
                final name = user['displayName'] ?? '名無し';
                final iconUrl = user['iconUrl'];
                final groupId = user['groupId'] ?? '';
                final isMyRow = uid == currentUid;

                return FutureBuilder(
                  future: FirestoreService.getGroupName(groupId),
                  builder: (context, groupSnapshot) {
                    final groupName = groupSnapshot.data ?? '（無所属）';
                    return Container(
                      color: isMyRow ? Colors.yellow[100] : null,
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$rank.', style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundImage: iconUrl != null
                                  ? NetworkImage(iconUrl)
                                  : const AssetImage('assets/icons/default.png') as ImageProvider,
                            ),
                          ],
                        ),
                        title: Text('$name（$groupName）', style: AppTextStyles.body),
                        trailing: Text('$count', style: AppTextStyles.label),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGroupRanking() {
    return const Center(
      child: Text('グループランキングは今後のアップデートで対応予定です'),
    );
  }
}
