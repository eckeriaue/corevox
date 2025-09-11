import { Socket } from 'phoenix'

console.info("import.meta.env", import.meta.env, globalThis.env)
export const socket = new Socket(globalThis?.env?.PUBLIC_APP_SOCKET_URL || import.meta.env.PUBLIC_APP_SOCKET_URL)
if (socket) {
  socket.connect()
}
