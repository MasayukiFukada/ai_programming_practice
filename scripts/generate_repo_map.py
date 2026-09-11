#!/usr/bin/env python3
"""
generate_repo_map.py
リポジトリのソースコードから関数・クラス・型の定義（骨格）を抽出し、
トークン消費を最小化しながらコードベース全体を把握できる Repo-Map を生成します。

外部依存ライブラリなし（Python 3 標準ライブラリのみ）で動作します。
"""

import ast
import os
import re
import sys
from pathlib import Path

# 無視するディレクトリ・パターン
IGNORED_DIRS = {
    ".git", ".jj", "node_modules", "dist", "build", "target",
    "__pycache__", ".venv", "venv", "env", ".mypy_cache",
    ".pytest_cache", ".ruff_cache", ".next", ".nuxt", ".gemini",
    ".idea", ".vscode", "coverage", ".coverage"
}

# 解析対象の拡張子
SUPPORTED_EXTENSIONS = {
    ".py", ".ts", ".tsx", ".js", ".jsx", ".go", ".rs"
}


def parse_python_ast(file_path: Path) -> list[str]:
    """Pythonファイルを ast で解析し、クラスと関数のシグネチャを抽出"""
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
        tree = ast.parse(content, filename=str(file_path))
    except Exception:
        return []

    lines = []
    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            lines.append(f"  class {node.name}:")
            for sub_node in node.body:
                if isinstance(sub_node, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    prefix = "async def" if isinstance(sub_node, ast.AsyncFunctionDef) else "def"
                    args = [a.arg for a in sub_node.args.args]
                    lines.append(f"    {prefix} {sub_node.name}({', '.join(args)})")
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            prefix = "async def" if isinstance(node, ast.AsyncFunctionDef) else "def"
            args = [a.arg for a in node.args.args]
            lines.append(f"  {prefix} {node.name}({', '.join(args)})")
    return lines


def parse_typescript_js(file_path: Path) -> list[str]:
    """TypeScript / JavaScript ファイルから export された型・関数・クラスを抽出"""
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return []

    lines = []
    # export interface, type, class, enum, function
    patterns = [
        r"^\s*export\s+(?:default\s+)?(?:async\s+)?function\s+([a-zA-Z0-9_$]+)\s*\([^)]*\)",
        r"^\s*export\s+(?:abstract\s+)?class\s+([a-zA-Z0-9_$]+)",
        r"^\s*export\s+interface\s+([a-zA-Z0-9_$]+)",
        r"^\s*export\s+type\s+([a-zA-Z0-9_$]+)",
        r"^\s*export\s+enum\s+([a-zA-Z0-9_$]+)",
        r"^\s*export\s+const\s+([a-zA-Z0-9_$]+)\s*=",
    ]
    
    for raw_line in content.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("//") or line.startswith("/*"):
            continue
        for p in patterns:
            m = re.match(p, raw_line)
            if m:
                # 簡潔な表現にトリミング
                clean_stmt = line.split("{")[0].rstrip()
                if clean_stmt.endswith("="):
                    clean_stmt = f"export const {m.group(1)}"
                lines.append(f"  {clean_stmt}")
                break
    return lines


def parse_go(file_path: Path) -> list[str]:
    """Goファイルから関数、構造体、インターフェースを抽出"""
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return []

    lines = []
    func_pattern = re.compile(r"^func\s+(\([^)]+\)\s+)?([A-Z][a-zA-Z0-9_]*)\s*\([^)]*\)")
    type_pattern = re.compile(r"^type\s+([A-Z][a-zA-Z0-9_]*)\s+(struct|interface)")

    for raw_line in content.splitlines():
        line = raw_line.strip()
        fm = func_pattern.match(line)
        if fm:
            clean = line.split("{")[0].rstrip()
            lines.append(f"  {clean}")
            continue
        tm = type_pattern.match(line)
        if tm:
            lines.append(f"  type {tm.group(1)} {tm.group(2)}")
    return lines


def parse_rust(file_path: Path) -> list[str]:
    """Rustファイルから公開関数・構造体・Enum・Traitを抽出"""
    try:
        content = file_path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return []

    lines = []
    patterns = [
        re.compile(r"^\s*pub\s+(?:async\s+)?fn\s+([a-zA-Z0-9_]+)\s*\([^)]*\)"),
        re.compile(r"^\s*pub\s+struct\s+([a-zA-Z0-9_]+)"),
        re.compile(r"^\s*pub\s+enum\s+([a-zA-Z0-9_]+)"),
        re.compile(r"^\s*pub\s+trait\s+([a-zA-Z0-9_]+)"),
    ]

    for raw_line in content.splitlines():
        line = raw_line.strip()
        for p in patterns:
            if p.match(line):
                clean = line.split("{")[0].rstrip(" ;")
                lines.append(f"  {clean}")
                break
    return lines


def extract_file_symbols(file_path: Path) -> list[str]:
    """拡張子に応じてシンボルを抽出"""
    ext = file_path.suffix.lower()
    if ext == ".py":
        return parse_python_ast(file_path)
    elif ext in {".ts", ".tsx", ".js", ".jsx"}:
        return parse_typescript_js(file_path)
    elif ext == ".go":
        return parse_go(file_path)
    elif ext == ".rs":
        return parse_rust(file_path)
    return []


def generate_repo_map(target_dir: Path) -> str:
    """ディレクトリ全体を探索して Repo-Map 文字列を生成"""
    repo_map = []
    repo_map.append(f"# Repo-Map: {target_dir.resolve().name}")
    repo_map.append(f"# Root: {target_dir.resolve()}\n")

    total_files = 0
    total_symbols = 0

    # ディレクトリを再帰走査（ソートして安定した順序を保証）
    all_files = []
    for root, dirs, files in os.walk(target_dir):
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS and not d.startswith(".")]
        for file in files:
            p = Path(root) / file
            if p.suffix.lower() in SUPPORTED_EXTENSIONS:
                all_files.append(p)

    all_files.sort()

    for file_path in all_files:
        symbols = extract_file_symbols(file_path)
        if symbols:
            rel_path = file_path.relative_to(target_dir)
            repo_map.append(str(rel_path))
            repo_map.extend(symbols)
            repo_map.append("")  # 空行
            total_files += 1
            total_symbols += len(symbols)

    repo_map.append(f"# Summary: {total_files} files mapped, {total_symbols} total symbols identified.")
    return "\n".join(repo_map)


def main():
    target_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    if not target_path.exists():
        print(f"Error: Target path does not exist: {target_path}", file=sys.stderr)
        sys.exit(1)

    result = generate_repo_map(target_path)
    print(result)


if __name__ == "__main__":
    main()
