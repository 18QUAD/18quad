import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// 現在ログイン中のUIDを取得
  static String get currentUid => _auth.currentUser!.uid;

  /// ユーザーの連打カウントを取得
  static Future<int> getCount(String uid) async {
    final doc = await _db.collection('counts').doc(uid).get();
    final data = doc.data();
    return data?['count'] ?? 0;
  }

  /// ユーザーの連打カウントを保存
  static Future<void> setCount(String uid, int count) async {
    await _db.collection('counts').doc(uid).set({'count': count});
  }

  /// ユーザーの連打カウントをリセット（0にする）
  static Future<void> resetCount(String uid) async {
    await _db.collection('counts').doc(uid).update({'count': 0});
  }

  /// ユーザーの情報（表示名・メールなど）を取得
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// ユーザーの表示名を更新
  static Future<void> updateDisplayName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({'displayName': name});
  }

  /// ユーザー情報(usersコレクション)を削除
  static Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// カウント情報(countsコレクション)を削除
  static Future<void> deleteCountData(String uid) async {
    await _db.collection('counts').doc(uid).delete();
  }

  /// ランキング用データ取得ストリーム（count順降順）
  static Stream<QuerySnapshot> getRankingStream() {
    return _db.collection('counts').orderBy('count', descending: true).snapshots();
  }
}
