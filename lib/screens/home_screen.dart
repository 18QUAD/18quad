import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _count = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('counts').doc(uid).get();
    setState(() {
      _count = doc.data()?['count'] ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _incrementCount() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _count++;
    });
    await FirebaseFirestore.instance.collection('counts').doc(uid).set({'count': _count});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('連打')),
      drawer: const AppDrawer(),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_count', style: const TextStyle(fontSize: 60)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _incrementCount,
                    child: const Text('連打！'),
                  ),
                ],
              ),
      ),
    );
  }
}
