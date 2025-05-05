class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? iconUrl;
  final String? groupId;
  final bool isAdmin;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.iconUrl,
    this.groupId,
    this.isAdmin = false,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      iconUrl: data['iconUrl'],
      groupId: data['groupId'],
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'iconUrl': iconUrl,
      'groupId': groupId,
      'isAdmin': isAdmin,
    };
  }
}
