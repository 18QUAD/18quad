import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isAdmin = false;
  String _displayName = '';
  String? _groupId;
  String _status = 'none';
  String? _iconUrl; // 追加

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  String get displayName => _displayName;
  String? get groupId => _groupId;
  String? get iconUrl => _iconUrl; // 追加

  // statusフィールド
  String get status => _status;
  bool get isNone => _status == 'none';
  bool get isMember => _status == 'member';
  bool get isManager => _status == 'manager';

  // 旧currentUser相当のgetter
  User? get currentUser => _user;

  // 管理者UIDのホワイトリスト
  static const List<String> adminUids = [
    'XvDaJNoQfjQY3uHycZTy8TCF2nJ3', // 管理者UIDをここに追加
  ];

  Future<void> loadUser() async {
    _user = _auth.currentUser;
    if (_user != null) {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _isAdmin = adminUids.contains(_user!.uid); // ← 変更点（最小）
        _displayName = data['displayName'] ?? '';
        _groupId = data['groupId'];
        _status = data['status'] ?? 'none';
        _iconUrl = data['iconUrl']; // 追加
      }
    }
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _isAdmin = false;
    _displayName = '';
    _groupId = null;
    _status = 'none';
    _iconUrl = null; // 追加
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    clearUser();
    notifyListeners(); // ✅ UIを確実に再描画
    print('[logout] _user=$_user, isAdmin=$_isAdmin, status=$_status');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); // ✅ ログイン画面へ遷移
  }
}
