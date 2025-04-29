const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true }); // CORS対応

admin.initializeApp();

/**
 * 指定ドキュメントのサブコレクションすべてを削除する関数
 */
async function deleteSubcollections(parentDocPath) {
  const parentDocRef = admin.firestore().doc(parentDocPath);
  const subcollections = await parentDocRef.listCollections();

  for (const subcollection of subcollections) {
    const subDocs = await subcollection.listDocuments();
    const deletePromises = subDocs.map(doc => doc.delete());
    await Promise.all(deletePromises);
    console.log(`✅ サブコレクション ${subcollection.id} を削除完了`);
  }
}

/**
 * 管理者専用：Firebase Authenticationユーザーと関連Firestoreデータを完全削除する（CORS対応）
 */
exports.deleteUserFully = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { uid } = req.body;

      if (!uid) {
        res.status(400).send('削除対象UIDが指定されていません');
        return;
      }

      // Firestore: users/{uid}配下のサブコレクションを削除
      await deleteSubcollections(`users/${uid}`);

      // Firestore: users/{uid}ドキュメントを削除
      await admin.firestore().collection('users').doc(uid).delete();
      console.log(`✅ Firestore users/${uid} 削除完了`);

      // Firebase Authentication: ユーザーアカウント削除
      await admin.auth().deleteUser(uid);
      console.log(`✅ Authentication UID(${uid}) 削除完了`);

      res.status(200).send(`UID(${uid}) を完全削除しました`);
    } catch (error) {
      console.error('❌ 完全削除エラー:', error);
      res.status(500).send(`完全削除に失敗しました: ${error.message}`);
    }
  });
});

/**
 * 新規ユーザー作成 (管理者専用、countsサブコレクション版)
 */
exports.createUser = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { email, password, displayName, iconUrl } = req.body;

      if (!email || !password || !displayName) {
        res.status(400).send('Missing required fields');
        return;
      }

      const userRecord = await admin.auth().createUser({
        email: email,
        password: password,
        displayName: displayName,
      });

      const safeIconUrl = typeof iconUrl === 'string' && iconUrl.trim() !== ''
        ? iconUrl
        : 'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

      await admin.firestore().collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: email,
        displayName: displayName,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        iconUrl: safeIconUrl,
        status: 'none',
        groupId: '',
      });

      await admin.firestore()
        .collection('users')
        .doc(userRecord.uid)
        .collection('counts')
        .doc(userRecord.uid)
        .set({
          count: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

      res.status(200).send('User created successfully');
    } catch (error) {
      console.error('Error creating user:', error);
      res.status(500).send('Internal server error');
    }
  });
});
