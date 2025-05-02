import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/app_drawer.dart';
import '../config/app_config.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;         // 総カウント（サーバ記録分＋ローカル加算分）
  int _localCount = 0;    // 同期待ちのローカル加算分
  bool _isLoading = true;
  Timer? _syncTimer;
  String? _userStatus;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCount();
    _startSyncTimer();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userData = await FirestoreService.getUserData(uid);
    setState(() {
      _userStatus = userData?['status'] ?? 'member';
      _isAdmin = userData?['isAdmin'] ?? false;
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(AppConfig.syncInterval, (_) => _syncToServer());
  }

  Future<void> _loadCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final serverCount = await FirestoreService.getDailyCount(user.uid, DateTime.now());
      setState(() {
        _count = serverCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _count = 0;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('カウントの読み込みに失敗しました: $e')),
      );
    }
  }

  void _incrementLocalCount() {
    setState(() {
      _count++;
      _localCount++;
    });
  }

  Future<void> _syncToServer() async {
    if (_localCount == 0) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirestoreService.incrementDailyCount(user.uid, _localCount);
      setState(() {
        _localCount = 0;
      });
    } catch (e) {
      debugPrint('同期失敗: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userStatus == null || _isAdmin == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('連打')),
      drawer: AppDrawer(
        isLoggedIn: true,
        userStatus: _userStatus!,
        isAdmin: _isAdmin!,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_count', style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _incrementLocalCount,
                    child: const Text('連打！'),
                  ),
                ],
              ),
      ),
    );
  }
}
