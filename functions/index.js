const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true }); // CORS対応

admin.initializeApp();

exports.createUser = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { email, password, displayName, iconUrl } = req.body;

      if (!email || !password || !displayName) {
        res.status(400).send('Missing required fields');
        return;
      }

      // Firebase Authenticationにユーザー登録
      const userRecord = await admin.auth().createUser({
        email: email,
        password: password,
        displayName: displayName,
      });

      // アイコンURLの補完
      const safeIconUrl = typeof iconUrl === 'string' && iconUrl.trim() !== ''
        ? iconUrl
        : 'https://firebasestorage.googleapis.com/v0/b/quad-2c91f.firebasestorage.app/o/user_icons%2Fdefault.png?alt=media&token=a2b91b53-2904-4601-b734-fbf92bc82ade';

      // Firestoreのusersコレクションに登録
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: email,
        displayName: displayName,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        iconUrl: safeIconUrl,
        status: 'none',
        groupId: '', // ★ここ追加！（初期は空）
      });

      // Firestoreのcountsコレクションにも初期登録
      await admin.firestore().collection('counts').doc(userRecord.uid).set({
        uid: userRecord.uid,
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
