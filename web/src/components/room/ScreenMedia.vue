<script setup lang="ts">
import {
  useTemplateRef,
  watch,
  nextTick,
  ref
} from 'vue'

const props = defineProps<{
  rtcId: string
  stream: MediaStream
}>()

const video = useTemplateRef('video')

const isFullscreen = ref(false)

watch(video, async video => {
  await nextTick()
  video!.srcObject = props.stream
}, {
  once: true,
})

</script>

<template>

<div
    :class="{
      'ring-base-300': true,
      'ring-primary': false,
      'relative': !isFullscreen,
      'absolute z-30 top-0 left-0 w-[calc(100%_-_var(--spacing)_*_8)] m-4': isFullscreen
    }"
    class="ring-2 bg-base-300 isolate rounded-2xl flex items-center justify-center overflow-hidden"
    style="object-fit: cover; object-position: center; box-shadow: 2px 2px 0px 0px var(--color-neutral);"
    :style="!isFullscreen ? {
      aspectRatio: '16 / 10',
    } : {
      height: 'calc(100% - (var(--spacing) * 24))'
    }"
>
    <div class="absolute inset-2 flex flex-col justify-between size-[calc(100%_-_var(--spacing)*4)]">
        <div />
        <div class="flex justify-end w-full relative z-20">
            <button
                class="btn btn-square relative btn-ghost"
                type="button"
                @click="isFullscreen = !isFullscreen"
            >
                <span
                    class="ph ph-corners-out"
                />
            </button>
        </div>
    </div>
    <video
        autoplay
        :data-remote-video="props.rtcId"
        playsinline
        class="min-w-full"
        ref="video"
    />
</div>
</template>
