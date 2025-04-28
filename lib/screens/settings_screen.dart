import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  Uint8List? _selectedImage;
  String? _currentIconUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        setState(() {
          _displayNameController.text = data['displayName'] ?? '';
          _currentIconUrl = data['iconUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  Future<String?> _uploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedImage == null) return null;

    final storageRef = FirebaseStorage.instance.ref().child('user_icons/${user.uid}.png');
    await storageRef.putData(_selectedImage!);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('ユーザーが見つかりません');
      }

      String? iconUrl;
      if (_selectedImage != null) {
        iconUrl = await _uploadImage();
      }

      final updateData = <String, dynamic>{};
      if (_displayNameController.text.isNotEmpty) {
        updateData['displayName'] = _displayNameController.text;
        await user.updateDisplayName(_displayNameController.text);
      }
      if (iconUrl != null) {
        updateData['iconUrl'] = iconUrl;
      }

      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存に失敗しました')),
        );
      }
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
      title: '設定',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? MemoryImage(_selectedImage!)
                          : (_currentIconUrl != null
                              ? NetworkImage(_currentIconUrl!) as ImageProvider
                              : null),
                      child: (_selectedImage == null && _currentIconUrl == null)
                          ? const Icon(Icons.add_a_photo, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(labelText: '表示名'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('保存'),
                  ),
                ],
              ),
      ),
    );
  }
}
