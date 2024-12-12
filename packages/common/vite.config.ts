import { defineConfig } from "vite";
import react from "@vitejs/plugin-react-swc";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [
    // Enables React with SWC for faster builds
    react(),
    // Enables path aliasing based on tsconfig.json
    tsconfigPaths(),
  ],
  build: {
    lib: {
      // Entry point for the library
      entry: "./src/index.ts",
      // Library name for UMD/IIFE builds
      name: "ReactComponentsCommon",
      // Output formats: ESM and CommonJS
      formats: ["es", "cjs"],
      // Output file names
      fileName: (format) => `common.${format}.js`,
    },
    rollupOptions: {
      // Externalize dependencies to prevent bundling
      external: ["react", "react-dom", "@react-components/utils"],
      output: {
        // Global variables for UMD/IIFE builds
        globals: {
          react: "React",
          "react-dom": "ReactDOM",
          "@react-components/utils": "ReactComponentsUtils",
        },
      },
    },
    sourcemap: true, // Optional: Enables source maps
  },
});
