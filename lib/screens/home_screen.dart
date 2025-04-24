import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  int _count = 0;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _loadCount();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final user = await UserService.fetchUser(uid);
      setState(() => _user = user);
    }
  }

  Future<void> _loadCount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('counts').doc(uid).get();
    setState(() {
      _count = doc.data()?['count'] ?? 0;
    });
  }

  Future<void> _incrementCount() async {
    setState(() => _count++);
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('counts').doc(uid).set({'count': _count});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '連打カウント',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_user?.iconUrl != null && _user!.iconUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(_user!.iconUrl),
                radius: 32,
              ),
            const SizedBox(height: 32),
            Text(
              '$_count',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _incrementCount,
              child: const Text('連打!'),
            ),
          ],
        ),
      ),
    );
  }
}
// noop: force update for drawer integration