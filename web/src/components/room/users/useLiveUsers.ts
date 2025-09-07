import type { Channel } from 'phoenix'
import type { MaybeRef, Ref } from 'vue'
import type { User } from './User'
import { toRaw, toValue } from 'vue'
import { makeMyId } from './makeMyId'

export function useLiveUsers(roomId: MaybeRef<string>, userId: MaybeRef<number>, channel: Channel, users: Ref<User[]>) {
  channel.on('presence_diff', (diff) => {
    if (diff.joins) {
      Object.entries(diff.joins)
        .filter(([_, { metas }]) => metas.at(0).id !== toValue(userId))
        .filter(([_, { metas }]) => !users.value.some(user => user.id === metas.at(0).id))
        .forEach(async ([_, { metas }]) => {
          const remoteUser = metas.at(0)
          users.value.push({
            enableCamera: remoteUser.enable_camera || false,
            enableMicrophone: remoteUser.enable_microphone || false,
            rtcId: makeMyId(toValue(roomId), toValue(userId)),
            streams: [],
            id: remoteUser.id,
            username: remoteUser.username,
            email: remoteUser.email,
            joined_at: new Date(remoteUser.joined_at)
          })
      })
    }
    if (diff.leaves) {
      Object.entries(diff.leaves).forEach(([_, { metas }]) => {
        users.value = users.value.filter(user => user.id !== metas[0].id)
      })
    }
  })

}
