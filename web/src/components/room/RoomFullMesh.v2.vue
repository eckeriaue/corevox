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
import { sleep } from 'radashi'
import {
  makeMyId,
  getRoomUsers,
  useLiveUsers,
  type User } from './users'

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

const users = ref<User[]>(await getRoomUsers(channel))

const me = computed<User>(() => {
  return users.value.find(user => user.id === props.user.id) as User
})

const stream = ref<MediaStream>(new MediaStream())
const enableCamera = ref(me.value.enableCamera)
const enableMicrophone = ref(me.value.enableMicrophone)
const rtcId = makeMyId(props.roomId, props.user.id)
const peer = new Peer(rtcId, peerConfig)

watch([enableCamera, enableMicrophone], async ([enableCamera, enableMicrophone]) => {
  channel.push('change_user_media', {
    enable_camera: enableCamera,
    enable_microphone: enableMicrophone,
    user_id: props.user.id
  }).receive('ok', () => {
    console.log('Media changed successfully')
  }).receive('error', (reason: Error) => {
    console.error('Failed to change media', reason)
  })
})


useLiveUsers(
  toRef(props, 'roomId'),
  toRef(() => props.user.id),
  channel,
  users
)

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
            :my-stream="stream"
            :room-id
            :peer
            :="user"
        />
    </ul>
</room-sidebar>
</template>
