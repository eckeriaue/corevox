import { defineAction } from 'astro:actions'

export const me = defineAction({
  async handler(_input, context) {
    const me = await context.session?.get('me')
    if (me) {
      return ({ user: me.user, token: me.token })
    } else {
      return ({ user: null, token: null })
    }
  }
})
