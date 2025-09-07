<script setup lang="ts">
import {
  useTemplateRef,
  ref,
  watch,
  nextTick,
  onMounted,
  effectScope,
  onUnmounted
} from 'vue'

import MediaShortInfo from './MediaShortInfo.vue'

const props = defineProps<{
  username: string
}>()


const video = useTemplateRef<HTMLVideoElement>('video')

const isLoading = ref(true)

const stream = defineModel<MediaStream | null>('stream', { default: null })
const enableCamera = defineModel<boolean>('enableCamera', { default: false })
const enableMicrophone = defineModel<boolean>('enableMicrophone', { default: false })

async function loadMedia() {
  isLoading.value = true
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: true }).catch(() => null)
  isLoading.value = false
  await nextTick()
  return stream
}

const mediaControlsScope = effectScope()

onMounted(async () => {
  stream.value = await loadMedia()
  if (!stream.value) {
    return
  }
  await nextTick()
  if (!video.value) {
    await new Promise<void>(r => {
      watch(video, () => r(), { once: true })
    })
  }
  video.value!.srcObject = stream.value
  mediaControlsScope.run(() => {
    watch(enableCamera, enableCamera => {
      stream.value?.getTracks().filter(track => track.kind === 'video').forEach(track => {
        track.enabled = enableCamera
      })
    }, { immediate: true })

    watch(enableMicrophone, enableMicrophone => {
      stream.value?.getTracks().filter(track => track.kind === 'audio').forEach(track => {
        track.enabled = enableMicrophone
      })
    }, { immediate: true })
  })
})

onUnmounted(() => {
  mediaControlsScope.stop()
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
        <span v-if="isLoading" class="loading loading-spinner loading-xl"></span>
        <video
            v-else
            autoplay
            :hidden="!enableCamera"
            muted
            playsinline
            ref="video"
        />
    </div>
</template>
