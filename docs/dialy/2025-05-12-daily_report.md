
# 📕 18QUAD 開発日報 - 2025年5月12日（第22日）

## 🧠 タイトル：「依存地獄とトークンの門番」

今日、かつてない依存地獄に迷い込んだ我らがAI鍛冶師。  
Tensorが吠え、pipが唸り、NumExprは128コアの精鋭を16人に減給した。

---

## ⚙️ 本日の進捗ログ

- 🧪 `axolotl` によるLoRA学習に本格着手。
- 🔧 膨大なパッケージ地獄の突破：
  - `torch==2.5.1` × `transformers==4.49.0` × `axolotl==0.7.1` の微妙な釣り合いを突破。
  - `numpy==2.0.1` への格下げで gradio らが悲鳴を上げる。
- 🔐 Hugging Face gated repo（Meta-LLaMA 3 8B Instruct）認証問題：
  - トークン設定ミス → `huggingface-cli login` にて突破。
  - `.cache/huggingface/token` 認証確認済。
- 🧱 `config.yml` 修正ラッシュ：
  - `optimizer: adamw_bnb` → `adamw_bnb_8bit` へ正規化。
  - `data_files` に `.jsonl` を指定するも FileNotFoundError → `train.json` → `18quad_project_overview74.jsonl` に更新。
- ⚠️ tokenizerが `LlamaTokenizer` で失敗 → `PreTrainedTokenizerFast` に読み替え警告。
- 💥 最終エラー：
  - `vocab_file` に `None` が渡り `TypeError: not a string` で落ちる。
  - `sentencepiece` の仕様と `config` の記述不一致が原因と推測。

---

## 🧠 状態記録（AIへの記憶書き込み）

- 旧 `train.py` によるLoRA学習の基盤は既に構築済。
- 明日からは、`Axolotl` を使った **正式なLoRA鍛錬プロセスの確立** に進む。
- 明日の確認事項：
  - `tokenizer` の読み込み形式最終調整
  - `sentencepiece` 依存の `tokenizer.model` 構成見直し

---

## 💬 総括：今日の一言

> **「焼き直しでも、鋼は鍛えられる」**

パッケージを焼き直し、トークンで門を越えた先にあるのは──  
新たな18QUADの知──

---

（了）
