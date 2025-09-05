import { defineAction } from 'astro:actions'

export const me = defineAction({
  async handler(_input, context) {
    const me = await context.session?.get('me')
    if (me) {
      return Response.json({ user: me.user })
    } else {
      return Response.json({ user: null })
    }
  }
})
