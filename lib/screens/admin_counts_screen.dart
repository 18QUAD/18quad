import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_scaffold.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  List<DocumentSnapshot> _users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance.collection('counts').orderBy('count', descending: true).get();
    setState(() {
      _users = snapshot.docs;
    });
  }

  Future<void> _resetCount(String uid) async {
    await FirebaseFirestore.instance.collection('counts').doc(uid).update({'count': 0});
    _loadData();
  }

  Future<void> _deleteUser(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await FirebaseFirestore.instance.collection('counts').doc(uid).delete();
    _loadData();
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
              await FirebaseFirestore.instance.collection('users').doc(uid).update({'displayName': controller.text});
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ユーザー管理',
      child: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final doc = _users[index];
          final uid = doc.id;
          final count = doc['count'] ?? 0;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const ListTile(title: Text('読み込み中...'));
              }
              final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
              final displayName = userData?['displayName'] ?? '名無し';
              final email = userData?['email'] ?? '不明';
              final iconUrl = userData?['iconUrl'];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: iconUrl != null
                      ? NetworkImage(iconUrl)
                      : const AssetImage('assets/icons/default.png') as ImageProvider,
                ),
                title: Text('$displayName', style: AppTextStyles.body),
                subtitle: Text('$email\nUID: ${uid.substring(0, 6)}...', style: AppTextStyles.label),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'reset') {
                      await _resetCount(uid);
                    } else if (value == 'edit') {
                      await _editUser(uid, displayName);
                    } else if (value == 'delete') {
                      await _deleteUser(uid);
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
}
