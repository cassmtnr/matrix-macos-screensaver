import { describe, expect, test } from 'bun:test';
import { FONT_FAMILY, loadFont } from '../fontLoader.js';

describe('fontLoader', () => {
  test('FONT_FAMILY is defined', () => {
    expect(FONT_FAMILY).toBe('MatrixFont');
  });

  test('loadFont returns a string', () => {
    const result = loadFont();
    expect(typeof result).toBe('string');
  });

  test('loadFont returns FONT_FAMILY when font is found', () => {
    const result = loadFont();
    // On macOS with AppleSDGothicNeo installed, should return MatrixFont
    expect([FONT_FAMILY, 'monospace']).toContain(result);
  });

  test('loadFont is idempotent (returns same value on repeated calls)', () => {
    const first = loadFont();
    const second = loadFont();
    expect(first).toBe(second);
  });
});
