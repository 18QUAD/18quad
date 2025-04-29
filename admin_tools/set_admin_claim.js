/**
 * Firebase Authentication カスタムクレーム設定スクリプト
 * 対象UIDに { admin: true } を付与する
 */

const admin = require('firebase-admin');

// ① サービスアカウントキーを使って初期化
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// ② 管理者にしたい対象UID
const targetUid = 'SKilNoUgiWRYSSMuuDAKY5rYPMu1';

async function setAdminClaim() {
  try {
    await admin.auth().setCustomUserClaims(targetUid, { admin: true });
    console.log(`✅ UID(${targetUid}) に admin:true を設定しました。`);
    process.exit(0);
  } catch (error) {
    console.error('❌ エラー:', error);
    process.exit(1);
  }
}

setAdminClaim();
