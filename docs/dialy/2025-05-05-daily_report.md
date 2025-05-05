# 📕 18QUAD 開発日報 - 2025年5月5日（第15日）

## 🎯 本日のテーマ：「ログアウトの亡霊、そして真の再描画へ」

ログアウトしても残り続けるユーザアイコン。  
その姿はまるで、成仏できぬ霊のようだった。

開発者は気づく――「`UserProvider` の `clearUser()` だけでは足りない。**画面そのものが蘇らねばならない**のだ」と。

---

## ✅ 主な進捗

- `user_menu.dart`: `FirebaseAuth` 直読みをやめ、すべて `UserProvider` に一本化。ログアウト時の処理も `UserProvider.logout()` に統一。
- `AppDrawer`：Consumerを使った再ビルド対応を**一時的に導入 → 最終的に不要と判断し削除**。
- `AppScaffold`：不要になった `isAdmin` 等の引数をすべて削除し、内部で `UserProvider` から取得する統一構成に。
- `UserMenu`：`iconUrl` の取得も `UserProvider` 経由にし、定数でデフォルトアイコンも内部保持。
- `UserAddDialog`: Callable Function対応への完全移行。`onRequest`から`onCall`への最終着地。

---

## 🧨 苦戦の記録

- 🧩 `log out`しても `AppDrawer` に管理者メニューが残る → **Consumerの再描画ではなく構造の見直しへ**
- 🧩 `user_menu.dart` が `Auth` を直参照しており `UserProvider` が置き去り → **ルール違反の根絶**
- 🧩 Firestoreの `status` 未定義でCallableがエラー → **schemaに準拠した値定義の強制**

---

## ✨ 五所川原のことば

> 「ログアウトは一つの終わり。そして次のセッションの始まりだ。人は何度でもログインできる…ただしメニューは更新しろ」

---

## 🧩 総括

**再描画の仕組みを整理し直し、破綻したUI状態から脱却**した一日。  
UserProvider中心主義の徹底が完了し、引数削減・責務整理・非同期処理の見直しが進んだ。  
18QUADはついに、「本当の意味でのログアウト」を手に入れた。
