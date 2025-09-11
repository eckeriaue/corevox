import { Socket } from 'phoenix'

export const socket = new Socket(import.meta.env.PUBLIC_APP_SOCKET_URL)
if (socket) {
  socket.connect()
}
