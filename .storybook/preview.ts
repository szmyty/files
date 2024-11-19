/**
 * @file preview.ts
 * @description Configuration for Storybook's preview settings, including parameters, themes, and decorators.
 * @author Alan Szmyt
 * @version 1.0.0
 *
 * This file sets up global configurations for Storybook's preview mode.
 * - Configures `parameters` to define Storybook's behavior, including controls, actions, and documentation.
 * - Utilizes `themes` from Storybook's theming module to apply a dark theme to the documentation.
 * - Defines a `preview` object with parameters and decorators.
 */

import type { Preview, Parameters } from "@storybook/react";
import { themes } from "@storybook/theming";

/**
 * Global parameters for Storybook.
 * These parameters control the behavior of the Storybook UI and how stories are rendered.
 */
export const parameters: Parameters = {
  /**
   * Configures actions in Storybook.
   * - Matches event handler properties (e.g., `onClick`, `onSubmit`) to generate action logs.
   * - Uses a regex pattern to identify prop names starting with "on" followed by an uppercase letter.
   */
  actions: { argTypesRegex: "^on[A-Z].*" },

  /**
   * Configures controls for Storybook's addon panel.
   * - `matchers.color`: Identifies properties related to color or background color for color pickers.
   * - `matchers.date`: Identifies properties ending with "Date" for date pickers.
   */
  controls: {
    matchers: {
      color: /(background|color)$/i, // Matches color-related properties
      date: /Date$/, // Matches date-related properties
    },
  },

  /**
   * Configures the documentation theme for Storybook.
   * - Sets the documentation theme to `themes.dark` for a dark mode appearance.
   */
  docs: {
    theme: themes.dark,
  },

  /**
   * Configures the layout for Storybook stories.
   * - `fullscreen`: Ensures the stories take up the full screen for better visualization.
   */
  layout: "fullscreen",
};

/**
 * Preview configuration for Storybook.
 * - Combines global `parameters` and an array of decorators (currently empty).
 * - Defines the `preview` object exported to Storybook.
 */
const preview: Preview = {
  parameters: parameters, // Assign global parameters
  decorators: [], // Array of global decorators (empty for now)
};

export default preview; // Export the preview configuration
