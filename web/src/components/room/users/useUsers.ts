import type { Channel } from 'phoenix'
import type { User } from './User'
import { ref } from 'vue'

type UsersMetas = {
  [key: string]: {
    metas: {
      id: number
      rtc_id: string
      email: string
      enable_camera: boolean
      enable_microphone: boolean
      username: string
    }[]
  }
}

export function useUsers(channel: Channel) {
  const users = ref<User[]>([])
  channel.on('presence_state', async (state: UsersMetas) => {
    users.value = Object.values(state).map(({ metas }) => {
      const remoteUser = metas.at(0)!
      return {
        id: remoteUser.id,
        // todo: use makeMyId
        rtcId: remoteUser.rtc_id,
        email: remoteUser.email,
        stream: new MediaStream(),
        enableCamera: remoteUser.enable_camera || false,
        enableMicrophone: remoteUser.enable_microphone || false,
        username: remoteUser.username,
      } satisfies User
    })
  })

  return { users }
}
