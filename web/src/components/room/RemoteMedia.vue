<script setup lang="ts">
import { ref } from 'vue'
import MediaShortInfo from './MediaShortData.vue'

const props = defineProps<{
  roomId: string
  id: number
  username: string
  email: string
  enableCamera: boolean
  rtcId: string
  enableMicrophone: boolean
}>()

const isLoading = ref(true)
const isFullscreen = ref(false)


</script>

<template>
<div
    :class="{
      'ring-base-300': true,
      'ring-primary': false,
      'relative': !isFullscreen,
      'absolute top-0 left-0 w-[calc(100%_-_var(--spacing)_*_8)] m-4': isFullscreen
    }"
    class="ring-2 bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
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
    <div class="absolute inset-2 flex flex-col justify-between size-[calc(100%_-_var(--spacing)*4)]">
        <media-short-info
            :enable-camera="props.enableCamera"
            :enable-microphone="props.enableMicrophone"
            :username="props.username"
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
     <span v-if="isLoading" class="loading loading-spinner loading-xl"></span>
    <video
        autoplay
        :hidden="!props.enableCamera"
        :muted="!props.enableMicrophone"
        :data-remote-video="props.rtcId"
        @load-remote-stream="isLoading = false"
        playsinline
        class="min-w-full"
        ref="video"
    />
</div>
</template>
