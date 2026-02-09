/**
 * MatrixColumn class representing a single vertical column of falling characters
 */

import { MATRIX_CHARS, NUM_ROWS } from './config.js';

/**
 * Represents a single vertical column of falling characters.
 *
 * Each column has:
 * - A head position that falls downward
 * - A trail of fading characters behind the head
 * - Random speed and trail length for visual variety
 * - Characters that randomly change to create a "glitchy" effect
 */
export class MatrixColumn {
  /** Horizontal pixel position of the column */
  readonly x: number;

  /** Number of character rows in the grid */
  private readonly numRows: number;

  /** List of characters displayed in this column */
  private chars: string[];

  /** Current vertical position of the bright "head" character */
  private headY: number;

  /** How fast the column falls (rows per frame) */
  private speed: number;

  /** Number of characters in the fading trail */
  private trailLength: number;

  /** Probability of a character changing each frame */
  private readonly charChangeProb: number = 0.02;

  /** Array of characters for random selection */
  private readonly charArray: string[];

  constructor(x: number, numRows: number = NUM_ROWS) {
    this.x = x;
    this.numRows = numRows;

    // Convert MATRIX_CHARS string to array for random access
    this.charArray = [...MATRIX_CHARS];

    // Pre-populate with random characters
    this.chars = Array.from({ length: numRows }, () => this.randomChar());

    // Start above the visible screen for a staggered entrance
    this.headY = this.randomInt(-numRows, 0);

    // Randomize speed and trail for visual variety
    this.speed = this.randomFloat(0.3, 1.0);
    this.trailLength = this.randomInt(10, 31);
  }

  /**
   * Get a random character from MATRIX_CHARS
   */
  private randomChar(): string {
    return this.charArray[Math.floor(Math.random() * this.charArray.length)];
  }

  /**
   * Get a random integer in range [min, max)
   */
  private randomInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min)) + min;
  }

  /**
   * Get a random float in range [min, max)
   */
  private randomFloat(min: number, max: number): number {
    return Math.random() * (max - min) + min;
  }

  /**
   * Advance the column by one frame.
   *
   * Moves the head position down, resets when off-screen, and randomly
   * mutates some characters for the glitch effect.
   */
  update(): void {
    this.headY += this.speed;

    // Reset column when it falls completely off screen
    if (this.headY - this.trailLength > this.numRows) {
      // Respawn above the screen with new random properties
      this.headY = this.randomInt(-this.trailLength * 2, -this.trailLength);
      this.speed = this.randomFloat(0.3, 1.0);
      this.trailLength = this.randomInt(10, 31);
    }

    // Randomly mutate characters for the "glitchy" look
    for (let i = 0; i < this.chars.length; i++) {
      if (Math.random() < this.charChangeProb) {
        this.chars[i] = this.randomChar();
      }
    }
  }

  /**
   * Calculate the brightness of a character at a specific row.
   *
   * The head character is brightest (rendered white), and characters
   * fade out along the trail behind it.
   *
   * @param row - The row index to check
   * @returns Brightness value from 0.0 (invisible) to 1.0 (full bright)
   */
  getBrightness(row: number): number {
    const distanceFromHead = this.headY - row;

    // Not visible: either ahead of head or past the trail
    if (distanceFromHead < 0 || distanceFromHead > this.trailLength) {
      return 0.0;
    }

    // Head character is brightest
    if (distanceFromHead < 1) {
      return 1.0;
    }

    // Trail fades out linearly
    return Math.max(0, 1.0 - distanceFromHead / this.trailLength);
  }

  /**
   * Get the character at a specific row
   *
   * @param row - The row index
   * @returns The character at that row
   */
  getChar(row: number): string {
    return this.chars[row % this.chars.length];
  }
}
