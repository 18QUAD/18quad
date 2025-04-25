const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.createUser = functions.https.onRequest(async (req, res) => {
  const { email, password, displayName } = req.body;

  if (!email || !password || !displayName) {
    res.status(400).send({ error: "email, password, displayName are required" });
    return;
  }

  try {
    // Firebase Auth にユーザー作成
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName,
    });

    // Firestore の counts に登録
    await admin.firestore().collection("counts").doc(userRecord.uid).set({
      displayName,
      email,
      count: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).send({ uid: userRecord.uid });
  } catch (error) {
    console.error("Error creating user:", error);
    res.status(500).send({ error: error.message });
  }
});
