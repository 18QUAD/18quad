import { onSchedule } from 'firebase-functions/v2/scheduler';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../firebase.config.js';

export const aggregateCountsAll = onSchedule(
  { schedule: 'every day 01:30', timeZone: 'Asia/Tokyo' },
  async () => {
    const snapshot = await db.collection('daily_counts').get();

    const monthlyUsers = {}, yearlyUsers = {}, totalUsers = {};
    const monthlyGroups = {}, yearlyGroups = {}, totalGroups = {};

    snapshot.forEach((doc) => {
      const data = doc.data();
      const uid = data.uid;
      const groupId = data.groupId || 'unknown';
      const count = data.count || 0;
      const month = data.month;
      const year = data.year;

      const keyMonthlyUser = `${month}_${uid}`;
      const keyYearlyUser = `${year}_${uid}`;
      const keyMonthlyGroup = `${month}_${groupId}`;
      const keyYearlyGroup = `${year}_${groupId}`;

      monthlyUsers[keyMonthlyUser] = (monthlyUsers[keyMonthlyUser] || 0) + count;
      yearlyUsers[keyYearlyUser] = (yearlyUsers[keyYearlyUser] || 0) + count;
      totalUsers[uid] = (totalUsers[uid] || 0) + count;

      monthlyGroups[keyMonthlyGroup] = (monthlyGroups[keyMonthlyGroup] || 0) + count;
      yearlyGroups[keyYearlyGroup] = (yearlyGroups[keyYearlyGroup] || 0) + count;
      totalGroups[groupId] = (totalGroups[groupId] || 0) + count;
    });

    const batch = db.batch();

    Object.entries(monthlyUsers).forEach(([key, count]) => {
      const [month, uid] = key.split('_');
      const ref = db.collection('monthly_counts_users').doc(key);
      batch.set(ref, {
        uid,
        month,
        year: month.slice(0, 4),
        count,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    Object.entries(yearlyUsers).forEach(([key, count]) => {
      const [year, uid] = key.split('_');
      const ref = db.collection('yearly_counts_users').doc(key);
      batch.set(ref, {
        uid,
        year,
        count,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    Object.entries(totalUsers).forEach(([uid, count]) => {
      const ref = db.collection('total_counts_users').doc(uid);
      batch.set(ref, {
        uid,
        count,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    Object.entries(monthlyGroups).forEach(([key, count]) => {
      const [month, groupId] = key.split('_');
      const ref = db.collection('monthly_counts_groups').doc(key);
      batch.set(ref, {
        groupId,
        month,
        year: month.slice(0, 4),
        count,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    Object.entries(yearlyGroups).forEach(([key, count]) => {
      const [year, groupId] = key.split('_');
      const ref = db.collection('yearly_counts_groups').doc(key);
      batch.set(ref, {
        groupId,
        year,
        count,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    Object.entries(totalGroups).forEach(([groupId, count]) => {
      const ref = db.collection('total_counts_groups').doc(groupId);
      batch.set(ref, {
        groupId,
        count,
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    await batch.commit();
    console.log(`✅ 集計完了: 個人/月(${Object.keys(monthlyUsers).length}), 年(${Object.keys(yearlyUsers).length}), 総(${Object.keys(totalUsers).length}) / グループ/月(${Object.keys(monthlyGroups).length}), 年(${Object.keys(yearlyGroups).length}), 総(${Object.keys(totalGroups).length})`);
  }
);
