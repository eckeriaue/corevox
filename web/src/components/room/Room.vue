<script setup lang="ts">
import {
  ref
} from 'vue'
import RoomSidebar from './RoomSidebar.vue'
import { socket } from '@/socket'
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

const isJoined = ref(false)

const channel = socket.channel(`rooms:${props.roomId}`, {
  params: { token: props.token }
})

const stream = ref<MediaStream | null>(null)
const enableCamera = ref(false)
const enableMicrophone = ref(false)


channel.join().receive('ok', (resp) => {
  isJoined.value = true
  console.log('Room joined successfully', resp)
}).receive('error', (resp) => {
  console.log('Unable to join room', resp)
})

</script>

<template>
    <room-sidebar
        :me="props.user"
        v-model:enable-camera="enableCamera"
        v-model:enable-microphone="enableMicrophone"
    >
        <suspense>
            <my-media v-model:stream="stream" v-model:enable-camera="enableCamera" v-model:enable-microphone="enableMicrophone" />
        </suspense>
    </room-sidebar>
</template>
