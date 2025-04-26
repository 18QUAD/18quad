const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true }); // ★ 追加！
admin.initializeApp();

exports.createUser = functions.https.onRequest((req, res) => {
  cors(req, res, async () => { // ★ CORSラップする
    try {
      const { email, password, displayName } = req.body;

      if (!email || !password || !displayName) {
        res.status(400).send('Missing required fields: email, password, displayName');
        return;
      }

      // Firebase Authenticationにユーザー登録
      const userRecord = await admin.auth().createUser({
        email: email,
        password: password,
        displayName: displayName,
      });

      // Firestoreのusersコレクションにユーザー情報登録
      await admin.firestore().collection('users').doc(userRecord.uid).set({
        displayName: displayName,
        email: email,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // ★ ここを追加 → countsコレクションにも初期count=0を登録
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
