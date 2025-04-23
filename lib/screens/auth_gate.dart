// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';
import 'title_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ロード中（未決定）
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.pink),
            ),
          );
        }

        // エラー発生時
        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'エラーが発生しました',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        // ログイン済みならホームへ
        if (snapshot.hasData) {
          print('ログイン中：${snapshot.data!.email}');
          return const HomeScreen();
        }

        // 未ログインならタイトル画面へ
        print('未ログイン状態 → タイトル画面へ');
        return const TitleScreen();
      },
    );
  }
}
