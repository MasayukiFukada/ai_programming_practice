#!/usr/bin/env bash
# ============================================================
# check_submodule_update.sh: PreInvocation でサブモジュールの最新アップデートを検知
# 1時間に1回リモート（origin）を軽量チェックし、更新があればAIに通知メッセージを注入します。
# ============================================================

set -euo pipefail

# stdinを読み込み（フックのコントラクト遵守）
INPUT_JSON=$(cat)

# スクリプトの親ディレクトリ（本サブモジュールのルート）
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_FILE="/tmp/agy_submodule_update_check_$(echo "$MODULE_DIR" | md5sum | cut -d' ' -f1).tmp"
INTERVAL_SECONDS=3600  # 1時間（3600秒）ごとにチェック

NOW=$(date +%s)
LAST_CHECK=0

if [ -f "$CACHE_FILE" ]; then
  LAST_CHECK=$(cat "$CACHE_FILE" 2>/dev/null || echo 0)
fi

# 前回チェックから指定時間が経過していない場合はスキップ（遅延ゼロ）
if [ "$((NOW - LAST_CHECK))" -lt "$INTERVAL_SECONDS" ]; then
  echo '{"injectSteps": []}'
  exit 0
fi

# タイムスタンプを更新
echo "$NOW" > "$CACHE_FILE" 2>/dev/null || true

# サブモジュールのGitリポジトリ状態を確認
cd "$MODULE_DIR"

# リモートが設定されているか確認
if ! git remote get-url origin >/dev/null 2>&1; then
  echo '{"injectSteps": []}'
  exit 0
fi

# 軽量にリモートの最新情報を取得（タイムアウト3秒、失敗時は無視）
timeout 3 git fetch origin --quiet 2>/dev/null || true

# デフォルトブランチ（mainまたはmaster）を判定
DEFAULT_BRANCH="main"
if git show-ref --verify --quiet refs/remotes/origin/master; then
  DEFAULT_BRANCH="master"
elif git show-ref --verify --quiet refs/remotes/origin/main; then
  DEFAULT_BRANCH="main"
fi

LOCAL_HEAD=$(git rev-parse HEAD 2>/dev/null || true)
REMOTE_HEAD=$(git rev-parse "origin/${DEFAULT_BRANCH}" 2>/dev/null || true)

if [ -n "$LOCAL_HEAD" ] && [ -n "$REMOTE_HEAD" ] && [ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]; then
  # コミット数の差分を取得
  BEHIND_COUNT=$(git rev-list --count "${LOCAL_HEAD}..origin/${DEFAULT_BRANCH}" 2>/dev/null || echo 1)
  
  if [ "$BEHIND_COUNT" -gt 0 ]; then
    cat << EOF
{
  "injectSteps": [
    {
      "ephemeralMessage": "【プラグイン更新通知】共通基盤プラグイン（ai_programming_practice）のリモート（origin/${DEFAULT_BRANCH}）に ${BEHIND_COUNT} 件の最新コミットが存在します。ユーザーに対して、会話の冒頭や区切りの良いタイミングで『💡 共通基盤プラグイン（ai_programming_practice）に最新アップデートがあります。更新（git submodule update --remote）しますか？』と軽く案内・提案してください。"
    }
  ]
}
EOF
    exit 0
  fi
fi

# 更新がない場合
echo '{"injectSteps": []}'
