import { Socket } from 'phoenix'

console.info("import.meta.env.PUBLIC_APP_SOCKET_URL", import.meta.env.PUBLIC_APP_SOCKET_URL)
export const socket = new Socket(import.meta.env.PUBLIC_APP_SOCKET_URL)
if (socket) {
  socket.connect()
}
