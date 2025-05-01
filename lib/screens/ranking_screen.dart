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
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());
  String _rankingType = 'day'; // 'day', 'month', 'year', 'total'

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
          _buildModeSelector(),
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

  Widget _buildModeSelector() {
    return DropdownButton<String>(
      value: _rankingType,
      onChanged: (value) {
        if (value != null) {
          setState(() => _rankingType = value);
        }
      },
      items: const [
        DropdownMenuItem(value: 'day', child: Text('日別')),
        DropdownMenuItem(value: 'month', child: Text('月別')),
        DropdownMenuItem(value: 'year', child: Text('年別')),
        DropdownMenuItem(value: 'total', child: Text('総数')),
      ],
    );
  }

  Widget _buildDateSelector() {
    if (_rankingType == 'day') {
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
    } else if (_rankingType == 'month') {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('月選択: '),
            DropdownButton<String>(
              value: _selectedMonth,
              onChanged: (value) => setState(() => _selectedMonth = value!),
              items: List.generate(12, (i) {
                final month = i + 1;
                final date = DateTime(DateTime.now().year, month);
                return DropdownMenuItem(
                  value: DateFormat('yyyy-MM').format(date),
                  child: Text(DateFormat('yyyy年MM月').format(date)),
                );
              }),
            ),
          ],
        ),
      );
    } else if (_rankingType == 'year') {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('年選択: '),
            DropdownButton<String>(
              value: _selectedYear,
              onChanged: (value) => setState(() => _selectedYear = value!),
              items: List.generate(5, (i) {
                final year = DateTime.now().year - i;
                return DropdownMenuItem(
                  value: year.toString(),
                  child: Text('$year年'),
                );
              }),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildIndividualRanking() {
    return FutureBuilder(
      future: FirestoreService.getRankingList(_rankingType, _selectedDate, _selectedMonth, _selectedYear),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('データがありません'));
        }

        final docs = snapshot.data!;
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
    return const Center(child: Text('グループランキングは今後のアップデートで対応予定です'));
  }
}
