import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  build: {
    lib: {
      entry: "src/index.ts", // Path to your library's entry point
      name: "CommonComponents", // Global name for UMD builds
      fileName: (format) => `common-components.${format}.js`, // Output file names
    },
    rollupOptions: {
      // Exclude dependencies from the bundled output
      external: ["react", "react-dom"],
      output: {
        globals: {
          react: "React",
          "react-dom": "ReactDOM",
        },
      },
    },
  },
});
