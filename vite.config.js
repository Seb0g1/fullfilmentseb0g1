import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    open: true
  },
  build: {
    // Оптимизация сборки
    target: 'es2015',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true, // Удаляем console.log в production
        drop_debugger: true,
      },
    },
    // Code splitting
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-vue': ['vue', 'vue-router'],
          'vendor-gsap': ['gsap'],
          'vendor-three': ['three'],
        },
      },
    },
    // Увеличиваем лимит предупреждений
    chunkSizeWarningLimit: 1000,
    // Оптимизация CSS
    cssCodeSplit: true,
    cssMinify: true,
  },
  // Оптимизация зависимостей
  optimizeDeps: {
    include: ['vue', 'vue-router', 'gsap'],
    exclude: ['three'], // Three.js лучше загружать динамически
  },
})
