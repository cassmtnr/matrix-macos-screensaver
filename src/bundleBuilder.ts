/**
 * macOS screensaver bundle building using xcodebuild
 */

import { execSync, spawnSync } from 'node:child_process';
import {
  copyFileSync,
  cpSync,
  existsSync,
  mkdirSync,
  readdirSync,
  rmSync,
  statSync,
} from 'node:fs';
import { join } from 'node:path';

/**
 * Check if xcodebuild is available on the system
 *
 * @returns true if xcodebuild is available
 */
export function checkXcodebuild(): boolean {
  try {
    execSync('which xcodebuild', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

/**
 * Recursively find a directory by name within a path
 */
function findDirectory(basePath: string, name: string): string | null {
  if (!existsSync(basePath)) {
    return null;
  }

  const entries = readdirSync(basePath, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = join(basePath, entry.name);

    if (entry.isDirectory()) {
      if (entry.name === name) {
        return fullPath;
      }

      // Recurse into subdirectories
      const found = findDirectory(fullPath, name);
      if (found) {
        return found;
      }
    }
  }

  return null;
}

/**
 * Calculate total size of a directory recursively
 */
export function getDirectorySize(dirPath: string): number {
  let totalSize = 0;

  const entries = readdirSync(dirPath, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = join(dirPath, entry.name);

    if (entry.isFile()) {
      totalSize += statSync(fullPath).size;
    } else if (entry.isDirectory()) {
      totalSize += getDirectorySize(fullPath);
    }
  }

  return totalSize;
}

/**
 * Build the macOS .saver bundle and embed the video.
 *
 * @param scriptDir - Path to the project directory containing the Xcode project
 * @param videoFile - Path to the generated .mov video file
 * @returns Path to the final MatrixSaver.saver bundle
 * @throws Error if build fails
 */
export function buildSaverBundle(scriptDir: string, videoFile: string): string {
  const buildDir = join(scriptDir, 'build');
  const outputSaver = join(scriptDir, 'MatrixSaver.saver');
  const xcodeProject = join(scriptDir, 'MatrixSaver.xcodeproj');

  // Validate Xcode project exists
  if (!existsSync(xcodeProject)) {
    throw new Error(
      `Xcode project not found at ${xcodeProject}\n` +
        'Please ensure MatrixSaver.xcodeproj exists in the same directory.',
    );
  }

  // Validate xcodebuild is available
  if (!checkXcodebuild()) {
    throw new Error(
      'xcodebuild not found. Please install Xcode Command Line Tools:\n' +
        '  xcode-select --install',
    );
  }

  console.log('\nBuilding MatrixSaver.saver...');

  // Run xcodebuild to compile the Swift screensaver
  const result = spawnSync(
    'xcodebuild',
    [
      '-project',
      xcodeProject,
      '-scheme',
      'MatrixSaver',
      '-configuration',
      'Release',
      '-derivedDataPath',
      buildDir,
      'build',
    ],
    {
      stdio: ['ignore', 'pipe', 'pipe'],
      encoding: 'utf-8',
    },
  );

  if (result.status !== 0) {
    throw new Error(
      `xcodebuild error: ${result.stderr}\n` +
        'Try running manually: xcodebuild -project MatrixSaver.xcodeproj ' +
        '-scheme MatrixSaver -configuration Release build',
    );
  }

  // Locate the built .saver bundle
  let builtSaver = join(
    buildDir,
    'Build',
    'Products',
    'Release',
    'MatrixSaver.saver',
  );

  if (!existsSync(builtSaver)) {
    // Search derived data if not in expected location
    const found = findDirectory(buildDir, 'MatrixSaver.saver');
    if (found) {
      builtSaver = found;
    }
  }

  if (!existsSync(builtSaver)) {
    throw new Error(
      'Build failed. Could not find MatrixSaver.saver in build directory.',
    );
  }

  // Copy built bundle to project root
  console.log('Copying built saver to project root...');
  if (existsSync(outputSaver)) {
    rmSync(outputSaver, { recursive: true, force: true });
  }
  cpSync(builtSaver, outputSaver, { recursive: true });

  // Embed the video in the bundle's Resources folder
  const resourcesDir = join(outputSaver, 'Contents', 'Resources');
  mkdirSync(resourcesDir, { recursive: true });

  console.log('Embedding video file...');
  copyFileSync(videoFile, join(resourcesDir, 'matrix_screensaver.mov'));

  return outputSaver;
}
