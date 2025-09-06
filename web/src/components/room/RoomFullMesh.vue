<script setup lang="ts">
import {
  computed,
  defineAsyncComponent,
  onUnmounted,
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

const RemoteMedia = defineAsyncComponent(() => import('./RemoteMedia.vue'))

const isJoined = ref(false)
// const makePresenceId = (userId: string) => `user:${userId}`
// const presenceUserId = computed(() => makePresenceId(props.user.id))

const channel = socket.channel(`rooms:${props.roomId}`, {
  token: props.token
})

const stream = ref<MediaStream | null>(null)
const users = ref<{ id: string; username: string; email: string; joined_at: number }[]>([])
const otherUsers = computed(() => users.value.filter(user => user.id !== props.user.id))
const enableCamera = ref(false)
const enableMicrophone = ref(false)

channel.join().receive('ok', (resp) => {
  isJoined.value = true
  console.log('Room joined successfully', resp)
}).receive('error', (resp) => {
  console.log('Unable to join room', resp)
})

channel.on('presence_state', (state) => {
  users.value = Object.entries(state).map(([key, data]) => ({
    id: data.metas.at(0).id,
    username: data.metas.at(0).username,
    email: data.metas.at(0).email,
    joined_at: data.metas.at(0).joined_at
  }))
})


channel.on('presence_diff', (diff) => {
  console.info(diff)
  if (diff.joins) {
    Object.entries(diff.joins).forEach(([key, data]) => {
      if (!users.value.some(user => user.id === data.metas[0].id)) {
        users.value.push({
          id: data.metas[0].id,
          username: data.metas[0].username,
          email: data.metas[0].email,
          joined_at: data.metas[0].joined_at
        })
      }
    })
  }
  if (diff.leaves) {
    Object.entries(diff.leaves).forEach(([key, data]) => {
      users.value = users.value.filter(user => user.id !== data.metas[0].id)
    })
  }
})


onUnmounted(() => {
  channel.leave()
})

</script>

<template>
    <room-sidebar
        :me="props.user"
        :users
        v-model:enable-camera="enableCamera"
        v-model:enable-microphone="enableMicrophone"
    >
        <ul class="grid grid-cols-3">
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
                v-for="user in otherUsers"
                :key="user.id"
                :="user"
            />
        </ul>



    </room-sidebar>
</template>
