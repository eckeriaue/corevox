<script setup lang="ts">
import {
  defineAsyncComponent,
  nextTick,
  watch,
  onScopeDispose,
  onUnmounted,
  ref,
  toRaw
} from 'vue'
import RoomSidebar from './RoomSidebar.vue'
import { socket } from '@/socket'
import { peerConfig } from '@/lib/webrtc'
import Peer from 'peerjs'
import MyMedia from './MyMedia.vue'

const props = defineProps<{
  roomId: string
  token: string
  user: {
    id: string
    email: string
    username: string
  }
}>()


const RemoteMedia = defineAsyncComponent(() => import('./RemoteMedia.vue'))

type User = {
  id: number
  username: string
  email: string
  joined_at: Date
  stream: MediaStream
}

const isJoined = ref(false)
// const makePresenceId = (userId: string) => `user:${userId}`
// const presenceUserId = computed(() => makePresenceId(props.user.id))

const channel = socket.channel(`rooms:${props.roomId}`, {
  token: props.token
})

const stream = ref<MediaStream | null>(null)
const users = ref<User[]>([])
const enableCamera = ref(false)
const enableMicrophone = ref(false)

const makeRoomId = (userId: string | number) => `room-${props.roomId}-user-${userId}`

const peer = new Peer(makeRoomId(props.user.id), peerConfig)

peer.on('open', (id) => {
  console.log('Peer ID:', id)
})
peer.on('connection', (conn) => {
  conn.on('data', (data) => {
    console.log('Received from', conn.peer, data)
  })
})


const leavePageAbortController = new AbortController()

channel.join().receive('ok', (resp) => {
  isJoined.value = true
  console.log('Room joined successfully', resp)
}).receive('error', (resp) => {
  console.log('Unable to join room', resp)
})

channel.on('presence_state', (state) => {
  users.value = Object.entries(state)
    .filter(([_, { metas }]) => metas.at(0).id !== props.user.id)
    .map(([_, { metas }]) => {
      const connection = peer.connect(makeRoomId(metas.at(0).id))
      connection.on('open', () => {
        console.log('Connected to', metas.at(0).id)
        connection.send({ type: 'hello', from: props.user.id })
      })
      connection.on('data', (data) => {
        console.log('Message from', metas.at(0).id, data)
      })


      return {
        id: metas.at(0).id,
        stream: new MediaStream(),
        username: metas.at(0).username,
        email: metas.at(0).email,
        joined_at: new Date(metas.at(0).joined_at)
    }
    })
})


channel.on('presence_diff', (diff) => {
  if (diff.joins) {
    Object.entries(diff.joins)
      .filter(([_, { metas }]) => metas.at(0).id !== props.user.id)
      .forEach(async ([_, { metas }]) => {
      if (!users.value.some(user => user.id === metas.at(0).id)) {
        if(!stream.value) {
          await new Promise<void>((r) => {
            watch(stream, () => r(), { once: true })
          })
        }

        users.value.push({
          stream: new MediaStream(),
          id: metas.at(0).id,
          username: metas.at(0).username,
          email: metas.at(0).email,
          joined_at: new Date(metas.at(0).joined_at)
        })
      }
    })
  }
  if (diff.leaves) {
    Object.entries(diff.leaves).forEach(([_, { metas }]) => {
      users.value = users.value.filter(user => user.id !== metas[0].id)
    })
  }
})


onScopeDispose(() => {
  channel.leave()
  leavePageAbortController.abort()
})
onUnmounted(() => {
  channel.leave()
  leavePageAbortController.abort()
})

</script>

<template>
    <room-sidebar
        :me="props.user"
        :users
        v-model:enable-camera="enableCamera"
        v-model:enable-microphone="enableMicrophone"
    >
        <ul class="grid grid-cols-3 gap-4 w-full">
            <suspense>
                <my-media
                    :username="props.user.username"
                    v-model:stream="stream"
                    v-model:enable-camera="enableCamera"
                    v-model:enable-microphone="enableMicrophone"
                />
                <template #fallback>
                    <div
                        class="ring-2 bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
                        style="width:300px;height:200px; object-fit: cover; object-position: center;"
                    >
                        <span class="loading loading-spinner loading-xl"></span>
                    </div>
                </template>
            </suspense>

            <remote-media
                v-for="user in users"
                :key="user.id"
                :="user"
            />
        </ul>



    </room-sidebar>
</template>
