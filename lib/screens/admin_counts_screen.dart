import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/app_scaffold.dart';

class AdminCountsScreen extends StatefulWidget {
  const AdminCountsScreen({super.key});

  @override
  State<AdminCountsScreen> createState() => _AdminCountsScreenState();
}

class _AdminCountsScreenState extends State<AdminCountsScreen> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final countsSnapshot =
        await FirebaseFirestore.instance.collection('counts').get();

    List<Map<String, dynamic>> result = [];

    for (var doc in countsSnapshot.docs) {
      final uid = doc.id;
      final count = doc.data()['count'] ?? 0;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final displayName = userDoc.data()?['displayName'] ?? '(不明)';
      final email = userDoc.data()?['email'] ?? '';

      result.add({
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'count': count,
      });
    }

    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppScaffold(
      title: 'ユーザー管理',
      user: user,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return ListTile(
                  leading: Text('${index + 1}位'),
                  title: Text(item['displayName']),
                  subtitle: Text('UID: ${item['uid']}'),
                  trailing: Text('${item['count']}'),
                );
              },
            ),
    );
  }
}
