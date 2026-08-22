#!/usr/bin/env bash
# ============================================================
# doc_drift_checker.sh: PreInvocation でコードとドキュメントの乖離を検知
# ソースコード変更があるのにドキュメント（README.mdやdocs/）が未更新の場合、
# AI（コハク）から自然にドキュメント更新を提案するリマインダーを注入します。
# ============================================================

set -euo pipefail

INPUT_JSON=$(cat)

CONV_ID=$(echo "$INPUT_JSON" | grep -o '"conversationId": *"[^"]*"' | sed -E 's/"conversationId": *"([^"]*)"/\1/' || true)
if [ -z "$CONV_ID" ]; then
  CONV_ID="default"
fi

CACHE_FILE="/tmp/agy_doc_drift_notified_${CONV_ID}.tmp"

# 同一セッション内で通知済みの場合は重複を抑制（1回のセッションでうるさくならないように制御）
if [ -f "$CACHE_FILE" ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# Git管理下でない場合はスキップ
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo '{"injectSteps": []}'
  exit 0
fi

# 変更されたファイル一覧を取得（未コミットの変更＋ステージング）
CHANGED_FILES=$(git status --porcelain 2>/dev/null | awk '{print $2}' || true)

if [ -z "$CHANGED_FILES" ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# ソースコードの変更があるか判定
HAS_CODE_CHANGES=false
if echo "$CHANGED_FILES" | grep -qE '\.(ts|tsx|js|jsx|py|rs|go|java|cpp|c|cs|rb|php|swift|kt)$'; then
  HAS_CODE_CHANGES=true
fi

# ドキュメント（README.mdやdocs/配下）の変更があるか判定
HAS_DOC_CHANGES=false
if echo "$CHANGED_FILES" | grep -qE '^(README\.md|docs/.*|.*\.doc\.md)$'; then
  HAS_DOC_CHANGES=true
fi

# ソースコードが変更されているが、ドキュメントが未更新の場合にリマインダーを注入
if [ "$HAS_CODE_CHANGES" = true ] && [ "$HAS_DOC_CHANGES" = false ]; then
  # 通知済みフラグを記録
  echo "1" > "$CACHE_FILE" 2>/dev/null || true

  cat << 'EOF'
{
  "injectSteps": [
    {
      "ephemeralMessage": "【ドキュメント更新リマインダー】機能コード（ソースコード）の変更が検知されましたが、README.md や docs/ 配下のドキュメントが未更新です。タスク完了時やコミット提案前の区切りの良いタイミングで、コハク（ドキュメント担当）のペルソナを用いて『主殿、機能の実装は整ったようじゃが、README.md や docs/ の仕様ドキュメントの更新もやっておくか？』と軽く提案してください。"
    }
  ]
}
EOF
  exit 0
fi

echo '{"injectSteps": []}'
