import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

// Static marketing page for Financo. Builds to dist/ for any static host.
export default defineConfig({
  // Relative base so assets resolve under the GitHub Pages project subpath
  // (/financo/). The live app is published one level down at /financo/app/.
  base: "./",
  plugins: [tailwindcss()],
  build: { outDir: "dist", emptyOutDir: true },
});
