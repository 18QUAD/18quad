import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/firestore_service.dart';
import '../widgets/app_scaffold.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _localCount = 0;
  int _previousTotal = 0;

  @override
  void initState() {
    super.initState();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // 未ログイン → ログイン画面にリダイレクト
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }

    _loadTotalCount(uid);
  }

  Future<void> _loadTotalCount(String uid) async {
    final total = await FirestoreService.getTotalCount(uid);
    setState(() {
      _previousTotal = total;
    });
  }

  Future<void> _incrementCount() async {
    setState(() {
      _localCount++;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirestoreService.incrementCount(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.status == null || userProvider.isAdmin == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppScaffold(
          title: 'ホーム',
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('前日までの総数: $_previousTotal'),
                Text('今日の連打数: $_localCount'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _incrementCount,
                  child: const Text('連打！'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
