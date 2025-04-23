import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<AppUser?> fetchUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(uid, doc.data()!);
    }
    return null;
  }

  static Future<void> updateUser({
    required String uid,
    required String displayName,
    required int iconId,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'iconId': iconId,
    });
  }

  static Future<void> updateIcon(String uid, int iconId) async {
    await _firestore.collection('users').doc(uid).update({
      'iconId': iconId,
    });
  }

  static Future<void> updateDisplayName(String uid, String displayName) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
    });
  }
}
