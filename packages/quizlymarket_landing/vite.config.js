import { defineConfig } from 'vite';

export default defineConfig({
  base: '/landing/',
  root: '.',
  publicDir: 'public',
  build: { outDir: 'dist', emptyOutDir: true, target: 'es2018' },
});
