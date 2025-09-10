import type { Channel } from 'phoenix'
import type { User } from './User'
import { onMounted, ref, toValue, type Ref, type MaybeRef, onUnmounted, toRaw, Suspense } from 'vue'
import { makeMyId } from './makeMyId'
import { withResolvers } from 'radashi'

type Meta = {
  id: number
  rtc_id: string
  email: string
  enable_camera: boolean
  enable_microphone: boolean
  username: string
}

type UserDiff = {
  joins: Record<string, { metas: Meta[]}>
  leaves: Record<string, { metas: Meta[]}>
}

type UsersMetas = {
  [key: string]: {
    metas: Meta[]
  }
}

async function getUsers(channel: Channel): Promise<User[]> {
  return new Promise(resolve => {
    channel.on('presence_state', async (state: UsersMetas) => {
      const users = Object.values(state).map(({ metas }) => {
        const remoteUser = metas.at(0)!
        return {
          id: remoteUser.id,
          // todo: use makeMyId
          rtcId: remoteUser.rtc_id,
          email: remoteUser.email,
          // stream: new MediaStream(),
          enableCamera: remoteUser.enable_camera || false,
          enableMicrophone: remoteUser.enable_microphone || false,
          username: remoteUser.username,
        } satisfies User
      })
      console.info('users', users)
      resolve(users)
    })

  })
}

export function useUsers({
  roomId,
  userId,
  channel,
  onJoin = (..._args: never[]) => null,
  onLeave = (..._args: never[]) => null,
  // onLoad = (..._args: never[]) => null,
}: {
  roomId: MaybeRef<string>,
  userId: MaybeRef<number>,
  channel: Channel,
  onJoin?(user: User): void,
  // onLoad?(users: User[]): void,
  onLeave?(user: User): void,
}) {

  const users = ref<User[]>([])

  function listenDiffs({ leaves, joins }: UserDiff) {

    if (leaves) {
      Object.values(leaves).forEach(({ metas }) => {
        users.value.filter(user => user.id === metas.at(0)!.id).forEach(user => {
          onLeave(user)
        })
        users.value = users.value.filter(user => user.id !== metas[0].id)
      })
    }
    if (joins) {
      Object.values(joins)
        .filter(({ metas }) => metas.at(0)!.id !== toValue(userId))
        .forEach(async ({ metas }) => {
          const remoteUser = metas.at(0)!
          const user = {
            enableCamera: remoteUser.enable_camera || false,
            enableMicrophone: remoteUser.enable_microphone || false,
            rtcId: makeMyId(toValue(roomId), toValue(userId)),
            id: remoteUser.id,
            stream: new MediaStream(),
            username: remoteUser.username,
            email: remoteUser.email,
          }
          users.value = [user, ...users.value]
          onJoin(user)
      })
    }
  }

  onMounted(async () => {
    console.info('first users', users.value)
    users.value = await getUsers(channel)
    console.info('loaded users', users.value)
    channel.on('presence_diff', listenDiffs)
  })

  onUnmounted(() => {
    channel.off('presence_diff', listenDiffs)
  })

  return {
    users,
  }
}
