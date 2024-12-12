import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [
    // Enables path aliasing based on tsconfig.json
    tsconfigPaths(),
  ],
  css: {
    postcss: "./postcss.config.cjs",
  },
  build: {
    lib: {
      // Entry point for the library
      entry: "./src/index.ts",
      // Library name for UMD/IIFE builds
      name: "ReactComponentsUtils",
      // Output formats: ESM and CommonJS
      formats: ["es", "cjs"],
      // Output file names
      fileName: (format) => `utils.${format}.js`,
    },
    rollupOptions: {
      // Externalize dependencies to prevent bundling
      external: [],
    },
    sourcemap: true, // Optional: Enables source maps
  },
});
