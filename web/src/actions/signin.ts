import { defineAction } from 'astro:actions'

export const signin = defineAction({
  async handler(input, context) {
    // remember
    const saveMe = context.session?.set('me', {
      token: input.token,
      user: {
        id: input.user.id,
        email: input.user.email,
        username: input.user.username,
      }
    })
    await (saveMe || Promise.resolve()).catch((error) => {
      console.error(error)
    })
    return { redirect: '/' }
  }
})
