/**
 * @file cspell.config.ts
 * @description Configuration file for cSpell, a spelling checker for code, comments, and more.
 *
 * This file defines cSpell settings to configure how it scans and checks spelling
 * within the project, including the language, paths to ignore, and additional advanced options.
 *
 * @see https://cspell.org/configuration
 * @see https://www.npmjs.com/package/cspell
 *
 * @type {import("cspell").CSpellUserSettings}
 */

import { noCase } from "change-case";
import { type AdvancedCSpellSettings } from "@cspell/cspell-types";
import { type PackageManifest } from "@pnpm/types";
import { readPackageJson } from "@pnpm/read-package-json";

// Load the `package.json` file to access metadata dynamically.
const packageJson: PackageManifest = await readPackageJson("package.json");

// Log the package name in kebab-case using `noCase` from the `change-case` library.
console.log(noCase(packageJson.name, { delimiter: "-" }));

/**
 * cSpell settings object.
 *
 * - Defines the version of the settings schema.
 * - Sets the default language to English (US).
 * - Includes paths and file patterns to ignore during spell checking.
 */
const settings: AdvancedCSpellSettings = {
  version: "0.2", // Version of the cSpell configuration schema.
  language: "en-US", // Default language for spell checking.
  useGitignore: true, // Enable ignoring paths defined in `.gitignore`.

  /**
   * List of file paths and patterns to ignore during spell checking.
   *
   * Includes commonly ignored directories, lock files, build outputs, and
   * various types of binary and image files.
   */
  ignorePaths: [
    "**/.gitignore", // Gitignore files
    "**/pnpm-lock.yaml", // Lock files
    "**/package.json", // `package.json` files
    "**/package-lock.json", // `package-lock.json` files
    "**/node_modules", // Node.js modules
    "**/dist", // Distribution directories
    "**/build", // Build directories
    "**/coverage", // Coverage reports
    "**/public", // Public assets
    "**/venv", // Virtual environments
    "**/virtualenv", // Alternative virtual environment folder
    "**/.venv", // Common hidden virtual environment folder
    "**/temp", // Temporary files and directories
    "**/tmp", // Alternative temporary directory
    "**/out", // Output directories
    "**/output", // Alternative output directory
    "**/bin", // Binary files
    "**/.git", // Git metadata
    "**/.vscode", // VSCode settings
    "**/.idea", // IntelliJ IDEA settings
    "**/*.drawio", // Diagrams
    "**/*.svg", // Scalable vector graphics
    "**/*.png", // PNG images
    "**/*.jpg", // JPEG images
    "**/*.jpeg", // Alternative JPEG format
    "**/*.otf", // Font files
    "**/.vitepress/cache", // VitePress cache
    "**/.vitepress/dist", // VitePress distribution folder
  ],
};

export default settings;
