
export function getVideoStream(): Promise<MediaStream> {
  return navigator.mediaDevices.getUserMedia({
    video: {
      width: { ideal: 400 }, // { max: 640 }
      height: { ideal: 250 },
      frameRate: { ideal: 24, max: 30 }
    },
  }).catch(error => {
    console.error('Error getting video stream:', error)
    return navigator.mediaDevices.getUserMedia({ video: true })
  }).catch(error => {
    console.error('Error getting video stream:', error)
    throw error
  })
}


export function getAudioStream(): Promise<MediaStream> {
  return navigator.mediaDevices.getUserMedia({
    audio: true
  }).catch(error => {
    console.error('Error getting audio stream:', error)
    throw error
  })
}


export const tracks = new EventTarget()
