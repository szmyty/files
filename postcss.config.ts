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

module.exports = {
  /**
   * PostCSS plugins configuration.
   *
   * - `tailwindcss`: Enables the use of Tailwind CSS.
   * - `autoprefixer`: Adds vendor prefixes to CSS rules for compatibility with different browsers.
   */
  plugins: {
    tailwindcss: {}, // Tailwind CSS integration
    autoprefixer: {}, // Automatically adds vendor prefixes to CSS
  },
};
