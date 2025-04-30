import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../widgets/app_scaffold.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _pickedImageBytes;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループ作成',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          if (_pickedImageBytes != null)
                            Image.memory(_pickedImageBytes!, height: 100)
                          else
                            const Icon(Icons.group, size: 100, color: Colors.grey),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text('アイコン画像を選択'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'グループ名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '紹介文（任意）',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _createGroup,
                        child: const Text('グループを作成する'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
      });
    }
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();
    final groupDescription = _descriptionController.text.trim();
    if (groupName.isEmpty) {
      _showError('グループ名を入力してください。');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('ユーザー情報を取得できません。');
        return;
      }

      final userDoc = await FirestoreService.getUserData(user.uid);
      if (userDoc != null && (userDoc['groupId'] ?? '').toString().isNotEmpty) {
        _showError('すでにグループに所属しています。');
        return;
      }

      await FirestoreService.createGroup(
        groupName: groupName,
        description: groupDescription,
        iconBytes: _pickedImageBytes,
        ownerUid: user.uid, // ← 追加された重要フィールド
      );

      if (mounted) Navigator.pop(context);
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
