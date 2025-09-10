<script setup lang="ts">
import {
  defineAsyncComponent,
  watch,
  ref,
  onBeforeMount,
} from 'vue'
import RoomSidebar from './RoomSidebar.vue'
import { socket } from '@/socket'
import { peerConfig } from '@/lib/webrtc'
import { Peer } from 'peerjs'
import MyMedia from './MyMedia.vue'
import { Presence } from 'phoenix'
import {
  makeMyId,
  type User
} from './users'

import { withResolvers } from 'radashi'


const RemoteMedia = defineAsyncComponent(() => import('./RemoteMedia.vue'))

const props = defineProps<{
  roomId: string
  token: string
  user: Pick<User, 'id' | 'email' | 'username'>
}>()


const channel = socket.channel(`rooms:${props.roomId}`, {
  token: props.token
})

const users = ref<User[]>([])

channel.join().receive('ok', () => {
  console.log('Joined room')
}).receive('error', (reason: Error) => {
  console.error('Failed to join room:', reason)
}).receive('timeout', () => {
  console.error('Failed to join room: timeout')
})

const rtcId = makeMyId(props.roomId, props.user.id)

const stream = ref<MediaStream | undefined>()
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


const presence = new Presence(channel)


const enableCamera = ref(false)
const enableMicrophone = ref(false)

watch([enableCamera, enableMicrophone], ([enableCamera, enableMicrophone]) => {
  channel.push('change_user_media', {
    enable_camera: enableCamera,
    enable_microphone: enableMicrophone,
  })
})

onBeforeMount(() => {
  presence.onSync(() => {
    users.value = presence.list((_id, { metas }) => {
      type Meta = {
        id: number
        email: string
        enable_camera: boolean
        enable_microphone: boolean
        username: string
        phx_ref: string
      }
      const remoteUser: Meta = metas.at(0)
      const rtcId = makeMyId(props.roomId, remoteUser.id)

      prepareMedia.promise.then(() => {
        const call = peer.call(rtcId, stream.value!)
        call.on('stream', remoteStream => {
          const getId = () => `[data-remote-video=${call.peer}]`
          const videoElement = document.querySelector(getId())
          if (videoElement instanceof HTMLVideoElement && !videoElement.srcObject) {
            videoElement.srcObject = remoteStream
            videoElement.dispatchEvent(new CustomEvent('load-remote-stream', {}))
          }
        })
      })

      return {
        id: remoteUser.id,
        phx_ref: remoteUser.phx_ref,
        rtcId,
        email: remoteUser.email,
        enableCamera: remoteUser.enable_camera,
        enableMicrophone: remoteUser.enable_microphone,
        username: remoteUser.username
      }
    })
  })

  peer.on('call', async call => {
    await prepareMedia.promise
    call.answer(stream.value)
    call.on('stream', remoteStream => {
      const getId = () => `[data-remote-video=${call.peer}]`
      const videoElement = document.querySelector(getId())
      if (videoElement instanceof HTMLVideoElement && !videoElement.srcObject) {
        videoElement.srcObject = remoteStream
        videoElement.dispatchEvent(new CustomEvent('load-remote-stream', {}))
      }
    })
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
