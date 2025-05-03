# Firestore データ構造定義（18QUAD 2025-05-01時点）

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

## 🔹 daily_counts（連打記録ログ）

**コレクション名：** `daily_counts`

| フィールド名 | 型       | 説明                     |
|--------------|----------|--------------------------|
| uid          | string   | ユーザーUID              |
| day          | string   | 日付（yyyy-MM-dd）       |
| month        | string   | 月（yyyy-MM）            |
| year         | string   | 年（yyyy）               |
| groupId      | string   | 所属グループID           |
| count        | number   | カウント数               |
| updatedAt    | timestamp| 最終更新日時             |

※ ドキュメントIDは `${uid}_${day}` 形式

---

## 🔹 monthly_counts_users（個人 月別集計）

| フィールド名 | 型     | 説明                     |
|--------------|--------|--------------------------|
| uid          | string | ユーザーUID              |
| month        | string | 月（yyyy-MM）            |
| year         | string | 年（yyyy）               |
| count        | number | 月間累計カウント         |

※ ドキュメントIDは `${month}_${uid}` 形式

---

## 🔹 yearly_counts_users（個人 年別集計）

| フィールド名 | 型     | 説明                     |
|--------------|--------|--------------------------|
| uid          | string | ユーザーUID              |
| year         | string | 年（yyyy）               |
| count        | number | 年間累計カウント         |

※ ドキュメントIDは `${year}_${uid}` 形式

---

## 🔹 total_counts_users（個人 通算集計）

| フィールド名 | 型     | 説明                     |
|--------------|--------|--------------------------|
| uid          | string | ユーザーUID              |
| count        | number | 通算累計カウント         |

※ ドキュメントIDは `uid`

---

## 🔹 daily_counts_groups（グループ集計・日単位）

| フィールド名 | 型     | 説明                     |
|--------------|--------|--------------------------|
| groupId      | string | グループID               |
| day          | string | 日付（yyyy-MM-dd）       |
| month        | string | 月（yyyy-MM）            |
| year         | string | 年（yyyy）               |
| count        | number | グループの合計カウント   |
| updatedAt    | timestamp | 集計日時              |

※ コレクションはサブコレクションとして設計される場合あり

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

## 🔹 セキュリティルール想定（抜粋）

- `users/{uid}`：`request.auth.uid == uid`
- `users/{uid}/group_requests`：`request.auth.uid == uid`
- `groups`：読み取りは全体公開、書き込みは `createdBy == request.auth.uid`
- `notifications`：`toUid == request.auth.uid`
- `daily_counts` / `*_counts_*`：読み取り制限（必要に応じて管理者のみ）

---

## 🔚 備考

- `counts` は `daily_counts` に一本化（2025-05更新）
- 個人集計・グループ集計はそれぞれ専用コレクションに責務分離
- 書き込み間隔はパラメータ制御に移行（高負荷時対応）
- ランキング表示の期間別集計は `*_counts_users` で対応済
