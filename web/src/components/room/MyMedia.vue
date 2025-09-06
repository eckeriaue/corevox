<script setup lang="ts">
import { useTemplateRef, ref, watch, nextTick, onMounted, triggerRef, effectScope, onUnmounted } from 'vue'

const video = useTemplateRef<HTMLVideoElement>('video')

const isLoading = ref(true)

const stream = defineModel<MediaStream | null>('stream', { default: null })
const enableCamera = defineModel<boolean>('enableCamera', { default: false })
const enableMicrophone = defineModel<boolean>('enableMicrophone', { default: false })

async function loadMedia() {
  isLoading.value = true
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: true })
  isLoading.value = false
  await nextTick()
  return stream
}

const mediaControlsScope = effectScope()

onMounted(async () => {
  stream.value = await loadMedia()
  await nextTick()
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
        class="bg-base-300 rounded-2xl flex items-center justify-center overflow-hidden"
        style="width:300px;height:200px; object-fit: cover; object-position: center;"
    >
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
