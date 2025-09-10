import { Socket } from 'phoenix'

export const socket = typeof window !== 'undefined' ? new Socket('/socket') : null
if (socket) {
  socket.connect()
}
