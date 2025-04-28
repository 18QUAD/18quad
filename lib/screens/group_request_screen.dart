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
  Map<String, dynamic>? _groupData;
  String? _groupDocId;

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
                      onPressed: _searchGroup,
                      child: const Text('グループを検索'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_groupData != null) ...[
                    if (_groupData!['iconUrl'] != null)
                      Center(
                        child: Image.network(
                          _groupData!['iconUrl'],
                          height: 100,
                          width: 100,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _groupData!['name'] ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_groupData!['description'] ?? ''),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _sendRequest,
                        child: const Text('このグループにリクエストする'),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _searchGroup() async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      _showError('招待コードを入力してください。');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        setState(() {
          _groupData = doc.data();
          _groupDocId = doc.id;
        });
      } else {
        setState(() {
          _groupData = null;
          _groupDocId = null;
        });
        _showError('該当するグループが見つかりません。');
      }
    } catch (e) {
      _showError('エラーが発生しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendRequest() async {
    if (_groupDocId == null) {
      _showError('グループが選択されていません。');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final existing = await FirebaseFirestore.instance
          .collection('group_requests')
          .where('requesterId', isEqualTo: currentUser.uid)
          .where('groupId', isEqualTo: _groupDocId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        _showError('すでに申請中のリクエストがあります。');
        return;
      }

      await FirebaseFirestore.instance.collection('group_requests').add({
        'requesterId': currentUser.uid,
        'groupId': _groupDocId,
        'inviteCode': _inviteCodeController.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      // ★ リクエスト送信成功後、ユーザーステータスを'pending'に更新
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'status': 'pending'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リクエストを送信しました。')),
      );

      setState(() {
        _inviteCodeController.clear();
        _groupData = null;
        _groupDocId = null;
      });
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
