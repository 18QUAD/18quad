import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_scaffold.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({Key? key}) : super(key: key);

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      setState(() {
        _error = 'グループ名を入力してください。';
      });
      return;
    }

    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      setState(() {
        _error = 'ログインしていません。';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirestoreService.createGroup(
        ownerUid: currentUser.uid,
        groupName: groupName,
        iconBytes: null,
      );

      await FirestoreService.updateUser(
        uid: currentUser.uid,
        displayName: currentUser.displayName,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } catch (e) {
      setState(() {
        _error = 'グループ作成に失敗しました: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループ作成',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(labelText: 'グループ名'),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? const CircularProgressIndicator() : const Text('作成'),
            ),
          ],
        ),
      ),
    );
  }
}
