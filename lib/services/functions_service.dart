import 'dart:convert';
import 'package:http/http.dart' as http;

class FunctionsService {
  static const String _createUserUrl = 'https://us-central1-quad-2c91f.cloudfunctions.net/createUser';
  static const String _deleteUserFullyUrl = 'https://us-central1-quad-2c91f.cloudfunctions.net/deleteUserFully';

  /// Cloud Functions経由で新規ユーザーを作成する
  static Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    String? iconUrl, // ★ アイコンURLも渡せる
  }) async {
    try {
      final uri = Uri.parse(_createUserUrl);
      print('★ リクエスト先URI (createUser): $uri');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
          'iconUrl': iconUrl ?? '',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('ユーザー作成に失敗しました: ${response.body}');
      }
    } catch (e) {
      throw Exception('ユーザー作成エラー: $e');
    }
  }

  /// Cloud Functions経由でユーザー完全削除する
  static Future<void> deleteUserFully(String uid) async {
    try {
      final uri = Uri.parse(_deleteUserFullyUrl);
      print('★ リクエスト先URI (deleteUserFully): $uri');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid}),
      );

      if (response.statusCode != 200) {
        throw Exception('ユーザー完全削除に失敗しました: ${response.body}');
      }
    } catch (e) {
      throw Exception('ユーザー完全削除エラー: $e');
    }
  }
}
