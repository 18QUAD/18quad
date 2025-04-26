const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
admin.initializeApp();

exports.createUser = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { email, password, displayName, iconUrl } = req.body; // ★ iconUrlも受け取る

      if (!email || !password || !displayName) {
        res.status(400).send('Missing required fields: email, password, displayName');
        return;
      }

      const safeIconUrl = iconUrl && iconUrl.trim() !== '' 
        ? iconUrl 
        : 'https://example.com/default-icon.png'; // ★ 空だったらデフォルト設定

      // Firebase Authentication にユーザー登録（photoURL設定しない）
      const userRecord = await admin.auth().createUser({
        email: email,
        password: password,
        displayName: displayName,
      });

      // Firestoreのusersコレクションにユーザー情報登録
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        displayName: displayName,
        email: email,
        iconUrl: safeIconUrl, // ★ ここに保存
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // countsコレクションにも初期count=0登録
      await admin.firestore().collection('counts').doc(userRecord.uid).set({
        count: 0,
      });

      res.status(200).send(`Successfully created user: ${userRecord.uid}`);
    } catch (error) {
      console.error('Error creating user:', error);
      res.status(500).send(`Error creating user: ${error.message}`);
    }
  });
});
