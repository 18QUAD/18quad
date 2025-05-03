
enum RankingType {
  day,
  month,
  year,
  total;

  String get label {
    switch (this) {
      case RankingType.day:
        return '日別';
      case RankingType.month:
        return '月別';
      case RankingType.year:
        return '年別';
      case RankingType.total:
        return '総数';
    }
  }
}
