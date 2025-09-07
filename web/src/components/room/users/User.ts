export type User = {
  id: number
  rtcId: string
  username: string
  email: string
  stream: MediaStream
  enableMicrophone: boolean
  enableCamera: boolean
}
