import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      // Travel frontend path: merchant-frontend -> travel-api.
      '/api/travel': {
        target: 'http://127.0.0.1:9200',
        changeOrigin: true,
      },
      '/merchant': {
        target: 'http://127.0.0.1:9108',
        changeOrigin: true,
      },
      '/api': {
        target: 'http://127.0.0.1:9108',
        changeOrigin: true,
      },
      '/static': {
        target: 'http://127.0.0.1:9108',
        changeOrigin: true,
      },
    },
  },
})
