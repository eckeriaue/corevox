<script setup lang="ts">
import { ref } from 'vue'
import MediaShortInfo from './MediaShortInfo.vue'

const props = defineProps<{
    stream: MediaStream
    peer: RTCPeerConnection
    joined_at: Date
    username: string
    id: number
    email: string
}>()

const isLoading = ref(true)

</script>

<template>
<div
    :class="{
      'ring-base-300': !false,
      'ring-primary': true,
    }"
    class="relative ring-2 bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
    style="aspect-ratio: 16 / 10; object-fit: cover; object-position: center;"
>
    <div class="absolute inset-2 size-[calc(100%_-_var(--spacing)*4)]">
        <media-short-info
            :enable-camera="false"
            :enable-microphone="false"
            :username="props.username"
        />
    </div>
    <span v-if="isLoading" class="loading loading-spinner loading-xl"></span>
    <video
        v-else
        autoplay
        muted
        playsinline
        ref="video"
    />
</div>
</template>
