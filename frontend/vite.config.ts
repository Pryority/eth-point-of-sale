import { defineConfig } from "vite";
import path from "path";
import react from "@vitejs/plugin-react-swc";
import { vitePluginTevm } from "@tevm/vite-plugin";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react(), vitePluginTevm()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      "@foundry": path.resolve(__dirname, "../foundry"),
    },
  },
});
