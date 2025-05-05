import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _displayNameController.text = userProvider.displayName;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final uid = userProvider.user?.uid ?? '';
    final iconUrl = userProvider.iconUrl;

    return AppScaffold(
      title: 'ユーザー設定',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    if (iconUrl != null && iconUrl.isNotEmpty)
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(iconUrl),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(labelText: '表示名'),
                      validator: (value) =>
                          value == null || value.isEmpty ? '表示名を入力してください' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: '新しいパスワード（任意）'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isLoading = true);

                        try {
                          await FirestoreService.updateUser(
                            uid: uid,
                            displayName: _displayNameController.text,
                          );

                          final newPassword = _passwordController.text.trim();
                          if (newPassword.isNotEmpty) {
                            await AuthService.updatePassword(newPassword);
                          }

                          await userProvider.loadUser();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('更新しました')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('更新に失敗しました: $e')),
                            );
                          }
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
