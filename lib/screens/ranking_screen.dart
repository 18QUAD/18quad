import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/ranking_header.dart';

enum RankingPeriod { daily, monthly, yearly, total }

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingPeriod _selectedPeriod = RankingPeriod.daily;
  DateTime _selectedDate = DateTime.now();

  List<String> _availableDays = [];
  List<String> _availableMonths = [];
  List<String> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _initAvailableDates();
  }

  void _initAvailableDates() {
    final now = DateTime.now();
    _availableDays = List.generate(30, (i) {
      final date = now.subtract(Duration(days: i));
      return DateFormat('yyyy-MM-dd').format(date);
    });

    _availableMonths = List.generate(12, (i) {
      final date = DateTime(now.year, now.month - i);
      return DateFormat('yyyy-MM').format(date);
    });

    _availableYears = List.generate(5, (i) => (now.year - i).toString());
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final myUid = userProvider.user?.uid ?? '';

    return AppScaffold(
      title: 'ランキング',
      child: Column(
        children: [
          RankingHeader(
            onTypeChanged: (type) {
              setState(() {
                _selectedPeriod = _parsePeriod(type);
              });
            },
            onDateChanged: (value) {
              setState(() {
                switch (_selectedPeriod) {
                  case RankingPeriod.daily:
                    _selectedDate = DateFormat('yyyy-MM-dd').parse(value);
                    break;
                  case RankingPeriod.monthly:
                    _selectedDate = DateFormat('yyyy-MM').parse(value);
                    break;
                  case RankingPeriod.yearly:
                    _selectedDate = DateTime.parse('$value-01-01');
                    break;
                  case RankingPeriod.total:
                    break;
                }
              });
            },
            availableDates: _availableDays,
            availableMonths: _availableMonths,
            availableYears: _availableYears,
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRanking(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('ランキングデータがありません'));
                }

                final rankingData = snapshot.data!;
                return ListView.builder(
                  itemCount: rankingData.length,
                  itemBuilder: (context, index) {
                    final data = rankingData[index];
                    final uid = data['uid'];
                    final count = data['count'] ?? 0;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: FirestoreService.getUserData(uid),
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data;
                        final displayName = userData?['displayName'] ?? '匿名';
                        final isMe = uid == myUid;

                        return ListTile(
                          leading: Text('${index + 1}位'),
                          title: Text(displayName),
                          trailing: Text('$count 回'),
                          tileColor: isMe ? Colors.blue.withOpacity(0.1) : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  RankingPeriod _parsePeriod(String type) {
    switch (type) {
      case 'day':
        return RankingPeriod.daily;
      case 'month':
        return RankingPeriod.monthly;
      case 'year':
        return RankingPeriod.yearly;
      case 'total':
        return RankingPeriod.total;
      default:
        return RankingPeriod.daily;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRanking() async {
    final day = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final month = DateFormat('yyyy-MM').format(_selectedDate);
    final year = DateFormat('yyyy').format(_selectedDate);
    return await FirestoreService.getRankingList(
      _selectedPeriod.name,
      day,
      month,
      year,
    );
  }
}
