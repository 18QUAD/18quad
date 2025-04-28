import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/functions_service.dart';
import '../widgets/app_scaffold.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Uint8List? _selectedImage;
  String? _uploadedIconUrl;

  final picker = ImagePicker();

  static const String defaultUserIconUrl =
      'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = bytes;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_icons/${DateTime.now().millisecondsSinceEpoch}.png');
    await storageRef.putData(_selectedImage!);
    _uploadedIconUrl = await storageRef.getDownloadURL();
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _displayNameController.text.isEmpty) {
      setState(() => _error = '全てのフィールドを入力してください');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _uploadImage();

      final iconUrlToUse = _uploadedIconUrl ?? defaultUserIconUrl;

      await FunctionsService.createUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
        iconUrl: iconUrlToUse,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '新規登録',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: (_selectedImage != null
                        ? MemoryImage(_selectedImage!)
                        : const NetworkImage(defaultUserIconUrl))
                    as ImageProvider<Object>, // ✅ キャスト追加で型エラー解消
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード'),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: '表示名'),
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: AppColors.textPrimary,
                      textStyle: AppTextStyles.button,
                    ),
                    child: const Text('登録'),
                  ),
          ],
        ),
      ),
    );
  }
}
