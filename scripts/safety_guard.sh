#!/usr/bin/env bash
# ============================================================
# safety_guard.sh: PreToolUse 安全ガードスクリプト
# 破壊的・危険なコマンドを検知し、ユーザー確認 (decision: ask) を要求します。
# ============================================================

set -euo pipefail

# stdinからJSON入力を読み込む
INPUT_JSON=$(cat)

# コマンド文字列を抽出
COMMAND_LINE=$(echo "$INPUT_JSON" | grep -o '"CommandLine": *"[^"]*"' | sed -E 's/"CommandLine": *"([^"]*)"/\1/' || true)

if [ -z "$COMMAND_LINE" ]; then
  # コマンドがない（別ツールの呼び出し等）場合は許可
  echo '{"decision": "allow"}'
  exit 0
fi

# 危険なコマンドパターンのチェック
DANGEROUS_REASONS=""

# 1. 強制プッシュ / ハードリセット / 破壊的Git操作
if echo "$COMMAND_LINE" | grep -qE 'git +push +.*(-f|--force)|git +reset +--hard|git +clean +-fdx'; then
  DANGEROUS_REASONS="破壊的なGit操作（強制プッシュ/ハードリセット/クリーン）"
# 2. ルートや広範なディレクトリの強制削除
elif echo "$COMMAND_LINE" | grep -qE 'rm +-rf +(/|\~|\.|\.\./|\*|\$HOME)'; then
  DANGEROUS_REASONS="広範囲・重要ディレクトリの強制削除（rm -rf）"
# 3. 機密ファイル（.env, *.pem, *.key, id_rsa等）の削除・上書き
elif echo "$COMMAND_LINE" | grep -qE '(rm|shred|truncate) +.*(\.env|\.pem|\.key|id_rsa)'; then
  DANGEROUS_REASONS="機密ファイル（.env / 鍵ファイル）の削除・変更操作"
# 4. ディスクフォーマット・システム変更
elif echo "$COMMAND_LINE" | grep -qE '(mkfs|dd +if=|fdisk|chmod +-R +777 +/)'; then
  DANGEROUS_REASONS="システム・ディスクに対する危険な低レベル操作"
fi

if [ -n "$DANGEROUS_REASONS" ]; then
  # 危険な操作を検知した場合はユーザーに確認を求める
  ESC_CMD=$(echo "$COMMAND_LINE" | sed 's/"/\\"/g')
  echo "{\"decision\": \"ask\", \"reason\": \"⚠️ 【安全ガード】危険な操作の可能性を検知しました: ${DANGEROUS_REASONS} (コマンド: ${ESC_CMD})。実行を許可しますか？\"}"
else
  # 安全なコマンドは自動許可
  echo '{"decision": "allow"}'
fi
