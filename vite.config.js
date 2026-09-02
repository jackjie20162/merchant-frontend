import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    proxy: {
      // 商家端接口代理到 zzhshopR2-api
      '/merchant': {
        target: 'http://127.0.0.1:9108',
        changeOrigin: true,
      },
      // 公开接口（平台类目树等）代理到 zzhshopR2-api
      '/api': {
        target: 'http://127.0.0.1:9108',
        changeOrigin: true,
      },
      // 上传附件静态资源代理到 zzhshopR2-api
      '/static': {
        target: 'http://127.0.0.1:9108',
        changeOrigin: true,
      },
    },
  },
})
