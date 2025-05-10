# 📕 18QUAD 開発日報 - 2025年5月10日（第20日）

## 🧠 タイトル：「誤認の沼地に挑む、反復抑制の剣」

かつて、18QUADという名のアプリは、あらゆるものに化けていた。  
Cloud Functionsの管理ツールになりすまし、データ基盤に擬態し、  
挙げ句の果てには「Cloud Firestore SDK Client SDK Client Client Client...」と**永劫回帰の地獄ループ**に突入した──

だが今日は違った。

---

## 🛠️ 本日の進捗ログ

- 🧱 **repetition_penalty=1.2** を武器に「ループ地獄」へ決別。
- ⚔️ `inference_lora.py` と `run_lora_train_and_infer_param.py` を完全対応版に修正。
- 📂 生成された**誤認系jsonlは累計30種以上**。特に以下を重点補強：
  - GCP管理ツール型誤認
  - DAO／eスポーツ化
  - Flutter構造体と誤認
  - SNS・社内ツール化
  - Cloud Firestore SDK SDK SDK SDK SDK... の業
- 🧠 推論出力の質が着実に改善。
  - 「FlutterとFirebaseを使ったタップ記録アプリです」まで正確に言及するように！
  - ただし「プロジェクトではない」「管理画面なし」「戦略的基盤にはならない」など**否定文ループがまだ多い**。

---

## 📊 LoRA訓練状況

- LoRA学習済み + 推論進行OK
- 明日、訂正jsonl群を再投入して再学習予定
- モデル暴走も「repetition_penalty」によって抑制中

---

## 💬 総括：今日の一言

> **「誤認が崩れ落ちる音が聞こえた。あとは真実を焼き付けるだけだ。」**

明日はいよいよ“訂正jsonl大収束祭”。  
もう、DAOにもGCPにも戻らせはしない。

---

（了）
