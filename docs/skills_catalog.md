# スキルカタログ・クイックリファレンス (Skills Catalog)

本リポジトリに収録されている全20種類の自律エージェント用スキルの一覧表です。
各スキルの担当ペルソナ、推奨モデル階層（Model Tier）、起動クイックコマンド、および役割をまとめています。

---

## 📋 全20スキル早見表

| スキル名 | 担当ペルソナ | 推奨モデル階層 | クイックコマンド | 主な役割とユースケース |
| :--- | :--- | :---: | :--- | :--- |
| **`plan_formulation`** | アゲハ (Gal) | `Standard` / `High-Reasoning` | 「計画」「方針」 | 技術選定や方針決定のトレードオフ（利点・欠点）を比較提示 |
| **`interview_requirements`** | アゲハ (Gal) | `Standard` | 「ヒアリング」「要件」 | フワッとした要望に対し鋭い逆質問で仕様や境界条件を明確化 |
| **`critique_ux_flow`** | アゲハ (Gal) | `Standard` | 「UX」「導線」 | UI/UX導線・操作フロー・文言の直感性をギャル目線でレビュー |
| **`scaffold_tdd`** | レイカ (Lady) | `High-Reasoning` | 「TDD」 | 実装前に仕様を満たすテストケース（Red）を先行生成 |
| **`generate_tests`** | レイカ (Lady) | `High-Reasoning` / `Inherit` | 「テスト」「単体テスト」 | 実装コードに対する網羅的エッジケース・異常系テストの自動生成 |
| **`generate_mock_factory`** | レイカ (Lady) | `Lightweight` / `Standard` | 「モック」「factory」 | 型定義に準拠したテスト用ダミーデータやFactory関数をお仕立て |
| **`refactor_for_testability`** | レイカ (Lady) | `High-Reasoning` | 「リファクタ」「純粋関数」 | 密結合・副作用を持つコードをテスタブルな純粋関数へ再構築 |
| **`scaffold_vsa`** | レイカ (Lady) | `Inherit` | 「スライス」「vsa」 | Vertical Slice Architecture に準拠した新機能の雛形を生成 |
| **`optimize_complexity`** | ナユタ (Geek) | **`High-Reasoning`** | 「最適化」「CCN」「複雑度」 | 全体構造を俯瞰し、CCN激減・計算量次元削減（$O(N^2) \to O(1)$）を実行 |
| **`benchmark_performance`** | ナユタ (Geek) | `High-Reasoning` / `Inherit` | 「ベンチ」「計測」 | 処理速度やメモリ消費のベンチマーク計測と改善効果の定量証明 |
| **`optimize_concurrency`** | ナユタ (Geek) | **`High-Reasoning`** | 「並行」「async」 | 非同期処理の直列化ボトルネック解消、Promise.all/Worker最適化 |
| **`upgrade_dependencies`** | ナユタ / レイカ | `High-Reasoning` | 「アプデ」「更新」 | 依存ライブラリの最新安定版アップグレードと破壊的変更の安全移行 |
| **`self_heal_error`** | ナユタ / アゲハ | **`High-Reasoning`** | 「修復」「自己修復」 | ビルド・テストエラーの根本原因特定と段階的修復（難航時相談） |
| **`review_code`** | サヨ (Smug) | **`Standard`** (通常)<br>/ **`High-Reasoning`** (厳密) | 「レビュー」「review」<br>（厳密時は「厳密レビュー」） | 6大観点・重要度付き厳密レビューとJSON出力（日常は `Standard` でクォータ保護、厳密時は `High-Reasoning`） |
| **`generate_fuzz_tests`** | サヨ (Smug) | **`High-Reasoning`** | 「ファズ」「意地悪」 | 極悪・意地悪データ（絵文字・極大・SQLi等）による攻撃テスト作成 |
| **`create_docs`** | コハク (Scholar) | `Standard` | 「ドキュメント」「仕様書」 | コードやアーキテクチャから人間向けの設計書・ドキュメントを生成 |
| **`distill_adr`** | コハク (Scholar) | `Standard` | 「ADR」「設計判断」 | 議論や作業履歴から「なぜその設計にしたか」を抽出しADR化 |
| **`visualize_architecture`** | コハク (Scholar) | `Standard` | 「図解」「シーケンス」「ER」 | 依存関係やデータフローをMermaid記法の図解（シーケンス/ER等）で可視化 |
| **`complex_task_delegation`**| オーケストレーター | `High-Reasoning` / `Inherit` | 「委譲」「並行」 | 複雑なタスクを複数サブエージェントに分割して協調進行（ネイティブ分離時は調査・独立レビュー・並列作業に特化） |
| **`setup_project_agents`** | コハク (Scholar) | `Inherit` | 「セットアップ」「初期化」 | 親プロジェクトの初期化支援（`AGENTS.md` 作成や `.gitignore` 設定） |

---

## 🎯 モデル階層（Model Tier）の使い分け指針

- **`High-Reasoning`（上位推論・高精度）**:
  - 核心的なロジック実装（`scaffold_tdd`, `refactor_for_testability`）
  - 全体最適化・CCN激減（`optimize_complexity`, `optimize_concurrency`）
  - 独立客観レビュー・脆弱性検証（`review_code`, `generate_fuzz_tests`）
  - エラー泥沼化時の根本原因特定（`self_heal_error`）
- **`Standard`（標準・バランス）**:
  - 要件ヒアリング、UIツッコミ（`interview_requirements`, `critique_ux_flow`）
  - ドキュメント作成、ADR蒸留、Mermaid図解（`create_docs`, `distill_adr`, `visualize_architecture`）
- **`Lightweight`（最軽量・高速）**:
  - モックやダミーデータの機械的生成（`generate_mock_factory`）
  - 定型フォーマット変換

※ネイティブの計画/実行分離（Planner-Executor）環境における二重委譲の回避ルール、および各ツール固有のモデル引数との対応表は [`rules/model_escalation_strategy.md`](../rules/model_escalation_strategy.md) を参照してください。
