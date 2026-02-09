/**
 * Frame generation using @napi-rs/canvas
 */

import { type Canvas, createCanvas } from '@napi-rs/canvas';
import { hsvToRgb } from './colors.js';
import { FONT_SIZE, HEIGHT, NUM_ROWS, WIDTH } from './config.js';
import { loadFont } from './fontLoader.js';
import type { MatrixColumn } from './MatrixColumn.js';

/**
 * Render a single frame of the Matrix rain effect.
 *
 * Draws all visible characters from all columns onto a black background.
 * The head of each column is rendered white; trail characters use the
 * current hue with fading brightness.
 *
 * @param columns - List of MatrixColumn objects to render
 * @param hue - Current color hue (0-360 degrees)
 * @returns Canvas containing the rendered frame
 */
export function generateFrame(columns: MatrixColumn[], hue: number): Canvas {
  const canvas = createCanvas(WIDTH, HEIGHT);
  const ctx = canvas.getContext('2d');

  // Start with black background
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, WIDTH, HEIGHT);

  // Load and set font
  const fontFamily = loadFont();
  ctx.font = `${FONT_SIZE}px "${fontFamily}"`;
  ctx.textBaseline = 'top';

  // Get the base color for trail characters
  const baseColor = hsvToRgb(hue, 0.85, 1.0);

  for (const col of columns) {
    for (let row = 0; row < NUM_ROWS; row++) {
      const brightness = col.getBrightness(row);

      // Skip invisible characters
      if (brightness <= 0) {
        continue;
      }

      const char = col.getChar(row);
      const x = col.x;
      const y = row * FONT_SIZE;

      // Head characters are white, trail characters fade with the hue
      let color: string;
      if (brightness >= 0.95) {
        color = 'rgb(255, 255, 255)';
      } else {
        const r = Math.round(baseColor[0] * brightness * 0.9);
        const g = Math.round(baseColor[1] * brightness * 0.9);
        const b = Math.round(baseColor[2] * brightness * 0.9);
        color = `rgb(${r}, ${g}, ${b})`;
      }

      ctx.fillStyle = color;

      try {
        ctx.fillText(char, x, y);
      } catch {
        // Fallback for characters the font can't render
        ctx.fillText('0', x, y);
      }
    }

    // Advance the column for the next frame
    col.update();
  }

  return canvas;
}
