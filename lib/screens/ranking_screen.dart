import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../widgets/app_scaffold.dart';
import '../services/firestore_service.dart';
import '../theme/text_styles.dart';
import '../models/ranking_type.dart';



class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}



class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  RankingType _rankingType = RankingType.day;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());

  final List<String> _availableDates = List.generate(
    7,
    (index) => DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: index))),
  );

  final List<String> _availableMonths = List.generate(
    12,
    (index) => DateFormat('yyyy-MM').format(DateTime(DateTime.now().year, DateTime.now().month - index, 1)),
  );

  final List<String> _availableYears = List.generate(
    5,
    (index) => (DateTime.now().year - index).toString(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          _buildRankingHeader(),
          Expanded(child: _buildIndividualRanking()),
        ],
      ),
    );
  }

  Widget _buildRankingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTypeSelector(),
          const SizedBox(width: 16),
          _buildDateSelector(),
          const SizedBox(width: 16),
          if (_rankingType != RankingType.day)
            Text(
              '※${_getReferenceDate()}時点',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return DropdownButton<RankingType>(
      value: _rankingType,
      items: [
        DropdownMenuItem(value: RankingType.day, child: Text('日別')),
        DropdownMenuItem(value: RankingType.month, child: Text('月別')),
        DropdownMenuItem(value: RankingType.year, child: Text('年別')),
        DropdownMenuItem(value: RankingType.total, child: Text('総数')),
      ],
      onChanged: (value) {
        setState(() {
          _rankingType = value!;
        });
      },
    );
  }

  Widget _buildDateSelector() {
    switch (_rankingType) {
      case RankingType.day:
        return _buildDaySelector();
      case RankingType.month:
        return _buildMonthSelector();
      case RankingType.year:
        return _buildYearSelector();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDaySelector() {
    return DropdownButton<String>(
      value: _selectedDate,
      items: _availableDates.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDate = value!;
        });
      },
    );
  }

  Widget _buildMonthSelector() {
    return DropdownButton<String>(
      value: _selectedMonth,
      items: _availableMonths.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMonth = value!;
        });
      },
    );
  }

  Widget _buildYearSelector() {
    return DropdownButton<String>(
      value: _selectedYear,
      items: _availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
      onChanged: (value) {
        setState(() {
          _selectedYear = value!;
        });
      },
    );
  }

  String _getReferenceDate() {
    if (_rankingType == RankingType.month) {
      return '${_selectedMonth}01日';
    } else if (_rankingType == RankingType.year) {
      return '${_selectedYear}01月01日';
    } else {
      final now = DateTime.now().subtract(const Duration(days: 1));
      final formatter = DateFormat('yyyy年MM月dd日');
      return formatter.format(now);
    }
  }

  Widget _buildIndividualRanking() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService.getRankingList(
        _rankingType.name,
        _selectedDate,
        _selectedMonth,
        _selectedYear,
      ),
      builder: (context, snapshot) {
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

            return FutureBuilder<Map<String, dynamic>?>(
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

                return FutureBuilder<String?>(
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

  String _getReferenceDateLabel() {
    if (_rankingType == RankingType.day) return '';
  
    final now = DateTime.now();
  
    if (_rankingType == RankingType.month) {
      final selected = DateTime.parse('$_selectedMonth-01');
      final isCurrentMonth = selected.year == now.year && selected.month == now.month;
  
      final refDate = isCurrentMonth
          ? now
          : DateTime(selected.year, selected.month + 1, 1);
  
      return '※${DateFormat('yyyy年MM月dd日').format(refDate)}時点';
    }
  
    if (_rankingType == RankingType.year) {
      final selected = DateTime.parse('$_selectedYear-01-01');
      final isCurrentYear = selected.year == now.year;
  
      final refDate = isCurrentYear
          ? now
          : DateTime(selected.year + 1, 1, 1);
  
      return '※${DateFormat('yyyy年MM月dd日').format(refDate)}時点';
    }
  
    // 総数
    return '※${DateFormat('yyyy年MM月dd日').format(now)}時点';
  }
}