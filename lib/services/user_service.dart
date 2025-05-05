import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  static Future<AppUser?> fetchUser(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(uid, doc.data()!);
    }
    return null;
  }

  static Future<void> updateUser({required AppUser user}) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(user.toMap());
  }
}
