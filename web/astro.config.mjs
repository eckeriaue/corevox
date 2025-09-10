// @ts-check
import { defineConfig } from 'astro/config'
import tailwindcss from '@tailwindcss/vite'
import node from '@astrojs/node'

import vue from '@astrojs/vue'

// https://astro.build/config
export default defineConfig({
  output: 'server',
  adapter: node({
    mode: 'standalone',
  }),
  devToolbar: {
    enabled: import.meta.env.DEV
  },
  vite: {
    envPrefix: ['PUBLIC_'],
    server: {
      allowedHosts: ['localhost', '127.0.0.1', 'corevox.ru'],
    },
    plugins: [tailwindcss({
      content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
    })]
  },

  integrations: [vue({ appEntrypoint: '/src/pages/_app' })]
})
