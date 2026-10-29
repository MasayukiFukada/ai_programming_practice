# 外部ナレッジ・採用技術リファレンス (External References & Inspirations)

本プロジェクトが設計思想、コードレビュー、アーキテクチャ、テスト手法、開発効率化においてインスパイアを受け、取り入れている外部のオープンソースプロジェクト、設計パターン、および技術ナレッジの出典一覧です。

---

## 📚 採用ナレッジ・出典一覧

| ナレッジ / 手法名 | 提唱者 / 出典 | 目的・解決する課題 | 本基盤での採用・実装箇所 |
| :--- | :--- | :--- | :--- |
| **Repo-Map**<br>（骨格マップ生成） | **Aider**<br>([aider.chat](https://aider.chat/docs/repomap.html)) | 大規模コードベース探索時のトークン消費を80〜95%削減し、型の見落としや車輪の再発明を防止する。 | [`scripts/generate_repo_map.py`](../scripts/generate_repo_map.py)<br>[`rules/repo_map_guideline.md`](../rules/repo_map_guideline.md) |
| **Vertical Slice Architecture (VSA)** | **Jimmy Bogard**<br>([jimmybogard.com](https://jimmybogard.com/vertical-slice-architecture/)) | 水平レイヤー（Controller/Service/Repo）による凝集度の分散を解消し、機能（スライス）単位で完結する設計にする。 | [`rules/vertical_slice_architecture.md`](../rules/vertical_slice_architecture.md)<br>[`skills/scaffold_vsa/`](../skills/scaffold_vsa/) |
| **Functional Core, Imperative Shell** | **Gary Bernhardt**<br>([Destroy All Software](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell)) | ビジネスロジックを副作用のない純粋関数に隔離し、I/Oモックを不要にして単体テストの信頼性を劇的に向上させる。 | [`rules/vertical_slice_architecture.md`](../rules/vertical_slice_architecture.md)<br>[`rules/ai_coding_principles.md`](../rules/ai_coding_principles.md) |
| **Mantis セキュリティレビュー** | **Mantis Framework** | 単なる推測や可能性の列挙（ハルシネーション）を防ぎ、Reviewer ⇄ Critic の二者反証ステップで再現可能な脆弱性のみを指摘する。 | [`rules/mantis_security_review.md`](../rules/mantis_security_review.md)<br>[`rules/code_review_guideline.md`](../rules/code_review_guideline.md) |
| **ミューテーションテスト**<br>(Mutation Testing) | **Stryker / Mutmut**<br>([stryker-mutator.io](https://stryker-mutator.io/)) | テストが通るだけでアサーションが空っぽの「無意味なテスト」を撲滅するため、AIがコードを一時的に反転させてテスト失敗を自己検証する。 | [`rules/mutation_testing_guideline.md`](../rules/mutation_testing_guideline.md)<br>[`rules/ai_coding_principles.md`](../rules/ai_coding_principles.md) |
| **Jujutsu (`jj`)** | **Google / jj-vcs**<br>([github.com/jj-vcs/jj](https://github.com/jj-vcs/jj)) | 作業コピーの自動追跡、コミット前の柔軟な履歴書き換え、安全なアンドゥ（`jj undo`）による開発テンポの最大化。 | [`rules/vcs_jujutsu_priority.md`](../rules/vcs_jujutsu_priority.md) |
| **Elephant-Goldfish Model (EGM)** | **Google**<br>([github.com/google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model)) | 開発中のコンテキスト汚染と自己バイアスを排除する「金魚（ゼロコンテキスト・ステートレス）レビュー」と、契約とコードの乖離を検知する「Driftチェック」。 | [`rules/model_escalation_strategy.md`](../rules/model_escalation_strategy.md)<br>[`rules/code_review_guideline.md`](../rules/code_review_guideline.md)<br>[`rules/quick_commands.md`](../rules/quick_commands.md) |
| **Action-First (ADHDフレンドリー)** | **認知負荷低減設計** | 多すぎる選択肢や長文による意思決定疲労を防ぎ、Enterキー1回で押せる「2分以内の最小初手アクション」にタスクを極小化する。 | [`commands/i-have-adhd.toml`](../commands/i-have-adhd.toml)<br>[`rules/quick_commands.md`](../rules/quick_commands.md) |

---

## 🔍 各技術の採用理由と本プロジェクトでのアレンジ

### 1. Repo-Map (Aider)
* **背景**: LLMがコード全体を把握しようとして全ファイルをそのまま読み込むと、あっという間にトークン上限に達し、しかも重要な定義を見落とします（Lost in the Middle現象）。
* **本基盤でのアレンジ**: 外部バイナリや重い依存関係（Tree-sitter等）を必要とせず、Python 3 標準ライブラリの AST 解析および正規表現のみで高速動作する軽量アナライザとして再実装しています。

### 2. Vertical Slice Architecture ＋ Functional Core
* **背景**: クリーンアーキテクチャやオニオンアーキテクチャは依存方向は綺麗になる反面、1機能の改修で多数の層を往復する必要があり、AIが全体像を見失いやすくなります。
* **本基盤でのアレンジ**: スライス（機能単位）の中に「契約（型・スキーマ）」「純粋コア（計算・判定）」「I/Oシェル（DB・外部API）」を同居させ、テストは純粋コアに対してのみインメモリで網羅する「3フェーズ委譲プロトコル」と融合させています。

### 3. Elephant-Goldfish Model (Google)
* **背景**: 長い会話を続けたLLMに「自分で書いたコードをレビュー」させると、これまでの対話の前提に引きずられて潜在的なバグや仕様漏れを見逃します（自己バイアス）。
* **本基盤でのアレンジ**:
  - 全てのタスクで仕様書作成を強制するのではなく、「重要なPRマージ前」や「難解なロジック」に対してのみ発動するオンデマンドの「金魚レビュー（Zero-Context Review）」として軽量化。
  - 設計フェーズで確定した `contract.ts`（型・スキーマ）と実装コードの乖離を素早く検出する「Contract Drift チェック」を導入。

### 4. ミューテーションテストの自律検証
* **背景**: AIが自動生成したテストは、時に `expect(true).toBe(true)` や甘いモックによって「何が起きてもGreenになる空洞化テスト」になりがちです。
* **本基盤でのアレンジ**: 重いCIツールを常時回す代わりに、レイカ（テスト担当）が「実装の境界値条件を一時的に書き換えて、意図通りRedになるか」をサンドボックス内で自律的に試行して証明するプロトコルを採用しています。
