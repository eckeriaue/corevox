import { Socket } from 'phoenix'

console.info("import.meta.env", import.meta.env)
export const socket = new Socket(import.meta.env.PUBLIC_APP_SOCKET_URL)
if (socket) {
  socket.connect()
}
