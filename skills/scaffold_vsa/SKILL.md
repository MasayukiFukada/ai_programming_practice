---
name: scaffold_vsa
description: Vertical Slice Architecture のルールに則って、対象プロジェクトの開発言語やフレームワークに合わせた新規機能（スライス）の雛形を生成します。
---

# scaffold_vsa スキル

このスキルは、プロジェクトで採用している Vertical Slice Architecture に基づき、新機能（スライス）の骨組みを生成するためのものです。
特定の言語に依存せず、親プロジェクトの設定（言語、フレームワークなど）に合わせて適切なファイルを生成してください。

## 前提条件

- 親プロジェクトの言語・フレームワーク設定（例: `.env` や `AGENTS.md` の技術スタック情報）を確認すること。
- プロジェクト独自の `rules`（例: `rules/VerticalSliceArchitecture_GuideLine_JP.md` 等）を必ず参照すること。

## 手順

1. ユーザーが作成したい「機能（ユースケース）」の名前と要件をヒアリングする（またはプロンプトから読み取る）。
2. プロジェクトの技術スタックを特定し、その言語における Vertical Slice のベストプラクティスを考案する。
   - ※ 参考として `examples/VerticalSliceArchitecture_Harness.ts` のような構造（TypeScript向けサンプル）も確認してよい。
3. 必要なファイル群（Controller/Handler, UseCase, Repository/DataAccess 等、スライス内で完結する要素）を提案し、合意を得る。
4. ユーザーの承認後、提案したディレクトリ構造と初期実装（テストコード含む）を生成する。

## 注意事項
- 各コンテキスト（機能）の範囲を最小限に絞り、他機能との密結合を避けること。
- オブジェクト指向より関数型（FP）アプローチをベースに実装を検討すること。
