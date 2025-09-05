import { defineAction } from 'astro:actions'

export const changeTheme = defineAction({
  async handler(input, context) {
    context.cookies.set('theme', input.theme, {
      path: '/',
      maxAge: 31536000,
      sameSite: 'lax',
      secure: true,
    })
    return { ok: true }
  }
})
