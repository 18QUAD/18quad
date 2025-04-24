import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();
    if (userData != null) {
      _nameController.text = userData['displayName'] ?? '';
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final name = _nameController.text;
    final password = _passwordController.text;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'displayName': name,
    });

    if (password.isNotEmpty) {
      await FirebaseAuth.instance.currentUser!.updatePassword(password);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
      Navigator.pop(context); // 前の画面に戻る
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー設定')),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '表示名'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: '新しいパスワード（空欄で変更なし）'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
    );
  }
}
