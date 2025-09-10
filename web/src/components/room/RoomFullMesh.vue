<script setup lang="ts">
import {
  defineAsyncComponent,
  watch,
  onScopeDispose,
  onUnmounted,
  ref,
  nextTick,
  toRaw,
  computed,
  toRef,
  onMounted,
} from 'vue'
import RoomSidebar from './RoomSidebar.vue'
import { socket } from '@/socket'
import { peerConfig } from '@/lib/webrtc'
import { Peer } from 'peerjs'
import MyMedia from './MyMedia.vue'
import {
  makeMyId,
  useUsers,
  type User
} from './users'

import { sleep, parseDuration, withResolvers } from 'radashi'

import {
  tracks,
} from './mediaDevices'

const RemoteMedia = defineAsyncComponent(() => import('./RemoteMedia.vue'))

const props = defineProps<{
  roomId: string
  token: string
  user: Pick<User, 'id' | 'email' | 'username'>
}>()


const channel = socket.channel(`rooms:${props.roomId}`, {
  token: props.token
})

channel.join().receive('ok', () => {
  console.log('Joined room')
}).receive('error', (reason: Error) => {
  console.error('Failed to join room:', reason)
}).receive('timeout', () => {
  console.error('Failed to join room: timeout')
})

const rtcId = makeMyId(props.roomId, props.user.id)

const stream = ref<MediaStream>()
const prepareMedia = withResolvers<MediaStream>()
navigator.mediaDevices.getUserMedia({ video: true, audio: true, })
.catch(() => {
  window.location.href = '/'
  throw new Error('receiving stream')
}).then(prepareStream => {
  prepareStream.getTracks().forEach(track => track.enabled = false)
  stream.value = prepareStream
  prepareMedia.resolve(stream.value)
})
const peer = new Peer(rtcId, peerConfig)

peer.on('call', async call => {
  await prepareMedia.promise
  call.answer(stream.value)
  call.on('stream', remoteStream => {
    console.info('remoteStream', remoteStream)
  })
})

const enableCamera = ref(false)
const enableMicrophone = ref(false)

const { users } = useUsers({
  channel,
  roomId: props.roomId,
  userId: props.user.id,
  async onJoin(user: User) {
    await prepareMedia.promise
    const call = peer.call(makeMyId(props.roomId, user.id), stream.value!)
    call.on('stream', stream => {
      console.info('join stream', stream)
    })
    },
  onLeave(user: User) {
    console.info('leave', user)
  }
})

</script>

<template>

<room-sidebar
    :users
    v-model:enable-camera="enableCamera"
    v-model:enable-microphone="enableMicrophone"
>

    <ul class="grid grid-cols-3 gap-4 w-full">
        <my-media
            :username="user.username"
            v-model:stream="stream"
            :peer
            v-model:enable-camera="enableCamera"
            v-model:enable-microphone="enableMicrophone"
        />
        <remote-media
            v-for="user in users.filter(user => user.id !== props.user.id)"
            :key="user.id"
            :room-id
            :="user"
        />
    </ul>
</room-sidebar>
</template>
