// AIがうっかり「スライス間の直接参照」を行ってしまった場合に、テスト実行（Vitest/Jest等）で即座にエラーを吐かせてAI自身に修正させるためのルールチェック用テストです。
import fs from 'fs';
import path from 'path';
import { describe, it, expect } from 'vitest';

describe('Vertical Slice Architecture Boundary Check (Harness)', () => {
  const featuresDir = path.resolve(__dirname, '../../src/features');

  it('Feature slices must NOT import code directly from other feature slices', () => {
    if (!fs.existsSync(featuresDir)) return;

    const slices = fs.readdirSync(featuresDir).filter((file) =>
      fs.statSync(path.join(featuresDir, file)).isDirectory()
    );

    const violations: string[] = [];

    for (const currentSlice of slices) {
      const slicePath = path.join(featuresDir, currentSlice);
      const files = getAllFiles(slicePath);

      for (const filePath of files) {
        const content = fs.readFileSync(filePath, 'utf-8');

        // 他のスライスからのインポート文を検出する正規表現
        for (const otherSlice of slices) {
          if (currentSlice === otherSlice) continue;

          const forbiddenImportRegex = new RegExp(
            `from\\s+['"].*\/features\/${otherSlice}(\/.*)?['"]`,
            'g'
          );

          if (forbiddenImportRegex.test(content)) {
            violations.push(
              `[Violation] ${path.relative(process.cwd(), filePath)} imports directly from slice '${otherSlice}'`
            );
          }
        }
      }
    }

    // 違反があった場合はテストを落とし、AIに理由を提示する
    expect(
      violations,
      `VSA Violation detected! Do not import directly between feature slices.\n${violations.join('\n')}`
    ).toEqual([]);
  });
});

function getAllFiles(dirPath: string, arrayOfFiles: string[] = []): string[] {
  const files = fs.readdirSync(dirPath);

  files.forEach((file) => {
    const fullPath = path.join(dirPath, file);
    if (fs.statSync(fullPath).isDirectory()) {
      arrayOfFiles = getAllFiles(fullPath, arrayOfFiles);
    } else if (file.endsWith('.ts') || file.endsWith('.tsx')) {
      arrayOfFiles.push(fullPath);
    }
  });

  return arrayOfFiles;
}
