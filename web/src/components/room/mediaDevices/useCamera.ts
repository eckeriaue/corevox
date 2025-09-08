import {
  ref,
  watch,
  nextTick,
  type Ref
} from 'vue'

import { getVideoStream, tracks } from './media'

export function useCamera(stream: Ref<MediaStream>, enableCamera: Ref<boolean>) {

  const isLoading = ref(false)

  async function streamCamera(enableCamera: boolean) {
    if (enableCamera) {
      const videoStream = await getVideoStream()
      videoStream.getVideoTracks()
        .filter(track => !stream.value.getTrackById(track.id))
        .forEach(track => {
          stream.value.addTrack(track)
          tracks.dispatchEvent(new CustomEvent('tracks:add-camera', {  }))
        })
    } else {
      stream.value.getVideoTracks().forEach(track => {
        track.enabled = false
        tracks.dispatchEvent(new CustomEvent('tracks:disable-camera', {  }))
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
