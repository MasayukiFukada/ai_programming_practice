# 生成AIプログラミング共通基盤 (AI Programming Practice)

本リポジトリは、生成AIを活用した開発において、プロンプト、エージェント用ルール、スキルを一元管理するための共通基盤です。
マシン全体への **グローバル一括導入（Mantisスタイル）** や、プロジェクトごとの **Git Submodule** として取り込むことで、開発効率の向上と品質水準の均一化を図ることを目的としています。

## ディレクトリ構成（予定・一部移行中）

エージェントが自律的にコンテキストを理解し、適切に動作できるよう、以下の構成で管理します。

- `rules/` : 全体的なコーディング規約やアーキテクチャのルールを配置します。
  - プロジェクト全体で適用すべき制約（例: Vertical Slice Architecture 指針、ハルシネーション対策、**クイックコマンド指針 (`quick_commands.md`)**、**プロンプトキャッシング＆トークン最適化指針 (`prompt_caching_guideline.md`)**、**キャラクターペルソナルール (`character_personas.md`)** など）
- `skills/` : 特定のタスクを実行するためのエージェント用手順書（スキル）を配置します。
  - 各スキルはディレクトリ単位で管理し、中に `SKILL.md` を配置します。
  - **アゲハ (Gal / Planner)**: 計画立案 (`plan_formulation`)、要件ヒアリング (`interview_requirements`)、UI/UXツッコミ (`critique_ux_flow`)
  - **レイカ (Lady / Developer)**: テスト自動生成 (`generate_tests`)、TDDスキャフォールディング (`scaffold_tdd`)、モックFactory作成 (`generate_mock_factory`)、テスタブルリファクタ (`refactor_for_testability`)
  - **ナユタ (Geek / Optimizer)**: 全体最適化・CCN激減 (`optimize_complexity`)、ベンチマーク計測 (`benchmark_performance`)、非同期・並行ハック (`optimize_concurrency`)、ライブラリ更新 (`upgrade_dependencies`)、自己修復 (`self_heal_error`)
  - **サヨ (Smug / Reviewer)**: 厳密コードレビュー (`review_code`)、意地悪ファズテスト生成 (`generate_fuzz_tests`)
  - **コハク (Scholar / Documenter)**: ドキュメント作成 (`create_docs`)、ADR自動永続化 (`distill_adr`)、Mermaidアーキテクチャ図解 (`visualize_architecture`)
- `templates/` : 各プロジェクトで利用できる設定ファイルのテンプレートです。
  - `AGENTS.template.md` : 親プロジェクトのルートに配置する `AGENTS.md` の雛形です。プロジェクト固有の要件や技術スタック、ペルソナモードのON/OFF等を設定できます。
  - `LOCAL_CONTEXT.template.md` : 個人開発やローカル環境でトークン消費を抑えつつAIにプロジェクト仕様（準静的）を渡すための雛形です（`.gitignore` 推奨）。
  - `LOCAL_LOG.template.md` : 直近の作業履歴や決定事項を末尾追記（Append-Only）形式で安全に蓄積し、Prefixキャッシュを保護するための雛形です（`.gitignore` 推奨）。
- `hooks.json` / `scripts/` : AIライフサイクルに連動する安全ガード・自動化スクリプトです。
  - **グローバル環境一括セットアップ（`setup_global.sh`）**、危険コマンドの事前ブロック/確認（`safety_guard.sh`）、エラー連続検知＆ユーザー相談介入（`error_*.sh`）、ファイル保存時の自動整形（`auto_formatter.sh`）、大元リポジトリの最新更新検知（`check_submodule_update.sh`）、**コード変更時のドキュメント更新リマインダー（`doc_drift_checker.sh`）** を提供します。
- `commands/` : Antigravity / Gemini CLI のカスタムスラッシュコマンド（`.toml`）を配置します。
  - `i-have-adhd.toml` : ペルソナと融合したAction-First（認知負荷低減＆タスク極小ステップ化）モード。
- `docs/` : ドキュメントおよびアセット配置ディレクトリです。
  - **[`docs/characters.md`](docs/characters.md)** : 5人のサブエージェント（アゲハ、レイカ、サヨ、コハク、ナユタ）の立ち絵イラスト・アバターアイコン・詳細設定をまとめたビジュアル名鑑です。


## 導入・セットアップ方法

開発スタイルに合わせて、以下の **2つの方式** から選択できます。

