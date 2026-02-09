import { describe, expect, test } from 'bun:test';
import {
  COLOR_KEYFRAMES,
  COLUMN_WIDTH,
  DURATION_SECONDS,
  FONT_SIZE,
  FPS,
  HEIGHT,
  MATRIX_CHARS,
  NUM_COLUMNS,
  NUM_ROWS,
  WIDTH,
} from '../config.js';

describe('config', () => {
  test('video dimensions are valid', () => {
    expect(WIDTH).toBeGreaterThan(0);
    expect(HEIGHT).toBeGreaterThan(0);
    expect(WIDTH).toBe(1920);
    expect(HEIGHT).toBe(1080);
  });

  test('FPS is positive', () => {
    expect(FPS).toBeGreaterThan(0);
    expect(FPS).toBe(30);
  });

  test('DURATION_SECONDS is positive', () => {
    expect(DURATION_SECONDS).toBeGreaterThan(0);
  });

  test('FONT_SIZE is positive', () => {
    expect(FONT_SIZE).toBeGreaterThan(0);
  });

  test('COLUMN_WIDTH equals FONT_SIZE', () => {
    expect(COLUMN_WIDTH).toBe(FONT_SIZE);
  });

  test('NUM_COLUMNS is calculated correctly', () => {
    expect(NUM_COLUMNS).toBe(Math.floor(WIDTH / COLUMN_WIDTH));
  });

  test('NUM_ROWS includes extra rows for off-screen spawning', () => {
    expect(NUM_ROWS).toBeGreaterThan(Math.floor(HEIGHT / FONT_SIZE));
  });

  test('MATRIX_CHARS is a non-empty string', () => {
    expect(typeof MATRIX_CHARS).toBe('string');
    expect(MATRIX_CHARS.length).toBeGreaterThan(0);
  });

  test('MATRIX_CHARS contains katakana', () => {
    expect(MATRIX_CHARS).toContain('ア');
    expect(MATRIX_CHARS).toContain('カ');
  });

  test('MATRIX_CHARS contains Latin letters', () => {
    expect(MATRIX_CHARS).toContain('A');
    expect(MATRIX_CHARS).toContain('Z');
  });

  test('MATRIX_CHARS contains digits', () => {
    expect(MATRIX_CHARS).toContain('0');
    expect(MATRIX_CHARS).toContain('9');
  });

  test('COLOR_KEYFRAMES is a non-empty array', () => {
    expect(Array.isArray(COLOR_KEYFRAMES)).toBe(true);
    expect(COLOR_KEYFRAMES.length).toBeGreaterThan(0);
  });

  test('COLOR_KEYFRAMES have valid structure', () => {
    for (const keyframe of COLOR_KEYFRAMES) {
      expect(typeof keyframe.time).toBe('number');
      expect(typeof keyframe.hue).toBe('number');
      expect(keyframe.time).toBeGreaterThanOrEqual(0);
      expect(keyframe.hue).toBeGreaterThanOrEqual(0);
      expect(keyframe.hue).toBeLessThanOrEqual(360);
    }
  });
});
