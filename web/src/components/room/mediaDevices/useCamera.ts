import {
  ref,
  watch,
  nextTick,
  type Ref
} from 'vue'

import { getVideoStream } from './media'

export function useCamera(stream: Ref<MediaStream>, enableCamera: Ref<boolean>) {

  const isLoading = ref(false)

  async function streamCamera(enableCamera: boolean) {
    await nextTick()
    if (enableCamera) {
      const videoStream = await getVideoStream()
      videoStream.getVideoTracks()
        .filter(track => !stream.value.getTrackById(track.id))
        .forEach(track => {
          stream.value.addTrack(track)
        })
    } else {
      stream.value.getVideoTracks().forEach(track => {
        track.stop()
        stream.value.removeTrack(track)
      })
    }
  }

  watch(enableCamera, async (enableCamera) => {
    isLoading.value = true
    await streamCamera(enableCamera)
    await nextTick()
    isLoading.value = false
  })

  return {
    isLoading,
  }
}
