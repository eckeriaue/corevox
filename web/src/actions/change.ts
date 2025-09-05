import type { APIContext } from 'astro'

export async function POST(context: APIContext) {
  const { theme } = await context.request.json()
  await (context.session?.set('theme', theme) || Promise.resolve())

  return Response.json({ success: true })
}
