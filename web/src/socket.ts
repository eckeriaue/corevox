import { Socket } from 'phoenix'

export const socket = typeof window !== 'undefined' ? new Socket(import.meta.env.PUBLIC_APP_SOCKET_URL) : null
if (socket) {
  socket.connect()
}
