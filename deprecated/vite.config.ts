/// <reference types="vitest" />

/**
 * Vite Configuration File
 *
 * This configuration sets up a modern development environment for building a React component library.
 * It includes support for TypeScript, React with SWC for faster builds, Tailwind CSS, path aliases,
 * ESLint integration, PWA capabilities, and testing configurations using Vitest.
 *
 * @see https://vitejs.dev/config/
 * @see https://vitest.dev/config/
 */

import { defineConfig } from "vite";
import path, { resolve } from "node:path";
import react from "@vitejs/plugin-react-swc";
import dts from "vite-plugin-dts";
import tailwindcss from "tailwindcss";
import tsconfigPaths from "vite-tsconfig-paths";
import eslintPlugin from "@nabla/vite-plugin-eslint";
import { VitePWA } from "vite-plugin-pwa";
import camelCase from "camelcase";
import packageJson from "./package.json";

// Helper function to get the package name in PascalCase
const getPackageNameCamelCase = (): string => {
  const name = packageJson.name;
  if (!name) {
    throw new Error("Name property in package.json is missing.");
  }
  return camelCase(name, { pascalCase: true });
};

// Get the package name from package.json
const packageName = packageJson.name.split("/").pop() || packageJson.name;

// Function to generate file names based on the format
const fileName = (format: string): string => {
  switch (format) {
    case "es":
      return `${packageName}.esm.js`;
    case "cjs":
      return `${packageName}.cjs.js`;
    case "umd":
      return `${packageName}.umd.js`;
    case "iife":
      return `${packageName}.iife.js`;
    default:
      return `${packageName}.${format}.js`;
  }
};

// Export the Vite configuration
export default defineConfig(({ mode }) => ({
  // Base public path when serving in development or production
  base: "./",

  // Build options
  build: {
    // Directory to output built files
    outDir: "./dist",

    // Library mode configuration
    lib: {
      // Entry point of the library
      entry: resolve(__dirname, "src/index.ts"),
      // Library name in PascalCase (e.g., MyComponentLibrary)
      name: getPackageNameCamelCase(),
      // Output formats: ESM, CommonJS, UMD, and IIFE
      formats: ["es", "cjs", "umd", "iife"],
      // Output file names
      fileName: (format) => fileName(format),
    },
    // Rollup options for externalizing dependencies and setting globals
    rollupOptions: {
      // External dependencies not to bundle into the library
      external: ["react", "react-dom", "tailwindcss"],
      output: {
        // Global variables for UMD/IIFE builds
        globals: {
          react: "React",
          "react-dom": "ReactDOM",
          tailwindcss: "tailwindcss",
        },
      },
    },
    // Generate sourcemaps for better debugging
    sourcemap: true,
    // Empty the output directory before each build
    emptyOutDir: true,
    // Minification options using Terser
    minify: "terser",
    terserOptions: {
      // Keep class names and function names (useful for debugging and class components)
      keep_classnames: true,
      keep_fnames: true,
    },
  },

  // Plugins to use
  plugins: [
    // Resolve paths based on tsconfig paths
    tsconfigPaths(),
    // React plugin with SWC for faster builds
    react(),
    // Conditionally include plugins based on the mode
    ...(mode === "test"
      ? []
      : [
          // ESLint plugin for code linting
          eslintPlugin(),
          // PWA plugin for progressive web app features
          VitePWA({
            registerType: "autoUpdate",
            includeAssets: [
              "favicon.png",
              "robots.txt",
              "apple-touch-icon.png",
              "icons/*.svg",
              "fonts/*.woff2",
            ],
            manifest: {
              theme_color: "#BD34FE",
              icons: [
                {
                  src: "/android-chrome-192x192.png",
                  sizes: "192x192",
                  type: "image/png",
                  purpose: "any maskable",
                },
                {
                  src: "/android-chrome-512x512.png",
                  sizes: "512x512",
                  type: "image/png",
                },
              ],
            },
          }),
        ]),
    // Generate TypeScript declaration files
    dts({
      // Insert types entry in package.json
      insertTypesEntry: true,
      // Rollup types to a single declaration file
      rollupTypes: true,
    }),
  ],

  // CSS options
  css: {
    postcss: "./postcss.config.cjs",
    // postcss: {
    //   plugins: [tailwindcss],
    // },
  },

  // Resolve options for path aliases
  resolve: {
    alias: [
      // Alias '@' to './src' for easy imports
      { find: "@", replacement: path.resolve(__dirname, "src") },
      // Alias '@@' to project root
      { find: "@@", replacement: path.resolve(__dirname) },
    ],
  },

  // Test configuration for Vitest
  test: {
    // Enable global variables like 'describe' and 'it'
    globals: true,
    // Test environment ('jsdom' for browser-like environment)
    environment: "jsdom",
    // Setup files to run before each test suite
    setupFiles: "src/setupTests.ts",
    // Include patterns for test files
    include: ["src/**/__tests__/*", "**/*.test.{ts,tsx}"],
    // Clear mocks after each test
    clearMocks: true,
    // Coverage configuration
    coverage: {
      // Files to include in coverage
      include: ["src/**/*"],
      // Files to exclude from coverage
      exclude: ["src/main.tsx"],
      // Coverage thresholds
      thresholds: {
        statements: 100,
        branches: 100,
        functions: 100,
        lines: 100,
      },
      // Coverage provider
      provider: "istanbul",
      // Enable coverage
      enabled: true,
      // Coverage reporters
      reporter: ["text", "lcov"],
      // Directory to output coverage reports
      reportsDirectory: "coverage",
    },
  },

  // Development server configuration
  server: {
    // Expose the server on all network interfaces
    host: true,
    // Port to run the development server
    port: 3000,
  },
}));
