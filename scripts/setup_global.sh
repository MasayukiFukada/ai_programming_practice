#!/usr/bin/env bash
# ==============================================================================
# setup_global.sh: Antigravity グローバル共通基盤セットアップスクリプト
#
# 本リポジトリの skills/ rules/ を ~/.gemini/config/ 配下にシンボリックリンクし、
# グローバル AGENTS.md にペルソナ展開設定を追記・登録します。
# ==============================================================================

set -euo pipefail

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

# 5. ~/.gemini/config/AGENTS.md へのペルソナ・VCS優先ルールの登録
PERSONA_PATH="${REPO_ROOT}/rules/character_personas.md"
PERSONA_INCLUDE="@[character_personas](${PERSONA_PATH})"
VCS_PATH="${REPO_ROOT}/rules/vcs_jujutsu_priority.md"
VCS_INCLUDE="@[vcs_jujutsu_priority](${VCS_PATH})"

if [ ! -f "${GLOBAL_AGENTS_MD}" ]; then
    cat << EOF > "${GLOBAL_AGENTS_MD}"
# グローバル共通エージェント設定

## キャラクターペルソナ
タスクの役割や指名に応じて、以下のキャラクターペルソナ（口調・行動規範）を適用してください：
${PERSONA_INCLUDE}

## バージョン管理システム（VCS）
リポジトリ内に \`.jj/\` が存在するか \`jj root\` が成功する場合、Git よりも **Jujutsu (\`jj\`)** を最優先で使用してください（例: \`jj status\`, \`jj diff\`, \`jj describe\`, \`jj commit\`, \`jj log\`）。
${VCS_INCLUDE}
EOF
    echo "✔ ${GLOBAL_AGENTS_MD} を新規作成し、ペルソナおよびJujutsu優先ルールを登録しました。"
else
    if ! grep -Fq "${PERSONA_INCLUDE}" "${GLOBAL_AGENTS_MD}" && ! grep -Fq "character_personas.md" "${GLOBAL_AGENTS_MD}"; then
        cat << EOF >> "${GLOBAL_AGENTS_MD}"

## キャラクターペルソナ
タスクの役割や指名に応じて、以下のキャラクターペルソナ（口調・行動規範）を適用してください：
${PERSONA_INCLUDE}
EOF
        echo "✔ ${GLOBAL_AGENTS_MD} にペルソナルールを追記・登録しました。"
    else
        echo "✔ ${GLOBAL_AGENTS_MD} には既にペルソナルールが登録されています。"
    fi

    if ! grep -Fq "${VCS_INCLUDE}" "${GLOBAL_AGENTS_MD}" && ! grep -Fq "vcs_jujutsu_priority.md" "${GLOBAL_AGENTS_MD}"; then
        cat << EOF >> "${GLOBAL_AGENTS_MD}"

## バージョン管理システム（VCS）
リポジトリ内に \`.jj/\` が存在するか \`jj root\` が成功する場合、Git よりも **Jujutsu (\`jj\`)** を最優先で使用してください（例: \`jj status\`, \`jj diff\`, \`jj describe\`, \`jj commit\`, \`jj log\`）。
${VCS_INCLUDE}
EOF
        echo "✔ ${GLOBAL_AGENTS_MD} にJujutsu優先ルールを追記・登録しました。"
    else
        echo "✔ ${GLOBAL_AGENTS_MD} には既にJujutsu優先ルールが登録されています。"
    fi
fi

echo ""
echo "=== セットアップが完了しました ==="
echo "これで、マシン上のどのプロジェクトでも共通スキルおよびペルソナが常時有効になります。"
