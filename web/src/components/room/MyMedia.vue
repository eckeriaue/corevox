<script setup lang="ts">
import {
  useTemplateRef,
  watch,
} from 'vue'

import MediaShortInfo from './MediaShortData.vue'
import type { Peer } from 'peerjs'

const props = defineProps<{
  username: string
  peer: Peer
}>()


const video = useTemplateRef<HTMLVideoElement>('video')

const stream = defineModel<MediaStream | undefined>('stream', { required: true })
const enableCamera = defineModel<boolean>('enableCamera', { default: false })
const enableMicrophone = defineModel<boolean>('enableMicrophone', { default: false })

watch(enableCamera, enableCamera => {
  stream.value && stream.value.getVideoTracks().forEach(track => {
    track.enabled = enableCamera
  })
}, {
  immediate: true
})

watch(enableMicrophone, enableMicrophone => {
  stream.value && stream.value.getAudioTracks().forEach(track => {
    track.enabled = enableMicrophone
  })
}, {
  immediate: true
})


const { stop } = watch([video, stream], ([video, stream]) => {
  if (video && stream) {
    video!.srcObject = stream!
    stop()
  }
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
                :enable-camera="enableCamera"
                :enable-microphone="enableMicrophone"
                :username="`Вы (${props.username})`"
            />
        </div>
        <div v-if="!stream" class="absolute inset-0 size-full flex items-center justify-center">
            <span class="loading loading-spinner loading-xl"></span>
        </div>
        <video
            autoplay
            :hidden="!stream || !enableCamera"
            muted
            playsinline
            ref="video"
        />
    </div>
</template>
