import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class UserAddDialog extends StatefulWidget {
  final VoidCallback onUserAdded;

  const UserAddDialog({super.key, required this.onUserAdded});

  @override
  State<UserAddDialog> createState() => _UserAddDialogState();
}

class _UserAddDialogState extends State<UserAddDialog> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _createUser() async {
    setState(() => isLoading = true);
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('createUser');
      final result = await callable.call({
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'displayName': nameController.text.trim(),
      });

      if (result.data != null) {
        widget.onUserAdded();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登録に失敗しました')),
        );
      }
    } catch (e) {
      print('Error creating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エラーが発生しました')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ユーザー追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(labelText: '表示名'),
          ),
          TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(labelText: 'メールアドレス'),
          ),
          TextField(
            controller: passwordController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(labelText: '初期パスワード'),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _createUser,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('登録'),
        ),
      ],
    );
  }
}
