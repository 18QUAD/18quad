import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get currentUid => _auth.currentUser!.uid;

  // ----------------------------
  // カウント関連
  // ----------------------------

  static Future<int> getCount(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('counts')
        .doc(uid)
        .get();
    final data = doc.data();
    return data?['count'] ?? 0;
  }

  static Future<void> setCount(String uid, int count) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('counts')
        .doc(uid)
        .set({'count': count});
  }

  static Future<void> resetCount(String uid) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('counts')
        .doc(uid)
        .update({'count': 0});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getRankingStream() {
    return _db
        .collectionGroup('counts')
        .orderBy('count', descending: true)
        .snapshots();
  }

  // ----------------------------
  // ユーザー関連
  // ----------------------------

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> updateDisplayName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({'displayName': name});
  }

  static Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  static Future<void> deleteCountData(String uid) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('counts')
        .doc(uid)
        .delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsersStream() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // ----------------------------
  // グループ関連
  // ----------------------------

  static Future<String?> getGroupName(String groupId) async {
    if (groupId.isEmpty) return null;
    final doc = await _db.collection('groups').doc(groupId).get();
    final data = doc.data();
    return data?['name'];
  }

  static Future<Map<String, dynamic>?> getGroupData(String groupId) async {
    if (groupId.isEmpty) return null;
    final doc = await _db.collection('groups').doc(groupId).get();
    return doc.data();
  }

  static Future<void> createGroup({
    required String groupName,
    String? description,
    required Uint8List? iconBytes,
  }) async {
    final uid = currentUid;
    final docRef = _db.collection('groups').doc();

    String iconUrl =
        'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/group_icons%2Fdefault.png?alt=media&token=0da944aa-d698-4cd6-b5cb-f4630b049cb3';

    if (iconBytes != null) {
      final fileName = 'group_icons/${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(iconBytes, SettableMetadata(contentType: 'image/png'));
      iconUrl = await ref.getDownloadURL();
    }

    final inviteCode = _generateInviteCode();

    await docRef.set({
      'name': groupName,
      'description': description ?? '',
      'iconUrl': iconUrl,
      'inviteCode': inviteCode,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
    });

    await _db.collection('users').doc(uid).update({
      'groupId': docRef.id,
      'status': 'manager',
    });
  }

  static Future<void> updateGroup({
    required String groupId,
    required String name,
    required String description,
    Uint8List? iconBytes,
  }) async {
    final Map<String, dynamic> updateData = {
      'name': name,
      'description': description,
    };

    if (iconBytes != null) {
      // 現在のiconUrlを取得して削除対象か確認
      final doc = await _db.collection('groups').doc(groupId).get();
      final oldIconUrl = doc.data()?['iconUrl'] as String? ?? '';
      if (oldIconUrl.isNotEmpty && !oldIconUrl.contains('default.png')) {
        try {
          final filePath = Uri.decodeFull(oldIconUrl.split('/o/')[1].split('?')[0]);
          await FirebaseStorage.instance.ref().child(filePath).delete();
          print('🧹 旧グループアイコン削除完了: $filePath');
        } catch (e) {
          print('⚠️ 旧グループアイコン削除失敗: $e');
        }
      }

      // 新しいアイコンをアップロード
      final fileName = 'group_icons/${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putData(iconBytes, SettableMetadata(contentType: 'image/png'));
      final iconUrl = await ref.getDownloadURL();
      updateData['iconUrl'] = iconUrl;
    }

    await _db.collection('groups').doc(groupId).update(updateData);
  }

  static Future<void> joinGroup(String groupId) async {
    final uid = currentUid;
    await _db.collection('users').doc(uid).update({
      'groupId': groupId,
      'status': 'member',
    });
  }

  static Future<void> deleteGroup(String groupId) async {
    if (groupId.isEmpty) return;

    final docRef = _db.collection('groups').doc(groupId);
    final doc = await docRef.get();

    if (!doc.exists) return;

    final data = doc.data();
    final iconUrl = data?['iconUrl'] as String? ?? '';

    if (iconUrl.isNotEmpty && !iconUrl.contains('default.png')) {
      try {
        final filePath = Uri.decodeFull(iconUrl.split('/o/')[1].split('?')[0]);
        await FirebaseStorage.instance.ref().child(filePath).delete();
        print('🧹 グループアイコン削除完了: $filePath');
      } catch (e) {
        print('⚠️ グループアイコン削除失敗: $e');
      }
    }

    await docRef.delete();
    print('✅ グループ $groupId を削除しました');
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
