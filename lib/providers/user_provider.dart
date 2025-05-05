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

  Future<void> loadUser() async {
    _user = _auth.currentUser;
    if (_user != null) {
      final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _isAdmin = data['isAdmin'] ?? false;
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

  Future<void> logout() async {
    await _auth.signOut();
    clearUser();
  }
}
