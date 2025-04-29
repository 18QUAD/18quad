const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });

admin.initializeApp();

/**
 * 指定ドキュメントのサブコレクションを全削除
 */
async function deleteSubcollections(parentDocPath) {
  const parentDocRef = admin.firestore().doc(parentDocPath);
  const subcollections = await parentDocRef.listCollections();

  for (const subcollection of subcollections) {
    const subDocs = await subcollection.listDocuments();
    const deletePromises = subDocs.map(doc => doc.delete());
    await Promise.all(deletePromises);
    console.log(`✅ サブコレクション ${subcollection.id} 削除完了`);
  }
}

/**
 * ユーザー完全削除（Firestore + Storage + Auth）
 */
exports.deleteUserFully = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { uid } = req.body;
      if (!uid) return res.status(400).send('削除対象UIDが指定されていません');

      const userDocRef = admin.firestore().collection('users').doc(uid);
      const userDoc = await userDocRef.get();
      const iconUrl = userDoc.exists ? userDoc.data().iconUrl : null;

      await deleteSubcollections(`users/${uid}`);
      await userDocRef.delete();
      console.log(`✅ Firestore users/${uid} 削除完了`);

      if (iconUrl && !iconUrl.includes('default.png')) {
        try {
          const filePath = decodeURIComponent(iconUrl.split('/o/')[1].split('?')[0]);
          await admin.storage().bucket().file(filePath).delete();
          console.log(`🧹 ユーザー画像削除完了: ${filePath}`);
        } catch (e) {
          console.warn(`⚠️ Storage削除失敗: ${e.message}`);
        }
      }

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
 * ユーザー作成（管理者用）
 */
exports.createUser = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { email, password, displayName, iconUrl } = req.body;

      if (!email || !password || !displayName) {
        return res.status(400).send('Missing required fields');
      }

      const userRecord = await admin.auth().createUser({
        email, password, displayName,
      });

      const safeIconUrl = iconUrl?.trim()
        ? iconUrl
        : 'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

      await admin.firestore().collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email,
        displayName,
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

/**
 * ユーザーアイコン画像更新（旧画像を削除）
 */
exports.updateUserIcon = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { uid, newIconUrl } = req.body;
      if (!uid || !newIconUrl) return res.status(400).send('uidとnewIconUrlが必要です');

      const userRef = admin.firestore().collection('users').doc(uid);
      const userDoc = await userRef.get();
      const oldIconUrl = userDoc.data()?.iconUrl || '';

      if (oldIconUrl && !oldIconUrl.includes('default.png')) {
        try {
          const filePath = decodeURIComponent(oldIconUrl.split('/o/')[1].split('?')[0]);
          await admin.storage().bucket().file(filePath).delete();
          console.log(`🧹 旧ユーザー画像削除: ${filePath}`);
        } catch (e) {
          console.warn(`⚠️ 削除失敗: ${e.message}`);
        }
      }

      await userRef.update({ iconUrl: newIconUrl });
      res.status(200).send('ユーザーアイコン更新完了');
    } catch (e) {
      console.error('❌ updateUserIcon エラー:', e);
      res.status(500).send(`更新失敗: ${e.message}`);
    }
  });
});

/**
 * グループアイコン画像更新（旧画像を削除）
 */
exports.updateGroupIcon = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { groupId, newIconUrl } = req.body;
      if (!groupId || !newIconUrl) return res.status(400).send('groupIdとnewIconUrlが必要です');

      const groupRef = admin.firestore().collection('groups').doc(groupId);
      const groupDoc = await groupRef.get();
      const oldIconUrl = groupDoc.data()?.iconUrl || '';

      if (oldIconUrl && !oldIconUrl.includes('default.png')) {
        try {
          const filePath = decodeURIComponent(oldIconUrl.split('/o/')[1].split('?')[0]);
          await admin.storage().bucket().file(filePath).delete();
          console.log(`🧹 旧グループ画像削除: ${filePath}`);
        } catch (e) {
          console.warn(`⚠️ 削除失敗: ${e.message}`);
        }
      }

      await groupRef.update({ iconUrl: newIconUrl });
      res.status(200).send('グループアイコン更新完了');
    } catch (e) {
      console.error('❌ updateGroupIcon エラー:', e);
      res.status(500).send(`更新失敗: ${e.message}`);
    }
  });
});