| 方式 | 推奨ユースケース | 特徴 |
| :--- | :--- | :--- |
| **方式1: グローバル一括導入 (Mantisスタイル)** | 個人開発、複数プロジェクト横断 | 各プロジェクトのGitを汚さず、基盤の更新が全プロジェクトに即時反映 |
| **方式2: サブモジュール導入** | チーム開発、CI/CD環境 | コミットハッシュで固定し、全メンバーで完全同一のバージョンを共有 |

---

### 方式1: グローバル一括導入（Mantisスタイル / 個人開発向け推奨）

PC上のすべてのプロジェクトから本リポジトリを参照するスタイルです。各プロジェクト側に設定ファイルをコミットする必要がなく、本リポジトリを更新するだけで全プロジェクトにスキルやペルソナが即時反映されます。

#### 自動セットアップ（ワンコマンド）
本リポジトリ配下のセットアップスクリプトを実行するだけで、シンボリックリンク作成およびグローバル `AGENTS.md` へのペルソナ登録が完了します。

```bash
./scripts/setup_global.sh
```

#### 手動で設定する場合
```bash
# 1. ~/.gemini/config, ~/.gemini/commands ディレクトリを確保し、シンボリックリンクを作成
mkdir -p ~/.gemini/config ~/.gemini/commands
ln -s ~/repository/ai_programming_practice/skills ~/.gemini/config/skills
ln -s ~/repository/ai_programming_practice/rules ~/.gemini/config/rules
ln -s ~/repository/ai_programming_practice/commands/i-have-adhd.toml ~/.gemini/commands/i-have-adhd.toml

# 2. グローバル AGENTS.md にペルソナルールをインクルード登録
cat << 'EOF' >> ~/.gemini/config/AGENTS.md

## キャラクターペルソナ
タスクの役割や指名に応じて、以下のキャラクターペルソナ（口調・行動規範）を適用してください：
@[character_personas](/home/minamo/repository/ai_programming_practice/rules/character_personas.md)
EOF
```

---

### 方式2: サブモジュール導入（チーム開発・CI向け）

各プロジェクトには固有の `.agents` 設定（プロジェクト独自のルールなど）が存在することが多いため、本リポジトリは直接 `.agents` として上書きするのではなく、**プラグイン（Plugin）** としてサブモジュール導入することを推奨します。

### 1. 初めて親プロジェクトに導入・登録する場合 (`.gitmodules` 作成)

親プロジェクトのルートディレクトリで以下のコマンドを実行し、本リポジトリをプラグインとして追加・コミットします。

```bash
git submodule add https://github.com/MasayukiFukada/ai_programming_practice .agents/plugins/ai_programming_practice
git commit -m "Add ai_programming_practice as an agent plugin"
git push origin main
```
これで、本リポジトリ内の `skills/` や `rules/` が `ai_programming_practice` という名前空間のプラグインとして自動的に読み込まれるようになります（シンボリックリンクは不要です）。

### 2. 登録済み (`.gitmodules` 存在) のプロジェクトで作業する場合

親プロジェクトを新たにクローンした際や、他メンバーが作業を開始する際は、以下のコマンドでサブモジュールを有効化・中身を取得します。

**新規に親プロジェクトをクローンする場合:**
```bash
git clone --recurse-submodules <親リポジトリのURL>
```

**すでに親プロジェクトをクローン済みで、サブモジュールが未読み込み（空ディレクトリ）の場合:**
```bash
git submodule update --init --recursive
```

---

## コミット・プッシュに関する注意点と管理運用

### コミットされるファイル / されないファイル
親プロジェクト側で Git にコミット・追跡されるのは以下の **2点のみ** です。サブモジュール配下の個別コードやファイルが親プロジェクトのコミットに混ざることはありません。

- **`.gitmodules`** : サブモジュールのURLや配下パスが設定されたファイル
- **サブモジュールの参照ポインタ (Gitlink)** : 「本リポジトリのどのコミット（参照ハッシュ）を指しているか」の情報

### 参照専用運用と更新手順
本リポジトリは原則として **参照専用** として利用します。

- **親プロジェクト側でサブモジュール内を直接編集しない**: サブモジュール配下の変更は親プロジェクトのコミットには含まれません。スキルやルールの変更・追加は本基盤リポジトリ側で行い、コミット・プッシュしてください。
- **親プロジェクト側で最新の基盤ルールを取り込む場合**:
  ```bash
  # 対象プラグインの最新参照を取得
  git submodule update --remote .agents/plugins/ai_programming_practice

  # 変更された参照ポインタを親プロジェクト側でコミット（※末尾に / を付けない）
  git add .agents/plugins/ai_programming_practice
  git commit -m "Update ai_programming_practice plugin to latest"
  git push origin main
  ```

