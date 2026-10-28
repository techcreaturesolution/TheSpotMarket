import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
  const isProd = mode === 'production';

  return {
    plugins: [react()],
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
      },
    },
    server: {
      port: 5180,
      host: true,
    },
    esbuild: {
      drop: isProd ? ['console', 'debugger'] : [],
      legalComments: 'none',
    },
    build: {
      target: 'es2020',
      sourcemap: false,
      cssCodeSplit: true,
      minify: 'esbuild',
      chunkSizeWarningLimit: 600,
      rollupOptions: {
        output: {
          manualChunks: {
            'vendor-react': [
              'react',
              'react-dom',
              'react-router-dom',
              'react-helmet-async',
            ],
            'vendor-gsap': ['gsap', '@gsap/react'],
            'vendor-icons': ['lucide-react'],
            'vendor-forms': ['react-hook-form', '@hookform/resolvers', 'zod'],
          },
          entryFileNames: 'assets/[name]-[hash].js',
          chunkFileNames: 'assets/[name]-[hash].js',
          assetFileNames: 'assets/[name]-[hash].[ext]',
        },
      },
    },
  };
});
