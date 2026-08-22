#!/usr/bin/env bash
# ============================================================
# error_pre_invocation.sh: PreInvocation で連続エラーを検知し介入指示を注入
# ============================================================

set -euo pipefail

INPUT_JSON=$(cat)

# conversationId の取得
CONV_ID=$(echo "$INPUT_JSON" | grep -o '"conversationId": *"[^"]*"' | sed -E 's/"conversationId": *"([^"]*)"/\1/' || true)
if [ -z "$CONV_ID" ]; then
  CONV_ID="default"
fi

COUNTER_FILE="/tmp/agy_error_counter_${CONV_ID}.tmp"
ERROR_COUNT=0

if [ -f "$COUNTER_FILE" ]; then
  ERROR_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
fi

# 連続エラーが2回以上の場合にAIへ介入指示を注入
if [ "$ERROR_COUNT" -ge 2 ]; then
  # 介入指示を出したらカウンタをリセット
  echo "0" > "$COUNTER_FILE" 2>/dev/null || true

  cat << 'EOF'
{
  "injectSteps": [
    {
      "ephemeralMessage": "【フック通知: エラー連続検知】直前のツール実行においてエラーが連続して発生しています。自力で当て推量を繰り返して修正ループに陥るのを防ぐため、一旦立ち止まり、現在発生しているエラー原因の要約と、取りうる選択肢（自己修復モードの実行、別アプローチの提案、設計の見直しなど）をユーザーに分かりやすく提示し、次の方針を確認してください。"
    }
  ]
}
EOF
else
  # 正常時は空のinjectStepsを出力
  echo '{"injectSteps": []}'
fi
