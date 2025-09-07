<script setup lang="ts">
import {
  useTemplateRef,
  watch,
  computed
} from 'vue'
import { useMicrophone, useCamera } from './mediaDevices'

import MediaShortInfo from './MediaShortData.vue'

const props = defineProps<{
  stream: MediaStream
  username: string
}>()


const video = useTemplateRef<HTMLVideoElement>('video')

const stream = defineModel<MediaStream>('stream', { required: true })
const enableCamera = defineModel<boolean>('enableCamera', { default: false })
const enableMicrophone = defineModel<boolean>('enableMicrophone', { default: false })

const microphone = useMicrophone(stream, enableMicrophone)
const camera = useCamera(stream, enableCamera)

const isLoading = computed(() => microphone.isLoading.value || camera.isLoading.value)

watch(video, video => {
  video!.srcObject = stream.value
}, {
  once: true,
})

</script>

<template>
    <div
        :class="{
          'ring-base-300': !enableMicrophone,
          'ring-primary': enableMicrophone,
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
        <div v-if="isLoading" class="absolute inset-0 size-full flex items-center justify-center">
            <span class="loading loading-spinner loading-xl"></span>
        </div>
        <video
            autoplay
            :hidden="!enableCamera || isLoading"
            muted
            playsinline
            ref="video"
        />
    </div>
</template>
