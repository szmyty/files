/**
 * @file tailwind.config.ts
 * @description Tailwind CSS configuration file for integrating Material Tailwind utilities.
 * This configuration uses a type-safe wrapper around the `withMT` function from `@material-tailwind/react`
 * to ensure the final configuration adheres to Tailwind CSS's `Config` type.
 *
 * @see https://tailwindcss.com/docs/configuration
 * @see https://www.material-tailwind.com/docs/react/installation
 */

import { Config } from "tailwindcss";
import withMT from "@material-tailwind/react/utils/withMT";

/**
 * Type-safe wrapper around the `withMT` function.
 *
 * @param {Config} config - The Tailwind CSS configuration object to enhance with Material Tailwind utilities.
 * @returns {Config} - The enhanced Tailwind CSS configuration object, ensuring compatibility with Material Tailwind.
 *
 * @description
 * The `withMT` function merges Material Tailwind's configuration with the base Tailwind configuration.
 * This wrapper enforces type safety, ensuring the returned object conforms to Tailwind's `Config` type.
 */
function withMaterialTailwind(config: Config): Config {
  return withMT(config) as Config;
}

/**
 * Tailwind CSS configuration object.
 *
 * @description
 * This configuration defines:
 * - The paths to scan for Tailwind CSS classes (`content`).
 * - Extensions to the default theme (`theme`).
 * - Plugins for additional utilities and components (`plugins`).
 */
const config: Config = withMaterialTailwind({
  /**
   * Paths to content files where Tailwind classes are used.
   * Tailwind scans these files to generate the necessary CSS.
   */
  content: [
    // "./index.html", // Main HTML entry file
    "./src/**/*.{vue,js,ts,jsx,tsx}", // Source files with supported extensions
  ],

  /**
   * Theme extensions.
   * Customize or extend the default Tailwind CSS theme.
   */
  theme: {
    extend: {}, // Extend default theme properties here
  },

  /**
   * Plugins to enhance Tailwind CSS functionality.
   */
  plugins: [
    require("@tailwindcss/forms"), // Adds better styling for form elements
  ],
});

export default config;
