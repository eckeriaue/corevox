import { Socket } from 'phoenix'

export const socket = typeof window !== 'undefined' ? new Socket(new URL('/socket', `wss://${globalThis.location.host}`).toString()) : null
if (socket) {
  socket.connect()
}
