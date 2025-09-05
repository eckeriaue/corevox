<script setup lang="ts">
import { onUnmounted, defineAsyncComponent, ref } from 'vue'
import { socket } from '../socket'
import { useMe } from '@/lib'

const CreateRoomButton = defineAsyncComponent(() => import('@/components/createRoom/CreateRoomButton.vue'))

const { isAuth } = useMe()

const status = ref<'loading' | 'loaded' | 'error'>('loading')
const rooms = ref([])

const channel = socket.channel('rooms:lobby', {})
channel.join().receive('ok', (payload: { rooms: [] }) => {
  rooms.value = payload.rooms
  status.value = 'loaded'
}).receive('error', (reason: Error) => {
  status.value = 'error'
  console.error('Failed to join', reason)
})

onUnmounted(() => {
  channel.leave()
})

</script>

<template>
<section  style="height:calc(100dvh - 64px)">
    <div v-if="isAuth" class="mt-16 mx-auto w-fit">
        <create-room-button />
    </div>
    <div class="flex items-center justify-center">
        <div
            v-if="status === 'loading'"
            class="flex flex-col items-center justify-center"
        >
            <p>Загрузка комнат...</p>
            <span class="loading loading-dots loading-xl"></span>
        </div>
        <div
            v-else-if="status === 'loaded'"
        >
            <ul v-if="rooms.length > 0">
                <li v-for="room in rooms" :key="room.id">{{ room.name }}</li>
            </ul>
            <p v-else>Комнат пока нет</p>
        </div>
        <p v-else>Ошибка загрузки комнат</p>
    </div>
</section>
</template>
