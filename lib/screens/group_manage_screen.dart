import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../widgets/app_scaffold.dart';
import '../services/firestore_service.dart';
import '../providers/user_provider.dart';

class GroupManageScreen extends StatefulWidget {
  const GroupManageScreen({super.key});

  @override
  State<GroupManageScreen> createState() => _GroupManageScreenState();
}

class _GroupManageScreenState extends State<GroupManageScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _pickedImageBytes;
  String? _currentIconUrl;
  String? _groupId;
  String? _inviteCode;

  @override
  void initState() {
    super.initState();
    _loadGroupInfo();
  }

  Future<void> _loadGroupInfo() async {
    setState(() => _isLoading = true);

    try {
      final groupId = context.read<UserProvider>().groupId ?? '';
      if (groupId.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/groupCreate');
        return;
      }

      _groupId = groupId;

      final groupData = await FirestoreService.getGroupData(groupId);
      if (groupData != null) {
        _nameController.text = groupData['name'] ?? '';
        _descriptionController.text = groupData['description'] ?? '';
        _currentIconUrl = groupData['iconUrl'];
        _inviteCode = groupData['inviteCode'];
      }
    } catch (e) {
      _showError('グループ情報取得エラー: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'グループ管理',
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
                          else if (_currentIconUrl != null)
                            Image.network(_currentIconUrl!, height: 100)
                          else
                            const Icon(Icons.group, size: 100, color: Colors.grey),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text('アイコン画像を変更'),
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
                        labelText: '紹介文',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    if (_inviteCode != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '招待コード: $_inviteCode',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _inviteCode!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('招待コードをコピーしました')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateGroup,
                        child: const Text('グループ情報を更新する'),
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

  Future<void> _updateGroup() async {
    if (_groupId == null) {
      _showError('グループ情報が見つかりません。');
      return;
    }

    final groupName = _nameController.text.trim();
    final groupDescription = _descriptionController.text.trim();
    if (groupName.isEmpty) {
      _showError('グループ名を入力してください。');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService.updateGroup(
        groupId: _groupId!,
        name: groupName,
        description: groupDescription,
        iconBytes: _pickedImageBytes,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showError('更新エラー: $e');
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
