import 'dart:math';
import 'dart:typed_data'; // ★追加
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Uint8List? _pickedImageBytes; // ★ここ変更

  final String defaultGroupIconUrl =
      'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/group_icons%2Fdefault.png?alt=media&token=0da944aa-d698-4cd6-b5cb-f4630b049cb3';

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
      final bytes = await picked.readAsBytes(); // ★バイナリ読み込み
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
        setState(() => _isLoading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()?['groupJoinStatus'] == 'approved') {
        _showError('すでにグループに所属しています。');
        setState(() => _isLoading = false);
        return;
      }

      String iconUrl = defaultGroupIconUrl;
      if (_pickedImageBytes != null) {
        final fileName = 'group_icons/${DateTime.now().millisecondsSinceEpoch}.png';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putData(_pickedImageBytes!, SettableMetadata(contentType: 'image/png'));
        iconUrl = await ref.getDownloadURL();
      }

      final inviteCode = _generateRandomInviteCode();

      final newGroupRef = await FirebaseFirestore.instance.collection('groups').add({
        'name': groupName,
        'description': groupDescription,
        'iconUrl': iconUrl,
        'inviteCode': inviteCode,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'groupId': newGroupRef.id,
        'groupJoinStatus': 'approved',
        'groupRequestId': '',
      });

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      _showError('エラーが発生しました: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateRandomInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
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
