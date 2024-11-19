/**
 * @file manager.ts
 * @description Configures the Storybook Manager UI theme and other manager-level settings.
 * @version 1.0.0
 *
 * This file sets global configurations for the Storybook Manager, specifically applying
 * a dark theme to the Storybook interface.
 *
 * @see https://storybook.js.org/docs/react/configure/features-and-behavior#manager-api
 */

import { addons } from "@storybook/manager-api";
import { themes } from "@storybook/theming";

/**
 * Configure the Storybook Manager with custom settings.
 *
 * @description The `addons.setConfig` method is used to customize the behavior and appearance
 * of the Storybook Manager. In this case, the dark theme from `@storybook/theming` is applied.
 *
 * @example
 * addons.setConfig({
 *   theme: themes.dark, // Apply the dark theme.
 * });
 */
addons.setConfig({
  theme: themes.dark, // Set the Storybook Manager to use the dark theme.
});
