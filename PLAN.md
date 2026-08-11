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
