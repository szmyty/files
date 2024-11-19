import { Config } from "tailwindcss";
import withMT from "@material-tailwind/react/utils/withMT";

/**
 * Type-safe wrapper around the withMT function.
 * Ensures the returned object conforms to Tailwind's Config type.
 */
function withMaterialTailwind(config: Config): Config {
  return withMT(config) as Config;
}

const config: Config = withMaterialTailwind({
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require("@tailwindcss/forms"),
  ],
});

export default config;
