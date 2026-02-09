#!/usr/bin/env bun
/**
 * Matrix Rain Screensaver Generator
 *
 * Generates a Matrix-style "digital rain" animation video and packages it as a
 * native macOS screensaver (.saver bundle).
 *
 * How it works:
 *     1. Generates individual PNG frames of the Matrix rain effect
 *     2. Encodes frames into an H.264 video using ffmpeg
 *     3. Builds the macOS screensaver bundle using xcodebuild
 *     4. Embeds the video into the bundle's Resources folder
 *
 * Requirements:
 *     - Node.js 18+
 *     - ffmpeg (brew install ffmpeg)
 *     - Xcode Command Line Tools (xcode-select --install)
 *
 * Usage:
 *     npm start
 *
 * Output:
 *     MatrixSaver.saver - Native macOS screensaver bundle ready for installation
 */

import { mkdtempSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildSaverBundle, getDirectorySize } from './bundleBuilder.js';
import { getHueAtTime } from './colors.js';
import {
  COLUMN_WIDTH,
  DURATION_SECONDS,
  FPS,
  HEIGHT,
  NUM_COLUMNS,
  NUM_ROWS,
  WIDTH,
} from './config.js';
import { generateFrame } from './frameGenerator.js';
import { MatrixColumn } from './MatrixColumn.js';
import { checkFfmpeg, encodeVideo } from './videoEncoder.js';

// Get the script directory (equivalent to Python's __file__)
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
// Go up one level from src/ to project root
const scriptDir = dirname(__dirname);

/**
 * Main entry point for the screensaver generator.
 *
 * Orchestrates the entire generation process:
 * 1. Validates required tools (ffmpeg)
 * 2. Generates PNG frames for each video frame
 * 3. Encodes frames to H.264 video using ffmpeg
 * 4. Builds the macOS screensaver bundle
 * 5. Cleans up temporary files
 */
async function main(): Promise<void> {
  console.log('Matrix Screensaver Generator');
  console.log('='.repeat(40));
  console.log(`Resolution: ${WIDTH}x${HEIGHT}`);
  console.log(
    `Duration: ${DURATION_SECONDS}s (${Math.floor(DURATION_SECONDS / 60)} minutes)`,
  );
  console.log(`FPS: ${FPS}`);
  console.log(`Total frames: ${DURATION_SECONDS * FPS}`);
  console.log();

  // Validate ffmpeg is installed
  if (!checkFfmpeg()) {
    console.error('Error: ffmpeg not found. Please install it:');
    console.error('  brew install ffmpeg');
    process.exit(1);
  }

  // Initialize all character columns
  const columns: MatrixColumn[] = [];
  for (let i = 0; i < NUM_COLUMNS; i++) {
    columns.push(new MatrixColumn(i * COLUMN_WIDTH, NUM_ROWS));
  }

  // Create temporary directory for frame images
  const tempDir = mkdtempSync(join(tmpdir(), 'matrix_frames_'));
  console.log(`Temporary frames directory: ${tempDir}`);

  const totalFrames = DURATION_SECONDS * FPS;
  const videoFile = join(scriptDir, 'matrix_screensaver.mov');

  try {
    // === Phase 1: Generate frames ===
    console.log('\nGenerating frames...');

    for (let frameNum = 0; frameNum < totalFrames; frameNum++) {
      const currentTime = frameNum / FPS;
      const hue = getHueAtTime(currentTime);

      const canvas = generateFrame(columns, hue);

      const framePath = join(
        tempDir,
        `frame_${String(frameNum).padStart(6, '0')}.png`,
      );
      const buffer = canvas.toBuffer('image/png');
      writeFileSync(framePath, buffer);

      // Progress update every 10 seconds of video
      if (frameNum % (FPS * 10) === 0) {
        const progress = (frameNum / totalFrames) * 100;
        console.log(
          `  Progress: ${progress.toFixed(1)}% ` +
            `(frame ${frameNum}/${totalFrames}, ` +
            `time ${currentTime.toFixed(1)}s, hue ${Math.round(hue)}°)`,
        );
      }
    }

    // === Phase 2: Encode video ===
    console.log('\nEncoding video with ffmpeg...');
    encodeVideo(tempDir, videoFile);

    const videoSize = statSync(videoFile).size;
    console.log(`\nVideo created: ${videoFile}`);
    console.log(`Video size: ${(videoSize / (1024 * 1024)).toFixed(1)} MB`);

    // === Phase 3: Build screensaver bundle ===
    const outputSaver = buildSaverBundle(scriptDir, videoFile);

    // Calculate and display final bundle size
    const saverSize = getDirectorySize(outputSaver);

    console.log(`\nSuccess! Created: ${outputSaver}`);
    console.log(`Bundle size: ${(saverSize / (1024 * 1024)).toFixed(1)} MB`);
    console.log('\nTo install:');
    console.log('  1. Double-click MatrixSaver.saver to install, or:');
    console.log('  2. Copy to ~/Library/Screen Savers/ manually');
    console.log('\nTo test:');
    console.log('  open /System/Library/PreferencePanes/ScreenSaver.prefPane');
  } finally {
    // Always clean up temporary frame files
    console.log('\nCleaning up temporary files...');
    rmSync(tempDir, { recursive: true, force: true });
  }
}

// Run the main function
main().catch((error) => {
  console.error('Error:', error.message);
  process.exit(1);
});
