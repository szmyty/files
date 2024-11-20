/**
 * @file postcss.config.ts
 * @description Configuration file for PostCSS, a tool for transforming CSS with JavaScript plugins.
 *
 * This file specifies plugins to use with PostCSS, including:
 * - `tailwindcss`: For integrating Tailwind CSS utilities.
 * - `autoprefixer`: To automatically add vendor prefixes for better browser compatibility.
 *
 * @see https://tailwindcss.com/docs/installation
 * @see https://github.com/postcss/autoprefixer
 */

import type { Plugin } from "postcss";

/**
 * PostCSS configuration object.
 * Defines plugins used by PostCSS to transform CSS.
 */
const config: {
  plugins: Record<string, Plugin | Record<string, unknown>>;
} = {
  plugins: {
    /**
     * Tailwind CSS integration.
     * Enables the use of Tailwind CSS utilities and customizations.
     */
    tailwindcss: {
      config: "./tailwind.config.ts",
    },

    /**
     * Autoprefixer integration.
     * Automatically adds vendor prefixes to CSS rules for better browser compatibility.
     */
    autoprefixer: {},
  },
};

export default config;
