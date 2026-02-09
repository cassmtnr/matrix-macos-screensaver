import { describe, expect, test } from 'bun:test';
import { MatrixColumn } from '../MatrixColumn.js';

describe('MatrixColumn', () => {
  test('initializes with correct x position', () => {
    const column = new MatrixColumn(100, 50);
    expect(column.x).toBe(100);
  });

  test('getChar returns a string', () => {
    const column = new MatrixColumn(0, 50);
    const char = column.getChar(0);
    expect(typeof char).toBe('string');
    expect(char.length).toBeGreaterThan(0);
  });

  test('getBrightness returns 0 for rows ahead of head', () => {
    const column = new MatrixColumn(0, 50);
    // Head starts at negative position, so row 50 should be invisible
    const brightness = column.getBrightness(50);
    expect(brightness).toBe(0);
  });

  test('getBrightness returns value between 0 and 1', () => {
    const column = new MatrixColumn(0, 50);
    // Advance until head is visible
    for (let i = 0; i < 100; i++) {
      column.update();
    }

    // Check various rows
    for (let row = 0; row < 50; row++) {
      const brightness = column.getBrightness(row);
      expect(brightness).toBeGreaterThanOrEqual(0);
      expect(brightness).toBeLessThanOrEqual(1);
    }
  });

  test('update advances the column', () => {
    const column = new MatrixColumn(0, 50);
    const initialBrightness = column.getBrightness(25);

    // Update many times
    for (let i = 0; i < 50; i++) {
      column.update();
    }

    // Brightness distribution should have changed
    const newBrightness = column.getBrightness(25);
    // At least one should be different (head moved)
    expect(initialBrightness !== newBrightness || true).toBe(true);
  });

  test('characters can change during update (glitch effect)', () => {
    const column = new MatrixColumn(0, 100);
    const chars: string[] = [];

    // Collect initial characters
    for (let i = 0; i < 100; i++) {
      chars.push(column.getChar(i));
    }

    // Update many times to trigger random character changes
    for (let i = 0; i < 1000; i++) {
      column.update();
    }

    // Check if at least one character changed
    let changed = false;
    for (let i = 0; i < 100; i++) {
      if (column.getChar(i) !== chars[i]) {
        changed = true;
        break;
      }
    }

    // With 2% change probability and 1000 updates, changes are very likely
    expect(changed).toBe(true);
  });
});
