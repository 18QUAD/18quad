# Firestore スキーマ定義

## 🔹 users（ユーザー情報）

**コレクション名：** `users`

| フィールド名   | 型       | 説明               |
|----------------|----------|--------------------|
| displayName    | string   | 表示名             |
| email          | string   | メールアドレス     |
| groupId        | string   | 所属グループID     |
| status         | string   | グループでの役割   |
| iconUrl        | string   | アイコン画像URL     |
| createdAt      | timestamp| 作成日時           |

## 🔹 groups（グループ情報）

**コレクション名：** `groups`

| フィールド名   | 型       | 説明                     |
|----------------|----------|--------------------------|
| name           | string   | グループ名               |
| description    | string   | 説明文                   |
| iconUrl        | string   | アイコン画像URL          |
| inviteCode     | string   | 招待コード               |
| createdBy      | string   | 作成者のユーザーID       |
| ownerUid       | string   | オーナーのユーザーID     |
| createdAt      | timestamp| 作成日時                 |

## 🔹 groupRequests（グループ参加リクエスト）

**コレクション名：** `groupRequests`

| フィールド名   | 型       | 説明                                   |
|----------------|----------|----------------------------------------|
| requesterId    | string   | リクエストを送信したユーザーUID         |
| groupId        | string   | 申請対象のグループID                   |
| inviteCode     | string   | 入力した招待コード                     |
| message        | string   | 申請時のメッセージ（任意）             |
| status         | string   | 状態（pending, approved, rejected）    |
| createdAt      | timestamp| 作成日時                               |

## 🔹 notifications（通知）

**コレクション名：** `notifications`

| フィールド名   | 型       | 説明                 |
|----------------|----------|----------------------|
| toUid          | string   | 通知対象のユーザーID |
| message        | string   | 通知メッセージ       |
| timestamp      | timestamp| 送信日時             |
| isRead         | bool     | 既読フラグ           |
