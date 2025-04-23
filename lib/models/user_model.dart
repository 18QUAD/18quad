class AppUser {
  final String uid;
  final String displayName;
  final int iconId;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.iconId,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      displayName: data['displayName'] ?? '',
      iconId: data['iconId'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'iconId': iconId,
    };
  }
}
