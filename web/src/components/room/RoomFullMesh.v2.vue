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
  onMounted,
} from 'vue'
import RoomSidebar from './RoomSidebar.vue'
import { socket } from '@/socket'
import { peerConfig } from '@/lib/webrtc'
import Peer from 'peerjs'
import MyMedia from './MyMedia.vue'
import type { User } from './User'
import { makeMyId } from './makeMyId'
import { getRoomUsers } from './getRoomUsers'


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

const users = ref<User[]>(await getRoomUsers(channel))
console.info(toRaw(users.value))
const stream = ref<MediaStream>(new MediaStream())
const enableCamera = ref(false)
const enableMicrophone = ref(false)
const rtcId = makeMyId(props.roomId, props.user.id)
const peer = new Peer(rtcId, peerConfig)

const RemoteMedia = defineAsyncComponent(() => import('./RemoteMedia.vue'))


</script>

<template>
<room-sidebar
    :users
    v-model:enable-camera="enableCamera"
    v-model:enable-microphone="enableMicrophone"
>
    <!-- @update:enable-microphone="streamMicrophone($event)" -->
    <!-- @update:enable-camera="streamCamera($event)" -->

    <ul class="grid grid-cols-3 gap-4 w-full">
        <my-media
            :username="user.username"
            :stream="stream"
            v-model:enable-camera="enableCamera"
            v-model:enable-microphone="enableMicrophone"
        />
    </ul>
</room-sidebar>
</template>
