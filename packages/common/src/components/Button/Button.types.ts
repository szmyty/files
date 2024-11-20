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

  /**
   * Optional placeholder attribute.
   * Useful for accessibility or custom scenarios.
   */
  placeholder?: string;

  /**
   * Event handler triggered when a pointer enters the button.
   */
  onPointerEnterCapture?: React.PointerEventHandler<HTMLButtonElement>;

  /**
   * Event handler triggered when a pointer leaves the button.
   */
  onPointerLeaveCapture?: React.PointerEventHandler<HTMLButtonElement>;
};
