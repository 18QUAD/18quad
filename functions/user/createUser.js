import { onRequest } from 'firebase-functions/v2/https';
import { auth, db } from '../firebase.config.js';
import { FieldValue } from 'firebase-admin/firestore';

export const createUser = onRequest(async (req, res) => {
  try {
    const { email, password, displayName } = req.body;
    if (!email || !password || !displayName) {
      return res.status(400).send('Missing required fields');
    }

    const userRecord = await auth.createUser({ email, password, displayName });
    await db.collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      displayName,
      createdAt: FieldValue.serverTimestamp(),
      status: 'none',
      groupId: '',
      iconUrl: '',
    });

    res.status(200).send('User created successfully');
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).send('Internal server error');
  }
});
