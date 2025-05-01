import { onRequest } from 'firebase-functions/v2/https';
import { db } from '../firebase.config.js';

export const updateUserIcon = onRequest(async (req, res) => {
  try {
    const { uid, iconUrl } = req.body;
    if (!uid || !iconUrl) return res.status(400).send('Missing uid or iconUrl');

    await db.collection('users').doc(uid).update({ iconUrl });
    res.status(200).send('User icon updated successfully');
  } catch (error) {
    console.error('Error updating user icon:', error);
    res.status(500).send('Internal server error');
  }
});
