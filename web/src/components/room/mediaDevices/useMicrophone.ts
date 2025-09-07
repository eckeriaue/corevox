import type { Ref } from 'vue'
import { watch, ref, nextTick } from 'vue'
import { getAudioStream } from './media'

export function useMicrophone(stream: Ref<MediaStream>, enableMicrophone: Ref<boolean>) {
  const isLoading = ref(false)

  async function streamMicrophone(enableMicrophone: boolean) {
    await nextTick()
    if (enableMicrophone) {
      const audioStream = await getAudioStream()
      audioStream.getAudioTracks()
        .filter(track => !stream.value.getTrackById(track.id))
        .forEach(track => {
          stream.value.addTrack(track)
        })
    } else {
      stream.value.getAudioTracks().forEach(track => {
        track.stop()
        stream.value.removeTrack(track)
      })
    }
  }

  watch(enableMicrophone, async (enableMicrophone) => {
    isLoading.value = true
    await streamMicrophone(enableMicrophone)
    await nextTick()
    isLoading.value = false
  })


  return {
    isLoading,
  }
}
