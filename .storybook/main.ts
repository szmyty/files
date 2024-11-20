/**
 * @file main.ts
 * @description Storybook configuration file for a Vite-powered React project.
 * Configures Storybook's behavior, paths, addons, TypeScript settings, and integrates Vite settings.
 *
 * @version 1.0.0
 *
 * This file contains the primary configuration for Storybook in a project using the Vite builder.
 * It specifies:
 * - Story paths.
 * - Addons for extended functionality.
 * - Framework and TypeScript options.
 * - Custom Vite final configuration with aliases for development and production environments.
 */

import { type StorybookConfig } from "@storybook/react-vite";
import { InlineConfig, mergeConfig } from "vite";
import path from "path";

// Resolves the project root directory relative to the `.storybook` directory.
const projectRoot = path.resolve(__dirname, "../");

/**
 * Storybook configuration object.
 * @see https://storybook.js.org/docs/react/configure/overview
 */
const config: StorybookConfig = {
  /**
   * Paths to locate story files in the project.
   * Uses glob patterns to include `.stories` files in the `src` directory.
   */
  stories: [
    path.join(projectRoot, "src", "**", "*.stories.@(js|jsx|ts|tsx|mdx)"),
  ],

  /**
   * Addons extend Storybook functionality.
   * These addons provide features like links, documentation, and interactions.
   */
  addons: [
    "@storybook/addon-links", // Allows navigation between stories.
    "@storybook/addon-essentials", // Provides a set of essential addons (e.g., controls, actions, docs).
    "@storybook/addon-onboarding", // Helps with getting started with Storybook.
    "@storybook/addon-interactions", // Adds support for interaction testing.
    "@storybook/addon-coverage", // Enables coverage reporting for stories.
  ],

  /**
   * Framework configuration.
   * Specifies React with Vite as the builder.
   */
  framework: {
    name: "@storybook/react-vite",
    options: {},
  },

  /**
   * Documentation settings.
   * Additional configurations for generating documentation can be added here.
   */
  docs: {},

  /**
   * Core configuration.
   * Disables telemetry, crash reports, and notifications to streamline the build process.
   */
  core: {
    builder: "@storybook/builder-vite", // Specifies Vite as the builder.
    enableCrashReports: false,
    disableTelemetry: true,
    disableWhatsNewNotifications: true,
  },

  /**
   * TypeScript configuration.
   * - Enables type checking.
   * - Uses `react-docgen` for React prop documentation generation.
   */
  typescript: {
    check: true, // Ensures TypeScript checks during build.
    skipCompiler: false, // Runs the TypeScript compiler during builds.
    reactDocgen: "react-docgen", // Generates documentation for React components.
  },

  /**
   * Log level for Storybook's output.
   * `debug` provides detailed logs for troubleshooting.
   */
  logLevel: "debug",
  /**
   * Overrides environment variables for the Storybook process.
   */
  env: (config: Record<string, string> = {}): Record<string, string> => ({
    ...config,
    ESLINT_NO_DEV_ERRORS: "true", // Convert boolean to string
    DISABLE_ESLINT_PLUGIN: "true", // Convert boolean to string
  }),
  staticDirs: [],
  /**
   * Custom Vite final configuration.
   * - Adds environment-specific configuration for development and production.
   * - Merges alias settings into Vite's configuration.
   *
   * @param {InlineConfig} config - The existing Vite configuration.
   * @param {object} options - Contextual information about the current build environment.
   * @returns {Promise<Record<string, any>>} - The merged Vite configuration.
   */
  async viteFinal(
    config: InlineConfig,
    { configType },
  ): Promise<Record<string, any>> {
    if (configType === "DEVELOPMENT") {
      // Add any additional configurations specific to the development environment here.
    }
    if (configType === "PRODUCTION") {
      // Add any additional configurations specific to the production environment here.
    }

    return mergeConfig(config, {
      resolve: {
        alias: {
          // Adds `@` as an alias for the `src` directory.
          "@": path.resolve(projectRoot, "src"),
        },
      },
    });
  },
};

export default config; // Export the Storybook configuration.
