/**
 * cSpell Configuration Options
 *
 * @see https://cspell.org/configuration
 * @see https://www.npmjs.com/package/cspell
 *
 * @type {import("cspell").CSpellUserSettings}
 */
import { noCase } from "change-case";
import { type AdvancedCSpellSettings } from "@cspell/cspell-types";
import { type PackageManifest } from "@pnpm/types";
import { type PackageJson } from "type-fest";
import { readPackageJson } from "@pnpm/read-package-json";

const packageJson: PackageManifest = readPackageJson("package.json");

console.log(noCase(packageJson.name, { delimiter: "-" }));

const settings: AdvancedCSpellSettings = {
  version: "0.2",
  language: "en-US",
  useGitignore: true,
  ignorePaths: [
    "**/.gitignore",
    "**/pnpm-lock.yaml",
    "**/package.json",
    "**/package-lock.json",
    "**/node_modules",
    "**/dist",
    "**/build",
    "**/coverage",
    "**/public",
    "**/venv",
    "**/virtualenv",
    "**/.venv",
    "**/temp",
    "**/tmp",
    "**/out",
    "**/output",
    "**/bin",
    "**/.git",
    "**/.vscode",
    "**/.idea",
    "**/*.drawio",
    "**/*.svg",
    "**/*.png",
    "**/*.jpg",
    "**/*.jpeg",
    "**/*.otf",
    "**/.vitepress/cache",
    "**/.vitepress/dist",
  ]
};

export default settings;
