# ✅ ユーザー登録・変更・削除時のテスト項目一覧

## 🟢 ユーザー登録（createUser）

- [ ] Firebase Auth にユーザーが作成されている（UID・メール）
- [ ] Firestore `/users/{uid}` が作成されている（email, displayName, iconUrl 等）
- [ ] Firestore `/users/{uid}/counts/{uid}` が count = 0 で作成されている
- [ ] `iconUrl` にデフォルト画像が設定されている
- [ ] UID が一意で、同じメールで重複登録できない
- [ ] グループ未参加で登録されている（groupId: "", status: none）

## 🟡 ユーザー情報変更

- [ ] 表示名が Auth と Firestore 両方で更新される
- [ ] パスワード変更が成功し、再ログイン可能
- [ ] アイコン画像が Storage に新規保存される
- [ ] アイコン変更前の画像が Storage から削除される（default.png 以外）
- [ ] `iconUrl` が Firestore に正しく更新される
- [ ] 同じ画像が別ユーザーと共有されていない（URLが一意）
- [ ] アイコン未選択で更新してもエラーにならない

## 🔴 ユーザー削除（deleteUserFully）

- [ ] Firestore `/users/{uid}` が削除されている
- [ ] Firestore `/users/{uid}/counts/{uid}` も削除されている
- [ ] Firebase Auth の UID が削除されている
- [ ] Storage 上のアイコン画像が削除されている（default.png 以外）
- [ ] default.png の画像は削除されない
- [ ] 削除済み UID で再ログインできない

## 🔐 セキュリティチェック（任意）

- [ ] 他ユーザーの Firestore データが読めない（Security Rules）
- [ ] groupId や status がクライアントから改ざんできない
- [ ] Storage の画像 URL が漏れていない（不正共有されていない）