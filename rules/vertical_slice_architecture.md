# Vertical Slice Architecture (VSA) 開発ガイドライン

本ガイドラインは、**Vertical Slice Architecture (VSA)** および **Feature-First** の設計思想に基づいて開発を行うための原則と制約を定めます。コードを作成・変更する際は、以下のルールを厳格に順守してください。

---

## 1. ディレクトリ構造のルール (Directory Structure)
すべての機能（ドメイン）は、`src/features/` ディレクトリ配下に独立したスライス（機能フォルダ）として配置してください。
技術的な役割（Controller/Service/Repository等）による水平分割ではなく、**ユーザーの行動や機能名（ビジネスユースケース）**で垂直に切り出します。

- ⭕ **良い例**: `src/features/create-user/`, `src/features/download-invoice/`, `src/features/cancel-subscription/`
- ❌ **悪い例**: `src/controllers/`, `src/services/`, `src/models/`, `src/repositories/`

---

## 2. スライス間の独立性ルール【最重要】(Slice Independence)
- **スライス間の直接参照・インポートは絶対禁止**:  
  `src/features/A` 配下のコードから、`src/features/B` 配下のコードを直接 `import` してはなりません。
- **共通ロジックの昇格**:  
  2つ以上のスライスで真に必要な共有ロジック・ユーティリティがある場合は、`src/shared/` 配下に移動してください。
- **スライス間の連携**:  
  スライス間で連携が必要な場合は、ドメインイベントを発行するか、上位のワークフロー（Orchestrator）スライスを作成して調停してください。

---

## 3. ファイルの同居ルール (Colocation)
機能に関連するファイルは、すべて同じスライスフォルダ内にまとめて配置（Colocation）してください。
- ハンドラー・実装ロジック (`<feature-name>.ts`)
- 入力バリデーションスキーマ (`<feature-name>.schema.ts`)
- 単体・結合テストコード (`<feature-name>.test.ts`)

※ ルート直下の `tests/` や `schemas/` などにテストやスキーマを分離しないでください。

---

## 4. 型・DTOの独立管理 (Type & DTO Isolation)
- リクエスト/レスポンスの型（DTO）やバリデーションスキーマを、他のスライスと共有・使い回ししないでください。
- 一見似ている型であっても、各スライスが自身の入出力定義を所有（Own）してください。
- これにより、あるスライスの仕様変更が他の無関係なスライスに波及（デグレ）するリスクを完全に排除します。

---

## 5. シンプルさの優先 (Simplicity First / YAGNI)
- 単純なCRUD機能に対して、不要なインターフェース（Interface）、リポジトリ（Repository）、抽象クラスを作らないでください。
- ビジネスロジックが極めて複雑でない限り、1つのハンドラーファイル内にシンプルかつ透明性の高いコードを完結して記述してください。
