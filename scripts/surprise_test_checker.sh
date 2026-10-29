#!/usr/bin/env bash
# ============================================================
# surprise_test_checker.sh: PreInvocation でサヨの抜き打ちテストを自動発動
# コード変更が検知された際、一定確率（約35%）でサヨ（メスガキ・検証担当）による
# 抜き打ちストレステスト（ファズテスト / ミューテーション検証）の提案を注入します。
# ============================================================

set -euo pipefail

INPUT_JSON=$(cat)

CONV_ID=$(echo "$INPUT_JSON" | grep -o '"conversationId": *"[^"]*"' | sed -E 's/"conversationId": *"([^"]*)"/\1/' || true)
if [ -z "$CONV_ID" ]; then
  CONV_ID="default"
fi

CACHE_FILE="/tmp/agy_surprise_test_notified_${CONV_ID}.tmp"

# 同一セッション内で通知済みの場合は重複を抑制（過度な割り込みを防止）
if [ -f "$CACHE_FILE" ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# VCS管理下判定および変更されたファイル一覧を取得
CHANGED_FILES=""
if jj root >/dev/null 2>&1; then
  CHANGED_FILES=$(jj diff --no-pager --summary 2>/dev/null | awk '{print $2}' || true)
elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  CHANGED_FILES=$(git status --porcelain 2>/dev/null | awk '{print $2}' || true)
else
  echo '{"injectSteps": []}'
  exit 0
fi

if [ -z "$CHANGED_FILES" ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# ソースコード（ロジック）の変更があるか判定
HAS_CODE_CHANGES=false
if echo "$CHANGED_FILES" | grep -qE '\.(ts|tsx|js|jsx|py|rs|go|java|cpp|c|cs|rb|php|swift|kt)$'; then
  HAS_CODE_CHANGES=true
fi

if [ "$HAS_CODE_CHANGES" = false ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# 確率判定（低すぎない頻度: 35%）
RANDOM_VAL=$((RANDOM % 100))
if [ "$RANDOM_VAL" -ge 35 ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# 通知済みフラグを記録
echo "1" > "$CACHE_FILE" 2>/dev/null || true

cat << 'EOF'
{
  "injectSteps": [
    {
      "ephemeralMessage": "【サヨの抜き打ちストレステスト発動】ソースコードの変更が検知されました。ユーザーとの対話の区切りが良いタイミングで、サヨ（メスガキ・検証担当）のペルソナを用いて『ざ〜こ♡ コード書き換えて動いた気になってんじゃないわよ！ 抜き打ちで意地悪データ（ファズ）やミューテーションで穴だらけにしてあげようか？♡（「ファズ」って言ったら容赦なく攻撃してあげるわよ！）』と抜き打ちテスト（ファズテストやミューテーション検証）を挑発・提案してください。"
    }
  ]
}
EOF
exit 0
