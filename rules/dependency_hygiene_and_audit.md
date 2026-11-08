# 依存関係衛生と脆弱性管理ルール (Dependency Hygiene & Vulnerability Audit Guideline)

本ガイドラインは、外部SaaSや特定プラットフォームの自動化ボットに依存せず、ローカル環境とGit/Jujutsuのみで自立してライブラリの陳腐化・セキュリティ脆弱性を防ぐための運用ルールおよびエージェント行動規範を定めます。

---

## 1. 基本思想：ローカル自立性と持続可能な運用 (Self-Sustained & Sustainable)

1. **脱SaaS・ベンダーロックインの排除**:
   プラットフォームの買収、規約変更、サービス終了、リポジトリ権限譲渡リスクに備え、依存関係の脆弱性監査（audit）および更新は**ローカルのCLIツールおよびリポジトリ内のスクリプトのみで完結可能**とします。
2. **スマートな緩さ（Graceful & Non-blocking）**:
   開発テンポを阻害しないため、日々の開発コマンドでは「文句（警告）は出すが手は止めない（Non-blocking）」および「環境にツールがなければ静かにスキップする（Graceful Degradation）」を原則とします。
3. **エージェントへの委譲とコンテキスト分離**:
   依存関係の更新・脆弱性対応は、機能追加やバグ修正と混ざらないよう独立したコミットとして扱い、AIエージェントに自律的に解消・テストパスまで遂行させます。

---

## 2. 2大運用ルール（入りの関門・出の関門）

エージェントおよび開発者は、以下の「入りの関門」と「出の関門」を厳格に遵守します。

### ① プロジェクト再開時の先行チェック（入りの関門）
- **判定条件**: リポジトリの最終コミットから **30日以上** 経過している状態で作業を開始する場合（`git log -1 --format=%ct` で判定）。
- **行動規範**:
  1. 本題の機能開発やバグ修正に着手する前に、**まず最初に依存関係の監査（audit）を実行**します。
  2. 脆弱性（特に Severity: **HIGH** / **CRITICAL**）が検知された場合、本作業とは完全に分離した**独立した先行コミット**として依存関係を更新し、テストが全件合格することを確認してから本来のタスクに進みます。
  3. これにより、「新機能開発中にライブラリの破壊的変更でビルドが壊れる」事態や「デバッグ時に原因の切り分けが困難になる問題」を未然に防ぎます。

### ② タスク完了・作業終了前の品質ゲート（出の関門）
- **判定条件**: タスク完了時、または作業を終了してコミット/マージリクエストを作成する前。
- **完了基準 (Definition of Done)**:
  1. 依存関係の監査を再度実行し、**`HIGH` および `CRITICAL` な脆弱性がゼロであること**を必須条件とします。
  2. 軽微な警告（`MODERATE` / `LOW`）についても、破壊的変更を伴わず安全に解消可能であれば、可能な限り解消（ゼロ警告）を目指します。
  3. 作業終了時にクリーンな状態を担保することで、次回プロジェクト再開時や他の開発者が触る際の地雷を完全に排除します。

---

## 3. 各言語・環境別の推奨ローカル監査ツール

外部サービスを使わず、ローカルCLIで完結する推奨ツール一覧です。

| 言語 / エコシステム | 推奨監査コマンド (Audit) | 更新確認コマンド (Outdated) | 特徴・備考 |
| :--- | :--- | :--- | :--- |
| **Go** | `govulncheck ./...` | `go list -u -m all` | Go公式ツール。静的解析のコールグラフ追跡により「実際に脆弱な関数を呼んでいるか」まで判定（ノイズ極小）。 |
| **Node.js** | `npm audit` / `pnpm audit` | `npm outdated` | 言語標準内蔵。 |
| **Rust** | `cargo audit` | `cargo outdated` | RustSec Advisory Database と照合。 |
| **Python** | `pip-audit` | `pip list --outdated` | PyPA公式推奨の脆弱性スキャナ。 |
| **言語横断 / 万能** | `trivy fs .` | - | Aqua Security提供のOSS。バイナリ単体でGo/Node/Python/Rust/OSパッケージをまとめてローカルスキャン可能。 |

---

## 4. Makefile / スクリプトへの組み込みパターン

リポジトリのタスクランナー（Makefile等）へ組み込む際は、以下のパターンを採用します。

```makefile
.PHONY: audit audit-if-needed update-deps

# 明示的な監査実行（手動またはCI用）
audit:
	@if [ -f "go.mod" ] && command -v govulncheck >/dev/null 2>&1; then \
		govulncheck ./...; \
	elif [ -f "package.json" ]; then \
		npm audit; \
	elif [ -f "Cargo.toml" ] && command -v cargo-audit >/dev/null 2>&1; then \
		cargo audit; \
	elif command -v trivy >/dev/null 2>&1; then \
		trivy fs . --severity HIGH,CRITICAL; \
	fi

# 30日以上経過時のみ緩く警告を出すターゲット（ビルドやテストの前提タスクに指定）
audit-if-needed:
	@bash -c '\
	LAST_COMMIT=$$(git log -1 --format=%ct 2>/dev/null || echo 0); \
	NOW=$$(date +%s); \
	if [ $$(( (NOW - LAST_COMMIT) / 86400 )) -ge 30 ]; then \
		echo "💡 [Notice] 前回のコミットから間が空いています。依存関係をチェックします..."; \
		make audit || true; \
		echo "💡 チェック終了。作業を継続します。"; \
	fi'

# 依存関係を一括更新してテストするターゲット
update-deps:
	@if [ -f "go.mod" ]; then \
		go get -u ./... && go mod tidy; \
	elif [ -f "package.json" ]; then \
		npm update; \
	elif [ -f "Cargo.toml" ]; then \
		cargo update; \
	fi
	@make test
```
