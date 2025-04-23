import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 高さを抑えたヘッダー
          Container(
            height: 80,
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            color: Colors.pink,
            child: const Text(
              'メニュー',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),

          // タイトルに戻る
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('タイトルに戻る', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),

          // 連打入力
          ListTile(
            leading: const Icon(Icons.flash_on, color: Colors.white),
            title: const Text('連打入力', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),

          // ランキング
          ListTile(
            leading: const Icon(Icons.leaderboard, color: Colors.white),
            title: const Text('ランキング', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/ranking');
            },
          ),
        ],
      ),
    );
  }
}
