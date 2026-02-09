/**
 * TypeScript type definitions for the Matrix Screensaver Generator
 */

/** RGB color tuple [red, green, blue] with values 0-255 */
export type RGB = [number, number, number];

/** Color keyframe for hue interpolation */
export interface ColorKeyframe {
  /** Time in seconds */
  time: number;
  /** Hue in degrees (0-360) */
  hue: number;
}
