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

import { sleep, parseDuration } from 'radashi'

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
const stream = ref<MediaStream>(new MediaStream())
const peer = new Peer(rtcId, peerConfig)

async function getStream() {
  if (stream.value.getTracks().length < 1) {
    await Promise.race([
      new Promise(r => tracks.addEventListener('tracks:add-microphone', r, { once: true })),
      new Promise(r => tracks.addEventListener('tracks:add-camera', r, { once: true })),
      sleep(parseDuration('10s')).then(() => console.error('get tracks timeout'))
    ])
    return getStream()
  }
  return Promise.resolve(stream.value)
}

await new Promise(resolve => {
  peer.on('open', () => {
    resolve()
    peer.on('call', async call => {
      call.answer(stream.value)
      call.on('stream', async remoteStream => {
        remoteStream.getTracks().forEach(track => {
          // todo
        })
      })
    })
  })
})


const enableCamera = ref(false)
const enableMicrophone = ref(false)

const { users } = useUsers({
  channel,
  roomId: props.roomId,
  userId: props.user.id,
  async onJoin(user: User) {
    await nextTick()
    console.info('join', user)
    if (enableCamera.value || enableMicrophone.value) {
      const call = peer.call(user.rtcId, await getStream())
      console.info('call!', call)
    }
  },
  onLeave(user: User) {
    console.info('leave', user)
  }
})

const me = computed<User>(() => {
  return users.value.find(user => user.id === props.user.id) as User
})


watch([enableCamera, enableMicrophone], async ([enableCamera, enableMicrophone]) => {
  if (enableCamera || enableMicrophone) {
    if (stream.value.getTracks().length < 1) {
      await Promise.race([
        new Promise(r => tracks.addEventListener('tracks:add-microphone', r, { once: true })),
        new Promise(r => tracks.addEventListener('tracks:add-camera', r, { once: true })),
      ])
    }
    users.value.filter(user => user.id !== props.user.id).forEach(user => {
      const call = peer.call(makeMyId(props.roomId, user.id), stream.value)
      call.on('stream', remoteStream  => {
        const index = users.value.findIndex(user => makeMyId(props.roomId, user.id) === call.peer)
        remoteStream.getTracks().forEach(track => {
          users.value.at(index)!.stream.addTrack(track)
        })
        users.value = users.value
      })
    })
  }

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
