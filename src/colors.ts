/**
 * Color utilities for the Matrix Screensaver Generator
 */

import { COLOR_KEYFRAMES } from './config.js';
import type { RGB } from './types.js';

/**
 * Convert HSV color to RGB tuple.
 *
 * @param hue - Hue in degrees (0-360)
 * @param saturation - Color saturation (0.0-1.0). Lower = more washed out.
 * @param value - Brightness (0.0-1.0). Lower = darker.
 * @returns RGB tuple [R, G, B] with values 0-255
 */
export function hsvToRgb(
  hue: number,
  saturation: number = 0.9,
  value: number = 1.0,
): RGB {
  // Normalize hue to 0-1 range
  const h = (((hue % 360) + 360) % 360) / 360;
  const s = saturation;
  const v = value;

  let r: number, g: number, b: number;

  if (s === 0) {
    // Achromatic (gray)
    r = g = b = v;
  } else {
    const i = Math.floor(h * 6);
    const f = h * 6 - i;
    const p = v * (1 - s);
    const q = v * (1 - f * s);
    const t = v * (1 - (1 - f) * s);

    switch (i % 6) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      default:
        r = v;
        g = p;
        b = q;
        break;
    }
  }

  return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
}

/**
 * Calculate the hue value at a given timestamp using linear interpolation.
 *
 * Interpolates between COLOR_KEYFRAMES to determine the current hue.
 * This enables smooth color transitions over time.
 *
 * @param t - Time in seconds since video start
 * @returns Hue value in degrees (0-360)
 */
export function getHueAtTime(t: number): number {
  for (let i = 0; i < COLOR_KEYFRAMES.length - 1; i++) {
    const { time: t1, hue: h1 } = COLOR_KEYFRAMES[i];
    const { time: t2, hue: h2 } = COLOR_KEYFRAMES[i + 1];

    if (t1 <= t && t <= t2) {
      // Linear interpolation between keyframes
      const progress = (t - t1) / (t2 - t1);
      const hue = h1 + (h2 - h1) * progress;
      return ((hue % 360) + 360) % 360;
    }
  }

  // Past last keyframe, return final hue
  const lastHue = COLOR_KEYFRAMES[COLOR_KEYFRAMES.length - 1].hue;
  return ((lastHue % 360) + 360) % 360;
}
