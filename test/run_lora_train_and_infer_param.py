import os
import gc
import torch
import argparse
import subprocess

parser = argparse.ArgumentParser(description="LoRA学習後に推論を行うスクリプト")
parser.add_argument("--prompt", type=str, required=True, help="推論に使うプロンプト文字列")
parser.add_argument("--max_new_tokens", type=int, default=256, help="生成するトークン数の上限")
parser.add_argument("--repetition_penalty", type=float, default=1.2, help="繰り返し抑制の強さ")

args = parser.parse_args()
prompt = args.prompt
max_new_tokens = args.max_new_tokens
repetition_penalty = args.repetition_penalty

# === ステップ1: 学習
print("🚀 LoRA学習を開始します...")
with open("train_log.txt", "w", encoding="utf-8") as log_file:
    process = subprocess.Popen(
        ["python", "train_all_jsonl.py"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        bufsize=1,
        universal_newlines=True
    )
    for line in process.stdout:
        print(line, end="")
        log_file.write(line)
    process.wait()
    print("✅ LoRA学習が完了しました。")

# === ステップ2: GPUメモリを明示的に解放
print("🧹 GPUメモリを解放中...")
gc.collect()
if torch.cuda.is_available():
    torch.cuda.empty_cache()
    torch.cuda.ipc_collect()

# === ステップ3: 推論
print("🤖 推論を開始します...")
with open("inference_log.txt", "w", encoding="utf-8") as infer_log:
    process = subprocess.Popen(
        [
            "python", "inference_lora.py",
            "--prompt", prompt,
            "--base_model", "meta-llama/Meta-Llama-3-8B-Instruct",
            "--adapter_path", "./lora-llama3-output",
            "--max_new_tokens", str(max_new_tokens),
            "--repetition_penalty", str(repetition_penalty)
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        bufsize=1,
        universal_newlines=True
    )
    for line in process.stdout:
        print(line, end="")
        infer_log.write(line)
    process.wait()
    print("✅ 推論が完了しました。")
