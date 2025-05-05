import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:rennda_app/firebase_options.dart';
import 'package:rennda_app/providers/user_provider.dart';
import 'package:rennda_app/screens/title_screen.dart';
import 'package:rennda_app/screens/home_screen.dart';
import 'package:rennda_app/screens/login_screen.dart';
import 'package:rennda_app/screens/register_screen.dart';
import 'package:rennda_app/screens/settings_screen.dart';
import 'package:rennda_app/screens/ranking_screen.dart';
import 'package:rennda_app/screens/group_manage_screen.dart';
import 'package:rennda_app/screens/group_request_screen.dart'; // ← 正しいファイル名
import 'package:rennda_app/screens/group_create_screen.dart' as user;
import 'package:rennda_app/screens/admin_counts_screen.dart';
import 'package:rennda_app/screens/admin_group_requests_screen.dart' as admin;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final userProvider = UserProvider();
  await userProvider.loadUser(); // 起動時にユーザ情報を読み込み

  runApp(
    ChangeNotifierProvider.value(
      value: userProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '18QUAD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TitleScreen(),
      routes: {
        '/title': (context) => const TitleScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/groupManage': (context) => const GroupManageScreen(),
        '/groupRequest': (context) => const GroupRequestScreen(), // 単数形に修正
        '/groupCreate': (context) => const user.GroupCreateScreen(),
        '/adminCounts': (context) => const AdminCountsScreen(),
        '/adminGroupRequests': (context) => const admin.AdminGroupRequestsScreen(),
      },
    );
  }
}
