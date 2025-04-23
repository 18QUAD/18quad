import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  String? _uid;
  String? _iconUrl;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final user = await UserService.fetchUser(uid);
      if (user != null) {
        setState(() {
          _uid = uid;
          _nameController.text = user.displayName;
          _iconUrl = user.iconUrl;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File file) async {
    final uid = _uid;
    if (uid == null) return null;
    final ref = FirebaseStorage.instance.ref('user_icons/$uid.png');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveUser() async {
    if (_uid == null) return;
    String? finalIconUrl = _iconUrl;
    if (_newImage != null) {
      final uploadedUrl = await _uploadImage(_newImage!);
      if (uploadedUrl != null) finalIconUrl = uploadedUrl;
    }

    final user = AppUser(
      uid: _uid!,
      displayName: _nameController.text,
      iconUrl: finalIconUrl ?? '',
    );

    await UserService.updateUser(user: user);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ユーザー設定',
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            backgroundImage: _newImage != null
                ? FileImage(_newImage!)
                : (_iconUrl != null && _iconUrl!.isNotEmpty)
                    ? NetworkImage(_iconUrl!) as ImageProvider
                    : const AssetImage('assets/icons/default.png'),
            radius: 40,
          ),
          TextButton(
            onPressed: _pickImage,
            child: const Text('画像を選択'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '表示名'),
            ),
          ),
          ElevatedButton(
            onPressed: _saveUser,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
