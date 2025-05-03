import { onRequest } from 'firebase-functions/v2/https';
import { auth, db } from '../firebase.config.js';

export const deleteUser = onRequest(async (req, res) => {
  try {
    const { uid } = req.body;
    if (!uid) return res.status(400).send('Missing UID');

    await auth.deleteUser(uid);
    await db.collection('users').doc(uid).delete();

    res.status(200).send('User deleted successfully');
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).send('Internal server error');
  }
});
