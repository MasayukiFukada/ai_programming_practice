# スキルカタログ・クイックリファレンス (Skills Catalog)

本リポジトリに収録されている全20種類の自律エージェント用スキルの一覧表です。
各スキルの担当ペルソナ、推奨モデル階層（Model Tier）、起動クイックコマンド、および役割をまとめています。

---

## 📋 全20スキル早見表

| スキル名 | 担当ペルソナ | 推奨モデル | クイックコマンド | 主な役割とユースケース |
| :--- | :--- | :---: | :--- | :--- |
| **`plan_formulation`** | アゲハ (Gal) | `flash` / `pro` | 「計画」「方針」 | 技術選定や方針決定のトレードオフ（利点・欠点）を比較提示 |
| **`interview_requirements`** | アゲハ (Gal) | `flash` | 「ヒアリング」「要件」 | フワッとした要望に対し鋭い逆質問で仕様や境界条件を明確化 |
| **`critique_ux_flow`** | アゲハ (Gal) | `flash` | 「UX」「導線」 | UI/UX導線・操作フロー・文言の直感性をギャル目線でレビュー |
| **`scaffold_tdd`** | レイカ (Lady) | `pro` | 「TDD」 | 実装前に仕様を満たすテストケース（Red）を先行生成 |
| **`generate_tests`** | レイカ (Lady) | `pro` / `inherit` | 「テスト」「単体テスト」 | 実装コードに対する網羅的エッジケース・異常系テストの自動生成 |
| **`generate_mock_factory`** | レイカ (Lady) | `flash_lite` / `flash` | 「モック」「factory」 | 型定義に準拠したテスト用ダミーデータやFactory関数をお仕立て |
| **`refactor_for_testability`** | レイカ (Lady) | `pro` | 「リファクタ」「純粋関数」 | 密結合・副作用を持つコードをテスタブルな純粋関数へ再構築 |
| **`scaffold_vsa`** | レイカ (Lady) | `inherit` | 「スライス」「vsa」 | Vertical Slice Architecture に準拠した新機能の雛形を生成 |
| **`optimize_complexity`** | ナユタ (Geek) | **`pro`** | 「最適化」「CCN」「複雑度」 | 全体構造を俯瞰し、CCN激減・計算量次元削減（$O(N^2) \to O(1)$）を実行 |
| **`benchmark_performance`** | ナユタ (Geek) | `pro` / `inherit` | 「ベンチ」「計測」 | 処理速度やメモリ消費のベンチマーク計測と改善効果の定量証明 |
| **`optimize_concurrency`** | ナユタ (Geek) | **`pro`** | 「並行」「async」 | 非同期処理の直列化ボトルネック解消、Promise.all/Worker最適化 |
| **`upgrade_dependencies`** | ナユタ / レイカ | `pro` | 「アプデ」「更新」 | 依存ライブラリの最新安定版アップグレードと破壊的変更の安全移行 |
| **`self_heal_error`** | ナユタ / アゲハ | **`pro`** | 「修復」「自己修復」 | ビルド・テストエラーの根本原因特定と段階的修復（難航時相談） |
| **`review_code`** | サヨ (Smug) | **`flash`** (通常)<br>/ **`pro`** (厳密) | 「レビュー」「review」<br>（厳密時は「厳密レビュー」） | 6大観点・重要度付き厳密レビューとJSON出力（日常はFlashでクォータ保護、本気時はPro/Argon） |
| **`generate_fuzz_tests`** | サヨ (Smug) | **`pro`** | 「ファズ」「意地悪」 | 極悪・意地悪データ（絵文字・極大・SQLi等）による攻撃テスト作成 |
| **`create_docs`** | コハク (Scholar) | `flash` | 「ドキュメント」「仕様書」 | コードやアーキテクチャから人間向けの設計書・ドキュメントを生成 |
| **`distill_adr`** | コハク (Scholar) | `flash` | 「ADR」「設計判断」 | 議論や作業履歴から「なぜその設計にしたか」を抽出しADR化 |
| **`visualize_architecture`** | コハク (Scholar) | `flash` | 「図解」「シーケンス」「ER」 | 依存関係やデータフローをMermaid記法の図解（シーケンス/ER等）で可視化 |
| **`complex_task_delegation`**| オーケストレーター | `pro` / `inherit` | 「委譲」「並行」 | 複雑なタスクを複数サブエージェントに分割して能動的に協調進行 |
| **`setup_project_agents`** | コハク (Scholar) | `inherit` | 「セットアップ」「初期化」 | 親プロジェクトの初期化支援（`AGENTS.md` 作成や `.gitignore` 設定） |

---

## 🎯 モデル階層（Model Tier）の使い分け指針

- **`pro` (High-Reasoning)**:
  - 核心的なロジック実装（`scaffold_tdd`, `refactor_for_testability`）
  - 全体最適化・CCN激減（`optimize_complexity`, `optimize_concurrency`）
  - 独立客観レビュー・脆弱性検証（`review_code`, `generate_fuzz_tests`）
  - エラー泥沼化時の根本原因特定（`self_heal_error`）
- **`flash` (Standard / Fast)**:
  - 要件ヒアリング、UIツッコミ（`interview_requirements`, `critique_ux_flow`）
  - ドキュメント作成、ADR蒸留、Mermaid図解（`create_docs`, `distill_adr`, `visualize_architecture`）
- **`flash_lite` (Lightweight / Ultra-Fast)**:
  - モックやダミーデータの機械的生成（`generate_mock_factory`）
  - 定型フォーマット変換
