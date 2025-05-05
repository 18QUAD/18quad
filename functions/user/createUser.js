import { onCall } from 'firebase-functions/v2/https';
import { auth, db } from '../firebase.config.js';
import { FieldValue } from 'firebase-admin/firestore';

export const createUser = onCall(async (request) => {
  try {
    const { email, password, displayName } = request.data;

    if (!email || !password || !displayName) {
      throw new Error('Missing required fields');
    }

    const userRecord = await auth.createUser({
      email,
      password,
      displayName,
    });

    await db.collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      displayName,
      createdAt: FieldValue.serverTimestamp(),
      status: 'none',
      groupId: '',
      iconUrl: '',
    });

    return { success: true };
  } catch (error) {
    console.error('Error creating user:', error);
    throw new Error('Internal server error');
  }
});
