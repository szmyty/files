/**
 * @file Button.types.ts
 * @description Type definitions for the Button component.
 */

import type { ButtonProps as MTButtonProps } from "@material-tailwind/react";

/**
 * Props for the Button component.
 * Extends Material Tailwind ButtonProps for consistency.
 */
export type ButtonProps = MTButtonProps & {
  /** Content of the Button. */
  children: React.ReactNode;
};
