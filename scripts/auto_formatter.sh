#!/usr/bin/env bash
# ============================================================
# auto_formatter.sh: PostToolUse でファイル変更時に自動フォーマットを適用
# トークン消費 0 でコードのインデントやスタイルを自動維持します。
# ============================================================

set -euo pipefail

INPUT_JSON=$(cat)

# 変更対象のファイルパスを抽出
TARGET_FILE=$(echo "$INPUT_JSON" | grep -o '"TargetFile": *"[^"]*"' | sed -E 's/"TargetFile": *"([^"]*)"/\1/' || true)

if [ -n "$TARGET_FILE" ] && [ -f "$TARGET_FILE" ]; then
  # 拡張子に応じたフォーマッタの実行（存在する場合のみ、バックグラウンド/サイレント）
  case "$TARGET_FILE" in
    *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
      if command -v npx >/dev/null 2>&1 && [ -f "package.json" ]; then
        npx --no-install prettier --write "$TARGET_FILE" >/dev/null 2>&1 || true
      fi
      ;;
    *.py)
      if command -v ruff >/dev/null 2>&1; then
        ruff format "$TARGET_FILE" >/dev/null 2>&1 || true
      elif command -v black >/dev/null 2>&1; then
        black --quiet "$TARGET_FILE" >/dev/null 2>&1 || true
      fi
      ;;
    *.rs)
      if command -v rustfmt >/dev/null 2>&1; then
        rustfmt "$TARGET_FILE" >/dev/null 2>&1 || true
      fi
      ;;
    *.go)
      if command -v gofmt >/dev/null 2>&1; then
        gofmt -w "$TARGET_FILE" >/dev/null 2>&1 || true
      fi
      ;;
  esac
fi

# PostToolUse は空JSONを出力
echo '{}'
