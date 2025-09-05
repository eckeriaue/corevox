import { defineAction } from 'astro:actions'

export const server = {
  changeTheme: defineAction({
    async handler(input, context) {
      console.info(input.theme)
      await (context.session?.set('theme', input.theme) || Promise.resolve())
    }
  })
}
