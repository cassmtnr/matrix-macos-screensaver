/**
 * Video encoding using ffmpeg subprocess
 */

import { execSync, spawnSync } from 'node:child_process';
import { join } from 'node:path';
import { FPS } from './config.js';

/**
 * Check if ffmpeg is available on the system
 *
 * @returns true if ffmpeg is available
 */
export function checkFfmpeg(): boolean {
  try {
    execSync('which ffmpeg', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

/**
 * Encode PNG frames to H.264 video using ffmpeg.
 *
 * @param framesDir - Directory containing frame_XXXXXX.png files
 * @param outputPath - Path for the output .mov file
 * @throws Error if ffmpeg fails
 */
export function encodeVideo(framesDir: string, outputPath: string): void {
  const inputPattern = join(framesDir, 'frame_%06d.png');

  const args = [
    '-y', // Overwrite output file
    '-framerate',
    String(FPS), // Input frame rate
    '-i',
    inputPattern, // Input pattern
    '-c:v',
    'libx264', // H.264 codec
    '-preset',
    'medium', // Encoding speed/quality tradeoff
    '-crf',
    '18', // Quality (lower = better, 18 is high)
    '-pix_fmt',
    'yuv420p', // Pixel format for compatibility
    '-movflags',
    '+faststart', // Enable streaming/seeking
    outputPath,
  ];

  const result = spawnSync('ffmpeg', args, {
    stdio: ['ignore', 'pipe', 'pipe'],
    encoding: 'utf-8',
  });

  if (result.status !== 0) {
    throw new Error(`FFmpeg error: ${result.stderr}`);
  }
}
