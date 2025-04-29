
---

## 📄 users

ユーザー情報を保持するルートコレクション。  
`uid` は Firebase Authentication に連動。

| フィールド名 | 型 | 説明 |
|:---|:---|:---|
| displayName | string | 表示名 |
| email | string | メールアドレス（認証と一致） |
| iconUrl | string | ユーザーアイコン画像URL |
| groupId | string | 所属グループID（未所属時は空文字） |
| status | string | none / member / manager |
| createdAt | timestamp | 登録時刻 |

---

## 📄 counts（users/{uid}/counts サブコレクション）

ユーザーごとの「連打数」記録。  
1ユーザーにつき1ドキュメント（uid一致）。

| フィールド名 | 型 | 説明 |
|:---|:---|:---|
| count | int | 連打数（初期値0） |
| createdAt | timestamp | 作成日時 |

📌 集計には `collectionGroup('counts')` を使用する。

---

## 📄 group_requests（users/{uid}/group_requests サブコレクション）※設計済

「グループ参加申請」データ。  
管理者による承認・拒否操作の対象。

| フィールド名 | 型 | 説明 |
|:---|:---|:---|
| inviteCode | string | 招待コード or グループ識別子 |
| status | string | pending / approved / rejected |
| createdAt | timestamp | リクエスト生成日時 |

---

## 📄 groups

ユーザーが作成する「グループ」を管理するルートコレクション。  
各ユーザーの `groupId` により所属を紐付ける。

| フィールド名 | 型 | 説明 |
|:---|:---|:---|
| groupName | string | グループの表示名 |
| ownerUid | string | グループ作成者のUID |
| createdAt | timestamp | 作成日時 |

📌 グループに所属中のユーザーは `users.status = member` または `manager` として区別される。

---

## 🚫 非推奨構成（旧仕様）

かつて使用していたが現在は廃止済みのトップレベル構成：

- `/counts/{uid}` ❌ → `/users/{uid}/counts/{uid}` に統合
- `/group_requests/{doc}` ❌ → `/users/{uid}/group_requests/{doc}` に統合予定

---

## ✅ メモ

- ユーザー作成：Cloud Functions `createUser`
- ユーザー削除：Cloud Functions `deleteUserFully`（Authentication含め完全削除）
- Web向け関数：すべて CORS 対応済（Flutter Web対応完了）

