import { defineAction } from 'astro:actions'

export const signout = defineAction({
  async handler(_input, context) {
    const deleteMe = context.session?.destroy()
    await (deleteMe || Promise.resolve())
    const redirectUrl = new URL('/', context.url.origin).toString()
    return { redirect: redirectUrl }
  }
})
