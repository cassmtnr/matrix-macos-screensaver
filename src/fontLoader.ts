/**
 * Font loading utilities for @napi-rs/canvas
 */

import { existsSync } from 'node:fs';
import { GlobalFonts } from '@napi-rs/canvas';

/**
 * List of macOS system fonts to try, in order of preference.
 */
const FONT_PATHS = [
  // Apple SD Gothic Neo - clean CJK font with Japanese + Korean support
  '/System/Library/Fonts/AppleSDGothicNeo.ttc',
  // Fallback to Latin monospace fonts
  '/System/Library/Fonts/Monaco.ttf',
  '/System/Library/Fonts/Menlo.ttc',
];

/** The family name we'll use for the registered font */
export const FONT_FAMILY = 'MatrixFont';

/** Track if font has been registered */
let fontRegistered = false;

/**
 * Register a suitable font for rendering characters.
 *
 * @returns The font family name to use in canvas context
 */
export function loadFont(): string {
  if (fontRegistered) {
    return FONT_FAMILY;
  }

  for (const fontPath of FONT_PATHS) {
    if (existsSync(fontPath)) {
      try {
        GlobalFonts.registerFromPath(fontPath, FONT_FAMILY);
        fontRegistered = true;
        return FONT_FAMILY;
      } catch {}
    }
  }

  console.warn('Warning: No suitable font found, using system default');
  return 'monospace';
}
