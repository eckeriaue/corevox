<script setup lang="ts">
import RoomSidebar from './RoomSidebar.vue'

const props = defineProps<{
  roomId: string
}>()

</script>

<template>
    <room-sidebar>
        {{ props.roomId }}
    </room-sidebar>
</template>
