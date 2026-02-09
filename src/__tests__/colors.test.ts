import { describe, expect, test } from 'bun:test';
import { getHueAtTime, hsvToRgb } from '../colors.js';

describe('hsvToRgb', () => {
  test('converts red (hue 0)', () => {
    const [r, g, b] = hsvToRgb(0, 1.0, 1.0);
    expect(r).toBe(255);
    expect(g).toBe(0);
    expect(b).toBe(0);
  });

  test('converts green (hue 120)', () => {
    const [r, g, b] = hsvToRgb(120, 1.0, 1.0);
    expect(r).toBe(0);
    expect(g).toBe(255);
    expect(b).toBe(0);
  });

  test('converts blue (hue 240)', () => {
    const [r, g, b] = hsvToRgb(240, 1.0, 1.0);
    expect(r).toBe(0);
    expect(g).toBe(0);
    expect(b).toBe(255);
  });

  test('converts yellow (hue 60)', () => {
    const [r, g, b] = hsvToRgb(60, 1.0, 1.0);
    expect(r).toBe(255);
    expect(g).toBe(255);
    expect(b).toBe(0);
  });

  test('converts cyan (hue 180)', () => {
    const [r, g, b] = hsvToRgb(180, 1.0, 1.0);
    expect(r).toBe(0);
    expect(g).toBe(255);
    expect(b).toBe(255);
  });

  test('converts magenta (hue 300)', () => {
    const [r, g, b] = hsvToRgb(300, 1.0, 1.0);
    expect(r).toBe(255);
    expect(g).toBe(0);
    expect(b).toBe(255);
  });

  test('converts white (saturation 0)', () => {
    const [r, g, b] = hsvToRgb(0, 0, 1.0);
    expect(r).toBe(255);
    expect(g).toBe(255);
    expect(b).toBe(255);
  });

  test('converts black (value 0)', () => {
    const [r, g, b] = hsvToRgb(0, 1.0, 0);
    expect(r).toBe(0);
    expect(g).toBe(0);
    expect(b).toBe(0);
  });

  test('handles hue > 360', () => {
    const [r1, g1, b1] = hsvToRgb(0, 1.0, 1.0);
    const [r2, g2, b2] = hsvToRgb(360, 1.0, 1.0);
    expect(r1).toBe(r2);
    expect(g1).toBe(g2);
    expect(b1).toBe(b2);
  });

  test('handles negative hue', () => {
    const [r1, g1, b1] = hsvToRgb(300, 1.0, 1.0);
    const [r2, g2, b2] = hsvToRgb(-60, 1.0, 1.0);
    expect(r1).toBe(r2);
    expect(g1).toBe(g2);
    expect(b1).toBe(b2);
  });
});

describe('getHueAtTime', () => {
  test('returns hue at time 0', () => {
    const hue = getHueAtTime(0);
    expect(hue).toBe(120); // Matrix green
  });

  test('returns hue for time within keyframes', () => {
    const hue = getHueAtTime(300);
    expect(hue).toBe(120); // Still green (constant keyframes)
  });

  test('returns final hue past last keyframe', () => {
    const hue = getHueAtTime(1000);
    expect(hue).toBe(120);
  });
});
