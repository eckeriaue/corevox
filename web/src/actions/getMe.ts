import { defineAction } from 'astro:actions'

export const getMe = defineAction({
  async handler(_input, context) {
    return context.session?.get('me') || Promise.resolve(null)
  }
})
