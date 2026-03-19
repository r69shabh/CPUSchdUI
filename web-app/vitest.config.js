import { defineConfig } from 'vitest/config';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@algorithms': path.resolve(__dirname, './src/algorithms'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@contexts': path.resolve(__dirname, './src/contexts'),
      '@data': path.resolve(__dirname, './src/data'),
    },
  },
  test: {
    globals: true,
    environment: 'node',
    setupFiles: './src/setupTests.js',
    include: [
      'src/algorithms/__tests__/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}',
    ], // Only run algorithm tests for now
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
    },
  },
});
