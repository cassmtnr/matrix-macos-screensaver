import { describe, expect, test } from 'bun:test';
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { checkXcodebuild, getDirectorySize } from '../bundleBuilder.js';

describe('bundleBuilder', () => {
  test('checkXcodebuild returns a boolean', () => {
    const result = checkXcodebuild();
    expect(typeof result).toBe('boolean');
  });

  test('checkXcodebuild returns true when xcodebuild is installed', () => {
    // This test assumes Xcode Command Line Tools are installed
    const result = checkXcodebuild();
    expect(result).toBe(true);
  });

  describe('getDirectorySize', () => {
    test('returns 0 for empty directory', () => {
      const tempDir = mkdtempSync(join(tmpdir(), 'test_empty_'));
      try {
        const size = getDirectorySize(tempDir);
        expect(size).toBe(0);
      } finally {
        rmSync(tempDir, { recursive: true, force: true });
      }
    });

    test('returns correct size for directory with files', () => {
      const tempDir = mkdtempSync(join(tmpdir(), 'test_size_'));
      try {
        // Create a file with known content
        const content = 'Hello, World!'; // 13 bytes
        writeFileSync(join(tempDir, 'test.txt'), content);

        const size = getDirectorySize(tempDir);
        expect(size).toBe(13);
      } finally {
        rmSync(tempDir, { recursive: true, force: true });
      }
    });

    test('returns correct size for nested directories', () => {
      const tempDir = mkdtempSync(join(tmpdir(), 'test_nested_'));
      try {
        // Create nested structure
        const subDir = join(tempDir, 'subdir');
        mkdirSync(subDir);

        writeFileSync(join(tempDir, 'root.txt'), '12345'); // 5 bytes
        writeFileSync(join(subDir, 'nested.txt'), '1234567890'); // 10 bytes

        const size = getDirectorySize(tempDir);
        expect(size).toBe(15);
      } finally {
        rmSync(tempDir, { recursive: true, force: true });
      }
    });
  });
});
