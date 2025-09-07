<script setup lang="ts">
import { ref, toRef, useTemplateRef, watch, nextTick, computed } from 'vue'
import MediaShortInfo from './MediaShortData.vue'
import { makeMyId } from './users'

import type { Peer, MediaConnection } from 'peerjs'

const props = defineProps<{
  roomId: string
  id: number
  username: string
  email: string
  stream: MediaStream
  peer: Peer
  joined_at: Date
  enableCamera: boolean
  enableMicrophone: boolean
}>()

const video = useTemplateRef<HTMLVideoElement>('video')
const isLoading = ref(false)

watch(video, () => {
  video.value!.srcObject = props.stream
}, {
  once: true,
})


</script>

<template>
<div
    :class="{
      'ring-base-300': true,
      'ring-primary': false,
    }"
    class="relative ring-2 bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
    style="aspect-ratio: 16 / 10; object-fit: cover; object-position: center;"
>
    <div class="absolute inset-2 size-[calc(100%_-_var(--spacing)*4)]">
        <media-short-info
            :enable-camera="props.enableCamera"
            :enable-microphone="props.enableMicrophone"
            :username="props.username"
        />
    </div>
    <span v-if="isLoading" class="loading loading-spinner loading-xl"></span>
    <video
        autoplay
        :hidden="!props.enableCamera"
        :muted="!props.enableMicrophone"
        playsinline
        ref="video"
    />
</div>
</template>
