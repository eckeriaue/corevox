import type { Channel } from 'phoenix'
import type { User } from './User'
import { withResolvers } from 'radashi'

type UsersMetas = {
  [key: string]: {
    metas: {
      id: number
      rtc_id: string
      email: string
      joined_at: string
      enable_camera: boolean
      enable_microphone: boolean
      username: string
    }[]
  }
}

export async function getRoomUsers(channel: Channel): Promise<User[]> {
  const { resolve, promise } = withResolvers<User[]>()
  channel.on('presence_state', async (state: UsersMetas) => {
    const users: User[] = Object.values(state).map(({ metas }) => {
      const remoteUser = metas.at(0)!
      return {
        id: remoteUser.id,
        rtcId: remoteUser.rtc_id,
        email: remoteUser.email,
        stream: new MediaStream(),
        joined_at: new Date(remoteUser.joined_at),
        enableCamera: remoteUser.enable_camera || false,
        enableMicrophone: remoteUser.enable_microphone || false,
        username: remoteUser.username,
      } satisfies User
    })
    resolve(users)
  })
  return promise
}
