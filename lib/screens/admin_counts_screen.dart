import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../services/firestore_service.dart';
import '../services/functions_service.dart'; // Cloud Functions呼び出し用

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ユーザー管理',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addUser,
        ),
      ],
      child: StreamBuilder(
        stream: FirestoreService.getUsersStream(), // usersコレクションを購読
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('データが存在しません'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final uid = doc.id;
              final data = doc.data();
              final displayName = data['displayName'] ?? '名無し';
              final email = data['email'] ?? '不明';
              final iconUrl = data['iconUrl'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: iconUrl != null
                      ? NetworkImage(iconUrl)
                      : const AssetImage('assets/icons/default.png') as ImageProvider,
                ),
                title: Text(displayName, style: AppTextStyles.body),
                subtitle: Text('$email\nUID: ${uid.substring(0, 6)}...', style: AppTextStyles.label),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'reset') {
                      await FirestoreService.resetCount(uid);
                    } else if (value == 'edit') {
                      await _editUser(uid, displayName);
                    } else if (value == 'delete') {
                      await FunctionsService.deleteUserFully(uid); // 🔥ここで完全削除！
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'reset', child: Text('カウントリセット')),
                    const PopupMenuItem(value: 'edit', child: Text('ユーザー編集')),
                    const PopupMenuItem(value: 'delete', child: Text('ユーザー削除')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editUser(String uid, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ユーザー名を編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '新しい表示名'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await FirestoreService.updateDisplayName(uid, controller.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser() async {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新規ユーザー追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'メールアドレス'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '表示名'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '初期パスワード'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FunctionsService.createUser(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
                displayName: nameController.text.trim(),
              );
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
