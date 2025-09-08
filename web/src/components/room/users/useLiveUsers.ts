import type { Channel } from 'phoenix'
import type { MaybeRef, Ref } from 'vue'
import type { User } from './User'
import { onMounted, onUnmounted, toValue } from 'vue'
import { makeMyId } from './makeMyId'

type Meta = {
  id: number
  enable_camera: boolean
  enable_microphone: boolean
  username: string
  email: string
}

type UserDiff = {
  joins: Record<string, { metas: Meta[]}>
  leaves: Record<string, { metas: Meta[]}>
}

export function useLiveUsers(
  roomId: MaybeRef<string>,
  userId: MaybeRef<number>,
  channel: Channel,
  users: Ref<User[]>
) {

  function listenDiffs(diff: UserDiff) {
    if (diff.joins) {
      Object.entries(diff.joins)
        .filter(([_, { metas }]) => metas.at(0)!.id !== toValue(userId))
        .filter(([_, { metas }]) => !users.value.some(user => user.id === metas.at(0)!.id))
        .forEach(async ([_, { metas }]) => {
          const remoteUser = metas.at(0)!
          users.value.push({
            enableCamera: remoteUser.enable_camera || false,
            enableMicrophone: remoteUser.enable_microphone || false,
            rtcId: makeMyId(toValue(roomId), toValue(userId)),
            id: remoteUser.id,
            stream: new MediaStream(),
            username: remoteUser.username,
            email: remoteUser.email,
          })
      })
    }
    if (diff.leaves) {
      Object.entries(diff.leaves).forEach(([_, { metas }]) => {
        users.value = users.value.filter(user => user.id !== metas[0].id)
      })
    }
  }

  onMounted(() => {
    channel.on('presence_diff', listenDiffs)
  })

  onUnmounted(() => {
    channel.off('presence_diff', listenDiffs)
  })

}
