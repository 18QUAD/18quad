import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedIconId = 0;
  bool _isLoading = true;
  String? _error;

  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await UserService.fetchUser(_uid);
    if (user != null) {
      _displayNameController.text = user.displayName;
      _selectedIconId = user.iconId;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await UserService.updateUser(
        uid: _uid,
        displayName: _displayNameController.text.trim(),
        iconId: _selectedIconId,
      );

      final newPassword = _passwordController.text.trim();
      if (newPassword.isNotEmpty) {
        await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新しました')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ユーザー設定')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('表示名'),
            TextField(controller: _displayNameController),
            const SizedBox(height: 16),
            const Text('新しいパスワード（任意）'),
            TextField(controller: _passwordController, obscureText: true),
            const SizedBox(height: 16),
            const Text('アイコン選択'),
            DropdownButton<int>(
              value: _selectedIconId,
              isExpanded: true,
              items: List.generate(10, (i) => DropdownMenuItem(
                value: i,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/icons/icon_$i.png'),
                      radius: 16,
                    ),
                    const SizedBox(width: 8),
                    Text('アイコン $i'),
                  ],
                ),
              )),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedIconId = val);
                }
              },
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: const Text('変更を保存'),
            ),
          ],
        ),
      ),
    );
  }
}
