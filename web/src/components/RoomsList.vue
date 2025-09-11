<script setup lang="ts">
import { onUnmounted, defineAsyncComponent, ref } from 'vue'
import { socket } from '@/socket'

const props = defineProps({
  ownerId: Number,
})

type Room = {
  id: string,
  description: string,
  name: string
}

const CreateRoomButton = defineAsyncComponent(() => import('@/components/createRoom/CreateRoomButton.vue'))

const status = ref<'loading' | 'loaded' | 'error'>('loading')
const rooms = ref<Room[]>([])

const channel = socket && socket.channel('rooms:lobby')

channel && channel.join().receive('ok', (payload: { rooms: Room[] }) => {
  rooms.value = payload.rooms
  status.value = 'loaded'
}).receive('error', (reason: Error) => {
  status.value = 'error'
  console.error('Failed to join', reason)
})

channel && channel.on('room_created', ({ room }: { room: Room }) => {
  rooms.value.unshift(room)
})

onUnmounted(() => {
  channel && channel.leave()
})

</script>

<template>
<section  style="height:calc(100dvh - 64px)">
    <div v-if="props.ownerId" class="mt-16 mx-auto w-fit">
        <create-room-button :ownerId="props.ownerId" :channel="channel!" />
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
            <ul
                v-if="rooms.length > 0"
                class="list bg-base-100 rounded-box"
                style="
                    box-shadow: 2px 2px 0px 0px var(--color-neutral), 1px 1px 0 0 inset rgba(255,255,255,.1);
                "
            >

              <li v-for="room in rooms" :key="room.id" class="list-row">
                <div></div>
                <div>
                  <span>{{ room.name }} </span>
                  <div class="text-xs font-semibold opacity-60"> {{ room.description || 'Без описания' }} </div>
                </div>
                <a
                    v-if="props.ownerId"
                    :href="'/rooms/' + room.id"
                    class="btn btn-square btn-ghost"
                >
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
