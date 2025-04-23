import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;
  bool _isLoading = true;
  AppUser? _user;

  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCount();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.fetchUser(_uid);
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _loadCount() async {
    final doc = await FirebaseFirestore.instance.collection('counts').doc(_uid).get();
    if (doc.exists) {
      setState(() => _count = doc.data()?['count'] ?? 0);
    }
  }

  Future<void> _saveCount() async {
    await FirebaseFirestore.instance.collection('counts').doc(_uid).set({'count': _count});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存しました')),
    );
  }

  void _increment() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('連打カウント'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ユーザー情報表示（アイコン＋表示名）
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/icon_${_user!.iconId}.png'),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _user!.displayName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // カウント表示
            Text('$_count', style: const TextStyle(fontSize: 48)),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _increment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              ),
              child: const Text('連打!', style: TextStyle(fontSize: 24)),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveCount,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
