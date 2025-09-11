<script setup lang="ts">
import {
  useTemplateRef,
  watch,
  ref,
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

const isFullscreen = ref(false)

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
          'relative': !isFullscreen,
          'absolute top-0 left-0 w-[calc(100%_-_var(--spacing)_*_8)] m-4': isFullscreen
        }"
        class="ring-2 bg-base-300 border border-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
        style="
            object-fit: cover;
            object-position: center;
            box-shadow: 2px 2px 0px 0px var(--color-neutral), 1px 1px 0 0 inset rgba(255,255,255,.1);
        "
        :style="!isFullscreen ? {
          aspectRatio: '16 / 10',
        } : {
          height: 'calc(100% - (var(--spacing) * 24))'
        }"
    >
        <div class="absolute flex flex-col justify-between inset-2 size-[calc(100%_-_var(--spacing)*4)]">
            <media-short-info
                :enable-camera="enableCamera"
                :enable-microphone="enableMicrophone"
                :username="`Вы (${props.username})`"
            />
            <div class="flex justify-end w-full">
                <button
                    class="btn btn-square btn-ghost"
                    type="button"
                    @click="isFullscreen = !isFullscreen"
                >
                    <span
                        class="ph ph-corners-out"
                    />
                </button>
            </div>
        </div>
        <div v-if="!stream" class="absolute inset-0 size-full flex items-center justify-center">
            <span class="loading loading-spinner loading-xl"></span>
        </div>
        <video
            autoplay
            :hidden="!stream || !enableCamera"
            muted
            class="min-w-full"
            playsinline
            ref="video"
        />
    </div>
</template>
