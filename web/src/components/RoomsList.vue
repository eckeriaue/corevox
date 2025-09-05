<script setup lang="ts">
import { onUnmounted, defineAsyncComponent, ref } from 'vue'
import { socket } from '@/socket'
import { useMe } from '@/lib'

type Room = {
  id: string,
  description: string,
  name: string
}

const CreateRoomButton = defineAsyncComponent(() => import('@/components/createRoom/CreateRoomButton.vue'))

const { isAuth } = useMe()

const status = ref<'loading' | 'loaded' | 'error'>('loading')
const rooms = ref<Room[]>([])

const channel = socket.channel('rooms:lobby')

channel.join().receive('ok', (payload: { rooms: Room[] }) => {
  rooms.value = payload.rooms
  status.value = 'loaded'
}).receive('error', (reason: Error) => {
  status.value = 'error'
  console.error('Failed to join', reason)
})

channel.on('room_created', ({ room }: { room: Room }) => {
  rooms.value.unshift(room)
  barba.go('/rooms/' + room.id)
})

onUnmounted(() => {
  channel.leave()
})

</script>

<template>
<section  style="height:calc(100dvh - 64px)">
    <div v-if="isAuth" class="mt-16 mx-auto w-fit">
        <create-room-button :channel />
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
            class="min-w-md mt-4"
        >
            <ul v-if="rooms.length > 0" class="list bg-base-100 rounded-box shadow-md">

              <li v-for="room in rooms" :key="room.id" class="list-row">
                <div></div>
                <div>
                  <div>{{ room.name }} </div>
                  <div v-if="room.description" class="text-xs uppercase font-semibold opacity-60"> {{ room.description }} </div>
                </div>
                <a :href="'/rooms/' + room.id" data-barba-prevent="self" class="btn btn-square btn-ghost">
                    <span class="ph ph-door-open" />
                </a>
              </li>
            </ul>

            <p v-else>Комнат пока нет</p>
        </div>
        <p v-else>Ошибка загрузки комнат</p>
    </div>
</section>
</template>
