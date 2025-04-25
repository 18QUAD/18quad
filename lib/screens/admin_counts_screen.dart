import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/app_scaffold.dart';

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final countsSnapshot = await FirebaseFirestore.instance.collection('counts').get();
    List<Map<String, dynamic>> result = [];

    for (var doc in countsSnapshot.docs) {
      final uid = doc.id;
      final count = doc.data()['count'] ?? 0;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      final displayName = (userData['displayName'] ?? '').toString().isEmpty
          ? '(名前未設定)'
          : userData['displayName'].toString();
      final email = userData['email']?.toString() ?? '(emailなし)';

      result.add({
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'count': count,
      });
    }

    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    if (mounted) {
      setState(() {
        data = result;
        isLoading = false;
      });
    }
  }

  void _showCreateUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新規ユーザー追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '表示名'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _createUserFromFunction(
                emailController.text.trim(),
                passwordController.text.trim(),
                nameController.text.trim(),
              );
            },
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  Future<void> _createUserFromFunction(String email, String password, String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();

    const functionUrl = 'https://us-central1-<your-project-id>.cloudfunctions.net/createUser'; // ← 差し替え必要！

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ユーザーを作成しました')),
        );
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('作成失敗: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('通信エラー: $e')),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> userData) {
    final nameController = TextEditingController(text: userData['displayName']);
    final emailController = TextEditingController(text: userData['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'ユーザー編集',
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: '表示名',
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uid = userData['uid'];
              final newName = nameController.text;
              final newEmail = emailController.text;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .set({
                'displayName': newName,
                'email': newEmail,
              }, SetOptions(merge: true));

              Navigator.pop(context);
              await _loadData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppScaffold(
      title: 'ユーザー管理',
      user: user,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    onPressed: _showCreateUserDialog,
                    child: const Text('＋ ユーザー追加'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return ListTile(
                        leading: Text('${index + 1}位', style: const TextStyle(color: Colors.white)),
                        title: Text(item['displayName'], style: const TextStyle(color: Colors.white)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UID: ${item['uid']}', style: const TextStyle(color: Colors.white)),
                            Text('メール: ${item['email']}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _showEditDialog(item),
                          child: const Text('編集'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
