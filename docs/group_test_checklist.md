# ✅ グループ作成・変更・削除時のテスト項目一覧

## 🟢 グループ作成（createGroup）

- [ ] Firestore `/groups/{groupId}` が作成されている
- [ ] グループ名・紹介文・iconUrl が正しく保存されている
- [ ] アイコン画像が Storage にアップロードされている（デフォルト含む）
- [ ] Firestore `/users/{uid}` に `groupId` と `status: manager` が正しく登録されている
- [ ] 招待コード（inviteCode）が適切に生成されている（8桁英数）

## 🟡 グループ情報変更（updateGroup）

- [ ] Firestore `/groups/{groupId}` の name と description が更新される
- [ ] 新しいアイコン画像が Storage にアップロードされる
- [ ] 変更前のアイコン画像が Storage から削除される（default.png 以外）
- [ ] Firestoreの `iconUrl` が新しい画像URLに更新される
- [ ] アイコン画像を変更しない場合は Storage に余計な保存が発生しない

## 🔴 グループ削除（deleteGroup）

- [ ] Firestore `/groups/{groupId}` が削除される
- [ ] Storage 上のグループアイコン画像が削除される（default.png 以外）
- [ ] グループに所属していたユーザーの groupId, status はどうなるか（※将来検討）

## 🔐 セキュリティチェック（任意）

- [ ] 他ユーザーが他グループのデータを編集・削除できない（Security Rules）
- [ ] アイコン画像のURL漏洩がない（Storageアクセス制御が適切）