library app_config;

import 'package:flutter/material.dart';

class AppConfig {
  // 連打書き込み間隔（例：10秒）
  static const Duration syncInterval = Duration(seconds: 10);

  // Firestoreコレクション名（変更時に一括対応）
  static const String dailyCountCollection = 'daily_counts';

  // 日付フォーマット（共通）
  static const String dateFormat = 'yyyy-MM-dd';
  static const String monthFormat = 'yyyy-MM';
  static const String yearFormat = 'yyyy';

  // その他追加予定のグローバル設定値…
}
