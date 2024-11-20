/**
 * @file Button.tsx
 * @description Button component using Material Tailwind for consistent styling.
 */

import { Button as MTButton } from "@material-tailwind/react";
import { ButtonProps } from "./Button.types";

/**
 * A customizable button component styled using Material Tailwind.
 *
 * @param {ButtonProps} props - Props for the Button component.
 * @returns {JSX.Element} Rendered Button component.
 */
export default function Button({
    children,
    placeholder,
    onPointerEnterCapture,
    onPointerLeaveCapture,
    ...props
}: ButtonProps): JSX.Element {
  return (
        <MTButton
            placeholder={undefined}
            onPointerEnterCapture={undefined}
            onPointerLeaveCapture={undefined}
            {...props}
        >
            {children}
        </MTButton>
  );
}
