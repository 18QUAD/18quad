import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Widget _buildIndividualRanking() {
    return StreamBuilder(
      stream: FirestoreService.getRankingStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        final currentUid = FirebaseAuth.instance.currentUser?.uid;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final parentPath = doc.reference.parent.parent;
            final uid = parentPath?.id ?? '';
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
    return FutureBuilder(
      future: _fetchGroupRankings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final groupList = snapshot.data!;

        return ListView.builder(
          itemCount: groupList.length,
          itemBuilder: (context, index) {
            final rank = index + 1;
            final group = groupList[index];
            final isMyGroup = group['groupId'] == _myGroupId;

            return Container(
              color: isMyGroup ? Colors.yellow[100] : null,
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rank.', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundImage: group['iconUrl'] != null
                          ? NetworkImage(group['iconUrl'])
                          : const AssetImage('assets/icons/default.png') as ImageProvider,
                    ),
                  ],
                ),
                title: Text(group['name'], style: AppTextStyles.body),
                subtitle: Text('人数: ${group['memberCount']}　平均: ${group['avg'].toStringAsFixed(1)}'),
                trailing: Text('${group['total']}', style: AppTextStyles.label),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchGroupRankings() async {
    final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final groupMap = <String, List<int>>{};
    final groupMeta = <String, Map<String, dynamic>>{};

    for (var userDoc in userSnapshot.docs) {
      final uid = userDoc.id;
      final groupId = userDoc.data()['groupId'];
      if (groupId == null || groupId == '') continue;

      final countDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('counts')
          .doc(uid)
          .get();
      final count = countDoc.data()?['count'] ?? 0;

      groupMap.putIfAbsent(groupId, () => []).add(count);
      groupMeta[groupId] = {
        'name': '',
        'iconUrl': '',
      };
    }

    for (var gid in groupMap.keys) {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(gid).get();
      groupMeta[gid] = {
        'name': groupDoc.data()?['name'] ?? '不明なグループ',
        'iconUrl': groupDoc.data()?['iconUrl'],
      };
    }

    final result = groupMap.entries.map((e) {
      final counts = e.value;
      final total = counts.fold(0, (sum, x) => sum + x);
      final avg = total / counts.length;
      return {
        'groupId': e.key,
        'total': total,
        'avg': avg,
        'memberCount': counts.length,
        'name': groupMeta[e.key]?['name'] ?? '不明',
        'iconUrl': groupMeta[e.key]?['iconUrl'],
      };
    }).toList();

    result.sort((a, b) => b['total'].compareTo(a['total']));
    return result;
  }
}
