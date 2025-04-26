import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_scaffold.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  List<DocumentSnapshot> _users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance.collection('counts').orderBy('count', descending: true).get();
    setState(() {
      _users = snapshot.docs;
    });
  }

  Future<void> _resetCount(String uid) async {
    await FirebaseFirestore.instance.collection('counts').doc(uid).update({'count': 0});
    _loadData();
  }

  Future<void> _deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await FirebaseFirestore.instance.collection('counts').doc(uid).delete();
    _loadData();
  }

  Future<void> _editUser(String uid, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ユーザー名を編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '新しい表示名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({'displayName': controller.text});
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();

    await showDialog(
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
              decoration: const InputDecoration(labelText: 'パスワード'),
              obscureText: true,
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
          TextButton(
            onPressed: () async {
              print('★ ユーザー追加ボタン押された！'); // 🔥 ログ追加

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

    const functionUrl = 'https://us-central1-quad-2c91f.cloudfunctions.net/createUser';

    try {
      final uri = Uri.parse(functionUrl);
      print('★ リクエスト先URI: $uri'); // 🔥 ログ追加

      final response = await http.post(
        uri,
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
      print('★ 通信エラー発生: $e'); // 🔥 ログ追加
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('通信エラー: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ユーザー管理',
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: const Icon(Icons.add),
      ),
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final doc = _users[index];
          final uid = doc.id;
          final count = doc['count'] ?? 0;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const ListTile(title: Text('読み込み中...'));
              }
              final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
              final displayName = userData?['displayName'] ?? '名無し';
              final email = userData?['email'] ?? '不明';

              return ListTile(
                title: Text('$displayName', style: AppTextStyles.body),
                subtitle: Text('$email\nUID: ${uid.substring(0, 6)}...', style: AppTextStyles.label),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'reset') {
                      await _resetCount(uid);
                    } else if (value == 'edit') {
                      await _editUser(uid, displayName);
                    } else if (value == 'delete') {
                      await _deleteUser(uid);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'reset', child: Text('カウントリセット')),
                    const PopupMenuItem(value: 'edit', child: Text('ユーザー編集')),
                    const PopupMenuItem(value: 'delete', child: Text('ユーザー削除')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
