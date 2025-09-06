<script setup lang="ts">
import {
  defineAsyncComponent,
  onScopeDispose,
  onUnmounted,
  ref,
  toRaw
} from 'vue'
import RoomSidebar from './RoomSidebar.vue'
import { socket } from '@/socket'
import { config } from '@/lib/webrtc'
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

const joinedAt = new Date()

const RemoteMedia = defineAsyncComponent(() => import('./RemoteMedia.vue'))

type User = {
  id: number
  username: string
  email: string
  joined_at: Date
  peer: RTCPeerConnection
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
    .map(([_, { metas }]) => ({
      id: metas.at(0).id,
      stream: new MediaStream(),
      peer: new RTCPeerConnection(config),
      username: metas.at(0).username,
      email: metas.at(0).email,
      joined_at: new Date(metas.at(0).joined_at)
  }))
})


channel.on('offer_delivery', async delivery => {
  if (delivery.from_user_id === props.user.id) {
    return
  }
  console.info(delivery.from_user_id, toRaw(users.value))
  const fromUser = users.value.find(user => user.id === delivery.from_user_id)
  if (!fromUser) {
    throw new Error('offer: User by delivery not found: ' + JSON.stringify(delivery))
  }
  fromUser.peer.setRemoteDescription(delivery.offer)
  const answer = await fromUser.peer.createAnswer()
  await fromUser.peer.setLocalDescription(answer)
  console.info(fromUser.peer)
  channel.push('answer', {
    answer,
    from_user_id: props.user.id,
    to_user_id: fromUser.id
  })
})

channel.on('answer_delivery', async delivery => {
  console.info(delivery)
  const toUser = users.value.find(user => user.id === delivery.to_user_id)
  if (!toUser) {
    throw new Error('answer: User by delivery not found: ' + JSON.stringify(delivery))
  }
  toUser.peer.setRemoteDescription(delivery.answer)
})



channel.on('presence_diff', (diff) => {
  if (diff.joins) {
    Object.entries(diff.joins)
      .filter(([_, { metas }]) => metas.at(0).id !== props.user.id)
      .forEach(([_, { metas }]) => {
      if (!users.value.some(user => user.id === metas.at(0).id)) {
        users.value.push({
          stream: new MediaStream(),
          peer: new RTCPeerConnection(config),
          id: metas.at(0).id,
          username: metas.at(0).username,
          email: metas.at(0).email,
          joined_at: new Date(metas.at(0).joined_at)
        })

      }
    })
  }
  if (diff.leaves) {
    Object.entries(diff.leaves).forEach(([key, { metas }]) => {
      users.value = users.value.filter(user => user.id !== metas[0].id)
    })
  }
})

function addTracksToRtc(myStream: MediaStream) {
  const tracks = myStream.getTracks()

  users.value.forEach(user => {
    tracks.forEach(track => {
      user.peer.addTrack(track, myStream)
    })
    user.peer.addEventListener('track', (event) => {
      user.stream.addTrack(event.track)
    }, {
      signal: leavePageAbortController.signal
    })
  })
}


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
                    @update:stream="$event && addTracksToRtc($event)"
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
