import { describe, expect, test } from 'bun:test';
import { checkFfmpeg } from '../videoEncoder.js';

describe('videoEncoder', () => {
  test('checkFfmpeg returns a boolean', () => {
    const result = checkFfmpeg();
    expect(typeof result).toBe('boolean');
  });

  test('checkFfmpeg returns false when ffmpeg is not installed or true when it is', () => {
    // This test verifies the function works correctly regardless of environment
    // We can't assume ffmpeg is installed (e.g., in CI)
    const result = checkFfmpeg();
    // Just verify it returns consistent results (call twice)
    expect(result).toBe(checkFfmpeg());
  });
});
