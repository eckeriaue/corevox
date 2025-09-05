import { defineAction } from 'astro:actions'

export const changeTheme = defineAction({
  async handler(input, context) {
    console.info(input.theme)
    await (context.session?.set('theme', input.theme) || Promise.resolve())
  }
})
