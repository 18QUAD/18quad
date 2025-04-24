import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  Uint8List? _imageBytes;
  XFile? _pickedFile;

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
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _pickedFile = picked;
      });
    }
  }

  Future<String?> _uploadImage(XFile file) async {
    final uid = _uid;
    if (uid == null) return null;
    final ref = FirebaseStorage.instance.ref('user_icons/$uid.png');

    final bytes = await file.readAsBytes();
    print('📤 putData 実行直前！');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/png'),
    );
    print('✅ putData 完了！ getting URL...');

    final url = await ref.getDownloadURL();
    print('download URL obtained: $url');
    return url;
  }

  Future<void> _saveUser() async {
    print('🚨 _saveUser に入ったぞ');
    if (_uid == null) {
      print('⚠️ _uid is null');
      return;
    }
    String? finalIconUrl = _iconUrl;
    if (_pickedFile != null) {
      print('📦 _pickedFile is not null');
      final uploadedUrl = await _uploadImage(_pickedFile!);
      if (uploadedUrl != null) finalIconUrl = uploadedUrl;
    }

    final user = AppUser(
      uid: _uid!,
      displayName: _nameController.text,
      iconUrl: finalIconUrl ?? '',
    );

    try {
      print('📝 Saving user to Firestore...');
      await UserService.updateUser(user: user);
      print('✅ Firestore 保存完了');
    } catch (e, stack) {
      print('🔥 Firestore 保存エラー: $e');
      print('stacktrace: $stack');
    }

    await _loadUser();
    setState(() {});

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プロフィールを保存しました')),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    print('🔥🔥🔥 これは最新版 settings_screen.dart のログだ！');
    print('🔥 表示直前のURL: $_iconUrl');

    final cleanedUrl = _iconUrl?.replaceAll(RegExp(r'\s+'), '') ?? '';

    return AppScaffold(
      title: 'ユーザー設定',
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (kIsWeb)
            // Web限定：Image.network で CORS問題を回避
            cleanedUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      cleanedUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('💥 Image.network error: $error');
                        return const Icon(Icons.error);
                      },
                    ),
                  )
                : const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/icons/default.png'),
                  )
          else
            CircleAvatar(
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : cleanedUrl.isNotEmpty
                      ? NetworkImage(cleanedUrl) as ImageProvider
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
            onPressed: () async {
              print('保存ボタンが押された！（爆弾ログ）');
              print('実行直前だ！ _saveUser = ${_saveUser}');
              try {
                await _saveUser();
              } catch (e, stack) {
                print('例外発生: $e');
                print('stacktrace: $stack');
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
