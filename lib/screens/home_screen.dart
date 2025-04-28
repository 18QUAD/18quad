import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../services/firestore_service.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _redirectIfNotLoggedIn();
    _loadCount();
  }

  Future<void> _redirectIfNotLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    }
  }

  Future<void> _loadCount() async {
    setState(() => _isLoading = true);
    try {
      _count = await FirestoreService.getCount(FirestoreService.currentUid);
    } catch (e) {
      print('カウント読み込みエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('データ読み込みエラー')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _incrementCount() async {
    setState(() {
      _count++;
    });
    try {
      await FirestoreService.setCount(FirestoreService.currentUid, _count);
    } catch (e) {
      print('カウント保存エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('データ保存エラー')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: '連打',
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_count',
                    style: AppTextStyles.title.copyWith(fontSize: 60),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _incrementCount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: AppColors.textPrimary,
                      textStyle: AppTextStyles.button.copyWith(fontSize: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('連打！'),
                  ),
                ],
              ),
      ),
    );
  }
}
