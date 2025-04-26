import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    try {
      final userData = await FirestoreService.getUserData(FirestoreService.currentUid);
      if (userData != null) {
        _nameController.text = userData['displayName'] ?? '';
      }
    } catch (e) {
      print('ユーザー情報読み込みエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ユーザー情報の取得に失敗しました')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    try {
      if (name.isNotEmpty) {
        await FirestoreService.updateDisplayName(FirestoreService.currentUid, name);
      }
      if (password.isNotEmpty) {
        await AuthService.updatePassword(password);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('保存エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー設定')),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '表示名',
                    ),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '新しいパスワード（空欄なら変更なし）',
                    ),
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: AppColors.textPrimary,
                      textStyle: AppTextStyles.button,
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ),
    );
  }
}
