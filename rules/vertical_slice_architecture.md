# Vertical Slice Architecture (VSA) 開発ガイドライン

本ガイドラインは、**Vertical Slice Architecture (VSA)** および **Feature-First** の設計思想に基づいて開発を行うための原則と制約を定めます。
本アーキテクチャは、人間の開発者だけでなく、**AIサブエージェント協調・並行開発（Fan-out）においてコンフリクトを最小化し、推論精度とテスタビリティを最大化する**ことを目的としています。
コードを作成・変更する際は、以下のルールを厳格に順守してください。

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
- 契約・型定義・入力バリデーションスキーマ (`contract.ts` または `<feature-name>.schema.ts`)
- 純粋ビジネスロジック (`core.ts` または `<feature-name>.core.ts`)
- ハンドラー・I/O統合 (`handler.ts` または `<feature-name>.ts`)
- テストコード (`core.spec.ts`, `handler.spec.ts`)
- モック・Factory (`mock.factory.ts`)

※ ルート直下の `tests/` や `schemas/` などにテストやスキーマを分離しないでください。

---

## 4. 型・DTOの独立管理 (Type & DTO Isolation)

- リクエスト/レスポンスの型（DTO）やバリデーションスキーマを、他のスライスと共有・使い回ししないでください。
- 一見似ている型であっても、各スライスが自身の入出力定義を所有（Own）してください。
- これにより、あるスライスの仕様変更が他の無関係なスライスに波及（デグレ）するリスクを完全に排除します。

---

## 5. Contract-First による並行開発 (Contract-First Parallelism)

新機能の実装や大幅な改修を行う際は、実装コードを書く前に**まず「契約（Contract）」を定義して確定**させてください。

1. **契約の先行コミット**:
   入出力スキーマ、リクエスト/レスポンスの型、バリデーションルールを `contract.ts`（またはスキーマファイル）に定義します。
2. **依存待ちゼロの並行作業（Fan-out）**:
   契約が固定された時点で、後続の作業を依存待ちなしに並行で進めることができます。
   - **エージェントA**: 純粋ビジネスロジックの実装と網羅テスト
   - **エージェントB**: I/OハンドラーおよびDB永続化の実装
   - **エージェントC**: テスト用ダミーデータ生成（Mock Factory）やファズテスト
   - **エージェントD**: クライアント/UI側の組み込み

---

## 6. CQRS によるスライス責務の分離 (Command / Query Separation)

ユースケースは可能な限り **更新系（Command）** と **参照系（Query）** のスライスに分離してください。

- **Commandスライス（例: `create-order`, `transfer-money`）**:
  - 関心事: 厳格なバリデーション、ビジネスルールの検証、トランザクション、データの整合性。
  - 設計: 後述の「Functional Core」を採用し、純粋ロジックを副作用から厳格に保護します。
- **Queryスライス（例: `list-orders`, `get-user-summary`）**:
  - 関心事: 画面やクライアントが求めるDTOへの最短・高速な射影（Projection）。
  - 設計: 不要なドメインエンティティや抽象リポジトリを経由せず、ORMやSQLで直接DTOを組み立てて返却します（過剰設計の排除）。

---

## 7. ロジックのテスタビリティと副作用分離 (Functional Core / Imperative Shell)

UIコンポーネント（View）は除外するとしても、**ドメインロジックや計算処理は極限までテスタブルに保つ**必要があります。
そのための標準設計として **Functional Core / Imperative Shell（純粋な核と命令的な殻）** を適用してください。

### ① Functional Core（純粋ドメインロジック: `core.ts`）
- 料金計算、状態遷移判定、権限チェック、集計アルゴリズムなど、判断や計算を伴うロジックを純粋関数（Pure Function）として切り出します。
- **制約**:
  - 外部I/O（DBアクセス、HTTPリクエスト、ファイル読み書き等）を直接行わないこと。
  - 現在日時（`Date.now()`）や乱数（`Math.random()`）などの非決定的な値は、引数として受け取ること。
- **メリット**:
  - DB接続や複雑なモックが一切不要となり、インメモリで数ミリ秒で完結する網羅的テスト（境界値・異常系・ファズテスト）を安全かつ高速に実行できます。

### ② Imperative Shell（薄いハンドラー / I/O統合層: `handler.ts`）
- フレームワークのルーティングやI/Oを調停する「薄い調整役」に徹します。
- **処理の流れ**:
  1. リクエストを受け取り、`contract.ts` でバリデーション。
  2. DBや外部サービスから必要なデータを取得（I/O）。
  3. `core.ts` の純粋関数にデータを渡し、計算・判定を実行。
  4. 計算結果をもとに、DBへの永続化や外部通知を実行（I/O）。
  5. レスポンスDTOを返却。

---

## 8. シンプルさの優先 (Simplicity First / YAGNI)

- **過剰な抽象化の禁止**:
  単純なCRUDやデータの受け渡ししかないスライスに対して、不要なインターフェース（Interface）、リポジトリ（Repository）、抽象クラスを作らないでください。
- **複雑度に応じた段階的設計**:
  - 単純な処理: 1つの `handler.ts` 内に手続き的に記述して完結（YAGNI）。
  - 計算やビジネス判断が複雑な処理: `contract.ts` + `core.ts`（純粋ロジック） + `handler.ts`（I/O）に分離してテスタビリティを確保。

---

## 9. スライスのファイル構成例

```
features/
  ├── transfer-balance/                 # 複雑なビジネスロジックを持つCommandスライス
  │   ├── contract.ts                   # 入出力スキーマ・DTO型定義 (Contract-First)
  │   ├── transfer.core.ts              # 純粋ドメイン計算（手数料・残高チェック等の純粋関数）
  │   ├── transfer.core.spec.ts         # コアロジックの高速網羅テスト（モック不要）
  │   ├── transfer.handler.ts           # DBトランザクション・外部APIを調停する薄いShell
  │   └── transfer.handler.spec.ts      # ハンドラーの結合テスト
  │
  └── get-account-history/              # 高速な取得が求められるQueryスライス
      ├── contract.ts                   # 画面が必要とする検索条件とレスポンス型
      ├── history.handler.ts            # DBから直接DTOへ射影して返すシンプルなハンドラー
      └── history.handler.spec.ts       # 正常系・異常系の基本テスト
```
