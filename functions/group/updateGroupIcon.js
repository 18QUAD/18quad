import { onRequest } from 'firebase-functions/v2/https';
import { db } from '../firebase.config.js';

export const updateGroupIcon = onRequest(async (req, res) => {
  try {
    const { groupId, iconUrl } = req.body;
    if (!groupId || !iconUrl) return res.status(400).send('Missing groupId or iconUrl');

    await db.collection('groups').doc(groupId).update({ iconUrl });
    res.status(200).send('Group icon updated successfully');
  } catch (error) {
    console.error('Error updating group icon:', error);
    res.status(500).send('Internal server error');
  }
});
