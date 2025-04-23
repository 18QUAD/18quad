import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const TapApp());
}

class TapApp extends StatelessWidget {
  const TapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '18QUAD',
      home: const TapHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TapHomePage extends StatefulWidget {
  const TapHomePage({super.key});

  @override
  State<TapHomePage> createState() => _TapHomePageState();
}

class _TapHomePageState extends State<TapHomePage> {
  BigInt holyTap = BigInt.zero;
  String userName = "";
  final userId = FirebaseAuth.instance.currentUser!.uid;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        holyTap = BigInt.parse(data['holyTap'] ?? '0');
        userName = data['name'] ?? '';
      });
    } else {
      _askUserName();
    }
  }

  Future<void> _askUserName() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('ユーザー名を入力'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'タップ名人'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() => userName = name);
                await _saveUserData();
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserData() async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': userName,
      'holyTap': holyTap.toString(),
    });
  }

  void _onTap() {
    setState(() {
      holyTap += BigInt.one;
    });
    _saveUserData();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildTapPage(),
      const RankingPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.touch_app), label: '連打'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'ランキング'),
        ],
      ),
    );
  }

  Widget _buildTapPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ようこそ $userName さん', style: const TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 20),
          Text('$holyTap', style: const TextStyle(fontSize: 36, color: Colors.pink)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: const Text('連打！', style: TextStyle(fontSize: 24)),
          )
        ],
      ),
    );
  }
}

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .orderBy('holyTap', descending: true)
          .limit(10)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? '名無し';
            final taps = data['holyTap'] ?? '0';
            return ListTile(
              title: Text('$name', style: const TextStyle(color: Colors.white)),
              trailing: Text('$taps', style: const TextStyle(color: Colors.pink)),
            );
          },
        );
      },
    );
  }
}
