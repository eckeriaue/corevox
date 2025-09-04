import type { APIRoute } from 'astro'

export const POST: APIRoute = async ({ params, request, cookies }) => {
  const body = await request.json()
  const { jwtToken } = body

  cookies.set('jwt', jwtToken, {
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 60 * 60 * 24,
    path: '/',
  })

  return new Response(
    JSON.stringify({
      message: 'Токен сохранен в cookie',
    }),
    { status: 200 }
  )
}
