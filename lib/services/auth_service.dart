import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // ★ デフォルトアイコンURL（修正版）
  static const String defaultUserIconUrl =
    'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

  /// ログイン
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// 新規登録
  static Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(displayName);

      // ★ default.pngをダウンロード
      final response = await http.get(Uri.parse(defaultUserIconUrl));
      if (response.statusCode != 200) {
        throw Exception('デフォルトアイコンのダウンロードに失敗しました');
      }

      // ★ Storageに /user_icons/{uid}.png としてアップロード
      final ref = FirebaseStorage.instance.ref().child('user_icons/${user.uid}.png');
      await ref.putData(response.bodyBytes);

      // ★ アップロードしたファイルのダウンロードURLを取得
      final uploadedIconUrl = await ref.getDownloadURL();

      // ★ Firestoreにユーザーデータ保存
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': displayName.isNotEmpty ? displayName : '(未設定)',
        'createdAt': Timestamp.now(),
        'status': 'none', // 初期ステータス
        'iconUrl': uploadedIconUrl, // ★ ユーザー専用のアイコンURL
      });
    }

    return userCredential;
  }

  /// ログアウト
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// パスワード更新（追加済み）
  static Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('ユーザーがログインしていません');
    }
  }
}
