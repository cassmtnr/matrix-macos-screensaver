/**
 * Configuration constants for the Matrix Screensaver Generator
 */

import type { ColorKeyframe } from './types.js';

// =============================================================================
// VIDEO CONFIGURATION
// =============================================================================

/** Video width in pixels */
export const WIDTH = 1920;

/** Video height in pixels */
export const HEIGHT = 1080;

/** Frames per second */
export const FPS = 30;

/** Total video length in seconds (the screensaver loops this) */
export const DURATION_SECONDS = 60;

// =============================================================================
// MATRIX RAIN CONFIGURATION
// =============================================================================

/** Character size in pixels */
export const FONT_SIZE = 18;

/** Horizontal spacing between columns */
export const COLUMN_WIDTH = FONT_SIZE;

/** Calculated number of character columns */
export const NUM_COLUMNS = Math.floor(WIDTH / COLUMN_WIDTH);

/** Number of character rows (extra rows for off-screen spawning) */
export const NUM_ROWS = Math.floor(HEIGHT / FONT_SIZE) + 5;

/**
 * Character set used in the rain effect.
 * The original Matrix used predominantly Japanese katakana with some Latin/symbols.
 * Katakana is repeated 3x to weight it more heavily in random selection (~70% katakana).
 */
export const MATRIX_CHARS =
  // Full-width katakana
  'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン' +
  // Voiced/semi-voiced katakana
  'ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ' +
  // Latin uppercase (repeated 3x)
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
  // Cyrillic uppercase (Russian)
  'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ' +
  // Korean (Hangul)
  '가나다라마바사아자차카타파하' +
  // Greek
  'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ' +
  // Digits
  '0123456789' +
  // Symbols (Matrix-style)
  ':<>*+=-@#$%&[?]{!}';

// =============================================================================
// COLOR CONFIGURATION
// =============================================================================

/**
 * Color keyframes define the hue at specific timestamps.
 * The hue interpolates linearly between keyframes.
 *
 * Hue reference: 0=Red, 60=Yellow, 120=Green, 180=Cyan, 240=Blue, 300=Magenta
 */
export const COLOR_KEYFRAMES: ColorKeyframe[] = [
  { time: 0, hue: 120 }, // Matrix Green (hue 120°)
  { time: 600, hue: 120 }, // Stay Matrix Green throughout
];
