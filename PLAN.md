# プロジェクト更新計画 (Plan)

## 目的
`ai_programming_practice` リポジトリをモダナイズし、他のプロジェクトから Git Submodule として取り込んで利用しやすい形に整備する。
生成AIによるコーディングのプロンプトやスキルを一元管理し、開発効率と品質水準を保つための基盤とする。

## ゴール
1. **README.md の刷新**
    - リポジトリの目的（Git Submodule での共通ルール・スキル管理）の明確化。
    - 古いプロンプト集（コピペ用）の廃止と、現在のエージェントベース（Customizations: Skills, Rules, AGENTS.md等）の概念への適応。
    - 親プロジェクトへの導入手順・セットアップ方法の記載。
    - リポジトリのディレクトリ構成（ルール、スキル、ドキュメントなど）の説明。
2. **古いプロンプト集の移行・整理**
    - 現在 README.md に直書きされている古いプロンプトを整理し、必要であれば `skills` などのモダンな仕組みとして再構築するか、削除する。
3. **必要なディレクトリ・ファイルの整備**
    - `skills/` や `rules/` など、エージェントカスタマイズ用のディレクトリ構成を整える（必要に応じてサンプルの作成）。

## 進捗
- [x] PLAN.md の作成（本ファイル）
- [x] README.md の構成案の作成と合意
- [x] README.md の更新
- [x] 不要なプロンプトの整理・ディレクトリ構造の整備
- [x] Vertical Slice Architecture 関連ファイルを skills/rules に適応する

## フェーズ2: AI向けコンテンツの拡充 (完了)
- [x] AI向けコーディング原則 (`rules/ai_coding_principles.md`) の作成（コンテキスト最小化、FP、テスタビリティ）
- [x] テスタブルなコードへのリファクタリングスキル (`skills/refactor_for_testability`) の作成
- [x] テストコード自動生成スキル (`skills/generate_tests`) の作成
- [x] コードレビューガイドライン (`rules/code_review_guideline.md`) および レビュースキル (`skills/review_code`) の作成
- [x] ドキュメント生成スキル (`skills/create_docs`) の作成

## フェーズ3: マルチエージェント・ハルシネーション対策 (完了)
- [x] ハルシネーション低減ガイドライン (`rules/anti_hallucination_guideline.md`) の作成
- [x] サブエージェント委譲スキル (`skills/complex_task_delegation`) の作成

## フェーズ4: リポジトリのクリーンアップ (完了)
- [x] 親プロジェクトのコンテキストを汚染する `AGENTS.md` を `templates/AGENTS.template.md` に退避・整理

## フェーズ5: サブエージェントのキャラクター性（ペルソナ）設定 (完了)
- [x] 親プロジェクトでの `AGENTS.md` 作成支援スキル（テンプレートを基に対話形式でプロジェクト設定を埋めるスキル、.gitignore追加支援含む）
- [x] 計画立案支援スキル（技術選定や方針決めの際に、メリット・デメリットを比較提示してユーザーに判断を求めるスキル）
- [x] キャラクターペルソナ共有ルール (`rules/character_personas.md`) の作成
    - 計画・設計担当: ギャル
    - 実装・テスト担当: お嬢さま
    - チェック・レビュー担当: メスガキ
    - 解説・ドキュメント担当: のじゃロリ
    - 技術的精度・フォーマット遵守を最優先するメタルールの定義
- [x] 各スキルへのペルソナ組み込み
    - `skills/plan_formulation` (アゲハ / ギャル)
    - `skills/generate_tests`, `skills/refactor_for_testability` (レイカ / お嬢さま)
    - `skills/review_code` (サヨ / メスガキ)
    - `skills/create_docs` (コハク / のじゃロリ)
- [x] AGENTSテンプレート (`templates/AGENTS.template.md`) 及び委譲スキル (`skills/complex_task_delegation`) への適用とON/OFF切替方法の整理
- [x] `README.md` への機能追記
- [x] キャラクター名の決定と設定・ドキュメント類への反映
    - 計画・設計: **アゲハ** (Gal / Planner)
    - 実装・テスト: **レイカ** (Lady / Developer)
    - チェック・レビュー: **サヨ** (Smug Critic / Reviewer)
    - 解説・ドキュメント: **コハク** (Ancient Scholar / Documenter)



