import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// The `/proxy` route forwards job-board requests to the local proxy server
// (run `npm run proxy`) so career-page APIs work in the browser despite CORS.
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/proxy': {
        target: 'http://localhost:8787',
        changeOrigin: true,
      },
    },
  },
  build: {
    rollupOptions: {
      output: {
        // Split heavy, rarely-changing deps into their own cacheable chunks so
        // the initial app bundle stays small.
        manualChunks: {
          firebase: ['firebase/app', 'firebase/auth', 'firebase/firestore'],
          react: ['react', 'react-dom', 'react-router-dom'],
        },
      },
    },
  },
});
