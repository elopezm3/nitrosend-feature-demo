import { defineConfig } from "vite"
import vue from "@vitejs/plugin-vue"
import tailwindcss from "@tailwindcss/vite"
import { fileURLToPath, URL } from "node:url"

export default defineConfig({
  plugins: [vue(), tailwindcss()],
  // Vite's output goes to public/spa so it cannot collide with anything Rails
  // precompiles into public/assets.
  build: { assetsDir: "spa" },
  resolve: {
    alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) }
  },
  server: {
    port: 5173,
    // Proxying to Rails keeps the browser on one origin, so the API needs no
    // CORS gem and cookies behave normally in development.
    proxy: {
      "/api": { target: "http://localhost:3000", changeOrigin: true }
    }
  }
})
