import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_scaffold.dart';

class GroupRequestScreen extends StatefulWidget {
  const GroupRequestScreen({super.key});

  @override
  State<GroupRequestScreen> createState() => _GroupRequestScreenState();
}

class _GroupRequestScreenState extends State<GroupRequestScreen> {
  final TextEditingController _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループ参加リクエスト',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _inviteCodeController,
                    decoration: const InputDecoration(
                      labelText: '招待コードを入力',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _sendRequest,
                      child: const Text('リクエスト送信'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _sendRequest() async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      _showError('招待コードを入力してください。');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ★ 仮実装：リクエスト内容を表示するだけ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('招待コード「$inviteCode」でリクエスト送信')),
      );
      // TODO: Firestoreにリクエスト登録処理（本実装は後ほど）

    } catch (e) {
      _showError('エラーが発生しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('エラー'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
