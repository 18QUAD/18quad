class AppUser {
  final String uid;
  final String displayName;
  final String iconUrl;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.iconUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'iconUrl': iconUrl,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      displayName: data['displayName'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
    );
  }
}
