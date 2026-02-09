import { describe, expect, test } from 'bun:test';
import { checkFfmpeg } from '../videoEncoder.js';

describe('videoEncoder', () => {
  test('checkFfmpeg returns a boolean', () => {
    const result = checkFfmpeg();
    expect(typeof result).toBe('boolean');
  });

  test('checkFfmpeg returns true when ffmpeg is installed', () => {
    // This test assumes ffmpeg is installed on the system
    // It should pass on systems with ffmpeg
    const result = checkFfmpeg();
    expect(result).toBe(true);
  });
});
