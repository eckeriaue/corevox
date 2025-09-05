import { defineAction } from 'astro:actions'

export const setMe = defineAction({
  async handler(input, context) {
    const saveMe = context.session?.set('me', {
      id: input.id,
      email: input.email,
      name: input.name,
      token: input.token,
    })
    await (saveMe || Promise.resolve())
    return { ok: !!saveMe }
  }
})
