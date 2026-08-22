#!/usr/bin/env bash
# ============================================================
# error_post_tool.sh: PostToolUse でツールの成否を監視しエラーカウンタを更新
# ============================================================

set -euo pipefail

INPUT_JSON=$(cat)

# conversationId の取得
CONV_ID=$(echo "$INPUT_JSON" | grep -o '"conversationId": *"[^"]*"' | sed -E 's/"conversationId": *"([^"]*)"/\1/' || true)
if [ -z "$CONV_ID" ]; then
  CONV_ID="default"
fi

COUNTER_FILE="/tmp/agy_error_counter_${CONV_ID}.tmp"

# エラーフィールドの有無をチェック
HAS_ERROR=$(echo "$INPUT_JSON" | grep -o '"error": *"[^"]*"' || true)

if [ -n "$HAS_ERROR" ]; then
  # エラー発生時: カウンタをインクリメント
  CURRENT=0
  if [ -f "$COUNTER_FILE" ]; then
    CURRENT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
  fi
  NEXT=$((CURRENT + 1))
  echo "$NEXT" > "$COUNTER_FILE"
else
  # 成功時: カウンタをリセット
  echo "0" > "$COUNTER_FILE" 2>/dev/null || true
fi

# PostToolUse は空JSONを出力
echo '{}'
