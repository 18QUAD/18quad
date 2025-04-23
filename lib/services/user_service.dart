import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final _users = FirebaseFirestore.instance.collection('users');

  static Future<AppUser?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  static Future<void> updateUser({required AppUser user}) async {
    await _users.doc(user.uid).set(user.toMap());
  }
}
