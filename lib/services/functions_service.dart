import 'dart:convert';
import 'package:http/http.dart' as http;

class FunctionsService {
  static const String _functionUrl = 'https://us-central1-quad-2c91f.cloudfunctions.net/createUser';

  /// Cloud Functions経由で新規ユーザーを作成する
  static Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final uri = Uri.parse(_functionUrl);
      print('★ リクエスト先URI: $uri'); // 🔥 ログを仕込んだ！

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('ユーザー作成に失敗しました: ${response.body}');
      }
    } catch (e) {
      throw Exception('ユーザー作成エラー: $e');
    }
  }
}
