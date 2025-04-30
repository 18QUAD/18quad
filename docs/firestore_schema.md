# Firestore データ構造定義（18QUAD 2025-04-30時点）

---

## 🔹 users（ユーザー情報）

**コレクション名：** `users`

| フィールド名   | 型       | 説明                                      |
|----------------|----------|-------------------------------------------|
| uid            | string   | ユーザーのUID（ドキュメントIDと一致）      |
| displayName    | string   | 表示名                                    |
| email          | string   | メールアドレス（認証に使用）              |
| iconUrl        | string   | プロフィール画像のURL（空ならデフォルト）  |
| groupId        | string   | 所属グループID（未所属なら空）             |
| status         | string   | 状態（none, member, manager）             |
| createdAt      | timestamp| 登録日時                                  |

---

### 🔸 サブコレクション：users/{uid}/counts

| ドキュメントID | 説明       |
|----------------|------------|
| {uid}          | 自分自身のカウント |

| フィールド名 | 型     | 説明         |
|--------------|--------|--------------|
| count        | number | 連打カウント |

---

### 🔸 サブコレクション：users/{uid}/group_requests

| フィールド名   | 型       | 説明                                   |
|----------------|----------|----------------------------------------|
| requesterId    | string   | リクエストを送信したユーザーUID         |
| groupId        | string   | 申請対象のグループID                   |
| inviteCode     | string   | 入力した招待コード                     |
| message        | string   | 申請時のメッセージ（任意）             |
| status         | string   | 状態（pending, approved, rejected）    |
| createdAt      | timestamp| 作成日時                               |

---

## 🔹 groups（グループ情報）

**コレクション名：** `groups`

| フィールド名   | 型       | 説明                                  |
|----------------|----------|---------------------------------------|
| name           | string   | グループ名                            |
| description    | string   | グループ紹介文（任意）                |
| iconUrl        | string   | グループ画像URL                       |
| inviteCode     | string   | 招待コード                            |
| createdBy      | string   | 作成者UID                             |
| ownerUid       | string   | グループ長UID（承認者）               |
| createdAt      | timestamp| 作成日時                              |

---

## 🔹 notifications（通知）

**コレクション名：** `notifications`

| フィールド名 | 型       | 説明                                     |
|--------------|----------|------------------------------------------|
| toUid        | string   | 通知対象ユーザーUID                      |
| message      | string   | 通知本文                                 |
| timestamp    | timestamp| 通知作成日時                             |
| isRead       | boolean  | 既読フラグ（false = 未読, true = 既読）   |

---

## 🔹 その他：セキュリティルール想定

- `users/{uid}`：`request.auth.uid == uid`
- `users/{uid}/group_requests`：`request.auth.uid == uid`
- `groups`：読み取りは全体公開、書き込みは `createdBy == request.auth.uid`
- `notifications`：`toUid == request.auth.uid`

---

## 🔚 備考

- `counts` はユーザーサブコレクション化（2025-04更新）
- `group_requests` もサブコレ化し、ユーザー単位のアクセス制御を強化
- 通知はリアルタイム性と既読管理を考慮して分離設計

---
