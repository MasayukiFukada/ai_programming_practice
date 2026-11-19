#!/usr/bin/env bash
# ==============================================================================
# setup_global.sh: Antigravity グローバル共通基盤セットアップスクリプト
#
# 本リポジトリの skills/ rules/ を ~/.gemini/config/ 配下にシンボリックリンクし、
# 軽量コア（rules/global_core.md）をグローバル AGENTS.md へ展開登録します。
# ==============================================================================

set -euo pipefail

usage() {
    cat << 'EOF'
Usage: setup_global.sh [OPTIONS]

Options:
  --migrate    既存の ~/.gemini/config/AGENTS.md のバックアップを作成し、
               軽量コア (rules/global_core.md) 構成へ移行（置換）します。
  -h, --help   このヘルプを表示します。
EOF
}

MIGRATE=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --migrate)
            MIGRATE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "エラー: 不明なオプションです: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GEMINI_CONFIG_DIR="${HOME}/.gemini/config"
GLOBAL_AGENTS_MD="${GEMINI_CONFIG_DIR}/AGENTS.md"

echo "=== Antigravity グローバル共通基盤セットアップ ==="
echo "リポジトリパス: ${REPO_ROOT}"
echo "グローバル設定パス: ${GEMINI_CONFIG_DIR}"
echo ""

# 1. ~/.gemini/config ディレクトリの確保
mkdir -p "${GEMINI_CONFIG_DIR}"

# 2. skills/ のシンボリックリンク作成
if [ -L "${GEMINI_CONFIG_DIR}/skills" ]; then
    echo "✔ skills シンボリックリンクは既に存在します: $(readlink "${GEMINI_CONFIG_DIR}/skills")"
elif [ -e "${GEMINI_CONFIG_DIR}/skills" ]; then
    echo "⚠ ${GEMINI_CONFIG_DIR}/skills が既存のディレクトリ/ファイルとして存在します。スキップします。"
else
    ln -s "${REPO_ROOT}/skills" "${GEMINI_CONFIG_DIR}/skills"
    echo "✔ skills シンボリックリンクを作成しました -> ${REPO_ROOT}/skills"
fi

# 3. rules/ のシンボリックリンク作成
if [ -L "${GEMINI_CONFIG_DIR}/rules" ]; then
    echo "✔ rules シンボリックリンクは既に存在します: $(readlink "${GEMINI_CONFIG_DIR}/rules")"
elif [ -e "${GEMINI_CONFIG_DIR}/rules" ]; then
    echo "⚠ ${GEMINI_CONFIG_DIR}/rules が既存のディレクトリ/ファイルとして存在します。スキップします。"
else
    ln -s "${REPO_ROOT}/rules" "${GEMINI_CONFIG_DIR}/rules"
    echo "✔ rules シンボリックリンクを作成しました -> ${REPO_ROOT}/rules"
fi

# 4. commands/ のシンボリックリンク作成（~/.gemini/commands 配下）
GEMINI_COMMANDS_DIR="${HOME}/.gemini/commands"
mkdir -p "${GEMINI_COMMANDS_DIR}"
if [ -d "${REPO_ROOT}/commands" ]; then
    for cmd_file in "${REPO_ROOT}/commands"/*.toml; do
        [ -e "${cmd_file}" ] || continue
        cmd_name="$(basename "${cmd_file}")"
        target_link="${GEMINI_COMMANDS_DIR}/${cmd_name}"
        if [ -L "${target_link}" ]; then
            echo "✔ commands/${cmd_name} シンボリックリンクは既に存在します: $(readlink "${target_link}")"
        elif [ -e "${target_link}" ]; then
            echo "⚠ ${target_link} が既存ファイルとして存在します。バックアップを作成してリンクを作成します。"
            mv "${target_link}" "${target_link}.bak"
            ln -s "${cmd_file}" "${target_link}"
            echo "✔ commands/${cmd_name} をリンクしました（既存ファイルを .bak に退避） -> ${cmd_file}"
        else
            ln -s "${cmd_file}" "${target_link}"
            echo "✔ commands/${cmd_name} シンボリックリンクを作成しました -> ${cmd_file}"
        fi
    done
fi

# 5. ~/.gemini/config/AGENTS.md への軽量コア登録・移行
GLOBAL_CORE_PATH="${REPO_ROOT}/rules/global_core.md"
GLOBAL_CORE_INCLUDE="@[global_core](${GLOBAL_CORE_PATH})"

write_slim_global_agents() {
    cat << EOF > "${GLOBAL_AGENTS_MD}"
# グローバル共通エージェント設定

${GLOBAL_CORE_INCLUDE}
EOF
}

if [ ! -f "${GLOBAL_AGENTS_MD}" ]; then
    write_slim_global_agents
    echo "✔ ${GLOBAL_AGENTS_MD} を新規作成し、軽量コア（global_core.md）を登録しました。"
elif [ "${MIGRATE}" = true ]; then
    BACKUP_PATH="${GLOBAL_AGENTS_MD}.bak.$(date +%Y%m%d%H%M%S)"
    if [ -e "${BACKUP_PATH}" ]; then
        BACKUP_PATH="${BACKUP_PATH}.$$"
    fi
    cp -p "${GLOBAL_AGENTS_MD}" "${BACKUP_PATH}"
    write_slim_global_agents
    echo "✔ 既存ファイルをバックアップし、軽量コア構成へ移行しました: ${BACKUP_PATH}"
    echo "  ※ ユーザー独自の追記があった場合は、バックアップから必要な行のみ転記してください。"
else
    if grep -Eq "character_personas\.md|vcs_jujutsu_priority\.md|model_escalation_strategy\.md" "${GLOBAL_AGENTS_MD}"; then
        echo "⚠ 旧構成（3ファイル丸ごと展開・24KB上限超過リスクあり）を検出しました。"
        echo "  ./scripts/setup_global.sh --migrate を実行すると、バックアップを作成して軽量コアへ移行できます。"
    elif grep -Fq "@[global_core](" "${GLOBAL_AGENTS_MD}"; then
        echo "✔ ${GLOBAL_AGENTS_MD} には既に軽量コア（global_core.md）が登録されています。"
    else
        printf '\n%s\n' "${GLOBAL_CORE_INCLUDE}" >> "${GLOBAL_AGENTS_MD}"
        echo "✔ ${GLOBAL_AGENTS_MD} の末尾に軽量コア（global_core.md）を追記・登録しました。"
    fi
fi

echo ""
echo "=== セットアップが完了しました ==="
echo "これで、マシン上のどのプロジェクトでも共通スキルおよび軽量コア設定が有効になります。"
