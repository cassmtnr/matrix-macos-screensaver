import { describe, expect, test } from 'bun:test';
import { NUM_ROWS } from '../config.js';
import { generateFrame } from '../frameGenerator.js';
import { MatrixColumn } from '../MatrixColumn.js';

describe('frameGenerator', () => {
  test('generateFrame returns a canvas', () => {
    const columns = [new MatrixColumn(0, 10), new MatrixColumn(18, 10)];
    const canvas = generateFrame(columns, 120);

    expect(canvas).toBeDefined();
    expect(typeof canvas.toBuffer).toBe('function');
  });

  test('generateFrame creates canvas with correct dimensions', () => {
    const columns = [new MatrixColumn(0, 10)];
    const canvas = generateFrame(columns, 120);

    expect(canvas.width).toBe(1920);
    expect(canvas.height).toBe(1080);
  });

  test('generateFrame produces PNG buffer', () => {
    const columns = [new MatrixColumn(0, 10)];
    const canvas = generateFrame(columns, 120);
    const buffer = canvas.toBuffer('image/png');

    expect(buffer).toBeInstanceOf(Buffer);
    expect(buffer.length).toBeGreaterThan(0);

    // PNG magic bytes
    expect(buffer[0]).toBe(0x89);
    expect(buffer[1]).toBe(0x50); // P
    expect(buffer[2]).toBe(0x4e); // N
    expect(buffer[3]).toBe(0x47); // G
  });

  test('generateFrame works with different hue values', () => {
    const columns = [new MatrixColumn(0, 10)];

    // Test various hues
    const hues = [0, 60, 120, 180, 240, 300];
    for (const hue of hues) {
      const canvas = generateFrame(columns, hue);
      expect(canvas).toBeDefined();
    }
  });

  test('generateFrame renders visible characters', () => {
    // Create columns with heads at visible positions
    const columns: MatrixColumn[] = [];
    for (let i = 0; i < 5; i++) {
      const col = new MatrixColumn(i * 18, NUM_ROWS);
      // Advance columns until they have visible content
      for (let j = 0; j < 100; j++) {
        col.update();
      }
      columns.push(col);
    }

    const canvas = generateFrame(columns, 120);
    const buffer = canvas.toBuffer('image/png');

    // Should produce valid PNG
    expect(buffer.length).toBeGreaterThan(1000);
  });

  test('generateFrame handles empty columns array', () => {
    const canvas = generateFrame([], 120);
    expect(canvas).toBeDefined();
    expect(canvas.width).toBe(1920);
  });
});
